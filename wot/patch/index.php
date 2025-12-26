<?php
/*
 * Modpack usage statistics script
 * Author: AlexALX
 * License: MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
?><html>
<head>
<title>Статистика патча</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<style type='text/css'>
body {	background-color: #f0f0f0;
}
</style>
</head>
<body>
<?php

	require_once("core.php");

	$query = $_SERVER['QUERY_STRING'];
	if ($query=="") {

	echo "Последняя версия патча: v".get_last_version()."<br><br>";

?>
<a href='log.txt'>Статистика скачиваний патча</a>
<br>
<br>Статистика использования патча по игрокам:
<br>
<table>
<?php

$i = 0;
foreach(glob("logs/*.cache") as $file) {
	//if ($i!=0) echo "<br>";
	$name = str_replace(".cache","",basename($file));	echo "<tr><td><a href='index.php?".$name."'>".$name."</a></td><td>".date("d/m/Y H:i:s",filemtime($file))."</td></tr>";
	$i++;
}

echo "</table>";

if ($i==0) echo "Нет данных.";
else {	echo "<br>Всего патч установило: ".$i." человек";
	echo "<br><a href='global.php'>Глобальная статистика использования модов</a>";
}

} else {

?>

<a href='index.php'>Назад</a><br><br>

<?php
if (!file_exists("logs/".$query.".cache")) echo "Данный игрок не найден.";
else {	$info = @unserialize(file_get_contents("logs/".$query.".cache"));
	if ($info!==false) {		echo "Ник в игре: <a target='_blank' href='http://worldoftanks.ru/community/accounts/".(isset($info['id'])?$info['id']."/":"#wot&at_search=".$info['name'])."'>".$info['name']."</a><br>";
		echo "Дата обновления: ".date("d/m/Y H:i:s",$info['date'])."<br>";
		echo "Версия сборки: ".str_replace("b"," <b><font color='#FF0000'>BETA</font></b>",$info['ver'])."<br>";
		echo "<br>Выбраные опции:<br><div style='font-size: 14px;border: 1px solid #828790;width:650px;background-color: #fff;'>";

		if (isset($info['outdated'])) {			echo "Данные устарели, используется старая или новая сборка.";
		} else {
			foreach($info['data'] as $arr) {
				if ($arr[0]=="xvm"&&strpos($arr[2],"{#XVM}")!==false) $arr[2] = "XVM";				echo str_repeat("&nbsp;<img src='dots.jpg'>&nbsp;",$arr[3])."<label><input name='".$arr[0]."' type='".(strpos($arr[0],"zoomx-")!==false||strpos($arr[0],"hp-v")!==false||strpos($arr[0],"angar-")!==false?"radio":"checkbox")."' value='ON'".($arr[1]?" checked":"")." onclick='this.checked = ".($arr[1]?"true":"false")."; return false;'> ".$arr[2]."</label><br>";
			}
		}

		echo "</div>";

	} else echo "Ошибка разбора данных.";
}

}

?>
</body>
</html>