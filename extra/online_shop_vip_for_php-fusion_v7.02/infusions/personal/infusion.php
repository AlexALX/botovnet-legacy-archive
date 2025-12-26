<?php
/*-------------------------------------------------------+
| PHP-Fusion Content Management System
| Copyright (C) 2002 - 2011 Nick Jones
| http://www.php-fusion.co.uk/
+--------------------------------------------------------+
| This plugin is VIP system and Shop for RUST and GMOD servers
| Also includes some personal in-game stats
| Use together with VIP in-game plugin
| Was used on Botov-NET servers
| Copyright (c) 2015 by AlexALX
+--------------------------------------------------------+
| This program is released as free software under the
| Affero GPL license. You can redistribute it and/or
| modify it under the terms of this license which you
| can read by viewing the included agpl.txt or online
| at www.gnu.org/licenses/agpl.html. Removal of this
| copyright header is strictly prohibited without
| written permission from the original author(s).
+--------------------------------------------------------*/

if (!defined("IN_FUSION") || !checkrights("I")) { header("Location:../../index.php"); exit; }

// Infusion Information
$inf_title = "Личный кабинет + VIP";
$inf_description = "Личный кабинет и система VIP";
$inf_version = "3.0.0";
$inf_developer = "AlexALX";
$inf_email = "alexalx@bigmir.net";
$inf_weburl = "http://alex-php.net/";

$inf_folder = "personal";

$inf_adminpanel[1] = array(
	"title" => "Личный кабинет и VIP",
	"image" => "infusion_panel.gif",
	"panel" => "admin/index.php",
	"rights" => "VIP"
);

/*
  `type` int(1) unsigned NOT NULL,
  `name` varchar(32) NOT NULL,
  `password` varchar(32) NOT NULL,
*/

$inf_newtable[1] = DB_PREFIX."game_vip (
  `vid` int(11) unsigned NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL,
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

$inf_newtable[2] = DB_PREFIX."game_vip_pays (
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

$inf_newtable[3] = DB_PREFIX."game_vip_ses (
  `vid` int(11) unsigned NOT NULL,
  `server` int(2) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `date` int(11) NOT NULL,
  PRIMARY KEY  (`vid`)
) ENGINE=MyISAM;";

$inf_newtable[4] = DB_PREFIX."game_vip_set (
  `enabled` int(1) unsigned NOT NULL,
  `free_vip` int(1) unsigned NOT NULL,
  `free_vipt` int(11) unsigned NOT NULL,
  `servers` varchar(255) NOT NULL,
  `pays` int(1) unsigned NOT NULL
) ENGINE=MyISAM;";

$inf_insertdbrow[1] = DB_PREFIX."game_vip_set VALUES ('1','0','0','')";

$inf_droptable[1] = DB_PREFIX."game_vip";
$inf_droptable[2] = DB_PREFIX."game_vip_pays";
$inf_droptable[3] = DB_PREFIX."game_vip_ses";
$inf_droptable[4] = DB_PREFIX."game_vip_set";

?>