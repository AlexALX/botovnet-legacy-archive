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

// This script is for WebMoney payment Gateway, must be configured in app
// Also might not work already, since was made long time ago

require_once "core.php";

error_reporting(0);

if (isset($_POST['LMI_PREREQUEST'])) {

	if(!$vip_sets['enabled']||!$vip_sets['pays']) die("Система временно отключена.");

	if (isset($_POST['LMI_PAYMENT_NO'])&&isnum($_POST['LMI_PAYMENT_NO'])) {
		$res = dbquery("SELECT * FROM ".DB_PREFIX."game_vip_pays WHERE pid='".$_POST['LMI_PAYMENT_NO']."' AND status='0'");

		if (dbrows($res)) {

			$fields = array("LMI_PAYEE_PURSE","LMI_PAYMENT_AMOUNT","LMI_MODE","LMI_PAYER_WM","LMI_PAYER_PURSE","LMI_CAPITALLER_WMID",
			"LMI_PAYMER_NUMBER","LMI_PAYMER_EMAIL","LMI_EURONOTE_NUMBER","LMI_EURONOTE_EMAIL","LMI_WMCHECK_NUMBER","LMI_TELEPAT_PHONENUMBER",
			"LMI_TELEPAT_ORDERID","LMI_PAYMENT_CREDITDAYS","LMI_PAYMENT_DESC","LMI_SDP_TYPE");

			$arr = array();
			foreach($fields as $field) {
				$arr[$field] = "";
			}
			foreach($_POST as $key=>$val) {
				if (in_array($key,$fields)&&trim($val)!="") {
					$arr[$key] = $val;
				}
			}

			$data = dbarray($res);
			if ($arr["LMI_PAYEE_PURSE"]!=$wm_pays[$data['ammount_type']]) die("Неверный кошелёк.");

			if ($data['stype']==1) {
				$res2 = dbquery("SELECT * FROM ".DB_PREFIX."game_shop WHERE id='".$data['vip_time']."'");
				if (!dbrows($res2)) die("Неверный предмет.");
				$data2 = dbarray($res2);
				if ($data2['enabled']==0) die("Предмет недоступен.");
				$price = ($data['ammount_type']==1?$data2['price_rub']:$data2['price_uah'])*$data['amount'];
				if (ceil($arr["LMI_PAYMENT_AMOUNT"])!=$price) die("Неверная сумма.");
				$ires2 = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_items WHERE pid='".$data['vip_time']."'");
				if (!dbrows($ires2)) die("Предметы отсутсвуют, пересоздайте платёж.");
				$hash = "";
				while ($idata2 = dbarray($ires2)) {
					$hash .= $idata2['res']."=".$idata2['amount']."|";
				}
				$hash = md5($hash);
				if ($data['hash']!=$hash) die("Предмет был изменён, пересоздайте платёж.");
				die("YES");
			} else {
				$prices = get_prices();
				$price = $prices[$data['ammount_type']][($data['server']!=0?1:0)][$data['vip_time']];
				if (ceil($arr["LMI_PAYMENT_AMOUNT"])!=$price) die("Неверная сумма.");

				$res = dbquery("SELECT vid FROM ".DB_PREFIX."game_vip WHERE vid='".$data['vid']."'");
				if (dbrows($res)) {
					$dat = dbarray($res);
					if ($dat['time']=="0") die("Ваш аккаунт бессрочный.");
					elseif ($dat['status']=='0') die("Аккаунт заморожен.");
					elseif ($dat['status']=='2') die("Аккаунт заблокирован.");
					die("YES");
				} else die("Неверный пользователь.");
			}

		} else {
			die("Неверный птатёж.");
		}

	} else die("Неверные данные.");

} else {

	if (isset($_POST['LMI_PAYMENT_NO'])&&isnum($_POST['LMI_PAYMENT_NO'])) {
		$res = dbquery("SELECT vid,vip_time,server,sid,amount,stype FROM ".DB_PREFIX."game_vip_pays WHERE pid='".$_POST['LMI_PAYMENT_NO']."' AND status='0'");

		if (dbrows($res)) {

			$fields = array("LMI_PAYEE_PURSE","LMI_PAYMENT_AMOUNT","LMI_PAYMENT_NO","LMI_MODE","LMI_SYS_INVS_NO","LMI_SYS_TRANS_NO","LMI_PAYER_PURSE","LMI_PAYER_WM",
			"LMI_CAPITALLER_WMID","LMI_PAYMER_NUMBER","LMI_PAYMER_EMAIL","LMI_EURONOTE_NUMBER","LMI_EURONOTE_EMAIL","LMI_WMCHECK_NUMBER","LMI_TELEPAT_PHONENUMBER",
			"LMI_TELEPAT_ORDERID","LMI_PAYMENT_CREDITDAYS","LMI_SYS_TRANS_DATE","LMI_SDP_TYPE","LMI_PAYMENT_DESC");

			$arr = array();
			foreach($fields as $field) {
				$arr[$field] = "";
			}
			$arr["LMI_MODE"] = 1;
			foreach($_POST as $key=>$val) {
				if (in_array($key,$fields)&&trim($val)!="") {
					$arr[$key] = stripinput($val);
				}
			}

			$check_arr = array("LMI_PAYEE_PURSE","LMI_PAYMENT_AMOUNT","LMI_PAYMENT_NO","LMI_MODE","LMI_SYS_INVS_NO","LMI_SYS_TRANS_NO","LMI_SYS_TRANS_DATE","LMI_SECRET_KEY","LMI_PAYER_PURSE","LMI_PAYER_WM");
			$hash = "";
			foreach($check_arr as $val) {
				if ($val=="LMI_SECRET_KEY")
					$hash .= $_wm_secret;
				else
					$hash .= $arr[$val];
			}

			if (strtoupper(hash('sha256',$hash))==$_POST["LMI_HASH"]) {
				$res2 = dbquery("UPDATE ".DB_PREFIX."game_vip_pays SET type='".$arr["LMI_MODE"]."', date='".parse_wm_time($arr['LMI_SYS_TRANS_DATE'])."', `status`='1',"
				." wm_sys_invs='".$arr["LMI_SYS_INVS_NO"]."', wm_sys_trans='".$arr["LMI_SYS_TRANS_NO"]."', pay_data='".base64_encode(serialize($arr))."' WHERE pid='".$_POST['LMI_PAYMENT_NO']."'");

				$data2 = dbarray($res);
                if ($data2['stype']==1) {
					$res = dbquery("SELECT * FROM ".DB_PREFIX."game_shop WHERE id='".$data2['vip_time']."'");
					if (dbrows($res)) {
						$ires2 = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_items WHERE pid='".$data2['vip_time']."'");
						if (!dbrows($ires2)) die("Предметы отсутсвуют, пересоздайте платёж.");
						while ($idata2 = dbarray($ires2)) {
							$res = dbquery("INSERT INTO ".DB_PREFIX."game_shop_pays VALUES('".md5(microtime())."','".$data2['sid']."','".$data2['server']."','".$idata2['res']."','".$idata2['amount']*$data2['amount']."','".$idata2['bp']."')");
						}
					} else die("Неверный предмет.");
                } else {
					$res = dbquery("SELECT * FROM ".DB_PREFIX."game_vip WHERE vid='".$data2['vid']."'");
					if (dbrows($res)) {
						$data = dbarray($res);
						$time = $data['time'];
						if ($data['time']>time()) {
							if ($data['server']=="0"&&$data2['server']=="0"||$data['server']!="0"&&$data2['server']!="0") {
								$time = $data['time']+calculate_amount_time($data2['vip_time']);
							} elseif ($data['server']!="0"&&$data2['server']=="0") {
								$time = ceil(($data['time']-time())/2)+time()+calculate_amount_time($data2['vip_time']);
							} elseif ($data['server']=="0"&&$data2['server']!="0") {
								$time = ceil(($data['time']-time())*2)+time()+calculate_amount_time($data2['vip_time']);
							}
						} else {
							$time = time()+calculate_amount_time($data2['vip_time']);
						}
						if (has_flag($data['flags'],"u")) $flags = str_replace("u","",$data['flags']);
						else $flags = $data['flags'];
						$res = dbquery("UPDATE ".DB_PREFIX."game_vip SET time='".$time."', server='".$data2['server']."', flags='".$flags."' WHERE vid='".$data2['vid']."'");
					} else die("Неверный пользователь.");
				}
			} else die("Неверная контрольная сумма!");

		} else {
			die("Неверный птатёж.");
		}

	}

}

?>