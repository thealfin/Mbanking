<?php

use Slim\Http\Request;
use Slim\Http\Response;

// ==================================================================================
// GROUP ROUTE UTAMA: API M-BANKING
// URL Base: /mbanking/api/...
// ==================================================================================
$app->group('/mbanking/api', function () use ($app) {

    // ==============================================================================
    // BAGIAN 1: DASHBOARD & GENERAL DATA
    // ==============================================================================

    /**
     * GET DASHBOARD: Data awal saldo, user, dan history
     * Mengambil 4 data sekaligus untuk load awal aplikasi
     */
    $app->get('/dashboard/all', function (Request $request, Response $response) {
        try {
            // 1. Ambil semua user (untuk simulasi login/testing)
            $users = $this->db->query("SELECT * FROM users ORDER BY created_at DESC")->fetchAll(PDO::FETCH_ASSOC);
            
            // 2. Ambil semua akun + join nama user
            $accounts = $this->db->query("SELECT a.*, u.full_name, u.email 
                                          FROM accounts a 
                                          JOIN users u ON a.user_id = u.user_id 
                                          ORDER BY a.created_at DESC")->fetchAll(PDO::FETCH_ASSOC);

            // 3. Ambil transaksi terbaru (Global - Limit 50)
            $transactions = $this->db->query("SELECT * FROM transactions ORDER BY transaction_date DESC LIMIT 50")->fetchAll(PDO::FETCH_ASSOC);
            
            // 4. Ambil log aktivitas (Global - Limit 50)
            $logs = $this->db->query("SELECT * FROM activity_logs ORDER BY created_at DESC LIMIT 50")->fetchAll(PDO::FETCH_ASSOC);

            // Return response JSON
            return $response->withJson([
                "status" => "success",
                "data" => [
                    "users" => $users,
                    "accounts" => $accounts,
                    "transactions" => $transactions,
                    "activity_logs" => $logs
                ]
            ]);

        } catch (Exception $e) {
            return $response->withJson(["status" => "error", "message" => $e->getMessage()], 500);
        }
    });

    /**
     * GET PROMOS
     * Data statis untuk banner promo di halaman depan
     */
    $app->get('/promos', function (Request $request, Response $response) {
        return $response->withJson([
            [
                "id" => 1, 
                "title" => "DISKON STARCOURT MALL", 
                "image_color" => "bg-pink-200", 
                "text_color" => "text-pink-800"
            ],
            [
                "id" => 2, 
                "title" => "CASHBACK ARCADE", 
                "image_color" => "bg-purple-200", 
                "text_color" => "text-purple-800"
            ],
            [
                "id" => 3, 
                "title" => "PROMO SURFER BOY PIZZA", 
                "image_color" => "bg-yellow-100", 
                "text_color" => "text-yellow-800"
            ]
        ]);
    });

    /**
     * GET BANKS
     * Mengambil daftar bank untuk dropdown transfer
     */
    $app->get('/banks', function (Request $request, Response $response) {
        try {
            // Pastikan tabel ref_banks ada
            $stmt = $this->db->query("SELECT * FROM ref_banks WHERE is_active = 1 ORDER BY bank_name ASC");
            $banks = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return $response->withJson([
                "status" => "success",
                "data"   => $banks
            ]);
        } catch (Exception $e) {
            return $response->withJson(["status" => "error", "message" => "Error: " . $e->getMessage()], 500);
        }
    });


    // ==============================================================================
    // BAGIAN 2: USER & PROFILE
    // ==============================================================================

    /**
     * GET PROFILE USER
     * Mengambil detail user beserta saldo akun utamanya
     */
    $app->get('/profile/{user_id}', function(Request $request, Response $response, $args){
        $uid = $args['user_id'];
        
        // Ambil data user dasar
        $userStmt = $this->db->prepare("SELECT * FROM users WHERE user_id = :uid");
        $userStmt->execute([':uid' => $uid]);
        $userData = $userStmt->fetch(PDO::FETCH_ASSOC);
        
        // Ambil data akun bank milik user tersebut
        $accStmt = $this->db->prepare("SELECT * FROM accounts WHERE user_id = :uid LIMIT 1");
        $accStmt->execute([':uid' => $uid]);
        $accData = $accStmt->fetch(PDO::FETCH_ASSOC);
        
        if($userData) {
            // Gabungkan data user dan data akun
            return $response->withJson([
                "status" => "success", 
                "data" => array_merge($userData, [
                    "card_number" => $accData['card_number'] ?? '-',
                    "account_number" => $accData['account_number'] ?? '-',
                    "balance" => $accData['balance'] ?? 0,
                    "account_id" => $accData['account_id'] ?? null,
                    "account_status" => $accData['status'] ?? 'INACTIVE'
                ])
            ]);
        }
        return $response->withJson(["status" => "failed", "message" => "User tidak ditemukan"], 404);
    });

    /**
     * SEARCH USERS
     * Fitur pencarian user berdasarkan nama atau email
     */
    $app->get('/users/cari/{keyword}', function(Request $request, Response $response, $args){
        $keyword = "%" . $args['keyword'] . "%";
        
        $sql = "SELECT user_id, full_name, email, phone_number 
                FROM users 
                WHERE full_name LIKE :kw OR email LIKE :kw";
                
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':kw' => $keyword]);
        
        return $response->withJson($stmt->fetchAll(PDO::FETCH_ASSOC));
    });

    /**
     * GET MESSAGES (LOG AKTIVITAS)
     * Mengambil notifikasi/pesan untuk user tertentu
     */
    $app->get('/messages/{user_id}', function(Request $request, Response $response, $args){
        $uid = $args['user_id'];
        
        // Query ambil log
        $sql = "SELECT * FROM activity_logs WHERE user_id = :uid ORDER BY created_at DESC LIMIT 20";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':uid' => $uid]);
        
        return $response->withJson([
            "status" => "success", 
            "data" => $stmt->fetchAll(PDO::FETCH_ASSOC)
        ]);
    });


    // ==============================================================================
    // BAGIAN 3: BENEFICIARIES (DAFTAR TRANSFER TERSIMPAN)
    // ==============================================================================

    /**
     * GET SAVED BENEFICIARIES
     * List rekening yang sudah disimpan user
     */
    $app->get('/beneficiaries/{user_id}', function (Request $request, Response $response, $args) {
        $uid = $args['user_id'];
        try {
            $sql = "SELECT s.*, b.bank_name 
                    FROM saved_beneficiaries s
                    LEFT JOIN ref_banks b ON s.bank_code = b.bank_code
                    WHERE s.user_id = :uid
                    ORDER BY s.is_favorite DESC, s.alias_name ASC";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute([':uid' => $uid]);
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return $response->withJson([
                "status" => "success",
                "data"   => $data
            ]);
        } catch (Exception $e) {
            // Jika error (misal tabel belum ada), return array kosong biar frontend gak crash
            return $response->withJson(["status" => "success", "data" => []]);
        }
    });

    /**
     * POST SAVE BENEFICIARY
     * Menyimpan kontak rekening baru
     */
    $app->post('/beneficiaries/save', function (Request $request, Response $response) {
        $data = $request->getParsedBody();
        $db = $this->db;

        // Validasi input
        if (empty($data['user_id']) || empty($data['bank_code']) || empty($data['account_number']) || empty($data['alias_name'])) {
            return $response->withJson(["status" => "error", "message" => "Data kontak tidak lengkap"], 400);
        }

        try {
            // Cek Duplikat
            $checkStmt = $db->prepare("SELECT id FROM saved_beneficiaries 
                                       WHERE user_id = :uid AND bank_code = :code AND account_number = :num");
            $checkStmt->execute([
                ':uid' => $data['user_id'],
                ':code' => $data['bank_code'],
                ':num' => $data['account_number']
            ]);

            if ($checkStmt->rowCount() > 0) {
                return $response->withJson(["status" => "error", "message" => "Kontak ini sudah ada di daftar tersimpan."], 409);
            }

            // Insert Data
            $sql = "INSERT INTO saved_beneficiaries (user_id, bank_code, account_number, alias_name, is_favorite, created_at) 
                    VALUES (:uid, :code, :num, :alias, 0, NOW())";
            
            $stmt = $db->prepare($sql);
            $stmt->execute([
                ':uid' => $data['user_id'],
                ':code' => $data['bank_code'],
                ':num' => $data['account_number'],
                ':alias' => $data['alias_name']
            ]);

            return $response->withJson([
                "status" => "success",
                "message" => "Kontak berhasil disimpan",
                "data" => [
                    "id" => $db->lastInsertId(),
                    "alias_name" => $data['alias_name']
                ]
            ]);

        } catch (Exception $e) {
            return $response->withJson(["status" => "error", "message" => "Gagal menyimpan: " . $e->getMessage()], 500);
        }
    });

    /**
     * DELETE BENEFICIARY
     * Menghapus kontak tersimpan
     */
    $app->delete('/beneficiaries/delete/{id}', function (Request $request, Response $response, $args) {
        $id = $args['id'];
        try {
            $stmt = $this->db->prepare("DELETE FROM saved_beneficiaries WHERE id = :id");
            $stmt->execute([':id' => $id]);
            return $response->withJson(["status" => "success", "message" => "Kontak dihapus"]);
        } catch (Exception $e) {
            return $response->withJson(["status" => "error", "message" => $e->getMessage()], 500);
        }
    });


    

    // ==============================================================================
    // BAGIAN 4: TRANSAKSI (TRANSFER, INQUIRY, HISTORY)
    // ==============================================================================

    /**
     * GET RECENT TRANSFER (Kode Baru dari User)
     * Mengambil history transfer terakhir dengan support Bank Luar
     */
    $app->get('/recent/{user_id}', function (Request $request, Response $response, $args) {
        $uid = $args['user_id'];
        try {
            $sql = "SELECT 
                        MAX(t.transaction_id) as transaction_id,
                        -- Logika: Jika bank_code kosong, berarti 'Bank Kita' (Internal)
                        COALESCE(b.bank_name, 'Bank Kita') as bank_name,
                        -- Ambil nomor rekening tujuan (prioritas kolom baru, fallback ke akun internal)
                        COALESCE(t.account_destination, a_dest.account_number) as account_destination,
                        -- Nama penerima
                        t.recipient_name as beneficiary_name,
                        MAX(t.created_at) as last_trx_date
                    FROM transactions t
                    JOIN accounts a_src ON t.from_account_id = a_src.account_id
                    -- Join opsional ke akun tujuan internal
                    LEFT JOIN accounts a_dest ON t.destination_account_id = a_dest.account_id
                    -- Join ke tabel referensi bank
                    LEFT JOIN ref_banks b ON t.bank_code = b.bank_code
                    WHERE a_src.user_id = :uid
                    AND t.transaction_type = 'TRANSFER'
                    GROUP BY account_destination
                    ORDER BY last_trx_date DESC
                    LIMIT 10";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([':uid' => $uid]);
            
            return $response->withJson([
                "status" => "success", 
                "data" => $stmt->fetchAll(PDO::FETCH_ASSOC)
            ]);

        } catch (Exception $e) {
            return $response->withJson(["status" => "error", "message" => $e->getMessage()]);
        }
    });

    /**
     * GET HISTORY DETAIL (Updated for External & Internal)
     * Mengambil history transfer terakhir (mendukung Bank Lain & Sesama)
     */
    $app->get('/transactions/recent/{user_id}', function (Request $request, Response $response, $args) {
        $uid = $args['user_id'];
        try {
            $sql = "SELECT 
                        MAX(t.transaction_id) as transaction_id,
                        -- Jika bank_code ada, ambil nama bank. Jika tidak, 'Bank Kita'
                        COALESCE(b.bank_name, 'Bank Kita') as bank_name,
                        
                        -- Ambil nomor rekening tujuan (prioritas kolom text, fallback ke akun internal)
                        COALESCE(t.account_destination, a_dest.account_number) as account_destination,
                        
                        -- Ambil nama penerima
                        COALESCE(t.recipient_name, u_dest.full_name) as beneficiary_name,
                        
                        t.destination_account_id,
                        MAX(t.transaction_date) as last_trx
                    FROM transactions t
                    JOIN accounts a_src ON t.source_account_id = a_src.account_id
                    LEFT JOIN accounts a_dest ON t.destination_account_id = a_dest.account_id
                    LEFT JOIN users u_dest ON a_dest.user_id = u_dest.user_id
                    LEFT JOIN ref_banks b ON t.bank_code = b.bank_code
                    WHERE a_src.user_id = :uid 
                      AND t.transaction_type = 'TRANSFER'
                      AND t.status = 'SUCCESS'
                    GROUP BY 
                        COALESCE(t.account_destination, a_dest.account_number), 
                        COALESCE(b.bank_name, 'Bank Kita'),
                        t.destination_account_id
                    ORDER BY last_trx DESC
                    LIMIT 10";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([':uid' => $uid]);
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return $response->withJson(["status" => "success", "data" => $data]);
        } catch (Exception $e) {
            return $response->withJson(["status" => "error", "message" => $e->getMessage()], 500);
        }
    });

    /**
     * INQUIRY REKENING (Internal)
     * Mengecek nama pemilik rekening tujuan sesama bank
     */
    $app->get('/transactions/inquiry/{account_number}', function (Request $request, Response $response, $args) {
        $accNum = $args['account_number'];
        
        $sql = "SELECT a.account_id, a.account_number, u.full_name, 'BANK KITA' as bank_name
                FROM accounts a
                JOIN users u ON a.user_id = u.user_id
                WHERE a.account_number = :num AND a.status = 'ACTIVE'";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':num' => $accNum]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            return $response->withJson(["status" => "success", "data" => $result]);
        } else {
            return $response->withJson(["status" => "failed", "message" => "Rekening tidak ditemukan"], 404);
        }
    });

    /**
     * POST TRANSFER
     * Eksekusi pemindahan saldo antar rekening
     */
    $app->post('/transactions/transfer', function (Request $request, Response $response) {
        $data = $request->getParsedBody();
        $db = $this->db;

        // 1. Validasi Kelengkapan Data
        if (empty($data['from_account_id']) || empty($data['to_account_id']) || empty($data['amount'])) {
            return $response->withJson(["status" => "error", "message" => "Data transfer tidak lengkap"], 400);
        }
        
        // 2. Validasi Rekening Sama
        if ($data['from_account_id'] == $data['to_account_id']) {
            return $response->withJson(["status" => "error", "message" => "Tidak bisa transfer ke diri sendiri"], 400);
        }
        
        // 3. Validasi Nominal Minimal
        $amount = (float) $data['amount'];
        if ($amount < 10000) {
            return $response->withJson(["status" => "error", "message" => "Minimal transfer Rp 10.000"], 400);
        }

        try {
            // Start Transaction (Atomic Operation)
            $db->beginTransaction();

            // STEP A: Lock Row Pengirim & Cek Saldo
            $stmtSrc = $db->prepare("SELECT balance FROM accounts WHERE account_id = ? FOR UPDATE");
            $stmtSrc->execute([$data['from_account_id']]);
            $sourceBalance = $stmtSrc->fetchColumn();

            if ($sourceBalance === false) throw new Exception("Rekening pengirim tidak valid.");
            if ($sourceBalance < $amount) throw new Exception("Saldo tidak mencukupi.");

            // STEP B: Lock Row Penerima
            $stmtDest = $db->prepare("SELECT balance FROM accounts WHERE account_id = ? FOR UPDATE");
            $stmtDest->execute([$data['to_account_id']]);
            $destBalance = $stmtDest->fetchColumn(); 

            if ($destBalance === false) throw new Exception("Rekening tujuan tidak ditemukan.");

            // STEP C: Hitung Saldo Baru
            $newSrcBalance = $sourceBalance - $amount;
            $newDestBalance = $destBalance + $amount;

            // STEP D: Update ke Database
            $db->prepare("UPDATE accounts SET balance = ? WHERE account_id = ?")->execute([$newSrcBalance, $data['from_account_id']]);
            $db->prepare("UPDATE accounts SET balance = ? WHERE account_id = ?")->execute([$newDestBalance, $data['to_account_id']]);

            // STEP E: Catat Log Transaksi (transactions table)
            $trxCode = 'TRF-' . date('ymd') . rand(1000, 9999); 
            $desc = $data['description'] ?? 'Transfer';
            
            $sqlTrx = "INSERT INTO transactions 
                       (transaction_code, source_account_id, destination_account_id, amount, transaction_type, description, status, transaction_date) 
                       VALUES (?, ?, ?, ?, 'TRANSFER', ?, 'SUCCESS', NOW())";
            
            $db->prepare($sqlTrx)->execute([$trxCode, $data['from_account_id'], $data['to_account_id'], $amount, $desc]);
            $transactionId = $db->lastInsertId();

            // STEP F: Catat Mutasi Rekening (account_mutations table)
            $sqlMut = "INSERT INTO account_mutations (account_id, transaction_id, mutation_type, amount, balance_after, created_at) 
                       VALUES (?, ?, ?, ?, ?, NOW())";
            
            // Mutasi DEBIT (Pengirim - Uang Keluar)
            $db->prepare($sqlMut)->execute([$data['from_account_id'], $transactionId, 'DEBIT', $amount, $newSrcBalance]);
            // Mutasi CREDIT (Penerima - Uang Masuk)
            $db->prepare($sqlMut)->execute([$data['to_account_id'], $transactionId, 'CREDIT', $amount, $newDestBalance]);

            // Commit perubahan
            $db->commit();

            return $response->withJson([
                "status" => "success",
                "message" => "Transfer Berhasil",
                "data" => [
                    "transaction_code" => $trxCode,
                    "balance_remaining" => $newSrcBalance
                ]
            ]);

        } catch (Exception $e) {
            // Rollback jika ada error di tengah jalan
            $db->rollBack();
            return $response->withJson(["status" => "error", "message" => $e->getMessage()], 400);
        }
    });


    // ==============================================================================
    // BAGIAN 5: MUTASI (HISTORY DETAIL)
    // ==============================================================================

    /**
     * GET MUTASI REKENING
     * Menampilkan detail uang masuk/keluar per akun
     */
    $app->get('/mutasi/{account_id}', function($request, $response, $args){
        $acc_id = $args['account_id'];
        try {
            $sql = "SELECT m.*, t.transaction_code, t.description, t.transaction_type,
                           CASE 
                               WHEN m.mutation_type = 'CREDIT' THEN 'UANG MASUK' 
                               ELSE 'UANG KELUAR' 
                           END as flow_type
                    FROM account_mutations m
                    JOIN transactions t ON m.transaction_id = t.transaction_id
                    WHERE m.account_id = :id
                    ORDER BY m.created_at DESC 
                    LIMIT 20";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute([':id' => $acc_id]);
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return $response->withJson([
                "status" => "success", 
                "data" => $result
            ]);
        } catch (Exception $e) {
            return $response->withJson(["status" => "error", "message" => $e->getMessage()], 500);
        }
    });

});


// ==================================================================================
// ROUTE DUPLIKAT (SESUAI PERMINTAAN USER)
// Ini adalah route Inquiry yang sama dengan yang ada di dalam group.
// Diletakkan di luar group /mbanking/api sebagai fallback atau legacy route.
// ==================================================================================
$app->get('/api/transactions/inquiry/{accountNumber}', function ($request, $response, $args) {
    $accountNumber = $args['accountNumber'];
    
    // Validasi input
    if (!is_numeric($accountNumber)) {
        return $response->withJson(['status' => 'error', 'message' => 'Format salah'], 400);
    }

    // Query DB
    $sql = "SELECT account_id, account_number, balance, user_id FROM accounts WHERE account_number = :acc LIMIT 1";
    $stmt = $this->db->prepare($sql);
    $stmt->execute([':acc' => $accountNumber]);
    $account = $stmt->fetch();

    if ($account) {
        $sqlUser = "SELECT full_name FROM users WHERE user_id = :uid";
        $stmtUser = $this->db->prepare($sqlUser);
        $stmtUser->execute([':uid' => $account['user_id']]);
        $user = $stmtUser->fetch();

        return $response->withJson([
            'status' => 'success',
            'data' => [
                'account_id' => $account['account_id'],
                'full_name' => $user['full_name'],
                // Balance disembunyikan untuk inquiry publik/transfer
            ]
        ]);
    }

    return $response->withJson(['status' => 'fail', 'message' => 'Tidak ditemukan'], 404);
});
?>