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

echo "<table width='50%' cellpadding='0' cellspacing='1' align='center' class='tbl-border'>\n<tr>\n";
echo "<td width='50%' align='center' class='".(!isset($_GET['unreg']) ? "tbl1" : "tbl2")."' style='padding-left:10px;padding-right:10px;'><a class='side' href='".FUSION_SELF.$aidlink."'>Зарегестрированные</a></td>\n";
echo "<td width='50%' align='center' class='".(isset($_GET['unreg']) ? "tbl1" : "tbl2")."' style='padding-left:10px;padding-right:10px;'><a class='side' href='".FUSION_SELF.$aidlink."&unreg'>Не зарегестрированные</a></td>\n";
echo "</tr>\n</table>\n<br>";

$reg_url = (isset($_GET['unreg'])?"&unreg":"");
if (!isset($_GET['rowstart']) || !isnum($_GET['rowstart'])) $rowstart = 0; else $rowstart = $_GET['rowstart'];

if (isset($_GET['action'])) {

unset($res);

if ($_GET['action']=="view") {

if (!isset($_GET['sid'])||!isnum($_GET['sid'])) redirect(VIP_BASEDIR."admin/index.php".$aidlink);

$res = dbquery("SELECT s.*, v.time AS vip_time, v.status AS vip_status FROM ".DB_PREFIX."game_stat s LEFT JOIN ".DB_PREFIX."game_vip v ON v.sid=s.sid WHERE s.sid='".intval($_GET['sid'])."' ORDER BY last DESC LIMIT 1");

$data = dbarray($res);

$data['total_time'] = dbresult(dbquery("SELECT sum(time) AS total_time FROM ".DB_PREFIX."game_stat WHERE sid='".intval($_GET['sid'])."'"),0);

add_to_head("<script type='text/javascript' src='".INCLUDES."jquery/jquery.js'></script>");
add_to_head("<script type='text/javascript' src='".INCLUDES."jquery/jquery-ui.min.js'></script>");
add_to_head("<link rel='stylesheet' href='".INCLUDES."jquery/jquery-ui.min.css' type='text/css' media='screen' />");

echo "<script type='text/javascript'>
var sid = '".$data['sid']."';

function select_server(serv) {
	if (serv=='') {
		$('#server_content').html('');
	} else {
		$.ajax({
			type: 'POST',
			url: '../ajax.php',
			data: { server: serv, sid: sid, admin: true }
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
		url: '../ajax.php?log',
		data: { server: id, sid: sid, admin: true }
	}).done(function( msg ) {
		if (msg=='Error'||msg=='') {

		} else {
			$('body').append(msg);
			$('#server_log').dialog({
				width:600,
				close: function( event, ui ) { clearInterval(intervalID) }
			});
			intervalID = setInterval(function() { update_log(id,sid) },2500)
		}
	});
}

function update_log(id,sid) {
	$.ajax({
		type: 'POST',
		url: '../ajax.php?log',
		data: { server: id, sid: sid, cont: true, admin: true }
	}).done(function( msg ) {
		if (msg=='Error'||msg=='') {

		} else {
			$('#server_log_cont').html(msg);
		}
	});
}

</script>";

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
<td class='tbl1'><a href='http://steamcommunity.com/profiles/".intval($data['sid'])."' target='_blank'>".intval($data['sid'])."</a></td>
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

echo "<center>[ <a href='".FUSION_SELF.$aidlink.$reg_url.($rowstart>0?"&rowstart=".$rowstart:"")."'>Назад</a> ]</center>";

} else redirect(FUSION_SELF.$aidlink.$reg_url);

} else {

opentable("Статистика игроков");

if (isset($_GET['clean'])) {
	$res = dbquery("SELECT v.name, v.sid FROM ".DB_PREFIX."game_stat v LEFT JOIN ".DB_PREFIX."users u ON u.user_steam=v.sid WHERE u.user_steam IS NULL AND ( SELECT max(last) FROM ".DB_PREFIX."game_stat WHERE sid=v.sid )<='".(time()-60*60*24*30)."' AND ( SELECT sum(time) FROM ".DB_PREFIX."game_stat WHERE sid=v.sid )<='".(60*60*4)."' GROUP BY v.sid");
	$c = 0;
	$sids = array();
	while ($data = dbarray($res)) {
		echo $data['sid']." ".$data['name']." - Удалён<br>";
		$sids[] = $data['sid'];
		$c++;
	}
	if ($c>0) {
		$sid_sql = "('".implode("', '",$sids)."')";
		$res2 = dbquery("DELETE FROM ".DB_PREFIX."game_stat WHERE sid IN ".$sid_sql);
		$res2 = dbquery("DELETE FROM ".DB_PREFIX."game_stat_gmod WHERE sid IN ".$sid_sql);
		$res2 = dbquery("DELETE FROM ".DB_PREFIX."game_stat_rust WHERE sid IN ".$sid_sql);
		$res2 = dbquery("DELETE FROM ".DB_PREFIX."game_stat_rust_ext WHERE sid IN ".$sid_sql);
		$res2 = dbquery("DELETE FROM ".DB_PREFIX."game_rust_log WHERE sid IN ".$sid_sql);
		//echo $sid_sql."<br><br>";
		echo "Удалено записей: ".$c."<br>";
	}
}

$reg = (!isset($_GET['unreg'])?"u.user_steam IS NOT NULL":"u.user_steam IS NULL");

$search = "";
$type = "name";
$is_search = false;
if (isset($_POST['search'])) {
	$search = addslashes($_POST['search']);
	if ($search!="") {
		$type = (preg_match("/^(sid|name)$/",$_POST['type'])?$_POST['type']:"sid");
		$is_search = true;
	}
}

$items_per_page = 20;
if ($is_search) {
	$res = dbquery("SELECT v.*,u.user_name FROM ".DB_PREFIX."game_stat v LEFT JOIN ".DB_PREFIX."users u ON u.user_steam=v.sid
	  JOIN (SELECT sid, MAX(server), MAX(last) last
        FROM ".DB_PREFIX."game_stat
        GROUP BY sid
        ) tmp ON v.sid = tmp.sid AND v.last = tmp.last
	WHERE ".($type=="sid"?"sid='".$search."'":"name LIKE '%".$search."%'")." ORDER BY v.last DESC, v.name ASC");
} else {
	$res = dbquery("SELECT v.*, vd.time AS vip_time, vd.status AS vip_status ,u.user_name FROM ".DB_PREFIX."game_stat v LEFT JOIN ".DB_PREFIX."users u ON u.user_steam=v.sid
	  JOIN (SELECT sid, MAX(server), MAX(last) last
        FROM ".DB_PREFIX."game_stat
        GROUP BY sid
        ) tmp ON v.sid = tmp.sid AND v.last = tmp.last
   		LEFT JOIN ".DB_PREFIX."game_vip vd ON v.sid=vd.sid
	WHERE ".$reg." ORDER BY v.last DESC, v.name ASC LIMIT $rowstart,$items_per_page");
}

echo "<form name='searchform' action='".FUSION_SELF.$aidlink."' method='post'><center>Поиск: <input name='search' type='text' value='".$search."' class='textbox'> <select name='type' class='textbox'>
<option value='name'".($type=='name'?"selected":"").">Ник</option>
<option value='sid'".($type=='sid'?"selected":"").">SteamID</option>
</select> <input type='submit' value='ОК' class='button'></center></form><br>";

if (dbrows($res)) {

	if (isset($_GET['unreg'])) echo "<center>[ <a href='".FUSION_SELF.$aidlink."&clean".$reg_url."'>Очистить старые данные (1 мес)</a> ]</center><br>";

	if ($is_search) {
		$rows = dbrows($res);
	} else {
		$rows = dbquery("SELECT u.user_steam FROM ".DB_PREFIX."game_stat v LEFT JOIN ".DB_PREFIX."users u ON u.user_steam=v.sid WHERE ".$reg." GROUP BY v.sid");
		$rows = dbrows($rows);
	}

	echo "<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
	<tr>
	<td class='tbl2'><b>Логин</b></td>
	<td class='tbl2'><b>Ник</b></td>
	"./*<td class='tbl2'><b>Часов</b></td>*/
	(!isset($_GET['unreg'])?"<td class='tbl2'><b>Тип</b></td>":"").
	"<td class='tbl2'><b>Последний визит</b></td>
	<td class='tbl2'><b>Последний сервер</b></td>
	<td class='tbl2'><b>Опции</b></td>
	</tr>";
    $i = 0;
	while ($data = dbarray($res)) {
		$i % 2 == 0 ? $tclass="tbl1" : $tclass="tbl2";
		echo "<tr>
		<td class='$tclass'>".($data['user_name']!=""?$data['user_name']:"--")."</td>
		<td class='$tclass'>".htmlspecialchars($data['name'])."</td>
		"./*<td class='$tclass'>".showtime($data['total_time'])."</td>*/
		(!isset($_GET['unreg'])?"<td class='$tclass' title='".($data['vip_time']>0?get_time($data['vip_time']):"---")."'>".get_personal_type($data['vip_time'],$data['vip_status'])."</td>":"").
		"<td class='$tclass'>".($data['last']>time()-360?"онлайн":showdate("%d/%m/%Y %H:%M",$data['last']))."</td>
		<td class='$tclass'>".get_servers($data['server'])."</td>
		<td class='$tclass' width='20' align='center'>"
		."<a href='".FUSION_SELF.$aidlink.$reg_url."&rowstart=".$rowstart."&action=view&sid=".$data['sid']."'><img src='".VIP_IMAGES."directory_listing.png' alt='Просмотр' title='Просмотр'></a> "
		."</td>
		</tr>"; $i++;
	}
	echo "</table>";

echo "<script type='text/javascript'>
function check_delete() {
	return confirm('Вы дейтсвительно хотите удалить этот аккаунт вместе с его платежами?');
}
</script>";

	if ($rows > $items_per_page) echo "<div align='center' style='margin-top:5px;'>\n".makePageNav($rowstart,$items_per_page,$rows,3,FUSION_SELF.$aidlink.$reg_url."&")."\n</div>\n";
} else {
	if ($is_search) echo "<center>По вашему запросу ничего не найдено.</center>";
	else echo "<center>В базе данных нет игроков.</center>";
}

closetable();

if (dbrows($res)) {
	opentable("Информация");

	$c = dbquery("SELECT u.user_steam FROM ".DB_PREFIX."game_stat v LEFT JOIN ".DB_PREFIX."users u ON u.user_steam=v.sid WHERE u.user_steam IS NOT NULL GROUP BY v.sid");
	$creg = dbrows($c);

	$c = dbquery("SELECT u.user_steam FROM ".DB_PREFIX."game_stat v LEFT JOIN ".DB_PREFIX."users u ON u.user_steam=v.sid WHERE u.user_steam IS NULL GROUP BY v.sid");
	$cnreg = dbrows($c);

	echo "<table align='center' cellpadding='0' cellspacing='0' width='100%'>
	<tr>
	<td width='40%'>Зарегестрировано: ".$creg."</td>
	<td width='60%'>Играло за последние 24 часа: ".dbrows(dbquery("SELECT sid FROM ".DB_PREFIX."game_stat WHERE last>='".(time()-60*60*24)."' GROUP BY sid"))."</td>
	</tr>
	<tr>
	<td>Не зарегестрировано: ".$cnreg."</td>
	<td>Играло за последнюю неделю: ".dbrows(dbquery("SELECT sid FROM ".DB_PREFIX."game_stat WHERE last>='".(time()-60*60*24*7)."' GROUP BY sid"))."</td>
	</tr>
	</table>";

	closetable();
}

}

require_once THEMES."templates/footer.php";

?>