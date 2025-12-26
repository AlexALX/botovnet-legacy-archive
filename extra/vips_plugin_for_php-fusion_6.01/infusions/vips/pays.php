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

$res = dbquery("SELECT vid,server,time,status FROM ".DB_PREFIX."csvips WHERE uid='".$userdata['user_id']."'");

if (isset($_GET['action'])) {

if ($_GET['action']=="new") {

if (dbrows($res)) {
	$data = dbarray($res);
	$resc = dbquery("SELECT pid FROM ".DB_PREFIX."csvips_pays WHERE vid='".$data['vid']."' AND status='0'");
} else {
	$data = array();
	$resc = "";
}

if (!$vip_sets['enabled']) {
	echo "<center><b>Невозможно купить VIP - система отключена.</b><br><br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";
} elseif ($resc!=""&&dbrows($resc)) {
	echo "<center><b>Невозможно купить VIP - у вас есть неоплаченые платежи.</b><br>Пожалуйста оплатите счёт или отмените платёж для повторного запроса на покупку.<br><br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";
} elseif (dbrows($res)&&$data['status']=='0') {
	echo "<center><b>Невозможно купить VIP - ваш аккаунт заморожен.</b><br><br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";
} elseif (dbrows($res)&&$data['status']=='2') {
	echo "<center><b>Невозможно купить VIP - ваш аккаунт заблокирован.</b><br><br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";
} else {

if (isset($_POST['save'])) {

	$vid = "";
	$error = "";
	$server = stripinput($_POST['server']);
	$time = stripinput($_POST['vip_time']);
	$amtype = stripinput($_POST['ammount_type']);

	if ($server==""||$time==""||$amtype==""||!isnum($server)||!isnum($time)||!isnum($amtype)) {
		if ($error!="") $error .= "<br>";
		$error .= "Не все обязательные поля были заполнены.";
	}

	if (!isset($_POST['accept'])||$_POST['accept']!="ON") {
		if ($error!="") $error .= "<br>";
		$error .= "Вы не согласились с условиями пользовательского соглашения!";
	}

	if (!dbrows($res)) {
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
			//echo "<div class='admin-message' align='center'><b>".$error."</b></div>\n<br>";
		} else {
			$res2 = dbquery("INSERT INTO ".DB_PREFIX."csvips VALUES('','".$userdata['user_id']."','".$type."','".$name."','".$password."','-1','".$server."','".get_default_flags()."','".$options."','0','1','".time()."','0')");
			if (!$res2) $error = "Произошла ошибка записи в базу данных.<br>Попробуйте ещё раз или обратитесь к системному администратору.";
			else $vid = mysql_insert_id();
		}
	}

	if ($error == "") {
		if (dbrows($res)&&is_array($data)) {
			$vid = $data['vid'];
		}
		if ($vid==""||!isnum($vid)) {
			$error = "Произошла ошибка записи в базу данных.<br>Попробуйте ещё раз или обратитесь к системному администратору.";
		}
	}

	if ($error != "") {
		echo "<div class='admin-message' align='center'><b>".$error."</b></div>\n<br>";
	} else {
		$calc = calculate_amount_desc($amtype,$time,$server);
		$res = dbquery("INSERT INTO ".DB_PREFIX."csvips_pays VALUES ('','".$vid."','".time()."','-1','".$calc[0]."','".$amtype."','','0','','','','0','".$calc[1]."','".$server."','".$time."');");
		if (!$res) redirect(FUSION_SELF."?status=error");
		else redirect(FUSION_SELF."?action=view&id=".mysql_insert_id());
	}

}

echo "<script type='text/javascript'>
function calculate_pay() {
	var pay = document.getElementById('pay_count');
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
	}
}
";
if ($data['time']>time()) {
$svrs = get_servers("",true);
foreach ($svrs as $key=>$svr) {
	$svr = explode(",",$svr);
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
</script>";

echo "<form name='actionform' action='".FUSION_SELF."?action=new' method='post' onSubmit='return ValidateForm(this);'>
<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>Покупка VIP Аккаунта для ".$userdata['user_name']."</b></td>
</tr>
<tr>
<td class='tbl2'>Валюта:</td>
<td class='tbl1'><select class='textbox' name='ammount_type' onchange='calculate_pay()' id='type'>
  <option value='0'>Гривны (WMU)</option>
  <option value='1'>Рубли (WMR)</option>
</select></td>
</tr>
<tr>
<td class='tbl2'>Срок:</td>
<td class='tbl1'><select class='textbox' name='vip_time' onchange='calculate_pay()' id='time'>
  <option value='0'>2 Недели</option>
  <option value='1'>1 Месяц</option>
  <option value='2'>2 Месяца</option>
  <option value='3'>3 Месяца</option>
  <option value='4'>6 Месяцев</option>
</select></td>
</tr>
<tr>
<td class='tbl2'>Сервер:</td>
<td class='tbl1'><select class='textbox' name='server' onchange='calculate_pay()' id='server'>
<option value=''>Выберите</option>
<option value='0'>Все</option>\n";
$servers = get_servers("",true);
foreach ($servers as $key=>$serv) {
	if ($key!=8) continue;
	echo "<option value='".$key."'>".$serv."</option>";
}
echo "<option value='' disabled>Rust Experimental - botov.net.ua:29015</option>
</select></td>
</tr>
<tr>
<td class='tbl2'>Итого к оплате:</td>
<td class='tbl1' id='pay_count'>--</td>
</tr>
<tr>
<td class='tbl2'>Подверждение</td>
<td class='tbl1'><label><input name='accept' type='checkbox' value='ON' id='accept'> Я согласен с условиями</label> <a href='".VIP_BASEDIR."lic.php' target='_blank'>пользовательского соглашения</a>.</td>
</tr>";

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

} elseif ($data['time']>time()) {

$sv = explode(",",get_servers($data['server'],false,true));

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

}

} elseif ($_GET['action']=="view") {

if (!dbrows($res)) redirect(FUSION_SELF);

if (!isset($_GET['id'])||!isnum($_GET['id'])) redirect(FUSION_SELF);

$res = dbquery("SELECT p.*, v.status AS vip_status FROM ".DB_PREFIX."csvips_pays p LEFT JOIN ".DB_PREFIX."csvips v ON v.vid=p.vid WHERE p.pid='".$_GET['id']."'");

if (dbrows($res)) {

if (isset($_GET['status'])) {
	if ($_GET['status']=="cancel") echo "<div class='admin-message' align='center'><b>Ваш платёж успешно отменён.</b></div>\n<br>";
	elseif ($_GET['status']=="error") echo "<div class='admin-message' align='center'><b>Произошла ошибка при добавлении платежа.</b><br>Попробуйте ещё раз или обратитесь к системному администратору.</div>\n<br>";
}

$data = dbarray($res);

if (isset($_GET['cancel'])&&$data['status']=='0'&&$data['vip_status']=='1') {
	$res = dbquery("UPDATE ".DB_PREFIX."csvips_pays SET status='3' WHERE pid='".$data['pid']."'");
	redirect(FUSION_SELF."?action=view&id=".$data['pid']."&status=cancel");
}

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
<td class='tbl1'>".get_servers($data['server'],false,true)."</td>
</tr>
<tr>
<td class='tbl2'>Срок:</td>
<td class='tbl1'>".get_vip_time($data['vip_time'])."</td>
</tr>";

echo "</table><center>";

if (!$vip_sets['enabled']) {
	echo "<b>Невозможно оплатить или отменить счёт - система отключена.</b><br>";
} elseif ($data['vip_status']=='0') {
	echo "<b>Невозможно оплатить или отменить счёт - ваш аккаунт заморожен.</b><br>";
} elseif ($data['vip_status']=='2') {
	echo "<b>Невозможно оплатить или отменить счёт - ваш аккаунт заблокирован.</b><br>";
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
	</tr>
	<tr>
	<td class='tbl2' colspan='2' align='center'><img src='".VIP_IMAGES."wm/visa.png' alt='help' style='vertical-align:middle;'> <b>Оплатить банковской карточкой</b></td>
	</tr>
	<tr>
	<td class='tbl1' colspan='2'>Если у вас есть банковская карточка Visa, MasterCard или счёт в Приват24, то вы можете оплатить в <u>ручном режиме</u>, оставив заявку написав <a href='".BASEDIR."messages.php?msg_send=1' target='_blank'>личное сообщение</a>.<br>В заявке вы должны написать что желаете купить vip, номер счёта (№".$data['pid']."), и ожидать дальнейших иструкций (в течении 3х дней).<br><b>Внимание!</b> Данный способ доступен только при оплате <u>гривной</u>.</td>
	</tr>
	</table>";
	echo "<br>[ <a href='".FUSION_SELF."?action=view&id=".$data['pid']."&cancel'><b>Отменить заказ</b></a> ]<br>";
	}
}

echo "<br>[ <a href='".FUSION_SELF."'>Назад</a> ]</center>";

}

}

} else {

if (dbrows($res)) {

if (isset($_GET['fail'])||isset($_GET['success'])) {
	if (isset($_POST['LMI_PAYMENT_NO'])&&isnum($_POST['LMI_PAYMENT_NO'])) {
		$res = dbquery("SELECT pid FROM ".DB_PREFIX."csvips_pays WHERE pid='".$_POST['LMI_PAYMENT_NO']."'".(isset($_GET['fail'])?" AND status='0'":""));
		if (dbrows($res)) {
			$fields = array("LMI_SYS_INVS_NO","LMI_SYS_TRANS_NO","LMI_SYS_TRANS_DATE","LMI_PAYMER_NUMBER","LMI_PAYMER_EMAIL","LMI_EURONOTE_NUMBER",
			"LMI_EURONOTE_EMAIL","LMI_WMCHECK_NUMBER","LMI_TELEPAT_PHONENUMBER","LMI_TELEPAT_ORDERID","LMI_PAYMENT_CREDITDAYS");
			$arr = array("LMI_SYS_INVS_NO"=>"","LMI_SYS_TRANS_NO"=>"");
			foreach($_POST as $key=>$val) {
				if (in_array($key,$fields)&&trim($val)!="") {
					$arr[$key] = stripinput($val);
				}
			}
			$res = dbquery("UPDATE ".DB_PREFIX."csvips_pays SET".(isset($_GET['fail'])?" status='2', type='0',":"")." wm_sys_invs='".$arr["LMI_SYS_INVS_NO"]."',".
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

$data = dbarray($res);

if (!isset($_GET['rowstart']) || !isnum($_GET['rowstart'])) $rowstart = 0; else $rowstart = $_GET['rowstart'];
$items_per_page = 20;
$res = dbquery("SELECT * FROM ".DB_PREFIX."csvips_pays WHERE vid='".$data['vid']."' ORDER BY time DESC LIMIT $rowstart,$items_per_page");

echo "<center>[ <a href='".FUSION_SELF."?action=new'>Купить VIP</a> ]</center><br>";

if (dbrows($res)) {

	$rows = dbcount("(vid)", "csvips_pays", " vid='".$data['vid']."'");

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


} else {
	echo "<center>Вы ещё не совершали платежей.<br><a href='".VIP_BASEDIR."pays.php?action=new'><img src='".VIP_IMAGES."price_alert.png' alt='Купить' title='Купить'> Купить VIP</a></center>";
}

}

vip_footer();

closetable();

}

require_once BASEDIR."side_right.php";
require_once BASEDIR."footer.php";
?>