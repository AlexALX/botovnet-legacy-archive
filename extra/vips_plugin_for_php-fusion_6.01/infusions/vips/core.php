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

require_once "../../maincore.php";

define("VIP_BASEDIR",INFUSIONS."vips/");
define("VIP_IMAGES",VIP_BASEDIR."images/");

$vip_sets = dbarray(dbquery("SELECT * FROM ".DB_PREFIX."csvips_set"));

function has_flag($flags,$flag,$multiple=false) {
	if ($multiple) {
		$flgs = str_split($flags);
		$flg = str_split($flag);
		$ret = true;
		foreach ($flg as $fl) {
			if (!in_array($fl,$flgs)) return false;
		}
		return $ret;
	} else {
		if (strpos($flags,$flag)!==false) return true;
	}
	return false;
}

function get_time($time,$ftime=0) {
	if ($time=="0") {
		return "Неограничено";
	} elseif ($time=="-1") {
		return "Не оплачено";
	} else {
		if ($ftime>0) {
			return showdate("%d/%m/%Y %H:%M",$time-$ftime+time());
		} else {
			return showdate("%d/%m/%Y %H:%M",$time);
		}
	}
}

function get_status($status,$time,$admin=false) {
	if ($status=="0") {
		return "Заморожен";
	} elseif ($status=="2") {
		return "Заблокирован";
	} elseif ($time=="0") {
		return "Активен";
	} else {
		if ($time>=time()) {
			return "Активен";
		} else {
			return "Не активен".($admin?" (срок истёк)":"");
		}
	}
	return "Ошибка";
}

function get_type($type) {
	if ($type=="0") {
		return "Ник игрока";
	} elseif ($type=="1") {
		return "Steam ID";
	} elseif ($type=="2") {
		return "IP";
	}
	return "Ошибка";
}

function has_option($opts,$opt) {
	if (strpos($opts,$opt)!==false) return true;
	return false;
}

function get_servers($server,$return=false,$single=false) {
	$ret = "Ошибка";
	$servers = array("1"=>"Classic, botov.net.ua:27015",
	"2"=>"Biohazard, botov.net.ua:27020",
	"3"=>"DeathRun, botov.net.ua:27016",
	"4"=>"War3FT, botov.net.ua:27017",
	"5"=>"GunGame, botov.net.ua:27018",
	"6"=>"Surf, botov.net.ua:27019",
	"7"=>"DeathMatch FFA, botov.net.ua:27021",
	"8"=>"Garry's Mod - Stargate, botov.net.ua:28015",
	"9"=>"Garry's Mod - Train, botov.net.ua:28016");
	if ($return) return $servers;
	if ($server=="0") {
		if ($single) return "Все сервера";
		$ret = "Все:";
		foreach($servers as $serv) {
			$ret .= "<br>".$serv;
		}
	} elseif (array_key_exists($server,$servers)) {
		$ret = $servers[$server];
	}
	return $ret;
}

function get_options($option,$return=false) {
	$ret = "Не установлены.";
	$options = array("m"=>"VIP модель игрока");
	if ($return) return $options;
	if ($option!="") {
		$ret = ""; $i = 0;
		foreach($options as $opt=>$val) {
			if (strpos($option,$opt)!==false) { if ($i!=0) $ret .= ", "; $ret .= $val; $i++; }
		}
	}
	return $ret;
}

function get_flags($flag,$return=false) {
	$ret = "Не установлены.";
	$flags = array("a"=>"VIP слот","b"=>"Доступ с забаненых подсетей","c"=>"Привилегии випа","d"=>"Голосования кик/бан","e"=>"Голосования карты/собственые","f"=>"Опции","u"=>"Бесплатный VIP (системный)","z"=>"Не VIP (системный)");
	if ($return) return $flags;
	if ($flag!="") {
		$ret = ""; $i = 0;
		foreach($flags as $opt=>$val) {
			if ($opt=="u"||$opt=="z") continue;
			if (strpos($flag,$opt)!==false) { if ($i!=0) $ret .= ", "; $ret .= $val; $i++; }
		}
	}
	return $ret;
}

function get_default_flags($type=0) {
	if ($type==0) return "abcdef";
	elseif ($type==1) return "abcdefu";
}

function get_vip_type($flags) {
	if (has_flag($flags,"abcdef",true)) {
		return "Полный".(has_flag($flags,"u")?" (бесплатный)":"");
	} elseif (!has_flag($flags,"z")) {
		return "Ограниченный".(has_flag($flags,"u")?" (бесплатный)":"");
	} elseif (has_flag($flags,"z")) {
		return "Без привилегий".(has_flag($flags,"u")?" (бесплатный)":"");
	}
	return "Ошибка";
}

function get_vip_time($type) {
	if ($type=="4") {
		return "6 Месяцев";
	} elseif ($type=="3") {
		return "3 Месяца";
	} elseif ($type=="2") {
		return "2 Месяца";
	} elseif ($type=="1") {
		return "1 Месяц";
	} elseif ($type=="0") {
		return "2 Недели";
	}
	return "Произвольный";
}

function plural_type($n) {
  return ($n%10==1 && $n%100!=11 ? 0 : ($n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2));
}

function get_to_time($time,$admin=false) {
	$_plural_days = array('день', 'дня', 'дней');
	$_plural_hours = array('час', 'часа', 'часов');
	$_plural_minutes = array('минута', 'минуты', 'минут');
	$days = $time / 60 / 60 / 24;
	if ($days>3) return round($days)." ".$_plural_days[plural_type(round($days))].(!$admin?" <a href='".VIP_BASEDIR."pays.php?action=new'><input type='image' src='".VIP_IMAGES."price_alert.png' alt='Продлить' title='Продлить' style='vertical-align:middle;'> Продлить</a>":"");
	if ($days>1) return round($days)." ".$_plural_days[plural_type(round($days))]." (истекает)".(!$admin?" <a href='".VIP_BASEDIR."pays.php?action=new'><input type='image' src='".VIP_IMAGES."price_alert.png' alt='Продлить' title='Продлить' style='vertical-align:middle;'> Продлить</a>":"");
	$hours = $time / 60 / 60;
	if ($hours>1) return round($hours)." ".$_plural_hours[plural_type(round($hours))].(!$admin?" <a href='".VIP_BASEDIR."pays.php?action=new'><input type='image' src='".VIP_IMAGES."price_alert.png' alt='Продлить' title='Продлить' style='vertical-align:middle;'> Продлить</a>":"");
	$minutes = round($time / 60);
	if ($hours>0) return round($minutes)." ".$_plural_minutes[plural_type(round($minutes))].(!$admin?" <a href='".VIP_BASEDIR."pays.php?action=new'><input type='image' src='".VIP_IMAGES."price_alert.png' alt='Продлить' title='Продлить' style='vertical-align:middle;'> Продлить</a>":"");

	return "Срок истёк".(!$admin?" <a href='".VIP_BASEDIR."pays.php?action=new'><input type='image' src='".VIP_IMAGES."price_alert.png' alt='Купить' title='Купить' style='vertical-align:middle;'> Купить</a>":"");
}

function get_days_time($time) {
	$time = ($time-time());
	$days = $time / 60 / 60 / 24;
	if ($days>1) return round($days);
	return 0;
}

function parse_wm_time($time) {
	$time_arr = array();
	if (preg_match_all("/^(\d{4})(\d{2})(\d{2}) (\d{2}):(\d{2}):(\d{2})$/",$time,$time_arr)) {
		$time = mktime($time_arr[4][0], $time_arr[5][0], $time_arr[6][0], $time_arr[2][0], $time_arr[3][0], $time_arr[1][0]);
		$dy=date('I',$time);
		if ($dy==1) return $time-60*60;
		if ($dy==0) return $time-60*60*2;
	}
	return time();
}

function get_pay_time($time) {
	if ($time=="0") {
		return "Не оплачено";
	} else {
		return showdate("%d/%m/%Y %H:%M",$time);
	}
}

function get_pay_status($status) {
	if ($status=="4") {
		return "Возращён";
	} elseif ($status=="3") {
		return "Отменён";
	} elseif ($status=="2") {
		return "Неудача";
	} elseif ($status=="1") {
		return "Оплачен";
	}
	return "Ожидает оплаты";
}

function get_pay_type($type) {
	if ($type=="1") {
		return "Рублей (WMR)";
	}
	return "Гривен (WMU)";
}

function get_pay_legacy($type) {
	if ($type=="2") {
		return "Добавленый";
	} elseif ($type=="1") {
		return "Тестовый";
	} elseif ($type=="0") {
		return "Реальный";
	}
	return "---";
}

function get_prices() {
	$prices = array();
	//$prices[0] = array("0"=>array("20","40","80","100","200"),"1"=>array("10","20","40","55","100"));
	//$prices[1] = array("0"=>array("70","140","280","350","700"),"1"=>array("35","70","140","200","400"));
	//$prices[0] = array("0"=>array("15","30","60","75","125"),"1"=>array("8","15","30","40","70"));
	//$prices[1] = array("0"=>array("60","120","240","280","450"),"1"=>array("30","60","120","160","250"));
	$prices[0] = array("0"=>array("30","60","120","140","250"),"1"=>array("15","30","60","85","160"));
	$prices[1] = array("0"=>array("120","240","360","570","1000"),"1"=>array("60","120","240","350","650"));
	return $prices;
}

function calculate_amount_desc($amtype,$time,$server) {
	global $userdata;
	$arr = array("0"=>"","1"=>"");
	$prices = get_prices();
	if (!preg_match("/^(0|1)$/",$amtype)) $amtype = "0";
	if (!preg_match("/^(0|1|2|3|4)$/",$time)) $time = "0";
	$servers = get_servers("",true);
	if ($server=="0"||!array_key_exists($server,$servers)) $server = "0";
	elseif (array_key_exists($server,$servers)) $server = "1";
	$arr[0] = $prices[$amtype][$server][$time];
	$arr[1] = "Пожертвование, VIP аккаунт на ".get_vip_time($time).", логин: ".$userdata['user_name'];
	return $arr;
}

function calculate_amount_time($time) {
	if ($time=="0") return 60*60*24*14;
	elseif ($time=="1") return 60*60*24*30;
	elseif ($time=="2") return 60*60*24*60;
	elseif ($time=="3") return 60*60*24*90;
	elseif ($time=="4") return 60*60*24*180;
	return 0;
}

require_once "wm_conf.php";

function vip_footer() {
	echo "<br><center><b><img src='".VIP_IMAGES."help.png' alt='help' style='vertical-align:middle;'> Необходима помощь?</b><br>Мы можете задать вопрос послав <a href='".BASEDIR."messages.php?msg_send=1' target='_blank'>личное сообщение</a>.</center>";
}

function need_login() {

	opentable("Ошибка");

    echo "<center>Для доступа к этой странице вы должны быть зарегестрированным пользователем.<br><br>Пожалуйста, <a href='".BASEDIR."login.php'>войдите</a> или <a href='".BASEDIR."register.php'>зарегестрируйтесь</a>.</center>";

	closetable();

}

?>