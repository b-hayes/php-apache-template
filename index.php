<?php

declare(strict_types=1);

//If the host forced the entire source code to be public, the main .htaccess file will redirect back here.
//so change the active dir and include the real index file as if the request landed there.
chdir(__DIR__ . '/public');
require_once __DIR__ . '/public/index.php';