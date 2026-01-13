<?php

use Slim\Http\Request;
use Slim\Http\Response;
use \Firebase\JWT\JWT;

//seluruh data
$app->get('/kategori', function ($request, $response, $datae) {
    $hasil = $this->db->query("select category_name from categories")->fetchAll(PDO::FETCH_ASSOC);
    $json = json_encode($hasil);
    print_r($json);
});

//tampil filter berdasar variabel
$app->get('/kategori/{filterx}', function($request, $response, $datae){

    $var1 = $datae['filterx'];

    $hasil = $this->db->query("select category_name from categories where category_name like '%$var1%'")->fetchAll(PDO::FETCH_ASSOC);
    $json = json_encode($hasil);
    print_r($json);
});
