<?php

declare(strict_types=1);

//convert all warnings and notices in to errors, if PHP is configured to report them.
set_error_handler(function ($severity, $message, $file, $line) {
    if (!(error_reporting() & $severity)) {
        return;
    }
    throw new \ErrorException($message, 0, $severity, $file, $line);
});

$host = explode(':', $_SERVER['HTTP_HOST'])[0]; // strip port if present
$developerMode = str_ends_with($host, 'localhost') || str_ends_with($host, '.local');
$jsonEncodeOptions = JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR;
if ($developerMode) {
    $jsonEncodeOptions |= JSON_PRETTY_PRINT;
}

// Catch fatal errors that crash php before any catch block can handle them.
register_shutdown_function(function () use ($developerMode, $jsonEncodeOptions) {
    $error = error_get_last();
    error_log('Fatal Error: ' . json_encode($error));
    ob_clean();
    if (!headers_sent()) http_response_code(500);
    echo '<h3>Fatal Server Error</h3>';
    if ($developerMode) {
        echo "<pre>" . json_encode($error, $jsonEncodeOptions) . "</pre>";
    }
});


$jsonRequest = str_contains($_SERVER['HTTP_ACCEPT'] ?? '', 'application/json')
    || str_contains($_SERVER['CONTENT_TYPE'] ?? '', 'application/json')
    || $_SERVER['REQUEST_METHOD'] !== 'GET';

try {
    //TODO: Uncomment this line if you are using composer libraries.
    //require_once __DIR__ . '/../vendor/autoload.php';

    if (!$jsonRequest) {
        // add common head tags here. Browser should merge them with whatever your app returns.
        echo <<<HTML
            <!DOCTYPE html>
            <head>
                <link rel="icon" type="image/png" href="/favicon.png">
                <link rel="stylesheet" href="/css/reset.css">
            </head>
            HTML;
    }
    //start your application here.
    throw new \Exception('Check out this error page!');

} catch (\Throwable $error) {
    //This is the last line of defense do not use any dependencies that could break.

    // Redact sensitive fields from trace arrays before logging
    $sanitize = function (mixed $data) use (&$sanitize): mixed {
        if (!is_array($data)) return $data;
        foreach ($data as $key => $value) {
            if (is_string($key) && stripos($key, 'password') !== false) {
                $data[$key] = '[REDACTED]';
            } else {
                $data[$key] = $sanitize($value);
            }
        }
        return $data;
    };

    $errorInfo = [
        'Error' => $error->getMessage(),
        ' file' => $error->getFile(),
        ' line' => $error->getLine(),
        'trace' => $sanitize($error->getTrace()),
        ' http' => $_SERVER['REQUEST_METHOD'] . ': ' . $_SERVER['REQUEST_URI']
    ];
    // Collect all previous exceptions recursively
    $causes = [];
    $prev = $error->getPrevious();
    while ($prev) {
        $causes[] = [
            'message' => $prev->getMessage(),
            'file'    => $prev->getFile(),
            'line'    => $prev->getLine(),
            'trace'   => $prev->getTraceAsString()
        ];
        $prev = $prev->getPrevious();
    }
    if ($causes) {
        $errorInfo['causes'] = $causes;
    }

    //log the error
    error_log(json_encode($errorInfo));

    //construct error response.
    if (!headers_sent()) http_response_code(500);
    $errorResponse = ['error' => ['message' => 'Internal server error']];

    //extra info for developers.
    if ($developerMode) {
        $errorResponse['error_details'] = $errorInfo;
    }

    //respond with JSON if appropriate
    if ($jsonRequest) {
        if (!headers_sent()) header('Content-Type: application/json');
        echo json_encode($errorResponse, $jsonEncodeOptions);
        return;
    }

    //otherwise assume we want a nice HTML error page.
    include __DIR__ . '/500.php';
    if ($developerMode) {
        echo "<pre style='z-index: 99999999999999999;'>";
        echo json_encode($errorResponse, $jsonEncodeOptions);
        echo "</pre>";
    }
}
?>
<style>
    <?php
    //injecting basic styles directly to prevent flash-banging dark mode users before the rest of the CSS loads.
    include __DIR__ . '/css/global.css';
    ?>
</style>
