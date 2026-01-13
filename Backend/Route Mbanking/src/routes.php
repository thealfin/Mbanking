<?php

use Slim\Http\Request;
use Slim\Http\Response;
use \Firebase\JWT\JWT;
 
$app->get('/login', function($request, $response, $datae){
	$time = time(); //untuk waktu saat ini
	$exp = $time+3600; //untuk waktu exp token diitung detik
    $settings = $this->get('settings'); // get settings array.
    
    $token = JWT::encode(['id' => '0001', 'hp' => '087859085520', 'kota'=>'malang', "iat"=>$time, "exp"=>$exp], $settings['jwt']['secret'], "HS256");
 
    return $this->response->withJson(['token' => $token]);
}); 


$app->post('/login', function (Request $request, Response $response, array $args) {
 
    $input = $request->getParsedBody();
    $sql = "SELECT * FROM users WHERE email= :email";
    $sth = $this->db->prepare($sql);
    $sth->bindParam("email", $input['email']);
    $sth->execute();
    $user = $sth->fetchObject();
 
    // verify email address.
    if(!$user) {
        return $this->response->withJson(['error' => true, 'message' => 'These credentials do not match our records.']);  
    }
 
    // verify password.
    if (!password_verify($input['password'],$user->password)) {
        return $this->response->withJson(['error' => true, 'message' => 'These credentials do not match our records.']);  
    }
 
    $settings = $this->get('settings'); // get settings array.
    
    $token = JWT::encode(['id' => $user->id, 'email' => $user->email], $settings['jwt']['secret'], "HS256");
 
    return $this->response->withJson(['token' => $token]);
 
});

$app->group('/api', function(\Slim\App $app) {
 
    $app->get('/user',function(Request $request, Response $response, array $args) {
        print_r($request->getAttribute('decoded_token_data'));
         /*output 
        stdClass Object
            (
                [id] => 2
                [email] => arjunphp@gmail.com
            )
                    
        */
    });
	
	$app->get('/tes', function($request, $response, $datae){
		echo 'cuman ngetes token';
	}); 
	
	#menampilkan data dari database dinkop table koperasi
	$app->get('/koperasi', function($request, $response, $datae){
		$hasil = $this->db->query("select * from koperasi")->fetchAll(PDO::FETCH_ASSOC);
		$json=json_encode($hasil);
			print_r($json);
	});
   
});

// Routes
/*
$app->get('/[{name}]', function (Request $request, Response $response, array $args) {
    // Sample log message
    $this->logger->info("Slim-Skeleton '/' route");

    // Render index view
    return $this->renderer->render($response, 'index.phtml', $args);
});
*/