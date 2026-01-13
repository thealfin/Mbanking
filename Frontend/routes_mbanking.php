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
     * Mengambil data spesifik untuk user yang sedang aktif
     */
    $app->get('/dashboard/{user_id}', function (Request $request, Response $response, $args) {
        $uid = $args['user_id'];
        try {
            // 1. Detail User & Akun Utama
            $account = $this->db->prepare("SELECT a.*, u.full_name, u.email 
                                          FROM accounts a 
                                          JOIN users u ON a.user_id = u.user_id 
                                          WHERE u.user_id = :uid LIMIT 1");
            $account->execute([':uid' => $uid]);
            $accountData = $account->fetch(PDO::FETCH_ASSOC);
            
            if (!$accountData) {
                return $response->withJson(["status" => "error", "message" => "User atau Akun tidak ditemukan"], 404);
            }

            $acc_id = $accountData['account_id'];

            // 2. Ambil Mutasi Terakhir (Limit 5)
            $mutasi = $this->db->prepare("SELECT m.*, t.transaction_type, t.description as trx_desc
                                         FROM account_mutations m
                                         LEFT JOIN transactions t ON m.transaction_id = t.transaction_id
                                         WHERE m.account_id = :acc_id
                                         ORDER BY m.created_at DESC LIMIT 5");
            $mutasi->execute([':acc_id' => $acc_id]);
            $recent_mutations = $mutasi->fetchAll(PDO::FETCH_ASSOC);
            
            // 3. Ambil Log Aktivitas Terakhir
            $logs = $this->db->prepare("SELECT * FROM activity_logs WHERE user_id = :uid ORDER BY created_at DESC LIMIT 10");
            $logs->execute([':uid' => $uid]);
            $activity_logs = $logs->fetchAll(PDO::FETCH_ASSOC);

            return $response->withJson([
                "status" => "success",
                "data" => [
                    "account" => $accountData,
                    "recent_mutations" => $recent_mutations,
                    "activity_logs" => $activity_logs
                ]
            ]);

        } catch (Exception $e) {
            return $response->withJson(["status" => "error", "message" => $e->getMessage()], 500);
        }
    });

    /**
     * GET DASHBOARD ALL (Legacy Support)
     */
    $app->get('/dashboard/all', function (Request $request, Response $response) {
        try {
            $users = $this->db->query("SELECT user_id, full_name, email FROM users ORDER BY created_at DESC")->fetchAll(PDO::FETCH_ASSOC);
            $accounts = $this->db->query("SELECT a.*, u.full_name FROM accounts a JOIN users u ON a.user_id = u.user_id")->fetchAll(PDO::FETCH_ASSOC);
            $transactions = $this->db->query("SELECT * FROM transactions ORDER BY transaction_date DESC LIMIT 50")->fetchAll(PDO::FETCH_ASSOC);
            
            return $response->withJson([
                "status" => "success",
                "data" => ["users" => $users, "accounts" => $accounts, "transactions" => $transactions]
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
     * GET HISTORY DETAIL (Updated for External & Internal)
     * Mengambil history transfer terakhir (mendukung Bank Lain & Sesama)
     */
    $app->get('/transactions/recent/{user_id}', function (Request $request, Response $response, $args) {
        $uid = $args['user_id'];
        try {
            $sql = "SELECT 
                        MAX(t.transaction_id) as transaction_id,
                        COALESCE(b.bank_name, 'Bank Kita') as bank_name,
                        COALESCE(t.account_destination, a_dest.account_number) as account_destination,
                        COALESCE(t.recipient_name, u_dest.full_name) as beneficiary_name,
                        t.destination_account_id,
                        MAX(COALESCE(t.transaction_date, t.created_at)) as last_trx
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
            // Query Mutasi dengan JOIN yang lebih robust untuk mengambil Nama dan No Rekening
            // Kita ambil data pengirim dan penerima secara detail dari tabel users & accounts
            $sql = "SELECT m.id, m.account_id, m.transaction_id, m.mutation_type, m.amount, m.balance_after, m.created_at,
                           t.transaction_code, 
                           t.description as trx_desc, 
                           t.transaction_type, 
                           t.status as transaction_status,
                           COALESCE(t.transaction_date, t.created_at, m.created_at) as transaction_time,
                           
                           -- Detail Pengirim (Source)
                           u_src.full_name as sender_name,
                           a_src.account_number as sender_account,
                           
                           -- Detail Penerima (Destination)
                           COALESCE(t.recipient_name, u_dest.full_name) as recipient_name,
                           COALESCE(t.account_destination, a_dest.account_number) as recipient_account,
                           
                           -- Info Bank
                           COALESCE(b.bank_name, 'BANK KITA') as bank_name,
                           COALESCE(t.bank_code, '001') as bank_id,
                           
                           -- Tipe Aliran Dana
                           CASE 
                               WHEN m.mutation_type = 'CREDIT' THEN 'UANG MASUK' 
                               ELSE 'UANG KELUAR' 
                           END as label
                    FROM account_mutations m
                    LEFT JOIN transactions t ON m.transaction_id = t.transaction_id
                    
                    -- Join ke akun pengirim (Source) dari transaksi
                    LEFT JOIN accounts a_src ON t.source_account_id = a_src.account_id
                    LEFT JOIN users u_src ON a_src.user_id = u_src.user_id
                    
                    -- Join ke akun penerima (Destination) dari transaksi
                    LEFT JOIN accounts a_dest ON t.destination_account_id = a_dest.account_id
                    LEFT JOIN users u_dest ON a_dest.user_id = u_dest.user_id
                    
                    -- Join ke referensi bank
                    LEFT JOIN ref_banks b ON t.bank_code = b.bank_code
                    
                    WHERE m.account_id = :id
                    ORDER BY m.created_at DESC, m.id DESC 
                    LIMIT 50";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute([':id' => $acc_id]);
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Post-processing untuk membersihkan data (No Nulls)
            foreach ($result as &$row) {
                // Gunakan ID mutasi sebagai fallback jika tidak ada transaction_id
                $idForHash = $row['id'] ?? rand(1000,9999);
                
                // Fallback jika join null (misal transaksi sistem/topup manual)
                $row['sender_name'] = $row['sender_name'] ?: 'Sistem';
                $row['sender_account'] = $row['sender_account'] ?: '-';
                $row['recipient_name'] = $row['recipient_name'] ?: 'Penerima';
                $row['recipient_account'] = $row['recipient_account'] ?: '-';
                $row['bank_name'] = $row['bank_name'] ?: 'BANK KITA';
                $row['bank_id'] = $row['bank_id'] ?: '001';
                $row['transaction_status'] = $row['transaction_status'] ?: 'SUCCESS';
                
                // Logic Tipe Transaksi yang lebih detail
                if (!$row['transaction_type']) {
                    if ($row['mutation_type'] == 'CREDIT') {
                        $row['transaction_type'] = 'TRANSFER MASUK';
                    } else {
                        $row['transaction_type'] = 'TRANSFER KELUAR';
                    }
                }
                
                $row['transaction_code'] = $row['transaction_code'] ?: 'TRX-' . strtoupper(substr(md5($idForHash), 0, 10));
                
                // Jika description kosong di mutasi, ambil dari transaksi
                $row['description'] = $row['description'] ?: ($row['trx_desc'] ?: $row['transaction_type']);
                
                // Ensure dates
                if (!isset($row['created_at'])) {
                    $row['created_at'] = $row['transaction_time'];
                }
            }

            return $response->withJson([
                "status" => "success", 
                "count" => count($result),
                "data" => $result
            ]);
        } catch (Exception $e) {
            return $response->withJson(["status" => "error", "message" => $e->getMessage()], 500);
        }
    });

});
?>