-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server-Version:               10.10.2-MariaDB - mariadb.org binary distribution
-- Server-Betriebssystem:        Win64
-- HeidiSQL Version:             12.10.0.7000
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Exportiere Datenbank-Struktur für aerztezentrum
CREATE DATABASE IF NOT EXISTS `aerztezentrum` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `aerztezentrum`;

-- Exportiere Struktur von Tabelle aerztezentrum.behandlung
CREATE TABLE IF NOT EXISTS `behandlung` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `kassenpflichtig` bit(1) DEFAULT b'0',
  `preis` decimal(16,4) DEFAULT NULL,
  `erstellt_am` datetime DEFAULT current_timestamp(),
  `erstellt_durch` varchar(30) DEFAULT NULL,
  `geaendert_am` datetime DEFAULT current_timestamp(),
  `geaendert_durch` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportiere Daten aus Tabelle aerztezentrum.behandlung: ~0 rows (ungefähr)

-- Exportiere Struktur von View aerztezentrum.dbs_validate_view
-- Erstelle temporäre Tabelle, um View-Abhängigkeiten zuvorzukommen
CREATE TABLE `dbs_validate_view` (
	`id` INT(11) NOT NULL,
	`medikament_id` INT(11) NULL,
	`behandlung_id` INT(11) NULL
) ENGINE=MyISAM;

-- Exportiere Struktur von Tabelle aerztezentrum.geschichte
CREATE TABLE IF NOT EXISTS `geschichte` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kunde_id` int(11) DEFAULT NULL,
  `behandlung_id` int(11) DEFAULT NULL,
  `medikament_id` int(11) DEFAULT NULL,
  `mitarbeiter_id` int(11) DEFAULT NULL,
  `behandlung_menge` decimal(8,2) DEFAULT 0.00,
  `medikament_menge` int(11) DEFAULT 0,
  `abgerechnet_am` datetime DEFAULT '0000-00-00 00:00:00',
  `erstellt_am` datetime DEFAULT current_timestamp(),
  `erstellt_durch` varchar(30) DEFAULT NULL,
  `geaendert_am` datetime DEFAULT current_timestamp(),
  `geaendert_durch` varchar(30) DEFAULT NULL,
  `bemerkung` mediumtext DEFAULT NULL,
  `medikament_abgegeben_am` datetime DEFAULT NULL,
  `behandlung_ausgefuehrt_am` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_geschichte_behandlung` (`behandlung_id`),
  KEY `fk_geschichte_medikament` (`medikament_id`),
  KEY `fk_geschichte_mitarbeiter` (`mitarbeiter_id`),
  KEY `fk_geschichte_kunde` (`kunde_id`),
  CONSTRAINT `fk_geschichte_behandlung` FOREIGN KEY (`behandlung_id`) REFERENCES `behandlung` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_geschichte_kunde` FOREIGN KEY (`kunde_id`) REFERENCES `kunde` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_geschichte_medikament` FOREIGN KEY (`medikament_id`) REFERENCES `medikament` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_geschichte_mitarbeiter` FOREIGN KEY (`mitarbeiter_id`) REFERENCES `mitarbeiter` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportiere Daten aus Tabelle aerztezentrum.geschichte: ~0 rows (ungefähr)

-- Exportiere Struktur von Tabelle aerztezentrum.jobart
CREATE TABLE IF NOT EXISTS `jobart` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `titel` varchar(100) NOT NULL,
  `erstellt_am` datetime DEFAULT current_timestamp(),
  `erstellt_durch` varchar(30) DEFAULT NULL,
  `geaendert_am` datetime DEFAULT current_timestamp(),
  `geaendert_durch` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportiere Daten aus Tabelle aerztezentrum.jobart: ~0 rows (ungefähr)

-- Exportiere Struktur von Tabelle aerztezentrum.krankenkasse
CREATE TABLE IF NOT EXISTS `krankenkasse` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `adresse` varchar(100) DEFAULT NULL,
  `plz` varchar(10) DEFAULT NULL,
  `ort` varchar(50) DEFAULT NULL,
  `erstellt_am` datetime DEFAULT current_timestamp(),
  `erstellt_durch` varchar(30) DEFAULT NULL,
  `geaendert_am` datetime DEFAULT current_timestamp(),
  `geaendert_durch` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportiere Daten aus Tabelle aerztezentrum.krankenkasse: ~0 rows (ungefähr)

-- Exportiere Struktur von Tabelle aerztezentrum.kunde
CREATE TABLE IF NOT EXISTS `kunde` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `krankenkasse_id` int(11) DEFAULT NULL,
  `vorname` varchar(100) NOT NULL,
  `nachname` varchar(100) NOT NULL,
  `adresse` varchar(100) DEFAULT NULL,
  `plz` varchar(10) NOT NULL,
  `ort` varchar(50) NOT NULL,
  `geburtsdatum` date DEFAULT NULL,
  `krankenkassenkarte` varchar(20) DEFAULT NULL,
  `erstellt_am` datetime DEFAULT current_timestamp(),
  `erstellt_durch` varchar(30) DEFAULT NULL,
  `geaendert_am` datetime DEFAULT current_timestamp(),
  `geaendert_durch` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_kunde_krankenkasse` (`krankenkasse_id`),
  CONSTRAINT `fk_kunde_krankenkasse` FOREIGN KEY (`krankenkasse_id`) REFERENCES `krankenkasse` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportiere Daten aus Tabelle aerztezentrum.kunde: ~0 rows (ungefähr)

-- Exportiere Struktur von Tabelle aerztezentrum.kunde_mitarbeiter
CREATE TABLE IF NOT EXISTS `kunde_mitarbeiter` (
  `kunde_id` int(11) NOT NULL,
  `mitarbeiter_id` int(11) NOT NULL,
  PRIMARY KEY (`kunde_id`,`mitarbeiter_id`),
  KEY `fk_kunde_mitarbeiter_mitarbeiter` (`mitarbeiter_id`),
  CONSTRAINT `fk_kunde_mitarbeiter_kunde` FOREIGN KEY (`kunde_id`) REFERENCES `kunde` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_kunde_mitarbeiter_mitarbeiter` FOREIGN KEY (`mitarbeiter_id`) REFERENCES `mitarbeiter` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportiere Daten aus Tabelle aerztezentrum.kunde_mitarbeiter: ~0 rows (ungefähr)

-- Exportiere Struktur von Tabelle aerztezentrum.medikament
CREATE TABLE IF NOT EXISTS `medikament` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `kassenpflichtig` bit(1) DEFAULT b'0',
  `lagerbestand` int(11) DEFAULT 0,
  `preis` decimal(16,4) DEFAULT NULL,
  `erstellt_am` datetime DEFAULT current_timestamp(),
  `erstellt_durch` varchar(30) DEFAULT NULL,
  `geaendert_am` datetime DEFAULT current_timestamp(),
  `geaendert_durch` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportiere Daten aus Tabelle aerztezentrum.medikament: ~0 rows (ungefähr)

-- Exportiere Struktur von Tabelle aerztezentrum.mitarbeiter
CREATE TABLE IF NOT EXISTS `mitarbeiter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `jobart_id` int(11) NOT NULL,
  `vorname` varchar(100) NOT NULL,
  `nachname` varchar(100) NOT NULL,
  `erstellt_am` datetime DEFAULT current_timestamp(),
  `erstellt_durch` varchar(30) DEFAULT NULL,
  `geaendert_am` datetime DEFAULT current_timestamp(),
  `geaendert_durch` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_mitarbeiter_jobart` (`jobart_id`),
  CONSTRAINT `fk_mitarbeiter_jobart` FOREIGN KEY (`jobart_id`) REFERENCES `jobart` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportiere Daten aus Tabelle aerztezentrum.mitarbeiter: ~0 rows (ungefähr)

-- Exportiere Struktur von Tabelle aerztezentrum.privategeschichte
CREATE TABLE IF NOT EXISTS `privategeschichte` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kunde_id` int(11) DEFAULT NULL,
  `mitarbeiter_id` int(11) DEFAULT NULL,
  `privatebemerkung` mediumtext DEFAULT NULL,
  `erstellt_am` datetime DEFAULT current_timestamp(),
  `erstellt_durch` varchar(30) DEFAULT NULL,
  `geaendert_am` datetime DEFAULT current_timestamp(),
  `geaendert_durch` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_privategeschichte_mitarbeiter` (`mitarbeiter_id`),
  KEY `fk_privategeschichte_kunde` (`kunde_id`),
  CONSTRAINT `fk_privategeschichte_kunde` FOREIGN KEY (`kunde_id`) REFERENCES `kunde` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_privategeschichte_mitarbeiter` FOREIGN KEY (`mitarbeiter_id`) REFERENCES `mitarbeiter` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportiere Daten aus Tabelle aerztezentrum.privategeschichte: ~0 rows (ungefähr)

-- Exportiere Struktur von View aerztezentrum.v_geschichte_sekretariat
-- Erstelle temporäre Tabelle, um View-Abhängigkeiten zuvorzukommen
CREATE TABLE `v_geschichte_sekretariat` (
	`id` INT(11) NOT NULL,
	`kunde_id` INT(11) NULL,
	`medikament_id` INT(11) NULL,
	`behandlung_id` INT(11) NULL,
	`medikament_abgegeben_am` DATETIME NULL,
	`behandlung_ausgefuehrt_am` DATETIME NULL
) ENGINE=MyISAM;

-- Entferne temporäre Tabelle und erstelle die eigentliche View
DROP TABLE IF EXISTS `dbs_validate_view`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `dbs_validate_view` AS SELECT id, medikament_id, behandlung_id from geschichte 
;

-- Entferne temporäre Tabelle und erstelle die eigentliche View
DROP TABLE IF EXISTS `v_geschichte_sekretariat`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_geschichte_sekretariat` AS SELECT id, kunde_id, medikament_id, behandlung_id, medikament_abgegeben_am, behandlung_ausgefuehrt_am from geschichte 
;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
