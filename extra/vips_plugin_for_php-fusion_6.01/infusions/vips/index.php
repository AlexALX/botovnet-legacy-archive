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

require_once "core.php";
require_once BASEDIR."subheader.php";
require_once BASEDIR."side_left.php";

if (iGUEST) need_login();
else {

opentable("Личный кабинет");

include("nav.php");

if (isset($_GET['action'])) {

if ($_GET['action']=="edit") {

$res = dbquery("SELECT * FROM ".DB_PREFIX."csvips WHERE uid='".$userdata['user_id']."'");

if (dbrows($res)) {

if (isset($_POST['save'])) {

	$error = "";
	$type = stripinput($_POST['type']);
	$name = stripinput($_POST['name']);
	$password = stripinput($_POST['password']);
	$options = "";
	if (isset($_POST['options'])&&is_array($_POST['options'])) {
		$options = stripinput(implode("",$_POST['options']));
	}

	if ($name==""||$type==""||$password==""&&$type!="1") {
		if ($error!="") $error .= "<br>";
		$error .= "Не все обязательные поля были заполнены.";
	}
	if ($password!=""&&md5(md5($password))==$userdata['user_password']) {
		if ($error!="") $error .= "<br>";
		$error .= "Пароль в игре не может совпадать с вашим паролем на сайте, придумайте другой.";
	}
	if (!isnum($type)) {
		if ($error!="") $error .= "<br>";
		$error .= "Не верный тип авторизации.";
	}
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
	if ($type=="2"&&($name=="127.0.0.1"||strpos($name,"192.168.")!==false)) {
		if ($error!="") $error .= "<br>";
		$error .= "Вы ввели локальный IP, необходимо указать внешний (интернета).<br>Ваш внешний IP: ".$_SERVER['REMOTE_ADDR'];
	}
	if (!preg_match("/^[A-Za-z0-9]{6,32}$/",$password)&&($type!="1"||$type=="1"&&$password!="")) {
		if ($error!="") $error .= "<br>";
		$error .= "Не верный пароль, пароль может содержать только английские буквы и цифры, длиной от 6 до 32 символов.";
	}

	if ($error!="") {
		echo "<div class='admin-message' align='center'><b>".$error."</b></div>\n<br>";
	} else {
		$res = dbquery("UPDATE ".DB_PREFIX."csvips SET name='".$name."', type='".$type."', password='".$password."', options='".$options."' WHERE uid='".$userdata['user_id']."'");

		redirect(FUSION_SELF."?status=saved");
	}

}

$data = dbarray($res);

echo "<script type='text/javascript'>
function showip(sel) {
	if (sel.value=='2') {
		document.getElementById('ip').style.display = '';
	} else {
		document.getElementById('ip').style.display = 'none';
	}
}
</script>";

echo "<form name='actionform' action='".FUSION_SELF."?action=edit' method='post'><table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>VIP Аккаунт - Редактирование данных</b></td>
</tr>";

echo "<tr>
<td class='tbl2'>Тип авторизации:</td>
<td class='tbl1'><select class='textbox' name='type' onchange='showip(this)'>
  <option value='0'".($data['type']=="0"?" selected":"").">Ник игрока</option>
  <option value='1'".($data['type']=="1"?" selected":"").">Steam ID</option>
  <option value='2'".($data['type']=="2"?" selected":"").">IP</option>
</select></td>
</tr>
<tr".($data['type']!=2?" style='display:none'":"")." id='ip'>
<td class='tbl2'>Ваш текущий IP:</td>
<td class='tbl1'>".$_SERVER['REMOTE_ADDR']."</td>
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
</tr>
<tr>
<td class='tbl2' align='center' colspan='2'><b>Опции:</b></td>
</tr>";

$options = get_options("",true);

$allow = has_flag($data['flags'],"e");

foreach ($options as $opt=>$val) {
echo "<tr>
<td class='tbl2'>".$val.":</td>
<td class='tbl1'><input name='options[]' type='checkbox' value='".$opt."'".(has_option($data['options'],$opt)?" checked":"")."".(!$allow?" disabled":"").">".(!$allow?" нет прав":"")."</td>
</tr>";
}

echo "<tr>
<td class='tbl2' align='center' colspan='2'><input type='submit' value='Сохранить' class='button' name='save'></td>
</tr>";

echo "</table></form>";

echo "<center>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";

}

}

} else {

$res = dbquery("SELECT * FROM ".DB_PREFIX."csvips WHERE uid='".$userdata['user_id']."'");

if (dbrows($res)) {

if (isset($_GET['status'])) {
	if ($_GET['status']=="saved") echo "<div class='admin-message' align='center'><b>Данные успешно сохранены.</b></div>\n<br>";
}

$data = dbarray($res);

echo "<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>VIP Аккаунт</b></td>
</tr>
<tr>
<td class='tbl2' width='50%'>Дата регистрации:</td>
<td class='tbl1'>".showdate("%d/%m/%Y %H:%M",$data['date'])."</td>
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
<td class='tbl1'>".get_to_time($data['time']-($data['ftime']>0?$data['ftime']:time()))."</td>
</tr>";
}
echo "<tr>
<td class='tbl2'>Статус:</td>
<td class='tbl1'>".get_status($data['status'],$data['time'])."</td>
</tr>
<tr>
<td class='tbl2'>Тип:</td>
<td class='tbl1'>".get_vip_type($data['flags'])."</td>
</tr>
<tr>
<td class='tbl2'>Права:</td>
<td class='tbl1'>".get_flags($data['flags'])."</td>
</tr>
<tr>
<td class='tbl2' colspan='2' align='center'><b>Данные авторизации:</b> <a href='".FUSION_SELF."?action=edit'><img src='".VIP_IMAGES."edit.png' alt='Редактировать' title='Редактировать'></a></td>
</tr>";

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

echo "<tr>
<td class='tbl2'>Сервер(а):</td>
<td class='tbl1'>".get_servers($data['server'])."</td>
</tr>";

echo "<tr>
<td class='tbl2'>Опции:</td>
<td class='tbl1'>".get_options($data['options'])."</td>
</tr>";

echo "</table>";

} else {
	echo "<center>У вас нет vip аккаунта.<br><a href='".VIP_BASEDIR."pays.php?action=new'><img src='".VIP_IMAGES."price_alert.png' alt='Купить' title='Купить'> Купить VIP</a></center>";
}

}

vip_footer();

closetable();

}

require_once BASEDIR."side_right.php";
require_once BASEDIR."footer.php";
?>