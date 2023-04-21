<?php

declare(strict_types=1);

//convert all warnings and notices in to errors, if PHP is configured to report them.
set_error_handler(function ($severity, $message, $file, $line) {
    if (!(error_reporting() & $severity)) {
        return;
    }
    throw new \ErrorException($message, 0, $severity, $file, $line);
});


try {
    require_once __DIR__ . '/../vendor/autoload.php';

    //start your application here.
    throw new \Exception('Check out this error page!');

} catch (\Throwable $error) {
    //This is the last line of defence do not use any dependencies that could break.

    $errorInfo = [//for developers eyes only
        'Error' => $error->getMessage(),
        ' file' => $error->getFile(),
        ' line' => $error->getLine(),
        'trace' => $error->getTrace(),
        ' http' => $_SERVER['REQUEST_METHOD'] . ': ' . $_SERVER['REQUEST_URI']
    ];
    if ($error->getPrevious()) {
        $errorInfo['cause'] = $error->getPrevious()->getTraceAsString();
    }

    //log the error
    error_log(json_encode($errorInfo));

    //construct error response.
    http_response_code(500);
    $errorResponse = ['error' => ['message' => 'Internal server error']];
    $encodingOptions = JSON_UNESCAPED_SLASHES;

    //extra info for developers.
    $developerMode = (stripos($_SERVER['HTTP_HOST'], 'localhost') !== false);
    if ($developerMode) {
        $errorResponse['error_details'] = $errorInfo;
        $encodingOptions = $encodingOptions | JSON_PRETTY_PRINT;
    }

    //respond with JSON if appropriate
    if ($_SERVER['REQUEST_METHOD'] !== 'GET' || ($_SERVER['HTTP_ACCEPT'] ?? null) === 'application/json') {
        echo json_encode($errorResponse, $encodingOptions);
        return;
    }

    //otherwise assume we want a nice html error page.
    include __DIR__ . '/500.php';
    if ($developerMode) {
        echo "<pre style='z-index: 99999999999999999;'>";
        echo json_encode($errorResponse, $encodingOptions);
        echo "</pre>";
    }
}

?>

<style>
    <?=
    //including it via php prevents the page flashing white before the css file is processed.
    include __DIR__ . '/css/global.css';
    ?>
</style>