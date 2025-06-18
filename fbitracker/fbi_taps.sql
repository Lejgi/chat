CREATE TABLE IF NOT EXISTS `fbi_taps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_charid` varchar(50) NOT NULL,
  `agent_id` varchar(50) NOT NULL,
  `tap_type` varchar(50) NOT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `active` int(1) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
