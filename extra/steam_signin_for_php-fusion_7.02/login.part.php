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

//This is code what you can put into login.php and login panel to get steam sign in:

	include_once(INCLUDES."steam_auth.php");
	echo "<noindex><a href='".SteamSignIn::genUrl()."' title='Sign in through Steam'><img src='".IMAGES."sits_small.png' title='Sign in through Steam'></a></noindex><br />\n<br />\n";

//Put it before 	if ($settings['enable_registration']) {