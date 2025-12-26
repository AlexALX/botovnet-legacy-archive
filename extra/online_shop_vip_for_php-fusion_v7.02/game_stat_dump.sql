/*
	This is MYSQL dump for game stat tables for RUST/GMOD
*/

DROP TABLE IF EXISTS `fusion_game_stat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fusion_game_stat` (
  `sid` varchar(20) NOT NULL,
  `server` int(2) NOT NULL,
  `time` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `last` int(11) NOT NULL,
  UNIQUE KEY `sid` (`sid`,`server`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `fusion_game_stat_gmod`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fusion_game_stat_gmod` (
  `sid` varchar(20) NOT NULL,
  `server` int(2) NOT NULL,
  `time` int(11) NOT NULL,
  `frags` varchar(30) NOT NULL,
  `death` varchar(30) NOT NULL,
  `played` int(10) NOT NULL,
  `last` int(11) NOT NULL,
  UNIQUE KEY `sid` (`sid`,`server`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `fusion_game_stat_rust`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fusion_game_stat_rust` (
  `sid` varchar(20) NOT NULL,
  `server` int(2) NOT NULL,
  `time` int(11) NOT NULL,
  `death` varchar(30) NOT NULL,
  `played` int(10) NOT NULL,
  `last` int(11) NOT NULL,
  UNIQUE KEY `sid` (`sid`,`server`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `fusion_game_stat_rust_ext`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fusion_game_stat_rust_ext` (
  `sid` varchar(20) NOT NULL,
  `server` int(2) NOT NULL,
  `animal` int(1) NOT NULL,
  `name` varchar(100) NOT NULL,
  `count` varchar(30) NOT NULL,
  UNIQUE KEY `sid` (`sid`,`server`,`animal`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;