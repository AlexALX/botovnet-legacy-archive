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

define("PERSONAL_API",true);
require_once "../core.php";
require_once THEMES."templates/admin_header.php";
require_once ADMIN."navigation.php";

if (!checkrights("VIP") || !defined("iAUTH") || $_GET['aid'] != iAUTH) { redirect(VIP_BASEDIR); };

require_once "nav.php";

$nav = array(
	array("name"=>"Предметы","url"=>"shop.php","no_action"=>true),
	array("name"=>"Категории","url"=>"shop.php","action"=>"cats"),
	array("name"=>"Инвенторий игроков","url"=>"shop.php","action"=>"inv"),
);

echo vip_build_nav($nav,true,"40%");

if (isset($_GET['action'])) {

if ($_GET['action']=="cats") {
if (isset($_GET['edit_cat'])) {

$error = "";

$id = intval($_GET['edit_cat']);
$edit = ($id!=0?true:false);

if (isset($_POST['save'])) {
	$name = stripinput($_POST['name']);
	$ord = stripinput($_POST['ord']);
	$type = stripinput($_POST['type']);
	$text = addslashes($_POST['text']);

	if ($name=="") $error = "Не заполнены обязательные поля!";

	if ($error=="") {
		if ($edit) {
			$res = dbquery("UPDATE ".DB_PREFIX."game_shop_cats SET name='".$name."', ord='".$ord."', type='".$type."', text='".$text."' WHERE id='".$id."'");
			redirect(FUSION_SELF.$aidlink."&action=cats&saved");
		} else {
			$res = dbquery("INSERT INTO ".DB_PREFIX."game_shop_cats VALUES('','".$ord."','".$name."','".$type."','".$text."')");
			redirect(FUSION_SELF.$aidlink."&action=cats&saved");
		}
	}

}
opentable((!$edit?"Добавить":"Редактировать")." категорию");

$data = array("name"=>"","ord"=>"","type"=>"","text"=>"");

if ($edit) {
	$res = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_cats WHERE id='".$id."'");
	if (dbrows($res)) $data = dbarray($res);
}

if ($error!="") echo "<center>".$error."</center><br>";

echo "<form name='paysform' action='".FUSION_SELF.$aidlink."&action=cats&edit_cat=".$id."' method='post'>
<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2'>Название:</td>
<td class='tbl1'><input name='name' type='text' value='".$data['name']."' class='textbox'></td>
</tr>
<tr>
<td class='tbl2'>Порядок:</td>
<td class='tbl1'><input name='ord' type='text' value='".$data['ord']."' class='textbox'></td>
</tr>
<tr>
<td class='tbl2'>Тип:</td>
<td class='tbl1'><select class='textbox' name='type'>
<option value='0'".($data['type']==0?" selected":"").">---</option>
<option value='1'".($data['type']==1?" selected":"").">Наборы</option>
<option value='2'".($data['type']==2?" selected":"").">Новинки</option>
</select></td>
</tr>
<tr>
<td class='tbl2'>Описание:</td>
<td class='tbl1'><textarea name='text' rows=6 cols=50 class='textbox'>".$data['text']."</textarea></td>
</tr>
<tr>
<td class='tbl2' align='center' colspan='2'><input type='submit' value='Сохранить' class='button' name='save'></td>
</tr>";

echo "</table></form>";

closetable();

} else {

opentable("Категории");

echo "<center>[ <a href='".FUSION_SELF.$aidlink."&action=cats&edit_cat=0'>Добавить категорию</a> ]</center><br>";

$res = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_cats ORDER BY ord ASC");

if (dbrows($res)) {

echo "<table cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2'><b>Название</b></td>
<td class='tbl2'><b>Порядок</b></td>
<td class='tbl2'><b>Опции</b></td>
</tr>";
   $i = 0;
while ($data = dbarray($res)) {
	$i % 2 == 0 ? $tclass="tbl1" : $tclass="tbl2";
	echo "<tr>
	<td class='$tclass'>".$data['name']."</td>
	<td class='$tclass' align='center'>".$data['ord']."</td>
	<td class='$tclass' align='center' width='40'>"
	."<a href='".FUSION_SELF.$aidlink."&action=cats&edit_cat=".$data['id']."'><img src='".VIP_IMAGES."edit.png' alt='Редактировать' title='Редактировать'></a> "
	."<a href='".FUSION_SELF.$aidlink."&action=cats&del_cat=".$data['id']."' onclick='return check_delete()'><img src='".VIP_IMAGES."remove.png' alt='Удалить' title='Удалить'></a>"
	."</td>
	</tr>"; $i++;
}
echo "</table>";

echo "<script type='text/javascript'>
function check_delete() {
	return confirm('Вы дейтсвительно хотите удалить эту категорию со всеми предметами?');
}
</script>";

} else {
	echo "<center>В базе данных нет категорий.</center>";
}

closetable();

}

} else if ($_GET['action']=="inv") {

if (isset($_GET['edit'])) {

$error = "";

$id = stripinput($_GET['edit']);
$edit = ($id!="0"?true:false);

$server = isset($_GET['server'])?intval($_GET['server']):0;

if (isset($_POST['save'])) {
	$sid = stripinput($_POST['sid']);
	$server = stripinput($_POST['server']);
	$res = stripinput($_POST['res']);
	$amount = intval($_POST['amount']);
	if ($amount<1) $amount = 1;
	$bp = (isset($_POST['bp'])&&$_POST['bp']=="ON"?1:0);
	$item = intval($_POST['item']);

	if ($item!=0) {
		$res = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_items WHERE pid='".$item."'");
		if (!dbrows($res)) $error = "Данный набор не существует!";
		else {
			while ($data = dbarray($res)) {
				$res2 = dbquery("INSERT INTO ".DB_PREFIX."game_shop_pays VALUES('".md5(microtime())."','".$sid."','".$server."','".$data['res']."','".$data['amount']."','".$data['bp']."')");
			}
			redirect(FUSION_SELF.$aidlink."&action=inv&server=".$server."&saved");
		}
	} else {

		if ($sid==""||$res=="") $error = "Не заполнены обязательные поля!";

		if ($error=="") {
			if ($edit) {
				$res = dbquery("UPDATE ".DB_PREFIX."game_shop_pays SET sid='".$sid."', server='".$server."', res='".$res."', amount='".$amount."', bp='".$bp."' WHERE hash='".$id."'");
				redirect(FUSION_SELF.$aidlink."&action=inv&server=".$server."&saved");
			} else {
				$res = dbquery("INSERT INTO ".DB_PREFIX."game_shop_pays VALUES('".md5(microtime())."','".$sid."','".$server."','".$res."','".$amount."','".$bp."')");
				redirect(FUSION_SELF.$aidlink."&action=inv&server=".$server."&saved");
			}
		}
	}

}
opentable((!$edit?"Добавить":"Редактировать")." предмет");

$data = array("sid"=>"","res"=>"","amount"=>"","bp"=>0,"server"=>$server);

if ($edit) {
	$res = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_pays WHERE hash='".$id."'");
	if (dbrows($res)) $data = dbarray($res);
}

if ($error!="") echo "<center>".$error."</center><br>";

echo "<form name='paysform' action='".FUSION_SELF.$aidlink."&action=inv&edit=".$id."' method='post'>
<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2'>SteamID:</td>
<td class='tbl1'><input name='sid' type='text' value='".$data['sid']."' class='textbox'></td>
</tr>
<tr>
<td class='tbl2'>Сервер:</td>
<td class='tbl1'><select class='textbox' name='server'>\n";
$servers = servers_arr();
foreach ($servers as $key=>$serv) {
	if ($key==1) continue;
	echo "<option value='".$key."'".($data['server']==$key?" selected":"").">".$serv[0]."</option>";
}
echo "</select></td>
</tr>";
if (!$edit) {
echo "<tr>
<td class='tbl2'>ID Набора:</td>
<td class='tbl1'><input name='item' type='text' value='' class='textbox' style='width:60px;'></td>
</tr>";
}
echo "<tr>
<td class='tbl2'>Ресурс:</td>
<td class='tbl1'><input name='res' type='text' value='".$data['res']."' class='textbox'></td>
</tr>
<tr>
<td class='tbl2'>Количество:</td>
<td class='tbl1'><input name='amount' type='text' value='".$data['amount']."' class='textbox'></td>
</tr>
<tr>
<td class='tbl2'>Рецепт:</td>
<td class='tbl1'><input name='bp' type='checkbox' value='ON'".($data['bp']!=0?" checked":"")."></td>
</tr>
<tr>
<td class='tbl2' align='center' colspan='2'><input type='submit' value='Сохранить' class='button' name='save'></td>
</tr>";

echo "</table></form>";

closetable();

} else {
opentable("Инвенторий игроков");

$server = isset($_GET['server'])?intval($_GET['server']):0;

echo "<center>Сервер: <select class='textbox' onchange='location.href=\"".FUSION_SELF.$aidlink."&action=inv&server=\"+this.value'>
<option value='0'>---</option>";
$servers = servers_arr();
foreach ($servers as $key=>$serv) {
	if ($key==1) continue;
	echo "<option value='".$key."'".($server==$key?" selected":"").">".$serv[0]."</option>";
}
echo "</select></center><br>";

if ($server==0) {
	echo "<center>Выберите сервер</center>";
} else {

if (isset($_GET['del'])) {
	$res = dbquery("DELETE FROM ".DB_PREFIX."game_shop_pays WHERE hash='".stripinput($_GET['del'])."'");
	redirect(FUSION_SELF.$aidlink."&action=inv&server=".$server."&deleted");
}

echo "<center>[ <a href='".FUSION_SELF.$aidlink."&action=inv&server=".$server."&edit=0'>Добавить</a> ]</center><br>";

$res = dbquery("SELECT p.*,u.user_name AS name FROM ".DB_PREFIX."game_shop_pays p LEFT JOIN ".DB_USERS." u ON u.user_steam=p.sid WHERE p.server='".$server."' ORDER BY sid");

if (dbrows($res)) {

echo "<table cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2'><b>SteamID</b></td>
<td class='tbl2'><b>Логин</b></td>
<td class='tbl2' align='center'><b>Ресурс</b></td>
<td class='tbl2' align='center'><b>Количество</b></td>
<td class='tbl2' align='center'><b>Рецепт</b></td>
<td class='tbl2' align='center'><b>Опции</b></td>
</tr>";
   $i = 0;
while ($data = dbarray($res)) {
	$i % 2 == 0 ? $tclass="tbl1" : $tclass="tbl2";
	echo "<tr>
	<td class='$tclass'>".$data['sid']."</td>
	<td class='$tclass' align='center'>".$data['name']."</td>
	<td class='$tclass' align='center'>".$data['res']."</td>
	<td class='$tclass' align='center'>".$data['amount']."</td>
	<td class='$tclass' align='center'>".($data['bp']?"Да":"Нет")."</td>
	<td class='$tclass' align='center' width='40'>"
	."<a href='".FUSION_SELF.$aidlink."&action=inv&edit=".$data['hash']."'><img src='".VIP_IMAGES."edit.png' alt='Редактировать' title='Редактировать'></a> "
	."<a href='".FUSION_SELF.$aidlink."&action=inv&server=".$server."&del=".$data['hash']."' onclick='return check_delete()'><img src='".VIP_IMAGES."remove.png' alt='Удалить' title='Удалить'></a>"
	."</td>
	</tr>"; $i++;
}
echo "</table>";

echo "<script type='text/javascript'>
function check_delete() {
	return confirm('Вы дейтсвительно хотите удалить этот предмет?');
}
</script>";

} else {
	echo "<center>В базе данных нет игроков.</center>";
}

}

closetable();

}

}

} else {
if (isset($_GET['edit_item'])) {
$id = intval($_GET['edit_item']);
$edit = ($id!=0?true:false);

if (isset($_POST['save'])) {
	print_r($_POST);

	$name = stripinput($_POST['name']);
	$cat = stripinput($_POST['cat']);
	$ord = stripinput($_POST['ord']);
	$server = stripinput($_POST['server']);
	$price_uah = stripinput($_POST['price_uah']);
	$price_rub = stripinput($_POST['price_rub']);
	$enabled = (isset($_POST['enabled'])&&$_POST['enabled']=="ON"?true:false);
	$desc = addslashes($_POST['desc']);
	$img = stripinput($_POST['img']);
	$pack = (isset($_POST['pack'])&&$_POST['pack']=="ON"?true:false);
	$new = (isset($_POST['new'])&&$_POST['new']=="ON"?true:false);

	if ($name==""&&$price_uah==""&&$price_rub=="") $error = "Не заполнены обязательные поля!";

	$resources = (is_array($_POST['res'])?$_POST['res']:array());

	if ($error=="") {
		if ($edit) {
			$res = dbquery("UPDATE ".DB_PREFIX."game_shop SET name='".$name."', ord='".$ord."', server='".$server."', cat='".$cat."', price_uah='".$price_uah."', price_rub='".$price_rub."', enabled='".$enabled."', `desc`='".$desc."', img='".$img."', pack='".$pack."', new='".$new."' WHERE id='".$id."'");
			if ($res) {
				$pid = $id;
				$res = dbquery("DELETE FROM ".DB_PREFIX."game_shop_items WHERE pid='".$pid."'");
				if (count($resources)) {
					$keys = array("name","res","amount","ord");
					foreach($resources as $key=>$value) {
						if (!is_array($value)) continue;
						$dat = array();
						foreach($keys as $val) {
							if (isset($value[$val])&&!empty($value[$val])) $dat[$val] = stripinput($value[$val]);
						}
						$dat["bp"] = isset($value['bp'])&&$value['bp']=="ON"?1:0;
						if (!isset($dat['amount'])) $dat['amount'] = 1;
						if (isset($dat['res'])&&isset($dat['amount'])) {
							$res = dbquery("INSERT INTO ".DB_PREFIX."game_shop_items VALUES ('".$pid."','".(isset($dat['ord'])?$dat['ord']:"")."','".(isset($dat['name'])?$dat['name']:"")."',"
							."'".$dat['res']."','".$dat['amount']."','".$dat['bp']."')");
						}
					}
				}
			}
			redirect(FUSION_SELF.$aidlink."&server=".$server."&saved");
		} else {
			$res = dbquery("INSERT INTO ".DB_PREFIX."game_shop VALUES('','".$cat."','".$ord."','".$server."','".$name."','".$price_uah."','".$price_rub."','".$enabled."','".$desc."','".$img."','".$pack."','".$new."')");
			if ($res) {
				$pid = mysql_insert_id();
				if (count($resources)) {
					$keys = array("name","res","amount","ord");
					foreach($resources as $key=>$value) {
						if (!is_array($value)) continue;
						$dat = array();
						foreach($keys as $val) {
							if (isset($value[$val])&&!empty($value[$val])) $dat[$val] = stripinput($value[$val]);
						}
						$dat["bp"] = isset($value['bp'])&&$value['bp']=="ON"?1:0;
						if (!isset($dat['amount'])) $dat['amount'] = 1;
						if (isset($dat['res'])&&isset($dat['amount'])) {
							$res = dbquery("INSERT INTO ".DB_PREFIX."game_shop_items VALUES ('".$pid."','".(isset($dat['ord'])?$dat['ord']:"")."','".(isset($dat['name'])?$dat['name']:"")."',"
							."'".$dat['res']."','".$dat['amount']."','".$dat['bp']."')");
						}
					}
				}
			}
			redirect(FUSION_SELF.$aidlink."&server=".$server."&saved");
		}
	}

}

$field = "<div>Название: <input name='res[{I}][name]' type='text' value='{NAME}' class='textbox'> Класс: <input name='res[{I}][res]' type='text' value='{RES}' class='textbox'> Количество: <input name='res[{I}][amount]' type='text' value='{AMOUNT}' class='textbox' style='width:50px'> Порядок: <input name='res[{I}][ord]' type='text' value='{ORD}' class='textbox' style='width:30px'> Рецепт: <input name='res[{I}][bp]' type='checkbox' value='ON'{BP}>&nbsp;&nbsp;<img src='".VIP_IMAGES."remove.png' onclick='remove_field(this)' alt='Удалить' title='Удалить'></div>";
$field_add = preg_replace("/{(NAME|RES|ORD|AMOUNT|BP)}/","",$field);

$data = array("name"=>"","ord"=>"","server"=>(isset($_GET['server'])?intval($_GET['server']):0),"cat"=>"","price_uah"=>"","price_rub"=>"","enabled"=>1,"desc"=>"","img"=>"","new"=>0,"pack"=>0);

if ($edit) {
	$res = dbquery("SELECT * FROM ".DB_PREFIX."game_shop WHERE id='".$id."'");
	if (dbrows($res)) $data = dbarray($res);
}

$oid = $id;
if (isset($_GET['copy'])) {
	$edit = false;
	$id = 0;
}

opentable((!$edit?"Добавить":"Редактировать")." предмет");

echo "<form name='paysform' action='".FUSION_SELF.$aidlink."&edit_item=".$id."' method='post'>
<table width='100%' cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2'>Название:</td>
<td class='tbl1'><input name='name' type='text' value='".$data['name']."' class='textbox'></td>
</tr>
<tr>
<td class='tbl2'>Категория:</td>
<td class='tbl1'><select class='textbox' name='cat'>";
$res = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_cats ORDER BY ord ASC");
while ($data2 = dbarray($res)) {
	echo "<option value='".$data2['id']."'".($data['cat']==$data2['id']?" selected":"").">".$data2['name']."</option>";
}
echo "</td>
</tr>
<tr>
<td class='tbl2'>Порядок:</td>
<td class='tbl1'><input name='ord' type='text' value='".$data['ord']."' class='textbox'></td>
</tr>
<tr>
<td class='tbl2'>Сервер:</td>
<td class='tbl1'><select class='textbox' name='server'>\n";
$servers = servers_arr();
foreach ($servers as $key=>$serv) {
	if ($key==1) continue;
	echo "<option value='".$key."'".($data['server']==$key?" selected":"").">".$serv[0]."</option>";
}
echo "</select></td>
</tr>
<tr>
<td class='tbl2'>Цена грн:</td>
<td class='tbl1'><input name='price_uah' type='text' value='".$data['price_uah']."' class='textbox'></td>
</tr>
<tr>
<td class='tbl2'>Цена руб:</td>
<td class='tbl1'><input name='price_rub' type='text' value='".$data['price_rub']."' class='textbox'></td>
</tr>
<tr>
<td class='tbl2'>Описание:</td>
<td class='tbl1'><textarea name='desc' rows=6 cols=50 class='textbox'>".$data['desc']."</textarea></td>
</tr>
<tr>
<td class='tbl2'>Картинка:</td>
<td class='tbl1'><input name='img' type='text' value='".$data['img']."' class='textbox'></td>
</tr>
<tr>
<td class='tbl2'>Опции:</td>
<td class='tbl1'><label><input name='enabled' type='checkbox' value='ON'".($data['enabled']?" checked":"")."> Включён</label>
 <label><input name='pack' type='checkbox' value='ON'".($data['pack']?" checked":"")."> Набор</label>
 <label><input name='new' type='checkbox' value='ON'".($data['new']?" checked":"")."> Новинка</label></td>
</tr>
<tr>
<td class='tbl2' align='center' colspan='2'>Предметы:</td>
</tr>
<tr>
<td class='tbl1' align='center' colspan='2' id='field_cont'>
[ <a onclick='return add_field()' href='#'>Добавить поле</a> ]<br><br>";
if ($edit || $id!=$oid) {
	$res2 = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_items WHERE pid='".$oid."'");
	if (dbrows($res2)) {
		$i = 0;
		while ($data2 = dbarray($res2)) {
			$field_edit = str_replace(
				array("{I}","{NAME}","{RES}","{ORD}","{AMOUNT}","{BP}"),
				array($i,$data2['name'],$data2['res'],$data2['ord'],$data2['amount'],($data2['bp']==1?" checked":"")),
			$field);
			echo $field_edit."\n";
			$i++;
		}
	}
} else echo str_replace("{I}","0",$field_add);
echo "</td>
</tr>
<tr>
<td class='tbl2' align='center' colspan='2'><input type='submit' value='Сохранить' class='button' name='save'></td>
</tr>";

echo "<script type='text/javascript'>
var last = $('#field_cont div').length;
if (last<0) last = 0;

function add_field() {
	var add = \"".$field_add."\";
	add = add.replace(/{I}/g,last);
	$('#field_cont').append(add);
	last++;
	return false;
}

function remove_field(obj) {

	$(obj).parent().remove();
}
</script>";

echo "</table></form>";

echo "<br><center>[ <a href='".FUSION_SELF.$aidlink."&server=".$data['server']."'>Назад</a> ]</center>";

closetable();

} else {

opentable("Управление предметами");

$server = isset($_GET['server'])?intval($_GET['server']):0;

echo "<center>[ <a href='".FUSION_SELF.$aidlink."&edit_item=0&server=".$server."'>Добавить предмет</a> ]</center><br>";

echo "<center>Сервер: <select class='textbox' onchange='location.href=\"".FUSION_SELF.$aidlink."&server=\"+this.value'>
<option value='0'>---</option>";
$servers = servers_arr();
foreach ($servers as $key=>$serv) {
	if ($key==1) continue;
	echo "<option value='".$key."'".($server==$key?" selected":"").">".$serv[0]." (".dbcount("(id)",DB_PREFIX."game_shop", "server='".$key."'").")</option>";
}
echo "</select></center><br>";

if ($server!=0) {

$res = dbquery("SELECT * FROM ".DB_PREFIX."game_shop WHERE server='".$server."' ORDER BY ord ASC");

if (dbrows($res)) {

echo "<table cellpadding='0' cellspacing='1' class='tbl-border' align='center'>
<tr>
<td class='tbl2'><b>ID</b></td>
<td class='tbl2'><b>Название</b></td>
<td class='tbl2'><b>Ресурсы</b></td>
<td class='tbl2'><b>Покупок</b></td>
<td class='tbl2'><b>Порядок</b></td>
<td class='tbl2'><b>Статус</b></td>
<td class='tbl2'><b>Опции</b></td>
</tr>";
   $i = 0;
while ($data = dbarray($res)) {
	$restxt = "";
	$res2 = dbquery("SELECT * FROM ".DB_PREFIX."game_shop_items WHERE pid='".$data['id']."'");
	if (dbrows($res2)) {
		while ($data2 = dbarray($res2)) {
			$restxt .= get_res_name($data2)." - ".$data2['amount']."\n";
		}
	}

	$count = dbcount("(pid)",DB_PREFIX."game_vip_pays","server='".$server."' AND vip_time='".$data['id']."' AND stype='1' AND status='1' AND type='0'");

	$i % 2 == 0 ? $tclass="tbl1" : $tclass="tbl2";
	echo "<tr>
	<td class='$tclass' align='center'>".$data['id']."</td>
	<td class='$tclass'>".$data['name']."</td>
	<td class='$tclass' align='center' title='".$restxt."'>-?-</td>
	<td class='$tclass' align='center'>".$count."</td>
	<td class='$tclass' align='center'>".$data['ord']."</td>
	<td class='$tclass' align='center'><img src='".VIP_IMAGES."lightbulb".($data['enabled']?"":"_off").".png' title='".($data['enabled']?"Вкл":"Выкл")."'></td>
	<td class='$tclass' align='center' width='60'>"
	."<a href='".FUSION_SELF.$aidlink."&edit_item=".$data['id']."&amp;copy'><img src='".VIP_IMAGES."page_copy.png' alt='Копировать' title='Копировать'></a> "
	."<a href='".FUSION_SELF.$aidlink."&edit_item=".$data['id']."'><img src='".VIP_IMAGES."edit.png' alt='Редактировать' title='Редактировать'></a> "
	."<a href='".FUSION_SELF.$aidlink."&del_item=".$data['id']."' onclick='return check_delete()'><img src='".VIP_IMAGES."remove.png' alt='Удалить' title='Удалить'></a>"
	."</td>
	</tr>"; $i++;
}
echo "</table>";

echo "<script type='text/javascript'>
function check_delete() {
	return confirm('Вы дейтсвительно хотите удалить эту категорию со всеми предметами?');
}
</script>";

} else {
	echo "<center>В базе данных нет категорий.</center>";
}

}

closetable();

}

}

require_once THEMES."templates/footer.php";

?>