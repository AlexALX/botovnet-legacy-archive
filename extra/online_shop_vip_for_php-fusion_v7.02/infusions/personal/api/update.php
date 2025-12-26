<?php
/*-------------------------------------------------------+
| PHP-Fusion Content Management System
| Copyright (C) 2002 - 2011 Nick Jones
| http://www.php-fusion.co.uk/
+--------------------------------------------------------+
| This script receive online players + some other shared stat (gmod/rust)
| Used on Botov-NET rust server
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

$api_key = 'someKey';

if (!isset($_GET['key'])||$_GET['key']!=$api_key) die();

define("PERSONAL_API",true);
require_once("../core.php");

function share_update($sid,$server,$time,$name) {
	$res = dbquery("SELECT sid FROM ".DB_PREFIX."game_stat WHERE sid='".$sid."' AND server='".$server."'");
	if (dbrows($res)) {
		$res = dbquery("UPDATE ".DB_PREFIX."game_stat SET time='".$time."',name='".$name."',last='".time()."' WHERE sid='".$sid."' AND server='".$server."';");
	} else {
		$res = dbquery("INSERT INTO ".DB_PREFIX."game_stat VALUES('".$sid."','".$server."','".$time."','".$name."',".time().");");
	}
}

if (isset($_GET['sid'])&&intval($_GET['sid'])!=0||isset($_POST['players'])) {
$sid = intval($_GET['sid']);
$server = intval($_POST['server']);
$servers = servers_arr();
if ($server==0||!isset($servers[$server])) die("Error");

if ($server==1) {
	$res = dbquery("SELECT * FROM ".DB_PREFIX."game_stat_gmod WHERE sid='".$sid."' AND server='".$server."'");

	$time = intval($_POST['time']);
	$frags = intval($_POST['frags']);
	$death = intval($_POST['death']);

	$name = mysql_real_escape_string($_POST['name']);

	if (dbrows($res)) {
		$data = dbarray($res);

		$frags = $frags;
		$death = $death;
		$played = "";

		if (isset($_GET['stage'])&&$_GET['stage']=="connect") ",played=played+1";

		if ($time<$data['time']) $time = $data['time'];

		$res = dbquery("UPDATE ".DB_PREFIX."game_stat_gmod SET time=".$time.",frags=frags+".$frags.",death=death+".$death.$played.",last='".time()."' WHERE sid='".$sid."' AND server='".$server."';");
	} else {
		$res = dbquery("INSERT INTO ".DB_PREFIX."game_stat_gmod VALUES('".$sid."','".$server."',".$time.",".$frags.",".$death.",1,".time().");");
	}

	share_update($sid,$server,$time,$name);
} elseif ($server==2||$server==3||$server==4) {
	//if (isset($_POST['players'])) {
	//} else {
		$res = dbquery("SELECT * FROM ".DB_PREFIX."game_stat_rust WHERE sid='".$sid."' AND server='".$server."'");

		$time = intval($_POST['time']);

		$name = mysql_real_escape_string($_POST['name']);

		if (dbrows($res)) {
			$data = dbarray($res);

			$played = "";
			$time = $data['time']+$time;

			if (isset($_GET['stage'])&&$_GET['stage']=="connect") $played = ",played=played+1";

			if ($time<$data['time']) $time = $data['time'];

			$res = dbquery("UPDATE ".DB_PREFIX."game_stat_rust SET time=".$time.$played.",last='".time()."' WHERE sid='".$sid."' AND server='".$server."';");
		} else {
			$res = dbquery("INSERT INTO ".DB_PREFIX."game_stat_rust VALUES('".$sid."','".$server."',".$time.",0,1,".time().");");
		}

		echo "OK";

		share_update($sid,$server,$time,$name);
	//}
}

} else die("Error");

?>