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

if (!defined("IN_FUSION")) { header("Location:index.php"); exit; }

// webmoney wallets - U for UAH, R for RUB (was in <2015 year)
$wm_pays = array("UXXX","RXXX");
// webmoney payment gateway secret
$_wm_secret = "xxxxxx";

?>