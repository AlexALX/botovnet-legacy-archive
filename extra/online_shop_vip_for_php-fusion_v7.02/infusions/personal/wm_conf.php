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

if (!defined("IN_FUSION")) { header("Location:index.php"); exit; }

// webmoney wallets - U for UAH, R for RUB (was in <2015 year)
$wm_pays = array("UXXX","RXXX");
// webmoney payment gateway secret
$_wm_secret = "xxxxxx";

?>