
CREATE TABLE IF NOT EXISTS `banking_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bank` varchar(50) DEFAULT NULL,
  `identifier` varchar(50) NOT NULL,
  `charidentifier` int(11) NOT NULL,
  `reason` longtext DEFAULT NULL,
  `account` int(1) DEFAULT 0,
  `cost` int(11) DEFAULT 0,
  `date` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;