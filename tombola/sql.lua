CREATE TABLE `lottery_tickets` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(64) NOT NULL,
  `name` VARCHAR(64) NOT NULL,
  `range_start` INT NOT NULL,
  `range_end` INT NOT NULL,
  `total_paid` INT NOT NULL,
  `method` VARCHAR(10) NOT NULL,
  `job` VARCHAR(64) NOT NULL,
  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);