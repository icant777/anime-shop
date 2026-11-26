-- MySQL dump 10.13  Distrib 8.0.13, for Win64 (x86_64)
--
-- Host: localhost    Database: xym-work
-- ------------------------------------------------------
-- Server version	8.0.13

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `xym-work`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `xym-work` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;

USE `xym-work`;

--
-- Table structure for table `character_subscription`
--

DROP TABLE IF EXISTS `character_subscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `character_subscription` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '订阅ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `character_id` bigint(20) NOT NULL COMMENT '订阅的角色ID',
  `notify_switch` tinyint(4) NOT NULL DEFAULT '1' COMMENT '推送开关：1开 2关',
  `subscribe_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '订阅时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_character` (`user_id`,`character_id`),
  KEY `idx_character` (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色订阅表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `character_subscription`
--

LOCK TABLES `character_subscription` WRITE;
/*!40000 ALTER TABLE `character_subscription` DISABLE KEYS */;
/*!40000 ALTER TABLE `character_subscription` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `condition_level`
--

DROP TABLE IF EXISTS `condition_level`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `condition_level` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '品相ID',
  `code` varchar(30) NOT NULL COMMENT '品相编码：BRAND_NEW/MINOR_DAMAGE/FACTORY_DAMAGE/CREASE',
  `name` varchar(50) NOT NULL COMMENT '品相名称：全新/初伤/厂伤/压痕',
  `description` varchar(200) DEFAULT NULL COMMENT '品相描述与判定标准',
  `level_no` int(11) NOT NULL DEFAULT '0' COMMENT '品相排序，越小品相越好',
  `discount_rate` decimal(5,4) NOT NULL DEFAULT '1.0000' COMMENT '相对全新的折价系数，1.0000表示不折价',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1启用 2停用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='品相等级字典表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `condition_level`
--

LOCK TABLES `condition_level` WRITE;
/*!40000 ALTER TABLE `condition_level` DISABLE KEYS */;
INSERT INTO `condition_level` VALUES (1,'BRAND_NEW','全新','未拆封全新',1,1.0000,1,'2026-11-20 16:26:25','2026-11-20 16:26:25'),(2,'MINOR_DAMAGE','微损','轻微使用痕迹',2,0.9000,1,'2026-11-20 16:26:25','2026-11-20 16:26:25');
/*!40000 ALTER TABLE `condition_level` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon_template`
--

DROP TABLE IF EXISTS `coupon_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `coupon_template` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '券模板ID',
  `coupon_code` varchar(50) NOT NULL COMMENT '模板编码',
  `coupon_name` varchar(100) NOT NULL COMMENT '券名称：满100减20',
  `coupon_type` tinyint(4) NOT NULL COMMENT '类型：1满减券 2折扣券 3无门槛券 4运费券',
  `discount_value` decimal(10,2) NOT NULL COMMENT '优惠值：满减/无门槛填金额；折扣券填折扣率如0.85',
  `threshold_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '使用门槛金额，0表示无门槛',
  `max_discount` decimal(10,2) DEFAULT NULL COMMENT '折扣券最高优惠金额，NULL不限',
  `total_count` int(11) NOT NULL DEFAULT '0' COMMENT '发行总量，0表示不限量',
  `claimed_count` int(11) NOT NULL DEFAULT '0' COMMENT '已领取数量（冗余计数）',
  `used_count` int(11) NOT NULL DEFAULT '0' COMMENT '已使用数量（冗余计数）',
  `per_user_limit` int(11) NOT NULL DEFAULT '1' COMMENT '每人限领张数',
  `scope_type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '适用范围：1全场 2分类 3指定IP 4指定商品',
  `scope_id` bigint(20) DEFAULT NULL COMMENT '范围对象ID；scope_type=1时为NULL，多态关联不建外键',
  `start_time` datetime NOT NULL COMMENT '领取开始时间',
  `end_time` datetime NOT NULL COMMENT '领取结束时间',
  `valid_days` int(11) NOT NULL DEFAULT '7' COMMENT '领取后有效天数，0表示固定到期时间',
  `fixed_expire_time` datetime DEFAULT NULL COMMENT '固定到期时间（valid_days=0时生效）',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1启用 2停用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_coupon_code` (`coupon_code`),
  KEY `idx_status_time` (`status`,`start_time`,`end_time`),
  KEY `idx_scope` (`scope_type`,`scope_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9002 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='消费券模板表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon_template`
--

LOCK TABLES `coupon_template` WRITE;
/*!40000 ALTER TABLE `coupon_template` DISABLE KEYS */;
INSERT INTO `coupon_template` VALUES (1,'C-001','满50减10',1,10.00,50.00,NULL,100,2,0,2,1,NULL,'2026-11-19 16:26:25','2026-12-20 16:26:25',7,NULL,1,'2026-11-20 16:26:25','2026-11-25 15:21:16'),(2,'C-002','无门槛5元',3,5.00,0.00,NULL,100,1,0,1,1,NULL,'2026-11-19 16:26:25','2026-12-20 16:26:25',7,NULL,1,'2026-11-20 16:26:25','2026-11-25 15:21:15');
/*!40000 ALTER TABLE `coupon_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deposit_escrow`
--

DROP TABLE IF EXISTS `deposit_escrow`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `deposit_escrow` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '托管ID',
  `escrow_no` varchar(64) NOT NULL COMMENT '托管流水号',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID（一单一托管）',
  `user_id` bigint(20) NOT NULL COMMENT '付款用户ID',
  `merchant_id` bigint(20) NOT NULL COMMENT '商家ID',
  `amount` decimal(10,2) NOT NULL COMMENT '托管定金金额',
  `platform_account` varchar(64) NOT NULL COMMENT '平台托管账户标识',
  `pay_channel` varchar(30) DEFAULT NULL COMMENT '支付渠道',
  `trade_no` varchar(100) DEFAULT NULL COMMENT '第三方支付流水号',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '托管状态：1已托管待补款 2已放款商家 3已退款用户 4平台赔付 5已过期',
  `balance_due_time` datetime NOT NULL COMMENT '补款截止时间',
  `extend_flag` tinyint(4) NOT NULL DEFAULT '0' COMMENT '延期标记：0否 1是',
  `extend_days` int(11) NOT NULL DEFAULT '0' COMMENT '已延期天数',
  `max_extend_days` int(11) NOT NULL DEFAULT '3' COMMENT '允许最大延期天数（规则：尾款可延期3天）',
  `extended_due_time` datetime DEFAULT NULL COMMENT '延期后的截止时间',
  `merchant_status_snapshot` tinyint(4) DEFAULT NULL COMMENT '商家状态快照（赔付判断依据）',
  `platform_compensation` tinyint(4) NOT NULL DEFAULT '0' COMMENT '平台是否赔付：0否 1是（商家关店/失联）',
  `compensation_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '平台赔付金额',
  `compensation_reason` varchar(200) DEFAULT NULL COMMENT '赔付原因',
  `payout_time` datetime DEFAULT NULL COMMENT '放款给商家时间',
  `refund_time` datetime DEFAULT NULL COMMENT '退款给用户时间',
  `audit_trail` json DEFAULT NULL COMMENT '托管状态流转轨迹，JSON数组',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_escrow_no` (`escrow_no`),
  UNIQUE KEY `uk_order` (`order_id`),
  KEY `idx_status_due` (`status`,`balance_due_time`),
  KEY `idx_compensation` (`platform_compensation`),
  KEY `fk_escrow_user` (`user_id`),
  KEY `fk_escrow_merchant` (`merchant_id`),
  CONSTRAINT `fk_escrow_merchant` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`),
  CONSTRAINT `fk_escrow_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `fk_escrow_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='定金托管表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deposit_escrow`
--

LOCK TABLES `deposit_escrow` WRITE;
/*!40000 ALTER TABLE `deposit_escrow` DISABLE KEYS */;
/*!40000 ALTER TABLE `deposit_escrow` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goods`
--

DROP TABLE IF EXISTS `goods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `goods` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '商品ID（SPU）',
  `goods_code` varchar(32) NOT NULL COMMENT '商品编码（业务唯一码）',
  `goods_name` varchar(200) NOT NULL COMMENT '商品名称',
  `ip_id` bigint(20) NOT NULL COMMENT '所属IPID（冗余，角色已归属IP）',
  `character_id` bigint(20) NOT NULL COMMENT '所属角色ID',
  `merchant_id` bigint(20) NOT NULL COMMENT '商家ID',
  `category` varchar(50) DEFAULT NULL COMMENT '品类：吧唧/立牌/手办/色纸/亚克力',
  `category_id` bigint(20) DEFAULT NULL COMMENT '商品分类ID（二级分类）',
  `sale_mode` tinyint(4) NOT NULL DEFAULT '1' COMMENT '销售模式：1现货 2预售定金 3预售全款',
  `min_price` decimal(10,2) DEFAULT '0.00' COMMENT '展示最低价（冗余，取各品相SKU最小单价）',
  `deposit` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '预售定金金额（非预售为0）',
  `images` json DEFAULT NULL COMMENT '商品主图列表，JSON数组，如["url1","url2"]',
  `attributes` json DEFAULT NULL COMMENT '规格属性：尺寸/材质/版本等K-V',
  `detail` text COMMENT '商品详情富文本',
  `presale_start` datetime DEFAULT NULL COMMENT '预售开始时间',
  `presale_end` datetime DEFAULT NULL COMMENT '预售结束时间',
  `push_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '订阅推送标记：0待推送 1已推送（上架后按character_id找订阅者）',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1上架 2下架 3草稿',
  `audit_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '审核状态：0待审 1通过 2驳回',
  `deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '软删除：0否 1是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_goods_code` (`goods_code`),
  KEY `idx_ip_character` (`ip_id`,`character_id`),
  KEY `idx_merchant` (`merchant_id`),
  KEY `idx_status` (`status`),
  KEY `idx_push` (`push_status`,`status`),
  KEY `fk_goods_character` (`character_id`),
  KEY `idx_category` (`category_id`),
  CONSTRAINT `fk_goods_category` FOREIGN KEY (`category_id`) REFERENCES `goods_category` (`id`),
  CONSTRAINT `fk_goods_character` FOREIGN KEY (`character_id`) REFERENCES `ip_character` (`id`),
  CONSTRAINT `fk_goods_ip` FOREIGN KEY (`ip_id`) REFERENCES `ip` (`id`),
  CONSTRAINT `fk_goods_merchant` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9019 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品表（SPU）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goods`
--

LOCK TABLES `goods` WRITE;
/*!40000 ALTER TABLE `goods` DISABLE KEYS */;
INSERT INTO `goods` VALUES (1,'G-001','初音未来 限定吧唧',1,1,1,'吧唧/徽章',101,1,20.00,0.00,NULL,NULL,NULL,NULL,NULL,0,1,1,0,'2026-11-20 16:26:25','2026-11-20 16:26:25'),(2,'G-002','炭治郎 亚克力立牌',2,2,2,'亚克力立牌',102,1,50.00,0.00,NULL,NULL,NULL,NULL,NULL,0,1,1,0,'2026-11-20 16:26:25','2026-11-20 16:26:25'),(9003,'G-101','原神 破格锋镞系列 马口铁徽章',1,1,1,'吧唧',101,1,18.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9004,'G-201','FURYU 初音未来 泡面压景品手办',1,1,1,'景品',203,1,83.30,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9005,'G-202','原神 蒙德城主题 粘土人 凯亚',1,1,1,'粘土人',202,1,329.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9006,'G-203','布鲁可 初音未来 奇迹版 积木人',1,1,2,'拼装模型',206,1,159.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9007,'G-301','bilibiliGoods Spark系列 乐谱笔记本',1,1,1,'笔记本',301,1,25.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9008,'G-302','咒术回战 横滨联动 橡胶防滑桌垫',2,2,2,'鼠标垫',302,1,68.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9009,'G-303','初音未来 主题帆布袋',1,1,1,'帆布袋',305,1,39.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9010,'G-401','初音未来 Spark系列 多功能收纳痛包',1,1,1,'痛包',403,1,128.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9011,'G-402','咒术回战 霓虹系列 T恤',2,2,2,'T恤',401,1,89.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9012,'G-403','初音未来 fufu 花娃娃单肩痛包',1,1,2,'痛包',403,1,75.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9013,'G-501','原神 骤雪系列 收藏卡套组盲盒',1,1,1,'收藏卡',501,1,19.90,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9014,'G-502','咒术回战 透光拍立得透明小卡',2,2,2,'拍立得',502,1,12.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9015,'G-503','原神 周年庆典 纪念票卡套组',1,1,1,'收藏卡',501,1,34.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9016,'G-601','咒术回战 霓虹系列 亚克力立牌',2,2,2,'场贩限定',601,1,45.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9017,'G-602','原神 破格锋镞系列 明信片套组',1,1,1,'特典',602,1,48.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9018,'G-603','bilibili 一番赏 初音未来 抽赏',1,1,1,'一番赏',603,1,28.00,0.00,NULL,'{\"材质\": \"正品周边\", \"系列\": \"官方周边\"}',NULL,NULL,NULL,0,1,1,0,'2026-11-26 11:36:00','2026-11-26 11:36:00');
/*!40000 ALTER TABLE `goods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goods_category`
--

DROP TABLE IF EXISTS `goods_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `goods_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `parent_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '父分类ID，0表示一级分类',
  `category_name` varchar(50) NOT NULL COMMENT '分类名称（吧唧/立牌/棉花娃娃等）',
  `category_code` varchar(50) NOT NULL COMMENT '分类编码，程序里用这个',
  `level` tinyint(4) NOT NULL DEFAULT '1' COMMENT '层级：1一级 2二级',
  `sort_no` int(11) NOT NULL DEFAULT '0' COMMENT '同级排序，越小越靠前',
  `icon_url` varchar(500) DEFAULT NULL COMMENT '分类图标URL',
  `description` varchar(200) DEFAULT NULL COMMENT '分类说明',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1启用 2停用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`category_code`),
  KEY `idx_parent` (`parent_id`),
  KEY `idx_name` (`category_name`),
  CONSTRAINT `fk_gc_parent` FOREIGN KEY (`parent_id`) REFERENCES `goods_category` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=604 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品分类表（动漫周边品类）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goods_category`
--

LOCK TABLES `goods_category` WRITE;
/*!40000 ALTER TABLE `goods_category` DISABLE KEYS */;
INSERT INTO `goods_category` VALUES (1,0,'周边商品','MERCH',1,1,NULL,'吧唧、立牌、色纸等轻周边',1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(2,0,'手办模型','FIGURE',1,2,NULL,'手办、粘土人、景品等',1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(3,0,'文具生活','STATIONERY',1,3,NULL,'文具与日用周边',1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(4,0,'服饰配件','APPAREL',1,4,NULL,'服饰与包袋',1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(5,0,'收藏卡牌','COLLECT',1,5,NULL,'卡牌、拍立得等收藏品',1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(6,0,'限定特典','LIMITED',1,6,NULL,'场贩限定、一番赏等',1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(101,1,'吧唧/徽章','BADGE',2,1,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(102,1,'亚克力立牌','ACRYLIC_STAND',2,2,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(103,1,'色纸','SHIKISHI',2,3,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(104,1,'挂件/钥匙扣','CHARMS',2,4,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(105,1,'棉花娃娃','COTTON_DOLL',2,5,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(106,1,'贴纸','STICKER',2,6,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(107,1,'海报','POSTER',2,7,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(108,1,'明信片','POSTCARD',2,8,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(109,1,'流沙麻将','SAND_MAHJONG',2,9,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(110,1,'咕卡/贴纸包','GUKA',2,10,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(111,1,'亚克力砖/摆件','ACRYLIC_BLOCK',2,11,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(201,2,'手办','SCALE_FIGURE',2,1,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(202,2,'粘土人','NENDOROID',2,2,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(203,2,'景品','PRIZE_FIGURE',2,3,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(204,2,'盒蛋/扭蛋','GACHAPON',2,4,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(205,2,'食玩','CANDY_TOY',2,5,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(206,2,'拼装模型','MODEL_KIT',2,6,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(301,3,'笔记本','NOTEBOOK',2,1,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(302,3,'鼠标垫','MOUSEPAD',2,2,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(303,3,'水杯','MUG',2,3,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(304,3,'手机壳','PHONE_CASE',2,4,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(305,3,'帆布袋','CANVAS_BAG',2,5,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(401,4,'T恤','T_SHIRT',2,1,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(402,4,'卫衣','HOODIE',2,2,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(403,4,'痛包','ITA_BAG',2,3,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(404,4,'袜子','SOCKS',2,4,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(405,4,'发饰','HAIR_ACCESSORY',2,5,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(501,5,'收藏卡','TRADING_CARD',2,1,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(502,5,'拍立得','POLAROID',2,2,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(503,5,'海报筒','POSTER_TUBE',2,3,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(601,6,'场贩限定','EVENT_LIMITED',2,1,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(602,6,'特典','BONUS',2,2,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30'),(603,6,'一番赏','ICHIJEN_KUJI',2,3,NULL,NULL,1,'2026-11-20 15:55:30','2026-11-20 15:55:30');
/*!40000 ALTER TABLE `goods_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goods_condition_rel`
--

DROP TABLE IF EXISTS `goods_condition_rel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `goods_condition_rel` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'SKU_ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID（SPU）',
  `condition_level_id` bigint(20) NOT NULL COMMENT '品相等级ID',
  `sku_code` varchar(64) NOT NULL COMMENT 'SKU编码',
  `price` decimal(10,2) NOT NULL COMMENT '该品相单价（判断是否≥300的依据）',
  `deposit` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '该品相定金，覆盖SPU默认值',
  `stock` int(11) NOT NULL DEFAULT '0' COMMENT '可售库存',
  `locked_stock` int(11) NOT NULL DEFAULT '0' COMMENT '锁定库存（下单未支付占用）',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1启用 2停用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_goods_condition` (`goods_id`,`condition_level_id`),
  UNIQUE KEY `uk_sku_code` (`sku_code`),
  KEY `idx_condition` (`condition_level_id`),
  CONSTRAINT `fk_gcr_condition` FOREIGN KEY (`condition_level_id`) REFERENCES `condition_level` (`id`),
  CONSTRAINT `fk_gcr_goods` FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9035 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品品相关联表（SKU层）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goods_condition_rel`
--

LOCK TABLES `goods_condition_rel` WRITE;
/*!40000 ALTER TABLE `goods_condition_rel` DISABLE KEYS */;
INSERT INTO `goods_condition_rel` VALUES (1,1,1,'G-001-N',20.00,0.00,97,3,1,'2026-11-20 16:26:25','2026-11-20 17:12:30'),(2,1,2,'G-001-D',18.00,0.00,49,1,1,'2026-11-20 16:26:25','2026-11-25 14:42:57'),(3,2,1,'G-002-N',50.00,0.00,0,80,1,'2026-11-20 16:26:25','2026-11-25 15:20:47'),(9003,9003,1,'G-101-N',18.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9004,9003,2,'G-101-D',16.20,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9005,9004,1,'G-201-N',83.30,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9006,9004,2,'G-201-D',74.97,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9007,9005,1,'G-202-N',329.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9008,9005,2,'G-202-D',296.10,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9009,9006,1,'G-203-N',159.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9010,9006,2,'G-203-D',143.10,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9011,9007,1,'G-301-N',25.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9012,9007,2,'G-301-D',22.50,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9013,9008,1,'G-302-N',68.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9014,9008,2,'G-302-D',61.20,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9015,9009,1,'G-303-N',39.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9016,9009,2,'G-303-D',35.10,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9017,9010,1,'G-401-N',128.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9018,9010,2,'G-401-D',115.20,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9019,9011,1,'G-402-N',89.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9020,9011,2,'G-402-D',80.10,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9021,9012,1,'G-403-N',75.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9022,9012,2,'G-403-D',67.50,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9023,9013,1,'G-501-N',19.90,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9024,9013,2,'G-501-D',17.91,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9025,9014,1,'G-502-N',12.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9026,9014,2,'G-502-D',10.80,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9027,9015,1,'G-503-N',34.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9028,9015,2,'G-503-D',30.60,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9029,9016,1,'G-601-N',45.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9030,9016,2,'G-601-D',40.50,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9031,9017,1,'G-602-N',48.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9032,9017,2,'G-602-D',43.20,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9033,9018,1,'G-603-N',28.00,0.00,66,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00'),(9034,9018,2,'G-603-D',25.20,0.00,23,0,1,'2026-11-26 11:36:00','2026-11-26 11:36:00');
/*!40000 ALTER TABLE `goods_condition_rel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_buy`
--

DROP TABLE IF EXISTS `group_buy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `group_buy` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '拼团ID',
  `group_no` varchar(64) NOT NULL COMMENT '团号',
  `leader_id` bigint(20) NOT NULL COMMENT '团长用户ID',
  `ip_id` bigint(20) NOT NULL COMMENT '发起IPID',
  `title` varchar(100) DEFAULT NULL COMMENT '拼团标题',
  `start_time` datetime NOT NULL COMMENT '开团时间',
  `end_time` datetime NOT NULL COMMENT '截止时间',
  `target_count` int(11) NOT NULL DEFAULT '0' COMMENT '成团目标人数',
  `current_count` int(11) NOT NULL DEFAULT '0' COMMENT '当前参团人数（冗余计数）',
  `deposit_per_slot` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '每角色位定金',
  `allocation_rule` json DEFAULT NULL COMMENT '排谷/弃谷规则配置，如{"mode":"queue","allowAbandon":true,"deadline":"..."}',
  `leader_credit_score` int(11) NOT NULL DEFAULT '100' COMMENT '团长信用分（初始100）',
  `leader_credit_flag` tinyint(4) NOT NULL DEFAULT '0' COMMENT '团长信用标记：0正常 1预警 2黑名单',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1招募中 2已成团 3失败 4取消',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_group_no` (`group_no`),
  KEY `idx_ip_status` (`ip_id`,`status`),
  KEY `idx_leader` (`leader_id`),
  CONSTRAINT `fk_gb_ip` FOREIGN KEY (`ip_id`) REFERENCES `ip` (`id`),
  CONSTRAINT `fk_gb_leader` FOREIGN KEY (`leader_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='拼团表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_buy`
--

LOCK TABLES `group_buy` WRITE;
/*!40000 ALTER TABLE `group_buy` DISABLE KEYS */;
/*!40000 ALTER TABLE `group_buy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_buy_participant`
--

DROP TABLE IF EXISTS `group_buy_participant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `group_buy_participant` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '参团ID',
  `group_buy_id` bigint(20) NOT NULL COMMENT '拼团ID',
  `slot_id` bigint(20) NOT NULL COMMENT '占的角色位ID',
  `user_id` bigint(20) NOT NULL COMMENT '参团用户ID',
  `join_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '参团时间',
  `deposit_paid` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '已付定金',
  `allocation_mode` tinyint(4) NOT NULL DEFAULT '0' COMMENT '分配方式：0待定 1排谷 2弃谷',
  `abandon_flag` tinyint(4) NOT NULL DEFAULT '0' COMMENT '弃谷标记：0否 1是',
  `abandon_time` datetime DEFAULT NULL COMMENT '弃谷时间',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1参团中 2已分配 3弃谷 4退团',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_group_user` (`group_buy_id`,`user_id`),
  KEY `idx_slot` (`slot_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `fk_gp_group` FOREIGN KEY (`group_buy_id`) REFERENCES `group_buy` (`id`),
  CONSTRAINT `fk_gp_slot` FOREIGN KEY (`slot_id`) REFERENCES `group_buy_slot` (`id`),
  CONSTRAINT `fk_gp_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='参团记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_buy_participant`
--

LOCK TABLES `group_buy_participant` WRITE;
/*!40000 ALTER TABLE `group_buy_participant` DISABLE KEYS */;
/*!40000 ALTER TABLE `group_buy_participant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_buy_slot`
--

DROP TABLE IF EXISTS `group_buy_slot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `group_buy_slot` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '角色位ID',
  `group_buy_id` bigint(20) NOT NULL COMMENT '拼团ID',
  `character_id` bigint(20) NOT NULL COMMENT '角色ID',
  `slot_no` int(11) NOT NULL COMMENT '角色位序号（拼团内唯一）',
  `quota` int(11) NOT NULL DEFAULT '1' COMMENT '该角色位名额',
  `taken` int(11) NOT NULL DEFAULT '0' COMMENT '已占名额（冗余计数）',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1开放 2已满 3关闭',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_group_slot` (`group_buy_id`,`slot_no`),
  KEY `idx_character` (`character_id`),
  CONSTRAINT `fk_slot_char` FOREIGN KEY (`character_id`) REFERENCES `ip_character` (`id`),
  CONSTRAINT `fk_slot_group` FOREIGN KEY (`group_buy_id`) REFERENCES `group_buy` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='拼团角色位表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_buy_slot`
--

LOCK TABLES `group_buy_slot` WRITE;
/*!40000 ALTER TABLE `group_buy_slot` DISABLE KEYS */;
/*!40000 ALTER TABLE `group_buy_slot` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guardian_verify`
--

DROP TABLE IF EXISTS `guardian_verify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `guardian_verify` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '验证ID',
  `user_id` bigint(20) NOT NULL COMMENT '未成年用户ID',
  `order_id` bigint(20) DEFAULT NULL COMMENT '关联超额订单ID',
  `verify_no` varchar(64) NOT NULL COMMENT '验证流水号',
  `guardian_name` varchar(50) DEFAULT NULL COMMENT '监护人姓名',
  `guardian_id_hash` varchar(255) DEFAULT NULL COMMENT '监护人身份证哈希',
  `relation` varchar(20) DEFAULT NULL COMMENT '与未成年人关系',
  `verify_method` tinyint(4) NOT NULL DEFAULT '1' COMMENT '验证方式：1人脸 2其他',
  `face_result` tinyint(4) NOT NULL COMMENT '人脸核验结果：1通过 2拒绝',
  `face_score` decimal(5,2) DEFAULT NULL COMMENT '人脸比对相似度',
  `verify_time` datetime NOT NULL COMMENT '验证时间',
  `expire_time` datetime DEFAULT NULL COMMENT '验证有效期（超期需重新验证）',
  `device_id` varchar(100) DEFAULT NULL COMMENT '验证设备标识',
  `risk_flag` tinyint(4) NOT NULL DEFAULT '0' COMMENT '风险标记：0正常 1可疑',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_verify_no` (`verify_no`),
  KEY `idx_user_time` (`user_id`,`verify_time`),
  KEY `idx_order` (`order_id`),
  CONSTRAINT `fk_gv_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `fk_gv_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='监护人人脸验证记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guardian_verify`
--

LOCK TABLES `guardian_verify` WRITE;
/*!40000 ALTER TABLE `guardian_verify` DISABLE KEYS */;
/*!40000 ALTER TABLE `guardian_verify` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ip`
--

DROP TABLE IF EXISTS `ip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `ip` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'IPID',
  `name` varchar(100) NOT NULL COMMENT '作品名（中文）',
  `name_en` varchar(100) DEFAULT NULL COMMENT '作品名（英文）',
  `publisher` varchar(100) DEFAULT NULL COMMENT '版权方/出版社',
  `category` varchar(50) DEFAULT NULL COMMENT '分类：动画/漫画/游戏/轻小说',
  `first_publish_date` date DEFAULT NULL COMMENT '首发日期',
  `cover_url` varchar(500) DEFAULT NULL COMMENT '封面图URL',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1正常 2下架',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9002 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='IP（作品）表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ip`
--

LOCK TABLES `ip` WRITE;
/*!40000 ALTER TABLE `ip` DISABLE KEYS */;
INSERT INTO `ip` VALUES (1,'初音未来','Hatsune Miku',NULL,'动漫',NULL,NULL,1,'2026-11-20 16:26:25','2026-11-20 16:26:25'),(2,'鬼灭之刃','Demon Slayer',NULL,'动漫',NULL,NULL,1,'2026-11-20 16:26:25','2026-11-20 16:26:25');
/*!40000 ALTER TABLE `ip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ip_character`
--

DROP TABLE IF EXISTS `ip_character`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `ip_character` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `ip_id` bigint(20) NOT NULL COMMENT '所属IPID',
  `name` varchar(100) NOT NULL COMMENT '角色名',
  `name_en` varchar(100) DEFAULT NULL COMMENT '角色名（英文）',
  `avatar_url` varchar(500) DEFAULT NULL COMMENT '角色头像URL',
  `gender` tinyint(4) DEFAULT NULL COMMENT '性别：0未知 1男 2女',
  `birthday` date DEFAULT NULL COMMENT '角色生日',
  `cv` varchar(100) DEFAULT NULL COMMENT '声优',
  `description` text COMMENT '角色简介',
  `sort_no` int(11) NOT NULL DEFAULT '0' COMMENT '角色主页排序，越小越靠前',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1正常 2隐藏',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ip_name` (`ip_id`,`name`),
  KEY `idx_ip` (`ip_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9002 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='IP角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ip_character`
--

LOCK TABLES `ip_character` WRITE;
/*!40000 ALTER TABLE `ip_character` DISABLE KEYS */;
INSERT INTO `ip_character` VALUES (1,1,'初音未来','Hatsune Miku',NULL,NULL,NULL,NULL,NULL,1,1,'2026-11-20 16:26:25','2026-11-20 16:26:25'),(2,2,'炭治郎','Tanjiro',NULL,NULL,NULL,NULL,NULL,1,1,'2026-11-20 16:26:25','2026-11-20 16:26:25');
/*!40000 ALTER TABLE `ip_character` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant`
--

DROP TABLE IF EXISTS `merchant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `merchant` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '商家ID',
  `shop_name` varchar(100) NOT NULL COMMENT '店铺名称',
  `owner_name` varchar(50) DEFAULT NULL COMMENT '经营者姓名',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '商家状态：1正常 2关店 3失联（触发赔付判断）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=9002 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchant`
--

LOCK TABLES `merchant` WRITE;
/*!40000 ALTER TABLE `merchant` DISABLE KEYS */;
INSERT INTO `merchant` VALUES (1,'谷子小铺','张三',NULL,1,'2026-11-20 16:26:25','2026-11-20 16:26:25'),(2,'二次元周边店','李四',NULL,1,'2026-11-20 16:26:25','2026-11-20 16:26:25');
/*!40000 ALTER TABLE `merchant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `minor_limit`
--

DROP TABLE IF EXISTS `minor_limit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `minor_limit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '限额ID',
  `user_id` bigint(20) NOT NULL COMMENT '实名未成年用户ID',
  `realname_status` tinyint(4) NOT NULL DEFAULT '2' COMMENT '实名状态：固定为2未成年',
  `single_limit` decimal(10,2) NOT NULL COMMENT '单笔消费限额（元）',
  `daily_limit` decimal(10,2) NOT NULL COMMENT '单日累计消费限额（元）',
  `daily_used` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '当日已消费（冗余计数，按日重置）',
  `limit_date` date NOT NULL COMMENT '统计日期，与daily_used配合每日清零',
  `verify_threshold` decimal(10,2) DEFAULT NULL COMMENT '触发监护人人脸验证的金额阈值',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1生效 2暂停',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user` (`user_id`),
  KEY `idx_limit_date` (`limit_date`),
  CONSTRAINT `fk_ml_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='未成年人消费限额表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `minor_limit`
--

LOCK TABLES `minor_limit` WRITE;
/*!40000 ALTER TABLE `minor_limit` DISABLE KEYS */;
/*!40000 ALTER TABLE `minor_limit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_item`
--

DROP TABLE IF EXISTS `order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `order_item` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID（SPU）',
  `goods_condition_rel_id` bigint(20) NOT NULL COMMENT '品相SKU_ID',
  `goods_name` varchar(200) NOT NULL COMMENT '商品名快照（下单时固化）',
  `condition_name` varchar(50) DEFAULT NULL COMMENT '品相名快照（下单时固化）',
  `ip_id` bigint(20) NOT NULL COMMENT 'IPID（冗余，供晒单/统计）',
  `character_id` bigint(20) NOT NULL COMMENT '角色ID（冗余，供晒单/统计）',
  `unit_price` decimal(10,2) NOT NULL COMMENT '成交单价（判断≥300的依据）',
  `quantity` int(11) NOT NULL DEFAULT '1' COMMENT '购买数量',
  `deposit_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '该明细分摊定金',
  `total_amount` decimal(10,2) NOT NULL COMMENT '该明细小计（unit_price*quantity）',
  `seal_video_required` tinyint(4) NOT NULL DEFAULT '0' COMMENT '该明细是否触发封箱视频',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`),
  KEY `idx_goods` (`goods_id`),
  KEY `idx_character` (`character_id`),
  KEY `fk_oi_sku` (`goods_condition_rel_id`),
  CONSTRAINT `fk_oi_goods` FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`),
  CONSTRAINT `fk_oi_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `fk_oi_sku` FOREIGN KEY (`goods_condition_rel_id`) REFERENCES `goods_condition_rel` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_item`
--

LOCK TABLES `order_item` WRITE;
/*!40000 ALTER TABLE `order_item` DISABLE KEYS */;
INSERT INTO `order_item` VALUES (1,1,1,1,'初音未来 限定吧唧',NULL,1,1,20.00,2,0.00,40.00,0,'2026-11-20 16:31:08'),(2,1,2,3,'炭治郎 亚克力立牌',NULL,2,2,50.00,1,0.00,50.00,0,'2026-11-20 16:31:08'),(3,2,1,1,'初音未来 限定吧唧',NULL,1,1,20.00,1,0.00,20.00,0,'2026-11-20 17:12:30'),(4,3,1,2,'初音未来 限定吧唧',NULL,1,1,18.00,1,0.00,18.00,0,'2026-11-25 14:42:57'),(5,4,2,3,'炭治郎 亚克力立牌',NULL,2,2,50.00,79,0.00,3950.00,0,'2026-11-25 15:20:47');
/*!40000 ALTER TABLE `order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_seal_video`
--

DROP TABLE IF EXISTS `order_seal_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `order_seal_video` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '视频存证ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID（与订单绑定）',
  `video_url` varchar(500) NOT NULL COMMENT '视频存储地址（OBS/OSS）',
  `video_sha256` varchar(64) NOT NULL COMMENT '视频文件SHA-256，防篡改存证',
  `duration_sec` int(11) DEFAULT NULL COMMENT '视频时长（秒）',
  `file_size` bigint(20) DEFAULT NULL COMMENT '文件大小（字节）',
  `recorded_at` datetime NOT NULL COMMENT '录制时间（发货前）',
  `operator_id` bigint(20) DEFAULT NULL COMMENT '录制操作人ID',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1有效 2作废',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order` (`order_id`),
  KEY `idx_sha` (`video_sha256`),
  CONSTRAINT `fk_seal_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='封箱视频存证表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_seal_video`
--

LOCK TABLES `order_seal_video` WRITE;
/*!40000 ALTER TABLE `order_seal_video` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_seal_video` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `orders` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` varchar(64) NOT NULL COMMENT '订单号（业务唯一）',
  `user_id` bigint(20) NOT NULL COMMENT '下单用户ID',
  `merchant_id` bigint(20) NOT NULL COMMENT '商家ID（冗余，便于赔付与对账）',
  `order_type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '订单类型：1现货 2预售定金',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '订单应付总额',
  `deposit_paid` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '已付定金合计',
  `balance_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '应付尾款合计',
  `balance_paid` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '已付尾款合计',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态：0待付定金 1定金已付待尾款 2已付全款待发货 3已发货 4已完成 5已取消 6已退款',
  `balance_due_time` datetime DEFAULT NULL COMMENT '尾款补款截止时间（下单时固化）',
  `extend_flag` tinyint(4) NOT NULL DEFAULT '0' COMMENT '尾款延期标记：0否 1是（规则2）',
  `extend_days` int(11) NOT NULL DEFAULT '0' COMMENT '已延期天数，上限3（规则2）',
  `is_high_value` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否高价单：明细单价≥300时为1',
  `seal_video_required` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否强制封箱视频：1是（规则3）',
  `receiver_name` varchar(50) DEFAULT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) DEFAULT NULL COMMENT '收货人电话',
  `receiver_address` varchar(500) DEFAULT NULL COMMENT '收货地址',
  `pay_time` datetime DEFAULT NULL COMMENT '全款付清时间',
  `delivery_time` datetime DEFAULT NULL COMMENT '发货时间',
  `complete_time` datetime DEFAULT NULL COMMENT '完成时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_status` (`user_id`,`status`),
  KEY `idx_merchant_status` (`merchant_id`,`status`),
  KEY `idx_created` (`created_at`),
  KEY `idx_balance_due` (`status`,`balance_due_time`),
  CONSTRAINT `fk_order_merchant` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`),
  CONSTRAINT `fk_order_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'OD17951634687939DCCE7',9002,1,1,90.00,0.00,90.00,90.00,2,NULL,0,0,0,0,'肖旭','13800000001','成都东软学院','2026-11-20 16:31:09',NULL,NULL,'2026-11-20 16:31:08','2026-11-20 16:31:08'),(2,'OD1795165950212425BB7',9004,1,1,20.00,0.00,20.00,20.00,2,NULL,0,0,0,0,'y7','1','1','2026-11-20 17:12:30',NULL,NULL,'2026-11-20 17:12:30','2026-11-20 17:12:30'),(3,'OD17955889770560C3639',9006,1,1,18.00,0.00,18.00,18.00,2,NULL,0,0,0,0,'icant','1','1','2026-11-25 14:42:57',NULL,NULL,'2026-11-25 14:42:57','2026-11-25 14:42:57'),(4,'OD1795591246976967C89',9002,2,1,3950.00,0.00,3950.00,3950.00,2,NULL,0,0,0,0,'xiaoxu','12','12','2026-11-25 15:20:47',NULL,NULL,'2026-11-25 15:20:46','2026-11-25 15:20:46');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `point_record`
--

DROP TABLE IF EXISTS `point_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `point_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '流水ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `change_type` tinyint(4) NOT NULL COMMENT '类型：1每日签到 2消费获得 3兑换抵扣 4积分过期 5后台调整 6邀请奖励',
  `points` int(11) NOT NULL COMMENT '变动积分，正数增加、负数减少',
  `balance_after` int(11) NOT NULL COMMENT '变动后余额，便于对账',
  `biz_type` varchar(30) DEFAULT NULL COMMENT '业务类型：signin/order/exchange/expire',
  `biz_no` varchar(64) DEFAULT NULL COMMENT '业务单号：签到写日期，消费写订单号',
  `remark` varchar(200) DEFAULT NULL COMMENT '说明，如"连续签到第3天 额外+5"',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_type` (`user_id`,`change_type`),
  KEY `idx_biz_no` (`biz_no`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `fk_pr_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='积分流水表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `point_record`
--

LOCK TABLES `point_record` WRITE;
/*!40000 ALTER TABLE `point_record` DISABLE KEYS */;
INSERT INTO `point_record` VALUES (7,9002,1,5,5,'signin','2026-11-20','连续签到第1天 +5','2026-11-20 16:31:02'),(8,9002,2,90,95,'order','OD17951634687939DCCE7','消费 90.00 元送积分','2026-11-20 16:31:08'),(9,9004,2,20,20,'order','OD1795165950212425BB7','消费 20.00 元送积分','2026-11-20 17:12:30'),(10,9006,2,18,18,'order','OD17955889770560C3639','消费 18.00 元送积分','2026-11-25 14:42:57'),(11,9002,2,3950,4045,'order','OD1795591246976967C89','消费 3950.00 元送积分','2026-11-25 15:20:47'),(12,9002,1,5,4050,'signin','2026-11-25','连续签到第1天 +5','2026-11-25 15:21:20');
/*!40000 ALTER TABLE `point_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `showcase`
--

DROP TABLE IF EXISTS `showcase`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `showcase` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '晒单ID',
  `user_id` bigint(20) NOT NULL COMMENT '发布用户ID',
  `order_item_id` bigint(20) DEFAULT NULL COMMENT '关联订单明细（可空，验货晒单）',
  `ip_id` bigint(20) NOT NULL COMMENT 'IPID',
  `character_id` bigint(20) NOT NULL COMMENT '角色ID（决定展示在哪个角色主页）',
  `scene_type` tinyint(4) NOT NULL COMMENT '场景类型：1痛包 2祭坛 3外拍',
  `title` varchar(100) DEFAULT NULL COMMENT '晒单标题',
  `content` text COMMENT '晒单正文',
  `cover_image` varchar(500) DEFAULT NULL COMMENT '封面图URL（冗余，取第一张）',
  `like_count` int(11) NOT NULL DEFAULT '0' COMMENT '点赞数（冗余计数）',
  `is_featured` tinyint(4) NOT NULL DEFAULT '0' COMMENT '角色主页精选：0否 1是',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1待审核 2已通过 3驳回',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_character_status` (`character_id`,`status`,`is_featured`),
  KEY `idx_user` (`user_id`),
  KEY `fk_show_item` (`order_item_id`),
  KEY `fk_show_ip` (`ip_id`),
  CONSTRAINT `fk_show_character` FOREIGN KEY (`character_id`) REFERENCES `ip_character` (`id`),
  CONSTRAINT `fk_show_ip` FOREIGN KEY (`ip_id`) REFERENCES `ip` (`id`),
  CONSTRAINT `fk_show_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_item` (`id`),
  CONSTRAINT `fk_show_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='晒单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `showcase`
--

LOCK TABLES `showcase` WRITE;
/*!40000 ALTER TABLE `showcase` DISABLE KEYS */;
/*!40000 ALTER TABLE `showcase` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `showcase_image`
--

DROP TABLE IF EXISTS `showcase_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `showcase_image` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '图片ID',
  `showcase_id` bigint(20) NOT NULL COMMENT '晒单ID',
  `image_url` varchar(500) NOT NULL COMMENT '图片URL',
  `sort_no` int(11) NOT NULL DEFAULT '0' COMMENT '展示顺序',
  `width` int(11) DEFAULT NULL COMMENT '图片宽度（像素）',
  `height` int(11) DEFAULT NULL COMMENT '图片高度（像素）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_showcase` (`showcase_id`),
  CONSTRAINT `fk_si_showcase` FOREIGN KEY (`showcase_id`) REFERENCES `showcase` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='晒单图片表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `showcase_image`
--

LOCK TABLES `showcase_image` WRITE;
/*!40000 ALTER TABLE `showcase_image` DISABLE KEYS */;
/*!40000 ALTER TABLE `showcase_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `signin_record`
--

DROP TABLE IF EXISTS `signin_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `signin_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '签到ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `sign_date` date NOT NULL COMMENT '签到日期',
  `continuous_days` int(11) NOT NULL DEFAULT '1' COMMENT '连续签到天数，断了重新从1算',
  `points_earned` int(11) NOT NULL DEFAULT '0' COMMENT '本次获得积分（含连续签到奖励）',
  `source` tinyint(4) NOT NULL DEFAULT '1' COMMENT '渠道：1APP 2小程序 3H5',
  `sign_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '签到时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`,`sign_date`),
  KEY `idx_date` (`sign_date`),
  CONSTRAINT `fk_sr_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='每日签到记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `signin_record`
--

LOCK TABLES `signin_record` WRITE;
/*!40000 ALTER TABLE `signin_record` DISABLE KEYS */;
INSERT INTO `signin_record` VALUES (4,9002,'2026-11-20',1,5,1,'2026-11-20 16:31:02'),(5,9002,'2026-11-25',1,5,1,'2026-11-25 15:21:20');
/*!40000 ALTER TABLE `signin_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_log`
--

DROP TABLE IF EXISTS `stock_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stock_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '流水ID',
  `sku_id` bigint(20) NOT NULL COMMENT 'SKU_ID（goods_condition_rel.id）',
  `change_type` tinyint(4) NOT NULL COMMENT '类型：1采购入库 2下单锁定 3发货出库 4取消释放 5盘点调整 6退货入库',
  `change_quantity` int(11) NOT NULL COMMENT '变动数量，正数为增加，负数为减少',
  `before_stock` int(11) NOT NULL COMMENT '变动前库存',
  `after_stock` int(11) NOT NULL COMMENT '变动后库存',
  `biz_type` varchar(30) DEFAULT NULL COMMENT '业务类型：order/refund/purchase/check',
  `biz_no` varchar(64) DEFAULT NULL COMMENT '业务单号（订单号/采购单号）',
  `operator_id` bigint(20) DEFAULT NULL COMMENT '操作人ID',
  `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
  PRIMARY KEY (`id`),
  KEY `idx_sku` (`sku_id`),
  KEY `idx_biz` (`biz_no`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `fk_sl_sku` FOREIGN KEY (`sku_id`) REFERENCES `goods_condition_rel` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='库存流水表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_log`
--

LOCK TABLES `stock_log` WRITE;
/*!40000 ALTER TABLE `stock_log` DISABLE KEYS */;
INSERT INTO `stock_log` VALUES (4,1,2,-2,100,98,'order','OD17951634687939DCCE7',9002,'下单锁定','2026-11-20 16:31:08'),(5,3,2,-1,80,79,'order','OD17951634687939DCCE7',9002,'下单锁定','2026-11-20 16:31:08'),(6,1,2,-1,98,97,'order','OD1795165950212425BB7',9004,'下单锁定','2026-11-20 17:12:30'),(7,2,2,-1,50,49,'order','OD17955889770560C3639',9006,'下单锁定','2026-11-25 14:42:57'),(8,3,2,-79,79,0,'order','OD1795591246976967C89',9002,'下单锁定','2026-11-25 15:20:47');
/*!40000 ALTER TABLE `stock_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '登录用户名',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `password_hash` varchar(255) NOT NULL COMMENT '密码哈希（bcrypt/argon2，禁止明文）',
  `realname_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '实名状态：0未实名 1成年 2未成年',
  `id_card_hash` varchar(255) DEFAULT NULL COMMENT '身份证号哈希（不可逆，仅用于关联校验）',
  `birth_date` date DEFAULT NULL COMMENT '出生日期，用于判定未成年',
  `avatar_url` varchar(500) DEFAULT NULL COMMENT '头像URL',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '账号状态：1正常 2禁用 3注销',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_realname_status` (`realname_status`)
) ENGINE=InnoDB AUTO_INCREMENT=9007 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (9002,'xiaoxu','13800000001',NULL,'e10adc3949ba59abbe56e057f20f883e',0,NULL,NULL,NULL,1,'2026-11-20 16:30:55','2026-11-20 16:30:55'),(9004,'y7','13458468470',NULL,'f379eaf3c831b04de153469d1bec345e',0,NULL,NULL,NULL,1,'2026-11-20 17:11:59','2026-11-20 17:11:59'),(9006,'icant','1',NULL,'f379eaf3c831b04de153469d1bec345e',0,NULL,NULL,NULL,1,'2026-11-25 14:40:26','2026-11-25 14:40:26');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_coupon`
--

DROP TABLE IF EXISTS `user_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `user_coupon` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户券ID',
  `user_id` bigint(20) NOT NULL COMMENT '领取用户ID',
  `template_id` bigint(20) NOT NULL COMMENT '券模板ID',
  `coupon_no` varchar(64) NOT NULL COMMENT '券码，展示给用户/核销用',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1未使用 2已使用 3已过期 4已作废',
  `receive_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
  `expire_time` datetime NOT NULL COMMENT '过期时间，领取时按valid_days算出',
  `use_time` datetime DEFAULT NULL COMMENT '使用时间',
  `order_id` bigint(20) DEFAULT NULL COMMENT '核销订单ID',
  `discount_amount` decimal(10,2) DEFAULT NULL COMMENT '实际优惠金额',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_coupon_no` (`coupon_no`),
  KEY `idx_user_status` (`user_id`,`status`,`expire_time`),
  KEY `idx_template` (`template_id`),
  KEY `idx_order` (`order_id`),
  CONSTRAINT `fk_uc_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `fk_uc_template` FOREIGN KEY (`template_id`) REFERENCES `coupon_template` (`id`),
  CONSTRAINT `fk_uc_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户消费券表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_coupon`
--

LOCK TABLES `user_coupon` WRITE;
/*!40000 ALTER TABLE `user_coupon` DISABLE KEYS */;
INSERT INTO `user_coupon` VALUES (4,9002,1,'CP10142EEF219C4893',1,'2026-11-20 16:31:02','2026-11-27 16:31:03',NULL,NULL,NULL,'2026-11-20 16:31:02','2026-11-20 16:31:02'),(5,9002,2,'CP296DF979E1F044D0',1,'2026-11-25 15:21:15','2026-12-02 15:21:16',NULL,NULL,NULL,'2026-11-25 15:21:15','2026-11-25 15:21:15'),(6,9002,1,'CP50295C0DD87846DD',1,'2026-11-25 15:21:16','2026-12-02 15:21:16',NULL,NULL,NULL,'2026-11-25 15:21:16','2026-11-25 15:21:16');
/*!40000 ALTER TABLE `user_coupon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_point_account`
--

DROP TABLE IF EXISTS `user_point_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `user_point_account` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '账户ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `balance` int(11) NOT NULL DEFAULT '0' COMMENT '当前可用积分',
  `frozen_point` int(11) NOT NULL DEFAULT '0' COMMENT '冻结积分（兑换中）',
  `total_earned` int(11) NOT NULL DEFAULT '0' COMMENT '累计获得积分',
  `total_used` int(11) NOT NULL DEFAULT '0' COMMENT '累计使用积分',
  `total_expired` int(11) NOT NULL DEFAULT '0' COMMENT '累计过期积分',
  `level` tinyint(4) NOT NULL DEFAULT '1' COMMENT '会员等级，按累计积分升级',
  `version` int(11) NOT NULL DEFAULT '0' COMMENT '乐观锁版本号，防止并发签到/兑换超扣',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user` (`user_id`),
  CONSTRAINT `fk_upa_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户积分账户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_point_account`
--

LOCK TABLES `user_point_account` WRITE;
/*!40000 ALTER TABLE `user_point_account` DISABLE KEYS */;
INSERT INTO `user_point_account` VALUES (4,9002,4050,0,4050,0,0,1,4,'2026-11-20 16:31:02','2026-11-25 15:21:20'),(5,9004,20,0,20,0,0,1,1,'2026-11-20 17:12:30','2026-11-20 17:12:30'),(6,9006,18,0,18,0,0,1,1,'2026-11-25 14:42:57','2026-11-25 14:42:57');
/*!40000 ALTER TABLE `user_point_account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_video`
--

DROP TABLE IF EXISTS `user_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `user_video` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '视频ID',
  `user_id` bigint(20) NOT NULL COMMENT '发布用户ID',
  `title` varchar(100) NOT NULL COMMENT '视频标题',
  `video_url` varchar(500) NOT NULL COMMENT '视频文件URL',
  `cover_url` varchar(500) DEFAULT NULL COMMENT '封面图URL',
  `description` varchar(500) DEFAULT NULL COMMENT '视频描述',
  `like_count` int(11) NOT NULL DEFAULT '0' COMMENT '点赞数',
  `view_count` int(11) NOT NULL DEFAULT '0' COMMENT '播放数',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态：1正常 2下架 3审核中',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `fk_uv_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户发布视频表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_video`
--

LOCK TABLES `user_video` WRITE;
/*!40000 ALTER TABLE `user_video` DISABLE KEYS */;
INSERT INTO `user_video` VALUES (1,9002,'我的第一个谷子视频','/videos/1795163475567_5c3840c0.mp4',NULL,'开箱啦',6,0,1,'2026-11-20 16:31:15','2026-11-26 11:29:12');
/*!40000 ALTER TABLE `user_video` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'xym-work'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-26 11:36:11
