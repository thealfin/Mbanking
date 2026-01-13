<?php
// DIC configuration

$container = $app->getContainer();

// view renderer
$container['renderer'] = function ($c) {
    $settings = $c->get('settings')['renderer'];
    return new Slim\Views\PhpRenderer($settings['template_path']);
};

// monolog
$container['logger'] = function ($c) {
    $settings = $c->get('settings')['logger'];
    $logger = new Monolog\Logger($settings['name']);
    $logger->pushProcessor(new Monolog\Processor\UidProcessor());
    $logger->pushHandler(new Monolog\Handler\StreamHandler($settings['path'], $settings['level']));
    return $logger;
};

// buat container untuk database PDO toko_madura
// $container['db'] = function(){
//     return new PDO('mysql:host=localhost;dbname=barang', 'root', '');
// };

// Buat container untuk database PDO mbanking
$container['db'] = function(){
    // Pastikan nama dbname=mbanking (sesuai nama database lo di phpMyAdmin/Navicat)
    $pdo = new PDO('mysql:host=localhost;dbname=m-banking', 'root', '');
    
    // Tambahan setting biar errornya jelas kelihatan (opsional tapi ngebantu banget)
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    
    return $pdo;
};

// Yang 'db_mbanking' dihapus aja biar gak bingung, kan kita udah pake 'db' utama