-- EletroCast Framework Database Schema
-- Create database tables for comprehensive FiveM framework

-- Users table for player data
CREATE TABLE IF NOT EXISTS `users` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(50) NOT NULL UNIQUE,
    `steam` varchar(50) DEFAULT NULL,
    `license` varchar(50) DEFAULT NULL,
    `discord` varchar(50) DEFAULT NULL,
    `group` varchar(50) DEFAULT 'user',
    `banned` tinyint(1) DEFAULT 0,
    `ban_reason` text DEFAULT NULL,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `last_login` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`),
    KEY `steam` (`steam`),
    KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Characters table for multi-character support
CREATE TABLE IF NOT EXISTS `characters` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `user_id` int(11) NOT NULL,
    `char_id` int(11) NOT NULL,
    `firstname` varchar(50) NOT NULL,
    `lastname` varchar(50) NOT NULL,
    `dob` date NOT NULL,
    `sex` varchar(1) NOT NULL DEFAULT 'M',
    `height` int(11) DEFAULT 175,
    `cash` int(11) DEFAULT 5000,
    `bank` int(11) DEFAULT 25000,
    `dirty_money` int(11) DEFAULT 0,
    `position` text DEFAULT NULL,
    `skin` longtext DEFAULT NULL,
    `job` varchar(50) DEFAULT 'unemployed',
    `job_grade` int(11) DEFAULT 0,
    `phone` varchar(20) DEFAULT NULL,
    `is_dead` tinyint(1) DEFAULT 0,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `user_char` (`user_id`, `char_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Items table for inventory system
CREATE TABLE IF NOT EXISTS `items` (
    `name` varchar(50) NOT NULL,
    `label` varchar(100) NOT NULL,
    `weight` decimal(8,2) DEFAULT 0.00,
    `rare` tinyint(1) DEFAULT 0,
    `can_remove` tinyint(1) DEFAULT 1,
    `description` text DEFAULT NULL,
    `metadata` longtext DEFAULT NULL,
    PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Character inventory
CREATE TABLE IF NOT EXISTS `character_inventory` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `character_id` int(11) NOT NULL,
    `item` varchar(50) NOT NULL,
    `count` int(11) DEFAULT 1,
    `slot` int(11) NOT NULL,
    `metadata` longtext DEFAULT NULL,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `char_slot` (`character_id`, `slot`),
    FOREIGN KEY (`character_id`) REFERENCES `characters`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`item`) REFERENCES `items`(`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Jobs table for employment system
CREATE TABLE IF NOT EXISTS `jobs` (
    `name` varchar(50) NOT NULL,
    `label` varchar(100) NOT NULL,
    `whitelisted` tinyint(1) DEFAULT 0,
    `grades` longtext DEFAULT NULL,
    PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Vehicles table for owned vehicles
CREATE TABLE IF NOT EXISTS `vehicles` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `owner` int(11) NOT NULL,
    `plate` varchar(8) NOT NULL UNIQUE,
    `model` varchar(50) NOT NULL,
    `mods` longtext DEFAULT NULL,
    `garage` varchar(50) DEFAULT 'pillboxgarage',
    `fuel` int(11) DEFAULT 100,
    `engine` decimal(8,2) DEFAULT 1000.00,
    `body` decimal(8,2) DEFAULT 1000.00,
    `state` tinyint(1) DEFAULT 1,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `plate` (`plate`),
    FOREIGN KEY (`owner`) REFERENCES `characters`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Business table for economy system
CREATE TABLE IF NOT EXISTS `businesses` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(100) NOT NULL,
    `owner` int(11) DEFAULT NULL,
    `employees` longtext DEFAULT NULL,
    `balance` int(11) DEFAULT 0,
    `type` varchar(50) NOT NULL,
    `data` longtext DEFAULT NULL,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`owner`) REFERENCES `characters`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Transaction logs for economy tracking
CREATE TABLE IF NOT EXISTS `transactions` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `character_id` int(11) NOT NULL,
    `type` enum('cash','bank','dirty_money') NOT NULL,
    `amount` int(11) NOT NULL,
    `reason` varchar(255) NOT NULL,
    `balance_before` int(11) NOT NULL,
    `balance_after` int(11) NOT NULL,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`character_id`) REFERENCES `characters`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stash table for storage systems
CREATE TABLE IF NOT EXISTS `stashes` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `stash` varchar(100) NOT NULL,
    `items` longtext DEFAULT NULL,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `stash` (`stash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default items
INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`, `description`) VALUES
('phone', 'Phone', 0.25, 0, 0, 'A basic smartphone'),
('id_card', 'ID Card', 0.01, 0, 0, 'Personal identification card'),
('driver_license', 'Driver License', 0.01, 0, 0, 'Official driving license'),
('cash', 'Cash', 0.00, 0, 0, 'Physical money'),
('burger', 'Burger', 0.35, 0, 1, 'A delicious burger'),
('water', 'Water', 0.25, 0, 1, 'Fresh water bottle'),
('bandage', 'Bandage', 0.15, 0, 1, 'Medical bandage for healing'),
('lockpick', 'Lockpick', 0.05, 0, 1, 'Tool for picking locks'),
('repairkit', 'Repair Kit', 2.50, 0, 1, 'Vehicle repair kit'),
('advancedrepairkit', 'Advanced Repair Kit', 4.00, 0, 1, 'Professional vehicle repair kit');

-- Insert default jobs
INSERT IGNORE INTO `jobs` (`name`, `label`, `whitelisted`, `grades`) VALUES
('unemployed', 'Unemployed', 0, '{"0":{"name":"Unemployed","payment":200}}'),
('police', 'Los Santos Police Department', 1, '{"0":{"name":"Cadet","payment":750},"1":{"name":"Officer","payment":1000},"2":{"name":"Sergeant","payment":1250},"3":{"name":"Lieutenant","payment":1500},"4":{"name":"Captain","payment":1750},"5":{"name":"Chief","payment":2000}}'),
('ambulance', 'Los Santos Medical Department', 1, '{"0":{"name":"Trainee","payment":750},"1":{"name":"Paramedic","payment":1000},"2":{"name":"Doctor","payment":1250},"3":{"name":"Surgeon","payment":1500},"4":{"name":"Chief","payment":1750}}'),
('mechanic', 'Mechanic', 0, '{"0":{"name":"Trainee","payment":500},"1":{"name":"Mechanic","payment":750},"2":{"name":"Lead Mechanic","payment":1000},"3":{"name":"Manager","payment":1250}}'),
('taxi', 'Taxi Driver', 0, '{"0":{"name":"Driver","payment":300},"1":{"name":"Experienced Driver","payment":450}}'),
('trucker', 'Trucker', 0, '{"0":{"name":"Driver","payment":400},"1":{"name":"Experienced Driver","payment":600},"2":{"name":"Lead Driver","payment":800}}');