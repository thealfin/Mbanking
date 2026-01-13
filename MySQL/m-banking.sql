/*
MySQL Data Transfer
Source Host: localhost
Source Database: m-banking
Target Host: localhost
Target Database: m-banking
Date: 1/13/2026 10:41:15 AM
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for account_mutations
-- ----------------------------
DROP TABLE IF EXISTS `account_mutations`;
CREATE TABLE `account_mutations` (
  `mutation_id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL COMMENT 'Milik rekening mana mutasi ini',
  `transaction_id` int(11) NOT NULL COMMENT 'Referensi ke tabel transaksi utama',
  `mutation_type` enum('DEBIT','CREDIT') NOT NULL COMMENT 'CREDIT=Uang Masuk, DEBIT=Uang Keluar',
  `amount` decimal(15,2) NOT NULL,
  `balance_after` decimal(15,2) DEFAULT 0.00 COMMENT 'Saldo setelah transaksi (Snapshot)',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`mutation_id`),
  KEY `fk_mutations_account` (`account_id`),
  KEY `fk_mutations_trx` (`transaction_id`),
  CONSTRAINT `fk_mutations_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mutations_trx` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=219 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ----------------------------
-- Table structure for accounts
-- ----------------------------
DROP TABLE IF EXISTS `accounts`;
CREATE TABLE `accounts` (
  `account_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `account_number` varchar(20) NOT NULL,
  `bank_code` varchar(10) DEFAULT NULL,
  `card_number` varchar(16) DEFAULT NULL,
  `balance` decimal(15,2) DEFAULT 0.00,
  `account_type` enum('SAVINGS','CURRENT','DEPOSITO') DEFAULT 'SAVINGS',
  `status` enum('ACTIVE','BLOCKED') DEFAULT 'ACTIVE',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`account_id`),
  KEY `fk_accounts_user` (`user_id`),
  KEY `fk_accounts_bank` (`bank_code`),
  CONSTRAINT `fk_accounts_bank` FOREIGN KEY (`bank_code`) REFERENCES `ref_banks` (`bank_code`) ON DELETE SET NULL,
  CONSTRAINT `fk_accounts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ----------------------------
-- Table structure for activity_logs
-- ----------------------------
DROP TABLE IF EXISTS `activity_logs`;
CREATE TABLE `activity_logs` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `bank_code` varchar(10) DEFAULT NULL,
  `activity_type` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`log_id`),
  KEY `fk_activity_bank` (`bank_code`),
  CONSTRAINT `fk_activity_bank` FOREIGN KEY (`bank_code`) REFERENCES `ref_banks` (`bank_code`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ----------------------------
-- Table structure for ref_banks
-- ----------------------------
DROP TABLE IF EXISTS `ref_banks`;
CREATE TABLE `ref_banks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bank_code` varchar(10) NOT NULL,
  `bank_name` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_bank_code` (`bank_code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ----------------------------
-- Table structure for saved_beneficiaries
-- ----------------------------
DROP TABLE IF EXISTS `saved_beneficiaries`;
CREATE TABLE `saved_beneficiaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `bank_code` varchar(10) DEFAULT NULL,
  `account_number` varchar(50) NOT NULL,
  `alias_name` varchar(100) DEFAULT NULL,
  `is_favorite` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_saved_user` (`user_id`),
  KEY `fk_saved_bank` (`bank_code`),
  CONSTRAINT `fk_saved_bank` FOREIGN KEY (`bank_code`) REFERENCES `ref_banks` (`bank_code`) ON DELETE CASCADE,
  CONSTRAINT `fk_saved_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ----------------------------
-- Table structure for transactions
-- ----------------------------
DROP TABLE IF EXISTS `transactions`;
CREATE TABLE `transactions` (
  `transaction_id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_code` varchar(50) NOT NULL,
  `source_account_id` int(11) DEFAULT NULL,
  `destination_account_id` int(11) DEFAULT NULL,
  `bank_code` varchar(10) DEFAULT NULL,
  `account_destination` varchar(50) DEFAULT NULL COMMENT 'Nomor rekening tujuan (string)',
  `amount` decimal(15,2) NOT NULL,
  `transaction_type` enum('TRANSFER','PAYMENT','TOPUP','PENARIKAN','DEPOSIT') NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `status` enum('PENDING','SUCCESS','FAILED') DEFAULT 'SUCCESS',
  `transaction_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`transaction_id`),
  KEY `fk_transactions_bank` (`bank_code`),
  CONSTRAINT `fk_transactions_bank` FOREIGN KEY (`bank_code`) REFERENCES `ref_banks` (`bank_code`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `bank_code` varchar(10) DEFAULT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `unique_email` (`email`),
  KEY `fk_users_bank` (`bank_code`),
  CONSTRAINT `fk_users_bank` FOREIGN KEY (`bank_code`) REFERENCES `ref_banks` (`bank_code`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ----------------------------
-- Records 
-- ----------------------------
INSERT INTO `account_mutations` VALUES ('1', '26', '26', 'DEBIT', '2000000.00', '0.00', '2026-01-10 09:00:00');
INSERT INTO `account_mutations` VALUES ('2', '26', '27', 'DEBIT', '2000000.00', '0.00', '2026-01-15 14:30:00');
INSERT INTO `account_mutations` VALUES ('3', '26', '28', 'DEBIT', '3000000.00', '0.00', '2026-01-20 10:15:00');
INSERT INTO `account_mutations` VALUES ('4', '26', '29', 'DEBIT', '1500000.00', '0.00', '2026-01-25 18:45:00');
INSERT INTO `account_mutations` VALUES ('5', '26', '30', 'DEBIT', '1500000.00', '0.00', '2026-02-01 08:00:00');
INSERT INTO `account_mutations` VALUES ('6', '26', '31', 'DEBIT', '2000000.00', '0.00', '2026-02-05 12:00:00');
INSERT INTO `account_mutations` VALUES ('8', '1', '26', 'CREDIT', '2000000.00', '0.00', '2026-01-10 09:00:00');
INSERT INTO `account_mutations` VALUES ('9', '1', '27', 'CREDIT', '2000000.00', '0.00', '2026-01-15 14:30:00');
INSERT INTO `account_mutations` VALUES ('10', '1', '28', 'CREDIT', '3000000.00', '0.00', '2026-01-20 10:15:00');
INSERT INTO `account_mutations` VALUES ('11', '1', '29', 'CREDIT', '1500000.00', '0.00', '2026-01-25 18:45:00');
INSERT INTO `account_mutations` VALUES ('12', '1', '30', 'CREDIT', '1500000.00', '0.00', '2026-02-01 08:00:00');
INSERT INTO `account_mutations` VALUES ('13', '1', '31', 'CREDIT', '2000000.00', '0.00', '2026-02-05 12:00:00');
INSERT INTO `account_mutations` VALUES ('14', '27', '67', 'DEBIT', '1000000.00', '7500000.00', '2026-01-07 15:08:22');
INSERT INTO `account_mutations` VALUES ('15', '20', '67', 'CREDIT', '1000000.00', '1500000.00', '2026-01-07 15:08:22');
INSERT INTO `account_mutations` VALUES ('16', '20', '68', 'DEBIT', '50000.00', '1450000.00', '2026-01-07 15:20:55');
INSERT INTO `account_mutations` VALUES ('17', '26', '68', 'CREDIT', '50000.00', '15050000.00', '2026-01-07 15:20:55');
INSERT INTO `account_mutations` VALUES ('18', '20', '69', 'DEBIT', '100000.00', '1350000.00', '2026-01-07 15:23:59');
INSERT INTO `account_mutations` VALUES ('19', '27', '69', 'CREDIT', '100000.00', '7600000.00', '2026-01-07 15:23:59');
INSERT INTO `account_mutations` VALUES ('20', '20', '70', 'DEBIT', '100000.00', '1250000.00', '2026-01-07 15:30:22');
INSERT INTO `account_mutations` VALUES ('21', '27', '70', 'CREDIT', '100000.00', '7700000.00', '2026-01-07 15:30:22');
INSERT INTO `account_mutations` VALUES ('22', '20', '71', 'DEBIT', '20000.00', '1230000.00', '2026-01-07 15:33:40');
INSERT INTO `account_mutations` VALUES ('23', '27', '71', 'CREDIT', '20000.00', '7720000.00', '2026-01-07 15:33:40');
INSERT INTO `account_mutations` VALUES ('24', '20', '72', 'DEBIT', '10000.00', '1220000.00', '2026-01-07 15:43:52');
INSERT INTO `account_mutations` VALUES ('25', '27', '72', 'CREDIT', '10000.00', '7730000.00', '2026-01-07 15:43:52');
INSERT INTO `account_mutations` VALUES ('26', '27', '73', 'DEBIT', '1000000.00', '6730000.00', '2026-01-07 19:24:04');
INSERT INTO `account_mutations` VALUES ('27', '20', '73', 'CREDIT', '1000000.00', '2220000.00', '2026-01-07 19:24:04');
INSERT INTO `account_mutations` VALUES ('28', '3', '74', 'DEBIT', '500000000.00', '499000000.00', '2026-01-07 19:38:47');
INSERT INTO `account_mutations` VALUES ('29', '20', '74', 'CREDIT', '500000000.00', '502220000.00', '2026-01-07 19:38:47');
INSERT INTO `account_mutations` VALUES ('30', '3', '75', 'DEBIT', '27000000.00', '472000000.00', '2026-01-07 19:39:12');
INSERT INTO `account_mutations` VALUES ('31', '20', '75', 'CREDIT', '27000000.00', '529220000.00', '2026-01-07 19:39:12');
INSERT INTO `account_mutations` VALUES ('32', '3', '76', 'DEBIT', '100000000.00', '372000000.00', '2026-01-07 19:40:09');
INSERT INTO `account_mutations` VALUES ('33', '20', '76', 'CREDIT', '100000000.00', '629220000.00', '2026-01-07 19:40:09');
INSERT INTO `account_mutations` VALUES ('34', '20', '77', 'DEBIT', '50000.00', '629170000.00', '2026-01-07 20:39:19');
INSERT INTO `account_mutations` VALUES ('35', '21', '77', 'CREDIT', '50000.00', '800000.00', '2026-01-07 20:39:19');
INSERT INTO `account_mutations` VALUES ('36', '20', '78', 'DEBIT', '10000.00', '629160000.00', '2026-01-07 20:39:42');
INSERT INTO `account_mutations` VALUES ('37', '21', '78', 'CREDIT', '10000.00', '810000.00', '2026-01-07 20:39:42');
INSERT INTO `account_mutations` VALUES ('38', '20', '79', 'DEBIT', '10000.00', '629150000.00', '2026-01-07 20:42:35');
INSERT INTO `account_mutations` VALUES ('39', '21', '79', 'CREDIT', '10000.00', '820000.00', '2026-01-07 20:42:35');
INSERT INTO `account_mutations` VALUES ('40', '20', '80', 'DEBIT', '11000.00', '629139000.00', '2026-01-07 20:53:49');
INSERT INTO `account_mutations` VALUES ('41', '21', '80', 'CREDIT', '11000.00', '831000.00', '2026-01-07 20:53:49');
INSERT INTO `account_mutations` VALUES ('42', '20', '81', 'DEBIT', '12000.00', '629127000.00', '2026-01-07 23:04:15');
INSERT INTO `account_mutations` VALUES ('43', '23', '81', 'CREDIT', '12000.00', '162000.00', '2026-01-07 23:04:15');
INSERT INTO `account_mutations` VALUES ('44', '20', '82', 'DEBIT', '31000.00', '629096000.00', '2026-01-07 23:05:10');
INSERT INTO `account_mutations` VALUES ('45', '21', '82', 'CREDIT', '31000.00', '862000.00', '2026-01-07 23:05:10');
INSERT INTO `account_mutations` VALUES ('46', '24', '83', 'DEBIT', '50000.00', '2450000.00', '2026-01-08 11:35:28');
INSERT INTO `account_mutations` VALUES ('47', '25', '83', 'CREDIT', '50000.00', '500000.00', '2026-01-08 11:35:28');
INSERT INTO `account_mutations` VALUES ('48', '24', '84', 'DEBIT', '10000.00', '2440000.00', '2026-01-08 11:41:42');
INSERT INTO `account_mutations` VALUES ('49', '25', '84', 'CREDIT', '10000.00', '510000.00', '2026-01-08 11:41:42');
INSERT INTO `account_mutations` VALUES ('50', '20', '85', 'DEBIT', '1000000.00', '6289960000.00', '2026-01-08 15:08:30');
INSERT INTO `account_mutations` VALUES ('51', '28', '85', 'CREDIT', '1000000.00', '2200000.00', '2026-01-08 15:08:30');
INSERT INTO `account_mutations` VALUES ('52', '1', '2', 'DEBIT', '150000.00', '0.00', '1959-03-05 14:00:00');
INSERT INTO `account_mutations` VALUES ('53', '1', '3', 'DEBIT', '2000000.00', '0.00', '1979-01-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('54', '2', '5', 'DEBIT', '50000.00', '0.00', '1984-01-02 00:00:00');
INSERT INTO `account_mutations` VALUES ('55', '2', '6', 'DEBIT', '100.00', '0.00', '1986-03-01 12:00:00');
INSERT INTO `account_mutations` VALUES ('56', '2', '7', 'DEBIT', '100.00', '0.00', '1986-03-02 12:00:00');
INSERT INTO `account_mutations` VALUES ('57', '2', '9', 'DEBIT', '666.00', '0.00', '1986-03-04 12:00:00');
INSERT INTO `account_mutations` VALUES ('58', '2', '10', 'DEBIT', '1.00', '0.00', '1986-03-05 12:00:00');
INSERT INTO `account_mutations` VALUES ('59', '3', '12', 'DEBIT', '5000000.00', '0.00', '1983-02-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('60', '3', '13', 'DEBIT', '2000000.00', '0.00', '1983-03-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('61', '3', '14', 'DEBIT', '500000.00', '0.00', '1983-04-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('62', '3', '15', 'DEBIT', '500000.00', '0.00', '1983-05-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('63', '3', '16', 'DEBIT', '500000.00', '0.00', '1983-06-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('64', '3', '17', 'DEBIT', '500000.00', '0.00', '1983-07-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('65', '3', '18', 'DEBIT', '15000000.00', '0.00', '1983-08-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('66', '3', '19', 'DEBIT', '200000.00', '0.00', '1983-09-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('67', '3', '21', 'DEBIT', '1000000.00', '0.00', '1986-01-02 09:00:00');
INSERT INTO `account_mutations` VALUES ('68', '26', '22', 'DEBIT', '100000.00', '0.00', '2026-01-01 10:00:00');
INSERT INTO `account_mutations` VALUES ('69', '28', '23', 'DEBIT', '50000.00', '0.00', '2026-01-02 11:00:00');
INSERT INTO `account_mutations` VALUES ('70', '23', '24', 'DEBIT', '25000.00', '0.00', '2026-01-03 12:00:00');
INSERT INTO `account_mutations` VALUES ('71', '20', '32', 'DEBIT', '50000.00', '0.00', '2026-01-11 09:00:00');
INSERT INTO `account_mutations` VALUES ('72', '20', '33', 'DEBIT', '25000.00', '0.00', '2026-01-12 10:00:00');
INSERT INTO `account_mutations` VALUES ('73', '20', '34', 'DEBIT', '100000.00', '0.00', '2026-01-13 11:00:00');
INSERT INTO `account_mutations` VALUES ('74', '20', '35', 'DEBIT', '15000.00', '0.00', '2026-01-14 12:00:00');
INSERT INTO `account_mutations` VALUES ('75', '20', '36', 'DEBIT', '50000.00', '0.00', '2026-01-15 13:00:00');
INSERT INTO `account_mutations` VALUES ('76', '20', '37', 'DEBIT', '200000.00', '0.00', '2026-01-16 14:00:00');
INSERT INTO `account_mutations` VALUES ('77', '20', '38', 'DEBIT', '45000.00', '0.00', '2026-01-17 15:00:00');
INSERT INTO `account_mutations` VALUES ('78', '20', '39', 'DEBIT', '20000.00', '0.00', '2026-01-18 16:00:00');
INSERT INTO `account_mutations` VALUES ('79', '20', '40', 'DEBIT', '100000.00', '0.00', '2026-01-19 17:00:00');
INSERT INTO `account_mutations` VALUES ('80', '20', '41', 'DEBIT', '30000.00', '0.00', '2026-01-23 18:00:00');
INSERT INTO `account_mutations` VALUES ('81', '21', '42', 'DEBIT', '40678.00', '0.00', '2025-12-31 11:03:28');
INSERT INTO `account_mutations` VALUES ('82', '21', '44', 'DEBIT', '23341.00', '0.00', '2025-12-17 11:03:28');
INSERT INTO `account_mutations` VALUES ('83', '21', '46', 'DEBIT', '30251.00', '0.00', '2025-12-23 11:03:28');
INSERT INTO `account_mutations` VALUES ('84', '21', '49', 'DEBIT', '34659.00', '0.00', '2026-01-02 11:03:28');
INSERT INTO `account_mutations` VALUES ('85', '21', '50', 'DEBIT', '43713.00', '0.00', '2025-12-27 11:03:28');
INSERT INTO `account_mutations` VALUES ('86', '21', '51', 'DEBIT', '54365.00', '0.00', '2025-12-16 11:03:28');
INSERT INTO `account_mutations` VALUES ('87', '21', '52', 'DEBIT', '67322.00', '0.00', '2025-12-25 11:03:28');
INSERT INTO `account_mutations` VALUES ('88', '21', '53', 'DEBIT', '89889.00', '0.00', '2026-01-01 11:03:28');
INSERT INTO `account_mutations` VALUES ('89', '22', '57', 'DEBIT', '50000.00', '0.00', '2026-01-06 11:03:28');
INSERT INTO `account_mutations` VALUES ('90', '22', '58', 'DEBIT', '20000.00', '0.00', '2026-01-06 11:03:28');
INSERT INTO `account_mutations` VALUES ('91', '23', '59', 'DEBIT', '15000.00', '0.00', '2026-01-06 11:03:28');
INSERT INTO `account_mutations` VALUES ('92', '23', '60', 'DEBIT', '100000.00', '0.00', '2026-01-06 11:03:28');
INSERT INTO `account_mutations` VALUES ('93', '24', '61', 'DEBIT', '75000.00', '0.00', '2026-01-06 11:03:28');
INSERT INTO `account_mutations` VALUES ('94', '24', '62', 'DEBIT', '500000.00', '0.00', '2026-01-06 11:03:28');
INSERT INTO `account_mutations` VALUES ('95', '26', '63', 'DEBIT', '200000.00', '0.00', '2026-01-06 11:03:28');
INSERT INTO `account_mutations` VALUES ('96', '26', '64', 'DEBIT', '150000.00', '0.00', '2026-01-06 11:03:28');
INSERT INTO `account_mutations` VALUES ('97', '27', '65', 'DEBIT', '300000.00', '0.00', '2026-01-06 11:03:28');
INSERT INTO `account_mutations` VALUES ('98', '27', '66', 'DEBIT', '5000000.00', '0.00', '2026-01-06 11:03:28');
INSERT INTO `account_mutations` VALUES ('99', '1', '1', 'CREDIT', '5000000.00', '0.00', '1959-03-01 10:00:00');
INSERT INTO `account_mutations` VALUES ('100', '3', '3', 'CREDIT', '2000000.00', '0.00', '1979-01-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('101', '2', '4', 'CREDIT', '100000.00', '0.00', '1984-01-01 00:00:00');
INSERT INTO `account_mutations` VALUES ('102', '25', '6', 'CREDIT', '100.00', '0.00', '1986-03-01 12:00:00');
INSERT INTO `account_mutations` VALUES ('103', '28', '7', 'CREDIT', '100.00', '0.00', '1986-03-02 12:00:00');
INSERT INTO `account_mutations` VALUES ('104', '2', '8', 'CREDIT', '5000000.00', '0.00', '1986-03-03 12:00:00');
INSERT INTO `account_mutations` VALUES ('105', '24', '10', 'CREDIT', '1.00', '0.00', '1986-03-05 12:00:00');
INSERT INTO `account_mutations` VALUES ('106', '3', '11', 'CREDIT', '100000000.00', '0.00', '1983-01-01 08:00:00');
INSERT INTO `account_mutations` VALUES ('107', '24', '14', 'CREDIT', '500000.00', '0.00', '1983-04-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('108', '24', '15', 'CREDIT', '500000.00', '0.00', '1983-05-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('109', '24', '16', 'CREDIT', '500000.00', '0.00', '1983-06-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('110', '24', '17', 'CREDIT', '500000.00', '0.00', '1983-07-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('111', '27', '19', 'CREDIT', '200000.00', '0.00', '1983-09-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('112', '3', '20', 'CREDIT', '50000000.00', '0.00', '1986-01-01 09:00:00');
INSERT INTO `account_mutations` VALUES ('113', '20', '22', 'CREDIT', '100000.00', '0.00', '2026-01-01 10:00:00');
INSERT INTO `account_mutations` VALUES ('114', '20', '23', 'CREDIT', '50000.00', '0.00', '2026-01-02 11:00:00');
INSERT INTO `account_mutations` VALUES ('115', '20', '24', 'CREDIT', '25000.00', '0.00', '2026-01-03 12:00:00');
INSERT INTO `account_mutations` VALUES ('116', '20', '25', 'CREDIT', '500000.00', '0.00', '2026-01-04 08:00:00');
INSERT INTO `account_mutations` VALUES ('117', '24', '34', 'CREDIT', '100000.00', '0.00', '2026-01-13 11:00:00');
INSERT INTO `account_mutations` VALUES ('118', '21', '36', 'CREDIT', '50000.00', '0.00', '2026-01-15 13:00:00');
INSERT INTO `account_mutations` VALUES ('119', '23', '39', 'CREDIT', '20000.00', '0.00', '2026-01-18 16:00:00');
INSERT INTO `account_mutations` VALUES ('120', '21', '42', 'CREDIT', '40678.00', '0.00', '2025-12-31 11:03:28');
INSERT INTO `account_mutations` VALUES ('121', '21', '44', 'CREDIT', '23341.00', '0.00', '2025-12-17 11:03:28');
INSERT INTO `account_mutations` VALUES ('122', '21', '45', 'CREDIT', '84882.00', '0.00', '2025-12-08 11:03:28');
INSERT INTO `account_mutations` VALUES ('123', '21', '46', 'CREDIT', '30251.00', '0.00', '2025-12-23 11:03:28');
INSERT INTO `account_mutations` VALUES ('124', '21', '47', 'CREDIT', '94399.00', '0.00', '2025-12-12 11:03:28');
INSERT INTO `account_mutations` VALUES ('125', '21', '48', 'CREDIT', '87982.00', '0.00', '2025-12-27 11:03:28');
INSERT INTO `account_mutations` VALUES ('126', '21', '51', 'CREDIT', '54365.00', '0.00', '2025-12-16 11:03:28');
INSERT INTO `account_mutations` VALUES ('127', '21', '52', 'CREDIT', '67322.00', '0.00', '2025-12-25 11:03:28');
INSERT INTO `account_mutations` VALUES ('179', '20', '86', 'DEBIT', '10000.00', '6289950000.00', '2026-01-09 15:17:18');
INSERT INTO `account_mutations` VALUES ('180', '23', '86', 'CREDIT', '10000.00', '172000.00', '2026-01-09 15:17:18');
INSERT INTO `account_mutations` VALUES ('181', '20', '87', 'DEBIT', '280000.00', '6289670000.00', '2026-01-09 15:21:42');
INSERT INTO `account_mutations` VALUES ('182', '23', '87', 'CREDIT', '280000.00', '452000.00', '2026-01-09 15:21:42');
INSERT INTO `account_mutations` VALUES ('183', '20', '88', 'DEBIT', '111000.00', '6289559000.00', '2026-01-09 15:31:45');
INSERT INTO `account_mutations` VALUES ('184', '24', '88', 'CREDIT', '111000.00', '2551000.00', '2026-01-09 15:31:45');
INSERT INTO `account_mutations` VALUES ('185', '20', '89', 'DEBIT', '40000.00', '6289519000.00', '2026-01-09 16:27:55');
INSERT INTO `account_mutations` VALUES ('186', '24', '89', 'CREDIT', '40000.00', '2591000.00', '2026-01-09 16:27:55');
INSERT INTO `account_mutations` VALUES ('187', '20', '90', 'DEBIT', '12000.00', '6289507000.00', '2026-01-09 17:34:55');
INSERT INTO `account_mutations` VALUES ('188', '26', '90', 'CREDIT', '12000.00', '15062000.00', '2026-01-09 17:34:55');
INSERT INTO `account_mutations` VALUES ('189', '20', '91', 'DEBIT', '15000.00', '6289492000.00', '2026-01-09 17:35:14');
INSERT INTO `account_mutations` VALUES ('190', '26', '91', 'CREDIT', '15000.00', '15077000.00', '2026-01-09 17:35:14');
INSERT INTO `account_mutations` VALUES ('191', '20', '92', 'DEBIT', '12000.00', '6289480000.00', '2026-01-12 11:03:27');
INSERT INTO `account_mutations` VALUES ('192', '26', '92', 'CREDIT', '12000.00', '15089000.00', '2026-01-12 11:03:27');
INSERT INTO `account_mutations` VALUES ('193', '20', '93', 'DEBIT', '12000.00', '6289468000.00', '2026-01-12 11:05:19');
INSERT INTO `account_mutations` VALUES ('194', '26', '93', 'CREDIT', '12000.00', '15101000.00', '2026-01-12 11:05:19');
INSERT INTO `account_mutations` VALUES ('195', '20', '94', 'DEBIT', '19000.00', '6289449000.00', '2026-01-12 11:06:36');
INSERT INTO `account_mutations` VALUES ('196', '26', '94', 'CREDIT', '19000.00', '15120000.00', '2026-01-12 11:06:36');
INSERT INTO `account_mutations` VALUES ('197', '20', '95', 'DEBIT', '90000.00', '6289359000.00', '2026-01-12 11:07:19');
INSERT INTO `account_mutations` VALUES ('198', '23', '95', 'CREDIT', '90000.00', '542000.00', '2026-01-12 11:07:19');
INSERT INTO `account_mutations` VALUES ('199', '20', '96', 'DEBIT', '15000.00', '6289344000.00', '2026-01-12 11:07:48');
INSERT INTO `account_mutations` VALUES ('200', '26', '96', 'CREDIT', '15000.00', '15135000.00', '2026-01-12 11:07:48');
INSERT INTO `account_mutations` VALUES ('201', '20', '97', 'DEBIT', '99000.00', '6289245000.00', '2026-01-12 11:37:21');
INSERT INTO `account_mutations` VALUES ('202', '25', '97', 'CREDIT', '99000.00', '609000.00', '2026-01-12 11:37:21');
INSERT INTO `account_mutations` VALUES ('203', '20', '98', 'DEBIT', '19000.00', '6289226000.00', '2026-01-12 11:44:44');
INSERT INTO `account_mutations` VALUES ('204', '27', '98', 'CREDIT', '19000.00', '6749000.00', '2026-01-12 11:44:44');
INSERT INTO `account_mutations` VALUES ('205', '20', '99', 'DEBIT', '10000.00', '6289216000.00', '2026-01-12 11:46:07');
INSERT INTO `account_mutations` VALUES ('206', '27', '99', 'CREDIT', '10000.00', '6759000.00', '2026-01-12 11:46:07');
INSERT INTO `account_mutations` VALUES ('207', '20', '100', 'DEBIT', '11001.00', '6289204999.00', '2026-01-12 12:19:53');
INSERT INTO `account_mutations` VALUES ('208', '23', '100', 'CREDIT', '11001.00', '553001.00', '2026-01-12 12:19:53');
INSERT INTO `account_mutations` VALUES ('209', '20', '101', 'DEBIT', '12000.00', '6289192999.00', '2026-01-12 13:00:21');
INSERT INTO `account_mutations` VALUES ('210', '27', '101', 'CREDIT', '12000.00', '6771000.00', '2026-01-12 13:00:21');
INSERT INTO `account_mutations` VALUES ('211', '20', '102', 'DEBIT', '62000.00', '6289130999.00', '2026-01-12 14:34:16');
INSERT INTO `account_mutations` VALUES ('212', '21', '102', 'CREDIT', '62000.00', '924000.00', '2026-01-12 14:34:16');
INSERT INTO `account_mutations` VALUES ('213', '20', '103', 'DEBIT', '12900.00', '6289118099.00', '2026-01-12 15:49:35');
INSERT INTO `account_mutations` VALUES ('214', '23', '103', 'CREDIT', '12900.00', '565901.00', '2026-01-12 15:49:35');
INSERT INTO `account_mutations` VALUES ('215', '20', '104', 'DEBIT', '11180.00', '6289106919.00', '2026-01-12 15:53:22');
INSERT INTO `account_mutations` VALUES ('216', '2', '104', 'CREDIT', '11180.00', '11180.00', '2026-01-12 15:53:22');
INSERT INTO `account_mutations` VALUES ('217', '20', '105', 'DEBIT', '23000.00', '6289083919.00', '2026-01-12 16:00:24');
INSERT INTO `account_mutations` VALUES ('218', '2', '105', 'CREDIT', '23000.00', '34180.00', '2026-01-12 16:00:24');
INSERT INTO `accounts` VALUES ('1', '1', '1950001', 'BDH', '6666000011112222', '50000.00', 'SAVINGS', 'BLOCKED', '2026-01-06 11:03:28');
INSERT INTO `accounts` VALUES ('2', '2', '1979001', 'HNL', '6666000033334444', '34180.00', 'CURRENT', 'ACTIVE', '2026-01-06 11:03:28');
INSERT INTO `accounts` VALUES ('3', '3', '1983000', 'BYR', '9999888877776666', '372000000.00', 'DEPOSITO', 'ACTIVE', '2026-01-06 11:03:28');
INSERT INTO `accounts` VALUES ('20', '4', '1983001', 'RUS', '5000111122223333', '6289083919.00', 'SAVINGS', 'ACTIVE', '2025-01-01 10:00:00');
INSERT INTO `accounts` VALUES ('21', '5', '1983002', 'HNL', '5000222233334444', '924000.00', 'SAVINGS', 'ACTIVE', '2025-01-02 11:30:00');
INSERT INTO `accounts` VALUES ('22', '6', '1983003', 'BYR', '5000333344445555', '300000.00', 'SAVINGS', 'ACTIVE', '2025-01-03 09:00:00');
INSERT INTO `accounts` VALUES ('23', '7', '1983004', 'BDH', '5000444455556666', '565901.00', 'SAVINGS', 'ACTIVE', '2025-01-04 14:00:00');
INSERT INTO `accounts` VALUES ('24', '8', '1983011', 'BDH', '5000999900001111', '2591000.00', 'SAVINGS', 'ACTIVE', '2025-01-05 10:00:00');
INSERT INTO `accounts` VALUES ('25', '9', '1983005', 'HFC', '5000555566667777', '609000.00', 'SAVINGS', 'ACTIVE', '2025-01-05 12:00:00');
INSERT INTO `accounts` VALUES ('26', '10', '1983999', 'BYR', '4000888899990000', '15135000.00', 'CURRENT', 'ACTIVE', '2024-12-01 08:00:00');
INSERT INTO `accounts` VALUES ('27', '11', '1983888', 'HFC', '4000777788889999', '6771000.00', 'SAVINGS', 'ACTIVE', '2024-12-01 08:00:00');
INSERT INTO `accounts` VALUES ('28', '12', '1983777', 'BDH', '5000666677778888', '2200000.00', 'SAVINGS', 'ACTIVE', '2025-01-06 09:00:00');
INSERT INTO `activity_logs` VALUES ('1', '4', 'HFC', 'LOGIN_SUCCESS', 'Login berhasil', '2026-01-01 08:00:00');
INSERT INTO `activity_logs` VALUES ('2', '4', 'HNL', 'CHECK_BALANCE', 'Melihat saldo rekening', '2026-01-01 08:05:00');
INSERT INTO `activity_logs` VALUES ('3', '4', 'HNL', 'TRANSFER_IN', 'Dana masuk Rp 100.000 dari Steve', '2026-01-01 10:00:00');
INSERT INTO `activity_logs` VALUES ('4', '4', 'UDS', 'PAYMENT_SUCCESS', 'Pembayaran Netflix Berhasil', '2026-01-02 09:00:00');
INSERT INTO `activity_logs` VALUES ('5', '4', 'HNL', 'LOGIN_FAILED', 'Gagal login (Password salah)', '2026-01-03 07:00:00');
INSERT INTO `activity_logs` VALUES ('6', '4', 'SBP', 'LOGIN_SUCCESS', 'Login berhasil', '2026-01-03 07:01:00');
INSERT INTO `activity_logs` VALUES ('7', '4', 'SMB', 'CHANGE_PASS', 'Password berhasil diubah', '2026-01-03 07:10:00');
INSERT INTO `activity_logs` VALUES ('8', '4', 'HFC', 'PROMO_NOTIF', 'Promo: Diskon 50% di Starcourt', '2026-01-04 10:00:00');
INSERT INTO `activity_logs` VALUES ('9', '4', 'UDS', 'TRANSFER_OUT', 'Transfer ke Dustin Rp 50.000', '2026-01-05 13:00:00');
INSERT INTO `activity_logs` VALUES ('10', '4', 'RUS', 'TOPUP_SUCCESS', 'Topup Pulsa Berhasil', '2026-01-05 13:05:00');
INSERT INTO `activity_logs` VALUES ('11', '4', 'SBP', 'SECURITY_ALERT', 'Login terdeteksi dari perangkat baru', '2026-01-06 12:00:00');
INSERT INTO `activity_logs` VALUES ('12', '4', 'HNL', 'WITHDRAWAL', 'Tarik tunai Rp 200.000', '2026-01-07 14:00:00');
INSERT INTO `activity_logs` VALUES ('13', '4', 'BYR', 'TRANSFER_IN', 'Dana masuk Rp 20.000 dari El', '2026-01-08 15:00:00');
INSERT INTO `activity_logs` VALUES ('14', '4', 'HNL', 'PAYMENT_SUCCESS', 'Pembayaran Pizza Berhasil', '2026-01-09 18:00:00');
INSERT INTO `activity_logs` VALUES ('15', '4', 'BYR', 'LOGIN_SUCCESS', 'Login berhasil', '2026-01-10 08:00:00');
INSERT INTO `activity_logs` VALUES ('16', '4', 'SBP', 'SYSTEM_INFO', 'Maintenance server dijadwalkan besok', '2026-01-10 09:00:00');
INSERT INTO `activity_logs` VALUES ('17', '4', 'UDS', 'CHECK_MUTATION', 'Melihat riwayat transaksi', '2026-01-10 09:05:00');
INSERT INTO `activity_logs` VALUES ('18', '4', 'SBP', 'TRANSFER_OUT', 'Transfer ke Will Rp 20.000', '2026-01-11 16:00:00');
INSERT INTO `activity_logs` VALUES ('19', '4', 'HNL', 'PROMO_NOTIF', 'Cashback 20% pembelian game', '2026-01-12 11:00:00');
INSERT INTO `activity_logs` VALUES ('20', '4', 'HNL', 'LOGOUT', 'Logout berhasil', '2026-01-12 20:00:00');
INSERT INTO `activity_logs` VALUES ('21', '1', 'BDH', 'LOGIN_SUCCESS', 'Login dari Creel House', '2026-01-06 11:03:28');
INSERT INTO `activity_logs` VALUES ('22', '1', 'SBP', 'ERROR', 'Koneksi terputus', '2026-01-06 11:03:28');
INSERT INTO `activity_logs` VALUES ('23', '1', 'UDS', 'CHECK_BALANCE', 'Cek Saldo', '2026-01-06 11:03:28');
INSERT INTO `activity_logs` VALUES ('24', '1', 'SMB', 'SECURITY', 'Akses ilegal terdeteksi', '2026-01-06 11:03:28');
INSERT INTO `activity_logs` VALUES ('25', '2', 'BYR', 'LOGIN_SUCCESS', 'Login dari Upside Down', '2026-01-06 11:03:28');
INSERT INTO `activity_logs` VALUES ('26', '2', 'RUS', 'MIND_CONNECT', 'Koneksi ke Max berhasil', '2026-01-06 11:03:28');
INSERT INTO `activity_logs` VALUES ('27', '2', 'RUS', 'PAYMENT', 'Pembayaran gagal', '2026-01-06 11:03:28');
INSERT INTO `activity_logs` VALUES ('28', '2', 'HFC', 'ALERT', 'Gerbang terbuka', '2026-01-06 11:03:28');
INSERT INTO `activity_logs` VALUES ('29', '3', 'BDH', 'LOGIN_SUCCESS', 'Login dari Hawkins Lab', '2026-01-06 11:03:28');
INSERT INTO `activity_logs` VALUES ('30', '3', 'SBP', 'TRANSFER', 'Transfer ke Subject 011 sukses', '2026-01-06 11:03:28');
INSERT INTO `activity_logs` VALUES ('31', '3', 'UDS', 'SYSTEM', 'Data eksperimen diunggah', '2026-01-06 11:03:28');
INSERT INTO `activity_logs` VALUES ('32', '3', 'HNL', 'LOGOUT', 'Logout', '2026-01-06 11:03:28');
INSERT INTO `ref_banks` VALUES ('1', 'BDH', 'BANK DISTRIC HAWKINS', '1');
INSERT INTO `ref_banks` VALUES ('2', 'BYR', 'BYERS FAMILY CREDIT UNION', '1');
INSERT INTO `ref_banks` VALUES ('3', 'HFC', 'HELLFIRE CLUB FINANCE', '1');
INSERT INTO `ref_banks` VALUES ('4', 'HNL', 'HAWKINS NATIONAL LAB', '1');
INSERT INTO `ref_banks` VALUES ('5', 'RUS', 'RUSSIAN BASE TREASURY', '1');
INSERT INTO `ref_banks` VALUES ('6', 'SBP', 'SURFER BOY PIZZA BANK', '1');
INSERT INTO `ref_banks` VALUES ('7', 'SMB', 'STARCOURT MALL BANK', '1');
INSERT INTO `ref_banks` VALUES ('8', 'UDS', 'UPSIDE DOWN SAVINGS', '1');
INSERT INTO `saved_beneficiaries` VALUES ('4', '4', 'RUS', '1983004', 'Will Zombie boy', '1', '2026-01-09 15:13:53');
INSERT INTO `saved_beneficiaries` VALUES ('5', '4', 'BDH', '1983011', 'El', '0', '2026-01-09 15:31:05');
INSERT INTO `saved_beneficiaries` VALUES ('6', '4', 'SMB', '1983999', 'Steve Anak tobat', '0', '2026-01-09 17:34:32');
INSERT INTO `saved_beneficiaries` VALUES ('10', '4', 'SBP', '1983005', 'Max Mayfield', '0', '2026-01-12 11:36:56');
INSERT INTO `saved_beneficiaries` VALUES ('11', '4', 'RUS', '1983888', 'Jim Hopper', '0', '2026-01-12 11:44:17');
INSERT INTO `saved_beneficiaries` VALUES ('12', '4', 'RUS', '1983002', 'Dustin Henderson', '0', '2026-01-12 14:33:48');
INSERT INTO `saved_beneficiaries` VALUES ('13', '4', 'HNL', '1979001', 'Vecna', '0', '2026-01-12 15:53:00');
INSERT INTO `transactions` VALUES ('1', 'TRX-HC-01', null, '1', 'BYR', null, '5000000.00', 'DEPOSIT', 'Warisan Keluarga Creel', 'SUCCESS', '1959-03-01 10:00:00');
INSERT INTO `transactions` VALUES ('2', 'PAY-HC-02', '1', null, 'RUS', null, '150000.00', 'PAYMENT', 'Perbaikan Jam Antik', 'SUCCESS', '1959-03-05 14:00:00');
INSERT INTO `transactions` VALUES ('3', 'TRX-HC-03', '1', '3', 'BYR', null, '2000000.00', 'TRANSFER', 'Donasi ke Lab Hawkins', 'SUCCESS', '1979-01-01 09:00:00');
INSERT INTO `transactions` VALUES ('4', 'TRX-VC-01', null, '2', 'SMB', null, '100000.00', 'DEPOSIT', 'Setor Tunai Upside Down', 'SUCCESS', '1984-01-01 00:00:00');
INSERT INTO `transactions` VALUES ('5', 'TRX-VC-02', '2', null, 'HNL', null, '50000.00', 'PAYMENT', 'Biaya Langganan Mind Flayer', 'SUCCESS', '1984-01-02 00:00:00');
INSERT INTO `transactions` VALUES ('6', 'TRX-VC-03', '2', '25', 'UDS', null, '100.00', 'TRANSFER', 'Pesan Mental ke Max', 'SUCCESS', '1986-03-01 12:00:00');
INSERT INTO `transactions` VALUES ('7', 'TRX-VC-04', '2', '28', 'UDS', null, '100.00', 'TRANSFER', 'Teror ke Nancy', 'SUCCESS', '1986-03-02 12:00:00');
INSERT INTO `transactions` VALUES ('8', 'TRX-VC-05', null, '2', 'SBP', null, '5000000.00', 'TOPUP', 'Energi Gate Opening', 'SUCCESS', '1986-03-03 12:00:00');
INSERT INTO `transactions` VALUES ('9', 'PAY-VC-06', '2', null, 'SMB', null, '666.00', 'PAYMENT', 'Pajak Dimensi Lain', 'SUCCESS', '1986-03-04 12:00:00');
INSERT INTO `transactions` VALUES ('10', 'TRX-VC-07', '2', '24', 'BYR', null, '1.00', 'TRANSFER', 'Hai Eleven', 'SUCCESS', '1986-03-05 12:00:00');
INSERT INTO `transactions` VALUES ('11', 'DEP-PB-01', null, '3', 'UDS', null, '100000000.00', 'DEPOSIT', 'Dana Riset Pemerintah', 'SUCCESS', '1983-01-01 08:00:00');
INSERT INTO `transactions` VALUES ('12', 'PAY-PB-02', '3', null, 'BYR', null, '5000000.00', 'PAYMENT', 'Tagihan Listrik Lab', 'SUCCESS', '1983-02-01 09:00:00');
INSERT INTO `transactions` VALUES ('13', 'PAY-PB-03', '3', null, 'SMB', null, '2000000.00', 'PAYMENT', 'Beli Eggos Grosir', 'SUCCESS', '1983-03-01 09:00:00');
INSERT INTO `transactions` VALUES ('14', 'TRX-PB-04', '3', '24', 'UDS', null, '500000.00', 'TRANSFER', 'Uang Saku Subject 011', 'SUCCESS', '1983-04-01 09:00:00');
INSERT INTO `transactions` VALUES ('15', 'TRX-PB-05', '3', '24', 'HFC', null, '500000.00', 'TRANSFER', 'Uang Saku Subject 011', 'SUCCESS', '1983-05-01 09:00:00');
INSERT INTO `transactions` VALUES ('16', 'TRX-PB-06', '3', '24', 'RUS', null, '500000.00', 'TRANSFER', 'Uang Saku Subject 011', 'SUCCESS', '1983-06-01 09:00:00');
INSERT INTO `transactions` VALUES ('17', 'TRX-PB-07', '3', '24', 'UDS', null, '500000.00', 'TRANSFER', 'Uang Saku Subject 011', 'SUCCESS', '1983-07-01 09:00:00');
INSERT INTO `transactions` VALUES ('18', 'PAY-PB-08', '3', null, 'HNL', null, '15000000.00', 'PAYMENT', 'Peralatan Sensorik', 'SUCCESS', '1983-08-01 09:00:00');
INSERT INTO `transactions` VALUES ('19', 'TRX-PB-09', '3', '27', 'HFC', null, '200000.00', 'TRANSFER', 'Dana Taktis Hopper', 'SUCCESS', '1983-09-01 09:00:00');
INSERT INTO `transactions` VALUES ('20', 'TRX-PB-10', null, '3', 'BYR', null, '50000000.00', 'DEPOSIT', 'Bonus Project Nina', 'SUCCESS', '1986-01-01 09:00:00');
INSERT INTO `transactions` VALUES ('21', 'WDR-PB-11', '3', null, 'BDH', null, '1000000.00', 'PENARIKAN', 'Tarik Tunai Darurat', 'SUCCESS', '1986-01-02 09:00:00');
INSERT INTO `transactions` VALUES ('22', 'TRX-IN-01', '26', '20', 'HFC', null, '100000.00', 'TRANSFER', 'Steve: Ganti Pizza', 'SUCCESS', '2026-01-01 10:00:00');
INSERT INTO `transactions` VALUES ('23', 'TRX-IN-02', '28', '20', 'BDH', null, '50000.00', 'TRANSFER', 'Nancy: Sisa Kembalian', 'SUCCESS', '2026-01-02 11:00:00');
INSERT INTO `transactions` VALUES ('24', 'TRX-IN-03', '23', '20', 'SBP', null, '25000.00', 'TRANSFER', 'Will: Patungan Komik', 'SUCCESS', '2026-01-03 12:00:00');
INSERT INTO `transactions` VALUES ('25', 'TRX-IN-04', null, '20', 'SBP', null, '500000.00', 'DEPOSIT', 'Uang Saku Ibu', 'SUCCESS', '2026-01-04 08:00:00');
INSERT INTO `transactions` VALUES ('26', 'TRX-IN-05', '22', '20', 'BYR', null, '15000.00', 'TRANSFER', 'Lucas: Kalah Taruhan D&D', 'SUCCESS', '2026-01-05 14:00:00');
INSERT INTO `transactions` VALUES ('27', 'TRX-IN-06', '24', '20', 'BYR', null, '20000.00', 'TRANSFER', 'El: Titip Beli Minum', 'SUCCESS', '2026-01-06 15:00:00');
INSERT INTO `transactions` VALUES ('28', 'TRX-IN-07', null, '20', 'BYR', null, '1000000.00', 'DEPOSIT', 'Angpao Tahun Baru', 'SUCCESS', '2026-01-07 09:00:00');
INSERT INTO `transactions` VALUES ('29', 'TRX-IN-08', '21', '20', 'BYR', null, '30000.00', 'TRANSFER', 'Dustin: Hutang Radio', 'SUCCESS', '2026-01-08 10:00:00');
INSERT INTO `transactions` VALUES ('30', 'TRX-IN-09', '26', '20', 'SMB', null, '200000.00', 'TRANSFER', 'Steve: Traktiran Nonton', 'SUCCESS', '2026-01-09 18:00:00');
INSERT INTO `transactions` VALUES ('31', 'TRX-IN-10', '25', '20', 'HNL', null, '10000.00', 'TRANSFER', 'Max: Sewa Kaset', 'SUCCESS', '2026-01-10 13:00:00');
INSERT INTO `transactions` VALUES ('32', 'PAY-OUT-01', '20', null, 'HNL', null, '50000.00', 'PAYMENT', 'Langganan Netflix', 'SUCCESS', '2026-01-11 09:00:00');
INSERT INTO `transactions` VALUES ('33', 'TOP-OUT-02', '20', null, 'HFC', null, '25000.00', 'TOPUP', 'Pulsa Telepon', 'SUCCESS', '2026-01-12 10:00:00');
INSERT INTO `transactions` VALUES ('34', 'TRX-OUT-03', '20', '24', 'UDS', null, '100000.00', 'TRANSFER', 'Kado Ultah Eleven', 'SUCCESS', '2026-01-13 11:00:00');
INSERT INTO `transactions` VALUES ('35', 'PAY-OUT-04', '20', null, 'UDS', null, '15000.00', 'PAYMENT', 'Jajan di Kantin', 'SUCCESS', '2026-01-14 12:00:00');
INSERT INTO `transactions` VALUES ('36', 'TRX-OUT-05', '20', '21', 'BYR', null, '50000.00', 'TRANSFER', 'Bayar Hutang Dustin', 'SUCCESS', '2026-01-15 13:00:00');
INSERT INTO `transactions` VALUES ('37', 'PAY-OUT-06', '20', null, 'BDH', null, '200000.00', 'PENARIKAN', 'Tarik Tunai ATM', 'SUCCESS', '2026-01-16 14:00:00');
INSERT INTO `transactions` VALUES ('38', 'PAY-OUT-07', '20', null, 'UDS', null, '45000.00', 'PAYMENT', 'Beli Majalah', 'SUCCESS', '2026-01-17 15:00:00');
INSERT INTO `transactions` VALUES ('39', 'TRX-OUT-08', '20', '23', 'RUS', null, '20000.00', 'TRANSFER', 'Pinjamkan Will', 'SUCCESS', '2026-01-18 16:00:00');
INSERT INTO `transactions` VALUES ('40', 'TOP-OUT-09', '20', null, 'UDS', null, '100000.00', 'TOPUP', 'Voucher Game', 'SUCCESS', '2026-01-01 17:00:00');
INSERT INTO `transactions` VALUES ('41', 'PAY-OUT-10', '20', null, 'BYR', null, '30000.00', 'PAYMENT', 'Surfer Boy Pizza', 'SUCCESS', '2025-01-23 18:00:00');
INSERT INTO `transactions` VALUES ('42', 'AUTO-5580', '21', '21', 'SBP', null, '40678.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2025-12-31 11:03:28');
INSERT INTO `transactions` VALUES ('43', 'AUTO-8197', null, null, 'HNL', null, '14581.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2025-12-08 11:03:28');
INSERT INTO `transactions` VALUES ('44', 'AUTO-4988', '21', '21', 'BYR', null, '23341.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2025-12-17 11:03:28');
INSERT INTO `transactions` VALUES ('45', 'AUTO-6417', null, '21', 'SMB', null, '84882.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2025-12-08 11:03:28');
INSERT INTO `transactions` VALUES ('46', 'AUTO-2972', '21', '21', 'BYR', null, '30251.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2025-12-23 11:03:28');
INSERT INTO `transactions` VALUES ('47', 'AUTO-5271', null, '21', 'HNL', null, '94399.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2025-12-12 11:03:28');
INSERT INTO `transactions` VALUES ('48', 'AUTO-3601', null, '21', 'SBP', null, '87982.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2025-12-27 11:03:28');
INSERT INTO `transactions` VALUES ('49', 'AUTO-1465', '21', null, 'BYR', null, '34659.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2026-01-02 11:03:28');
INSERT INTO `transactions` VALUES ('50', 'AUTO-6352', '21', null, 'HFC', null, '43713.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2025-12-27 11:03:28');
INSERT INTO `transactions` VALUES ('51', 'AUTO-3649', '21', '21', 'SBP', null, '54365.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2025-12-16 11:03:28');
INSERT INTO `transactions` VALUES ('52', 'AUTO-9584', '21', '21', 'HNL', null, '67322.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2025-12-25 11:03:28');
INSERT INTO `transactions` VALUES ('53', 'AUTO-435', '21', null, 'HFC', null, '89889.00', 'TRANSFER', 'Transaksi Dustin Auto', 'SUCCESS', '2026-01-01 11:03:28');
INSERT INTO `transactions` VALUES ('57', 'DUM-01', '22', null, 'UDS', null, '50000.00', 'PAYMENT', 'Jajan Lucas', 'SUCCESS', '2026-01-06 11:03:28');
INSERT INTO `transactions` VALUES ('58', 'DUM-02', '22', null, 'HFC', null, '20000.00', 'TOPUP', 'Pulsa Lucas', 'SUCCESS', '2026-01-06 11:03:28');
INSERT INTO `transactions` VALUES ('59', 'DUM-03', '23', null, 'BDH', null, '15000.00', 'PAYMENT', 'Jajan Will', 'SUCCESS', '2026-01-06 11:03:28');
INSERT INTO `transactions` VALUES ('60', 'DUM-04', '23', null, 'RUS', null, '100000.00', 'PENARIKAN', 'Tarik Will', 'SUCCESS', '2026-01-06 11:03:28');
INSERT INTO `transactions` VALUES ('61', 'DUM-05', '24', null, 'HNL', null, '75000.00', 'PAYMENT', 'Waffle Eleven', 'SUCCESS', '2026-01-06 11:03:28');
INSERT INTO `transactions` VALUES ('62', 'DUM-06', '24', null, 'HNL', null, '500000.00', 'DEPOSIT', 'Tabungan El', 'SUCCESS', '2026-01-06 11:03:28');
INSERT INTO `transactions` VALUES ('63', 'DUM-07', '26', null, 'BDH', null, '200000.00', 'PAYMENT', 'Bensin Steve', 'SUCCESS', '2026-01-06 11:03:28');
INSERT INTO `transactions` VALUES ('64', 'DUM-08', '26', null, 'UDS', null, '150000.00', 'PAYMENT', 'Hair Spray Steve', 'SUCCESS', '2026-01-06 11:03:28');
INSERT INTO `transactions` VALUES ('65', 'DUM-09', '27', null, 'UDS', null, '300000.00', 'PAYMENT', 'Donuts Hopper', 'SUCCESS', '2026-01-06 11:03:28');
INSERT INTO `transactions` VALUES ('66', 'DUM-10', '27', null, 'SBP', null, '5000000.00', 'DEPOSIT', 'Gaji Hopper', 'SUCCESS', '2026-01-06 11:03:28');
INSERT INTO `transactions` VALUES ('67', 'TRF-2601077773', '27', '20', 'HFC', null, '1000000.00', 'TRANSFER', 'Uang jajan dari Hopper', 'SUCCESS', '2026-01-07 15:08:22');
INSERT INTO `transactions` VALUES ('68', 'TRF-2601078404', '20', '26', 'BDH', null, '50000.00', 'TRANSFER', 'Transfer ke Steve Harrington', 'SUCCESS', '2026-01-07 15:20:55');
INSERT INTO `transactions` VALUES ('69', 'TRF-2601074729', '20', '27', 'SBP', null, '100000.00', 'TRANSFER', 'Transfer ke Jim Hopper', 'SUCCESS', '2026-01-07 15:23:59');
INSERT INTO `transactions` VALUES ('70', 'TRF-2601073178', '20', '27', 'RUS', null, '100000.00', 'TRANSFER', 'Transfer ke Jim Hopper', 'SUCCESS', '2026-01-07 15:30:22');
INSERT INTO `transactions` VALUES ('71', 'TRF-2601078178', '20', '27', 'UDS', null, '20000.00', 'TRANSFER', 'gw tf  bro', 'SUCCESS', '2026-01-07 15:33:40');
INSERT INTO `transactions` VALUES ('72', 'TRF-2601076939', '20', '27', 'SBP', null, '10000.00', 'TRANSFER', 'Transfer ke Jim Hopper', 'SUCCESS', '2026-01-07 15:43:52');
INSERT INTO `transactions` VALUES ('73', 'TRF-2601072481', '27', '20', 'HFC', null, '1000000.00', 'TRANSFER', 'Uang jajan dari Hopper', 'SUCCESS', '2026-01-07 19:24:04');
INSERT INTO `transactions` VALUES ('74', 'TRF-2601071095', '3', '20', 'UDS', null, '500000000.00', 'TRANSFER', 'Transfer ke Mike Wheeler', 'SUCCESS', '2026-01-07 19:38:47');
INSERT INTO `transactions` VALUES ('75', 'TRF-2601074353', '3', '20', 'BDH', null, '27000000.00', 'TRANSFER', 'Transfer ke Mike Wheeler', 'SUCCESS', '2026-01-07 19:39:12');
INSERT INTO `transactions` VALUES ('76', 'TRF-2601074620', '3', '20', 'HFC', null, '100000000.00', 'DEPOSIT', 'Rekening Papa di hack dustin', 'SUCCESS', '2026-01-07 19:40:09');
INSERT INTO `transactions` VALUES ('77', 'TRF-2601078738', '20', '21', 'HFC', null, '50000.00', 'TRANSFER', 'Transfer ke Dustin Henderson', 'SUCCESS', '2026-01-07 20:39:19');
INSERT INTO `transactions` VALUES ('78', 'TRF-2601072024', '20', '21', 'BDH', null, '10000.00', 'TOPUP', 'Transfer ke Dustin Henderson', 'SUCCESS', '2026-01-07 20:39:42');
INSERT INTO `transactions` VALUES ('79', 'TRF-2601074649', '20', '21', 'SBP', null, '10000.00', 'PENARIKAN', 'Transfer ke Dustin Henderson', 'SUCCESS', '2026-01-07 20:42:35');
INSERT INTO `transactions` VALUES ('80', 'TRF-2601071090', '20', '21', 'HFC', null, '11000.00', 'PAYMENT', 'Transfer ke Dustin Henderson', 'SUCCESS', '2026-01-07 20:53:49');
INSERT INTO `transactions` VALUES ('81', 'TRF-2601073641', '20', '23', 'UDS', null, '12000.00', 'TRANSFER', 'Modal di Upside down', 'SUCCESS', '2026-01-07 23:04:14');
INSERT INTO `transactions` VALUES ('82', 'TRF-2601079755', '20', '21', 'SMB', null, '31000.00', 'TRANSFER', 'Transfer ke Dustin Henderson', 'SUCCESS', '2026-01-07 23:05:10');
INSERT INTO `transactions` VALUES ('83', 'TRF-2601081713', '24', '25', 'BYR', null, '50000.00', 'PAYMENT', 'Patungan beli seblak', 'SUCCESS', '2026-01-08 11:35:28');
INSERT INTO `transactions` VALUES ('84', 'TRF-2601083972', '24', '25', 'SBP', null, '10000.00', 'PAYMENT', 'Urunan  beli cempol', 'SUCCESS', '2026-01-08 11:41:42');
INSERT INTO `transactions` VALUES ('85', 'TRF-2601089192', '20', '28', 'RUS', null, '1000000.00', 'DEPOSIT', 'Uang jajan dari Sultan', 'SUCCESS', '2026-01-08 15:08:30');
INSERT INTO `transactions` VALUES ('86', 'TRF-2601097342', '20', '23', 'UDS', null, '10000.00', 'TRANSFER', '', 'SUCCESS', '2026-01-09 15:17:18');
INSERT INTO `transactions` VALUES ('87', 'TRF-2601099377', '20', '23', 'SMB', null, '280000.00', 'TRANSFER', 'buat jajan di upside down', 'SUCCESS', '2026-01-09 15:21:42');
INSERT INTO `transactions` VALUES ('88', 'TRF-2601095502', '20', '24', 'SBP', null, '111000.00', 'TRANSFER', '', 'SUCCESS', '2026-01-09 15:31:45');
INSERT INTO `transactions` VALUES ('89', 'TRF-2601095495', '20', '24', 'BDH', null, '40000.00', 'TRANSFER', '', 'SUCCESS', '2026-01-09 16:27:55');
INSERT INTO `transactions` VALUES ('90', 'TRF-2601097610', '20', '26', 'UDS', null, '12000.00', 'TRANSFER', 'bayar geprek', 'SUCCESS', '2026-01-09 17:34:55');
INSERT INTO `transactions` VALUES ('91', 'TRF-2601098419', '20', '26', 'BYR', null, '15000.00', 'TRANSFER', 'beli bakso', 'SUCCESS', '2026-01-09 17:35:14');
INSERT INTO `transactions` VALUES ('92', 'TRF-2601126697', '20', '26', 'UDS', null, '12000.00', 'TRANSFER', 'top up ep ep', 'SUCCESS', '2026-01-12 11:03:27');
INSERT INTO `transactions` VALUES ('93', 'TRF-2601121777', '20', '26', 'HFC', null, '12000.00', 'TRANSFER', 'ep ep lagi', 'SUCCESS', '2026-01-12 11:05:19');
INSERT INTO `transactions` VALUES ('94', 'TRF-2601127570', '20', '26', 'RUS', null, '19000.00', 'TRANSFER', '', 'SUCCESS', '2026-01-12 11:06:36');
INSERT INTO `transactions` VALUES ('95', 'TRF-2601125287', '20', '23', 'UDS', null, '90000.00', 'TRANSFER', 'buat ngopi', 'SUCCESS', '2026-01-12 11:07:19');
INSERT INTO `transactions` VALUES ('96', 'TRF-2601124881', '20', '26', 'HFC', null, '15000.00', 'TRANSFER', '', 'SUCCESS', '2026-01-12 11:07:48');
INSERT INTO `transactions` VALUES ('97', 'TRF-2601122898', '20', '25', 'RUS', null, '99000.00', 'TRANSFER', 'tf cilok', 'SUCCESS', '2026-01-12 11:37:21');
INSERT INTO `transactions` VALUES ('98', 'TRF-2601124653', '20', '27', 'RUS', null, '19000.00', 'TRANSFER', '', 'SUCCESS', '2026-01-12 11:44:44');
INSERT INTO `transactions` VALUES ('99', 'TRF-2601122015', '20', '27', 'SBP', null, '10000.00', 'TRANSFER', '', 'SUCCESS', '2026-01-12 11:46:07');
INSERT INTO `transactions` VALUES ('100', 'TRF-2601126082', '20', '23', 'BYR', null, '11001.00', 'TRANSFER', 'tunggakan', 'SUCCESS', '2026-01-12 12:19:53');
INSERT INTO `transactions` VALUES ('101', 'TRF-2601124015', '20', '27', 'BYR', null, '12000.00', 'TRANSFER', 'haha', 'SUCCESS', '2026-01-12 13:00:21');
INSERT INTO `transactions` VALUES ('102', 'TRF-2601121065', '20', '21', 'RUS', null, '62000.00', 'TRANSFER', 'bayar upeti', 'SUCCESS', '2026-01-12 14:34:16');
INSERT INTO `transactions` VALUES ('103', 'TRF-2601127120', '20', '23', null, null, '12900.00', 'TRANSFER', 'depo pacuan kuda', 'SUCCESS', '2026-01-12 15:49:35');
INSERT INTO `transactions` VALUES ('104', 'TRF-2601122609', '20', '2', null, null, '11180.00', 'TRANSFER', 'bayar kos ', 'SUCCESS', '2026-01-12 15:53:22');
INSERT INTO `transactions` VALUES ('105', 'TRF-2601122705', '20', '2', null, null, '23000.00', 'TRANSFER', '', 'SUCCESS', '2026-01-12 16:00:24');
INSERT INTO `users` VALUES ('1', 'HNL', 'Henry Creel', 'henry@creelhouse.com', '08100000666', '1959-01-01 00:00:00');
INSERT INTO `users` VALUES ('2', 'SMB', 'Vecna', '001@upsidedown.com', '08100000001', '1979-09-01 00:00:00');
INSERT INTO `users` VALUES ('3', 'UDS', 'Dr. Martin Brenner', 'papa@hawkinslab.gov', '08100000999', '1983-01-01 00:00:00');
INSERT INTO `users` VALUES ('4', 'HNL', 'Mike Wheeler', 'mike@avclub.com', '08120000001', '2025-01-01 10:00:00');
INSERT INTO `users` VALUES ('5', 'RUS', 'Dustin Henderson', 'dustin@suzie.com', '08120000002', '2025-01-02 11:30:00');
INSERT INTO `users` VALUES ('6', 'RUS', 'Lucas Sinclair', 'lucas@hawkins.com', '08120000003', '2025-01-03 09:00:00');
INSERT INTO `users` VALUES ('7', 'RUS', 'Will Byers', 'will@wizard.com', '08120000004', '2025-01-04 14:00:00');
INSERT INTO `users` VALUES ('8', 'SMB', 'Eleven Hopper', 'el@eggos.com', '08120000011', '2025-01-05 10:00:00');
INSERT INTO `users` VALUES ('9', 'RUS', 'Max Mayfield', 'madmax@arcade.com', '08120000005', '2025-01-05 12:00:00');
INSERT INTO `users` VALUES ('10', 'SMB', 'Steve Harrington', 'steve@scoops.com', '08129999999', '2024-12-01 08:00:00');
INSERT INTO `users` VALUES ('11', 'HFC', 'Jim Hopper', 'chief@police.gov', '08128888888', '2024-12-01 08:00:00');
INSERT INTO `users` VALUES ('12', 'SMB', 'Nancy Wheeler', 'nancy@press.com', '08127777777', '2025-01-06 09:00:00');
