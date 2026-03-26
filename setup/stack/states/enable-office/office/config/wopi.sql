/*M!999999\- enable the sandbox mode */
-- MariaDB dump 10.19  Distrib 10.11.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: ilias
-- ------------------------------------------------------
-- Server version	10.11.14-MariaDB-0+deb12u2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `wopi_app`
--

DROP TABLE IF EXISTS `wopi_app`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wopi_app` (
  `id` int(11) NOT NULL,
  `name` varchar(256) NOT NULL,
  `favicon` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wopi_app`
--

LOCK TABLES `wopi_app` WRITE;
/*!40000 ALTER TABLE `wopi_app` DISABLE KEYS */;
INSERT INTO `wopi_app` VALUES
(58,'Word','http://172.24.0.251/web-apps/apps/documenteditor/main/resources/img/favicon.ico'),
(59,'Excel','http://172.24.0.251/web-apps/apps/spreadsheeteditor/main/resources/img/favicon.ico'),
(60,'PowerPoint','http://172.24.0.251/web-apps/apps/presentationeditor/main/resources/img/favicon.ico'),
(61,'Pdf','http://172.24.0.251/web-apps/apps/pdfeditor/main/resources/img/favicon.ico'),
(62,'application/msword',NULL),
(63,'application/vnd.google-apps.document',NULL),
(64,'text/html',NULL),
(65,'text/markdown',NULL),
(66,'application/vnd.apple.pages',NULL),
(67,'application/x-iwork-pages-sffpages',NULL),
(68,'application/vnd.sun.xml.writer.template',NULL),
(69,'application/vnd.sun.xml.writer',NULL),
(70,'application/vnd.ms-works',NULL),
(71,'application/xml',NULL),
(72,'text/xml',NULL),
(73,'application/vnd.ms-word.document.macroenabled.12',NULL),
(74,'application/vnd.openxmlformats-officedocument.wordprocessingml.document',NULL),
(75,'application/vnd.ms-word.template.macroenabled.12',NULL),
(76,'application/vnd.openxmlformats-officedocument.wordprocessingml.template',NULL),
(77,'application/epub+zip',NULL),
(78,'application/vnd.oasis.opendocument.text',NULL),
(79,'application/vnd.oasis.opendocument.text-template',NULL),
(80,'application/rtf',NULL),
(81,'text/rtf',NULL),
(82,'text/plain',NULL),
(83,'application/vnd.google-apps.spreadsheet',NULL),
(84,'application/vnd.apple.numbers',NULL),
(85,'application/x-iwork-numbers-sffnumbers',NULL),
(86,'application/vnd.sun.xml.calc',NULL),
(87,'application/vnd.ms-excel',NULL),
(88,'text/csv',NULL),
(89,'application/vnd.oasis.opendocument.spreadsheet',NULL),
(90,'application/vnd.oasis.opendocument.spreadsheet-template',NULL),
(91,'text/tab-separated-values',NULL),
(92,'application/vnd.ms-excel.sheet.binary.macroenabled.12',NULL),
(93,'application/vnd.ms-excel.sheet.macroenabled.12',NULL),
(94,'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',NULL),
(95,'application/vnd.ms-excel.template.macroenabled.12',NULL),
(96,'application/vnd.openxmlformats-officedocument.spreadsheetml.template',NULL),
(97,'application/vnd.google-apps.presentation',NULL),
(98,'application/vnd.apple.keynote',NULL),
(99,'application/x-iwork-keynote-sffkey',NULL),
(100,'application/vnd.oasis.opendocument.graphics',NULL),
(101,'application/vnd.ms-powerpoint',NULL),
(102,'application/vnd.sun.xml.impress',NULL),
(103,'application/vnd.oasis.opendocument.presentation',NULL),
(104,'application/vnd.oasis.opendocument.presentation-template',NULL),
(105,'application/vnd.ms-powerpoint.template.macroenabled.12',NULL),
(106,'application/vnd.openxmlformats-officedocument.presentationml.template',NULL),
(107,'application/vnd.ms-powerpoint.slideshow.macroenabled.12',NULL),
(108,'application/vnd.openxmlformats-officedocument.presentationml.slideshow',NULL),
(109,'application/vnd.ms-powerpoint.presentation.macroenabled.12',NULL),
(110,'application/vnd.openxmlformats-officedocument.presentationml.presentation',NULL),
(111,'image/vnd.djvu',NULL),
(112,'application/oxps',NULL),
(113,'application/vnd.ms-xpsdocument',NULL),
(114,'application/pdf',NULL);
/*!40000 ALTER TABLE `wopi_app` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

--
-- Table structure for table `wopi_action`
--

DROP TABLE IF EXISTS `wopi_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wopi_action` (
  `id` int(11) NOT NULL,
  `app_id` int(11) NOT NULL,
  `name` varchar(256) NOT NULL,
  `ext` varchar(256) NOT NULL,
  `urlsrc` varchar(2048) NOT NULL,
  `url_appendix` varchar(4000) DEFAULT NULL,
  `target_ext` varchar(256) DEFAULT NULL,
  `target_text` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `i1_idx` (`app_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wopi_action`
--

LOCK TABLES `wopi_action` WRITE;
/*!40000 ALTER TABLE `wopi_action` DISABLE KEYS */;
INSERT INTO `wopi_action` VALUES
(405,58,'view','doc','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(406,58,'embedview','doc','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(407,58,'convert','doc','http://172.24.0.251/hosting/wopi/convert-and-edit/doc/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(408,58,'view','dot','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(409,58,'embedview','dot','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(410,58,'convert','dot','http://172.24.0.251/hosting/wopi/convert-and-edit/dot/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(411,58,'view','fodt','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(412,58,'embedview','fodt','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(413,58,'convert','fodt','http://172.24.0.251/hosting/wopi/convert-and-edit/fodt/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(414,58,'view','gdoc','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(415,58,'embedview','gdoc','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(416,58,'convert','gdoc','http://172.24.0.251/hosting/wopi/convert-and-edit/gdoc/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(417,58,'view','hml','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(418,58,'embedview','hml','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(419,58,'convert','hml','http://172.24.0.251/hosting/wopi/convert-and-edit/hml/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(420,58,'view','htm','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(421,58,'embedview','htm','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(422,58,'convert','htm','http://172.24.0.251/hosting/wopi/convert-and-edit/htm/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(423,58,'view','hwp','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(424,58,'embedview','hwp','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(425,58,'convert','hwp','http://172.24.0.251/hosting/wopi/convert-and-edit/hwp/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(426,58,'view','hwpx','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(427,58,'embedview','hwpx','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(428,58,'convert','hwpx','http://172.24.0.251/hosting/wopi/convert-and-edit/hwpx/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(429,58,'view','md','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(430,58,'embedview','md','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(431,58,'convert','md','http://172.24.0.251/hosting/wopi/convert-and-edit/md/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(432,58,'view','mht','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(433,58,'embedview','mht','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(434,58,'convert','mht','http://172.24.0.251/hosting/wopi/convert-and-edit/mht/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(435,58,'view','mhtml','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(436,58,'embedview','mhtml','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(437,58,'convert','mhtml','http://172.24.0.251/hosting/wopi/convert-and-edit/mhtml/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(438,58,'view','pages','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(439,58,'embedview','pages','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(440,58,'convert','pages','http://172.24.0.251/hosting/wopi/convert-and-edit/pages/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(441,58,'view','stw','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(442,58,'embedview','stw','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(443,58,'convert','stw','http://172.24.0.251/hosting/wopi/convert-and-edit/stw/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(444,58,'view','sxw','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(445,58,'embedview','sxw','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(446,58,'convert','sxw','http://172.24.0.251/hosting/wopi/convert-and-edit/sxw/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(447,58,'view','wps','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(448,58,'embedview','wps','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(449,58,'convert','wps','http://172.24.0.251/hosting/wopi/convert-and-edit/wps/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(450,58,'view','wpt','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(451,58,'embedview','wpt','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(452,58,'convert','wpt','http://172.24.0.251/hosting/wopi/convert-and-edit/wpt/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(453,58,'view','xml','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(454,58,'embedview','xml','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(455,58,'convert','xml','http://172.24.0.251/hosting/wopi/convert-and-edit/xml/docx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','docx',NULL),
(456,58,'view','docm','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(457,58,'embedview','docm','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(458,58,'edit','docm','http://172.24.0.251/hosting/wopi/word/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(459,58,'view','docx','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(460,58,'embedview','docx','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(461,58,'edit','docx','http://172.24.0.251/hosting/wopi/word/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(462,58,'view','dotm','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(463,58,'embedview','dotm','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(464,58,'edit','dotm','http://172.24.0.251/hosting/wopi/word/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(465,58,'view','dotx','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(466,58,'embedview','dotx','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(467,58,'edit','dotx','http://172.24.0.251/hosting/wopi/word/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(468,58,'view','epub','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(469,58,'embedview','epub','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(470,58,'edit','epub','http://172.24.0.251/hosting/wopi/word/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(471,58,'view','fb2','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(472,58,'embedview','fb2','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(473,58,'edit','fb2','http://172.24.0.251/hosting/wopi/word/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(474,58,'view','html','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(475,58,'embedview','html','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(476,58,'edit','html','http://172.24.0.251/hosting/wopi/word/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(477,58,'view','odt','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(478,58,'embedview','odt','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(479,58,'edit','odt','http://172.24.0.251/hosting/wopi/word/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(480,58,'view','ott','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(481,58,'embedview','ott','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(482,58,'edit','ott','http://172.24.0.251/hosting/wopi/word/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(483,58,'view','rtf','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(484,58,'embedview','rtf','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(485,58,'edit','rtf','http://172.24.0.251/hosting/wopi/word/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(486,58,'view','txt','http://172.24.0.251/hosting/wopi/word/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(487,58,'embedview','txt','http://172.24.0.251/hosting/wopi/word/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(488,58,'edit','txt','http://172.24.0.251/hosting/wopi/word/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(489,59,'view','et','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(490,59,'embedview','et','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(491,59,'convert','et','http://172.24.0.251/hosting/wopi/convert-and-edit/et/xlsx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','xlsx',NULL),
(492,59,'view','ett','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(493,59,'embedview','ett','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(494,59,'convert','ett','http://172.24.0.251/hosting/wopi/convert-and-edit/ett/xlsx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','xlsx',NULL),
(495,59,'view','fods','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(496,59,'embedview','fods','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(497,59,'convert','fods','http://172.24.0.251/hosting/wopi/convert-and-edit/fods/xlsx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','xlsx',NULL),
(498,59,'view','gsheet','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(499,59,'embedview','gsheet','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(500,59,'convert','gsheet','http://172.24.0.251/hosting/wopi/convert-and-edit/gsheet/xlsx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','xlsx',NULL),
(501,59,'view','numbers','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(502,59,'embedview','numbers','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(503,59,'convert','numbers','http://172.24.0.251/hosting/wopi/convert-and-edit/numbers/xlsx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','xlsx',NULL),
(504,59,'view','sxc','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(505,59,'embedview','sxc','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(506,59,'convert','sxc','http://172.24.0.251/hosting/wopi/convert-and-edit/sxc/xlsx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','xlsx',NULL),
(507,59,'view','xls','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(508,59,'embedview','xls','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(509,59,'convert','xls','http://172.24.0.251/hosting/wopi/convert-and-edit/xls/xlsx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','xlsx',NULL),
(510,59,'view','xlt','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(511,59,'embedview','xlt','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(512,59,'convert','xlt','http://172.24.0.251/hosting/wopi/convert-and-edit/xlt/xlsx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','xlsx',NULL),
(513,59,'view','csv','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(514,59,'embedview','csv','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(515,59,'edit','csv','http://172.24.0.251/hosting/wopi/cell/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(516,59,'view','ods','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(517,59,'embedview','ods','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(518,59,'edit','ods','http://172.24.0.251/hosting/wopi/cell/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(519,59,'view','ots','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(520,59,'embedview','ots','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(521,59,'edit','ots','http://172.24.0.251/hosting/wopi/cell/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(522,59,'view','tsv','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(523,59,'embedview','tsv','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(524,59,'edit','tsv','http://172.24.0.251/hosting/wopi/cell/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(525,59,'view','xlsb','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(526,59,'embedview','xlsb','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(527,59,'edit','xlsb','http://172.24.0.251/hosting/wopi/cell/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(528,59,'view','xlsm','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(529,59,'embedview','xlsm','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(530,59,'edit','xlsm','http://172.24.0.251/hosting/wopi/cell/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(531,59,'view','xlsx','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(532,59,'embedview','xlsx','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(533,59,'edit','xlsx','http://172.24.0.251/hosting/wopi/cell/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(534,59,'view','xltm','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(535,59,'embedview','xltm','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(536,59,'edit','xltm','http://172.24.0.251/hosting/wopi/cell/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(537,59,'view','xltx','http://172.24.0.251/hosting/wopi/cell/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(538,59,'embedview','xltx','http://172.24.0.251/hosting/wopi/cell/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(539,59,'edit','xltx','http://172.24.0.251/hosting/wopi/cell/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(540,60,'view','dps','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(541,60,'embedview','dps','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(542,60,'convert','dps','http://172.24.0.251/hosting/wopi/convert-and-edit/dps/pptx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','pptx',NULL),
(543,60,'view','dpt','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(544,60,'embedview','dpt','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(545,60,'convert','dpt','http://172.24.0.251/hosting/wopi/convert-and-edit/dpt/pptx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','pptx',NULL),
(546,60,'view','fodp','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(547,60,'embedview','fodp','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(548,60,'convert','fodp','http://172.24.0.251/hosting/wopi/convert-and-edit/fodp/pptx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','pptx',NULL),
(549,60,'view','gslides','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(550,60,'embedview','gslides','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(551,60,'convert','gslides','http://172.24.0.251/hosting/wopi/convert-and-edit/gslides/pptx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','pptx',NULL),
(552,60,'view','key','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(553,60,'embedview','key','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(554,60,'convert','key','http://172.24.0.251/hosting/wopi/convert-and-edit/key/pptx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','pptx',NULL),
(555,60,'view','odg','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(556,60,'embedview','odg','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(557,60,'convert','odg','http://172.24.0.251/hosting/wopi/convert-and-edit/odg/pptx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','pptx',NULL),
(558,60,'view','pot','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(559,60,'embedview','pot','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(560,60,'convert','pot','http://172.24.0.251/hosting/wopi/convert-and-edit/pot/pptx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','pptx',NULL),
(561,60,'view','pps','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(562,60,'embedview','pps','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(563,60,'convert','pps','http://172.24.0.251/hosting/wopi/convert-and-edit/pps/pptx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','pptx',NULL),
(564,60,'view','ppt','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(565,60,'embedview','ppt','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(566,60,'convert','ppt','http://172.24.0.251/hosting/wopi/convert-and-edit/ppt/pptx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','pptx',NULL),
(567,60,'view','sxi','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(568,60,'embedview','sxi','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(569,60,'convert','sxi','http://172.24.0.251/hosting/wopi/convert-and-edit/sxi/pptx','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&','pptx',NULL),
(570,60,'view','odp','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(571,60,'embedview','odp','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(572,60,'edit','odp','http://172.24.0.251/hosting/wopi/slide/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(573,60,'view','otp','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(574,60,'embedview','otp','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(575,60,'edit','otp','http://172.24.0.251/hosting/wopi/slide/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(576,60,'view','potm','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(577,60,'embedview','potm','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(578,60,'edit','potm','http://172.24.0.251/hosting/wopi/slide/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(579,60,'view','potx','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(580,60,'embedview','potx','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(581,60,'edit','potx','http://172.24.0.251/hosting/wopi/slide/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(582,60,'view','ppsm','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(583,60,'embedview','ppsm','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(584,60,'edit','ppsm','http://172.24.0.251/hosting/wopi/slide/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(585,60,'view','ppsx','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(586,60,'embedview','ppsx','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(587,60,'edit','ppsx','http://172.24.0.251/hosting/wopi/slide/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(588,60,'view','pptm','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(589,60,'embedview','pptm','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(590,60,'edit','pptm','http://172.24.0.251/hosting/wopi/slide/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(591,60,'view','pptx','http://172.24.0.251/hosting/wopi/slide/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(592,60,'embedview','pptx','http://172.24.0.251/hosting/wopi/slide/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(593,60,'edit','pptx','http://172.24.0.251/hosting/wopi/slide/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(594,61,'view','djvu','http://172.24.0.251/hosting/wopi/pdf/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(595,61,'embedview','djvu','http://172.24.0.251/hosting/wopi/pdf/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(596,61,'view','docxf','http://172.24.0.251/hosting/wopi/pdf/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(597,61,'embedview','docxf','http://172.24.0.251/hosting/wopi/pdf/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(598,61,'view','oform','http://172.24.0.251/hosting/wopi/pdf/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(599,61,'embedview','oform','http://172.24.0.251/hosting/wopi/pdf/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(600,61,'view','oxps','http://172.24.0.251/hosting/wopi/pdf/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(601,61,'embedview','oxps','http://172.24.0.251/hosting/wopi/pdf/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(602,61,'view','xps','http://172.24.0.251/hosting/wopi/pdf/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(603,61,'embedview','xps','http://172.24.0.251/hosting/wopi/pdf/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(604,61,'view','pdf','http://172.24.0.251/hosting/wopi/pdf/view','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(605,61,'embedview','pdf','http://172.24.0.251/hosting/wopi/pdf/view','embed=1&<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL),
(606,61,'edit','pdf','http://172.24.0.251/hosting/wopi/pdf/edit','<rs=DC_LLCC&><dchat=DISABLE_CHAT&><embed=EMBEDDED&><fs=FULLSCREEN&><hid=HOST_SESSION_ID&><rec=RECORDING&><sc=SESSION_CONTEXT&><thm=THEME_ID&><ui=UI_LLCC&><wopisrc=WOPI_SOURCE&>&',NULL,NULL);
/*!40000 ALTER TABLE `wopi_action` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-27 11:51:36