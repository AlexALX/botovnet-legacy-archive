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

require_once "core.php";
require_once THEMES."templates/header.php";

//if (iGUEST) need_login();
//else {

opentable("Онлайн магазин");

set_meta("keywords","Rust, Rust Experimental, Rust сервер, Rust выживание, онлайн магазин rust");

set_meta("description","Botov.NET.UA Rust - Выживание - онлайн магазин сервер выживание для Rust Experimental. Играть в Rust");

if (!iGUEST) include("nav.php");
/*
if (!iADMIN&&$userdata["user_id"]!=5) {
	echo "<br><center>Онлайн магазин находиться в стадии разработки (для rust серверов).</center><br>";
} else {
*/
$server = isset($_GET['server'])?intval($_GET['server']):0;
$cat = isset($_GET['cat'])?intval($_GET['cat']):0;

echo "<center><b>Сервер:</b> <select class='textbox' onchange='location.href=\"".FUSION_SELF."?server=\"+this.value'>
<option value='0'>---</option>";
$servers = servers_arr();
$sname = "";
foreach ($servers as $key=>$serv) {
	if ($key==1) continue;
	if ($server==$key) $sname = $serv[0];
	echo "<option value='".$key."'".($server==$key?" selected":"").">".$serv[0]."</option>";
}
echo "</select></center><br>";

if ($sname!="") set_title("Онлайн магазин - ".$sname." - Botov.NET.UA");

if ($server!=0 && array_key_exists($server,$servers)) {

echo "<center><b>Категория:</b> ".($cat==0?"<u>Все</u>":"<a href='".FUSION_SELF."?server=".$server."'>Все</a>");
$res = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_cats ORDER BY ord, name");
$curtype = 0;
$text = "";
while ($data = dbarray($res)) {
	$sql = "";
	if ($data['type']==1) $sql = " OR pack='1'";
	if ($data['type']==2) $sql = " OR new='1'";
	if ($cat==$data['id']) { $curtype = $data['type']; $text = $data['text']; }
	$count = dbcount("(id)",DB_PREFIX."game_shop","(cat='".$data['id']."'".$sql.") AND server='".$server."' AND enabled='1'");
	if ($count==0) continue;
	echo " | ".($cat==$data['id']?"<u>".$data['name']."</u>":"<a href='".FUSION_SELF."?server=".$server."&cat=".$data['id']."'>".$data['name']."</a>");
}
echo "</center><br>";

$sql = "";
if ($curtype==1) $sql = " OR pack='1'";
if ($curtype==2) $sql = " OR new='1'";
$res = dbquery("SELECT * FROM ".DB_PREFIX."game_shop WHERE server='".$server."' AND enabled='1'".($cat!=0?" AND (cat='".$cat."'".$sql.")":"")." ORDER BY new=0, ord, name");

if (dbrows($res)) {
echo "<div align='center'>";

if ($text!="") echo "<div>".$text."</div><br>";

while ($data = dbarray($res)) {
echo "<div style='display: inline-block;'><table class='tbl-border' style='width:205px; margin: 5px;'>
<tr>
<td class='tbl2' align='center' style='font-size: 18px;'>".($data['new']!=0?"<span style='line-height: 9px;border-radius: 8px; font-size:10px; color: #fff; background: #ff0000; font-weight: bold;'>&nbsp;НОВИНКА&nbsp;</span><br>":"").$data['name']."</td>
</tr>
<tr>
<td class='tbl1' style='font-size: 14px;' align='center'>";
$res2 = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_items WHERE pid='".$data['id']."' ORDER BY ord,name");
if ($data['desc']!="") echo $data['desc']."<br>";
if (dbrows($res2)) {
	$imgtxt = "";
	while ($data2 = dbarray($res2)) {
		$name = get_res_name($data2).($data2['bp']&&$data2['amount']==1?"":" - ".$data2['amount']).(!$data2['bp']&&$data2['amount']<600?" шт":"");
		if ($data['desc']=="") echo $name."<br>";
		$img = get_res_icon($data2['res']);
		if ($img!="") $imgtxt .= "<div style='position: relative;display: inline-block;'>".($data2['bp']?"<img src='".VIP_IMAGES."icons/blueprint.png' style='position: absolute;right:2px;top:2px;opacity: 0.8;'>":"").($data2['amount']>1?"<span style='position: absolute;right:-3px;bottom:-3px;font-size: 10px;color: #fff;background-color: #444;opacity: 0.8'>x".$data2['amount']."</span>":"")."<img src='".$img."' title='".$name."'>"."</div> ";
	}
	if ($imgtxt!="") echo "<br><center>".$imgtxt."</center>";
}
echo "</td>
</tr>
<tr>
<td class='tbl2' align='center'>Стоимость: ".$data['price_uah']." грн / ".$data['price_rub']." руб</td>
</tr>
<tr>
<td class='tbl2' align='center'>";
if ($data['price_uah']==0||$data['price_rub']==0) echo "Недоступно";
else echo "<input onclick='location.href=\"".VIP_BASEDIR."pays.php?action=new&server=".$data['server']."&item=".$data['id']."\"' type='submit' value='Купить' class='button'>";
echo "</td>
</tr>
</table></div>";

}

echo "</div><div style='clear: both;'></div>";

} else {
	echo "<center>Предметы отсутсвуют для данного сервера или категории.</center>";
}
} else {
	echo "<center>Выберите сервер</center>";
}

//}

vip_footer();

closetable();

//}

require_once THEMES."templates/footer.php";
?>