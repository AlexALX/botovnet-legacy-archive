<?php
/*-------------------------------------------------------+
| PHP-Fusion Content Management System
| Copyright (C) 2002 - 2011 Nick Jones
| http://www.php-fusion.co.uk/
+--------------------------------------------------------+
| Filename: user_steam_include.php
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
if (!defined("IN_FUSION")) { die("Access Denied"); }

// Display user field input
if ($profile_method == "input") {
	/*$user_steam = isset($user_data['user_steam']) ? $user_data['user_steam'] : "";
	if ($this->isError()) { $user_steam = isset($_POST['user_steam']) ? stripinput($_POST['user_steam']) : $user_steam; }

	echo "<tr>\n";
	echo "<td class='tbl".$this->getErrorClass("user_steam")."'><label for='user_steam'>".$locale['uf_icq'].$required."</label></td>\n";
	echo "<td class='tbl".$this->getErrorClass("user_steam")."'>";
	echo "<input type='text' id='user_steam' name='user_steam' value='".$user_steam."' maxlength='16' class='textbox' style='width:200px;' />";
	echo "</td>\n</tr>\n";

	if ($required) { $this->setRequiredJavaScript("user_steam", $locale['uf_icq_error']); }
     */

 	if (iGUEST&&defined("_GLOB_STEAM64")) {        $steamid = intval(_GLOB_STEAM64);
        $_SESSION['steamid'] = $steamid;
 	} else { 		$steamid = intval($user_data['user_steam']);
 	}

	echo "<tr>\n";
	echo "<td class='tbl".$this->getErrorClass("user_steam")."'><label for='user_steam'>Steam профиль:</label></td>\n";
	echo "<td class='tbl".$this->getErrorClass("user_steam")."'>";
	echo "<a href='http://steamcommunity.com/profiles/".$steamid."' target='_blank'>".$steamid."</a> <img src='".INFUSIONS."personal/images/help.png' title='Изменение steam профиля возможно только по запросу к адмистрации данного сайта при наличии уважительной причины'>";
	echo "</td>\n</tr>\n";

// Display in profile
} elseif ($profile_method == "display") {
	if ($user_data['user_steam']) {
		echo "<tr>\n";
		echo "<td class='tbl1'>Steam профиль:</td>\n";
		echo "<td align='right' class='tbl1'><a href='http://steamcommunity.com/profiles/".intval($user_data['user_steam'])."' target='_blank'>перейти</a></td>\n";
		echo "</tr>\n";
	}

// Insert and update
} elseif ($profile_method == "validate_insert" /* || $profile_method == "validate_update"*/) {
	$this->_setDBValue("user_steam", intval($_POST['user_steam']));
	/*// Get input data
	if (isset($_POST['user_steam']) && ($_POST['user_steam'] != "" || $this->_isNotRequired("user_steam"))) {
		if (isnum($_POST['user_steam']) || $_POST['user_steam'] == "") {
			// Set update or insert user data
			$this->_setDBValue("user_steam", $_POST['user_steam']);
		} else {
			$this->_setError("user_steam", $locale['uf_icq_error2']);
		}
	} else {
		$this->_setError("user_steam", $locale['uf_icq_error'], true);
	}  */
}
?>