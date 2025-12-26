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

?>
<a href='index.php'>Назад</a>
<br>
<br>Глобальная статистика использования модов.
<br>Отображаються данные только тех у кого стоит последняя версия сборки (v<?php echo get_last_version() ?>).
<br>
<br>
<?php

$global = array();
$globaln = array();

$i = 0;
foreach(glob("logs/*.cache") as $file) {
	$info = @unserialize(file_get_contents($file));
	if ($info!==false && isset($info['data']) && get_last_version(true)==$info['ver']) {
		if (isset($info['outdated'])) continue;
		foreach($info['data'] as $val) {			if (array_key_exists($val[0],$mods_last)&&$val[1]) {				if (!isset($global[$val[0]])) { $global[$val[0]] = 0; $globaln[$val[0]] = array(); }
				$global[$val[0]]++;
				$globaln[$val[0]][] = $info['name'];
			}
		}
		$i++;
	}
}

if ($i>0) {

echo "<div style='font-size: 14px;border: 1px solid #828790;width:700px;background-color: #fff;padding-left: 5px;padding-right: 5px;'>";

foreach($mods_last as $key=>$val) {
	if ($key=="xvm") $val = "XVM";
	$perc = round(isset($global[$key])?$global[$key]/$i*100:0,2);   // text-shadow: 1px 1px 0px #aaa;
	echo "<span style='color: ".rgb2hex(hsv2rgb(120*($perc/100)+0.1,100,83))."' title='".(isset($globaln[$key])?implode(", ",$globaln[$key]):"")."'>".str_repeat("&nbsp;<img src='dots.jpg'>&nbsp;",substr_count($key,"-"))." ".$val." <div style='float: right'>".$perc."% [".(isset($global[$key])?$global[$key]:0)."]</div></span><br>";
}

echo "</div>";

}

if ($i==0) echo "Нет данных.";
else {	echo "<br>Всего патч установило: ".$i." человек";
}

?>
</body>
</html>