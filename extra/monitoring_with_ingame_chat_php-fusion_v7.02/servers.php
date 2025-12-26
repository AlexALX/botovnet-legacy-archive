<?php
/*-------------------------------------------------------+
| PHP-Fusion Content Management System
| Copyright (C) 2002 - 2011 Nick Jones
| http://www.php-fusion.co.uk/
+--------------------------------------------------------+
| This script was a page with game servers info and online players
| Also did displayed in-game chat from rust servers
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

require_once "maincore.php";
require_once THEMES."templates/header.php";

include(INCLUDES."monitoring.php");

add_to_title("Мониторинг наших серверов");

$s = 0;
$server = array();

$server[$s] = array();
$server[$s]['ip'] = "botov.net.ua";
$server[$s]['port'] = "29015";
$server[$s]['rip'] = "192.168.100.1";
$server[$s]['rport'] = "29016";
//$server[$s]['dname'] = "RU-UA - Bыживaниe - Бoльшe дepeвa Botov.NET.UA";
//$server[$s]['nav'] = "---";
$server[$s]['status'] = '';
$server[$s]['game'] = 'rust';
$server[$s]['protocol'] = 'sq';
$server[$s]['id'] = '3';
$server[$s]['cid'] = '1';
$s++;

$server[$s] = array();
$server[$s]['ip'] = "botov.net.ua";
$server[$s]['port'] = "29020";
$server[$s]['rip'] = "192.168.100.1";
$server[$s]['rport'] = "29021";
//$server[$s]['dname'] = "RU-UA 8KM|4xCбop|TП|HOME|Kиты|EVENT - Botov.NET.UA";
//$server[$s]['nav'] = "---";
$server[$s]['status'] = '';
$server[$s]['game'] = 'rust';
$server[$s]['protocol'] = 'sq';
$server[$s]['id'] = '2';
$server[$s]['cid'] = '2';
$s++;
                             /*
$server[$s] = array();
$server[$s]['ip'] = "botov.net.ua";
$server[$s]['port'] = "29025";
$server[$s]['rip'] = "192.168.100.1";
$server[$s]['rport'] = "29026";
//$server[$s]['dname'] = "RU-UA 8KM|4xCбop|TП|HOME|Kиты|EVENT - Botov.NET.UA";
//$server[$s]['nav'] = "---";
$server[$s]['status'] = '';
$server[$s]['game'] = 'rust';
$server[$s]['protocol'] = 'sq';
$server[$s]['id'] = '4';
$server[$s]['cid'] = '3';
$s++;
                    */
$server[$s] = array();
$server[$s]['ip'] = "botov.net.ua";
$server[$s]['port'] = "28015";
$server[$s]['rip'] = "192.168.100.1";
$server[$s]['rport'] = "28015";
//$server[$s]['dname'] = "UA-IX Ukraine (Russian) Botov.NET.UA Gmod Stargate Server";
//$server[$s]['nav'] = "---";//"<b><a href='http://botov.net.ua/forum/index.php?showforum=46'>Форум</a></b> | <b><a href='http://botov.net.ua/forum/index.php?showtopic=2449'>Правила</a></b> | <a href='http://botov.net.ua/forum/index.php?showtopic=2445'>Необходимые аддоны</a> | <a href='http://botov.net.ua/forum/index.php?showtopic=2447'>Список карт сервера</a>";
$server[$s]['status'] = '';
$server[$s]['game'] = 'source';
$server[$s]['protocol'] = 'sq';
$server[$s]['id'] = '1';
$s++;

if (isset($_GET['sv_test'])&&$_GET['sv_test']=="99") {
$server[$s] = array();
$server[$s]['ip'] = "botov.net.ua";
$server[$s]['port'] = "29095";
$server[$s]['rip'] = "192.168.100.1";
$server[$s]['rport'] = "29096";
//$server[$s]['dname'] = "RU-UA 8KM|4xCбop|TП|HOME|Kиты|EVENT - Botov.NET.UA";
//$server[$s]['nav'] = "---";
$server[$s]['status'] = '';
$server[$s]['game'] = 'rust';
$server[$s]['protocol'] = 'sq';
$server[$s]['id'] = '99';
$server[$s]['cid'] = '99';
$s++;

}

    /*
$server[$s] = array();
$server[$s]['ip'] = "botov.net.ua";
$server[$s]['port'] = "28016";
$server[$s]['rip'] = "192.168.100.1";
$server[$s]['rport'] = "28016";
$server[$s]['dname'] = "UA-IX Ukraine (Russian) Botov.NET.UA Gmod Train Server";
//$server[$s]['nav'] = "---";
$server[$s]['status'] = '';
$server[$s]['game'] = 'source';
$server[$s]['protocol'] = 'sq';
$server[$s]['id'] = '2';
$s++;    */

opentable("Мониторинг наших серверов");

$ic = array("on" => "0", "all" => "0", "plo" => "0", "pla" => "0");

foreach($server as $i=>$arr) {
//if (!isset($arr['dname'])) continue;

$arr['dname'] = "Error";
$cfil = INCLUDES."sv_api/cache/".$arr['id']."-dname.cache";
if (file_exists($cfil)) {
	$arr['dname'] = htmlspecialchars(file_get_contents($cfil));
}

if ($i != 0) echo "<br>";

if ($arr['status'] != 'closed') {

//if ($server[$i]['protocol'] == 'sq') {
$serv = serverInfo_sq($arr['rip'], $arr['rport'], ($arr['game'])!=""?$arr['game']:"", $arr['dname'],$arr['cid']);
//}

if (isset($serv['name'])&&$serv['name']!=""&&$serv['name']!=$arr['dname']) {
	file_put_contents($cfil,$serv['name']);
	$arr['dname'] = $serv['name'];
}

echo "<script type='text/javascript'>
<!--
function toggle_sup".$i."() {
	var smu = document.getElementById('show_users".$i."');
	var smutxt = document.getElementById('show_users_text".$i."');
	if (smu.style.display == 'none') {
		smu.style.display = 'block';
		smutxt.innerHTML = 'Игроки:';
	} else {
		smu.style.display = 'none';
		smutxt.innerHTML = 'Игроки';
	}
}

function toggle2_sup".$i."() {
	var smu = document.getElementById('show_info".$i."');
	var smutxt = document.getElementById('show_info_text".$i."');
	if (smu.style.display == 'none') {
		smu.style.display = 'block';
		smutxt.innerHTML = 'Дополнительно:';
	} else {
		smu.style.display = 'none';
		smutxt.innerHTML = 'Дополнительно';
	}
}

var intervalID
function show_chat(id,name) {
	$('#server_chat').remove();
	clearInterval(intervalID)
	$.ajax({
		type: 'POST',
		url: 'includes/sv_api/show_chat.php',
		data: { server: id, name: name }
	}).done(function( msg ) {
		if (msg=='Error'||msg=='') {

		} else {
			$('body').append(msg);
			$('#server_chat').dialog({
				width:600,
				close: function( event, ui ) { clearInterval(intervalID) }
			});
			intervalID = setInterval(function() { update_chat(id,name) },5000)
		}
	});
}

function update_chat(id,name) {
	$.ajax({
		type: 'POST',
		url: 'includes/sv_api/show_chat.php',
		data: { server: id, name: name, cont: true }
	}).done(function( msg ) {
		if (msg=='Error'||msg=='') {

		} else {
			$('#server_chat_cont').html(msg);
		}
	});
}

//-->
</script>";
}

echo "<table cellpadding='1' cellspacing='1' width='100%' class='tbl-border'>\n";

$ic['all']++;

if ($arr['status'] == 'closed') {

echo "<tr>
<td class='tbl2' width='50%'><b>".$arr['dname']."</b></td>
<td class='tbl2' align='right'>".$arr['ip'].":".$arr['port']."</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Статус:</b></td>
<td class='tbl1' align='right'><b><span style='color:red'>Закрыт</span></b></td>
</tr>";
} else if ($arr['status'] == 'disabled') {

echo "<tr>
<td class='tbl2' width='50%'><b>".$arr['dname']."</b></td>
<td class='tbl2' align='right'>".$arr['ip'].":".$arr['port']."</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Статус:</b></td>
<td class='tbl1' align='right'><b><span style='color:gray'>Выключен</span></b></td>
</tr>";
} else if ($serv['status'] == 'off') {

echo "<tr>
<td class='tbl2' width='50%'><b>".$arr['dname']."</b></td>
<td class='tbl2' align='right'>".$arr['ip'].":".$arr['port']."</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Статус:</b></td>
<td class='tbl1' align='right'><b><span style='color:red'>не работает</span></b> (возможно смена карты)</td>
</tr>";

} else {

if ($arr['steam']=='disable') {
echo "<tr>
<td class='tbl2' width='50%'><b>".$serv['name']."</b></td>
<td class='tbl2' align='right' width='50%' colspan='2'>".$arr['ip'].":".$arr['port']."</td>
</tr>";
} else {
echo "<tr>
<td class='tbl2' width='50%'><b>".$serv['name']."</b></td>
<td class='tbl2' align='right' width='50%'>".$arr['ip'].":".$arr['port']."</td>
<td class='tbl2' width='1%'><a href='steam://connect/".$arr['ip'].":".($arr['game']=="rust"?$arr['rport']:$arr['port'])."' target='_blank'><img src='".IMAGES."steam.png' style='margin:0px;' border='0' alt='Соединиться через steam' title='Соединиться через steam'></a></td>
</tr>";
}

echo "<tr>
<td class='tbl1' width='50%'><b>Статус:</b></td>
<td class='tbl1' align='right' colspan='2'><b><span style='color:green'>работает</span></b></td>
</tr>";

$ic['on']++;

if ($serv['os'] == 'l') {
$os = "Linux";
} else if ($serv['os'] == 'w') {
$os = "Linux (wine)";
} else {
$os = "<span style='color:red'>ошибка определения</span>";
}

echo "<tr>
<td class='tbl1' width='50%'><b>ОС:</b></td>
<td class='tbl1' align='right' colspan='2'>".$os."</td>
</tr>";

if ($serv['cpu']!="") {
echo "<tr>
<td class='tbl1' width='50%'><b>Загрузка ЦП:</b></td>
<td class='tbl1' align='right' colspan='2'>".$serv['cpu']."</td>
</tr>";
}

echo "<tr>
<td class='tbl1' width='50%'><b>Игроков:</b></td>
<td class='tbl1' align='right' colspan='2'>".($serv['players']!=""||$serv['maxplayers']!=""?$serv['players']."/".$serv['maxplayers']:"<span style='color:red'>ошибка определения</span>")."</td>
</tr>";

$ic['plo'] += $serv['players'];
$ic['pla'] += $serv['maxplayers'];

echo "<tr>
<td class='tbl1' width='50%'><b>Карта:</b></td>
<td class='tbl1' align='right' colspan='2'>".($serv['map']?$serv['map']:"<span style='color:red'>ошибка определения</span>")."</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Игра:</b></td>
<td class='tbl1' align='right' colspan='2'>".($serv['game']?$serv['game']:"<span style='color:red'>ошибка определения</span>")."</td>
</tr>";

if ($arr['protocol']=="sq"&&$arr['game']!="rust") {

echo "<tr>
<td class='tbl2' colspan='3' align='center'><img alt='' border='0' src='".THEME."images/bullet.gif'>&nbsp;
<b><a href=\"javascript:void(0)\" onClick=\"toggle2_sup".$i."();\"><span id='show_info_text".$i."'>Дополнительно</span></a></b>&nbsp;
<img alt='' border='0' src='".THEME."images/bulletb.gif'>
</td>
</tr>";

echo "<tr>
<td class='tbl1' colspan='3'><div id='show_info".$i."' style='display: none;'><table cellpadding='1' cellspacing='1' align='center' class='tbl-border'>\n";

if ($serv['metamod'] || $serv['amxmodx'] || $serv['amxbans'] || $serv['dproto']
|| $serv['csdm'] || $serv['rhlg'] || $serv['hlg'] || $serv['cap']) echo "<tr>
<td class='tbl2' align='center' colspan='3'><b>Аддоны</b></td>
</tr>";

if ($serv['metamod']) echo "<tr>
<td class='tbl1'><b>MetaMod</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['metamod']."</td>
</tr>";

if ($serv['dproto']) echo "<tr>
<td class='tbl1'><b>Dproto</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['dproto']."</td>
</tr>";

if ($serv['amxmodx']) echo "<tr>
<td class='tbl1'><b>AMXModX</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['amxmodx']."</td>
</tr>";

if ($serv['cap']) echo "<tr>
<td class='tbl1'><b>Carter Addon Pack</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['cap']."</td>
</tr>";

if ($serv['amxbans']) echo "<tr>
<td class='tbl1'><b>AMXBans</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['amxbans']."</td>
</tr>";

if ($serv['hlg']) echo "<tr>
<td class='tbl1'><b>HLGuard</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['hlg']."</td>
</tr>";

if ($serv['rhlg']) echo "<tr>
<td class='tbl1'><b>Reallite HLGuard</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['rhlg']."</td>
</tr>";

if ($serv['csdm']) echo "<tr>
<td class='tbl1'><b>CSDM</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['csdm']."</td>
</tr>";

if ($serv['bio']) echo "<tr>
<td class='tbl1'><b>Biohazard</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['bio']."</td>
</tr>";

if ($serv['usurf']) echo "<tr>
<td class='tbl1'><b>uSurf</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['usurf']."</td>
</tr>";

if ($serv['gg']) echo "<tr>
<td class='tbl1'><b>GunGame</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['gg']."</td>
</tr>";

if ($serv['dr']) echo "<tr>
<td class='tbl1'><b>DeathRun</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['dr']."</td>
</tr>";

if ($serv['atac']) echo "<tr>
<td class='tbl1'><b>ATAC</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['atac']."</td>
</tr>";

if ($serv['upatch']) echo "<tr>
<td class='tbl1'><b>Unicode Patch</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['upatch']."</td>
</tr>";

//if ($serv['amxmodx']) {

echo "<tr>
<td class='tbl2' align='center' colspan='3'><b>Прочее</b></td>
</tr>";

if (trim($serv['password'])!="") echo "<tr>
<td class='tbl1'><b>Нужен пароль:</b></td>
<td class='tbl2' align='right' colspan='2'>".($serv['password'] ? "да" : "нет")."</td>
</tr>";

if ($serv['nextmap']!="") echo "<tr>
<td class='tbl1'><b>Следующая карта:</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['nextmap']."</td>
</tr>";

if ($serv['timeleft']!="") echo "<tr>
<td class='tbl1'><b>Осталось:</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['timeleft']."</td>
</tr>";
    /*
if ($serv['sv_type']!="") echo "<tr>
<td class='tbl1'><b>Тип сервера:</b></td>
<td class='tbl2' align='right' colspan='2'>".($serv['sv_type'] == "d" ? "dedicated" : "listen")."</td>
</tr>"; */
/*
if ($serv['timelimit']!="") echo "<tr>
<td class='tbl1'><b>Время на карту:</b></td>
<td class='tbl2' align='right' colspan='2'>".($serv['timelimit'] ? $serv['timelimit']." мин" : "неограниченно")."</td>
</tr>";
*/
if ($serv['rt']!="") echo "<tr>
<td class='tbl1'><b>Время раунда:</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['rt']." мин</td>
</tr>";

if ($serv['ft']!="") echo "<tr>
<td class='tbl1'><b>Задержка:</b></td>
<td class='tbl2' align='right' colspan='2'>".$serv['ft']." сек</td>
</tr>";

if ($serv['ff']!="") echo "<tr>
<td class='tbl1'><b>Огонь по своим:</b></td>
<td class='tbl2' align='right' colspan='2'>".($serv['ff'] ? "вкл" : "выкл")."</td>
</tr>";

if ($serv['fl']!="") echo "<tr>
<td class='tbl1'><b>Фонарик:</b></td>
<td class='tbl2' align='right' colspan='2'>".($serv['fl'] ? "вкл" : "выкл")."</td>
</tr>";

if ($serv['tkp']!="") echo "<tr>
<td class='tbl1'><b>Наказание за ТК:</b></td>
<td class='tbl2' align='right' colspan='2'>".($serv['tkp'] ? "вкл" : "выкл")."</td>
</tr>";

if ($serv['ve']!="") echo "<tr>
<td class='tbl1'><b>Микрофон:</b></td>
<td class='tbl2' align='right' colspan='2'>".($serv['ve'] ? "вкл" : "выкл")."</td>
</tr>";

//}

echo "</table>\n</div></td>
</tr>";

}

if ($serv['players'] == "0") {

echo "<tr>
<td class='tbl2' colspan='3' align='center'><b>Игроков нет.</b></td>
</tr>";

} else if ($serv['players'] == "") {

echo "<tr>
<td class='tbl2' colspan='3' align='center'><b><span style='color:red'>Ошибка определения игроков.</span></b></td>
</tr>";

} else {

echo "<tr>
<td class='tbl2' colspan='3' align='center'><img alt='' border='0' src='".THEME."images/bullet.gif'>&nbsp;
<b><a href=\"javascript:void(0)\" onClick=\"toggle_sup".$i."();\"><span id='show_users_text".$i."'>Игроки</span></a></b>&nbsp;
<img alt='' border='0' src='".THEME."images/bulletb.gif'>
</td>
</tr>";

echo "<tr>
<td class='tbl1' colspan='3'><div id='show_users".$i."' style='display: none;'><table cellpadding='1' cellspacing='1' width='100%' class='tbl-border'>
<tr>
<td class='tbl2' align='center'><b>#</b></td>
<td class='tbl2' width='80%'><b>Ник</b></td>
<td class='tbl2' width='20%' align='center'><b>Счёт</b></td>
<td class='tbl2' align='center'><b>Время</b></td>
</tr>\n";

for ($p=0;$p<count($serv[stats]);$p++) {

echo "<tr>
<td class='tbl1' align='center'>".($p+1)."</td>
<td class='tbl1' width='95%'>".stripinput($serv[stats][$p]['name'])."</td>
<td class='tbl1' width='5%' align='center'>".$serv[stats][$p]['kills']."</td>
<td class='tbl1' align='center'>".$serv[stats][$p]['time']."</td>
</tr>\n";

}

echo "</table>\n</div></td>
</tr>";

}

}

if (isset($arr['nav'])) {
echo "<tr>
<td class='tbl2' align='center' colspan='3'>".$arr['nav']."</td>
</tr>";
}

if (file_exists(INCLUDES."sv_api/cache/".($arr['id']).".cache")) {
echo "<tr>
<td class='tbl2' colspan='3' align='center'><b><a href='#' onclick=\"show_chat(".($arr['id']).",'".$arr['dname']."'); return false;\">Чат сервера</a></b></td>
</tr>";
}

echo "</table>\n";

}

echo "<br><table cellpadding='1' cellspacing='1' width='100%' class='tbl-border'>\n";

echo "<tr>
<td class='tbl2' width='50%' align='center' colspan='2'><b>Статистика</b></td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Онлайн серверов/Всего:</b></td>
<td class='tbl1' align='right'>".$ic['on']."/".$ic['all']."</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Онлайн игроков/Мест:</b></td>
<td class='tbl1' align='right'>".$ic['plo']."/".$ic['pla']."</td>
</tr>";

echo "</table>";

closetable();

require_once THEMES."templates/footer.php";

?>