-- MySQL dump 10.13  Distrib 5.6.12, for osx10.7 (x86_64)
--
-- Host: localhost    Database: membership_development
-- ------------------------------------------------------
-- Server version	5.6.12

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activites`
--

DROP TABLE IF EXISTS `activites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL DEFAULT '',
  `description_fr` varchar(255) NOT NULL DEFAULT '',
  `description_en` varchar(255) NOT NULL DEFAULT '',
  `url_fr` varchar(255) DEFAULT NULL,
  `url_en` varchar(255) DEFAULT NULL,
  `gratuite` tinyint(1) DEFAULT NULL,
  `cout` decimal(8,2) DEFAULT '0.00',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `par_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `activites_membres`
--

DROP TABLE IF EXISTS `activites_membres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activites_membres` (
  `activite_id` int(11) DEFAULT NULL,
  `membre_id` int(11) DEFAULT NULL,
  KEY `par_membre` (`membre_id`),
  KEY `par_activite` (`activite_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `constantes`
--

DROP TABLE IF EXISTS `constantes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `constantes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `baseSenior` decimal(8,2) DEFAULT '0.00',
  `baseIndividu` decimal(8,2) DEFAULT '0.00',
  `baseFamille` decimal(8,2) DEFAULT '0.00',
  `activiteSenior` decimal(8,2) DEFAULT '0.00',
  `activiteIndividu` decimal(8,2) DEFAULT '0.00',
  `activiteFamille` decimal(8,2) DEFAULT '0.00',
  `rabaisPreInscriptionSenior` decimal(8,2) DEFAULT '0.00',
  `rabaisPreInscriptionIndividu` decimal(8,2) DEFAULT '0.00',
  `rabaisPreInscriptionFamille` decimal(8,2) DEFAULT '0.00',
  `finPreInscription` date DEFAULT NULL,
  `codeLeconNatation` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `cout_billet` decimal(8,2) DEFAULT '0.00',
  `age_min_individu` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cotisations`
--

DROP TABLE IF EXISTS `cotisations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cotisations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `famille_id` int(11) DEFAULT NULL,
  `cotisation_calculee` decimal(8,2) DEFAULT '0.00',
  `cotisation_exemption` decimal(8,2) DEFAULT '0.00',
  `non_taxable` decimal(8,2) DEFAULT '0.00',
  `familiale` tinyint(1) DEFAULT NULL,
  `frais1` decimal(8,2) DEFAULT '0.00',
  `frais1_explication` varchar(255) DEFAULT '',
  `frais2` decimal(8,2) DEFAULT '0.00',
  `frais2_explication` varchar(255) DEFAULT '',
  `frais3` decimal(8,2) DEFAULT '0.00',
  `frais3_explication` varchar(255) DEFAULT '',
  `frais4` decimal(8,2) DEFAULT '0.00',
  `frais4_explication` varchar(255) DEFAULT '',
  `frais5` decimal(8,2) DEFAULT '0.00',
  `frais5_explication` varchar(255) DEFAULT '',
  `frais6` decimal(8,2) DEFAULT '0.00',
  `frais6_explication` varchar(255) DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `rabais_preinscription` decimal(8,2) DEFAULT '0.00',
  `nombre_billets` int(11) DEFAULT '0',
  `cout_billets` decimal(8,2) DEFAULT '0.00',
  `frais_supplementaires` decimal(8,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `par_famille` (`famille_id`)
) ENGINE=InnoDB AUTO_INCREMENT=711 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `familles`
--

DROP TABLE IF EXISTS `familles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `familles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `adresse1` varchar(255) DEFAULT NULL,
  `adresse2` varchar(255) DEFAULT NULL,
  `ville` varchar(255) DEFAULT NULL,
  `province` varchar(2) DEFAULT NULL,
  `code_postal` varchar(6) DEFAULT NULL,
  `tel_soir` varchar(20) DEFAULT NULL,
  `tel_jour` varchar(20) DEFAULT NULL,
  `courriel1` varchar(255) DEFAULT NULL,
  `courriel2` varchar(255) DEFAULT NULL,
  `langue` varchar(255) DEFAULT NULL,
  `etat` varchar(255) DEFAULT NULL,
  `code_acces` varchar(255) DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `par_code_acces` (`code_acces`)
) ENGINE=InnoDB AUTO_INCREMENT=617 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `membres`
--

DROP TABLE IF EXISTS `membres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `membres` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `famille_id` int(11) DEFAULT NULL,
  `nom` varchar(255) NOT NULL DEFAULT '',
  `prenom` varchar(255) NOT NULL DEFAULT '',
  `naissance` date NOT NULL,
  `ecusson` varchar(255) NOT NULL DEFAULT '',
  `cours_de_natation` varchar(255) DEFAULT '',
  `session_de_natation` varchar(255) DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `par_famille` (`famille_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2189 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notes`
--

DROP TABLE IF EXISTS `notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `famille_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `auteur` varchar(255) DEFAULT NULL,
  `info` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `par_famille` (`famille_id`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `paiements`
--

DROP TABLE IF EXISTS `paiements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paiements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `famille_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `montant` decimal(8,2) DEFAULT '0.00',
  `non_taxable` decimal(8,2) DEFAULT '0.00',
  `taxable` decimal(8,2) DEFAULT '0.00',
  `tps` decimal(8,2) DEFAULT '0.00',
  `tvq` decimal(8,2) DEFAULT '0.00',
  `note` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `par` varchar(255) DEFAULT '',
  `no_cheque` int(11) DEFAULT '0',
  `comptant` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `par_famille` (`famille_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `participations`
--

DROP TABLE IF EXISTS `participations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `participations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description_fr` varchar(255) NOT NULL,
  `description_en` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `participations_membres`
--

DROP TABLE IF EXISTS `participations_membres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `participations_membres` (
  `participation_id` int(11) DEFAULT NULL,
  `membre_id` int(11) DEFAULT NULL,
  KEY `par_membre` (`membre_id`),
  KEY `par_participation` (`participation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `recus`
--

DROP TABLE IF EXISTS `recus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `famille_id` int(11) DEFAULT NULL,
  `annee` int(11) DEFAULT NULL,
  `info` varchar(255) DEFAULT NULL,
  `prenom` varchar(255) DEFAULT NULL,
  `nom` varchar(255) DEFAULT NULL,
  `naissance` date NOT NULL,
  `montant` decimal(8,2) DEFAULT '0.00',
  `montant_recu` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `par_famille_annee` (`famille_id`,`annee`)
) ENGINE=InnoDB AUTO_INCREMENT=3009 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `roles` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `courriel` varchar(255) DEFAULT NULL,
  `nom` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-06-01 22:53:32
INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20110707024451');

INSERT INTO schema_migrations (version) VALUES ('20120529013417');

INSERT INTO schema_migrations (version) VALUES ('20150602024858');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');

