<?php
/*-------------------------------------------------------+
| PHP-Fusion Content Management System
| Copyright (C) 2002 - 2011 Nick Jones
| http://www.php-fusion.co.uk/
+--------------------------------------------------------+
| This script was a page with server physical status
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

if (!defined("IN_FUSION")) die();

$err = false;
$file = BASEDIR."temp/sensors.cache";
if (!file_exists($file)) $err = true;

if (!$err) {

$file = file_get_contents($file);
preg_match_all("/temp[1-5]:\s*\+([0-9.]+)°C/sUix",$file,$arr);
if (!isset($arr[1])||count($arr[1])<5) $err = true;

preg_match("/ST3300657SS:\s*([0-9.]+)°C/sUix",$file,$harr);
if (!isset($harr[1])) $err = true;

preg_match("/WD3200YS-01PGB0:\s*([0-9.]+)°C/sUix",$file,$harr2);
if (!isset($harr2[1])) $err = true;

}

function temp_color($temp,$type="cpu") {
	$colors = array(
		"34.9"=>array(1,"#001AE3"),"49.9"=>array(0,"#00BE00"),
		"59.9"=>array(0,"#E0D800"),"69.9"=>array(0,"#F5AC00"),
		"999"=>array(1,"#F50000")
	);
	if ($type=="hdd") $colors = array(
		"30"=>array(1,"#001AE3"),"39"=>array(0,"#00BE00"),
		"44"=>array(0,"#E0D800"),"49"=>array(0,"#F5AC00"),
		"999"=>array(1,"#F50000")
	);
	if ($type=="mb") $colors = array(
		"40"=>array(1,"#001AE3"),"60"=>array(0,"#00BE00"),
		"70"=>array(0,"#E0D800"),"75"=>array(0,"#F5AC00"),
		"999"=>array(1,"#F50000")
	);
	foreach($colors as $key=>$value) {
		if ($temp>$key) continue;
		$temp = "<div style='background-color:".$value[1].";".($value[0]==1?"color: #fff;":"")."'><b>".$temp."&deg;C</b></div>"; // text-shadow: 1px 1px 0.5px #555;
		break;
	}
	return $temp;
}


$stage = "<span style='color:gray'><b>Данные недоступны</b></span>";

$tarr = array();

if (!$err) {
	$tarr = array(
		"Процессор #1"=>array("cpu",$arr[1][0]),"Процессор #2"=>array("cpu",$arr[1][1]),
		"Процессор #3"=>array("cpu",$arr[1][2]),"Процессор #4"=>array("cpu",$arr[1][3]),
		"Материнская плата"=>array("mb",$arr[1][4]),
		"SAS Seagate 300GB"=>array("hdd",$harr[1]),
		"SATA WD 320GB"=>array("hdd",$harr2[1])
	);

	$tstage = array($arr[1][0],$arr[1][1],$arr[1][2],$arr[1][3]); // ,$arr[1][4]
	$temp = max($tstage);
	if ($temp<50) $stage = "<span style='color:green'><b>Норма</b></span>";
	elseif ($temp<60) $stage = "<span style='color:#B9B600'><b>Небольшой нагрев</b></span>";
	elseif ($temp<70) $stage = "<span style='color:orange'><b>Умеренный перегрев</b></span>";
	else $stage = "<span style='color:red'><b>Сильный перегрев</b></span>";

}

echo "<table cellpadding='1' cellspacing='1' width='100%' class='tbl-border'>\n";

echo "<tr>
<td class='tbl2' colspan='2'><b>Botov-NET</b> [<a href='/images/botov/SDC10529.JPG' target='_blank'>Фото1</a>] [<a href='/images/botov/SDC10532.JPG' target='_blank'>Фото2</a>]</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Процессоры:</b></td>
<td class='tbl1' width='50%'>4xAMD Opteron 8389 2.90GHz</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Количество ядер:</b></td>
<td class='tbl1' width='50%'>16 (4x4)</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Материнская плата:</b></td>
<td class='tbl1' width='50%'>Supermicro H8QM3-2</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Оперативная память:</b></td>
<td class='tbl1' width='50%'>8x2GB DDR2 REG 667 Mhz (16 ГБ)</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Винчестера:</b></td>
<td class='tbl1' width='50%'>SAS Seagate 15K.7 15000rpm 300GB 16Mb
<br>SATA-2 320Gb WD3200YS 7200rpm 16Mb</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Блок питания:</b></td>
<td class='tbl1' width='50%'>Thermaltake SP850M 850W</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Операционная система:</b></td>
<td class='tbl1' width='50%'>Linux Ubuntu Server 12.04 x64</td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Статус:</b></td>
<td class='tbl1' width='50%'><span style='color:green'><b>Работает</b></span></td>
</tr>";

echo "<tr>
<td class='tbl1' width='50%'><b>Состояние температуры:</b></td>
<td class='tbl1' width='50%'>".$stage."</td>
</tr>";
     /*
echo "<tr>
<td class='tbl1' width='50%'><b>Комментарий:</b></td>
<td class='tbl1' width='50%'>Необходимы установить новые кулера для охлаждения процессоров, т.к. лето наступило и температура некоторых процессоров уже бывает <strong>72+</strong> градусов.</tr>";
       */
echo "<tr><td class='tbl2' align='center' colspan='2'><b>Температура сервера</b></td></tr>";

if (!$err) {

echo "<tr>
<td class='tbl1' colspan='2' align='center'>
<table class='tbl-border' cellpadding='1' cellspacing='1'>
<tbody><tr>
<td class='tbl2' align='center'><b>Тип</b></td>
<td class='tbl2' align='center'><b>Температура</b></td>
</tr>";

foreach($tarr as $key=>$value) {
	echo "<tr>
	<td class='tbl1' align='center'>".$key."</td>
	<td class='tbl1' align='center'>".temp_color($value[1],$value[0])."</td>
	</tr>";
}

echo "</tbody></table>
<br>Данные обновляются раз в 5 минут.
</td>
</tr>";

}

if ($err) {
echo "<tr><td class='tbl1' align='center' colspan='2'>Данные временно не доступны.</td></tr>";
}

echo "</table>";

?>