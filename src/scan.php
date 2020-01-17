<?php
$dir      = 'files';
$response = scan($dir);
function scan($dir)
{
    $files = [];
    if (file_exists($dir)) {
        foreach (scandir($dir) as $f) {
            if (!$f || $f[0] == '.') {
                continue;
            }
            if (is_dir($dir . DIRECTORY_SEPARATOR . $f)) {
                $files[] = [
                    'name'  => $f,
                    'type'  => 'folder',
                    'path'  => $dir . DIRECTORY_SEPARATOR . $f,
                    'items' => scan($dir . DIRECTORY_SEPARATOR . $f)
                ];
            } else {
                $files[] = [
                    'name' => $f,
                    'type' => 'file',
                    'path' => $dir . DIRECTORY_SEPARATOR . $f,
                    'size' => filesize($dir . DIRECTORY_SEPARATOR . $f)
                ];
            }
        }

    }
    return $files;
}

header('Content-type: application/json');
echo json_encode([
    'name'  => 'files',
    'type'  => 'folder',
    'path'  => $dir,
    'items' => $response
]);
