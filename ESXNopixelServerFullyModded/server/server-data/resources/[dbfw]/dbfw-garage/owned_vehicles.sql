-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.3.16-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for onecity
CREATE DATABASE IF NOT EXISTS `onecity` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `onecity`;

-- Dumping structure for table onecity.owned_vehicles
CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(30) NOT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext NOT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `stored` tinyint(1) NOT NULL DEFAULT 0,
  `state` varchar(50) NOT NULL DEFAULT 'Out',
  `finance` int(32) NOT NULL DEFAULT 0,
  `model` varchar(60) NOT NULL DEFAULT '0',
  `financetimer` int(32) NOT NULL DEFAULT 0,
  `garage` varchar(200) DEFAULT 'A',
  `engine_damage` int(11) DEFAULT 1000,
  `body_damage` int(11) DEFAULT 1000,
  `lasthouse` int(11) DEFAULT 0,
  `degredation` varchar(100) DEFAULT '100,100,100,100,100,100,100',
  `fuel` int(11) NOT NULL DEFAULT 100,
  `modLivery` int(11) DEFAULT NULL,
  `job` varchar(50) DEFAULT NULL,
  `paidprice` int(11) DEFAULT 0,
  `repaytime` int(32) DEFAULT 0,
  `date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

-- Dumping data for table onecity.owned_vehicles: ~2 rows (approximately)
/*!40000 ALTER TABLE `owned_vehicles` DISABLE KEYS */;
REPLACE INTO `owned_vehicles` (`id`, `owner`, `plate`, `vehicle`, `type`, `stored`, `state`, `finance`, `model`, `financetimer`, `garage`, `engine_damage`, `body_damage`, `lasthouse`, `degredation`, `fuel`, `modLivery`, `job`, `paidprice`, `repaytime`, `date`) VALUES
	(1, 'steam:11000010aa15521', '35EUX133', '{"modTank":-1,"neonEnabled":[false,false,false,false],"neonColor":[255,0,255],"modSeats":-1,"engineHealth":998.875,"modFender":-1,"modTrimB":-1,"modFrontBumper":-1,"modXenon":false,"modDashboard":-1,"tyres":[false,false,false,false,false,false,false],"windowTint":-1,"modSpeakers":-1,"modEngineBlock":-1,"modTrunk":-1,"fuelLevel":80.0,"modRightFender":-1,"modDial":-1,"modGrille":-1,"modAPlate":-1,"modSuspension":-1,"modHydrolic":-1,"modTurbo":false,"dirtLevel":3.2,"wheels":3,"modBackWheels":-1,"pearlescentColor":3,"modBrakes":-1,"modAirFilter":-1,"plateIndex":0,"modRearBumper":-1,"modHood":-1,"modFrontWheels":-1,"modStruts":-1,"modRoof":-1,"wheelColor":156,"modWindows":-1,"modHorns":-1,"modSteeringWheel":-1,"tyreSmokeColor":[255,255,255],"modTrimA":-1,"modVanityPlate":-1,"model":142944341,"modSideSkirt":-1,"modPlateHolder":-1,"modEngine":-1,"plate":"35EUX133","modLivery":0,"doors":[false,false,false,false,false,false],"modSpoilers":-1,"modFrame":-1,"color1":0,"modExhaust":-1,"modAerials":-1,"color2":0,"modSmokeEnabled":1,"extras":{"10":false,"12":false},"bodyHealth":984.0,"modShifterLeavers":-1,"windows":[1,1,1,1,1,1,1,1,1,1,1,false,false],"modTransmission":-1,"modArchCover":-1,"modDoorSpeaker":-1,"modArmor":-1,"modOrnaments":-1}', 'car', 0, 'In', 0, 'baller2', 0, 'T', 999, 985, 0, '99,100,100,100,100,99,100,0', 100, 0, NULL, 44000, 0, '2020-08-14'),
	(2, 'steam:11000010aa15521', '42GPQ107', '{"pearlescentColor":3,"modGrille":-1,"modPlateHolder":-1,"modBackWheels":-1,"windowTint":-1,"plateIndex":0,"modSmokeEnabled":false,"modVanityPlate":-1,"modFender":-1,"neonEnabled":[false,false,false,false],"modSteeringWheel":-1,"modRoof":-1,"modAirFilter":-1,"modTransmission":-1,"modWindows":-1,"tyreSmokeColor":[255,255,255],"dirtLevel":8.0,"modSpoilers":-1,"modDashboard":-1,"modArchCover":-1,"color1":0,"modSideSkirt":-1,"modArmor":-1,"modEngineBlock":-1,"modSeats":-1,"modAPlate":-1,"modExhaust":-1,"modOrnaments":-1,"plate":"42GPQ107","modHorns":-1,"neonColor":[255,0,255],"wheels":3,"modTurbo":false,"modAerials":-1,"modRearBumper":-1,"modTrimB":-1,"fuelLevel":80.0,"modTrunk":-1,"color2":0,"wheelColor":156,"modDoorSpeaker":-1,"modStruts":-1,"modDial":-1,"modTank":-1,"modSpeakers":-1,"modHood":-1,"modSuspension":-1,"modFrame":-1,"modBrakes":-1,"modTrimA":-1,"modFrontBumper":-1,"model":142944341,"bodyHealth":1000.0,"modXenon":false,"modEngine":-1,"engineHealth":1000.0,"modHydrolic":-1,"modShifterLeavers":-1,"modFrontWheels":-1,"modLivery":-1,"modRightFender":-1,"extras":{"12":false,"10":true}}', 'car', 0, 'In', 0, 'baller2', 0, 'T', 1000, 1000, 0, '100,100,100,100,100,100,100', 100, NULL, NULL, 44000, 0, '2020-08-14'),
	(5, 'steam:11000010aa15521', '24YBM731', '{"modTurbo":false,"pearlescentColor":6,"modTrimA":-1,"modEngineBlock":-1,"color1":36,"wheelColor":0,"modGrille":-1,"modXenon":false,"modVanityPlate":-1,"modStruts":-1,"modHorns":-1,"modRightFender":-1,"modTrimB":-1,"neonEnabled":[false,false,false,false],"modSeats":-1,"fuelLevel":74.0,"modFrontWheels":-1,"modShifterLeavers":-1,"modDial":-1,"modAPlate":-1,"plateIndex":4,"modEngine":-1,"modSuspension":-1,"tyres":[false,false,false,false,false,false,false],"modDashboard":-1,"modWindows":-1,"modRearBumper":-1,"doors":[false,false,false,false,false,false],"modPlateHolder":-1,"modTrunk":-1,"modSteeringWheel":-1,"modAerials":-1,"modRoof":-1,"modArmor":-1,"wheels":0,"modHood":-1,"modExhaust":-1,"modArchCover":-1,"windows":[1,1,1,false,false,1,1,1,1,false,1,false,false],"modTransmission":-1,"windowTint":-1,"modFender":-1,"extras":[],"modBackWheels":-1,"bodyHealth":977.53875732422,"modHydrolic":-1,"color2":0,"model":-1752116803,"modFrame":-1,"modBrakes":-1,"modLivery":0,"modSideSkirt":-1,"modSpoilers":-1,"modSpeakers":-1,"modAirFilter":-1,"modOrnaments":-1,"dirtLevel":9.5,"modFrontBumper":-1,"modDoorSpeaker":-1,"neonColor":[255,0,255],"modSmokeEnabled":1,"engineHealth":991.78765869141,"modTank":-1,"tyreSmokeColor":[255,255,255],"plate":"24YBM731"}', 'car', 0, 'Nomal Impound', 0, 'gtr', 0, 'Impound Lot', 992, 985, 0, '98,94,97,97,96,99,94,0', 99, 0, NULL, 990000, 0, '2020-08-30');
/*!40000 ALTER TABLE `owned_vehicles` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
