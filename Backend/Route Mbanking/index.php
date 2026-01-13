<?php
// ... use Slim ...

// Script Anti-Blokir Browser (CORS)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header('HTTP/1.1 200 OK');
    exit;
}

// ... kode $app = new \Slim\App ...

if (PHP_SAPI == 'cli-server') {
    // To help the built-in PHP dev server, check if the request was actually for
    // something which should probably be served as a static file
    $url  = parse_url($_SERVER['REQUEST_URI']);
    $file = __DIR__ . $url['path'];
    if (is_file($file)) {
        return false;
    }
}

require __DIR__ . '/vendor/autoload.php';

session_start();

// Instantiate the app
$settings = require __DIR__ . '/src/settings.php';
$app = new \Slim\App($settings);

// Set up dependencies
require __DIR__ . '/src/dependencies.php';

// Register middleware
require __DIR__ . '/src/middleware.php';

// Register routes
require __DIR__ . '/src/routes_xlsx.php';
require __DIR__ . '/src/routes_opentbs.php';
require __DIR__ . '/src/routes_kategori.php'; //-> didaftarkan baru
require __DIR__ . '/src/routes_toko_madura.php'; //-> didaftarkan baru
require __DIR__ . '/src/routes_mbanking.php'; //-> didaftarkan baru


// Run app
$app->run();

