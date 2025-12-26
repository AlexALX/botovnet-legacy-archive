<?php
/*-------------------------------------------------------+
| PHP-Fusion Content Management System
| Copyright (C) 2002 - 2011 Nick Jones
| http://www.php-fusion.co.uk/
+--------------------------------------------------------+
| Filename: register.php
| Author: Hans Kristian Flaatten {Starefossen}
+--------------------------------------------------------+
| This file was modified for make Steam AUTH
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
require_once CLASSES."UserFields.class.php";
require_once CLASSES."UserFieldsInput.class.php";
include LOCALE.LOCALESET."user_fields.php";

if (iMEMBER || !$settings['enable_registration']) { redirect("index.php"); }

@session_start();

$errors = array();
if (isset($_GET['email']) && isset($_GET['code'])) {
	if (!preg_check("/^[-0-9A-Z_\.]{1,50}@([-0-9A-Z_\.]+\.){1,50}([0-9A-Z]){2,4}$/i", $_GET['email'])) {
		redirect("register.php?error=activate");
	}
	if (!preg_check("/^[0-9a-z]{40}$/", $_GET['code'])) { redirect("register.php?error=activate"); }
	$result = dbquery(
		"SELECT user_info FROM ".DB_NEW_USERS."
		WHERE user_code='".$_GET['code']."' AND user_email='".$_GET['email']."'
		LIMIT 1"
	);
	if (dbrows($result)) {
		add_to_title($locale['global_200'].$locale['u155']);

		// getmequick at gmail dot com
		// http://www.php.net/manual/en/function.unserialize.php#71270
		function unserializeFix($var) {
			$var = preg_replace('!s:(\d+):"(.*?)";!e', "'s:'.strlen('$2').':\"$2\";'", $var);
			return unserialize($var);
		}

		$data = dbarray($result);
		$user_info = unserializeFix(stripslashes($data['user_info']));
		$result = dbquery("INSERT INTO ".DB_USERS." (".$user_info['user_field_fields'].") VALUES (".$user_info['user_field_inputs'].")");
		$result = dbquery("DELETE FROM ".DB_NEW_USERS." WHERE user_code='".$_GET['code']."' LIMIT 1");

		opentable($locale['u155']);
		if ($settings['admin_activation'] == "1") {
			echo "<div style='text-align:center'><br />\n".$locale['u171']."<br /><br />\n".$locale['u162']."<br /><br />\n</div>\n";
		} else {
			echo "<div style='text-align:center'><br />\n".$locale['u171']."<br /><br />\n".$locale['u161']."<br /><br />\n</div>\n";
		}
		closetable();
	} else {
		redirect("index.php");
	}
} elseif (isset($_POST['register'])) {

	if (isset($_SESSION['steamid'])&&$_SESSION['steamid']!=0) {
		$_POST['user_steam'] = intval($_SESSION['steamid']);

		$userInput = new UserFieldsInput();
		$userInput->validation 				= $settings['display_validation'];
		$userInput->emailVerification 		= $settings['email_verification'];
		$userInput->adminActivation 		= $settings['admin_activation'];
		$userInput->skipCurrentPass 		= true;
		$userInput->registration			= true;
		$userInput->saveInsert();
		$userInput->displayMessages();
		$errors = $userInput->getErrorsArray();
		if (count($errors)==0) unset($_SESSION['steamid']);
		unset($userInput);

	} else {
		echo "Ошибка определения SteamID.";
	}
}

if ((!isset($_POST['register']) && !isset($_GET['code'])) || (isset($_POST['register']) && count($errors) > 0)) {
	opentable($locale['u101']);

	include_once(INCLUDES."steam_auth.php");
	if (isset($_SESSION['steamid'])) {
		$steamid = intval($_SESSION['steamid']);
	} else {
		$steamid = SteamSignIn::validate();
	}
	if(!empty($steamid)) {
		define("_GLOB_STEAM64",intval($steamid));
		$res = dbquery("SELECT user_id,user_name FROM ".DB_USERS." WHERE user_steam='".intval($steamid)."'");

		if (dbrows($res)) {
			$data = dbarray($res);
			echo "Ошибка, SteamID <a href='http://steamcommunity.com/profiles/".$steamid."' target='_blank'>".$steamid."</a> уже зарегестрирован на <a href='".BASEDIR."profile.php?lookup=".$data['user_id']."' target='_blank'>".$data['user_name']."</a>.
			<br>
			<br>Пожалуйста, войдите на странице <a href='".BASEDIR."login.php'>входа</a>.<br>";
		} else {
			$total = dbresult(dbquery("SELECT sum(time) AS total_time FROM ".DB_PREFIX."game_stat WHERE sid='".intval($steamid)."'"),0);
			echo $total;
			if ($total<600) {
				echo "Ошибка, данный SteamID не подходит для регистрации.
				<br>
				<br>Вы должны сыграть хотябы <b>10 минут</b> на любом из <a target='_blank' href='".BASEDIR."servers.php'>наших серверов</a>.
				<br>
				<br>Если вы уже отыграли более 10 минут (и вышли с сервера) но видите это сообщение, попробуйте немного позже ещё раз.
				<br>Если это не помогло - сообщите администратору через <a target='_blank' href='http://vk.com/botovnetua'>группу ВК</a>.<br>";
			} else {
				$_POST['user_name'] = SteamSignIn::steamid64_to_name($steamid);
				$userFields 						= new UserFields();
				$userFields->postName 				= "register";
				$userFields->postValue 				= $locale['u101'];
				$userFields->displayValidation 		= $settings['display_validation'];
				$userFields->displayTerms 			= $settings['enable_terms'];
				$userFields->showAdminPass 			= false;
				$userFields->showAvatarInput 		= false;
				$userFields->skipCurrentPass 		= true;
				$userFields->registration			= true;
				$userFields->errorsArray 			= $errors;
				$userFields->displayInput();
			}
		}

	} else {

	echo "<table class='tbl-border' cellpadding='0' cellspacing='0' align='center'>";
	echo "<tr><td class='tbl2' align='center'>";

echo "Для начала регистрации на сайте необходимо войти через steam аккаунт:
<br>
<br><a href='".SteamSignIn::genUrl()."' title='Sign in through Steam'><img src='".IMAGES."sits_large_noborder.png' title='Sign in through Steam'></a>";

	echo "</td></tr>";
	echo "</table>";
	}

	echo "<br><center><a href='http://steampowered.com/' target='_blank'>Powered by Steam</a></center>";

	closetable();
}

require_once THEMES."templates/footer.php";
?>