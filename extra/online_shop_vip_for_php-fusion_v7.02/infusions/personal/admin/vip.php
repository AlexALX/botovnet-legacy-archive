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

if (isset($_GET['action'])) {

unset($res);

if ($_GET['action']=="edit"||$_GET['action']=="new") {

opentable(($_GET['action']=="new"?"Добавить VIP":"Редактирование VIP'а"));

if ($_GET['action']=="edit") {
if (!isset($_GET['id'])||!isnum($_GET['id'])) redirect(VIP_BASEDIR."admin/vip.php".$aidlink);

$res = dbquery("SELECT v.*, u.user_name, a.user_name AS admin_name FROM ".DB_PREFIX."game_vip v LEFT JOIN ".DB_PREFIX."users u ON u.user_id=v.uid LEFT JOIN ".DB_PREFIX."users a ON a.user_id=v.aid WHERE vid='".$_GET['id']."'");

}

if ($_GET['action']=="new"||dbrows($res)) {

if ($_GET['action']=="new") $data = array("uid"=>"0","status"=>"1","time"=>"-1","user_name"=>"","flags"=>get_default_flags(1),"type"=>"0","name"=>"","password"=>"","options"=>"","vid"=>"0","server"=>"0","admin_name"=>"","aid"=>"0");
else $data = dbarray($res);

if (isset($_POST['save'])) {

	$error = "";
	//$type = stripinput($_POST['type']);
	$status = stripinput($_POST['status']);
	$server = stripinput($_POST['server']);
	//$name = stripinput($_POST['name']);
	//$password = stripinput($_POST['password']);
	$options = "";
	if (isset($_POST['options'])&&is_array($_POST['options'])) {
		$options = stripinput(implode("",$_POST['options']));
	}

	$flags = "";
	if (isset($_POST['flags'])&&is_array($_POST['flags'])) {
		$flags = stripinput(implode("",$_POST['flags']));
	}

	if (!isset($_POST['uid'])||!isnum($_POST['uid'])) $uid = 0; else $uid = $_POST['uid'];

	//if ($name==""||$type==""||$status==""||$server==""||!isset($_POST['time'])||!is_array($_POST['time'])||$password==""&&$type!="1") {
	if ($status==""||$server==""||!isset($_POST['time'])||!is_array($_POST['time'])) {
		if ($error!="") $error .= "<br>";
		$error .= "Не все обязательные поля были заполнены.";
	}
	$key = "time";
	if (isset($_POST[$key])&&$_POST[$key]['mday']!="--" && $_POST[$key]['mon']!="--" && $_POST[$key]['year']!="----") {
		$time = mktime($_POST[$key]['hours'],$_POST[$key]['minutes'],0,$_POST[$key]['mon'],$_POST[$key]['mday'],$_POST[$key]['year']);
	} else {
		$time = 0;
	}
	if (isset($_POST['time_type'])&&$_POST['time_type']!="") {
		if ($_POST['time_type']==0) $time = 0;
		elseif ($_POST['time_type']==-1) $time = -1;
	}/*
	if (!isnum($type)) {
		if ($error!="") $error .= "<br>";
		$error .= "Не верный тип авторизации.";
	}*/
	if (!isnum($server)) {
		if ($error!="") $error .= "<br>";
		$error .= "Не верный сервер.";
	} /*
	if (strlen($name)>32&&$type=="0") {
		if ($error!="") $error .= "<br>";
		$error .= "Ваш Ник слишком длинный, максимум 32 символа.";
	} elseif (strlen($name)<2&&$type=="0") {
		if ($error!="") $error .= "<br>";
		$error .= "Ваш ник слишком короткий, минимум 2 символа.";
	}
	if ($type=="1"&&!preg_match("/^STEAM_0:[01]:[0-9]{7,10}$/",$name)) {
		if ($error!="") $error .= "<br>";
		$error .= "Не верный Steam ID, пример: STEAM_0:1:12345678.";
	}
	if ($type=="2"&&!preg_match("/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/",$name)) {
		if ($error!="") $error .= "<br>";
		$error .= "Не верный IP, пример: 123.123.123.123.";
	}
	if (!preg_match("/^[A-Za-z0-9]{6,32}$/",$password)&&($type!="1"||$type=="1"&&$password!="")) {
		if ($error!="") $error .= "<br>";
		$error .= "Не верный пароль, пароль может содержать только английские буквы и цифры, длиной от 6 до 32 символов.";
	} */

	$ftime = 0;
	if ($status==0&&$data['status']!=0) $ftime = time();
	elseif ($status==0&&$data['status']==0) {
		$ftime = $data['ftime'];
		$time = $data['time'];
	}

	if ($error!="") {
		echo "<div class='admin-message' align='center'><b>".$error."</b></div>\n<br>";
	} else {
		if ($_GET['action']=="new") {
			$sid = intval($_POST['sid']);
		                                            // ,'".$type."','".$name."','".$password."'
			$res = dbquery("INSERT INTO ".DB_PREFIX."game_vip VALUES('','".$uid."','".$sid."','".$time."','".$server."','".$flags."','".$options."','".$userdata['user_id']."','".$status."','".time()."','0')");
			redirect(FUSION_SELF.$aidlink."&status=added");
		} else {

			if (isset($_POST['add_type'])&&$_POST['add_type']=="0") $typ = "-"; else $typ = "+";
			$add = 0;
			if (isset($_POST['add_time'])&&isnum($_POST['add_time'])&&$_POST['add_time']>0) {
				if ($_POST['add_timet']=="2") $add = $_POST['add_time']*60*60*24;
				elseif ($_POST['add_timet']=="1") $add = $_POST['add_time']*60*60;
				else $add = $_POST['add_time']*60;
			}
                                                        // name='".$name."', type='".$type."', password='".$password."',
			$res = dbquery("UPDATE ".DB_PREFIX."game_vip SET options='".$options."', flags='".$flags."',time=".($add!=0?"time".$typ.$add:"'".$time."'").",status='".$status."',uid='".$uid."',server='".$server."', ftime='".$ftime."' WHERE vid='".$_GET['id']."'");
			redirect(FUSION_SELF.$aidlink."&status=saved");
		}
	}

}

echo "<form name='actionform' action='".FUSION_SELF.$aidlink."&action=".$_GET['action']."&id=".$data['vid']."' method='post'>
<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>VIP Аккаунт ".$data['user_name']."</b></td>
</tr>
<tr>
<td class='tbl2'>User ID:</td>
<td class='tbl1'><input name='uid' type='text' class='textbox' value='".$data['uid']."'></td>
</tr>
<tr>
<td class='tbl2'>Дата регистрации:</td>
<td class='tbl1'>".showdate("%d/%m/%Y %H:%M",$data['date']).($data['aid']!="0"?" (выдал: ".$data['admin_name'].")":"")."</td>
</tr>";

if ($data['time'] > 0) {
	$time = getdate($data['time']);
	if ($data['ftime']>0&&$data['ftime']<=$data['time']) {
		$time = getdate($data['time']-$data['ftime']+time());
	}
}

echo "<tr>
<td class='tbl2'>Действителен до:</td>
<td class='tbl1'><select name='time[mday]' class='textbox'>\n<option>--</option>\n";
	for ($i=1;$i<=31;$i++) echo "<option".(isset($time['mday']) && $time['mday'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> <select name='time[mon]' class='textbox'>\n<option>--</option>\n";
	for ($i=1;$i<=12;$i++) echo "<option".(isset($time['mon']) && $time['mon'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> <select name='time[year]' class='textbox'>\n<option>----</option>\n";
	for ($i=date('Y',strtotime("-1 years"));$i<=date("Y", strtotime('+10 years'));$i++) echo "<option".(isset($time['year']) && $time['year'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> / <select name='time[hours]' class='textbox'>\n";
	for ($i=0;$i<=24;$i++) echo "<option".(isset($time['hours']) && $time['hours'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> : <select name='time[minutes]' class='textbox'>\n";
	for ($i=0;$i<=60;$i++) echo "<option".(isset($time['minutes']) && $time['minutes'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> <select class='textbox' name='time_type'>
  <option value=''>---</option>
  <option value='0'>Неограничено</option>
  <option value='-1'>Не оплачено</option>
</select> ";

	if ($_GET['action']=="edit"&&$data['ftime']==0) {
		if ($data['time']>=time()||$data['time']==0) echo "Активен";
		elseif ($data['time']==-1) echo "Не оплачен";
		else echo "Срок истёк";
	} elseif($_GET['action']=="edit") {
		echo "(при разморозке)";
	}

echo "</td>
</tr>";

if ($data['time']>0) {

if ($_GET['action']=="edit") echo "<tr>
<td class='tbl2'>Действие:</td>
<td class='tbl1'><select class='textbox' name='add_type'>
<option value='1'>Добавить</option>
<option value='0'>Отнять</option>
</select> <input name='add_time' type='text' value='' class='textbox'> <select class='textbox' name='add_timet'>
<option value='0'>Минут</option>
<option value='1'>Часов</option>
<option value='2'>Дней</option>
</select></td>
</tr>";

echo "<tr>
<td class='tbl2'>Осталось:</td>
<td class='tbl1'>".get_to_time($data['time']-($data['ftime']>0?$data['ftime']:time()),true)."</td>
</tr>";
}

echo "<tr>
<td class='tbl2'>Статус:</td>
<td class='tbl1'><select class='textbox' name='status'>
  <option value='0'".($data['status']=="0"?" selected":"").">Заморожен</option>
  <option value='1'".($data['status']=="1"?" selected":"").">Активен</option>
  <option value='2'".($data['status']=="2"?" selected":"").">Заблокирован</option>
</select></td>
</tr>
<tr>
<td class='tbl2'>Сервер:</td>
<td class='tbl1'><select class='textbox' name='server'>
<option value='0'".($data['server']=="0"?" selected":"").">Все</option>\n";
$servers = servers_arr();
foreach ($servers as $key=>$serv) {
	echo "<option value='".$key."'".($data['server']==$key?" selected":"").">".$serv[0]."</option>";
}
echo "</select></td>
</tr>
<tr>
<td class='tbl2' colspan='2' align='center'><b>Данные авторизации</b></td>
</tr>
<tr>
<td class='tbl2'>SteamID:</td>
<td class='tbl1'>";
if (intval($data['sid'])!=0) {
echo "<a href='http://steamcommunity.com/profiles/".intval($data['sid'])."' target='_blank'>".intval($data['sid'])."</a>";
} else {
echo "<input name='sid' type='text' class='textbox'>";
}
echo "</td>
</tr>
<tr>
<td class='tbl2' align='center' colspan='2'><b>Права:</b></td>
</tr>
<tr>
<td class='tbl2'>Тип:</td>
<td class='tbl1'>".get_vip_type($data['flags'])."</td>
</tr>";

$flags = get_flags("",true);

foreach ($flags as $opt=>$val) {
echo "<tr>
<td class='tbl2'>".$val.":</td>
<td class='tbl1'><input name='flags[]' type='checkbox' value='".$opt."'".(has_option($data['flags'],$opt)?"checked":"")."></td>
</tr>";
}

/*
echo "<tr>
<td class='tbl2'>Тип авторизации:</td>
<td class='tbl1'><select class='textbox' name='type'>
  <option value='0'".($data['type']=="0"?" selected":"").">Ник игрока</option>
  <option value='1'".($data['type']=="1"?" selected":"").">Steam ID</option>
  <option value='2'".($data['type']=="2"?" selected":"").">IP</option>
</select></td>
</tr>
<tr>
<td class='tbl2'>Ник/SteamID/IP:</td>
<td class='tbl1'><input name='name' type='text' value='".$data['name']."' class='textbox'><br><span class='small2'>Доступен только один вариант авторизации.</span></td>
</tr>
<tr>
<td class='tbl2'>Пароль в игре:</td>
<td class='tbl1'><input name='password' type='text' value='".$data['password']."' class='textbox'><br><span class='small2'>Пароль не обязателен при авторизации по Steam ID (оставте поле пустым).</span></td>
</tr>
<tr>
<td class='tbl1' colspan='2'><span class='small2'>Пароль к игре хранится в открытом (не зашифрованном) виде, поэтому задавайте случайный пароль.<br>Пароль может содержать только английские буквы и цифры.<br><br>Используйте консольную команду setinfo \"_vip\" \"ваш_пароль\" для установки пароля в игре.<br>Помните: ваш пароль могут украсть при заходе на сервер не принадлежащий нашему проекту.</span></td>
</tr>  */
echo "<tr>
<td class='tbl2' align='center' colspan='2'><b>Опции:</b></td>
</tr>";

$options = get_options("",true);

foreach ($options as $opt=>$val) {
echo "<tr>
<td class='tbl2'>".$val.":</td>
<td class='tbl1'><input name='options[]' type='checkbox' value='".$opt."'".(has_option($data['options'],$opt)?"checked":"")."></td>
</tr>";
}

echo "<tr>
<td class='tbl2' align='center' colspan='2'><input type='submit' value='".($_GET['action']=="edit"?"Сохранить":"Добавить")."' class='button' name='save'></td>
</tr>";

echo "</table></form>";

echo "<center>[ <a href='".FUSION_SELF.$aidlink."'>Назад</a> ]</center>";

closetable();

} else {
	redirect(VIP_BASEDIR."admin/vip.php".$aidlink);
}

} elseif ($_GET['action']=="view") {

if (!isset($_GET['id'])||!isnum($_GET['id'])) redirect(VIP_BASEDIR."admin/vip.php".$aidlink);

$res = dbquery("SELECT v.*, u.user_name, a.user_name AS admin_name FROM ".DB_PREFIX."game_vip v LEFT JOIN ".DB_PREFIX."users u ON u.user_id=v.uid LEFT JOIN ".DB_PREFIX."users a ON a.user_id=v.aid WHERE vid='".$_GET['id']."'");

$data = dbarray($res);

echo "<script type='text/javascript'>
function check_delete() {
	return confirm('Вы дейтсвительно хотите удалить этот аккаунт вместе с его платежами?');
}
</script>";

echo "<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>VIP Аккаунт ".$data['user_name']."</b> "
."<a href='".FUSION_SELF.$aidlink."&action=edit&id=".$data['vid']."'><img src='".VIP_IMAGES."edit.png' alt='Редактировать' title='Редактировать'></a> "
."<a href='".FUSION_SELF.$aidlink."&action=pays&id=".$data['vid']."'><img src='".VIP_IMAGES."money_dollar.png' alt='Платежи' title='Платежи'></a> "
."<a href='".FUSION_SELF.$aidlink."&del&id=".$data['vid']."' onclick='return check_delete()'><img src='".VIP_IMAGES."remove.png' alt='Удалить' title='Удалить'></a>"
."</td>
</tr>
<tr>
<td class='tbl2' width='50%'>Дата регистрации:</td>
<td class='tbl1'>".showdate("%d/%m/%Y %H:%M",$data['date']).($data['aid']!="0"?" (выдал: ".$data['admin_name'].")":"")."</td>
</tr>";
if ($data['status']!=0) {
echo "<tr>
<td class='tbl2'>Действителен до:</td>
<td class='tbl1'>".get_time($data['time'])."</td>
</tr>";
}
if ($data['time']!=0) {
echo "<tr>
<td class='tbl2'>Осталось:</td>
<td class='tbl1'>".get_to_time($data['time']-($data['ftime']>0?$data['ftime']:time()),true)."</td>
</tr>";
}
echo "<tr>
<td class='tbl2'>Статус:</td>
<td class='tbl1'>".get_status($data['status'],$data['time'])."</td>
</tr>
<tr>
<td class='tbl2'>Тип:</td>
<td class='tbl1'>".get_vip_type($data['flags'])."</td>
</tr>"; /*
<tr>
<td class='tbl2'>Права:</td>
<td class='tbl1'>".get_flags($data['flags'])."</td>
</tr> */
echo "<tr>
<td class='tbl2' colspan='2' align='center'><b>Данные авторизации:</b></td>
</tr>";
          /*
if ($data['name']=="") {
echo "<tr>
<td class='tbl1' colspan='2' align='center'><span style='color:red'><b>Не заполнено!</b></span></td>
</tr>";
} else {
echo "<tr>
<td class='tbl2'>".get_type($data['type'])."</td>
<td class='tbl1'>".$data['name']."</td>
</tr>
<tr>
<td class='tbl2'>Пароль в игре:</td>
<td class='tbl1'>".($data['password']!=""?$data['password']:"Без пароля")."</td>
</tr>
<tr>
<td class='tbl1' colspan='2'><span class='small2'>Используйте консольную команду setinfo \"_vip\" \"ваш_пароль\" для установки пароля в игре.<br>Помните: ваш пароль могут украсть при заходе на сервер не принадлежащий нашему проекту.</span></td>
</tr>";
}
         */
echo "<tr>
<td class='tbl2'>Сервер(а):</td>
<td class='tbl1'>".get_servers($data['server'])."</td>
</tr>
<tr>
<td class='tbl2'>SteamID:</td>
<td class='tbl1'><a href='http://steamcommunity.com/profiles/".intval($data['sid'])."' target='_blank'>".intval($data['sid'])."</a></td>
</tr>";
    /*
echo "<tr>
<td class='tbl2'>Опции:</td>
<td class='tbl1'>".get_options($data['options'])."</td>
</tr>";
       */
echo "</table>";

echo "<center>[ <a href='".FUSION_SELF.$aidlink."'>Назад</a> ]</center>";

} elseif ($_GET['action']=="settings") {

opentable("Настройки VIP системы");

if (isset($_POST['save'])) {

	$enabled = (isset($_POST['enabled'])&&$_POST['enabled']=="ON")?1:0;
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

	$res = dbquery("UPDATE ".DB_PREFIX."game_vip_set SET enabled='".$enabled."', free_vip='".$free_vip."', free_vipt='".$free_vipt."', servers='".$servers."'");

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

	redirect(FUSION_SELF.$aidlink."&status=saved");

}

if ($vip_sets['free_vipt']>0) $free_vipt = getdate($vip_sets['free_vipt']);
echo "<form name='actionform' action='".FUSION_SELF.$aidlink."&action=settings' method='post'>
<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>Настройки</b></td>
</tr>
<tr>
<td class='tbl2'>Включить систему:</td>
<td class='tbl1'><input name='enabled' type='checkbox' value='ON'".($vip_sets['enabled']==1?" checked":"")."></td>
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
	echo "<option value='".$key."'>".$serv."</option>";
}
echo "</select></td>";

echo "<tr>
<td class='tbl2' align='center' colspan='2'><input type='submit' value='Сохранить' class='button' name='save'></td>
</tr>";

echo "</table></form>";

closetable();

} elseif ($_GET['action']=="pays") {

opentable("Платежи");

if (isset($_GET['edit'])||isset($_GET['add'])) {

if (isset($_GET['pid'])&&!isnum($_GET['pid'])) redirect(FUSION_SELF.$aidlink);

$res = dbquery("SELECT * FROM ".DB_PREFIX."game_vip_pays WHERE pid='".$_GET['pid']."'");

if (isset($_GET['add'])&&!dbrows($res)||dbrows($res)&&isset($_GET['edit'])) {

if (isset($_POST['save'])) {

	$error = "";
	$vid = stripinput($_POST['vid']);
	$sid = stripinput($_POST['sid']);
	$status = stripinput($_POST['status']);
	$type = stripinput($_POST['type']);
	$server = stripinput($_POST['server']);
	$vtime = intval($_POST['vip_time']);
	$desc = str_replace("&lt;br&gt;","<br>",stripinput($_POST['desc']));
	$amtype = stripinput($_POST['ammount_type']);
	$ammount = stripinput($_POST['ammount']);
	$stype = (isset($_POST['stype'])&&$_POST['stype']=="ON"?1:0);
	$iamm = 0;
	if ($stype) {
		$vtime = stripinput($_POST['item_id']);
		$iamm = stripinput($_POST['item_amount']);
	}

	if ($vid==""||$ammount==""||!isnum($vid)||!isnum($status)||$server==""||$amtype==""||!isnum($server)||!isnum($amtype)) {
		if ($error!="") $error .= "<br>";
		$error .= "Не все обязательные поля были заполнены.";
	}

	$key = "time";
	if (isset($_POST[$key])&&$_POST[$key]['mday']!="--" && $_POST[$key]['mon']!="--" && $_POST[$key]['year']!="----") {
		$time = mktime($_POST[$key]['hours'],$_POST[$key]['minutes'],0,$_POST[$key]['mon'],$_POST[$key]['mday'],$_POST[$key]['year']);
	} else {
		$time = 0;
	}
	$key = "date";
	if (isset($_POST[$key])&&$_POST[$key]['mday']!="--" && $_POST[$key]['mon']!="--" && $_POST[$key]['year']!="----") {
		$date = mktime($_POST[$key]['hours'],$_POST[$key]['minutes'],0,$_POST[$key]['mon'],$_POST[$key]['mday'],$_POST[$key]['year']);
	} else {
		$date = 0;
	}

	if ($error != "") {
		echo "<div class='admin-message' align='center'><b>".$error."</b></div>\n<br>";
	} else {
		if (isset($_GET['add'])) {
			$res = dbquery("INSERT INTO ".DB_PREFIX."game_vip_pays VALUES ('','".$vid."','".($time!=0?$time:time())."','".$type."','".$ammount."','".$amtype."','','".$date."','','','','".$status."','".$desc."','".$server."','".$vtime."','".$iamm."','".$stype."','".$sid."','');");
			redirect(FUSION_SELF.$aidlink."&action=pays&view".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&pid=".mysql_insert_id()."&status=saved");
		} else {
			$res = dbquery("UPDATE ".DB_PREFIX."game_vip_pays SET vid='".$vid."', time='".$time."', date='".$date."', status='".$status."', type='".$type."', ammount='".$ammount."', ammount_type='".$amtype."', `desc`='".$desc."', server='".$server."', vip_time='".$vtime."', stype='".$stype."', sid='".$sid."', amount='".$iamm."' WHERE pid='".$_GET['pid']."';");
			redirect(FUSION_SELF.$aidlink."&action=pays&view".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&pid=".$_GET['pid']."&status=saved");
		}
	}

}

if (isset($_GET['add'])) $data = array("pid"=>" Новый","vid"=>(isset($_GET['id'])&&isnum($_GET['id'])?$_GET['id']:"0"),"time"=>"0","date"=>"0","status"=>"0","ammount"=>"0.00","ammount_type"=>"0","desc"=>"","server"=>"0","vip_time"=>"0","type"=>"2","stype"=>"0","amount"=>"0");
else $data = dbarray($res);
if ($data['time']>0) $time = getdate($data['time']);
if ($data['date']>0) $date = getdate($data['date']);
echo "<form name='paysform' action='".FUSION_SELF.$aidlink."&action=pays&".(isset($_GET['add'])?"add":"edit").(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"").(isnum($data['pid'])?"&pid=".$data['pid']:"")."' method='post'>
<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>Платёж №".$data['pid']."</b></td>
</tr>
<tr>
<td class='tbl2'>VIP ID:</td>
<td class='tbl1'><input name='vid' type='text' class='textbox' value='".$data['vid']."'></td>
</tr>
<tr>
<td class='tbl2'>SteamID:</td>
<td class='tbl1'><input name='sid' type='text' class='textbox' value='".$data['sid']."'></td>
</tr>
<tr>
<td class='tbl2' width='50%'>Дата:</td>
<td class='tbl1'><select name='time[mday]' class='textbox'>\n<option>--</option>\n";
	for ($i=1;$i<=31;$i++) echo "<option".(isset($time['mday']) && $time['mday'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> <select name='time[mon]' class='textbox'>\n<option>--</option>\n";
	for ($i=1;$i<=12;$i++) echo "<option".(isset($time['mon']) && $time['mon'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> <select name='time[year]' class='textbox'>\n<option>----</option>\n";
	for ($i=date('Y',strtotime("-1 years"));$i<=date("Y", strtotime('+10 years'));$i++) echo "<option".(isset($time['year']) && $time['year'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> / <select name='time[hours]' class='textbox'>\n";
	for ($i=0;$i<=24;$i++) echo "<option".(isset($time['hours']) && $time['hours'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> : <select name='time[minutes]' class='textbox'>\n";
	for ($i=0;$i<=60;$i++) echo "<option".(isset($time['minutes']) && $time['minutes'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select></td>
</tr>
<tr>
<td class='tbl2'>Дата оплаты:</td>
<td class='tbl1'><select name='date[mday]' class='textbox'>\n<option>--</option>\n";
	for ($i=1;$i<=31;$i++) echo "<option".(isset($date['mday']) && $date['mday'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> <select name='date[mon]' class='textbox'>\n<option>--</option>\n";
	for ($i=1;$i<=12;$i++) echo "<option".(isset($date['mon']) && $date['mon'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> <select name='date[year]' class='textbox'>\n<option>----</option>\n";
	for ($i=date('Y',strtotime("-1 years"));$i<=date("Y", strtotime('+10 years'));$i++) echo "<option".(isset($date['year']) && $date['year'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> / <select name='date[hours]' class='textbox'>\n";
	for ($i=0;$i<=24;$i++) echo "<option".(isset($date['hours']) && $date['hours'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select> : <select name='date[minutes]' class='textbox'>\n";
	for ($i=0;$i<=60;$i++) echo "<option".(isset($date['minutes']) && $date['minutes'] == $i ? " selected='selected'" : "").">$i</option>\n";
	echo "</select></td>
</tr>
<tr>
<td class='tbl2'>Статус:</td>
<td class='tbl1'><select class='textbox' name='status'>
	<option value='0'".($data['status']=='0'?" selected":"").">Ожидает оплаты</option>
	<option value='1'".($data['status']=='1'?" selected":"").">Оплачен</option>
	<option value='2'".($data['status']=='2'?" selected":"").">Неудача</option>
	<option value='3'".($data['status']=='3'?" selected":"").">Отменён</option>
	<option value='4'".($data['status']=='4'?" selected":"").">Возращён</option>
</select></td>
</tr>
<tr>
<td class='tbl2'>Тип:</td>
<td class='tbl1'><select class='textbox' name='type'>
	<option value='2'".($data['type']=='2'?" selected":"").">Добавленый</option>
	<option value='1'".($data['type']=='1'?" selected":"").">Тестовый</option>
	<option value='0'".($data['type']=='0'?" selected":"").">Реальный</option>
	<option value='-1'".($data['type']=='-1'?" selected":"").">---</option>
</select></td>
</tr>
<tr>
<td class='tbl2'>Сумма:</td>
<td class='tbl1'><input name='ammount' type='text' class='textbox' value='".$data['ammount']."'> <select class='textbox' name='ammount_type'>
  <option value='0'".($data['ammount_type']=='0'?" selected":"").">Гривны (WMU)</option>
  <option value='1'".($data['ammount_type']=='1'?" selected":"").">Рубли (WMR)</option>
</select></td>
</tr>
<tr>
<td class='tbl2'>Описание:</td>
<td class='tbl1'><input name='desc' type='text' class='textbox' value='".$data['desc']."' style='width:320px'></td>
</tr>
<tr>
<td class='tbl2'>Сервер:</td>
<td class='tbl1'><select class='textbox' name='server'>
<option value='0'".($data['server']=='0'?" selected":"").">Все</option>\n";
$servers = servers_arr();
foreach ($servers as $key=>$serv) {
	echo "<option value='".$key."'".($data['server']==$key?" selected":"").">".$serv[0].", ".$serv[1]."</option>";
}
echo "</select></td>
</tr>
<tr>
<td class='tbl2'>Предмет:</td>
<td class='tbl1'><input name='stype' type='checkbox' value='ON'".($data['stype']==1?" checked":"")."> ID: <input name='item_id' type='text' value='".($data['stype']==1?$data['vip_time']:"")."' class='textbox'> Количество: <input name='item_amount' type='text' value='".($data['stype']==1?$data['amount']:"")."' class='textbox'></td>
</tr>
<tr>
<td class='tbl2'>Срок:</td>
<td class='tbl1'><select class='textbox' name='vip_time'>
  <option value='0'".($data['vip_time']=='0'?" selected":"").">3 Дня</option>
  <option value='1'".($data['vip_time']=='1'?" selected":"").">2 Недели</option>
  <option value='2'".($data['vip_time']=='2'?" selected":"").">1 Месяц</option>
  <option value='3'".($data['vip_time']=='3'?" selected":"").">3 Месяца</option>
  <option value='-1'".($data['vip_time']=='-1'?" selected":"").">Произвольный</option>
</select></td>
</tr>";

echo "<tr>
<td class='tbl2' align='center' colspan='2'><input type='submit' value='Сохранить' class='button' name='save'></td>
</tr>";

echo "</table></form><center>";

echo "<br>[ <a href='".FUSION_SELF.$aidlink."&action=pays&view".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&pid=".$data['pid']."'>Назад</a> ]</center>";

}

} elseif (isset($_GET['view'])) {

if (!isset($_GET['pid'])||!isnum($_GET['pid'])) redirect(FUSION_SELF.$aidlink);

$res = dbquery("SELECT o.*,v.uid,u.user_name FROM ".DB_PREFIX."game_vip_pays o LEFT JOIN ".DB_PREFIX."game_vip v ON v.vid=o.vid LEFT JOIN ".DB_PREFIX."users u ON v.uid=u.user_id OR o.sid=u.user_steam WHERE o.pid='".$_GET['pid']."'");

if (dbrows($res)) {

if (isset($_GET['status'])) {
	if ($_GET['status']=="cancel") echo "<div class='admin-message' align='center'><b>Платёж успешно отменён.</b></div>\n<br>";
	elseif ($_GET['status']=="saved") echo "<div class='admin-message' align='center'><b>Платёж успешно сохранён.</b></div>\n<br>";
	elseif ($_GET['status']=="pay") echo "<div class='admin-message' align='center'><b>Платёж успешно оплачен.</b></div>\n<br>";
}

$data = dbarray($res);

if (isset($_GET['pay'])&&$data['status']==0) {
	$res2 = dbquery("UPDATE ".DB_PREFIX."game_vip_pays SET type='2', date='".time()."', `status`='1' WHERE pid='".$data['pid']."'");

	$data2 = $data;

	if ($data2['stype']==1) {
		$res = dbquery("SELECT * FROM ".DB_PREFIX."game_shop WHERE id='".$data2['vip_time']."'");
		if (dbrows($res)) {
			$ires2 = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_items WHERE pid='".$data2['vip_time']."'");
			if (dbrows($ires2)) {
				while ($idata2 = dbarray($ires2)) {
					$res = dbquery("INSERT INTO ".DB_PREFIX."game_shop_pays VALUES('".md5(microtime())."','".$data2['sid']."','".$data2['server']."','".$idata2['res']."','".$idata2['amount']*$data2['amount']."','".$idata2['bp']."')");
				}
			}
		}
		if ($_GET['pay']=="nw") redirect(FUSION_SELF.$aidlink."&action=pays".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&status=pay");
		else redirect(FUSION_SELF.$aidlink."&action=pays&view".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&pid=".$_GET['pid']."&status=pay");
    } else {
		$res = dbquery("SELECT * FROM ".DB_PREFIX."game_vip WHERE vid='".$data2['vid']."'");
		if (dbrows($res)) {
			$data = dbarray($res);
			$time = $data['time'];
			if ($data['time']>time()) {
				if ($data['server']=="0"&&$data2['server']=="0"||$data['server']!="0"&&$data2['server']!="0") {
					$time = $data['time']+calculate_amount_time($data2['vip_time']);
				} elseif ($data['server']!="0"&&$data2['server']=="0") {
					$time = ceil(($data['time']-time())/2)+time()+calculate_amount_time($data2['vip_time']);
				} elseif ($data['server']=="0"&&$data2['server']!="0") {
					$time = ceil(($data['time']-time())*2)+time()+calculate_amount_time($data2['vip_time']);
				}
			} else {
				$time = time()+calculate_amount_time($data2['vip_time']);
			}
			if (!has_flag($data['flags'],"u")) $flags = $data['flags']."u";
			else $flags = $data['flags'];
			$res = dbquery("UPDATE ".DB_PREFIX."game_vip SET time='".$time."', server='".$data2['server']."', flags='".$flags."' WHERE vid='".$data2['vid']."'");
			if ($_GET['pay']=="nw") redirect(FUSION_SELF.$aidlink."&action=pays".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&status=pay");
			else redirect(FUSION_SELF.$aidlink."&action=pays&view".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&pid=".$_GET['pid']."&status=pay");
		}
	}
}

echo "<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>Платёж №".$data['pid']."</b></td>
</tr>
<tr>
<td class='tbl2' width='50%'>Логин:</td>
<td class='tbl1'>".$data['user_name']."</td>
</tr>
<tr>
<td class='tbl2' width='50%'>Дата:</td>
<td class='tbl1'>".showdate("%d/%m/%Y %H:%M",$data['time'])."</td>
</tr>
<tr>
<td class='tbl2'>Дата оплаты:</td>
<td class='tbl1'>".get_pay_time($data['date'])."</td>
</tr>
<tr>
<td class='tbl2'>Статус:</td>
<td class='tbl1'>".get_pay_status($data['status'])."</td>
</tr>
<tr>
<td class='tbl2'>Сумма:</td>
<td class='tbl1'>".$data['ammount']." ".get_pay_type($data['ammount_type'])."</td>
</tr>
<tr>
<td class='tbl2'>Описание:</td>
<td class='tbl1'>".$data['desc']."</td>
</tr>
<tr>
<td class='tbl2'>Сервер:</td>
<td class='tbl1'>".get_servers($data['server'],true)."</td>
</tr>";
if ($data['stype']==0) {
echo "<tr>
<td class='tbl2'>Срок:</td>
<td class='tbl1'>".get_vip_time($data['vip_time'])."</td>
</tr>";
}

echo "</table><center>";

echo "[ <a href='".FUSION_SELF.$aidlink."&action=pays&edit".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&pid=".$data['pid']."'>Редактировать</a> ]";
if ($data['status']==0&&$data['vip_time']!=4) echo " [ <a href='".FUSION_SELF.$aidlink."&action=pays&view&pay".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&pid=".$data['pid']."'>Оплатить</a> ]";
echo "<br>";

}

echo "<br>[ <a href='".FUSION_SELF.$aidlink."&action=pays".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."'>Назад</a> ]</center>";

} else {

if (isset($_GET['del'])) {
	if (!isset($_GET['pid'])||!isnum($_GET['pid'])) redirect(FUSION_SELF.$aidlink);
	$res = dbquery("DELETE FROM ".DB_PREFIX."game_vip_pays WHERE pid='".$_GET['pid']."'");
	redirect(FUSION_SELF.$aidlink."&action=pays".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&status=del");
}

if (isset($_GET['status'])) {
	if ($_GET['status']=="saved") echo "<div class='admin-message' align='center'><b>Платёж успешно сохранён.</b></div>\n<br>";
	elseif ($_GET['status']=="del") echo "<div class='admin-message' align='center'><b>Платёж успешно удалён.</b></div>\n<br>";
	elseif ($_GET['status']=="pay") echo "<div class='admin-message' align='center'><b>Платёж успешно оплачен.</b></div>\n<br>";
}

if (!isset($_GET['rowstart']) || !isnum($_GET['rowstart'])) $rowstart = 0; else $rowstart = $_GET['rowstart'];
$items_per_page = 20;
$res = dbquery("SELECT o.*,v.uid,u.user_name FROM ".DB_PREFIX."game_vip_pays o LEFT JOIN ".DB_PREFIX."game_vip v ON v.vid=o.vid LEFT JOIN ".DB_PREFIX."users u ON v.uid=u.user_id OR o.sid=u.user_steam ".(isset($_GET['id'])&&isnum($_GET['id'])?"WHERE o.vid='".$_GET['id']."' ":"")."ORDER BY time DESC LIMIT $rowstart,$items_per_page");

echo "<center>[ <a href='".FUSION_SELF.$aidlink."&action=pays&add".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."'>Добавить платёж</a> ]</center><br>";

if (dbrows($res)) {

	if (isset($_GET['id'])&&isnum($_GET['id'])) echo "<center><b>Платежи VIP ID'а:</b> ".$_GET['id']."</center><br>";
	else echo "<center><b>Все платежи</b></center><br>";

	$rows = dbcount("(vid)", DB_PREFIX."game_vip_pays", (isset($_GET['id'])&&isnum($_GET['id'])?" vid='".$_GET['id']."'":""));

	echo "<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
	<tr>
	<td class='tbl2'><b>#</b></td>
	<td class='tbl2'><b>Логин</b></td>
	<td class='tbl2'><b>Дата</b></td>
	<td class='tbl2'><b>Сервер</b></td>
	<td class='tbl2'><b>Тип</b></td>
	<td class='tbl2'><b>Статус</b></td>
	<td class='tbl2'><b>Сумма</b></td>
	<td class='tbl2'><b>Платёж</b></td>
	<td class='tbl2'><b>Опции</b></td>
	</tr>";
    $i = 0;
	while ($data = dbarray($res)) {
		$i % 2 == 0 ? $tclass="tbl1" : $tclass="tbl2";
		echo "<tr>
		<td class='$tclass'>".$data['pid']."</td>
		<td class='$tclass'>".($data['user_name']!=""?$data['user_name']:"--")."</td>
		<td class='$tclass'>".showdate("%d/%m/%Y %H:%M",$data['time'])."</td>
		<td class='$tclass'>".get_servers($data['server'],true,true)."</td>
		<td class='$tclass'>".($data['stype']?"Предмет":"VIP Аккаунт")."</td>
		<td class='$tclass'>".get_pay_status($data['status'])."</td>
		<td class='$tclass'>".ceil($data['ammount'])." ".get_pay_type($data['ammount_type'])."</td>
		<td class='$tclass'>".get_pay_legacy($data['type'])."</td>
		<td class='$tclass' width='80'>"
		."<a href='".FUSION_SELF.$aidlink."&action=pays&view".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&pid=".$data['pid']."'><img src='".VIP_IMAGES."directory_listing.png' alt='Подробнее' title='Подробнее'></a> ";
		if ($data['status']=='0'&&$data['vip_time']!=4) echo "<a href='".FUSION_SELF.$aidlink."&action=pays&view&pay=nw".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&pid=".$data['pid']."'><img src='".VIP_IMAGES."money_add.png' alt='Оплатить' title='Оплатить'></a> ";
		echo "<a href='".FUSION_SELF.$aidlink."&action=pays&edit".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&pid=".$data['pid']."'><img src='".VIP_IMAGES."edit.png' alt='Редактировать' title='Редактировать'></a> "
		."<a href='".FUSION_SELF.$aidlink."&action=pays&del".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&pid=".$data['pid']."' onclick='return check_delete()'><img src='".VIP_IMAGES."remove.png' alt='Удалить' title='Удалить'></a>"
		."</td>
		</tr>"; $i++;
	}
	echo "</table>";

	if ($rows > $items_per_page) echo "<div align='center' style='margin-top:5px;'>\n".makePageNav($rowstart,$items_per_page,$rows,3,FUSION_SELF.$aidlink."&action=pays".(isset($_GET['id'])&&isnum($_GET['id'])?"&id=".$_GET['id']:"")."&")."\n</div>\n";
} else {
	echo "<center>Нет платежей.</center>";
}

echo "<script type='text/javascript'>
function check_delete() {
	return confirm('Вы дейтсвительно хотите удалить этот платёж?');
}
</script>";

}

closetable();

} else redirect(FUSION_SELF.$aidlink);

} else {

opentable("VIP Администрирование");

if (isset($_GET['del'])) {
	if (!isset($_GET['id'])||!isnum($_GET['id'])) redirect(FUSION_SELF.$aidlink);
	$res = dbquery("DELETE FROM ".DB_PREFIX."game_vip WHERE vid='".$_GET['id']."'");
	$res = dbquery("DELETE FROM ".DB_PREFIX."game_vip_pays WHERE vid='".$_GET['id']."'");
	$res = dbquery("DELETE FROM ".DB_PREFIX."game_vip_ses WHERE vid='".$_GET['id']."'");
	redirect(FUSION_SELF.$aidlink."&status=del");
}

if (isset($_GET['status'])) {
	if ($_GET['status']=="saved") echo "<div class='admin-message' align='center'><b>Данные успешно сохранены.</b></div>\n<br>";
	elseif ($_GET['status']=="added") echo "<div class='admin-message' align='center'><b>VIP пользователь успешно добавлен.</b></div>\n<br>";
	elseif ($_GET['status']=="del") echo "<div class='admin-message' align='center'><b>Аккаунт успешно удалён.</b></div>\n<br>";
}

if (!isset($_GET['rowstart']) || !isnum($_GET['rowstart'])) $rowstart = 0; else $rowstart = $_GET['rowstart'];
$items_per_page = 20;
$res = dbquery("SELECT v.*,u.user_name FROM ".DB_PREFIX."game_vip v LEFT JOIN ".DB_PREFIX."users u ON u.user_id=v.uid ORDER BY v.time='0' DESC, v.time DESC LIMIT $rowstart,$items_per_page");

echo "<center>[ <a href='".FUSION_SELF.$aidlink."&action=new'>Добавить нового</a> ]</center><br>";

if (dbrows($res)) {

	$rows = dbcount("(vid)", DB_PREFIX."game_vip");

	echo "<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
	<tr>
	<td class='tbl2'><b>Логин</b></td>
	<td class='tbl2'><b>Действителен до</b></td>
	<td class='tbl2'><b>Сервер</b></td>
	<td class='tbl2'><b>Статус</b></td>
	<td class='tbl2'><b>Опции</b></td>
	</tr>";
    $i = 0;
	while ($data = dbarray($res)) {
		$i % 2 == 0 ? $tclass="tbl1" : $tclass="tbl2";
		echo "<tr>
		<td class='$tclass'>".($data['user_name']!=""?$data['user_name']:"--")."</td>
		<td class='$tclass'>".get_time($data['time'],$data['ftime'])."</td>
		<td class='$tclass'>".get_servers($data['server'],true,true)."</td>
		<td class='$tclass'>".get_status($data['status'],$data['time'],true)."</td>
		<td class='$tclass' width='80'>"
		."<a href='".FUSION_SELF.$aidlink."&action=view&id=".$data['vid']."'><img src='".VIP_IMAGES."directory_listing.png' alt='Просмотр' title='Просмотр'></a> "
		."<a href='".FUSION_SELF.$aidlink."&action=edit&id=".$data['vid']."'><img src='".VIP_IMAGES."edit.png' alt='Редактировать' title='Редактировать'></a> "
		."<a href='".FUSION_SELF.$aidlink."&action=pays&id=".$data['vid']."'><img src='".VIP_IMAGES."money_dollar.png' alt='Платежи' title='Платежи'></a> "
		."<a href='".FUSION_SELF.$aidlink."&del&id=".$data['vid']."' onclick='return check_delete()'><img src='".VIP_IMAGES."remove.png' alt='Удалить' title='Удалить'></a>"
		."</td>
		</tr>"; $i++;
	}
	echo "</table>";

echo "<script type='text/javascript'>
function check_delete() {
	return confirm('Вы дейтсвительно хотите удалить этот аккаунт вместе с его платежами?');
}
</script>";

	if ($rows > $items_per_page) echo "<div align='center' style='margin-top:5px;'>\n".makePageNav($rowstart,$items_per_page,$rows,3,FUSION_SELF.$aidlink."&")."\n</div>\n";
} else {
	echo "<center>В базе данных нет випов.</center>";
}

closetable();

if (dbrows($res)) {
	opentable("Информация");

	$costs = dbarray(dbquery("SELECT (SELECT sum(ammount) FROM `".DB_PREFIX."game_vip_pays` WHERE ammount_type='0' AND type='0' AND status='1') AS uasum,(SELECT sum(ammount) FROM `".DB_PREFIX."game_vip_pays` WHERE ammount_type='1' AND type='0' AND status='1')  AS rusum"));
	echo "<table align='center' cellpadding='0' cellspacing='0' width='100%'>
	<tr>
	<td width='40%'>Всего випов: ".dbcount("(vid)",DB_PREFIX."game_vip")."</td>
	<td width='60%'>Всего платежей: ".dbcount("(pid)",DB_PREFIX."game_vip_pays")."</td>
	</tr>
	<tr>
	<td>Активных: ".dbcount("(vid)",DB_PREFIX."game_vip"," status='1' AND (time>'".time()."' or time='0')")."</td>
	<td>Оплаченых: ".dbcount("(pid)",DB_PREFIX."game_vip_pays"," status='1'")."</td>
	</tr>
	<tr>
	<td>Замороженных: ".dbcount("(vid)",DB_PREFIX."game_vip"," status='0'")."</td>
	<td>Неудачных: ".dbcount("(pid)",DB_PREFIX."game_vip_pays"," status='2'")."</td>
	</tr>
	<tr>
	<td>Заблокированных: ".dbcount("(vid)",DB_PREFIX."game_vip"," status='2'")."</td>
	<td>Отменённых: ".dbcount("(pid)",DB_PREFIX."game_vip_pays"," status='3'")."</td>
	</tr>
	<tr>
	<td>Получено средств: ".ceil($costs["uasum"])." UAH и ".ceil($costs["rusum"])." RUB</td>
	<td>Ожидающих: ".dbcount("(pid)",DB_PREFIX."game_vip_pays"," status='0'")."</td>
	</tr>
	</table>";

	closetable();
}

}

require_once THEMES."templates/footer.php";

?>