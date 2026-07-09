/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 127.0.0.1    Database: dash_fastapi
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
-- Table structure for table `apscheduler_jobs`
--

DROP TABLE IF EXISTS `apscheduler_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `apscheduler_jobs` (
  `id` varchar(191) NOT NULL,
  `next_run_time` double DEFAULT NULL,
  `job_state` blob NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_apscheduler_jobs_next_run_time` (`next_run_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `apscheduler_jobs`
--

LOCK TABLES `apscheduler_jobs` WRITE;
/*!40000 ALTER TABLE `apscheduler_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `apscheduler_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table`
--

DROP TABLE IF EXISTS `gen_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table` (
  `table_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) DEFAULT NULL COMMENT '生成功能作者',
  `gen_type` char(1) DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='代码生成业务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table`
--

LOCK TABLES `gen_table` WRITE;
/*!40000 ALTER TABLE `gen_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table_column`
--

DROP TABLE IF EXISTS `gen_table_column`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table_column` (
  `column_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint(20) DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) DEFAULT '' COMMENT '字典类型',
  `sort` int(11) DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='代码生成业务表字段';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table_column`
--

LOCK TABLES `gen_table_column` WRITE;
/*!40000 ALTER TABLE `gen_table_column` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table_column` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_config`
--

DROP TABLE IF EXISTS `sys_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_config` (
  `config_id` int(5) NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='参数配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_config`
--

LOCK TABLES `sys_config` WRITE;
/*!40000 ALTER TABLE `sys_config` DISABLE KEYS */;
INSERT INTO `sys_config` VALUES
(1,'主框架页-默认皮肤样式名称','sys.index.skinName','skin-blue','Y','admin','2026-06-05 08:31:19','',NULL,'蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow'),
(2,'用户管理-账号初始密码','sys.user.initPassword','123456','Y','admin','2026-06-05 08:31:19','',NULL,'初始化密码 123456'),
(3,'主框架页-侧边栏主题','sys.index.sideTheme','theme-dark','Y','admin','2026-06-05 08:31:19','',NULL,'深色主题theme-dark，浅色主题theme-light'),
(4,'账号自助-验证码开关','sys.account.captchaEnabled','false','N','admin','2026-06-05 08:31:19','admin','2026-06-05 09:55:04','是否开启验证码功能（true开启，false关闭）'),
(5,'账号自助-是否开启用户注册功能','sys.account.registerUser','false','Y','admin','2026-06-05 08:31:19','',NULL,'是否开启注册用户功能（true开启，false关闭）'),
(6,'账号自助-是否开启忘记密码功能','sys.account.forgetUser','true','Y','admin','2026-06-05 08:31:19','',NULL,'是否开启忘记密码功能（true开启，false关闭）'),
(7,'用户登录-黑名单列表','sys.login.blackIPList','','Y','admin','2026-06-05 08:31:19','',NULL,'设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
/*!40000 ALTER TABLE `sys_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dept`
--

DROP TABLE IF EXISTS `sys_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dept` (
  `dept_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint(20) DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) DEFAULT '' COMMENT '部门名称',
  `order_num` int(4) DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `status` char(1) DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=200 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='部门表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dept`
--

LOCK TABLES `sys_dept` WRITE;
/*!40000 ALTER TABLE `sys_dept` DISABLE KEYS */;
INSERT INTO `sys_dept` VALUES
(100,0,'0','集团总公司',0,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-06-05 08:31:18','',NULL),
(101,100,'0,100','分公司',1,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-06-05 08:31:18','admin','2026-06-05 09:28:01'),
(102,100,'0,100','长沙分公司',2,'年糕','15888888888','niangao@qq.com','0','2','admin','2026-06-05 08:31:18',NULL,NULL),
(103,101,'0,100,101','管理部门',1,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-06-05 08:31:18','admin','2026-06-05 09:28:09'),
(104,101,'0,100,101','市场部门',2,'年糕','15888888888','niangao@qq.com','0','2','admin','2026-06-05 08:31:18',NULL,NULL),
(105,101,'0,100,101','测试部门',3,'年糕','15888888888','niangao@qq.com','0','2','admin','2026-06-05 08:31:18',NULL,NULL),
(106,101,'0,100,101','财务部门',4,'年糕','15888888888','niangao@qq.com','0','2','admin','2026-06-05 08:31:18',NULL,NULL),
(107,101,'0,100,101','运维部门',5,'年糕','15888888888','niangao@qq.com','0','2','admin','2026-06-05 08:31:18',NULL,NULL),
(108,102,'0,100,102','市场部门',1,'年糕','15888888888','niangao@qq.com','0','2','admin','2026-06-05 08:31:18',NULL,NULL),
(109,102,'0,100,102','财务部门',2,'年糕','15888888888','niangao@qq.com','0','2','admin','2026-06-05 08:31:18',NULL,NULL);
/*!40000 ALTER TABLE `sys_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_data`
--

DROP TABLE IF EXISTS `sys_dict_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_data` (
  `dict_code` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int(4) DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='字典数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_data`
--

LOCK TABLES `sys_dict_data` WRITE;
/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` VALUES
(1,1,'男','0','sys_user_sex','','','Y','0','admin','2026-06-05 08:31:19','',NULL,'性别男'),
(2,2,'女','1','sys_user_sex','','','N','0','admin','2026-06-05 08:31:19','',NULL,'性别女'),
(3,3,'未知','2','sys_user_sex','','','N','0','admin','2026-06-05 08:31:19','',NULL,'性别未知'),
(4,1,'显示','0','sys_show_hide','','primary','Y','0','admin','2026-06-05 08:31:19','',NULL,'显示菜单'),
(5,2,'隐藏','1','sys_show_hide','','danger','N','0','admin','2026-06-05 08:31:19','',NULL,'隐藏菜单'),
(6,1,'正常','0','sys_normal_disable','','primary','Y','0','admin','2026-06-05 08:31:19','',NULL,'正常状态'),
(7,2,'停用','1','sys_normal_disable','','danger','N','0','admin','2026-06-05 08:31:19','',NULL,'停用状态'),
(8,1,'正常','0','sys_job_status','','primary','Y','0','admin','2026-06-05 08:31:19','',NULL,'正常状态'),
(9,2,'暂停','1','sys_job_status','','danger','N','0','admin','2026-06-05 08:31:19','',NULL,'停用状态'),
(10,1,'默认','default','sys_job_group','','default','Y','0','admin','2026-06-05 08:31:19','',NULL,'默认分组'),
(11,2,'数据库','sqlalchemy','sys_job_group','','success','N','0','admin','2026-06-05 08:31:19','',NULL,'数据库分组'),
(12,3,'redis','redis','sys_job_group','','warning','N','0','admin','2026-06-05 08:31:19','',NULL,'reids分组'),
(13,1,'默认','default','sys_job_executor','','default','N','0','admin','2026-06-05 08:31:19','',NULL,'线程池'),
(14,2,'进程池','processpool','sys_job_executor','','primary','N','0','admin','2026-06-05 08:31:19','',NULL,'进程池'),
(15,1,'是','Y','sys_yes_no','','primary','Y','0','admin','2026-06-05 08:31:19','',NULL,'系统默认是'),
(16,2,'否','N','sys_yes_no','','danger','N','0','admin','2026-06-05 08:31:19','',NULL,'系统默认否'),
(17,1,'通知','1','sys_notice_type','','warning','Y','0','admin','2026-06-05 08:31:19','',NULL,'通知'),
(18,2,'公告','2','sys_notice_type','','success','N','0','admin','2026-06-05 08:31:19','',NULL,'公告'),
(19,1,'正常','0','sys_notice_status','','primary','Y','0','admin','2026-06-05 08:31:19','',NULL,'正常状态'),
(20,2,'关闭','1','sys_notice_status','','danger','N','0','admin','2026-06-05 08:31:19','',NULL,'关闭状态'),
(21,99,'其他','0','sys_oper_type','','info','N','0','admin','2026-06-05 08:31:19','',NULL,'其他操作'),
(22,1,'新增','1','sys_oper_type','','info','N','0','admin','2026-06-05 08:31:19','',NULL,'新增操作'),
(23,2,'修改','2','sys_oper_type','','info','N','0','admin','2026-06-05 08:31:19','',NULL,'修改操作'),
(24,3,'删除','3','sys_oper_type','','danger','N','0','admin','2026-06-05 08:31:19','',NULL,'删除操作'),
(25,4,'授权','4','sys_oper_type','','primary','N','0','admin','2026-06-05 08:31:19','',NULL,'授权操作'),
(26,5,'导出','5','sys_oper_type','','warning','N','0','admin','2026-06-05 08:31:19','',NULL,'导出操作'),
(27,6,'导入','6','sys_oper_type','','warning','N','0','admin','2026-06-05 08:31:19','',NULL,'导入操作'),
(28,7,'强退','7','sys_oper_type','','danger','N','0','admin','2026-06-05 08:31:19','',NULL,'强退操作'),
(29,8,'生成代码','8','sys_oper_type','','warning','N','0','admin','2026-06-05 08:31:19','',NULL,'生成操作'),
(30,9,'清空数据','9','sys_oper_type','','danger','N','0','admin','2026-06-05 08:31:19','',NULL,'清空操作'),
(31,1,'成功','0','sys_common_status','','primary','N','0','admin','2026-06-05 08:31:19','',NULL,'正常状态'),
(32,2,'失败','1','sys_common_status','','danger','N','0','admin','2026-06-05 08:31:19','',NULL,'停用状态');
/*!40000 ALTER TABLE `sys_dict_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_type`
--

DROP TABLE IF EXISTS `sys_dict_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_type` (
  `dict_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) DEFAULT '' COMMENT '字典类型',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`),
  UNIQUE KEY `dict_type` (`dict_type`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='字典类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_type`
--

LOCK TABLES `sys_dict_type` WRITE;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` VALUES
(1,'用户性别','sys_user_sex','0','admin','2026-06-05 08:31:19','',NULL,'用户性别列表'),
(2,'菜单状态','sys_show_hide','0','admin','2026-06-05 08:31:19','',NULL,'菜单状态列表'),
(3,'系统开关','sys_normal_disable','0','admin','2026-06-05 08:31:19','',NULL,'系统开关列表'),
(4,'任务状态','sys_job_status','0','admin','2026-06-05 08:31:19','',NULL,'任务状态列表'),
(5,'任务分组','sys_job_group','0','admin','2026-06-05 08:31:19','',NULL,'任务分组列表'),
(6,'任务执行器','sys_job_executor','0','admin','2026-06-05 08:31:19','',NULL,'任务执行器列表'),
(7,'系统是否','sys_yes_no','0','admin','2026-06-05 08:31:19','',NULL,'系统是否列表'),
(8,'通知类型','sys_notice_type','0','admin','2026-06-05 08:31:19','',NULL,'通知类型列表'),
(9,'通知状态','sys_notice_status','0','admin','2026-06-05 08:31:19','',NULL,'通知状态列表'),
(10,'操作类型','sys_oper_type','0','admin','2026-06-05 08:31:19','',NULL,'操作类型列表'),
(11,'系统状态','sys_common_status','0','admin','2026-06-05 08:31:19','',NULL,'登录状态列表');
/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_job`
--

DROP TABLE IF EXISTS `sys_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_job` (
  `job_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) NOT NULL DEFAULT 'default' COMMENT '任务组名',
  `job_executor` varchar(64) DEFAULT 'default' COMMENT '任务执行器',
  `invoke_target` varchar(500) NOT NULL COMMENT '调用目标字符串',
  `job_args` varchar(255) DEFAULT '' COMMENT '位置参数',
  `job_kwargs` varchar(255) DEFAULT '' COMMENT '关键字参数',
  `cron_expression` varchar(255) DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`,`job_name`,`job_group`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='定时任务调度表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_job`
--

LOCK TABLES `sys_job` WRITE;
/*!40000 ALTER TABLE `sys_job` DISABLE KEYS */;
INSERT INTO `sys_job` VALUES
(1,'系统默认（无参）','default','default','module_task.scheduler_test.job',NULL,NULL,'0/10 * * * * ?','3','1','1','admin','2026-06-05 08:31:19','',NULL,''),
(2,'系统默认（有参）','default','default','module_task.scheduler_test.job','test',NULL,'0/15 * * * * ?','3','1','1','admin','2026-06-05 08:31:19','',NULL,''),
(3,'系统默认（多参）','default','default','module_task.scheduler_test.job','new','{\"test\": 111}','0/20 * * * * ?','3','1','1','admin','2026-06-05 08:31:19','',NULL,'');
/*!40000 ALTER TABLE `sys_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_job_log`
--

DROP TABLE IF EXISTS `sys_job_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_job_log` (
  `job_log_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) NOT NULL COMMENT '任务组名',
  `job_executor` varchar(64) NOT NULL COMMENT '任务执行器',
  `invoke_target` varchar(500) NOT NULL COMMENT '调用目标字符串',
  `job_args` varchar(255) DEFAULT '' COMMENT '位置参数',
  `job_kwargs` varchar(255) DEFAULT '' COMMENT '关键字参数',
  `job_trigger` varchar(255) DEFAULT '' COMMENT '任务触发器',
  `job_message` varchar(500) DEFAULT NULL COMMENT '日志信息',
  `status` char(1) DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) DEFAULT '' COMMENT '异常信息',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='定时任务调度日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_job_log`
--

LOCK TABLES `sys_job_log` WRITE;
/*!40000 ALTER TABLE `sys_job_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_job_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_logininfor`
--

DROP TABLE IF EXISTS `sys_logininfor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_logininfor` (
  `info_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) DEFAULT '' COMMENT '操作系统',
  `status` char(1) DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) DEFAULT '' COMMENT '提示消息',
  `login_time` datetime DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`),
  KEY `idx_sys_logininfor_s` (`status`),
  KEY `idx_sys_logininfor_lt` (`login_time`)
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统访问记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_logininfor`
--

LOCK TABLES `sys_logininfor` WRITE;
/*!40000 ALTER TABLE `sys_logininfor` DISABLE KEYS */;
INSERT INTO `sys_logininfor` VALUES
(100,'admin','','未知','Python Requests 2','Other','1','验证码错误','2026-06-05 08:31:53'),
(101,'admin','','未知','Python Requests 2','Other','1','验证码错误','2026-06-05 08:31:56'),
(102,'admin','10.100.1.254','未知','Chrome 135','Windows 10','0','登录成功','2026-06-05 08:33:05'),
(103,'admin','','未知','Python Requests 2','Other','1','验证码错误','2026-06-05 09:35:40'),
(104,'admin','','未知','Python Requests 2','Other','1','验证码错误','2026-06-05 09:35:44'),
(105,'admin','','未知','Python Requests 2','Other','1','验证码错误','2026-06-05 09:52:29'),
(106,'admin','','未知','Python Requests 2','Other','1','验证码错误','2026-06-05 09:55:14'),
(107,'admin','','未知','Python Requests 2','Other','1','验证码错误','2026-06-05 09:55:17'),
(108,'admin','','未知','Python Requests 2','Other','0','登录成功','2026-06-05 09:56:25'),
(109,'admin','10.100.1.254','未知','Chrome 135','Windows 10','0','登录成功','2026-06-08 00:55:16');
/*!40000 ALTER TABLE `sys_logininfor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_menu`
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `menu_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) NOT NULL COMMENT '菜单名称',
  `parent_id` bigint(20) DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int(4) DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) DEFAULT '' COMMENT '路由名称',
  `is_frame` int(1) DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int(1) DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2009 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜单权限表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES
(1,'系统管理',0,1,'system',NULL,'','',1,0,'M','0','0','','antd-setting','admin','2026-06-05 08:31:18','',NULL,'系统管理目录'),
(100,'用户管理',1,1,'user','system.user','','',1,0,'C','0','0','system:user:list','antd-user','admin','2026-06-05 08:31:18','',NULL,'用户管理菜单'),
(101,'角色管理',1,2,'role','system.role','','',1,0,'C','0','0','system:role:list','antd-team','admin','2026-06-05 08:31:18','',NULL,'角色管理菜单'),
(102,'菜单管理',1,3,'menu','system.menu','','',1,0,'C','1','0','system:menu:list','antd-app-store-add','admin','2026-06-05 08:31:18','',NULL,'菜单管理菜单'),
(103,'部门管理',1,4,'dept','system.dept','','',1,0,'C','0','0','system:dept:list','antd-cluster','admin','2026-06-05 08:31:18','',NULL,'部门管理菜单'),
(104,'岗位管理',1,5,'post','system.post','','',1,0,'C','0','0','system:post:list','antd-idcard','admin','2026-06-05 08:31:18','',NULL,'岗位管理菜单'),
(106,'参数设置',1,7,'config','system.config','','',1,0,'C','0','0','system:config:list','antd-calculator','admin','2026-06-05 08:31:18','',NULL,'参数设置菜单'),
(108,'日志管理',1,9,'log','','','',1,0,'M','0','0','','antd-bug','admin','2026-06-05 08:31:18','',NULL,'日志管理菜单'),
(500,'操作日志',108,1,'operlog','monitor.operlog','','',1,0,'C','0','0','monitor:operlog:list','antd-clear','admin','2026-06-05 08:31:18','',NULL,'操作日志菜单'),
(501,'登录日志',108,2,'logininfor','monitor.logininfor','','',1,0,'C','0','0','monitor:logininfor:list','antd-control','admin','2026-06-05 08:31:18','',NULL,'登录日志菜单'),
(1000,'用户查询',100,1,'','','','',1,0,'F','0','0','system:user:query','#','admin','2026-06-05 08:31:18','',NULL,''),
(1001,'用户新增',100,2,'','','','',1,0,'F','0','0','system:user:add','#','admin','2026-06-05 08:31:18','',NULL,''),
(1002,'用户修改',100,3,'','','','',1,0,'F','0','0','system:user:edit','#','admin','2026-06-05 08:31:18','',NULL,''),
(1003,'用户删除',100,4,'','','','',1,0,'F','0','0','system:user:remove','#','admin','2026-06-05 08:31:18','',NULL,''),
(1004,'用户导出',100,5,'','','','',1,0,'F','0','0','system:user:export','#','admin','2026-06-05 08:31:18','',NULL,''),
(1005,'用户导入',100,6,'','','','',1,0,'F','0','0','system:user:import','#','admin','2026-06-05 08:31:18','',NULL,''),
(1006,'重置密码',100,7,'','','','',1,0,'F','0','0','system:user:resetPwd','#','admin','2026-06-05 08:31:18','',NULL,''),
(1007,'角色查询',101,1,'','','','',1,0,'F','0','0','system:role:query','#','admin','2026-06-05 08:31:18','',NULL,''),
(1008,'角色新增',101,2,'','','','',1,0,'F','0','0','system:role:add','#','admin','2026-06-05 08:31:18','',NULL,''),
(1009,'角色修改',101,3,'','','','',1,0,'F','0','0','system:role:edit','#','admin','2026-06-05 08:31:18','',NULL,''),
(1010,'角色删除',101,4,'','','','',1,0,'F','0','0','system:role:remove','#','admin','2026-06-05 08:31:18','',NULL,''),
(1011,'角色导出',101,5,'','','','',1,0,'F','0','0','system:role:export','#','admin','2026-06-05 08:31:18','',NULL,''),
(1012,'菜单查询',102,1,'','','','',1,0,'F','0','0','system:menu:query','#','admin','2026-06-05 08:31:18','',NULL,''),
(1013,'菜单新增',102,2,'','','','',1,0,'F','0','0','system:menu:add','#','admin','2026-06-05 08:31:18','',NULL,''),
(1014,'菜单修改',102,3,'','','','',1,0,'F','0','0','system:menu:edit','#','admin','2026-06-05 08:31:18','',NULL,''),
(1015,'菜单删除',102,4,'','','','',1,0,'F','0','0','system:menu:remove','#','admin','2026-06-05 08:31:18','',NULL,''),
(1016,'部门查询',103,1,'','','','',1,0,'F','0','0','system:dept:query','#','admin','2026-06-05 08:31:18','',NULL,''),
(1017,'部门新增',103,2,'','','','',1,0,'F','0','0','system:dept:add','#','admin','2026-06-05 08:31:18','',NULL,''),
(1018,'部门修改',103,3,'','','','',1,0,'F','0','0','system:dept:edit','#','admin','2026-06-05 08:31:18','',NULL,''),
(1019,'部门删除',103,4,'','','','',1,0,'F','0','0','system:dept:remove','#','admin','2026-06-05 08:31:18','',NULL,''),
(1020,'岗位查询',104,1,'','','','',1,0,'F','0','0','system:post:query','#','admin','2026-06-05 08:31:18','',NULL,''),
(1021,'岗位新增',104,2,'','','','',1,0,'F','0','0','system:post:add','#','admin','2026-06-05 08:31:18','',NULL,''),
(1022,'岗位修改',104,3,'','','','',1,0,'F','0','0','system:post:edit','#','admin','2026-06-05 08:31:18','',NULL,''),
(1023,'岗位删除',104,4,'','','','',1,0,'F','0','0','system:post:remove','#','admin','2026-06-05 08:31:18','',NULL,''),
(1024,'岗位导出',104,5,'','','','',1,0,'F','0','0','system:post:export','#','admin','2026-06-05 08:31:18','',NULL,''),
(1030,'参数查询',106,1,'#','','','',1,0,'F','0','0','system:config:query','#','admin','2026-06-05 08:31:18','',NULL,''),
(1031,'参数新增',106,2,'#','','','',1,0,'F','0','0','system:config:add','#','admin','2026-06-05 08:31:18','',NULL,''),
(1032,'参数修改',106,3,'#','','','',1,0,'F','0','0','system:config:edit','#','admin','2026-06-05 08:31:18','',NULL,''),
(1033,'参数删除',106,4,'#','','','',1,0,'F','0','0','system:config:remove','#','admin','2026-06-05 08:31:18','',NULL,''),
(1034,'参数导出',106,5,'#','','','',1,0,'F','0','0','system:config:export','#','admin','2026-06-05 08:31:18','',NULL,''),
(1039,'操作查询',500,1,'#','','','',1,0,'F','0','0','monitor:operlog:query','#','admin','2026-06-05 08:31:18','',NULL,''),
(1040,'操作删除',500,2,'#','','','',1,0,'F','0','0','monitor:operlog:remove','#','admin','2026-06-05 08:31:18','',NULL,''),
(1041,'日志导出',500,3,'#','','','',1,0,'F','0','0','monitor:operlog:export','#','admin','2026-06-05 08:31:18','',NULL,''),
(1042,'登录查询',501,1,'#','','','',1,0,'F','0','0','monitor:logininfor:query','#','admin','2026-06-05 08:31:18','',NULL,''),
(1043,'登录删除',501,2,'#','','','',1,0,'F','0','0','monitor:logininfor:remove','#','admin','2026-06-05 08:31:18','',NULL,''),
(1044,'日志导出',501,3,'#','','','',1,0,'F','0','0','monitor:logininfor:export','#','admin','2026-06-05 08:31:18','',NULL,''),
(1045,'账户解锁',501,4,'#','','','',1,0,'F','0','0','monitor:logininfor:unlock','#','admin','2026-06-05 08:31:18','',NULL,''),
(2000,'预警控制',0,5,'warning',NULL,NULL,'',1,0,'M','1','0',NULL,'antd-warning','admin','2026-06-05 09:40:10','',NULL,''),
(2004,'预警处置控制',2000,3,'',NULL,NULL,'',1,0,'F','0','0','warning:dispose:control','#','admin','2026-06-05 09:43:32','',NULL,''),
(2006,'预警列表',2000,1,'',NULL,'','',0,1,'F','0','0','warning:list:list','#','admin','2026-06-08 01:16:59','',NULL,''),
(2007,'预警沟通',2000,2,'',NULL,'','',0,1,'F','0','0','warning:communicate:list','#','admin','2026-06-08 01:16:59','',NULL,''),
(2008,'预警处置',2000,4,'',NULL,'','',0,1,'F','0','0','warning:dispose:list','#','admin','2026-06-08 01:16:59','',NULL,'');
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_notice`
--

DROP TABLE IF EXISTS `sys_notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_notice` (
  `notice_id` int(4) NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(100) NOT NULL COMMENT '公告标题',
  `notice_type` char(1) NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob DEFAULT NULL COMMENT '公告内容',
  `status` char(1) DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知公告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_notice`
--

LOCK TABLES `sys_notice` WRITE;
/*!40000 ALTER TABLE `sys_notice` DISABLE KEYS */;
INSERT INTO `sys_notice` VALUES
(1,'温馨提醒：2018-07-01 vfadmin新版本发布啦','2','新版本内容','0','admin','2026-06-05 08:31:19','',NULL,'管理员'),
(2,'维护通知：2018-07-01 vfadmin系统凌晨维护','1','维护内容','0','admin','2026-06-05 08:31:19','',NULL,'管理员');
/*!40000 ALTER TABLE `sys_notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_oper_log`
--

DROP TABLE IF EXISTS `sys_oper_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_oper_log` (
  `oper_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) DEFAULT '' COMMENT '模块标题',
  `business_type` int(2) DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(100) DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) DEFAULT '' COMMENT '请求方式',
  `operator_type` int(1) DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) DEFAULT '' COMMENT '返回参数',
  `status` int(1) DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint(20) DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`),
  KEY `idx_sys_oper_log_bt` (`business_type`),
  KEY `idx_sys_oper_log_s` (`status`),
  KEY `idx_sys_oper_log_ot` (`oper_time`)
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_oper_log`
--

LOCK TABLES `sys_oper_log` WRITE;
/*!40000 ALTER TABLE `sys_oper_log` DISABLE KEYS */;
INSERT INTO `sys_oper_log` VALUES
(100,'部门管理',3,'module_admin/controller/dept_controller.delete_system_dept()','DELETE',1,'admin','研发部门','/system/dept/101','10.100.1.254','未知','{\"dept_ids\": \"101\"}','{\"code\": 601, \"msg\": \"存在下级部门,不允许删除\", \"success\": false, \"time\": \"2026-06-05T08:34:40.288231\"}',1,'存在下级部门,不允许删除','2026-06-05 08:34:40',0),
(101,'部门管理',3,'module_admin/controller/dept_controller.delete_system_dept()','DELETE',1,'admin','研发部门','/system/dept/101','10.100.1.254','未知','{\"dept_ids\": \"101\"}','{\"code\": 601, \"msg\": \"存在下级部门,不允许删除\", \"success\": false, \"time\": \"2026-06-05T08:34:43.930054\"}',1,'存在下级部门,不允许删除','2026-06-05 08:34:43',0),
(102,'部门管理',3,'module_admin/controller/dept_controller.delete_system_dept()','DELETE',1,'admin','研发部门','/system/dept/103','10.100.1.254','未知','{\"dept_ids\": \"103\"}','{\"code\": 601, \"msg\": \"部门存在用户,不允许删除\", \"success\": false, \"time\": \"2026-06-05T08:34:46.660447\"}',1,'部门存在用户,不允许删除','2026-06-05 08:34:46',1),
(103,'部门管理',3,'module_admin/controller/dept_controller.delete_system_dept()','DELETE',1,'admin','研发部门','/system/dept/107','10.100.1.254','未知','{\"dept_ids\": \"107\"}','{\"code\": 200, \"msg\": \"删除成功\", \"success\": true, \"time\": \"2026-06-05T08:35:01.572547\"}',0,'','2026-06-05 08:35:01',1),
(104,'部门管理',3,'module_admin/controller/dept_controller.delete_system_dept()','DELETE',1,'admin','研发部门','/system/dept/106','10.100.1.254','未知','{\"dept_ids\": \"106\"}','{\"code\": 200, \"msg\": \"删除成功\", \"success\": true, \"time\": \"2026-06-05T08:35:04.665692\"}',0,'','2026-06-05 08:35:04',1),
(105,'部门管理',3,'module_admin/controller/dept_controller.delete_system_dept()','DELETE',1,'admin','研发部门','/system/dept/105','10.100.1.254','未知','{\"dept_ids\": \"105\"}','{\"code\": 601, \"msg\": \"部门存在用户,不允许删除\", \"success\": false, \"time\": \"2026-06-05T08:35:08.541038\"}',1,'部门存在用户,不允许删除','2026-06-05 08:35:08',0),
(106,'用户管理',3,'module_admin/controller/user_controller.delete_system_user()','DELETE',1,'admin','研发部门','/system/user/2','10.100.1.254','未知','{\"user_ids\": \"2\"}','{\"code\": 200, \"msg\": \"删除成功\", \"success\": true, \"time\": \"2026-06-05T08:35:25.130979\"}',0,'','2026-06-05 08:35:25',1),
(107,'用户管理',3,'module_admin/controller/user_controller.delete_system_user()','DELETE',1,'admin','研发部门','/system/user/1','10.100.1.254','未知','{\"user_ids\": \"1\"}','{\"code\": 500, \"msg\": \"不允许操作超级管理员用户\", \"success\": false, \"time\": \"2026-06-05T08:35:38.002193\"}',1,'不允许操作超级管理员用户','2026-06-05 08:35:38',0),
(108,'部门管理',3,'module_admin/controller/dept_controller.delete_system_dept()','DELETE',1,'admin','研发部门','/system/dept/105','10.100.1.254','未知','{\"dept_ids\": \"105\"}','{\"code\": 200, \"msg\": \"删除成功\", \"success\": true, \"time\": \"2026-06-05T08:37:57.172436\"}',0,'','2026-06-05 08:37:57',1),
(109,'部门管理',3,'module_admin/controller/dept_controller.delete_system_dept()','DELETE',1,'admin','研发部门','/system/dept/104','10.100.1.254','未知','{\"dept_ids\": \"104\"}','{\"code\": 200, \"msg\": \"删除成功\", \"success\": true, \"time\": \"2026-06-05T08:38:00.385848\"}',0,'','2026-06-05 08:38:00',1),
(110,'部门管理',3,'module_admin/controller/dept_controller.delete_system_dept()','DELETE',1,'admin','研发部门','/system/dept/109','10.100.1.254','未知','{\"dept_ids\": \"109\"}','{\"code\": 200, \"msg\": \"删除成功\", \"success\": true, \"time\": \"2026-06-05T08:38:03.558675\"}',0,'','2026-06-05 08:38:03',1),
(111,'部门管理',3,'module_admin/controller/dept_controller.delete_system_dept()','DELETE',1,'admin','研发部门','/system/dept/108','10.100.1.254','未知','{\"dept_ids\": \"108\"}','{\"code\": 200, \"msg\": \"删除成功\", \"success\": true, \"time\": \"2026-06-05T08:38:06.103878\"}',0,'','2026-06-05 08:38:06',1),
(112,'部门管理',3,'module_admin/controller/dept_controller.delete_system_dept()','DELETE',1,'admin','研发部门','/system/dept/102','10.100.1.254','未知','{\"dept_ids\": \"102\"}','{\"code\": 200, \"msg\": \"删除成功\", \"success\": true, \"time\": \"2026-06-05T08:38:08.846368\"}',0,'','2026-06-05 08:38:08',1),
(113,'用户管理',2,'module_admin/controller/user_controller.edit_system_user()','PUT',1,'admin','研发部门','/system/user','10.100.1.254','未知','{\"user_id\": 1, \"dept_id\": \"100\", \"user_name\": \"admin\", \"nick_name\": \"超级管理员\", \"user_type\": \"00\", \"email\": \"niangao@163.com\", \"phonenumber\": \"15888888888\", \"sex\": \"1\", \"avatar\": \"\", \"password\": \"$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2\", \"status\": \"0\", \"del_flag\": \"0\", \"login_ip\": \"127.0.0.1\", \"login_date\": \"2026-06-05T08:33:05\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null, \"remark\": \"管理员\", \"admin\": true, \"post_ids\": [1], \"role_ids\": [1], \"dept\": {\"dept_id\": 103, \"parent_id\": 101, \"ancestors\": \"0,100,101\", \"dept_name\": \"研发部门\", \"order_num\": 1, \"leader\": \"年糕\", \"phone\": \"15888888888\", \"email\": \"niangao@qq.com\", \"status\": \"0\", \"del_flag\": \"0\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null}, \"role\": []}','{\"code\": 500, \"msg\": \"不允许操作超级管理员用户\", \"success\": false, \"time\": \"2026-06-05T09:15:13.188953\"}',1,'不允许操作超级管理员用户','2026-06-05 09:15:13',0),
(114,'用户管理',2,'module_admin/controller/user_controller.edit_system_user()','PUT',1,'admin','研发部门','/system/user','10.100.1.254','未知','{\"user_id\": 1, \"dept_id\": \"100\", \"user_name\": \"admin\", \"nick_name\": \"超级管理员\", \"user_type\": \"00\", \"email\": \"niangao@163.com\", \"phonenumber\": \"15888888888\", \"sex\": \"0\", \"avatar\": \"\", \"password\": \"$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2\", \"status\": \"0\", \"del_flag\": \"0\", \"login_ip\": \"127.0.0.1\", \"login_date\": \"2026-06-05T08:33:05\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null, \"remark\": \"管理员\", \"admin\": true, \"post_ids\": [1], \"role_ids\": [1], \"dept\": {\"dept_id\": 103, \"parent_id\": 101, \"ancestors\": \"0,100,101\", \"dept_name\": \"研发部门\", \"order_num\": 1, \"leader\": \"年糕\", \"phone\": \"15888888888\", \"email\": \"niangao@qq.com\", \"status\": \"0\", \"del_flag\": \"0\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null}, \"role\": []}','{\"code\": 500, \"msg\": \"不允许操作超级管理员用户\", \"success\": false, \"time\": \"2026-06-05T09:15:34.906271\"}',1,'不允许操作超级管理员用户','2026-06-05 09:15:34',0),
(115,'用户管理',2,'module_admin/controller/user_controller.edit_system_user()','PUT',1,'admin','研发部门','/system/user','10.100.1.254','未知','{\"user_id\": 1, \"dept_id\": \"100\", \"user_name\": \"admin\", \"nick_name\": \"超级管理员\", \"user_type\": \"00\", \"email\": \"niangao@163.com\", \"phonenumber\": \"15888888888\", \"sex\": \"0\", \"avatar\": \"\", \"password\": \"$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2\", \"status\": \"0\", \"del_flag\": \"0\", \"login_ip\": \"127.0.0.1\", \"login_date\": \"2026-06-05T08:33:05\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null, \"remark\": \"管理员\", \"admin\": true, \"post_ids\": [1], \"role_ids\": [1], \"dept\": {\"dept_id\": 103, \"parent_id\": 101, \"ancestors\": \"0,100,101\", \"dept_name\": \"研发部门\", \"order_num\": 1, \"leader\": \"年糕\", \"phone\": \"15888888888\", \"email\": \"niangao@qq.com\", \"status\": \"0\", \"del_flag\": \"0\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null}, \"role\": []}','{\"code\": 500, \"msg\": \"不允许操作超级管理员用户\", \"success\": false, \"time\": \"2026-06-05T09:15:36.494721\"}',1,'不允许操作超级管理员用户','2026-06-05 09:15:36',0),
(116,'岗位管理',3,'module_admin/controller/post_controler.delete_system_post()','DELETE',1,'admin','研发部门','/system/post/3','10.100.1.254','未知','{\"post_ids\": \"3\"}','{\"code\": 200, \"msg\": \"删除成功\", \"success\": true, \"time\": \"2026-06-05T09:16:07.544388\"}',0,'','2026-06-05 09:16:07',1),
(117,'岗位管理',2,'module_admin/controller/post_controler.edit_system_post()','PUT',1,'admin','研发部门','/system/post','10.100.1.254','未知','{\"post_id\": 2, \"post_code\": \"se\", \"post_name\": \"管理经理\", \"post_sort\": 2, \"status\": \"0\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null, \"remark\": \"\"}','{\"code\": 200, \"msg\": \"更新成功\", \"success\": true, \"time\": \"2026-06-05T09:16:29.446209\"}',0,'','2026-06-05 09:16:29',2),
(118,'部门管理',2,'module_admin/controller/dept_controller.edit_system_dept()','PUT',1,'admin','研发部门','/system/dept','10.100.1.254','未知','{\"dept_id\": 103, \"parent_id\": 101, \"ancestors\": \"0,100,101\", \"dept_name\": \"研发部门\", \"order_num\": 1, \"leader\": \"年糕\", \"phone\": \"15888888888\", \"email\": \"niangao@qq.com\", \"status\": \"0\", \"del_flag\": \"0\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null}','{\"code\": 200, \"msg\": \"更新成功\", \"success\": true, \"time\": \"2026-06-05T09:16:52.519079\"}',0,'','2026-06-05 09:16:52',3),
(119,'部门管理',2,'module_admin/controller/dept_controller.edit_system_dept()','PUT',1,'admin','研发部门','/system/dept','10.100.1.254','未知','{\"dept_id\": 101, \"parent_id\": 100, \"ancestors\": \"0,100\", \"dept_name\": \"分公司\", \"order_num\": 1, \"leader\": \"年糕\", \"phone\": \"15888888888\", \"email\": \"niangao@qq.com\", \"status\": \"0\", \"del_flag\": \"0\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null}','{\"code\": 200, \"msg\": \"更新成功\", \"success\": true, \"time\": \"2026-06-05T09:28:01.605888\"}',0,'','2026-06-05 09:28:01',3),
(120,'部门管理',2,'module_admin/controller/dept_controller.edit_system_dept()','PUT',1,'admin','管理部门','/system/dept','10.100.1.254','未知','{\"dept_id\": 103, \"parent_id\": 101, \"ancestors\": \"0,100,101\", \"dept_name\": \"管理部门\", \"order_num\": 1, \"leader\": \"年糕\", \"phone\": \"15888888888\", \"email\": \"niangao@qq.com\", \"status\": \"0\", \"del_flag\": \"0\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"admin\", \"update_time\": \"2026-06-05T09:16:52\"}','{\"code\": 200, \"msg\": \"更新成功\", \"success\": true, \"time\": \"2026-06-05T09:28:09.513237\"}',0,'','2026-06-05 09:28:09',2),
(121,'用户管理',2,'module_admin/controller/user_controller.edit_system_user()','PUT',1,'admin','管理部门','/system/user','10.100.1.254','未知','{\"user_id\": 1, \"dept_id\": 103, \"user_name\": \"admin\", \"nick_name\": \"超级管理员\", \"user_type\": \"00\", \"email\": \"niangao@163.com\", \"phonenumber\": \"15888888888\", \"sex\": \"1\", \"avatar\": \"\", \"password\": \"$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2\", \"status\": \"0\", \"del_flag\": \"0\", \"login_ip\": \"127.0.0.1\", \"login_date\": \"2026-06-05T08:33:05\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null, \"remark\": \"管理员\", \"admin\": true, \"post_ids\": [1], \"role_ids\": [1], \"dept\": {\"dept_id\": 103, \"parent_id\": 101, \"ancestors\": \"0,100,101\", \"dept_name\": \"管理部门\", \"order_num\": 1, \"leader\": \"年糕\", \"phone\": \"15888888888\", \"email\": \"niangao@qq.com\", \"status\": \"0\", \"del_flag\": \"0\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"admin\", \"update_time\": \"2026-06-05T09:28:09\"}, \"role\": []}','{\"code\": 500, \"msg\": \"不允许操作超级管理员用户\", \"success\": false, \"time\": \"2026-06-05T09:28:20.253631\"}',1,'不允许操作超级管理员用户','2026-06-05 09:28:20',0),
(122,'用户管理',2,'module_admin/controller/user_controller.edit_system_user()','PUT',1,'admin','管理部门','/system/user','10.100.1.254','未知','{\"user_id\": 1, \"dept_id\": 103, \"user_name\": \"admin\", \"nick_name\": \"超级管理员\", \"user_type\": \"00\", \"email\": \"niangao@163.com\", \"phonenumber\": \"15888888888\", \"sex\": \"1\", \"avatar\": \"\", \"password\": \"$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2\", \"status\": \"0\", \"del_flag\": \"0\", \"login_ip\": \"127.0.0.1\", \"login_date\": \"2026-06-05T08:33:05\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null, \"remark\": \"管理员\", \"admin\": true, \"post_ids\": [2], \"role_ids\": [1], \"dept\": {\"dept_id\": 103, \"parent_id\": 101, \"ancestors\": \"0,100,101\", \"dept_name\": \"管理部门\", \"order_num\": 1, \"leader\": \"年糕\", \"phone\": \"15888888888\", \"email\": \"niangao@qq.com\", \"status\": \"0\", \"del_flag\": \"0\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"admin\", \"update_time\": \"2026-06-05T09:28:09\"}, \"role\": []}','{\"code\": 500, \"msg\": \"不允许操作超级管理员用户\", \"success\": false, \"time\": \"2026-06-05T09:35:54.076604\"}',1,'不允许操作超级管理员用户','2026-06-05 09:35:54',12),
(123,'用户管理',2,'module_admin/controller/user_controller.edit_system_user()','PUT',1,'admin','管理部门','/system/user','10.100.1.254','未知','{\"user_id\": 1, \"dept_id\": 103, \"user_name\": \"admin\", \"nick_name\": \"超级管理员\", \"user_type\": \"00\", \"email\": \"niangao@163.com\", \"phonenumber\": \"15888888888\", \"sex\": \"1\", \"avatar\": \"\", \"password\": \"$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2\", \"status\": \"0\", \"del_flag\": \"0\", \"login_ip\": \"127.0.0.1\", \"login_date\": \"2026-06-05T08:33:05\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"\", \"update_time\": null, \"remark\": \"管理员\", \"admin\": true, \"post_ids\": [2], \"role_ids\": [1], \"dept\": {\"dept_id\": 103, \"parent_id\": 101, \"ancestors\": \"0,100,101\", \"dept_name\": \"管理部门\", \"order_num\": 1, \"leader\": \"年糕\", \"phone\": \"15888888888\", \"email\": \"niangao@qq.com\", \"status\": \"0\", \"del_flag\": \"0\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:18\", \"update_by\": \"admin\", \"update_time\": \"2026-06-05T09:28:09\"}, \"role\": []}','{\"code\": 500, \"msg\": \"不允许操作超级管理员用户\", \"success\": false, \"time\": \"2026-06-05T09:35:55.445604\"}',1,'不允许操作超级管理员用户','2026-06-05 09:35:55',0),
(124,'角色管理',2,'module_admin/controller/role_controller.edit_system_role()','PUT',1,'admin','管理部门','/system/role','10.100.1.254','未知','{\"role_name\": \"普通角色\", \"role_key\": \"common\", \"role_sort\": 2, \"status\": \"0\", \"remark\": \"普通角色\", \"menu_ids\": [500, 501, 108, 100, 101, 102, 103, 104, 106, 1, 2, 3, 1000, 1006, 1007, 1012, 1016, 1020, 1030, 1039, 1042, 1045], \"menu_check_strictly\": true, \"role_id\": 2}','{\"code\": 200, \"msg\": \"更新成功\", \"success\": true, \"time\": \"2026-06-05T09:37:44.835488\"}',0,'','2026-06-05 09:37:44',3),
(125,'角色管理',2,'module_admin/controller/role_controller.edit_system_role()','PUT',1,'admin','管理部门','/system/role','10.100.1.254','未知','{\"role_name\": \"超级管理员\", \"role_key\": \"admin\", \"role_sort\": 1, \"status\": \"0\", \"remark\": \"超级管理员\", \"menu_ids\": [2005, 2001, 2003, 1, 100, 101, 102, 103, 104, 106, 108, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1030, 1031, 1032, 1033, 1034, 500, 501, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 2, 3, 2000, 2004], \"menu_check_strictly\": true, \"role_id\": 1}','{\"code\": 500, \"msg\": \"不允许操作超级管理员角色\", \"success\": false, \"time\": \"2026-06-05T09:48:29.835651\"}',1,'不允许操作超级管理员角色','2026-06-05 09:48:29',0),
(126,'角色管理',2,'module_admin/controller/role_controller.edit_system_role()','PUT',1,'admin','管理部门','/system/role','10.100.1.254','未知','{\"role_name\": \"超级管理员\", \"role_key\": \"admin\", \"role_sort\": 1, \"status\": \"0\", \"remark\": \"超级管理员\", \"menu_ids\": [2005, 2001, 2003, 1, 100, 101, 102, 103, 104, 106, 108, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1030, 1031, 1032, 1033, 1034, 500, 501, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 2, 3, 2000, 2004], \"menu_check_strictly\": true, \"role_id\": 1}','{\"code\": 500, \"msg\": \"不允许操作超级管理员角色\", \"success\": false, \"time\": \"2026-06-05T09:48:30.990881\"}',1,'不允许操作超级管理员角色','2026-06-05 09:48:30',0),
(127,'参数管理',2,'module_admin/controller/config_controller.edit_system_config()','PUT',1,'admin','管理部门','/system/config','10.100.1.254','未知','{\"config_id\": 4, \"config_name\": \"账号自助-验证码开关\", \"config_key\": \"sys.account.captchaEnabled\", \"config_value\": \"true\", \"config_type\": \"N\", \"create_by\": \"admin\", \"create_time\": \"2026-06-05T08:31:19\", \"update_by\": \"\", \"update_time\": null, \"remark\": \"是否开启验证码功能（true开启，false关闭）\"}','{\"code\": 200, \"msg\": \"更新成功\", \"success\": true, \"time\": \"2026-06-05T09:55:04.709594\"}',0,'','2026-06-05 09:55:04',1),
(128,'登录日志',5,'module_admin/controller/log_controller.export_system_login_log_list()','POST',1,'admin','管理部门','/monitor/logininfor/export','10.100.1.254','未知','','{\"code\": 200, \"message\": \"获取成功\"}',0,'','2026-06-08 01:22:24',4),
(129,'账户解锁',0,'module_admin/controller/log_controller.unlock_system_user()','GET',1,'admin','管理部门','/monitor/logininfor/unlock/admin','10.100.1.254','未知','{\"user_name\": \"admin\"}','{\"code\": 500, \"msg\": \"该用户未锁定\", \"success\": false, \"time\": \"2026-06-08T01:22:33.303776\"}',1,'该用户未锁定','2026-06-08 01:22:33',0);
/*!40000 ALTER TABLE `sys_oper_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_post`
--

DROP TABLE IF EXISTS `sys_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_post` (
  `post_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) NOT NULL COMMENT '岗位名称',
  `post_sort` int(4) NOT NULL COMMENT '显示顺序',
  `status` char(1) NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='岗位信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_post`
--

LOCK TABLES `sys_post` WRITE;
/*!40000 ALTER TABLE `sys_post` DISABLE KEYS */;
INSERT INTO `sys_post` VALUES
(1,'ceo','董事长',1,'0','admin','2026-06-05 08:31:18','',NULL,''),
(2,'se','管理经理',2,'0','admin','2026-06-05 08:31:18','admin','2026-06-05 09:16:29',''),
(4,'user','普通员工',4,'0','admin','2026-06-05 08:31:18','',NULL,'');
/*!40000 ALTER TABLE `sys_post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `role_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) NOT NULL COMMENT '角色权限字符串',
  `role_sort` int(4) NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES
(1,'超级管理员','admin',1,'1',1,1,'0','0','admin','2026-06-05 08:31:18','',NULL,'超级管理员'),
(2,'普通角色','common',2,'2',1,1,'0','0','admin','2026-06-05 08:31:18','admin','2026-06-05 09:37:44','普通角色');
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_dept`
--

DROP TABLE IF EXISTS `sys_role_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_dept` (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `dept_id` bigint(20) NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`,`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色和部门关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_dept`
--

LOCK TABLES `sys_role_dept` WRITE;
/*!40000 ALTER TABLE `sys_role_dept` DISABLE KEYS */;
INSERT INTO `sys_role_dept` VALUES
(2,100),
(2,101),
(2,105);
/*!40000 ALTER TABLE `sys_role_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_menu`
--

DROP TABLE IF EXISTS `sys_role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `menu_id` bigint(20) NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色和菜单关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_menu`
--

LOCK TABLES `sys_role_menu` WRITE;
/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;
INSERT INTO `sys_role_menu` VALUES
(1,2000),
(2,1),
(2,100),
(2,101),
(2,102),
(2,103),
(2,104),
(2,106),
(2,108),
(2,500),
(2,501),
(2,1000),
(2,1006),
(2,1007),
(2,1012),
(2,1016),
(2,1020),
(2,1030),
(2,1039),
(2,1042),
(2,1045);
/*!40000 ALTER TABLE `sys_role_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `user_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint(20) DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) DEFAULT '' COMMENT '手机号码',
  `sex` char(1) DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) DEFAULT '' COMMENT '密码',
  `status` char(1) DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime DEFAULT NULL COMMENT '最后登录时间',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES
(1,103,'admin','超级管理员','00','niangao@163.com','15888888888','1','','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','0','0','127.0.0.1','2026-06-08 00:55:17','admin','2026-06-05 08:31:18','',NULL,'管理员'),
(2,105,'niangao','年糕','00','niangao@qq.com','15666666666','1','','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','0','2','127.0.0.1','2026-06-05 08:31:18','admin','2026-06-05 08:31:18','admin','2026-06-05 08:35:25','测试员');
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_post`
--

DROP TABLE IF EXISTS `sys_user_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_post` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`,`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户与岗位关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_post`
--

LOCK TABLES `sys_user_post` WRITE;
/*!40000 ALTER TABLE `sys_user_post` DISABLE KEYS */;
INSERT INTO `sys_user_post` VALUES
(1,1);
/*!40000 ALTER TABLE `sys_user_post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_role`
--

DROP TABLE IF EXISTS `sys_user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_role` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户和角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_role`
--

LOCK TABLES `sys_user_role` WRITE;
/*!40000 ALTER TABLE `sys_user_role` DISABLE KEYS */;
INSERT INTO `sys_user_role` VALUES
(1,1);
/*!40000 ALTER TABLE `sys_user_role` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-08  1:28:43
