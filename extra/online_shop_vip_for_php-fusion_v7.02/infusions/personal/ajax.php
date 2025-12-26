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

if (iGUEST||intval($userdata['user_steam'])==0||!isset($_POST['server'])||isset($_POST['admin'])&&!iADMIN) die("Error");
$server = intval($_POST['server']);
$servers = servers_arr();
if (!isset($servers[$server])) die("Error");

if (isset($_POST['admin'])&&iADMIN&&isset($_POST['sid'])) {
	$sid = preg_replace("/[^0-9]/","",$_POST['sid']);
	$admin = true;
} else {
	$sid = $userdata['user_steam'];
	$admin = false;
}

if ($server==1) {
	$res = dbquery("SELECT * FROM ".DB_PREFIX."game_stat_gmod WHERE sid='".$sid."' AND server='".$server."'");
	$data = dbarray($res);

if (isset($data['time'])) {

echo "<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>".$servers[$server][0]."</b></td>
</tr>
<tr>
<td class='tbl2' width='50%'>Сыграно времени:</td>
<td class='tbl1' width='50%'>".showtime($data['time'])."</td>
</tr>
<tr>
<td class='tbl2'>Сыграно раз:</td>
<td class='tbl1'>".$data['played']."</td>
</tr>
<tr>
<td class='tbl2'>Убийств:</td>
<td class='tbl1'>".$data['frags']."</td>
</tr>
<tr>
<td class='tbl2'>Смертей:</td>
<td class='tbl1'>".$data['death']."</td>
</tr>
</table>";

} else {
	if ($admin) echo "<center>Данный игрок не играл на данном сервере.</center>";
	else echo "<center>Вы не играли на данном сервере.</center>";
}

} elseif($server==2||$server==3||$server==4) {

if (isset($_GET['log'])) {
if (!isset($_POST['cont'])) echo "<div id='server_log' style='display:none' title=\"Лог последних убийств и смертей\"><div id='server_log_cont'>";

$res = dbquery("SELECT * FROM ".DB_PREFIX."game_rust_log WHERE sid='".$sid."' AND server='".$server."'");

if (dbrows($res)) {
while($data = dbarray($res)) {
	echo "[".showdate("%H:%M:%S",$data['time'])."] ".htmlspecialchars($data['message'])."<br>";
}
} else echo "Нет данных.";
if (!isset($_POST['cont'])) echo "</div></div>";


} else {

	$res = dbquery("SELECT * FROM ".DB_PREFIX."game_stat_rust WHERE sid='".$sid."' AND server='".$server."'");
	$data = dbarray($res);

if (isset($data['time'])) {

echo "<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>".$servers[$server][0]."</b></td>
</tr>
<tr>
<td class='tbl2' width='50%'>Сыграно времени:</td>
<td class='tbl1' width='50%'>".showtime($data['time'])."</td>
</tr>
<tr>
<td class='tbl2'>Сыграно раз:</td>
<td class='tbl1'>".$data['played']."</td>
</tr>
<tr>
<td class='tbl2'>Смертей:</td>
<td class='tbl1'>".$data['death']."</td>
</tr>
";

$types = array();
$names = array("player"=>"игроков","boar"=>"кабанов","stag"=>"оленей","wolf"=>"волков","chicken"=>"куриц","bear"=>"медведей","horse"=>"лошадей");

$res = dbquery("SELECT count,name FROM ".DB_PREFIX."game_stat_rust_ext WHERE sid='".$sid."' AND server='".$server."'");

foreach($names as $val) {
	$types[$val] = 0;
}

while($cdata = dbarray($res)) {
	$types[(isset($names[$cdata['name']])?$names[$cdata['name']]:$cdata['name'])] = $cdata['count'];
}

echo "<tr>
<td class='tbl2' colspan='2' align='center'><b>Статистика убийств</b></td>
</tr>";
foreach($types as $key=>$value) {
echo "<tr>
<td class='tbl2'>Убито ".$key.":</td>
<td class='tbl1'>".$value."</td>
</tr>";
}
echo "<tr>
<td class='tbl2' colspan='2' align='center'><b><a href='#' onclick=\"show_log('".$server."','".$sid."'); return false;\">Лог последних убийств и смертей</a></b></td>
</tr>";
echo "</table>";

} else {
	if ($admin) echo "<center>Данный игрок не играл на данном сервере.</center>";
	else echo "<center>Вы не играли на данном сервере.</center>";
}

}

}

?>