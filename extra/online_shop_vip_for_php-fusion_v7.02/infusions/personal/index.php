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

$res = dbquery("SELECT s.*, v.time AS vip_time, v.status AS vip_status FROM ".DB_PREFIX."game_stat s LEFT JOIN ".DB_PREFIX."game_vip v ON v.sid=s.sid WHERE s.sid='".$userdata['user_steam']."' ORDER BY last DESC LIMIT 1");

if (dbrows($res)) {

echo "<script type='text/javascript'>
function select_server(serv) {
	if (serv=='') {
		$('#server_content').html('');
	} else {
		$.ajax({
			type: 'POST',
			url: 'ajax.php',
			data: { server: serv }
		}).done(function( msg ) {
			if (msg=='Error'||msg=='') {
				$('#server_content').html('<center>Ошибка загрузки</center>');
			} else {
				$('#server_content').html(msg);
			}
		});
	}
}

$( document ).ready(function() {
	if ($('#server_select').val()!='') {
		select_server($('#server_select').val());
	}
});

var intervalID
function show_log(id,sid) {
	$('#server_log').remove();
	clearInterval(intervalID)
	$.ajax({
		type: 'POST',
		url: 'ajax.php?log',
		data: { server: id, sid: sid }
	}).done(function( msg ) {
		if (msg=='Error'||msg=='') {

		} else {
			$('body').append(msg);
			$('#server_log').dialog({
				width:600,
				close: function( event, ui ) { clearInterval(intervalID) }
			});
			intervalID = setInterval(function() { update_log(id,sid) },5000)
		}
	});
}

function update_log(id,sid) {
	$.ajax({
		type: 'POST',
		url: 'ajax.php?log',
		data: { server: id, sid: sid, cont: true }
	}).done(function( msg ) {
		if (msg=='Error'||msg=='') {

		} else {
			$('#server_log_cont').html(msg);
		}
	});
}

</script>";

$data = dbarray($res);

$data['total_time'] = dbresult(dbquery("SELECT sum(time) AS total_time FROM ".DB_PREFIX."game_stat WHERE sid='".$userdata['user_steam']."'"),0);

echo "<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>Общая статистика</b></td>
</tr>
<tr>
<td class='tbl2' width='50%'>Последний визит:</td>
<td class='tbl1'>".($data['last']>time()-360?"онлайн":showdate("%d/%m/%Y %H:%M",$data['last']))."</td>
</tr>
<tr>
<td class='tbl2' width='50%'>Последний сервер:</td>
<td class='tbl1'>".get_servers($data['server'],true)."</td>
</tr>
<tr>
<td class='tbl2'>Ник на сервере:</td>
<td class='tbl1'>".htmlspecialchars($data['name'])."</td>
</tr>";
echo "<tr>
<td class='tbl2'>Сыграно времени:</td>
<td class='tbl1'>".showtime($data['total_time'])."</td>
</tr>";
echo "<tr>
<td class='tbl2'>Тип аккаунта:</td>
<td class='tbl1'>".get_personal_type($data['vip_time'],$data['vip_status'])."</td>
</tr>";/*
echo "<tr>
<td class='tbl2'>Статус:</td>
<td class='tbl1'>".get_status($data['status'],$data['time'])."</td>
</tr>*/
echo "<tr>
<td class='tbl2'>Steam профиль:</td>
<td class='tbl1'><a href='http://steamcommunity.com/profiles/".intval($userdata['user_steam'])."' target='_blank'>".intval($userdata['user_steam'])."</a></td>
</tr>";
echo "</table>";

echo "<br><br><table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2' colspan='2' align='center'><b>Подробная статистика</b></td>
</tr>
<tr>
<td class='tbl1' colspan='2' align='center'><select class='textbox' style='width: 200px;' onchange='select_server(this.value)' id='server_select'>
<option value=''>- Выберите сервер -</option>\n";
$servers = servers_arr();
foreach($servers as $key=>$server) {
	echo "<option value='".$key."'>".$server[0]."</option>\n";
}
echo "</select></td>
</tr>
</table>";

echo "<br><br><div id='server_content'></div>";

} else {
	echo "<center>Вы ещё не играли на наших серверах.<br><a href='".BASEDIR."servers.php'>Наши сервера</a></center>";
}

closetable();

}

require_once THEMES."templates/footer.php";
?>