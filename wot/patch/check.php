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
require_once("core.php");

//file_put_contents("logs/test.txt",print_r($_GET,true));
//file_put_contents("logs/test2.txt",print_r($_POST,true));

if (!isset($_POST['name'])) die();

$log = array();

$log["data"] = array();

$log["ver"] = (isset($_POST['ver'])&&preg_match("/[0-9b.]/",$_POST['ver'])?$_POST['ver']:0);

$mods_arr = $mods_last;

if ($log["ver"]!=get_last_version(true)) {	if (isset($mods[$log["ver"]])) $mods_arr = $mods[$log["ver"]];
	else { $mods_arr = array(); $log['outdated'] = true; }
}

foreach($mods_arr as $key=>$val) {
	if (isset($_POST[$key])) {
		if ($key=="xvm"&&preg_match("/[0-9.]+/",$_POST[$key])) {
			$log["data"][] = array($key,true,str_replace("{#XVM}",$_POST[$key],$val),0);
		} else {
			$log["data"][] = array($key,true,$val,substr_count($key,"-"));
		}
	} else {		$log["data"][] = array($key,false,$val,substr_count($key,"-"));
	}
}

//if (isset($_POST['id'])&&preg_match("/^[0-9]+$/",$_POST['id'])) $log["id"] = $_POST['id'];
$log["name"] = preg_replace("/[^0-9A-Za-z-_]/","",$_POST['name']);
$log["date"] = time();

file_put_contents("logs/".$log["name"].".cache",serialize($log));

echo "OK";

/*
$log = "Ник в игре: ".$_POST['name']."\n\n";

foreach($arr as $key=>$val) {	if (isset($_POST[$key])) {		if ($key=="xvm"&&preg_match("/[0-9.]+/",$_POST[$key])) {			$log .= str_replace("{#XVM}",$_POST[$key],$val)."\n";
		} else {
			if (substr_count($key,"-")>0) {				$log .= str_repeat("\t",substr_count($key,"-"));
			}			$log .= $val."\n";
		}
	}
}

$log .= "\nВерсия патча: ".(isset($_POST['ver'])&&preg_match("/[0-9b.]/",$_POST['ver'])?$_POST['ver']:"Ошибка");
$log .= "\nДата отправки данных: ".date("d/m/Y H:i:s");

file_put_contents("logs/".preg_replace("/[^0-9A-Za-z-_]/","",$_POST['name']).".txt",$log);
*/
?>