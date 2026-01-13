<?php

use Slim\Http\Request;
use Slim\Http\Response;
use \Firebase\JWT\JWT;
 
$app->get('/', function($request, $response, $datae){
	return "lain-lain";
}); 


#sumber https://github.com/shuchkin/simplexlsx/
$app->get('/bacafilexlsx', function($request, $response, $datae){
	echo SimpleXLSX::parse('tes.xlsx')->toHTML();
}); 

$app->get('/tablexlsx', function($request, $response, $datae){
if ( $xlsx = SimpleXLSX::parse('tes.xlsx') ) {
	echo '<table border="1" cellpadding="3" style="border-collapse: collapse">';
	foreach( $xlsx->rows() as $r ) {
		echo '<tr><td>'.implode('</td><td>', $r ).'</td></tr>';
	}
	echo '</table>';
} else {
	echo SimpleXLSX::parseError();
}
}); 

$app->get('/rowsex', function($request, $response, $datae){
	$arraye=SimpleXLSX::parse('tes.xlsx')->rowsEx() ;
	print json_encode($arraye);
}); 


#tampilkan data dengan header (baris awal) sebagai key nya
$app->get('/byheader', function($request, $response, $datae){
if ( $xlsx = SimpleXLSX::parse('tes.xlsx')) {
	// Produce array keys from the array values of 1st array element
	$header_values = $arraye = [];
	foreach ( $xlsx->rows() as $k => $r ) {
		if ( $k === 0 ) {
			$header_values = $r;
			continue;
		}
		$arraye[] = array_combine( $header_values, $r );
	}
	print json_encode($arraye);
}
}); 



