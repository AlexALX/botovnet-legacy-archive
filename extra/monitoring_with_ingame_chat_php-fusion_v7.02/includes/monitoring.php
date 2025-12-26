<?php
/*-------------------------------------------------------+
| PHP-Fusion Content Management System
| Copyright (C) 2002 - 2011 Nick Jones
| http://www.php-fusion.co.uk/
+--------------------------------------------------------+
| This script is part of monitoring system
| Used on Botov-NET servers
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

// This script requires https://github.com/xPaw/PHP-Source-Query-Class
// Might not work with new versions, was used in 2015 year

if (!defined("IN_FUSION")) die("Access Denied.");

function cmp($a, $b) {
  $orderBy=array('kills'=>'desc', 'Frags'=>'desc', 'frag'=>'desc', 'name'=>'asc');
  $result= 0;
  foreach( $orderBy as $key => $value ) {
    if( $a[$key] == $b[$key] ) continue;
    $result= ($a[$key] < $b[$key])? -1 : 1;
    if( $value=='desc' ) $result= -$result;
    break;
    }
  return $result;
}


function serverInfo_SQ($ip, $port, $game="",$dname="", $id=0) {
	require_once 'SourceQuery/SourceQuery.class.php';
	$Query = new SourceQuery();
	if ($game!="") $Query->Connect( $ip, $port, 1, SourceQuery :: SOURCE );
	else $Query->Connect( $ip, $port, 1, SourceQuery :: GOLDSOURCE );

	$data = $Query->GetInfo();

	$server = array();

	if (!is_array($data)) {
		$server['status'] = 'off';
	} else {
		$server['players'] = $data['Players'];
		$server['maxplayers'] = $data['MaxPlayers'];
		$server['name'] = $data['HostName'];
		$server['map'] = $data['Map'];
		$server['game'] = ($data['ModDesc']=="rust_server"?"Rust Experimental":$data['ModDesc']);
		$server['os'] = $data['Os'];
		$server['status'] = 'on';
		$server['sv_type'] = $data['Dedicated'];

		if($game=="rust") {
			if (file_exists(BASEDIR."sv_files/rust/cache/".($id).".json")) {
				$json = unserialize(file_get_contents(BASEDIR."sv_files/rust/cache/".($id).".json"));
				if (!is_array($json)) $json = array();

				$list = array();
				foreach($json as $name=>$time) {
					$list[] = array($name,$time);
				}

				for($i=0;$i<$server['players'];$i++) {
					if(isset($list[$i])&&trim($list[$i][0]))
						$server['stats'][$i] = array("name" => trim($list[$i][0]), "kills" => "-", "time" => gmdate("H:i:s", time()-$list[$i][1]));
					else
						$server['stats'][] = array("name" => "Соеденяется...", "kills" => "-", "time" => "-");
				}
			}
		} else {

			$players = $Query->GetPlayers( );
			if (is_array($players)) {
				usort($players, 'cmp');
				for($i=0;$i<$server['players'];$i++) {
					if(isset($players[$i]['Name'])&&trim($players[$i]['Name'])!="")
						$server['stats'][$i] = array("name" => htmlspecialchars($players[$i]['Name']), "kills" => $players[$i]['Frags'], "time" => $players[$i]['TimeF']);
					else
						$server['stats'][] = array("name" => "Соеденяется...", "kills" => "-", "time" => "-");
		        }
			}

			$rules = $Query->GetRules();
			if (is_array($players)) {
				$server['metamod'] = $rules['metamod_version'];
				$server['amxmodx'] = $rules['amxmodx_version'];
				$server['amxbans'] = $rules['amxbans_version'];
				if ($port=="28015") {
					$server['cap'] = $rules['stargate_cap_version'];
				}
				$server['dproto'] = $rules['dp_version'];
				$server['csdm'] = $rules['csdm_version'];
				$server['rhlg'] = $rules['rhlg_version'];
				$server['hlg'] = $rules['hlg_version'];
				$server['bio'] = $rules['bh_version'];
				$server['gg'] = $rules['gg_version'];
				$server['dr'] = $rules['deathrun_version'];
				$server['atac'] = $rules['atac_version'];
				$server['upatch'] = $rules['upatch_version'];
				$server['usurf'] = $rules['usurf_version'];
				$server['nextmap'] = $rules['amx_nextmap'];

				$server['timelimit'] = $rules['mp_timelimit'];

				$server['rt'] = $rules['mp_roundtime'];
				$server['ft'] = $rules['mp_freezetime'];
				$server['ff'] = $rules['mp_friendlyfire'];
				$server['fl'] = $rules['mp_flashlight'];
				$server['stm'] = $rules['mp_startmoney'];

				$server['tkp'] = $rules['mp_tkpunish'];

				$server['ve'] = $rules['sv_voiceenable'];
				$server['password'] = $rules['sv_password'];
			}

			/*if ($game!="")*/ $rcon = $Query->SetRconPassword("#botov_gmod_123");
			//else $rcon = $Query->SetRconPassword("botovnetuaa-123cxz");

			if ($rcon!=false) {
				$stats = explode("\n",$Query->Rcon("stats"));

				$stats_arr = explode(" ",trim($stats[1]));
				$cpu = $stats_arr[0];

				if ($cpu<15) {
					$server['cpu'] = "<span style='color:gray'>".round($cpu)."%</span>";
				} elseif ($cpu<60) {
					$server['cpu'] = "<span style='color:green'>".round($cpu)."%</span>";
				} elseif ($cpu<85) {
					$server['cpu'] = "<span style='color:blue'>".round($cpu)."%</span>";
				} else {
					$server['cpu'] = "<span style='color:red;font-weight:bold'>".round($cpu)."%</span>";
				}

			}

		}

	}

	$Query->Disconnect();

	return $server;
}

?>