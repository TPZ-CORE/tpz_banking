
CREATE TABLE IF NOT EXISTS `banking` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `identifier` varchar(50) NOT NULL,
  `charidentifier` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `money` int(11) DEFAULT 0,
  `gold` int(11) DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
