<?php

use Slim\Http\Request;
use Slim\Http\Response;
use \Firebase\JWT\JWT;

// 1. TAMPILKAN SELURUH DATA (JOIN KATEGORI & SATUAN)
$app->get('/toko_madura', function ($request, $response, $datae) {
    // Kita perlu join ke tabel satuan biar frontend tau nama satuannya apa (misal: "Pcs")
    // karena di tabel barang isinya cuma angka ID (misal: "1")
    $sql = "SELECT b.*, k.nama_kategori, s.nama_satuan 
            FROM barang b
            LEFT JOIN kategori k ON b.id_kategori = k.id_kategori
            LEFT JOIN satuan s ON b.id_satuan = s.id_satuan
            ORDER BY b.id_barang DESC";

    $hasil = $this->db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    $json = json_encode($hasil);
    print_r($json);
});

// 2. TAMPIL FILTER BERDASAR VARIABEL (Search Nama)
$app->get('/toko_madura/{filterx}', function($request, $response, $datae){
    $var1 = $datae['filterx'];
    // Join juga disini biar lengkap outputnya
    $sql = "SELECT b.*, s.nama_satuan 
            FROM barang b 
            LEFT JOIN satuan s ON b.id_satuan = s.id_satuan
            WHERE b.nama_barang LIKE '%$var1%'";
            
    $hasil = $this->db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    $json = json_encode($hasil);
    print_r($json);
});

// 3. TAMPILKAN FILTER BERDASARKAN ID SATUAN (Update logika pencarian)
$app->get('/toko_madura/satuan/{satuanx}', function($request, $response, $datae){
    $var1 = $datae['satuanx']; // Ini diasumsikan ID atau Nama
    
    // Kita cari berdasarkan nama satuan di tabel relasi
    $sql = "SELECT b.nama_barang, s.nama_satuan 
            FROM barang b
            JOIN satuan s ON b.id_satuan = s.id_satuan
            WHERE s.nama_satuan LIKE '%$var1%'";

    $hasil = $this->db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    $json = json_encode($hasil);
    print_r($json);
});

// 4. MENAMBAHKAN DATA TRANSAKSI
$app->post('/toko_madura/transaksi', function($request, $response, $datae){
    $datakiriman = $request->getParsedBody();
    $tanggal_transaksi = $datakiriman['tanggal_transaksi'];
    $total_bayar = $datakiriman['total_bayar'];
    
    $hasil = $this->db->query("INSERT INTO transaksi (tanggal_transaksi, total_bayar)
    VALUES ('$tanggal_transaksi', '$total_bayar');");
    
    echo 'transaksi telah sukses';
});

// 5. MENAMBAH DATA BARANG (REVAMPED: Pakai id_satuan)
$app->post('/toko_madura', function($request, $response, $datae){
    $datakiriman = $request->getParsedBody();
    
    $id_kategori = $datakiriman['id_kategori'];
    $id_satuan   = $datakiriman['id_satuan']; // UBAH: Ambil ID Satuan
    $nama_barang = $datakiriman['nama_barang'];
    $harga_beli  = $datakiriman['harga_beli'];
    $harga_jual  = $datakiriman['harga_jual'];
    $stok        = $datakiriman['stok'];

    // Insert menggunakan id_satuan
    $sql = "INSERT INTO barang (id_kategori, id_satuan, nama_barang, harga_beli, harga_jual, stok)
            VALUES ('$id_kategori', '$id_satuan', '$nama_barang', '$harga_beli', '$harga_jual', '$stok')";

    $hasil = $this->db->query($sql);

    echo 'Data barang telah berhasil ditambahkan';
});

// 6. UPDATE DATA BARANG (REVAMPED: Pakai id_satuan)
$app->put('/toko_madura/{id_barang}', function($request, $response, $datae){
    $id_barang = $datae['id_barang'];
    $datakiriman = $request->getParsedBody();

    $id_kategori = $datakiriman['id_kategori'];
    $id_satuan   = $datakiriman['id_satuan']; // UBAH: Ambil ID Satuan
    $nama_barang = $datakiriman['nama_barang'];
    $harga_beli  = $datakiriman['harga_beli'];
    $harga_jual  = $datakiriman['harga_jual'];
    $stok        = $datakiriman['stok'];

    // Update query menggunakan id_satuan
    $sql = "UPDATE barang SET 
        id_kategori = '$id_kategori',
        id_satuan = '$id_satuan', 
        nama_barang = '$nama_barang',
        harga_beli = '$harga_beli',
        harga_jual = '$harga_jual',
        stok = '$stok'
        WHERE id_barang = '$id_barang'";

    $hasil = $this->db->query($sql);
    
    echo 'Data barang telah berhasil diupdate';
});

// 7. MENGHAPUS DATA BARANG
$app->delete('/toko_madura/{id_barang}', function($request, $response, $datae){
    $id_barang = $datae['id_barang'];
    $hasil = $this->db->query("delete from barang where id_barang = '$id_barang'");
    echo 'Data barang telah berhasil dihapus';
});


// --- HALAMAN REPORT & API PENDUKUNG ---

// A. Laporan Stok Lengkap
$app->get('/toko_madura/laporan/stok', function($request, $response){
    // Join juga ke satuan biar reportnya enak dibaca
    $sql = "SELECT b.*, k.nama_kategori, s.nama_satuan
            FROM barang b 
            LEFT JOIN kategori k ON b.id_kategori = k.id_kategori 
            LEFT JOIN satuan s ON b.id_satuan = s.id_satuan
            ORDER BY b.stok ASC";
            
    $hasil = $this->db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    
    return $response->withHeader('Content-Type', 'application/json')
                    ->write(json_encode($hasil));
});

// B. Laporan Transaksi
$app->get('/toko_madura/laporan/transaksi', function($request, $response){
    $sql = "SELECT * FROM transaksi ORDER BY tanggal_transaksi DESC";
    $hasil = $this->db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    
    return $response->withHeader('Content-Type', 'application/json')
                    ->write(json_encode($hasil));
});

// C. Laporan Detail Transaksi
$app->get('/toko_madura/laporan/detail', function($request, $response){
    $sql = "SELECT d.id_detail, t.tanggal_transaksi, b.nama_barang, d.jumlah, d.subtotal, t.id_transaksi
            FROM detail_transaksi d
            JOIN barang b ON d.id_barang = b.id_barang
            JOIN transaksi t ON d.id_transaksi = t.id_transaksi
            ORDER BY t.tanggal_transaksi DESC";
    $hasil = $this->db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    
    return $response->withHeader('Content-Type', 'application/json')
                    ->write(json_encode($hasil));
});

// D. API List Kategori (Untuk Dropdown)
$app->get('/toko_madura/laporan/kategori', function($request, $response){
    $sql = "SELECT * FROM kategori ORDER BY id_kategori ASC";
    $hasil = $this->db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    
    return $response->withHeader('Content-Type', 'application/json')
                    ->write(json_encode($hasil));
});

// E. API List Satuan (REVAMPED: Ambil dari tabel satuan)
$app->get('/toko_madura/laporan/satuan', function($request, $response){
    // UBAH: Sekarang ambil dari tabel master satuan, bukan distinct barang
    $sql = "SELECT * FROM satuan ORDER BY id_satuan ASC";
    
    $hasil = $this->db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    
    return $response->withHeader('Content-Type', 'application/json')
                    ->write(json_encode($hasil));
});