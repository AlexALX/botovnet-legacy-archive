<?
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

opentable("Навигация");

echo "<table width='50%' cellpadding='0' cellspacing='1' align='center' class='tbl-border'>\n<tr>\n";
echo "<td width='33%' align='center' class='".(!isset($_GET['action'])||preg_match("/(edit|new|view)/i",$_GET['action']) ? "tbl1" : "tbl2")."' style='padding-left:10px;padding-right:10px;'><a class='side' href='admin.php".$aidlink."'>База VIP'ов</a></td>\n";
echo "<td width='33%' align='center' class='".(preg_match("/(pays)/i",$_GET['action']) ? "tbl1" : "tbl2")."' style='padding-left:10px;padding-right:10px;'><a class='side' href='admin.php".$aidlink."&action=pays'>Платежи</a></td>\n";
echo "<td width='33%' align='center' class='".(preg_match("/(settings)/i",$_GET['action']) ? "tbl1" : "tbl2")."' style='padding-left:10px;padding-right:10px;'><a class='side' href='admin.php".$aidlink."&action=settings'>Настройки</a></td>\n";
echo "</tr>\n</table>\n";

closetable();
tablebreak();

?>