<?php
/*

This script receive data from online-web.lua plugin
Then store in .json file for display it on some page later
Should have cache/ folder writable nearby

-----------

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

	// should match plugin variable
	$api_key = "someKey";

    if(isset($_GET['key']) && $_GET['key']==$api_key && isset($_POST['list'])) {
        $list = $_POST['list'];
        $players = explode('||,||',$list);
        //array_shift($players);

		$add = "1";
		if (isset($_GET['server'])&&$_GET['server']=="2") $add = "2";
		if (isset($_GET['server'])&&$_GET['server']=="3") $add = "3";
		if (isset($_GET['server'])&&$_GET['server']=="99") $add = "99";

        if (file_exists("cache/".$add.".json")) {
        	$json = unserialize(file_get_contents("cache/".$add.".json"));
        } else {
        	$json = array();
        }
        if (!is_array($json)) $json = array();
        $list = array();
        foreach($players as $name) {
        	if ($name=="") continue;
        	$list[$name] = (isset($json[$name])?$json[$name]:time());
        }

    	file_put_contents('cache/'.$add.'.json', serialize($list));
    }
?>