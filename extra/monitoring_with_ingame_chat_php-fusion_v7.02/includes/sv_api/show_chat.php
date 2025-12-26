<?php
/*-------------------------------------------------------+
| PHP-Fusion Content Management System
| Copyright (C) 2002 - 2011 Nick Jones
| http://www.php-fusion.co.uk/
+--------------------------------------------------------+
| This script receive in-game chat from gmod server
| Other part of it is:
| web-update.lua on gmod-server
| Used on Botov-NET gmod server
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

//require("../../infusions/personal/core.php");
require("../../maincore.php");

$server = intval($_POST['server']);
$name = stripinput($_POST['name']);
//$servers = servers_arr();
//if ($server==0||!isset($servers[$server])) die("Error");

$json = array();

if (file_exists("cache/".$server.".cache")) {
$json = unserialize(file_get_contents("cache/".$server.".cache"));
if (!is_array($json)) $json = array();
//$json = array_slice($json,-15);
}

//$json = array_reverse($json);

if (!isset($_POST['cont'])) echo "<div id='server_chat' style='display:none' title=\"".htmlspecialchars($name)."\"><div id='server_chat_cont' style='height: 300px;'>";
foreach($json as $time=>$arr) {
	if (isset($arr[4])) {
		echo "[".showdate("%H:%M:%S",$arr[0])."] ".htmlspecialchars($arr[3])."<br>";
	} else {
		echo "[".showdate("%H:%M:%S",$arr[0])."] <b><span style='color:rgba(".htmlspecialchars($arr[2]).",1);'>".htmlspecialchars($arr[1])."</span>:</b> ".htmlspecialchars($arr[3])."<br>";
	}
}
if (!isset($_POST['cont'])) echo "</div></div>";

?>