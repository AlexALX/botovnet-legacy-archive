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

define("PERSONAL_API",true);
require_once "../core.php";
require_once THEMES."templates/admin_header.php";
require_once ADMIN."navigation.php";

if (!checkrights("VIP") || !defined("iAUTH") || $_GET['aid'] != iAUTH) { redirect(VIP_BASEDIR); };

require_once "nav.php";

unset($res);

opentable("Настройки VIP системы");

if (isset($_POST['save'])) {

	$enabled = (isset($_POST['enabled'])&&$_POST['enabled']=="ON")?1:0;
	$shop_enabled = (isset($_POST['shop_enabled'])&&$_POST['shop_enabled']=="ON")?1:0;
	$pays = (isset($_POST['pays'])&&$_POST['pays']=="ON")?1:0;
	$free_vip = (isset($_POST['free_vip'])&&$_POST['free_vip']=="ON")?1:0;
	if (is_array($_POST['servers'])&&count($_POST['servers'])>0) {
		$servers = ".".stripinput(implode(".",$_POST['servers'])).".";
	} else $servers = "";

	$key = "free_vipt";
	if (isset($_POST[$key])&&$_POST[$key]['mday']!="--" && $_POST[$key]['mon']!="--" && $_POST[$key]['year']!="----") {
		$free_vipt = mktime($_POST[$key]['hours'],$_POST[$key]['minutes'],0,$_POST[$key]['mon'],$_POST[$key]['mday'],$_POST[$key]['year']);
	} else {
		$free_vipt = 0;
	}

	$res = dbquery("UPDATE ".DB_PREFIX."game_vip_set SET enabled='".$enabled."', shop_enabled='".$shop_enabled."', free_vip='".$free_vip."', free_vipt='".$free_vipt."', servers='".$servers."', pays='".$pays."'");

	if (isset($_POST['time'])&&isnum($_POST['time'])) {
		if (isset($_POST['type'])&&$_POST['type']=="0") $typ = "-"; else $typ = "+";
		$add = 0;
		if ($_POST['time_type']=="2") $add = $_POST['time']*60*60*24;
		elseif ($_POST['time_type']=="1") $add = $_POST['time']*60*60;
		else $add = $_POST['time']*60;
		$where = "";
		if (isset($_POST['servers_add'])&&is_array($_POST['servers_add'])&&count(servers_arr())>count($_POST['servers_add'])) {
			$where = " AND ("; $i = 0;
			foreach($_POST['servers_add'] as $serv) {
				if ($i!=0) $where .= " OR ";
 				$where .= "server='".$serv."'";
 				$i++;
			}
			$where .= ")";
		}
		if ($add>0) $res = dbquery("UPDATE ".DB_PREFIX."game_vip SET time=time".$typ.$add." WHERE `time`>'0' AND `time`>'".time()."'".$where);
	}

	if (isset($_POST['price'])&&$_POST['price']!=""&&floatval($_POST['price'])>0) {
		if ($_POST['price_type']==1) {
			$res = dbquery("UPDATE ".DB_PREFIX."game_shop SET price_uah=CEIL(price_rub*".floatval($_POST['price']).") WHERE price_rub!='0'");
		} else {
			$res = dbquery("UPDATE ".DB_PREFIX."game_shop SET price_rub=CEIL(price_uah*".floatval($_POST['price']).") WHERE price_uah!='0'");
		}
	}

	redirect(FUSION_SELF.$aidlink."&status=saved");

}

if ($vip_sets['free_vipt']>0) $free_vipt = getdate($vip_sets['free_vipt']);
echo "<form name='actionform' action='".FUSION_SELF.$aidlink."' method='post'>
<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>Настройки</b></td>
</tr>
<tr>
<td class='tbl2'>Включить систему:</td>
<td class='tbl1'><input name='enabled' type='checkbox' value='ON'".($vip_sets['enabled']==1?" checked":"")."></td>
</tr>
<tr>
<td class='tbl2'>Включить онлайн магазин:</td>
<td class='tbl1'><input name='shop_enabled' type='checkbox' value='ON'".($vip_sets['shop_enabled']==1?" checked":"")."></td>
</tr>
<tr>
<td class='tbl2'>Включить систему оплаты:</td>
<td class='tbl1'><input name='pays' type='checkbox' value='ON'".($vip_sets['pays']==1?" checked":"")."></td>
</tr>
<tr>
<td class='tbl2'>Включить бесплатный VIP:</td>
<td class='tbl1'><input name='free_vip' type='checkbox' value='ON'".($vip_sets['free_vip']==1?" checked":"")."></td>
</tr>
<tr>
<td class='tbl2'>Бесплатный VIP до:</td>
<td class='tbl1'><select name='free_vipt[mday]' class='textbox'>\n<option>--</option>\n";
	for ($i=1;$i<=31;$i++) echo "<option".(isset($free_vipt['mday']) && $free_vipt['mday'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> <select name='free_vipt[mon]' class='textbox'>\n<option>--</option>\n";
	for ($i=1;$i<=12;$i++) echo "<option".(isset($free_vipt['mon']) && $free_vipt['mon'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> <select name='free_vipt[year]' class='textbox'>\n<option>----</option>\n";
	for ($i=date('Y',strtotime("-1 years"));$i<=date("Y", strtotime('+10 years'));$i++) echo "<option".(isset($free_vipt['year']) && $free_vipt['year'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> / <select name='free_vipt[hours]' class='textbox'>\n";
	for ($i=0;$i<=24;$i++) echo "<option".(isset($free_vipt['hours']) && $free_vipt['hours'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> : <select name='free_vipt[minutes]' class='textbox'>\n";
	for ($i=0;$i<=60;$i++) echo "<option".(isset($free_vipt['minutes']) && $free_vipt['minutes'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> ".($data['free_vipt']>=time()?"Активен":"Срок истёк")."</td>
</tr>";

if ($vip_sets['free_vipt']>0) {
echo "<tr>
<td class='tbl2'>Осталось:</td>
<td class='tbl1'>".get_to_time($vip_sets['free_vipt']-time(),true)."</td>
</tr>";
}

$servers = servers_arr();
$servs = explode(".",$vip_sets['servers']);
echo "<tr>
<td class='tbl2'>Сервера:</td>
<td class='tbl1'><select class='textbox' name='servers[]' multiple size='".count($servers)."'>";
foreach ($servers as $key=>$serv) {
	echo "<option value='".$key."'".(in_array($key,$servs)?" selected":"").">".$serv[0].", ".$serv[1]."</option>";
}
echo "</select></td>
</tr>
<tr>
<td class='tbl2' align='center' colspan='2'><b>Дополнительно:</b></td>
</tr>
<tr>
<td class='tbl2'>Действие:</td>
<td class='tbl1'><select class='textbox' name='type'>
<option value='1'>Добавить</option>
<option value='0'>Отнять</option>
</select></td>
</tr>
<tr>
<td class='tbl2'>Всем VIP по:</td>
<td class='tbl1'><input name='time' type='text' value='' class='textbox'> <select class='textbox' name='time_type'>
<option value='0'>Минут</option>
<option value='1'>Часов</option>
<option value='2'>Дней</option>
</select></td>
</tr>
<tr>
<td class='tbl2'>На серверах:</td>
<td class='tbl1'><select class='textbox' name='servers_add[]' multiple size='".count($servers)."'>";
foreach ($servers as $key=>$serv) {
	echo "<option value='".$key."'>".$serv[0].", ".$serv[1]."</option>";
}
echo "</select></td>";

echo "<tr>
<td class='tbl2'>Обновить цены:</td>
<td class='tbl1'><input name='price' type='text' value='' class='textbox'> <select class='textbox' name='price_type'>
<option value='0'>грн</option>
<option value='1'>руб</option>
</select></td>
</tr>
<tr>
<td class='tbl2' align='center' colspan='2'><input type='submit' value='Сохранить' class='button' name='save'></td>
</tr>";

echo "</table></form>";

closetable();

require_once THEMES."templates/footer.php";

?>