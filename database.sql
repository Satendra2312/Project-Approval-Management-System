-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 27, 2025 at 06:48 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `task_laravel`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_project_status` (IN `project_id` INT, IN `admin_user_id` INT, IN `new_status` ENUM('approved','rejected','pending'), IN `rejection_reason` TEXT)   BEGIN
    DECLARE current_status VARCHAR(20);

    -- Start transaction
    START TRANSACTION;

    -- Fetch current status
    SELECT status INTO current_status FROM projects WHERE id = project_id;

    -- Validate project existence
    IF current_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Project not found';
        ROLLBACK;
    ELSE
        -- Prevent unnecessary updates
        IF current_status = new_status THEN
            SELECT 'success' AS status, CONCAT('Project is already ', new_status) AS message;
        ELSE
            -- Handle transitions based on current status
            CASE 
                WHEN current_status = 'pending' THEN
                    UPDATE projects SET status = new_status, updated_at = NOW() WHERE id = project_id;
                    
                    IF new_status = 'approved' THEN
                        INSERT INTO approvals (project_id, admin_id, status, created_at, updated_at)
                        VALUES (project_id, admin_user_id, 'approved', NOW(), NOW())
                        ON DUPLICATE KEY UPDATE status = 'approved', updated_at = NOW();
                    ELSEIF new_status = 'rejected' THEN
                        INSERT INTO approvals (project_id, admin_id, status, rejection_reason, created_at, updated_at)
                        VALUES (project_id, admin_user_id, 'rejected', rejection_reason, NOW(), NOW())
                        ON DUPLICATE KEY UPDATE status = 'rejected', rejection_reason = rejection_reason, updated_at = NOW();
                    END IF;

                WHEN current_status = 'approved' THEN
                    IF new_status = 'rejected' THEN
                        UPDATE projects SET status = new_status, updated_at = NOW() WHERE id = project_id;
                        
                        INSERT INTO approvals (project_id, admin_id, status, rejection_reason, created_at, updated_at)
                        VALUES (project_id, admin_user_id, 'rejected', rejection_reason, NOW(), NOW())
                        ON DUPLICATE KEY UPDATE status = 'rejected', rejection_reason = rejection_reason, updated_at = NOW();
                    ELSEIF new_status = 'pending' THEN
                        UPDATE projects SET status = new_status, updated_at = NOW() WHERE id = project_id;
                        DELETE FROM approvals WHERE project_id = project_id;
                    END IF;

                WHEN current_status = 'rejected' THEN
                    IF new_status = 'approved' THEN
                        UPDATE projects SET status = new_status, updated_at = NOW() WHERE id = project_id;
                        
                        INSERT INTO approvals (project_id, admin_id, status, created_at, updated_at)
                        VALUES (project_id, admin_user_id, 'approved', NOW(), NOW())
                        ON DUPLICATE KEY UPDATE status = 'approved', updated_at = NOW();
                    ELSEIF new_status = 'pending' THEN
                        UPDATE projects SET status = new_status, updated_at = NOW() WHERE id = project_id;
                        DELETE FROM approvals WHERE project_id = project_id;
                    END IF;
            END CASE;

            -- Log status update
            INSERT INTO audit_logs (user_id, action, auditable_id, auditable_type, timestamp)
            VALUES (admin_user_id, CONCAT('project_', new_status), project_id, 'App\\Models\\Project', NOW());

            -- Commit changes
            COMMIT;
            SELECT 'success' AS status, CONCAT('Project status updated to ', new_status) AS message;
        END IF;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `approvals`
--

CREATE TABLE `approvals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `project_id` bigint(20) UNSIGNED NOT NULL,
  `admin_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` varchar(255) NOT NULL,
  `reason` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `approvals`
--

INSERT INTO `approvals` (`id`, `project_id`, `admin_id`, `status`, `reason`, `created_at`, `updated_at`) VALUES
(45, 3, 6, 'rejected', 'this', '2025-04-25 16:08:03', '2025-04-25 16:08:03'),
(46, 9, 6, 'approved', NULL, '2025-04-25 21:49:30', '2025-04-25 21:49:30'),
(47, 5, 6, 'approved', NULL, '2025-04-25 22:22:42', '2025-04-25 22:22:42'),
(48, 4, 6, 'approved', NULL, '2025-04-25 22:23:26', '2025-04-25 22:23:26'),
(49, 3, 6, 'approved', NULL, '2025-04-25 22:23:28', '2025-04-25 22:23:28'),
(50, 9, 6, 'rejected', 'reee', '2025-04-25 16:54:48', '2025-04-25 16:54:48'),
(51, 9, 6, 'approved', NULL, '2025-04-25 22:25:09', '2025-04-25 22:25:09'),
(52, 4, 6, 'rejected', 'dfdg', '2025-04-25 16:55:50', '2025-04-25 16:55:50'),
(53, 9, 6, 'rejected', 'reject', '2025-04-26 11:32:20', '2025-04-26 11:32:20'),
(54, 9, 6, 'approved', NULL, '2025-04-26 17:09:05', '2025-04-26 17:09:05'),
(55, 4, 6, 'approved', NULL, '2025-04-26 17:09:11', '2025-04-26 17:09:11'),
(56, 4, 6, 'rejected', 'gdf', '2025-04-26 11:39:20', '2025-04-26 11:39:20'),
(57, 9, 6, 'rejected', 'ssdgdf', '2025-04-26 11:39:27', '2025-04-26 11:39:27'),
(58, 9, 6, 'approved', NULL, '2025-04-26 17:17:49', '2025-04-26 17:17:49'),
(59, 9, 6, 'rejected', 'sdsdsafsa', '2025-04-26 11:47:57', '2025-04-26 11:47:57'),
(60, 9, 6, 'approved', NULL, '2025-04-26 17:23:09', '2025-04-26 17:23:09'),
(61, 9, 6, 'rejected', 'vsdfdsfsf', '2025-04-26 11:55:13', '2025-04-26 11:55:13'),
(62, 9, 6, 'approved', NULL, '2025-04-26 17:26:08', '2025-04-26 17:26:08'),
(63, 5, 6, 'rejected', 'fafafass', '2025-04-26 11:57:58', '2025-04-26 11:57:58'),
(64, 9, 6, 'rejected', 'reject', '2025-04-27 07:49:44', '2025-04-27 07:49:44'),
(65, 5, 6, 'approved', NULL, '2025-04-27 13:19:54', '2025-04-27 13:19:54'),
(66, 11, 6, 'rejected', 'Check', '2025-04-27 09:48:07', '2025-04-27 09:48:07'),
(67, 9, 6, 'approved', NULL, '2025-04-27 15:18:14', '2025-04-27 15:18:14'),
(68, 13, 6, 'approved', NULL, '2025-04-27 16:45:03', '2025-04-27 16:45:03'),
(69, 9, 6, 'rejected', 'Rejected', '2025-04-27 11:15:26', '2025-04-27 11:15:26');

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `auditable_type` varchar(255) NOT NULL,
  `auditable_id` bigint(20) UNSIGNED NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `auditable_type`, `auditable_id`, `timestamp`, `created_at`, `updated_at`) VALUES
(12, 6, 'project_approved', 'App\\Models\\Project', 3, '2025-04-20 15:27:04', NULL, NULL),
(13, 6, 'project_rejected', 'App\\Models\\Project', 2, '2025-04-20 15:59:26', NULL, NULL),
(15, 6, 'project_approved', 'App\\Models\\Project', 1, '2025-04-20 18:41:01', NULL, NULL),
(16, 6, 'project_approved', 'App\\Models\\Project', 5, '2025-04-25 20:47:45', NULL, NULL),
(17, 6, 'project_rejected', 'App\\Models\\Project', 5, '2025-04-25 21:00:38', NULL, NULL),
(18, 6, 'project_approved', 'App\\Models\\Project', 4, '2025-04-25 21:17:05', NULL, NULL),
(19, 6, 'project_rejected', 'App\\Models\\Project', 4, '2025-04-25 21:30:44', NULL, NULL),
(20, 6, 'project_rejected', 'App\\Models\\Project', 3, '2025-04-25 21:38:03', NULL, NULL),
(21, 6, 'project_approved', 'App\\Models\\Project', 9, '2025-04-25 21:49:30', NULL, NULL),
(22, 6, 'project_approved', 'App\\Models\\Project', 5, '2025-04-25 22:22:42', NULL, NULL),
(23, 6, 'project_approved', 'App\\Models\\Project', 4, '2025-04-25 22:23:26', NULL, NULL),
(24, 6, 'project_approved', 'App\\Models\\Project', 3, '2025-04-25 22:23:28', NULL, NULL),
(25, 6, 'project_rejected', 'App\\Models\\Project', 9, '2025-04-25 22:24:48', NULL, NULL),
(26, 6, 'project_approved', 'App\\Models\\Project', 9, '2025-04-25 22:25:09', NULL, NULL),
(27, 6, 'project_rejected', 'App\\Models\\Project', 4, '2025-04-25 22:25:50', NULL, NULL),
(28, 6, 'project_rejected', 'App\\Models\\Project', 9, '2025-04-26 17:02:20', NULL, NULL),
(29, 6, 'project_approved', 'App\\Models\\Project', 9, '2025-04-26 17:09:05', NULL, NULL),
(30, 6, 'project_approved', 'App\\Models\\Project', 4, '2025-04-26 17:09:11', NULL, NULL),
(31, 6, 'project_rejected', 'App\\Models\\Project', 4, '2025-04-26 17:09:20', NULL, NULL),
(32, 6, 'project_rejected', 'App\\Models\\Project', 9, '2025-04-26 17:09:27', NULL, NULL),
(33, 6, 'project_approved', 'App\\Models\\Project', 9, '2025-04-26 17:17:49', NULL, NULL),
(34, 6, 'project_rejected', 'App\\Models\\Project', 9, '2025-04-26 17:17:57', NULL, NULL),
(35, 6, 'project_approved', 'App\\Models\\Project', 9, '2025-04-26 17:23:09', NULL, NULL),
(36, 6, 'project_rejected', 'App\\Models\\Project', 9, '2025-04-26 17:25:13', NULL, NULL),
(37, 6, 'project_approved', 'App\\Models\\Project', 9, '2025-04-26 17:26:08', NULL, NULL),
(38, 6, 'project_rejected', 'App\\Models\\Project', 5, '2025-04-26 17:27:58', NULL, NULL),
(39, 6, 'project_rejected', 'App\\Models\\Project', 9, '2025-04-27 13:19:44', NULL, NULL),
(40, 6, 'project_approved', 'App\\Models\\Project', 5, '2025-04-27 13:19:54', NULL, NULL),
(41, 6, 'project_rejected', 'App\\Models\\Project', 11, '2025-04-27 15:18:07', NULL, NULL),
(42, 6, 'project_approved', 'App\\Models\\Project', 9, '2025-04-27 15:18:14', NULL, NULL),
(43, 6, 'project_approved', 'App\\Models\\Project', 13, '2025-04-27 16:45:03', NULL, NULL),
(44, 6, 'project_rejected', 'App\\Models\\Project', 9, '2025-04-27 16:45:26', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `queue`, `payload`, `attempts`, `reserved_at`, `available_at`, `created_at`) VALUES
(25, 'default', '{\"uuid\":\"3794af59-50c6-4cfb-ae0e-eab8ca9acc92\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:5;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745614067, 1745614067),
(26, 'default', '{\"uuid\":\"0628d20e-083c-4b82-bd3c-8bd0e15e5093\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:5;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:9:\\\"Check for\\\";}\"}}', 0, NULL, 1745614838, 1745614838),
(27, 'default', '{\"uuid\":\"4a688481-8518-4e9c-9b3f-cb219c6e8c39\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:4;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745615825, 1745615825),
(28, 'default', '{\"uuid\":\"be727f00-dfe7-4868-aa0c-05fff2aa8d8c\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:4;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:6:\\\"reject\\\";}\"}}', 0, NULL, 1745616644, 1745616644),
(29, 'default', '{\"uuid\":\"528197a1-3069-47b8-a214-6b6093096027\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:3;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:4:\\\"this\\\";}\"}}', 0, NULL, 1745617083, 1745617083),
(30, 'default', '{\"uuid\":\"200fbadc-9199-45c1-a5b0-21eac2163529\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745617770, 1745617770),
(31, 'default', '{\"uuid\":\"6fb0a913-6a1a-45c8-9f25-5ce43c64e1f2\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:5;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745619762, 1745619762),
(32, 'default', '{\"uuid\":\"bee37923-f3f6-472a-88dc-da2da531ebba\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:4;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745619806, 1745619806),
(33, 'default', '{\"uuid\":\"c15d77bb-b42d-45ac-baba-7892c67fa1cd\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:3;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745619808, 1745619808),
(41, 'default', '{\"uuid\":\"6949047f-8f3c-459d-8c13-cf9c25e9228b\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:4:\\\"reee\\\";}\"}}', 0, NULL, 1745619888, 1745619888),
(42, 'default', '{\"uuid\":\"218a2ace-e4f5-4440-80c9-b7afd9c5f871\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745619909, 1745619909),
(46, 'default', '{\"uuid\":\"ec2202cc-687c-4a02-867f-0b1cb934e72f\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:4;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:4:\\\"dfdg\\\";}\"}}', 0, NULL, 1745619950, 1745619950),
(47, 'default', '{\"uuid\":\"11ca138c-33ea-4b7d-9ddf-d3190f480073\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:6:\\\"reject\\\";}\"}}', 0, NULL, 1745686943, 1745686943),
(48, 'default', '{\"uuid\":\"d66543e4-cf3e-40c4-acc3-da9a5fda2f13\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745687345, 1745687345),
(49, 'default', '{\"uuid\":\"553ba2da-2f19-4528-866f-225f9ddded13\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:4;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745687352, 1745687352),
(50, 'default', '{\"uuid\":\"bb313f94-8633-47d2-bfa5-e552d81d7203\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:4;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:3:\\\"gdf\\\";}\"}}', 0, NULL, 1745687360, 1745687360),
(51, 'default', '{\"uuid\":\"351b70b7-1715-4e8c-8c50-832fde266248\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:6:\\\"ssdgdf\\\";}\"}}', 0, NULL, 1745687367, 1745687367),
(52, 'default', '{\"uuid\":\"b62f906a-f5a9-4338-a8c8-433c40b37785\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745687869, 1745687869),
(53, 'default', '{\"uuid\":\"7b855115-68eb-4e99-b2e0-c99cb1f0bc67\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:9:\\\"sdsdsafsa\\\";}\"}}', 0, NULL, 1745687877, 1745687877),
(54, 'default', '{\"uuid\":\"a92b8008-febf-45f9-b84d-1ef5e470fe8b\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745688189, 1745688189),
(55, 'default', '{\"uuid\":\"c39bce68-80e9-4e28-8fe4-5bad251f0cb5\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:9:\\\"vsdfdsfsf\\\";}\"}}', 0, NULL, 1745688313, 1745688313),
(56, 'default', '{\"uuid\":\"40af0c38-dae4-4eb2-aefc-d57908a6b2da\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745688369, 1745688369),
(57, 'default', '{\"uuid\":\"25775d4b-33d1-49b1-9468-5b2d7d8dd9ab\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:5;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:8:\\\"fafafass\\\";}\"}}', 0, NULL, 1745688478, 1745688478),
(58, 'default', '{\"uuid\":\"e70668de-8569-4cf2-b15a-efc49df98993\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:6:\\\"reject\\\";}\"}}', 0, NULL, 1745759987, 1745759987),
(59, 'default', '{\"uuid\":\"45d15665-0d54-4f81-bf3e-a6e1382dea3d\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:5;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745759995, 1745759995),
(60, 'default', '{\"uuid\":\"95f4dbc5-832f-40c4-9b34-1b932f169049\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:10;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:9:\\\"submitted\\\";}\"}}', 0, NULL, 1745762493, 1745762493),
(61, 'default', '{\"uuid\":\"7a89ed48-0f40-4bf6-a048-1c4ab5466927\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:11;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:9:\\\"submitted\\\";}\"}}', 0, NULL, 1745762660, 1745762660),
(62, 'default', '{\"uuid\":\"50bed69f-de7c-44b1-9287-2f7454265144\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:11;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:5:\\\"Check\\\";}\"}}', 0, NULL, 1745767087, 1745767087),
(63, 'default', '{\"uuid\":\"dcb64382-8f8e-4546-b4aa-3797615e0e88\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745767095, 1745767095),
(64, 'default', '{\"uuid\":\"03096bc6-b30c-457e-a5c8-2809e93e679d\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:12;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:9:\\\"submitted\\\";}\"}}', 0, NULL, 1745771248, 1745771248),
(65, 'default', '{\"uuid\":\"0ff3df1c-0a88-4d8a-b550-2642b58d1dfa\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:13;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:9:\\\"submitted\\\";}\"}}', 0, NULL, 1745772250, 1745772250),
(66, 'default', '{\"uuid\":\"4642385d-4b7d-490a-a1ab-aa275744b7b4\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":2:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:13;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"approved\\\";}\"}}', 0, NULL, 1745772303, 1745772303),
(67, 'default', '{\"uuid\":\"daab4d89-55ec-4b9a-8a90-29a5f120bc69\",\"displayName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendProjectNotificationEmail\",\"command\":\"O:37:\\\"App\\\\Jobs\\\\SendProjectNotificationEmail\\\":3:{s:7:\\\"project\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:18:\\\"App\\\\Models\\\\Project\\\";s:2:\\\"id\\\";i:9;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:4:\\\"type\\\";s:8:\\\"rejected\\\";s:6:\\\"reason\\\";s:8:\\\"Rejected\\\";}\"}}', 0, NULL, 1745772326, 1745772326);

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_04_20_065829_create_projects_table', 1),
(5, '2025_04_20_065830_create_approvals_table', 1),
(6, '2025_04_20_065830_create_audit_logs_table', 1),
(7, '2025_04_20_102429_create_personal_access_tokens_table', 2);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(6, 'App\\Models\\User', 6, 'auth_token', '179f7822f15dc064c73c72a0061659e659bb1cd3cf538a1393520abc1cbf569f', '[\"*\"]', '2025-04-25 16:09:38', NULL, '2025-04-20 13:35:06', '2025-04-25 16:09:38'),
(7, 'App\\Models\\User', 2, 'auth_token', '00b7610f68e31f105a1751f1f94882bb78c48f8a345d3a9c75e8692b6bafe3c5', '[\"*\"]', '2025-04-20 13:47:32', NULL, '2025-04-20 13:41:28', '2025-04-20 13:47:32'),
(8, 'App\\Models\\User', 6, 'auth_token', '3aecb43af278e5646c14a973fe5b32b07d1798311ab8a954e198fa9bf88bd80a', '[\"*\"]', '2025-04-22 13:37:03', NULL, '2025-04-22 13:34:57', '2025-04-22 13:37:03'),
(9, 'App\\Models\\User', 6, 'auth_token', 'a51084e1cbe18149afe31400fd7624b698dc8d1866df1013f6234e1d1c04dc7d', '[\"*\"]', '2025-04-22 13:41:44', NULL, '2025-04-22 13:37:29', '2025-04-22 13:41:44'),
(10, 'App\\Models\\User', 6, 'auth_token', '41d2e6863b005d102ac1078c38117efde97504064f95bd21e5cb4527edc172c6', '[\"*\"]', '2025-04-22 13:49:11', NULL, '2025-04-22 13:42:07', '2025-04-22 13:49:11'),
(11, 'App\\Models\\User', 6, 'auth_token', '520ad675db994fc445bc4363e1deb51ab4e593d76a627261ccd0ec502b9eee8c', '[\"*\"]', '2025-04-22 14:09:29', NULL, '2025-04-22 13:49:36', '2025-04-22 14:09:29'),
(12, 'App\\Models\\User', 6, 'auth_token', '9a90969b2b9d7d92a588bb881b6b6f02c069049327250cab8d65b5d6c091b602', '[\"*\"]', '2025-04-22 14:15:05', NULL, '2025-04-22 14:09:52', '2025-04-22 14:15:05'),
(13, 'App\\Models\\User', 6, 'auth_token', 'bc551633c6d0ae6380eb57e32f3ccd60c2954a3ba671c31f35e30b70f02cf6e2', '[\"*\"]', '2025-04-22 14:17:41', NULL, '2025-04-22 14:15:15', '2025-04-22 14:17:41'),
(14, 'App\\Models\\User', 6, 'auth_token', 'b05dd76df7a58c0c21315025f01dc31861f11c64b8556d169ec7a06e6cee6f94', '[\"*\"]', '2025-04-22 15:09:50', NULL, '2025-04-22 14:28:02', '2025-04-22 15:09:50'),
(15, 'App\\Models\\User', 6, 'auth_token', '4ed89f2105fc12a30003aad48e767eaf1d13c3657b816742fef292e495551e65', '[\"*\"]', NULL, NULL, '2025-04-22 14:44:53', '2025-04-22 14:44:53'),
(16, 'App\\Models\\User', 6, 'auth_token', '2e741085f52115949a189f7f89ce976ce8170b0ebd2a3b02d6d326b82faa65c4', '[\"*\"]', NULL, NULL, '2025-04-22 14:52:31', '2025-04-22 14:52:31'),
(18, 'App\\Models\\User', 6, 'auth_token', '6080ad3dc67dfbd7508b14663ca197f386bbc7fb6842e4ddd69e72d13cc224f9', '[\"*\"]', NULL, NULL, '2025-04-23 13:46:02', '2025-04-23 13:46:02'),
(19, 'App\\Models\\User', 6, 'auth_token', '723ebd438159b5c780be1758d2e691093339add5ab63112c7bcff45594d35f10', '[\"*\"]', NULL, NULL, '2025-04-23 14:47:02', '2025-04-23 14:47:02'),
(20, 'App\\Models\\User', 6, 'auth_token', '6d432f3a250d32e75daf6018c5742bf2662e6a32d6dccad9bf1ee93483b12b28', '[\"*\"]', NULL, NULL, '2025-04-23 14:47:20', '2025-04-23 14:47:20'),
(21, 'App\\Models\\User', 6, 'auth_token', '8dd5255a56315d11246dca49aa579f459881647994392cfbd05acd6ee3287989', '[\"*\"]', NULL, NULL, '2025-04-23 14:47:44', '2025-04-23 14:47:44'),
(22, 'App\\Models\\User', 6, 'auth_token', '76d62c83956210909ee5e45788b6e6be9e5168c997f11f72c9aa7ba0d2c1b01d', '[\"*\"]', NULL, NULL, '2025-04-23 14:48:48', '2025-04-23 14:48:48'),
(23, 'App\\Models\\User', 6, 'auth_token', '5707348d6cbfeb7f1716ebd42631330be364ca84acfc9e3f9e054e0fb61eb729', '[\"*\"]', NULL, NULL, '2025-04-23 14:54:19', '2025-04-23 14:54:19'),
(24, 'App\\Models\\User', 6, 'auth_token', 'fcbbeb817b904a83ac7d1faa5d3c0208912c3e06512498edaa3a0c7fd233db75', '[\"*\"]', NULL, NULL, '2025-04-23 15:05:43', '2025-04-23 15:05:43'),
(25, 'App\\Models\\User', 6, 'auth_token', '4063414c723c9c18cc5bb0012f3b9e3eddcf879b029103fd1c761ff6d549fe11', '[\"*\"]', '2025-04-27 07:44:43', NULL, '2025-04-23 15:07:59', '2025-04-27 07:44:43'),
(34, 'App\\Models\\User', 14, 'auth_token', 'a5a6dbc841554365db835c0ef0fb1a6fbe2e8d05b28f7e159c0d7be28d7ade37', '[\"*\"]', '2025-04-26 12:36:21', NULL, '2025-04-26 12:30:26', '2025-04-26 12:36:21'),
(40, 'App\\Models\\User', 15, 'auth_token', 'd0295cfb281518bf7171db00800b514f3a705b9c4529484024361cb5ddeef79f', '[\"*\"]', NULL, NULL, '2025-04-27 10:29:18', '2025-04-27 10:29:18'),
(41, 'App\\Models\\User', 16, 'auth_token', '1e8c9011f3cda5001ddd6635d15c160365b392716ea715fb48b8ce1fbad3d3a8', '[\"*\"]', NULL, NULL, '2025-04-27 10:30:18', '2025-04-27 10:30:18'),
(42, 'App\\Models\\User', 17, 'auth_token', '36fcb5ecf78e7c5ab0e0118ccdc07280e125f98874f43ea6b6a3be28a84f22f7', '[\"*\"]', NULL, NULL, '2025-04-27 10:30:45', '2025-04-27 10:30:45'),
(43, 'App\\Models\\User', 18, 'auth_token', 'afa704dca7848480d68b8cdf61c0ba41dc8b3f2aef5d3bc7a0bec68882d5fe4a', '[\"*\"]', NULL, NULL, '2025-04-27 10:35:05', '2025-04-27 10:35:05'),
(44, 'App\\Models\\User', 19, 'auth_token', '7ec23a80a65f37936565b8d23ab0344e3c8ca24346ed7262156fb4ab536a5e63', '[\"*\"]', NULL, NULL, '2025-04-27 10:39:10', '2025-04-27 10:39:10'),
(45, 'App\\Models\\User', 20, 'auth_token', '307f2421e90c81a8428dc67a528884b2eb3e8e7c2ae3012753c170a98a00e3ee', '[\"*\"]', NULL, NULL, '2025-04-27 10:41:28', '2025-04-27 10:41:28'),
(46, 'App\\Models\\User', 21, 'auth_token', '9e24700871e41508648cbd80fc7416d293eba6cc8103bc6d56897adacda78962', '[\"*\"]', NULL, NULL, '2025-04-27 10:45:24', '2025-04-27 10:45:24'),
(47, 'App\\Models\\User', 22, 'auth_token', '26fa45e7c056ecc122d189efec67ab5f6ddd220e58f9d1a34a060621a214cf9d', '[\"*\"]', NULL, NULL, '2025-04-27 10:48:39', '2025-04-27 10:48:39'),
(48, 'App\\Models\\User', 23, 'auth_token', 'bc1030a4bf0015096ce249155bd8c5599891f78dbfbcd825aa321c835bb6360a', '[\"*\"]', NULL, NULL, '2025-04-27 10:56:47', '2025-04-27 10:56:47'),
(52, 'App\\Models\\User', 24, 'auth_token', '8f4c6013c58a86021c310ff0929a1decb260eeacd4bf0aa320f7067f088fb98b', '[\"*\"]', NULL, NULL, '2025-04-27 11:06:52', '2025-04-27 11:06:52');

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`id`, `user_id`, `title`, `description`, `file_path`, `status`, `created_at`, `updated_at`) VALUES
(3, 2, 'Website Redesign', 'Develop a new design to modernize the company website.', 'path/to/design.pdf', 'approved', '2025-04-20 11:04:39', '2025-04-25 22:23:28'),
(4, 2, 'This is a title', 'this is a description', NULL, 'rejected', '2025-04-20 13:46:01', '2025-04-26 11:39:20'),
(5, 2, 'This is a title', 'this is a description', NULL, 'approved', '2025-04-20 13:46:29', '2025-04-27 13:19:54'),
(9, 14, 'Project5', 'this project 5', NULL, 'rejected', '2025-04-25 18:30:00', '2025-04-27 11:15:26'),
(10, 14, 'Check Demo', 'Project Description', NULL, 'pending', '2025-04-27 08:31:33', '2025-04-27 08:31:33'),
(11, 14, 'Check Demo', 'dhbikughbgnisdkbhsfinsfdh', 'project_files/rYjrxYm6gPPZ4LBLZH5pa51BwvR8OMkTESSY1LCm.png', 'rejected', '2025-04-27 08:34:20', '2025-04-27 09:48:07'),
(12, 23, 'Check Demo', 'fsdgfdhgfdgdgd', 'project_files/Oi9oMw2f4yw0w9EzqKUoLIPgCQuRi0CdbwLj8xOQ.png', 'pending', '2025-04-27 10:57:27', '2025-04-27 10:57:27'),
(13, 2, 'This is a title', 'this is a description', 'project_files/PQ1QpY7UuAp8kaYY1VsL0GePNixFykv729WMU9Sd.png', 'approved', '2025-04-27 11:14:10', '2025-04-27 16:45:03');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('T54IDzgYAz8xQPCYXe94YTENn75rXvDyxE1Hk9w8', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiclFWR3NUZnFnb2N0bnZ1b3RJbW9QTVVvQ2V3NzlvcEVIcmtTT1BzOCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1745139024);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'user',
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `role`, `remember_token`, `created_at`, `updated_at`) VALUES
(2, 'Regular User', 'user@example.com', NULL, '$2y$12$S9IiP4d3xfXEXxML9Z/NgO35ktyNH7FxyWLBBQ10i/gRjhlZ45kDa', 'user', NULL, '2025-04-20 02:57:24', '2025-04-20 02:57:24'),
(6, 'Rocky 2', 'rocky.rbl2312@gmail.com', NULL, '$2y$12$S9IiP4d3xfXEXxML9Z/NgO35ktyNH7FxyWLBBQ10i/gRjhlZ45kDa', 'admin', NULL, '2025-04-20 04:13:17', '2025-04-20 04:13:17'),
(14, 'Satya', 'satya123@gmail.com', NULL, '$2y$12$S9IiP4d3xfXEXxML9Z/NgO35ktyNH7FxyWLBBQ10i/gRjhlZ45kDa', 'user', NULL, '2025-04-25 18:30:00', '2025-04-25 18:30:00'),
(15, 'Satendra', 'sk.gautam967@gmail.com', NULL, '$2y$12$Ab.12OuTRuFa8TlSUtcIc.ySEIh8pBJr6jNH0ak0b6TyDAB0YAXIa', 'user', NULL, '2025-04-27 10:29:18', '2025-04-27 10:29:18'),
(16, 'John Smith', 'johnsmith3@example.com', NULL, '$2y$12$.NeljROdZ05TbZTKIzB2neYlHHSs7luHeUD4jD84aTD2.z.bsc.Ru', 'user', NULL, '2025-04-27 10:30:18', '2025-04-27 10:30:18'),
(17, 'John Smith', 'johnsmith4@example.com', NULL, '$2y$12$4MpLQXNVKlxlwSboDGKuXOBTQD/KlGMuQni17DRxs4uuw0LqqAgry', 'user', NULL, '2025-04-27 10:30:45', '2025-04-27 10:30:45'),
(18, 'Satendra', 'sk.gautam9673@gmail.com', NULL, '$2y$12$B8SkcJxJuxYE.hAekXjusOTQEsZspkmp.tZpaV8uycT3u9g69RpR2', 'user', NULL, '2025-04-27 10:35:05', '2025-04-27 10:35:05'),
(19, 'Satendra', 'sk.gautam93@gmail.com', NULL, '$2y$12$3RrXS9/Asro.RdWPH24GdeN.Iq2NC6s/w3wTnSkQ389UkoCfRao/q', 'user', NULL, '2025-04-27 10:39:09', '2025-04-27 10:39:09'),
(20, 'satendra', 'rocky.rbl2@gmail.com', NULL, '$2y$12$fACkB84vZEjGHDQHKHJ6zeyX2HI6WIFWgx4sKTGUDZPBCiVolUL7m', 'user', NULL, '2025-04-27 10:41:28', '2025-04-27 10:41:28'),
(21, 'satendra', 'rocky.rl2@gmail.com', NULL, '$2y$12$jJochzjGj6I89iaf5QNn4efYm7jcH4YNxHKgtV02Ss5vxrpzJ8fAy', 'user', NULL, '2025-04-27 10:45:24', '2025-04-27 10:45:24'),
(22, 'Satendra', 'skm9673@gmail.com', NULL, '$2y$12$wbF8aDGjmxPpL8Ub/wn3Fesq0XkVg1kx/P4m7ON52jPQkoHXyB3hG', 'user', NULL, '2025-04-27 10:48:39', '2025-04-27 10:48:39'),
(23, 'Satendra', 'skm673@gmail.com', NULL, '$2y$12$C1aH0vwynX65pDrrH/LPQepD/DX2wS7/HzyF5UHctzTO8suVkMudW', 'user', NULL, '2025-04-27 10:56:46', '2025-04-27 10:56:46'),
(24, 'Satendra', 'sk.gautm9673@gmail.com', NULL, '$2y$12$oZ/KAwOjhMPBX.TyYyF8AeblwM587gU.5o4fptBWsLNFPePo8ienW', 'user', NULL, '2025-04-27 11:06:52', '2025-04-27 11:06:52');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `approvals`
--
ALTER TABLE `approvals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `approvals_project_id_foreign` (`project_id`),
  ADD KEY `approvals_admin_id_foreign` (`admin_id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `audit_logs_user_id_foreign` (`user_id`),
  ADD KEY `audit_logs_auditable_type_auditable_id_index` (`auditable_type`,`auditable_id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `projects_user_id_foreign` (`user_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `approvals`
--
ALTER TABLE `approvals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `approvals`
--
ALTER TABLE `approvals`
  ADD CONSTRAINT `approvals_admin_id_foreign` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `approvals_project_id_foreign` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `projects_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
