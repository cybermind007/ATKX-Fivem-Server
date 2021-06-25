-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.17 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for essentialmode
CREATE DATABASE IF NOT EXISTS `essentialmode` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `essentialmode`;

-- Dumping structure for table essentialmode.fine_types
CREATE TABLE IF NOT EXISTS `fine_types_ems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table essentialmode.fine_types: ~70 rows (approximately)
/*!40000 ALTER TABLE `fine_types_ems` DISABLE KEYS */;
INSERT INTO `fine_types_ems` (`id`, `label`, `amount`, `category`) VALUES
	(1, '(I)Illegal Passing', 150, 0),
	(2, '(I)Illegal Turn', 70, 0),
	(3, '(I)Illegal U-turn', 70, 0),
	(4, '(I)Jaywalking', 50, 0),
	(5, '(I)Loitering', 50, 0),
	(6, '(I)Failure to Obey Traffic Control Devices', 150, 0),
	(7, '(I)Failure to Stop', 150, 0),
	(8, '(I)Failure to Yield to Emergency Vehicle', 250, 0),
	(9, '(I)Riding on a Sidewalk', 70, 0),
	(10, '(I)Stalking', 170, 0),
	(11, '(I)Speeding < 5 MPH', 90, 0),
	(12, '(I)Speeding 5-15 MPH', 130, 0),
	(13, '(I)Speeding 15-30 MPH', 180, 0),
	(14, '(I)Speeding > 30 MPH', 300, 0),
	(15, '(I)Driving on the Wrong Side of The Road', 200, 0),
	(16, '(M)Possession of a stolen identification(5M)', 500, 0),
	(17, '(M)Possession of a Controlled Dangerous Substance(15M)', 340, 0),
	(18, '(M)Possession of Drug Paraphernalia (5M)', 120, 0),
	(19, '(M)Possession of Marijuana (More than 30G)(10M)', 260, 0),
	(20, '(M)Receiving / Possession Stolen Property(10M)', 350, 0),
	(21, '(M)Reckless Driving(10M)', 110, 1),
	(22, '(M)Hit and Run(5M)', 300, 1),
	(23, '(F)Hit and Run(20M)', 750, 1),
	(24, '(M)Evading(10M)', 250, 1),
	(25, '(F)Reckless Evading(20M)', 450, 1),
	(26, '(M)Assault(10M)', 200, 1),
	(27, '(M)Assault on Emergency Personnel(15M)', 90, 1),
	(28, '(F)Involuntary Manslaughter(35M)', 2000, 1),
	(29, '(F)Vehicular Manslaughter(35M)', 3000, 1),
	(30, '(F)Voluntary Manslaughter(40M)', 4000, 1),
	(31, '(F)Second Degree Murder(55M)', 5000, 2),
	(32, '(F)Second Degree Murder on Emergency Personnel(100M)', 10000, 2),
	(33, '(F)Accessory Second Degree Murder(30M)', 2000, 2),
	(34, '(F)Accessory Second Degree Murder on Emergency Personnel(35M)', 3000, 2),
	(35, '(F)First Degree Murder(75M)', 7500, 2),
	(36, '(F)First Degree Murder on a Emergency Personnel(9999M)(PERMA)', 50000, 2),
	(37, '(M)Unlawful Imprisonment(10M)', 500, 2),
	(38, '(F)Kidnapping(15M)', 750, 2),
	(39, '(M)Criminal Threats(5M)', 300, 2),
	(40, '(F)Assault with a Deadly Weapon(15M)', 800, 2),
	(41, '(M)Petty Theft<$1000', 500, 2),
	(42, '(F)Grand Theft>$1000(10M)', 1000, 2),
	(43, '(F)Grand Theft Auto(15M)', 750, 2),
	(44, '(F)Second Degree Robbery(20M)', 1500, 2),
	(45, '(F)First Degree Robbery w/ Serious Injury(30M)', 2000, 3),
	(46, '(F)Extortion(15M)', 500, 3),
	(47, '(F)Impersonation(20M)', 300, 3),
	(48, '(F)Impersonating a Law Enforcement Officer', 500, 3),
	(49, '(F)Vehicle Registration Fraud(20M)', 650, 3),
	(50, '(F)Burglary(20M)', 500, 3),
	(51, '(M)Trespassing(5M)', 250, 3),
	(52, '(F)Felony Trespassing(10M)', 350, 2),
	(53, '(F)Bribery(5M)', 350, 2),
	(54, '(F)Escaping Custody(15M)', 400, 2),
	(55, '(F)Jailbreak(30M)', 1000, 2),
	(56, '(M)Disobeying a Law Enforcement Officer(5M)', 150, 2),
	(57, '(M)Disorderly Conduct(5M)', 150, 2),
	(58, '(M)Disturbing the Peace(5M)', 150, 2),
	(59, '(M)Vandalism of Government Property(10M)', 350, 2),
	(60, '(M)Criminal Possession of a Firearm [Class 1](10M)', 500, 2),
	(61, '(F)Criminal Possession of a Firearm [Class 2](20M)', 750, 2),
	(62, '(F)Criminal Possession of a Firearm [Class 3](30M)', 1000, 2),
	(63, '(F)Criminal Sale of a Firearm [Class 1](15M)', 1000, 2),
	(64, '(F)Criminal Sale of a Firearm [Class 2](25M)', 1250, 2),
	(65, '(F)Criminal Sale of a Firearm [Class 3](35M)', 1500, 2),
	(66, '(M)Criminal Use of a Firearm(10M)', 600, 2),
	(67, '(M)Brandishing(10M)', 600, 2),
	(68, '(M)Resisting Arrest(15M)', 500, 2),
	(69, '(F)Terrorism(100M)', 15000, 2),
	(70, '(M)Driving While Intoxicated(10M)(Loss of License)', 750, 2);
/*!40000 ALTER TABLE `fine_types` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
