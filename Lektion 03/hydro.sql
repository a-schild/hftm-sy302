-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server-Version:               11.7.2-MariaDB - mariadb.org binary distribution
-- Server-Betriebssystem:        Win64
-- HeidiSQL Version:             12.11.0.7065
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Exportiere Datenbank-Struktur für hydro
CREATE DATABASE IF NOT EXISTS `hydro` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `hydro`;

-- Exportiere Struktur von Tabelle hydro.measures
CREATE TABLE IF NOT EXISTS `measures` (
  `station_id` varchar(50) NOT NULL DEFAULT '',
  `measuretime` datetime NOT NULL,
  `volume_per_sec` float DEFAULT 0,
  `temperature` float DEFAULT 0,
  `niveau` float DEFAULT 0,
  `Spalte 6` int(11) DEFAULT NULL,
  PRIMARY KEY (`station_id`,`measuretime`),
  CONSTRAINT `FK_measures_stations` FOREIGN KEY (`station_id`) REFERENCES `stations` (`station_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Exportiere Daten aus Tabelle hydro.measures: ~3 rows (ungefähr)
INSERT INTO `measures` (`station_id`, `measuretime`, `volume_per_sec`, `temperature`, `niveau`, `Spalte 6`) VALUES
	('CHBE10', '2025-10-21 13:47:40', 45, 6, 456, NULL),
	('CHBS45', '2025-10-21 13:48:50', 4567, 3, 344, NULL),
	('CHVS10', '2025-10-21 13:57:32', 346, 0, 0, NULL);

-- Exportiere Struktur von Tabelle hydro.stations
CREATE TABLE IF NOT EXISTS `stations` (
  `station_id` varchar(50) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `longitude` float DEFAULT 0,
  `latitude` float DEFAULT 0,
  PRIMARY KEY (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Exportiere Daten aus Tabelle hydro.stations: ~4 rows (ungefähr)
INSERT INTO `stations` (`station_id`, `name`, `longitude`, `latitude`) VALUES
	('CHBE10', 'Hagnek', 46.456, 7.455),
	('CHBE11', NULL, 0, 0),
	('CHBS45', 'Baselstadt', 0, 0),
	('CHVS10', 'Sion', 0, 0);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;