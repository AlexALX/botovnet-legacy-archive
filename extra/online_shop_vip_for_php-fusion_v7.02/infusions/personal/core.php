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
if (defined("PERSONAL_API")) {
	require_once "../../../maincore.php";
} else {
	require_once "../../maincore.php";
}

//ini_set("display_errors",true);
//error_reporting(E_ALL);

define("VIP_BASEDIR",INFUSIONS."personal/");
define("VIP_IMAGES",VIP_BASEDIR."images/");

$vip_sets = dbarray(dbquery("SELECT * FROM ".DB_PREFIX."game_vip_set"));

$res = dbquery("UPDATE ".DB_PREFIX."game_vip_pays SET status='3' WHERE status='0' AND time<='".(time()-60*60*24*7)."'");

function servers_arr() {
	$arr = array(
		"1"=>array("Garry's Mod - Stargate","botov.net.ua:28015"),
		"3"=>array("Rust - Выживание","botov.net.ua:29015"),
		"2"=>array("Rust - Фан Сервер","botov.net.ua:29020"),
		//"4"=>array("Rust - Остров Смерти","botov.net.ua:29025")
	);
	return $arr;
}

$vip_disable_all = false;

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

function get_servers($server,$single=false,$name=false) {
	$ret = "Ошибка";
	$servers = servers_arr();
	if ($server=="0") {
		if ($single) return "Все сервера";
		$ret = "Все:";
		foreach($servers as $serv) {
			$ret .= "<br>".$serv[0].", ".$serv[1];
		}
	} elseif (array_key_exists($server,$servers)) {
		$ret = $servers[$server][0].(!$name?", ".$servers[$server][1]:"");
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
	if ($type=="3") {
		return "3 Месяца";
	} elseif ($type=="2") {
		return "1 Месяц";
	} elseif ($type=="1") {
		return "2 Недели";
	} elseif ($type=="0") {
		return "3 Дня";
	}
	return "Произвольный";
}

function plural_type($n) {
  return ($n%10==1 && $n%100!=11 ? 0 : ($n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2));
}

function get_to_time($time,$admin=false,$server=-1) {
	$_plural_days = array('день', 'дня', 'дней');
	$_plural_hours = array('час', 'часа', 'часов');
	$_plural_minutes = array('минута', 'минуты', 'минут');
	$days = $time / 60 / 60 / 24;
	$buytxt = (!$admin?" <a href='".VIP_BASEDIR."pays.php?action=new&server=".$server."'><input type='image' src='".VIP_IMAGES."price_alert.png' alt='Продлить' title='Продлить' style='vertical-align:middle;'> Продлить</a>":"");
	if ($days>3) return round($days)." ".$_plural_days[plural_type(round($days))].$buytxt;
	if ($days>1) return round($days)." ".$_plural_days[plural_type(round($days))]." (истекает)".$buytxt;
	$hours = $time / 60 / 60;
	if ($hours>1) return round($hours)." ".$_plural_hours[plural_type(round($hours))].$buytxt;
	$minutes = round($time / 60);
	if ($hours>0) return round($minutes)." ".$_plural_minutes[plural_type(round($minutes))].$buytxt;

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
		if ($dy==1) return $time;
		if ($dy==0) return $time-60*60;
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
	//$prices[0] = array("0"=>array("30","60","120","140","250"),"1"=>array("15","30","60","85","160"));
	//$prices[1] = array("0"=>array("80","240","310","360","650"),"1"=>array("40","80","160","220","420"));
	$prices[0] = array("0"=>array("12","45","75","190"),"1"=>array("7","25","40","100"));
	$prices[1] = array("0"=>array("35","125","210","520"),"1"=>array("20","75","110","270"));
	return $prices;
}

function calculate_amount_desc($amtype,$time,$server) {
	global $userdata;
	$arr = array("0"=>"","1"=>"");
	$prices = get_prices();
	if (!preg_match("/^(0|1)$/",$amtype)) $amtype = "0";
	if (!preg_match("/^(0|1|2|3|4)$/",$time)) $time = "0";
	$servers = servers_arr();
	if ($server=="0"||!array_key_exists($server,$servers)) $server = "0";
	elseif (array_key_exists($server,$servers)) $server = "1";
	$arr[0] = $prices[$amtype][$server][$time];
	$arr[1] = "Пожертвование, VIP аккаунт на ".get_vip_time($time).", логин: ".$userdata['user_name'];
	return $arr;
}

function calculate_amount_time($time) {
	if ($time=="0") return 60*60*24*3;
	elseif ($time=="1") return 60*60*24*14;
	elseif ($time=="2") return 60*60*24*30;
	elseif ($time=="3") return 60*60*24*90;
	return 0;
}

require_once('wm_conf.php');

function vip_footer() {
	echo "<br><center><b><img src='".VIP_IMAGES."help.png' alt='help' style='vertical-align:middle;'> Необходима помощь?</b><br>Вы можете задать вопрос послав <a href='".BASEDIR."messages.php?msg_send=1' target='_blank'>личное сообщение</a>.</center>";
}

function need_login() {

	opentable("Ошибка");

    echo "<center>Для доступа к этой странице вы должны быть зарегестрированным пользователем.<br><br>Пожалуйста, <a href='".BASEDIR."login.php'>войдите</a> или <a href='".BASEDIR."register.php'>зарегестрируйтесь</a>.</center>";

	closetable();

}

function showtime($sec) {
	$_plural_days = array('день', 'дня', 'дней');
	$_plural_hours = array('час', 'часа', 'часов');
	$_plural_minutes = array('минута', 'минуты', 'минут');

	$seconds = $sec;

	$rhours = floor($seconds/3600);

	$days = floor($seconds/86400);
	$seconds = $seconds-($days*86400);
	$hours = floor($seconds/3600);
	$seconds = $seconds-($hours*3600);
	$minutes = floor($seconds/60);
	if ($rhours<=0) {
		return $minutes." ".$_plural_minutes[plural_type($minutes)];
	} else {
		$str = "";
		if ($days>0) $str .= $days." ".$_plural_days[plural_type($days)];
		if ($hours>0) {
			if ($str!="") $str .= " ";
			$str .= $hours." ".$_plural_hours[plural_type($hours)];
			if ($days>0) $str .= " (".$rhours." ".$_plural_hours[plural_type($rhours)].")";
		}
	}

	return $str;
}

function get_personal_type($time,$status) {
	if ($status==1&&($time>time()||$time==0)) {
		return "VIP аккаунт";
	}
	return "Базовый аккаунт";
}

function vip_build_nav($links,$admin=false,$width='50%',$class='tbl-border') {
	global $aidlink;
	$nav = "<table width='$width' cellpadding='0' cellspacing='1' align='center' class='$class'>\n<tr>\n";
	$wid = floor(100/count($links))."%";
	foreach($links as $arr) {
		$nav .= "<td width='".(isset($arr['width'])?$arr['width']:$wid)."' align='center' class='"
		.(preg_match("/".(isset($arr['preg'])?$arr['preg']:$arr['url'])."/i", FUSION_SELF) && (isset($arr['no_action'])&&!isset($_GET['action'])||!isset($arr['no_action']))
		&& (!isset($arr['action'])&&!isset($arr['preg_action']) || isset($arr['no_action'])&&$arr['no_action']&&!isset($_GET['action'])
		|| isset($_GET['action'])&&preg_match("/".(isset($arr['preg_action'])?$arr['preg_action']:$arr['action'])."/", $_GET['action']))
		? "tbl1" : "tbl2")."' style='padding-left:10px;padding-right:10px;'><a class='side' href='".$arr['url']
		.($admin?$aidlink.(isset($arr['action'])?"&":""):(isset($arr['action'])?"?":"")).(isset($arr['action'])?"action=".$arr['action']:"")."'>".$arr['name']."</a></td>\n";
	}
	$nav .= "</tr>\n</table>\n<br>\n";
	return $nav;
}

// shop

$rust_icons = array(
	"wood"=>array("Дерево","Wood_icon.png"),
	"stones"=>array("Камень","Stones_icon.png"),
	"explosive.timed"=>array("C4","Timed_Explosive_Charge_icon.png"),
	"rifle_ak"=>array("AK47","Assault_Rifle_icon.png"),
	"charcoal"=>array("Уголь","Charcoal_icon.png"),
	"grenade.smoke"=>array("Supply Drop","Supply_Signal_icon.png"),
	"hazmat_boots"=>array("Антирад сапоги","Hazmat_Boots_icon.png"),
	"hazmat_gloves"=>array("Антирад перчатки","Hazmat_Gloves_icon.png"),
	"hazmat_helmet"=>array("Антирад шлем","Hazmat_Helmet_icon.png"),
	"hazmat_jacket"=>array("Антирад куртка","Hazmat_Jacket_icon.png"),
	"hazmat_pants"=>array("Антирад штаны","Hazmat_Pants_icon.png"),
	"box_wooden_large"=>array("Большой ящик","Large_Wood_Box_icon.png"),
	"lantern"=>array("Светильник","Lantern_icon.png"),
	"сloth"=>array("Ткань","Cloth_icon.png"),
	"fat_animal"=>array("Животный жир","Animal_Fat_icon.png"),
	"metal_fragments"=>array("Металлические фрагменты","Metal_Fragments_icon.png"),
	"sulfur"=>array("Сера","Sulfur_icon.png"),
	"rocket_launcher"=>array("Ракетница","Rocket_Launcher_icon.png"),
	"ammo_pistol"=>array("Пистолетный патрон","Pistol_Bullet_icon.png"),
	"ammo_pistol_fire"=>array("Пистолетный патрон (Зажигательный)","Incendiary_Pistol_Bullet_icon.png"),
	"ammo_pistol_hv"=>array("Пистолетный патрон (скоростной)","HV_Pistol_Ammo_icon.png"),
	"ammo_rifle"=>array("Патрон 5.56-мм","5.56_Rifle_Ammo_icon.png"),
	"ammo_rifle_explosive"=>array("Патрон 5.56-мм (Разрывной)","Explosive_5.56_Rifle_Ammo_icon.png"),
	"ammo_rifle_incendiary"=>array("Патрон 5.56-мм (Зажигательный)","Incendiary_5.56_Rifle_Ammo_icon.png"),
	"ammo_rifle_hv"=>array("Патрон 5.56-мм (Скоростной)","HV_5.56_Rifle_Ammo_icon.png"),
	"ammo_rocket_basic"=>array("Ракета","Rocket_icon.png"),
	"ammo_rocket_fire"=>array("Ракета (Зажигательная)","Incendiary_Rocket_icon.png"),
	"ammo_rocket_hv"=>array("Ракета (Скоростная)","High_Velocity_Rocket_icon.png"),
	"ammo_shotgun"=>array("Картечь 12-го калибра","12_Gauge_Buckshot_icon.png"),
	"ammo_shotgun_slug"=>array("Пуля 12-го калибра","12_Gauge_Slug_icon.png"),
	"explosives"=>array("Взрывчатка","Explosives_icon.png"),
	"gunpowder"=>array("Порох","Gun_Powder_icon.png"),
	"lowgradefuel"=>array("Топливо низкого качества","Low_Grade_Fuel_icon.png"),
	"bone_fragments"=>array("Фрагменты костей","Bone_Fragments_icon.png"),
	"smg_thompson"=>array("Автомат Томпсона","Thompson_icon.png"),
	"rifle_bolt"=>array("Винтовка","Bolt_Action_Rifle_icon.png"),
	"pistol_revolver"=>array("Револьвер","Revolver_icon.png"),
	"shotgun_pump"=>array("Помповый дробовик","Pump_Shotgun_icon.png"),
	"smg_2"=>array("Самодельный пистолет-пулемет","Custom_SMG_icon.png"),
	"pistol_semiauto"=>array("Пистолет полуавтоматический","Semi-Automatic_Pistol_icon.png"),
	"mining.quarry"=>array("Буровая установка","Mining_Quarry_icon.png"),
	"surveycharge"=>array("Геологический заряд","Survey_Charge_icon.png"),
	"hatchet"=>array("Топор","Hatchet_icon.png"),
	"pickaxe"=>array("Кирка","Pick_Axe_icon.png"),
	"grenade.f1"=>array("Граната F1","F1_Grenade_icon.png"),
	"hat.miner"=>array("Налобный фонарик","Miners_Hat_icon.png"),
	"barricade.concrete"=>array("Бетонная баррикада","Concrete_Barricade_icon.png"),
	"barricade.metal"=>array("Металлическая баррикада","Metal_Barricade_icon.png"),
	"barricade.sandbags"=>array("Мешки с песком","Sandbag_Barricade_icon.png"),
	"barricade.stone"=>array("Каменная баррикада","Stone_Barriade_icon.png"),
	"barricade.woodwire"=>array("Деревянная баррикада с шипами","Barbed_Wooden_Barricade_icon.png"),
	"metal_plate_torso"=>array("Металлический нагрудник","Metal_Chest_Plate_icon.png"),
	"spikes.floor"=>array("Деревянные колья","Wooden_Floor_Spikes_icon.png"),
	"trap_bear"=>array("Капкан","Snap_Trap_icon.png"),
	"trap_landmine"=>array("Наземная мина","Land_Mine_icon.png"),
	"riot_helmet"=>array("Шлем бунтаря","Riot_Helmet_icon.png"),
	"fun_guitar"=>array("Акустическая гитара","Acoustic_Guitar_icon.png"),
	"largemedkit"=>array("Большая аптечка","Large_Medkit_icon.png"),
	"syringe_medical"=>array("Медицинский шприц","Medical_Syringe_icon.png"),
	"antiradpills"=>array("Противорадиационные таблетки","Anti-Radiation_Pills_icon.png"),
	"corn"=>array("Кукуруза","Corn_icon.png"),
	"seed.corn"=>array("Семена кукурузы","Corn_Seed_icon.png"),
	"pumpkin"=>array("Тыква","Pumpkin_icon.png"),
	"seed.pumpkin"=>array("Семена тыквы","Pumpkin_Seed_icon.png"),
	"wolfmeat_cooked"=>array("Приготовленное волчье мясо","Cooked_Mystery_Meat_icon.png"),
	"urban_boots"=>array("Городские ботинки","Urban_Boots_icon.png"),
	"urban_jacket"=>array("Красная куртка","Red_Jacket_icon.png"),
	"urban_pants"=>array("Городские брюки","Urban_Pants_icon.png"),
	"burlap_gloves"=>array("Кожаные перчатки","Leather_Gloves_icon.png"),
	"vagabond_jacket"=>array("Куртка бродяги","Vagabond_Jacket_icon.png"),
	"metal_facemask"=>array("Металлическая маска","Metal_Facemask_icon.png"),
	"jacket_snow"=>array("Пуховик - красный","Snow_Jacket_-_Red_icon.png"),
	"jacket_snow2"=>array("Пуховик - черный","Snow_Jacket_-_Black_icon.png"),
	"jacket_snow3"=>array("Пуховик - лесной камуфляж","Snow_Jacket_-_Wood_Camo_icon.png"),
	"bucket_helmet"=>array("Шлем-ведро","Bucket_Helmet_icon.png"),
	"metal_ore"=>array("Железная руда","Metal_Ore_icon.png"),
	"sulfur_ore"=>array("Серная руда","Sulfur_Ore_icon.png"),
	"paper"=>array("Бумага","Paper_icon.png"),
	"water_catcher_large"=>array("Большой водосборник","Large_Water_Catcher_icon.png"),
	"lock.code"=>array("Кодовый замок","Code_Lock_icon.png"),
	"machete"=>array("Мачете","Machete_icon.png"),
	"salvaged_sword"=>array("Меч","Salvaged_Sword_icon.png"),
);

function get_res_name($data) {
	global $rust_icons;
	$name = $data['res'];
	if (isset($data['name'])&&!empty($data['name'])) $name = $data['name'];
	if (array_key_exists($data['res'],$rust_icons))	$name = $rust_icons[$data['res']][0];
	if ($data['bp']) $name .= " (рецепт)";
	return $name;
}

function get_res_icon($res) {
	global $rust_icons;
	if (array_key_exists($res,$rust_icons))	return VIP_IMAGES."icons/".$rust_icons[$res][1];
	return "";
}

?>