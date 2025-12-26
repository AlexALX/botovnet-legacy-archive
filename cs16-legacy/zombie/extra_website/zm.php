<?php
/*
MIT License

Copyright (c) 2015 by AlexALX

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND...
*/

header('Content-Type: text/html; charset=utf-8');
error_reporting(0);

if (!defined("BASEDIR"))
	define("BASEDIR","");

echo "<center><a href='http://botov.net.ua/forum/index.php?showtopic=969' target='_blank'><b>Скачать модели</b></a><br>Распаковывать в папку cstrike/models/player</center><br><table cellpadding='1' cellspacing='1' width='100%' class='tbl-border'>\n";

echo "<tr>
<td class='tbl2' width='50%' colspan='3' align='center'><b>Значения</b></td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Здоровье</b></td>
<td class='tbl1' width='65%'>Количество жизней у человека/зомби.</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Скорость</b></td>
<td class='tbl1' width='65%'>Скорость передвижения человека/зомби.</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Высота прыжка (гравитация)</b></td>
<td class='tbl1' width='65%'>Высота прыжка человека/зомби (значение гравитации).</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Сила атаки</b></td>
<td class='tbl1' width='65%'>Сила атаки человека/зомби.</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Сила повреждения</b></td>
<td class='tbl1' width='65%'>Сила повреждениям человека/зомби от пуль/гранаты/ножа. Чем ниже значение, тем меньше повреждение.</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Скорость при повреждении</b></td>
<td class='tbl1' width='65%'>Скорость зомби при его повреждении (от пуль).</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Восстановление скорости</b></td>
<td class='tbl1' width='65%'>Скорость восстановления нормальной скорости зомби после повреждения (в секундах).</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Регенерация</b></td>
<td class='tbl1' width='65%'>Скорость восстановления здоровья зомби.</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Включение регенерации</b></td>
<td class='tbl1' width='65%'>Включение регенерации здоровья у зомби после повреждения (в секундах).</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Сила отдачи</b></td>
<td class='tbl1' width='65%'>Сила отдачи зомби, когда по нему стреляют. Чем ниже значение, тем меньше отдача.</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Специальная возможность</b></td>
<td class='tbl1' width='65%'>Особое умение у данного класса зомби.</td>
</tr>";

echo "</table><br>";

//$zm_class = array();

//include(BASEDIR."zm_class.php");

if (!file_exists(BASEDIR."zm_class.php")) {
echo "Ошибка парсинга файла конфигурации зомби.";

} else {

$zm_class = @parse_ini_file(BASEDIR."zm_class.php",true);

if (!$zm_class) {

echo "Ошибка парсинга файла конфигурации зомби.";

} else {

function is_true_float($val){
    if( is_float($val) && ( (float) $val > (int) $val || strlen($val) != strlen( (int) $val) ) && (int) $val != 0  ) return true;
    else return false;
}

echo "<table cellpadding='1' cellspacing='1' width='100%' class='tbl-border'>\n";

echo "<tr>
<td class='tbl2' width='50%' colspan='3' align='center'><b>Человек</b> (для сравнения)</td>
</tr>";

echo "<tr>
<td class='tbl2' rowspan='10'><a href='".BASEDIR."images/zombie/human.png'><img src='".BASEDIR."images/zombies/human.png' align='left' width='150' height='200'></a></td>
<td class='tbl2' width='35%'><b>Здоровье:</b></td>
<td class='tbl1' width='65%'><img src='".BASEDIR."images/star.gif' align='left'> (100)</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Скорость:</b></td>
<td class='tbl1' width='65%'><img src='".BASEDIR."images/star.gif' align='left'><img src='".BASEDIR."images/star.gif' align='left'> (210-260 в зависимости от оружия)</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Высота прыжка:</b></td>
<td class='tbl1' width='65%'><img src='".BASEDIR."images/star.gif' align='left'><img src='".BASEDIR."images/star.gif' align='left'> (1.0)</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Сила атаки:</b></td>
<td class='tbl1' width='65%'><img src='".BASEDIR."images/star.gif' align='left'><img src='".BASEDIR."images/star.gif' align='left'> (1.0)</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Сила повреждения:</b></td>
<td class='tbl1' width='65%'><img src='".BASEDIR."images/star.gif' align='left'><img src='".BASEDIR."images/star.gif' align='left'><img src='".BASEDIR."images/star.gif' align='left'><img src='".BASEDIR."images/star.gif' align='left'><img src='".BASEDIR."images/star.gif' align='left'><img src='".BASEDIR."images/star.gif' align='left'> (0.1)</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Скорость при повреждении:</b></td>
<td class='tbl1' width='65%'>---</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Восстановление скорости:</b></td>
<td class='tbl1' width='65%'>---</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Регенерация:</b></td>
<td class='tbl1' width='65%'>---</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Включение регенерации:</b></td>
<td class='tbl1' width='65%'>---</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Сила отдачи:</b></td>
<td class='tbl1' width='65%'>---</td>
</tr>";

echo "</table><br>";

function parse_star($val,$type) {

$star = "<img src='".BASEDIR."images/star.gif' align='left'>";

if ($type == "HEALTH") {
	if ($val < 120)			$result = str_repeat($star,1);
	else if ($val < 140)	$result = str_repeat($star,2);
	else if ($val < 160)	$result = str_repeat($star,3);
	else if ($val < 195)	$result = str_repeat($star,4);
	else if ($val < 245)	$result = str_repeat($star,5);
	else if ($val < 325)	$result = str_repeat($star,6);
	else if ($val >= 325)	$result = str_repeat($star,7);
} else if ($type == "SPEED") {
	if ($val <= 235)		$result = str_repeat($star,1);
	else if ($val <= 250)	$result = str_repeat($star,2);
	else if ($val < 280)	$result = str_repeat($star,3);
	else if ($val <= 300)	$result = str_repeat($star,4);
	else if ($val <= 350)	$result = str_repeat($star,5);
	else if ($val > 350)	$result = str_repeat($star,6);
} else if ($type == "GRAVITY") {
	if ($val < 0.36)		$result = str_repeat($star,5);
	else if ($val < 0.5)	$result = str_repeat($star,4);
	else if ($val <= 0.9)	$result = str_repeat($star,3);
	else if ($val == 1.0)	$result = str_repeat($star,2);
	else if ($val > 1.0)	$result = str_repeat($star,1);
} else if ($type == "ATTACK") {
	if ($val <= 0.5)		$result = str_repeat($star,1);
	else if ($val <= 1.0)	$result = str_repeat($star,2);
	else if ($val <= 1.5)	$result = str_repeat($star,3);
	else if ($val <= 2.0)	$result = str_repeat($star,4);
	else if ($val <= 2.5)	$result = str_repeat($star,5);
	else if ($val > 2.5)	$result = str_repeat($star,6);
} else if ($type == "DEFENCE") {
	if ($val <= 0.05)		$result = str_repeat($star,1);
	else if ($val <= 0.06)	$result = str_repeat($star,2);
	else if ($val <= 0.07)	$result = str_repeat($star,3);
	else if ($val <= 0.08)	$result = str_repeat($star,4);
	else if ($val <= 0.09)	$result = str_repeat($star,5);
	else if ($val > 0.1)	$result = str_repeat($star,6);
} else if ($type == "HITSPEED") {
	if ($val <= 0.7)		$result = str_repeat($star,1);
	else if ($val <= 0.8)	$result = str_repeat($star,2);
	else if ($val <= 0.9)	$result = str_repeat($star,3);
	else if ($val <= 1.0)	$result = str_repeat($star,4);
	else if ($val > 1.0)	$result = str_repeat($star,5);
} else if ($type == "HITDELAY") {
	if ($val <= 0.35)		$result = str_repeat($star,4);
	else if ($val <= 0.4)	$result = str_repeat($star,3);
	else if ($val <= 0.5)	$result = str_repeat($star,2);
	else if ($val >= 0.5)	$result = str_repeat($star,1);
} else if ($type == "REGENDLY") {
	if (1/$val <= 4.6)		$result = str_repeat($star,1);
	else if (1/$val <= 6)	$result = str_repeat($star,2);
	else if (1/$val <= 9.6)	$result = str_repeat($star,3);
	else if (1/$val > 9.6)	$result = str_repeat($star,4);
} else if ($type == "HITREGENDLY") {
	if ($val <= 0.6)		$result = str_repeat($star,6);
	else if ($val < 1.0)	$result = str_repeat($star,5);
	else if ($val < 1.5)	$result = str_repeat($star,4);
	else if ($val < 2.0)	$result = str_repeat($star,3);
	else if ($val < 2.4)	$result = str_repeat($star,2);
	else if ($val > 2.4)	$result = str_repeat($star,1);
} else if ($type == "KNOCKBACK") {
	if ($val <= 0.45)		$result = str_repeat($star,1);
	else if ($val <= 0.7)	$result = str_repeat($star,2);
	else if ($val <= 1.0)	$result = str_repeat($star,3);
	else if ($val <= 1.4)	$result = str_repeat($star,4);
	else if ($val <= 1.7)	$result = str_repeat($star,5);
	else if ($val > 1.7)	$result = str_repeat($star,6);
}

return $result;
}

foreach ($zm_class as $zm_name => $zm_info) {

if (eregi("noburn",$zm_info[DESC]) && eregi("noflash",$zm_info[DESC]) && eregi("speedbullets",$zm_info[DESC]))
	$rowspan = 13;
else if (eregi("noburn",$zm_info[DESC]) && eregi("noflash",$zm_info[DESC]) || eregi("noflash",$zm_info[DESC]) && eregi("speedbullets",$zm_info[DESC]) || eregi("noburn",$zm_info[DESC]) && eregi("speedbullets",$zm_info[DESC]))
	$rowspan = 12;
else if (eregi("noburn",$zm_info[DESC]) || eregi("noflash",$zm_info[DESC]) || eregi("speedbullets",$zm_info[DESC]))
	$rowspan = 11;
else
	$rowspan = 10;

echo "<table cellpadding='1' cellspacing='1' width='100%' class='tbl-border'>\n";

echo "<tr>
<td class='tbl2' width='50%' colspan='3' align='center'><b>".$zm_name."</b> (".$zm_info[DESC].")</td>
</tr>";

if (file_exists(BASEDIR."images/zombie/".strtolower($zm_name).".png") && file_exists(BASEDIR."images/zombies/".strtolower($zm_name).".png"))
	$image = "<a href='".BASEDIR."images/zombie/".strtolower($zm_name).".png'><img src='".BASEDIR."images/zombies/".strtolower($zm_name).".png' align='left' width='150' height='200'></a>";
else if (file_exists(BASEDIR."images/zombies/".strtolower($zm_name).".png"))
	$image = "<img src='".BASEDIR."images/zombies/".strtolower($zm_name).".png' align='left' width='150' height='200'>";
else
	$image = "---";

echo "<tr>
<td class='tbl2' rowspan='$rowspan'>$image</td>
<td class='tbl2' width='35%'><b>Здоровье:</b></td>
<td class='tbl1' width='65%'>".parse_star($zm_info[HEALTH],'HEALTH')." (".str_replace(".0","",$zm_info[HEALTH]).")</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Скорость:</b></td>
<td class='tbl1' width='65%'>".parse_star($zm_info[SPEED],'SPEED')." (".str_replace(".0","",$zm_info[SPEED]).")</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Высота прыжка:</b></td>
<td class='tbl1' width='65%'>".parse_star($zm_info[GRAVITY],'GRAVITY')." (".$zm_info[GRAVITY].")</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Сила атаки:</b></td>
<td class='tbl1' width='65%'>".parse_star($zm_info[ATTACK],'ATTACK')." (".$zm_info[ATTACK].")</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Сила повреждения:</b></td>
<td class='tbl1' width='65%'>".parse_star($zm_info[DEFENCE],'DEFENCE')." (".$zm_info[DEFENCE].")</td>
</tr>";

if (eregi("speedbullets",$zm_info[DESC])) {
echo "<tr>
<td class='tbl2' width='35%'><b>Скорость при повреждении:</b></td>
<td class='tbl1' width='65%'>Увеличивается до ".str_replace(".0","",$zm_info[HITSPEED]).".</td>
</tr>";
} else {
echo "<tr>
<td class='tbl2' width='35%'><b>Скорость при повреждении:</b></td>
<td class='tbl1' width='65%'>".parse_star($zm_info[HITSPEED],'HITSPEED')." (".$zm_info[HITSPEED].")</td>
</tr>";
}

if (eregi("speedbullets",$zm_info[DESC])) {
echo "<tr>
<td class='tbl2' width='35%'><b>Восстановление скорости:</b></td>
<td class='tbl1' width='65%'>Уменьшаеться до ".str_replace(".0","",$zm_info[SPEED])." (".$zm_info[HITDELAY].").</td>
</tr>";
} else {
echo "<tr>
<td class='tbl2' width='35%'><b>Восстановление скорости:</b></td>
<td class='tbl1' width='65%'>".parse_star($zm_info[HITDELAY],'HITDELAY')." (".$zm_info[HITDELAY].")</td>
</tr>";
}

echo "<tr>
<td class='tbl2' width='35%'><b>Регенерация:</b></td>
<td class='tbl1' width='65%'>".parse_star($zm_info[REGENDLY],'REGENDLY')." (";

if (is_true_float(1/$zm_info[REGENDLY]))
	printf("%.1f",1/$zm_info[REGENDLY]);
else
	printf("%.0f",1/$zm_info[REGENDLY]);

echo " хп/сек)</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Включение регенерации:</b></td>
<td class='tbl1' width='65%'>".parse_star($zm_info[HITREGENDLY],'HITREGENDLY')." (".$zm_info[HITREGENDLY]." сек)</td>
</tr>";

echo "<tr>
<td class='tbl2' width='35%'><b>Сила отдачи:</b></td>
<td class='tbl1' width='65%'>".parse_star($zm_info[KNOCKBACK],'KNOCKBACK')." (".$zm_info[KNOCKBACK].")</td>
</tr>";

if (eregi("noburn",$zm_info[DESC]) && eregi("noflash",$zm_info[DESC]) && eregi("speedbullets",$zm_info[DESC])) {
echo "<tr>
<td class='tbl2' width='35%'><b>Специальная возможность:</b></td>
<td class='tbl1' width='65%'>Не горит от напалм гранат, не слепит от флешек (гранат/фонариков), ускоряется когда по нему стреляют.</td>
</tr>";
} else if (eregi("noburn",$zm_info[DESC]) && eregi("noflash",$zm_info[DESC])) {
echo "<tr>
<td class='tbl2' width='35%'><b>Специальная возможность:</b></td>
<td class='tbl1' width='65%'>Не горит от напалм гранат, не слепит от флешек (гранат/фонариков).</td>
</tr>";
} else if (eregi("noflash",$zm_info[DESC]) && eregi("speedbullets",$zm_info[DESC])) {
echo "<tr>
<td class='tbl2' width='35%'><b>Специальная возможность:</b></td>
<td class='tbl1' width='65%'>Не слепит от флешек (гранат/фонариков), ускоряется когда по нему стреляют.</td>
</tr>";
} else if (eregi("noburn",$zm_info[DESC]) && eregi("speedbullets",$zm_info[DESC])) {
echo "<tr>
<td class='tbl2' width='35%'><b>Специальная возможность:</b></td>
<td class='tbl1' width='65%'>Не горит от напалм гранат, ускоряется когда по нему стреляют.</td>
</tr>";
} else if (eregi("noburn",$zm_info[DESC])) {
echo "<tr>
<td class='tbl2' width='35%'><b>Специальная возможность:</b></td>
<td class='tbl1' width='65%'>Не горит от напалм гранат.</td>
</tr>";
} else if (eregi("noflash",$zm_info[DESC])) {
echo "<tr>
<td class='tbl2' width='35%'><b>Специальная возможность:</b></td>
<td class='tbl1' width='65%'>Не слепит от флешек (гранат/фонариков).</td>
</tr>";
} else if (eregi("speedbullets",$zm_info[DESC])) {
echo "<tr>
<td class='tbl2' width='35%'><b>Специальная возможность:</b></td>
<td class='tbl1' width='65%'>Ускоряется когда по нему стреляют.</td>
</tr>";
}

echo "</table><br>";

}

}

}

echo "<center>&copy; 2009-2010 by <a href='http://alex-php.net/'>AlexALX</a></center>";

?>