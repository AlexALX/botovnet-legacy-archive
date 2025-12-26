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

// must match gmod web-update.lua key
$api_key = "someKey";

if (!isset($_GET['key'])||$_GET['key']!=$api_key) die();

require("../../maincore.php");

$server = intval($_POST['server']);
//$servers = servers_arr();
//if ($server==0||!isset($servers[$server])) die("Error");

$json = array();

if (trim($_POST['message'])=="") die();

if (file_exists("cache/".$server.".cache")) {
$json = unserialize(file_get_contents("cache/".$server.".cache"));
if (!is_array($json)) $json = array();
$json = array_slice($json,-30);
}

if (isset($_POST['msg'])) $json[$_POST['time']] = array($_POST['time'],"","",$_POST['message'],true);
else $json[$_POST['time']] = array($_POST['time'],$_POST['name'],$_POST['color'],$_POST['message']);

file_put_contents("cache/".$server.".cache",serialize($json));

?>