<?php
/*---------------------------------------------------+
| This plugin is VIP system for CS 1.6 servers
| Use together with VIP_SQL.sma
| Was used on Botov-NET cs 1.6 servers
| Copyright (c) 2015 by AlexALX
+----------------------------------------------------+
| PHP-Fusion 6 Content Management System
+----------------------------------------------------+
| Copyright © 2002 - 2006 Nick Jones
| http://www.php-fusion.co.uk/
+----------------------------------------------------+
| Released under the terms & conditions of v2 of the
| GNU General Public License. For details refer to
| the included gpl.txt file or visit http://gnu.org
+----------------------------------------------------*/

// This script is for WebMoney payment Gateway, must be configured in app
// Also might not work already, since was made long time ago

require_once "core.php";

error_reporting(0);

if (isset($_POST['LMI_PREREQUEST'])) {

	if(!$vip_sets['enabled']) die("Система временно отключена.");

	if (isset($_POST['LMI_PAYMENT_NO'])&&isnum($_POST['LMI_PAYMENT_NO'])) {
		$res = dbquery("SELECT * FROM ".DB_PREFIX."csvips_pays WHERE pid='".$_POST['LMI_PAYMENT_NO']."' AND status='0'");

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

			$prices = get_prices();
			$price = $prices[$data['ammount_type']][($data['server']!=0?1:0)][$data['vip_time']];
			if (ceil($arr["LMI_PAYMENT_AMOUNT"])!=$price) die("Неверная сумма.");

			$res = dbquery("SELECT vid FROM ".DB_PREFIX."csvips WHERE vid='".$data['vid']."'");
			if (dbrows($res)) {
				$dat = dbarray($res);
				if ($dat['time']=="0") die("Ваш аккаунт бессрочный.");
				elseif ($dat['status']=='0') die("Аккаунт заморожен.");
				elseif ($dat['status']=='2') die("Аккаунт заблокирован.");
				die("YES");
			} else die("Неверный пользователь.");

		} else {
			die("Неверный птатёж.");
		}

	} else die("Неверные данные.");

} else {

	if (isset($_POST['LMI_PAYMENT_NO'])&&isnum($_POST['LMI_PAYMENT_NO'])) {
		$res = dbquery("SELECT vid,vip_time,server FROM ".DB_PREFIX."csvips_pays WHERE pid='".$_POST['LMI_PAYMENT_NO']."' AND status='0'");

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

			if (strtoupper(md5($hash))==$_POST["LMI_HASH"]) {
				$res2 = dbquery("UPDATE ".DB_PREFIX."csvips_pays SET type='".$arr["LMI_MODE"]."', date='".parse_wm_time($arr['LMI_SYS_TRANS_DATE'])."', `status`='1',"
				." wm_sys_invs='".$arr["LMI_SYS_INVS_NO"]."', wm_sys_trans='".$arr["LMI_SYS_TRANS_NO"]."', pay_data='".base64_encode(serialize($arr))."' WHERE pid='".$_POST['LMI_PAYMENT_NO']."'");

				$data2 = dbarray($res);
				$res = dbquery("SELECT * FROM ".DB_PREFIX."csvips WHERE vid='".$data2['vid']."'");
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
					$res = dbquery("UPDATE ".DB_PREFIX."csvips SET time='".$time."', server='".$data2['server']."', flags='".$flags."' WHERE vid='".$data2['vid']."'");
				} else die("Неверный пользователь.");
			} else die("Неверная контрольная сумма!");

		} else {
			die("Неверный птатёж.");
		}

	}

}

?>