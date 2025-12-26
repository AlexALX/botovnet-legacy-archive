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

opentable("Навигация");
/*
echo "<table width='50%' cellpadding='0' cellspacing='1' align='center' class='tbl-border'>\n<tr>\n";
echo "<td width='33%' align='center' class='".(!isset($_GET['action'])||preg_match("/(edit|new|view)/i",$_GET['action']) ? "tbl1" : "tbl2")."' style='padding-left:10px;padding-right:10px;'><a class='side' href='admin.php".$aidlink."'>База VIP'ов</a></td>\n";
echo "<td width='33%' align='center' class='".(preg_match("/(pays)/i",$_GET['action']) ? "tbl1" : "tbl2")."' style='padding-left:10px;padding-right:10px;'><a class='side' href='admin.php".$aidlink."&action=pays'>Платежи</a></td>\n";
echo "<td width='33%' align='center' class='".(preg_match("/(settings)/i",$_GET['action']) ? "tbl1" : "tbl2")."' style='padding-left:10px;padding-right:10px;'><a class='side' href='admin.php".$aidlink."&action=settings'>Настройки</a></td>\n";
echo "</tr>\n</table>\n";
*/

$nav = array(
	array("name"=>"Статистика игроков","url"=>"index.php"),
	array("name"=>"База VIP'ов","url"=>"vip.php","no_action"=>true,"preg_action"=>"(edit|new|view)"),
	array("name"=>"Платежи","url"=>"vip.php","action"=>"pays","preg_action"=>"(pays)"),
	array("name"=>"Настройки","url"=>"settings.php"),
	array("name"=>"Онлайн магазин","url"=>"shop.php"),
);

echo vip_build_nav($nav,true,"75%");

closetable();

?>