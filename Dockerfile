FROM alpine:3.10
LABEL Maintainer="AlicFeng <a@samego.com>" \
      Description="NP container with Nginx 1.16 & PHP-FPM 7.3 based on Alpine Linux"

# env list
ENV TIMEZONE=Asia/Shanghai

# create container entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# install dependent app including php,nginx,composer
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    # install evn dependence
    apk --no-cache add --virtual .build-deps \
        tzdata \
        gnupg \
    # install php nginx supervisor
    && apk --no-cache add php7 php7-fpm \
        php7-openssl php7-json php7-curl \
        php7-zlib php7-phar php7-intl php7-dom \
        php7-ctype php7-session php7-mbstring \
        nginx \
        supervisor  \
    # timezone
    && ln -snf /usrx/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    # create www.www and configuration for application
    && addgroup -S www \
    && adduser -D -S -h /var/cache/www -s /sbin/nologin -G www www \
    && mkdir -p /var/www/app /run/nginx \
    && chown -R www.www /run \
    && chown -R www.www /var/lib/nginx \
    && chown -R www.www /var/tmp/nginx \
    && chown -R www.www /var/log/nginx \
    # clean
    && apk del .build-deps -f \
    && rm -rf /tmp/* /var/cache/apk/*

# configure php-fpm
COPY php/php-fpm.d/www.conf /etc/php7/php-fpm.d/www.conf
COPY php/conf.d/php.ini /etc/php7/conf.d/php.ini
# configure supervisord
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# configure nginx
COPY nginx/conf.d/ /etc/nginx/conf.d/
# add application
COPY --chown=www:www src /var/www/app
COPY --chown=www:www files /var/www/app/files


WORKDIR /var/www/app
EXPOSE 80 443
CMD ["docker-entrypoint.sh"]
