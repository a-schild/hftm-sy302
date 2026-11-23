-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server-Version:               10.5.5-MariaDB - mariadb.org binary distribution
-- Server-Betriebssystem:        Win64
-- HeidiSQL Version:             12.7.0.6850
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Exportiere Datenbank-Struktur für carrental
DROP DATABASE IF EXISTS `carrental`;
CREATE DATABASE IF NOT EXISTS `carrental` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `carrental`;

-- Exportiere Struktur von Tabelle carrental.car
DROP TABLE IF EXISTS `car`;
CREATE TABLE IF NOT EXISTS `car` (
  `car_id` int(11) NOT NULL,
  `serialnumber` varchar(20) NOT NULL,
  `numberofseats` int(11) DEFAULT NULL,
  `brand` varchar(20) DEFAULT NULL,
  `color` varchar(20) DEFAULT NULL,
  `licenseplate` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`car_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Exportiere Daten aus Tabelle carrental.car: ~7 rows (ungefähr)
INSERT INTO `car` (`car_id`, `serialnumber`, `numberofseats`, `brand`, `color`, `licenseplate`) VALUES
	(1, 'SN123456', 5, 'Toyota', 'Red', 'BE-12312'),
	(2, 'SN789012', 4, 'Honda', 'Blue', 'BS-8453'),
	(3, 'SN345678', 7, 'Ford', 'Black', 'AI-8237'),
	(4, 'SN901234', 2, 'BMW', 'Silver', 'ZH-23334'),
	(5, 'SN567890', 5, 'Volkswagen', 'White', 'GE-4445'),
	(6, 'SN901235', 2, 'BMW', 'Silver', 'FR-9877'),
	(7, 'SN901236', 2, 'BMW', 'Silver', 'VS-76984');

-- Exportiere Struktur von Tabelle carrental.carrental
DROP TABLE IF EXISTS `carrental`;
CREATE TABLE IF NOT EXISTS `carrental` (
  `customer_id` int(11) NOT NULL,
  `car_id` int(11) NOT NULL,
  `startrental` date NOT NULL,
  `endrental` date DEFAULT NULL,
  `startkmcounter` int(11) DEFAULT NULL,
  `endkmcounter` int(11) DEFAULT NULL,
  `remarks` varchar(4096) DEFAULT NULL,
  PRIMARY KEY (`customer_id`,`car_id`,`startrental`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Exportiere Daten aus Tabelle carrental.carrental: ~7 rows (ungefähr)
INSERT INTO `carrental` (`customer_id`, `car_id`, `startrental`, `endrental`, `startkmcounter`, `endkmcounter`, `remarks`) VALUES
	(101, 1, '2024-05-01', '2024-05-10', 10000, 10500, NULL),
	(102, 3, '2024-03-24', '2024-03-26', 7600, 7800, NULL),
	(102, 3, '2024-04-01', '2024-04-08', 7800, 8000, 'Needs cleaning'),
	(102, 3, '2024-05-03', '2024-05-08', 8000, 8200, 'Needs cleaning'),
	(103, 2, '2024-05-05', NULL, 6000, NULL, NULL),
	(104, 4, '2024-05-07', NULL, 20000, NULL, NULL),
	(105, 5, '2024-05-10', '2024-05-15', 15000, 15200, NULL);

-- Exportiere Struktur von Tabelle carrental.carservice
DROP TABLE IF EXISTS `carservice`;
CREATE TABLE IF NOT EXISTS `carservice` (
  `carservice_id` int(11) NOT NULL,
  `car_id` int(11) NOT NULL,
  `servicestart` date NOT NULL,
  `serviceend` date DEFAULT NULL,
  `servicecosts` decimal(8,2) DEFAULT NULL,
  `warrantyservice` tinyint(1) DEFAULT NULL,
  `servicereason` varchar(4096) DEFAULT NULL,
  PRIMARY KEY (`carservice_id`,`car_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Exportiere Daten aus Tabelle carrental.carservice: ~4 rows (ungefähr)
INSERT INTO `carservice` (`carservice_id`, `car_id`, `servicestart`, `serviceend`, `servicecosts`, `warrantyservice`, `servicereason`) VALUES
	(201, 1, '2024-04-01', '2024-04-05', 200.00, 0, 'Regular maintenance'),
	(202, 3, '2024-01-02', '2024-01-15', NULL, 1, 'Warranty repair'),
	(203, 2, '2024-03-15', '2024-03-20', 300.00, 0, 'Brake replacement'),
	(204, 5, '2024-05-12', NULL, NULL, 0, 'Tire rotation');

-- Exportiere Struktur von Tabelle carrental.customer
DROP TABLE IF EXISTS `customer`;
CREATE TABLE IF NOT EXISTS `customer` (
  `customer_id` int(11) NOT NULL,
  `firstname` varchar(30) NOT NULL,
  `lastname` varchar(30) NOT NULL,
  `address` varchar(30) DEFAULT NULL,
  `mobilephone` varchar(10) NOT NULL,
  `zip` varchar(10) NOT NULL,
  `city` varchar(30) NOT NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Exportiere Daten aus Tabelle carrental.customer: ~5 rows (ungefähr)
INSERT INTO `customer` (`customer_id`, `firstname`, `lastname`, `address`, `mobilephone`, `zip`, `city`) VALUES
	(101, 'John', 'Doe', '123 Main St', '555-1234', '12345', 'Springfield'),
	(102, 'Jane', 'Smith', '456 Elm St', '555-5678', '67890', 'Maplewood'),
	(103, 'Michael', 'Johnson', '789 Oak St', '555-9012', '34567', 'Rivertown'),
	(104, 'Sarah', 'Lee', '101 Pine St', '555-3456', '89012', 'Hillcrest'),
	(105, 'Emily', 'Brown', '234 Cedar St', '555-7890', '45678', 'Lakeside');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
