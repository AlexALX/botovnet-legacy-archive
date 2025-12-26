<?php
/*-------------------------------------------------------+
| PHP-Fusion Content Management System
| Copyright (C) 2002 - 2011 Nick Jones
| http://www.php-fusion.co.uk/
+--------------------------------------------------------+
| This script receive online players and deaths + some individual stats from RUST game server
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

function add_log($sid,$server,$message) {
$res = dbquery("DELETE FROM ".DB_PREFIX."game_rust_log
  WHERE time <= (
    SELECT time
    FROM (
      SELECT time
      FROM ".DB_PREFIX."game_rust_log
      WHERE sid='".$sid."' AND server='".$server."'
      ORDER BY time DESC
      LIMIT 1 OFFSET 20
    ) log
  ) AND sid='".$sid."' AND server='".$server."'");

$res = dbquery("INSERT INTO ".DB_PREFIX."game_rust_log VALUES(".time().",'".$sid."','".$server."','".$message."')");

}

function add_db($sid,$server,$animal=0,$name="player") {
	if ($animal==0) $name = "player";
	$res = dbquery("SELECT * FROM ".DB_PREFIX."game_stat_rust_ext WHERE sid='".$sid."' AND server='".$server."' AND animal='".$animal."' AND name='".$name."'");

	if (dbrows($res)) {
		$res = dbquery("UPDATE ".DB_PREFIX."game_stat_rust_ext SET count=count+1 WHERE sid='".$sid."' AND server='".$server."' AND animal='".$animal."' AND name='".$name."';");
	} else {
		$res = dbquery("INSERT INTO ".DB_PREFIX."game_stat_rust_ext VALUES('".$sid."','".$server."','".$animal."','".$name."',1);");
	}
}

if (isset($_GET['sid'])&&intval($_GET['sid'])!=0||isset($_GET['sidk'])&&intval($_GET['sidk'])!=0) {
$sid = intval($_GET['sid']);
$sidk = intval($_GET['sidk']);
$server = intval($_POST['server']);
$servers = servers_arr();
if ($server==0||!isset($servers[$server])&&$server!=99) die("Error");

if ($server==3||$server==2||$server==4) {
              /*
	if (isset($_GET['get_time'])) {
		if ($sid>0) {
			$res = dbquery("SELECT time FROM ".DB_PREFIX."game_stat_rust WHERE sid='".$sid."' AND server='".$server."';");
			if (dbrows($res)) {
            	$data = dbarray($res);
            	echo $data['time'];
			} else echo "0";
		}
	} else {    */
		$animal = intval($_POST['animal']);
		$killed = mysql_real_escape_string($_POST['killed']);
		$killer = mysql_real_escape_string($_POST['killer']);
		$message = mysql_real_escape_string($_POST['message']);

		if ($sid>0) add_log($sid,$server,$message);
		if ($sidk>0) add_log($sidk,$server,$message);
		if ($animal==0) {
			if ($sidk>0) add_db($sidk,$server);
			if ($sid>0) add_db($sid,$server);
		} elseif ($animal==1) {
			if ($sidk>0) add_db($sidk,$server,1,$killed);
		}
		if ($sid>0) $res = dbquery("UPDATE ".DB_PREFIX."game_stat_rust SET death=death+1 WHERE sid='".$sid."' AND server='".$server."';");
	//}
} elseif ($server==99) {
	$animal = intval($_POST['animal']);
	$killed = mysql_real_escape_string($_POST['killed']);
	$killer = mysql_real_escape_string($_POST['killer']);
	$message = mysql_real_escape_string($_POST['message']);

	file_put_contents("test.txt",$animal." | ".$killed." | ".$killer." | ".$message."\r\n",FILE_APPEND);
}

}

?>