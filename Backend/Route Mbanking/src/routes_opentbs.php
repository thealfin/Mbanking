<?php

use Slim\Http\Request;
use Slim\Http\Response;
use \Firebase\JWT\JWT;

$app->get('/opentbs', function ($request, $response, $datae) {


    //inisialisasi opentbs
    $TBS = new clsTinyButStrong; // new instance of TBS
    $ok = class_exists('clsOpenTBS', true);
    $TBS->Plugin(TBS_INSTALL,  OPENTBS_PLUGIN); // load the OpenTBS plugin

    $datawaktu = array('tanggal' => '15 juni 2021');
    $dataname = array('nama' => 'Muhammad Fatur Rohima Kaharunia');
    $datanim = array('nim' => '1903040006');

    $template = 'template.xlsx';
    $TBS->LoadTemplate($template, OPENTBS_ALREADY_UTF8); // Also merge some [onload] automatic fields (depends of the type of
    // Merge data in the body of the document

    // $TBS->MergeBlock('data', $data);
    $TBS->MergeField('waktu', $datawaktu);
    $TBS->MergeField('name', $dataname);
    $TBS->MergeField('nim', $datanim);


    // -----------------
    // Output the result
    // -----------------

    // $TBS->Show(OPENTBS_DOWNLOAD, 'hasil.xlsx'); // untuk download
    $TBS->Show(OPENTBS_FILE, 'hasil3333.xlsx'); //untuk simpan di server

    echo "tersimpan!";
});
