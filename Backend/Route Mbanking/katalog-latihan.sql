/*
MySQL Data Transfer
Source Host: localhost
Source Database: katalog-latihan
Target Host: localhost
Target Database: katalog-latihan
Date: 27/12/2025 13.06.24
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for categories
-- ----------------------------
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for instructors
-- ----------------------------
DROP TABLE IF EXISTS `instructors`;
CREATE TABLE `instructors` (
  `instructor_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `bio` text,
  PRIMARY KEY (`instructor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for products
-- ----------------------------
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `instructor_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`),
  KEY `category_id` (`category_id`),
  KEY `instructor_id` (`instructor_id`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`),
  CONSTRAINT `products_ibfk_2` FOREIGN KEY (`instructor_id`) REFERENCES `instructors` (`instructor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for reviews
-- ----------------------------
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) DEFAULT NULL,
  `user_name` varchar(100) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `comment` text,
  PRIMARY KEY (`review_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records 
-- ----------------------------
INSERT INTO `categories` VALUES ('1', 'Web Development');
INSERT INTO `categories` VALUES ('2', 'Graphic Design');
INSERT INTO `categories` VALUES ('3', 'Digital Marketing');
INSERT INTO `instructors` VALUES ('1', 'Budi Setiawan', 'Senior Fullstack Developer dengan pengalaman 10 tahun.');
INSERT INTO `instructors` VALUES ('2', 'Sari Wijaya', 'Expert UI/UX Designer di tech startup global.');
INSERT INTO `products` VALUES ('1', 'Belajar React JS Dasar', 'Kursus intensif membuat aplikasi web modern.', '250000.00', '1', '1', '2025-12-27 13:04:29');
INSERT INTO `products` VALUES ('2', 'Mastering Adobe Illustrator', 'Panduan lengkap desain vektor untuk pemula.', '150000.00', '2', '2', '2025-12-27 13:04:29');
INSERT INTO `products` VALUES ('3', 'Strategi SEO 2024', 'Cara menaikkan ranking website di Google.', '200000.00', '3', '1', '2025-12-27 13:04:29');
INSERT INTO `reviews` VALUES ('1', '1', 'Andi', '5', 'Penjelasannya sangat mudah dipahami!');
INSERT INTO `reviews` VALUES ('2', '1', 'Maya', '4', 'Materi bagus, tapi video agak lambat dibuka.');
INSERT INTO `reviews` VALUES ('3', '2', 'Riko', '5', 'Sekarang saya sudah bisa bikin logo sendiri.');
