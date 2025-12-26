<?
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

if (!$vip_sets['enabled']) {
	echo "<center><b>Внимание!</b><br>Система временно отключена, платежи не принимаються!</center><br>";
}

//echo "<center><b>Внимание!</b><br>Система проходит стадию тестирования, оплата не взимается!<br>Дата окончания тестирования: 28 марта 2013 года.</center><br>";

$nav = array(
	array("name"=>"Личный кабинет","url"=>"index.php"),
	array("name"=>"VIP Аккаунт","url"=>"vip.php"),
	array("name"=>"Онлайн магазин","url"=>"shop.php"),
	array("name"=>"Платежи","url"=>"pays.php")
);

echo vip_build_nav($nav,false,"75%");
/*
if (FUSION_SELF=="vip.php"||FUSION_SELF=="pays.php") {
$nav = array(
	array("name"=>"Информация","url"=>"vip.php"),
	array("name"=>"Платежи","url"=>"pays.php")
);

echo vip_build_nav($nav,false,"30%");

}*/

?>