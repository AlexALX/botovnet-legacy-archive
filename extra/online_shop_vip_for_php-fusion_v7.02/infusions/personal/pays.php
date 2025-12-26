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

if (iGUEST) need_login();
else {

opentable("Личный кабинет");

include("nav.php");

$res = dbquery("SELECT vid,server,time,status FROM ".DB_PREFIX."game_vip WHERE uid='".$userdata['user_id']."'");

if (isset($_GET['action'])) {

if ($_GET['action']=="new") {

$server = isset($_GET['server'])?intval($_GET['server']):-1;

if (dbrows($res)) {
	$data = dbarray($res);
	$resc = dbquery("SELECT pid FROM ".DB_PREFIX."game_vip_pays WHERE (vid='".$data['vid']."' OR sid='".intval($userdata['user_steam'])."') AND status='0'");;
} else {
	$data = array("vid"=>"");
	$resc = dbquery("SELECT pid FROM ".DB_PREFIX."game_vip_pays WHERE sid='".intval($userdata['user_steam'])."' AND status='0'");
}

$item = isset($_GET['item'])?intval($_GET['item']):0;
$item_err = "";
$is_item = false;
if ($server>0 && $item>0) {
	$ires = dbquery("SELECT * FROM ".DB_PREFIX."game_shop WHERE id='".$item."' AND server='".$server."'");
	if (dbrows($ires)) {
		$idata = dbarray($ires);
		$ires2 = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_items WHERE pid='".$idata['id']."'");
		if (!dbrows($ires2)) $item_err = "Ошибка, данный предмет не содержит ресурсов!";
		if ($idata['enabled']=="0"||$idata['price_uah']==0||$idata['price_rub']==0) $item_err = "Ошибка, данный предмет недоступен!";
	} else {
		$item_err = "Ошибка, данный предмет не существует!";
	}
	$is_item = true;
}

if (!$vip_sets['enabled']) {
	echo "<center><b>Невозможно купить VIP/предмет - система отключена.</b><br><br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";
} elseif (!$vip_sets['pays']) {
	echo "<center><b>Невозможно купить VIP/предмет - система оплаты временно отключена.</b><br><br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";
} elseif ($resc!=""&&dbrows($resc)) {
	$datc = dbarray($resc);
	redirect(FUSION_SELF."?action=view&id=".$datc['pid']."&exists");
	//echo "<center><b>Невозможно купить VIP/предмет - у вас есть неоплаченые платежи.</b><br>Пожалуйста оплатите счёт или отмените платёж для повторного запроса на покупку.<br><br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";
} elseif (dbrows($res)&&$data['status']=='0') {
	echo "<center><b>Невозможно купить VIP/предмет - ваш аккаунт заморожен.</b><br><br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";
} elseif (dbrows($res)&&$data['status']=='2') {
	echo "<center><b>Невозможно купить VIP/предмет - ваш аккаунт заблокирован.</b><br><br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";
} elseif ($item_err!="") {
	echo "<center><b>".$item_err."</b><br><br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";
} else {

if (isset($_POST['save'])) {

	$vid = "";
	$error = "";
	$amtype = stripinput($_POST['ammount_type']);
	if (!$is_item) {
		$server = stripinput($_POST['server']);
		$time = stripinput($_POST['vip_time']);

		if ($server==""||$time==""||$amtype==""||!isnum($server)||!isnum($time)||!isnum($amtype)) {
			if ($error!="") $error .= "<br>";
			$error .= "Не все обязательные поля были заполнены.";
		}
	} else {
		$amount = intval($_POST['item_amount']);
		if ($amount<1) $amount = 1;
	}

	if ($server!=0) {
		$servers = servers_arr();
		if (!isset($servers[$server])) {
			if ($error!="") $error .= "<br>";
			$error .= "Ошибка, выбран неверный сервер.";
		} elseif (isset($servers[$server][2])) {
			if ($error!="") $error .= "<br>";
			$error .= "Ошибка, данный сервер недоступен.";
		}
	} elseif ($vip_disable_all) {
		if ($error!="") $error .= "<br>";
		$error .= "Ошибка, данный сервер недоступен.";
	}

	if (!isset($_POST['accept'])||$_POST['accept']!="ON") {
		if ($error!="") $error .= "<br>";
		$error .= "Вы не согласились с условиями пользовательского соглашения!";
	}

	if (intval($userdata['user_steam'])==0) {
		if ($error!="") $error .= "<br>";
		$error .= "Ошибка, неверный SteamID.";
	}

	if (!dbrows($res) && !$is_item) {
		/*$type = stripinput($_POST['type']);
		$name = stripinput($_POST['name']);
		$password = stripinput($_POST['password']);
		$options = "";
		if (isset($_POST['options'])&&is_array($_POST['options'])) {
			$options = stripinput(implode("",$_POST['options']));
		}*/

		$options = "";
		/*
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
		} */

		if ($error!="") {
			//echo "<div class='admin-message' align='center'><b>".$error."</b></div>\n<br>";
		} else {
			$res2 = dbquery("INSERT INTO ".DB_PREFIX."game_vip VALUES('','".$userdata['user_id']."','".intval($userdata['user_steam'])."','-1','".$server."','".get_default_flags()."','".$options."','0','1','".time()."','0')");
			if (!$res2) $error = "Произошла ошибка записи в базу данных.<br>Попробуйте ещё раз или обратитесь к системному администратору.";
			else $vid = mysql_insert_id();
			$res3 = dbquery("UPDATE ".DB_PREFIX."game_vip_pays SET vid='".$vid."' WHERE vid='0' AND sid='".intval($userdata['user_steam'])."'");
		}
	}

	if ($error == "") {
		if (dbrows($res)&&is_array($data)) {
			$vid = $data['vid'];
		}
		if (!$is_item&&($vid==""||!isnum($vid))) {
			$error = "Произошла ошибка записи в базу данных.<br>Попробуйте ещё раз или обратитесь к системному администратору.";
		}
	}

	if ($error != "") {
		echo "<div class='admin-message' align='center'><b>".$error."</b></div>\n<br>";
	} else {
		$sid = intval($userdata['user_steam']);
		if ($is_item) {
			$calc = ($amtype==1?$idata['price_rub']:$idata['price_uah']);
			$calc *= $amount;
			$calctxt = "Пожертвование, предмет \"".$idata['name']."\"".($amount>1?" ".$amount." шт.":"")."<br>Содержание: ";
			$added = false;
			$hash = "";
			while ($idata2 = dbarray($ires2)) {
				if ($added) $calctxt .= ", ";
				$calctxt .= get_res_name($idata2).($idata2['bp']&&$idata2['amount']*$amount==1?"":" - ".$idata2['amount']*$amount);
				$hash .= $idata2['res']."=".$idata2['amount']."|";
				$added = true;
			}
			$hash = md5($hash);
			$res = dbquery("INSERT INTO ".DB_PREFIX."game_vip_pays VALUES ('','".(isnum($vid)?$vid:"0")."','".time()."','-1','".$calc."','".$amtype."','','0','','','','0','".$calctxt."','".$server."','".$idata['id']."','".$amount."','1','".$sid."','".$hash."');");
		} else {
			$calc = calculate_amount_desc($amtype,$time,$server);
			$res = dbquery("INSERT INTO ".DB_PREFIX."game_vip_pays VALUES ('','".$vid."','".time()."','-1','".$calc[0]."','".$amtype."','','0','','','','0','".$calc[1]."','".$server."','".$time."','0','0','".$sid."','');");
		}
		if (!$res) redirect(FUSION_SELF."?status=error");
		else redirect(FUSION_SELF."?action=view&id=".mysql_insert_id());
	}

}

echo "<script type='text/javascript'>
function calculate_pay() { \n";
if ($is_item) {
echo "
	var pay = document.getElementById('pay_count');
	var type = document.getElementById('type').value;
	var prices = ".json_encode(array($idata['price_uah'],$idata['price_rub'])).";
	var amount = document.getElementById('item_amount').value;
	var type_m = '';
	if (type=='1') {
		type_m = 'Рублей (WMR)';
	} else {
		type_m = 'Гривен (WMU)';
	}
	if (type=='1') {
		pay.innerHTML = prices[1]*amount + ' ' + type_m;
	} else {
		pay.innerHTML = prices[0]*amount + ' ' + type_m;
	}
	pay.style.color='red';
	pay.style.fontWeight='bold';
";
} else {
echo " var pay = document.getElementById('pay_count');
	var time = document.getElementById('time').value;
	var server = document.getElementById('server').value;
	var type = document.getElementById('type').value;
	var timem = document.getElementById('timem');
	var svr = '';
	var prices = ".json_encode(get_prices()).";
	var type_m = '';
	if (type=='1') {
		type_m = 'Рублей (WMR)';
	} else {
		type_m = 'Гривен (WMU)';
	}
	if (server!='') {
		if (server=='0') {
			svr = '0';
		} else {
			svr = '1';
		}
		if (type=='1') {
			pay.innerHTML = prices[1][svr][time] + ' ' + type_m;
		} else {
			pay.innerHTML = prices[0][svr][time] + ' ' + type_m;
		}
		pay.style.color='red';
		pay.style.fontWeight='bold';";
		if ($data['time']>time()) {
		echo "
		if (server!='".$data['server']."') {
			warn_time.innerHTML = calculate_time(server,".$data['server'].",time);
			warn_serv.innerHTML = get_server_name(server);
			warn.style.display = '';
			timem.style.display = 'none';
		} else {
			timem_t.innerHTML = calculate_time(server,".$data['server'].",time);
			timem.style.display = '';
			warn.style.display = 'none';
		}";
        }
		echo "
	} else {
		pay.innerHTML = '--';
		pay.style.color='';
		pay.style.fontWeight='normal';
	}  ";
}
echo "\n
}
";
if ($data['time']>time()) {
$svrs = servers_arr();
foreach ($svrs as $key=>$svr) {
	$svrs[$key] = $svr[0];
}

echo "
function get_server_name(server) {
	var servers = ".json_encode($svrs).";
	if (server=='0') return 'Все сервера';
	if (servers[server]) return servers[server];
}

function calculate_amount_time(time) {
	if (time=='0') return 14;
	else if (time=='1') return 30;
	else if (time=='2') return 60;
	else if (time=='3') return 90;
	else if (time=='4') return 180;
	return 0;
}

function plural_type(n) {
  return (n%10==1 && n%100!=11 ? 0 : (n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2));
}

function calculate_time(server,old_serv,time) {
	var plural_days = ".json_encode(array('день', 'дня', 'дней')).";
	if (server=='0'&&old_serv=='0'||server!='0'&&old_serv!='0') {
		var timet = ".get_days_time($data['time'])." + calculate_amount_time(time);
		return timet + ' ' + plural_days[plural_type(timet)];
	} else if (old_serv!='0'&&server=='0') {
		var timet = ".round(get_days_time($data['time'])/2)." + calculate_amount_time(time);
		return timet + ' ' + plural_days[plural_type(timet)];
	} else if (old_serv=='0'&&server!='0') {
		var timet = ".(get_days_time($data['time'])*2)." + calculate_amount_time(time);
		return timet + ' ' + plural_days[plural_type(timet)];
	}

} ";
}
echo "
function ValidateForm(frm) {
	if (frm.server.value=='') {
		alert('Вы не выбрали сервер для которого хотите купить VIP аккаунт!');
		return false;
	} else if (document.getElementById('accept').checked==false) {
		alert('Вы не согласились с условиями пользовательского соглашения! Продолжение невозможно!');
		return false;
	}
}

function showip(sel) {
	if (sel.value=='2') {
		document.getElementById('ip').style.display = '';
	} else {
		document.getElementById('ip').style.display = 'none';
	}
}

function cham(add) {
	var currentVal = parseInt($('#item_amount').val());
	if (!isNaN(currentVal)) {
		if (add==true) $('#item_amount').val(currentVal + 1)
		else {
			if (currentVal - 1 < 1) $('#item_amount').val(1);
			else $('#item_amount').val(currentVal - 1);
		}
	} else $('#item_amount').val(1);
	calculate_pay();
	return false;
}

function check_am() {
	var currentVal = parseInt($('#item_amount').val());
	if (!isNaN(currentVal)) {
		if (currentVal<1) $('#item_amount').val(1);
	} else $('#item_amount').val(1);

	calculate_pay();
}
</script>";

echo "<form name='actionform' action='".FUSION_SELF."?action=new&server=".$server.($is_item?"&item=".$item:"")."' method='post' onSubmit='return ValidateForm(this);'>
<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>Покупка ".($is_item?"предмета":"VIP Аккаунта")." для ".$userdata['user_name']."</b></td>
</tr>";
if ($is_item) {
echo "<tr>
<td class='tbl2'>Описание:</td>
<td class='tbl1'>Предмет \"".$idata['name']."\"
<br>";
while ($idata2 = dbarray($ires2)) {
	echo get_res_name($idata2).($idata2['bp']&&$idata2['amount']==1?"":" - ".$idata2['amount'])."<br>";
}
echo "</td>
</tr>
<tr>
<td class='tbl2'>Стоимость:</td>
<td class='tbl1'>".$idata['price_uah']." грн / ".$idata['price_rub']." руб</td>
</tr>";
}
echo "<tr>
<td class='tbl2'>SteamID:</td>
<td class='tbl1'><a href='http://steamcommunity.com/profiles/".intval($userdata['user_steam'])."' target='_blank'>".intval($userdata['user_steam'])."</a></td>
</tr>
<tr>
<td class='tbl2'>Валюта:</td>
<td class='tbl1'><select class='textbox' name='ammount_type' onchange='calculate_pay()' id='type'>
  <option value='0'>Гривны (WMU)</option>
  <option value='1'>Рубли (WMR)</option>
</select></td>
</tr>";
if ($is_item) {
echo "<tr>
<td class='tbl2'>Количество:</td>
<td class='tbl1'><input type='submit' value='&nbsp;-&nbsp;' class='button' onclick='return cham(false);'> <input id='item_amount' name='item_amount' type='text' value='1' class='textbox' style='width:30px;' onchange='check_am();'> <input type='submit' value='&nbsp;+&nbsp;' class='button' onclick='return cham(true);'></td>
</tr>";
} else {
echo "<tr>
<td class='tbl2'>Срок:</td>
<td class='tbl1'><select class='textbox' name='vip_time' onchange='calculate_pay()' id='time'>
  <option value='0'>3 Дня</option>
  <option value='1'>2 Недели</option>
  <option value='2'>1 Месяц</option>
  <option value='3'>3 Месяца</option>
</select></td>
</tr>";
}
echo "<tr>
<td class='tbl2'>Сервер:</td>
<td class='tbl1'>";
if ($is_item) {
$servers = servers_arr();
echo $servers[$server][0].", ".$servers[$server][1];
} else {
echo "<select class='textbox' name='server' onchange='calculate_pay()' id='server'>
<option value=''>Выберите</option>
<option value='0'".($vip_disable_all?" disabled":"").($server=="0"?" selected":"").">Все</option>\n";
$servers = servers_arr();
foreach ($servers as $key=>$serv) {
	echo "<option value='".$key."'".(isset($serv[2])?" disabled":"").($server==$key?" selected":"").">".$serv[0].", ".$serv[1]."</option>";
}
echo "</select>";
}
echo "</td>
</tr>
<tr>
<td class='tbl2'>Итого к оплате:</td>
<td class='tbl1' id='pay_count'>--</td>
</tr>
<tr>
<td class='tbl2'>Подверждение</td>
<td class='tbl1'><label><input name='accept' type='checkbox' value='ON' id='accept'> Я согласен с условиями</label> <a href='".VIP_BASEDIR."lic.php' target='_blank'>пользовательского соглашения</a>.</td>
</tr>";
    /*
if (!dbrows($res)) {
echo "<tr>
<td class='tbl2' colspan='2' align='center'><b>Данные авторизации</b><br><span class='small2'>Вы сможете изменить эти данные в личном кабинете когда пожелаете.</span></td>
</tr>";

echo "<tr>
<td class='tbl2'>Тип авторизации:</td>
<td class='tbl1'><select class='textbox' name='type' onchange='showip(this)'>
  <option value='0'>Ник игрока</option>
  <option value='1'>Steam ID</option>
  <option value='2'>IP</option>
</select></td>
</tr>
<tr style='display:none' id='ip'>
<td class='tbl2'>Ваш текущий IP:</td>
<td class='tbl1'>".$_SERVER['REMOTE_ADDR']."</td>
</tr>
<tr>
<td class='tbl2'>Ник/SteamID/IP:</td>
<td class='tbl1'><input name='name' type='text' value='' class='textbox'><br><span class='small2'>Доступен только один вариант авторизации.</span></td>
</tr>
<tr>
<td class='tbl2'>Пароль в игре:</td>
<td class='tbl1'><input name='password' type='text' value='' class='textbox'><br><span class='small2'>Пароль не обязателен при авторизации по Steam ID (оставте поле пустым).</span></td>
</tr>
<tr>
<td class='tbl1' colspan='2'><span class='small2'>Пароль к игре хранится в открытом (не зашифрованном) виде, поэтому задавайте случайный пароль.<br>Пароль может содержать только английские буквы и цифры.<br><br>Используйте консольную команду setinfo \"_vip\" \"ваш_пароль\" для установки пароля в игре.<br>Помните: ваш пароль могут украсть при заходе на сервер не принадлежащий нашему проекту.</span></td>
</tr>
<tr>
<td class='tbl2' align='center' colspan='2'><b>Опции:</b></td>
</tr>";

$options = get_options("",true);

foreach ($options as $opt=>$val) {
echo "<tr>
<td class='tbl2'>".$val.":</td>
<td class='tbl1'><input name='options[]' type='checkbox' value='".$opt."'></td>
</tr>";
}

} else*/if ($data['time']>time()) {

$sv = explode(",",get_servers($data['server'],true));

echo "<tr id='warn' style='display:none'>
<td class='tbl1' colspan='2'><b>Внимание! Вы выбрали другой сервер для VIP аккаунта!</b>
<br>Вы выбрали сервер: <u><span id='warn_serv'></span></u>, ваш текущий сервер: <u>".$sv[0]."</u>.
<br>Срок действия будет автоматически пересчитан, и составит: <u><span id='warn_time'></span></u>.</td>
</tr>";

echo "<tr id='timem' style='display:none'>
<td class='tbl1' colspan='2'>Срок действия после продления составит: <u><span id='timem_t'></span></u>.</td>
</tr>";

}

echo "<tr>
<td class='tbl2' align='center' colspan='2'><input type='submit' value='Продолжить' class='button' name='save'></td>
</tr>";

echo "</table></form>";

echo "<center>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";

echo "<script type='text/javascript'>
calculate_pay();
</script>";

}

} elseif ($_GET['action']=="view") {

//if (!dbrows($res)) redirect(FUSION_SELF);

if (!isset($_GET['id'])||!isnum($_GET['id'])) redirect(FUSION_SELF);

$resc = dbquery("SELECT vid FROM ".DB_PREFIX."game_vip WHERE sid='".intval($userdata['user_steam'])."'");
$vid = "";
if (dbrows($resc)) {
	$datc = dbarray($resc);
	$vid = intval($datc['vid']);
	if ($vid==0) $vid = "";
}

$res = dbquery("SELECT p.*, v.status AS vip_status FROM ".DB_PREFIX."game_vip_pays p LEFT JOIN ".DB_PREFIX."game_vip v ON v.vid=p.vid WHERE p.pid='".$_GET['id']."' AND (".($vid!=""?"v.vid='".$vid."' OR ":"")."p.sid='".intval($userdata['user_steam'])."')");

if (dbrows($res)) {

if (isset($_GET['status'])) {
	if ($_GET['status']=="cancel") echo "<div class='admin-message' align='center'><b>Ваш платёж успешно отменён.</b></div>\n<br>";
	elseif ($_GET['status']=="error") echo "<div class='admin-message' align='center'><b>Произошла ошибка при добавлении платежа.</b><br>Попробуйте ещё раз или обратитесь к системному администратору.</div>\n<br>";
}

$data = dbarray($res);

if (isset($_GET['cancel'])&&$data['status']=='0'&&$data['vip_status']=='1') {
	$res = dbquery("UPDATE ".DB_PREFIX."game_vip_pays SET status='3' WHERE pid='".$data['pid']."'");
	redirect(FUSION_SELF."?action=view&id=".$data['pid']."&status=cancel");
}

if (isset($_GET['exists'])) echo "<center><b>Невозможно купить VIP/предмет - у вас есть неоплаченые платежи.</b><br>Пожалуйста оплатите счёт или отмените платёж для повторного запроса на покупку.<br><br><b>Детали предыдущего платежа:</b></center><br>";

echo "<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>Платёж №".$data['pid']."</b></td>
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

if (!$vip_sets['enabled']) {
	echo "<br><b>Невозможно оплатить или отменить счёт - система отключена.</b><br>";
} elseif (!$vip_sets['pays']) {
	echo "<br><b>Невозможно оплатить или отменить счёт - система оплаты временно отключена.</b><br>";
} elseif ($data['vip_status']=='0') {
	echo "<br><b>Невозможно оплатить или отменить счёт - ваш аккаунт заморожен.</b><br>";
} elseif ($data['vip_status']=='2') {
	echo "<br><b>Невозможно оплатить или отменить счёт - ваш аккаунт заблокирован.</b><br>";
} else {
	if ($data['status']==0) {

	echo "<br>Средства принимаются как добровольное <b>ПОЖЕРТВОВАНИЕ</b>.<br>";

		$form_fields = "<input type='hidden' name='LMI_PAYMENT_AMOUNT' value='".$data['ammount']."'>
  <input type='hidden' name='LMI_PAYMENT_NO' value='".$data['pid']."'>
  <input type='hidden' name='LMI_PAYEE_PURSE' value='".($data['ammount_type']==1?$wm_pays[1]:$wm_pays[0])."'>
  <input type='hidden' name='LMI_SIM_MODE' value='0'>
  <input type='hidden' name='LMI_PAYMENT_DESC_BASE64' value='".base64_encode("Пожертвование")."'>";

	echo "<br>
	<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
	<tr>
	<td class='tbl2' colspan='2' align='center'><img src='".VIP_IMAGES."wm/webmoney.png' alt='help' style='vertical-align:middle;'> <b>Оплатить с кошелька WebMoney</b></td>
	</tr>
	<tr>
	<td class='tbl1'>Вы должны быть <a href='http://start.webmoney.ru' target='_blank'>зарегистрированным пользователем</a> WebMoney и иметь Keeper Classic, Light, Mini или Mobile.</td>
	<td class='tbl2' width='1%'><form name='payform' action='https://merchant.webmoney.ru/lmi/payment.asp?at=authtype_8' method='post'><input class='button' type='submit' value='Оплатить'>".$form_fields."</form></td>
	</tr>
	<tr>
	<td class='tbl2' colspan='2' align='center'><img src='".VIP_IMAGES."wm/terminal.png' alt='help' style='vertical-align:middle;'> <b>Оплатить через терминал</b></td>
	</tr>";
	if ($data['ammount_type']!=1) {
		echo "<tr>
		<td class='tbl1'>1. Попав на сайт WebMoney, введите номер телефона.<br>2. Получите SMS с номером счета.<br>3. Внесите оплату по номеру счета в платежном терминале, кассе банка или интернет-банкинге (нужно оплатить дополнительную комиссию до 6%).</td>
		<td class='tbl2'><form name='payform' action='https://merchant.webmoney.ru/lmi/payment.asp?at=authtype_7' method='post'><input name='LMI_ALLOW_SDP' type='hidden' value='8'><input class='button' type='submit' value='Оплатить'>".$form_fields."</form></td>
		</tr>";
	} else {
		echo "<tr>
		<td class='tbl1'>1. Внесите необходимую сумму через терминал указав ваш номер телефона.<br>2. Получите чек/квитанцию с датой платежа и SMS с кодом платежа.<br>3. Введите эти данные после перехода на сайт webmoney.</td>
		<td class='tbl2'><form name='payform' action='https://merchant.webmoney.ru/lmi/payment.asp?at=authtype_7' method='post'><input class='button' type='submit' value='Оплатить'>".$form_fields."</form></td>
		</tr>";
	}
	echo "<tr>
	<td class='tbl2' colspan='2' align='center'><img src='".VIP_IMAGES."wm/check.png' alt='help' style='vertical-align:middle;'> <b>Оплатить с WebMoney Чека</b> [<a href='".($data['ammount_type']==1?"http://www.webmoney.ru/rus/services/spendwm_noreg/terminal.shtml":"http://webmoney.ua/about/services/check")."' target='_blank'>что это?</a>]</td>
	</tr>
	<tr>
	<td class='tbl1'>1. Попав на сайт WebMoney, выберите пункт \"WebMoney Check\", введите свой номер телефона и пароль.<br> 2. Получите SMS с одноразовым кодом подтверждения и введите его на странице для подтверждения оплаты.<br>3. Неизрасходованным остатком на WebMoney Чеке можно распоряжаться из кабинета на сайте check.webmoney.ru.</td>
	<td class='tbl2'><form name='payform' action='https://merchant.webmoney.ru/lmi/payment.asp?at=authtype_13' method='post'><input class='button' type='submit' value='Оплатить'>".$form_fields."</form></td>
	</tr>" /*
	<tr>
	<td class='tbl2' colspan='2' align='center'><img src='".VIP_IMAGES."wm/visa.png' alt='help' style='vertical-align:middle;'> <b>Оплатить банковской карточкой</b></td>
	</tr>
	<tr>
	<td class='tbl1' colspan='2'>Если у вас есть банковская карточка Visa, MasterCard или счёт в Приват24, то вы можете оплатить в <u>ручном режиме</u>, оставив заявку написав <a href='".BASEDIR."messages.php?msg_send=1' target='_blank'>личное сообщение</a>.<br>В заявке вы должны написать что желаете купить vip, номер счёта (№".$data['pid']."), и ожидать дальнейших иструкций (в течении 3х дней).<br><b>Внимание!</b> Данный способ доступен только при оплате <u>гривной</u>.</td>
	</tr>  */ ."
	</table>";
	echo "<br>[ <a href='".FUSION_SELF."?action=view&id=".$data['pid']."&cancel'><b>Отменить заказ</b></a> ]<br>";
	}
}

echo "<br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";

} else echo "<center><b>Неверный платёж!</b><br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";

}

} else {

//if (dbrows($res)) {

if (isset($_GET['fail'])||isset($_GET['success'])) {
	if (isset($_POST['LMI_PAYMENT_NO'])&&isnum($_POST['LMI_PAYMENT_NO'])) {
		$res = dbquery("SELECT pid FROM ".DB_PREFIX."game_vip_pays WHERE pid='".$_POST['LMI_PAYMENT_NO']."'".(isset($_GET['fail'])?" AND status='0'":""));
		if (dbrows($res)) {
			$fields = array("LMI_SYS_INVS_NO","LMI_SYS_TRANS_NO","LMI_SYS_TRANS_DATE","LMI_PAYMER_NUMBER","LMI_PAYMER_EMAIL","LMI_EURONOTE_NUMBER",
			"LMI_EURONOTE_EMAIL","LMI_WMCHECK_NUMBER","LMI_TELEPAT_PHONENUMBER","LMI_TELEPAT_ORDERID","LMI_PAYMENT_CREDITDAYS");
			$arr = array("LMI_SYS_INVS_NO"=>"","LMI_SYS_TRANS_NO"=>"");
			foreach($_POST as $key=>$val) {
				if (in_array($key,$fields)&&trim($val)!="") {
					$arr[$key] = stripinput($val);
				}
			}
			$res = dbquery("UPDATE ".DB_PREFIX."game_vip_pays SET".(isset($_GET['fail'])?" status='2', type='0',":"")." wm_sys_invs='".$arr["LMI_SYS_INVS_NO"]."',".
			" wm_sys_trans='".$arr["LMI_SYS_TRANS_NO"]."', client_data='".(count($arr)>2?base64_encode(serialize($arr)):"")."' WHERE pid='".$_POST['LMI_PAYMENT_NO']."'");
			redirect(FUSION_SELF."?status=".(isset($_GET['fail'])?"fail":"success"));
		}
	}
}

if (isset($_GET['status'])) {
	if ($_GET['status']=="saved") echo "<div class='admin-message' align='center'><b>Данные успешно сохранены.</b></div>\n<br>";
	elseif ($_GET['status']=="success") echo "<div class='admin-message' align='center'><b>Платёж успешно оплачен, ожидайте его обработки.</b></div>\n<br>";
	elseif ($_GET['status']=="fail") echo "<div class='admin-message' align='center'><b>Не удалось провести платёж, заказ отменён.</b></div>\n<br>";
}

if (dbrows($res)) {
	$data = dbarray($res);
	$vid = $data['vid'];
} else {
	$vid = 0;
}

if (!isset($_GET['rowstart']) || !isnum($_GET['rowstart'])) $rowstart = 0; else $rowstart = $_GET['rowstart'];
$items_per_page = 20;
$res = dbquery("SELECT * FROM ".DB_PREFIX."game_vip_pays WHERE ".($vid!=0?"vid='".$vid."' OR ":"")."sid='".intval($userdata['user_steam'])."' ORDER BY time DESC LIMIT $rowstart,$items_per_page");

echo "<center>[ <a href='".FUSION_SELF."?action=new'>Купить VIP</a> ]</center><br>";

if (dbrows($res)) {

	$rows = dbcount("(vid)", DB_PREFIX."game_vip_pays", ($vid!=0?"vid='".$vid."' OR ":"")."sid='".intval($userdata['user_steam'])."'");

	echo "<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
	<tr>
	<td class='tbl2'><b>#</b></td>
	<td class='tbl2'><b>Дата</b></td>
	<td class='tbl2'><b>Статус</b></td>
	<td class='tbl2'><b>Сумма</b></td>
	<td class='tbl2'><b>Опции</b></td>
	</tr>";
    $i = 0;
	while ($data = dbarray($res)) {
		$i % 2 == 0 ? $tclass="tbl1" : $tclass="tbl2";
		echo "<tr>
		<td class='$tclass'>".$data['pid']."</td>
		<td class='$tclass'>".showdate("%d/%m/%Y %H:%M",$data['time'])."</td>
		<td class='$tclass'>".get_pay_status($data['status'])."</td>
		<td class='$tclass'>".ceil($data['ammount'])." ".get_pay_type($data['ammount_type'])."</td>
		<td class='$tclass'><a href='".FUSION_SELF."?action=view&id=".$data['pid']."'>Подробнее</a></td>
		</tr>"; $i++;
	}
	echo "</table>";

	if ($rows > $items_per_page) echo "<div align='center' style='margin-top:5px;'>\n".makePageNav($rowstart,$items_per_page,$rows,3)."\n</div>\n";
} else {
	echo "<center>Вы ещё не совершали платежей.</center>";
}


/*} else {
	echo "<center>Вы ещё не совершали платежей.<br><a href='".VIP_BASEDIR."pays.php?action=new'><img src='".VIP_IMAGES."price_alert.png' alt='Купить' title='Купить'> Купить VIP</a></center>";
}*/

}

vip_footer();

closetable();

}

require_once THEMES."templates/footer.php";
?>