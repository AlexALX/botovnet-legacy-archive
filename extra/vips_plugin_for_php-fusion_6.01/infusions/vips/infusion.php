<?php
/*---------------------------------------------------+
| This plugin is VIP system for CS 1.6 servers
| Use together with VIP_SQL.sma
| Was used on Botov-NET cs 1.6 servers
| Copyright (c) 2015 by AlexALX
+----------------------------------------------------+
| PHP-Fusion 6 Content Management System
+----------------------------------------------------+
| Copyright © 2002 - 2006 Nick Jones
| http://www.php-fusion.co.uk/
+----------------------------------------------------+
| Released under the terms & conditions of v2 of the
| GNU General Public License. For details refer to
| the included gpl.txt file or visit http://gnu.org
+----------------------------------------------------*/

if (!defined("IN_FUSION") || !checkrights("I")) { header("Location:../../index.php"); exit; }

// Infusion Information
$inf_title = "Система VIP";
$inf_description = "Автоматизированая система VIP";
$inf_version = "2.0.0";
$inf_developer = "AlexALX";
$inf_email = "alexalx@bigmir.net";
$inf_weburl = "http://alex-php.net/";

$inf_folder = "vips";
$inf_admin_image = "infusion_panel.gif";
$inf_admin_panel = "admin.php";

$inf_newtables = 4;
$inf_insertdbrows = 1;
$inf_altertables = 0;
$inf_deldbrows = 0;

$inf_newtable_[1] = "csvips (
  `vid` int(11) unsigned NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL,
  `type` int(1) unsigned NOT NULL,
  `name` varchar(32) NOT NULL,
  `password` varchar(32) NOT NULL,
  `time` int(11) NOT NULL,
  `server` int(2) NOT NULL,
  `flags` varchar(32) NOT NULL,
  `options` varchar(32) NOT NULL,
  `aid` int(11) unsigned NOT NULL,
  `status` int(1) unsigned NOT NULL,
  `date` int(11) unsigned NOT NULL,
  `ftime` int(11) unsigned NOT NULL,
  PRIMARY KEY  (`vid`)
) ENGINE=MyISAM;";

$inf_newtable_[2] = "csvips_pays (
  `pid` int(11) unsigned NOT NULL auto_increment,
  `vid` int(11) unsigned NOT NULL,
  `time` int(11) NOT NULL,
  `type` int(1) NOT NULL,
  `ammount` decimal(10,2) unsigned NOT NULL,
  `ammount_type` int(1) unsigned NOT NULL,
  `pay_data` text NOT NULL,
  `date` int(11) NOT NULL,
  `wm_sys_invs` varchar(255) NOT NULL,
  `wm_sys_trans` varchar(255) NOT NULL,
  `client_data` text NOT NULL,
  `status` int(1) unsigned NOT NULL,
  `desc` varchar(255) NOT NULL,
  `server` int(1) NOT NULL,
  `vip_time` int(1) unsigned NOT NULL,
  PRIMARY KEY  (`pid`)
) ENGINE=MyISAM;";

$inf_newtable_[3] = "csvips_ses (
  `vid` int(11) unsigned NOT NULL,
  `server` int(2) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `date` int(11) NOT NULL,
  PRIMARY KEY  (`vid`)
) ENGINE=MyISAM;";

$inf_newtable_[4] = "csvips_set (
  `enabled` int(1) unsigned NOT NULL,
  `free_vip` int(1) unsigned NOT NULL,
  `free_vipt` int(11) unsigned NOT NULL,
  `servers` varchar(255) NOT NULL
) ENGINE=MyISAM;";

$inf_insertdbrow_[1] = "csvips_set VALUES ('1','0','0','')";

$inf_droptable_[1] = "csvips";
$inf_droptable_[2] = "csvips_pays";
$inf_droptable_[3] = "csvips_ses";
$inf_droptable_[4] = "csvips_set";

?>