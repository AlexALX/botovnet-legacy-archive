<?php
/*-------------------------------------------------------+
| PHP-Fusion Content Management System
| Copyright (C) 2002 - 2011 Nick Jones
| http://www.php-fusion.co.uk/
+--------------------------------------------------------+
| This file patch is for make Steam AUTH
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

/*Put this code AFTER

// Autenticate user
require_once CLASSES."Authenticate.class.php";

Put next:
*/

if (isset($_GET['openid_sig'])) {
	include_once(INCLUDES."steam_auth.php");
	$steamid = SteamSignIn::validate();
	if ($steamid!="") {
		$res = dbquery("SELECT user_name,user_password FROM ".DB_USERS." WHERE user_steam='".intval($steamid)."'");
		if (dbrows($res)) {
			$data = dbarray($res);
			define("_GLOB_STEAM_AUTH",true);
			$_POST['login'] = true;
			$_POST['user_name'] = $data['user_name'];
			$_POST['user_pass'] = $data['user_password'];
			$_POST['remember_me'] = true;
			unset($data,$res);
		} else {
			@session_start();
			$_SESSION['steamid'] = intval($steamid);
			redirect(BASEDIR."register.php");
		}
	}
}