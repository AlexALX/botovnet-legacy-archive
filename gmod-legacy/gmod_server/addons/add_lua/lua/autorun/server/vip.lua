/*

This plugin is part of VIP system for gmod and website based on PHP-Fusion
To see what it did you can check:
- extra/online_shop_vip_for_php-fusion_v7.02/xxx/motd.php (SERVER ID 1)

This plugin itself do nothing if not edit other plugins to use IsVIP functions!
Also have different permission support by VIPHasFlag and VIPHasOption

It was used with ULX, create VIP group, then set proper permissions for items etc

Used on Botov-NET gmod server

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

require( "mysqloo" )

AddCSLuaFile("autorun/client/vip.lua")

local DB_VIPS = "fusion_game_vip"
local DB_SETTINGS = "fusion_game_vip_set"
--local DB_SES = "fusion_csvips_ses"

local connected = false;
local queue = {}
local db = mysqloo.connect("localhost", "user", "pass", "dbname", 3306)

local vip_enabled=false
local amx_free_vip=false
local amx_free_vipt=0
local VIP_TYPE = {"Name","SteamID","IP"};
local DELAY_CHECK_VIP = 300.0;

local lua_vip_server = CreateConVar("lua_vip_server","0",{FCVAR_NEVER_AS_STRING});
local lua_vip_field = CreateConVar("lua_vip_field", "_vip",{});

util.AddNetworkString("VIP.Player.Chat");

function db:onConnected()
	print( "Database has connected!" )
	connected = true;
	reload_vips();
	--timer.Create("VIP_CLEAN_SES",360.0,0,function() clean_ses2() end)
end

function db:onConnectionFailed( err )
	print( "Connection to database failed!" )
	print( "Error:", err )
end

function query( sql, callback, error )
	if (!connected) then return end
	local q = db:query( sql )
	function q:onSuccess( data )
		if (callback!=nil) then callback( data ) end
	end
	function q:onError( err )
		print( "Query Errored, error:", err, " sql: ", sql )
		if (error!=nil) then error() end
	end
	q:start()
end

function SQL_Settings()
	local callback = function(data)
		if (data==nil or data[1]==nil) then return end
		local serv = lua_vip_server:GetInt();
		enabled = data[1]['enabled']
		servers = data[1]['servers']
		free_vip = data[1]['free_vip']
		free_vipt = data[1]['free_vipt']

		if (enabled==0 or serv==0) then
			vip_enabled = false;
		else
			vip_enabled = true;
			if (free_vip==1 and free_vipt>0 and servers:find("."..lua_vip_server:GetInt()..".")) then
				amx_free_vip = true;
				amx_free_vipt = free_vipt;
			end
		end
		--clean_ses();

		for k,p in pairs (player.GetHumans()) do
			if p:IsConnected() then
				check_ini(p,false);
			end
		end
	end
	query("SELECT * FROM "..DB_SETTINGS,callback);
end

local function SetPlayerTeam(ply)
	if (not IsValid(ply)) then return end
	local time = tonumber(ply:GetUTimeTotalTime());
    /*
	if (ply._gb_pirate and ply._gb_pirate==true and not ply:IsAdmin() and not ply:IsVIP()) then
		ply:SetUserGroup("user");
		return
	end*/

	if (ply:IsUserGroup("moderator")) then
		return
	end

	if (not ply:IsAdmin() and ply:IsVIP()) then
		if (ply:VIPHasFlag("t")) then
			if (time>=60*60*4) then
				ply:SetUserGroup("free_vip");
			else
				ply:SetUserGroup("user");
			end
		else
			ply:SetUserGroup("vip");
		end
		return
	end
	if (not ply:IsAdmin()) then
		if (time>=60*60*60) then
			ply:SetUserGroup("reg_player");
		elseif (time>=60*60*6) then
			ply:SetUserGroup("player");
		else
			ply:SetUserGroup("user");
		end
	end
end

function check_inif(ply)

	if(not IsValid(ply) or not ply:IsConnected()) then return end

	local time = tonumber(ply:GetUTimeTotalTime());

	if (os.time() <= amx_free_vipt and time>=60*60*4 and not ply:IsAdmin()) then
		ply.p_VIP = true
		ply.t_VIP = amx_free_vipt
		ply.f_VIP = "ctu"
		ply.o_VIP = "z"
		ply.s_VIP = 1
		ply.tp_VIP = 0;
		ply.v_VIP = 0;
	else
		ply.p_VIP = false
		ply.t_VIP = "0"
		ply.f_VIP = "z"
		ply.o_VIP = "z"
		ply.s_VIP = -1
		ply.tp_VIP = 0;
		ply.v_VIP = 0;
	end
end

function check_inis(ply)

	if(not IsValid(ply) or not ply:IsConnected()) then return end

	check_ini(ply,true);
end

function check_ini(ply,nomsg)

	if(not IsValid(ply) or not ply:IsConnected()) then return end

	ply.p_VIP = false
	ply.t_VIP = "0"
	ply.f_VIP = "z"
	ply.o_VIP = "z"
	ply.s_VIP = -1
	ply.tp_VIP = 0;
	ply.v_VIP = 0;

	if (vip_enabled!=true) then return end

	if (connected) then

		local callback = function(data)

            local name = ply:GetName();
            local steamid = ply:SteamID64();
            local ip = string.Explode(":",ply:IPAddress());
            ip = ip[1];
            --local password = ply:GetInfo(lua_vip_field:GetString());

            --local text,pass,type,time,status,vid;
            local time,status,vid,sid,type;

			for k,v in pairs(data) do
				--text = v['name'];
				--pass = v['password'];
				--type = v['type'];

				type = 1;
				sid = v['sid'];
				status = v['status'];
				time = v['time'];
				vid = v['vid'];
                --if ((type==0 and text:lower()==name:lower() and pass==password
				--or type==1 and text==steamid and (pass=="" or pass==password)
				--or type==2 and text==ip and pass==password) and (type==1 or nomsg or check_ses(vid,false))) then
				if (sid==steamid) then
					if (status==1) then
						if (time==0 or os.time() <= time) then
							ply.p_VIP = true;
							ply.t_VIP = time;
							ply.f_VIP = v['flags'];
							ply.o_VIP = v['options'];
							ply.s_VIP = status;
							ply.tp_VIP = type;
							if (type!=1) then
								ply.v_VIP = vid;
								--insert_ses(vid,ip)
							end
							if (not nomsg) then
								print("Login: \""..name.."<"..steamid.."><"..status..">\" vip (account type \""..VIP_TYPE[type+1].."\") (flags \""..ply.f_VIP.."\") (address \""..ip.."\")")
								ply:PrintMessage(HUD_PRINTCONSOLE,"* VIP Autorized");
							end
						else
							ply.p_VIP = false
							ply.t_VIP = time
							ply.f_VIP = "z"
							ply.o_VIP = "z"
							ply.s_VIP = status
							ply.tp_VIP = type
							ply.v_VIP = 0
							if (not nomsg) then
								print("Unactive login: \""..name.."<"..steamid.."><"..status..">\" vip (account type \""..VIP_TYPE[type+1].."\") (flags \""..ply.f_VIP.."\") (address \""..ip.."\")")
								ply:PrintMessage(HUD_PRINTCONSOLE,"* Warning: VIP Expired");
							end
						end
					else
						ply.p_VIP = false
						ply.t_VIP = time
						ply.f_VIP = "z"
						ply.o_VIP = "z"
						ply.s_VIP = status
						ply.tp_VIP = type
						ply.v_VIP = 0
						if (not nomsg) then
							print("Unactive login: \""..name.."<"..steamid.."><"..status..">\" vip (account type \""..VIP_TYPE[type+1].."\") (flags \""..ply.f_VIP.."\") (address \""..ip.."\")")
						end
					end
                end

                /*if (!is_user_bot(id) && status==1 && (!equal(pass, "")&&type==1||type!=1) && !equal(pass, password) ) {
					server_cmd("kick #%d You password for VIP is incorrect. Ваш пароль для VIP не правильный.",get_user_userid(id))
					return PLUGIN_HANDLED_MAIN
                }*/
     		end
     		SetPlayerTeam(ply);
		end
		query("SELECT vid,sid,time,flags,options,status FROM "..DB_VIPS.." WHERE server='0' OR server='"..lua_vip_server:GetInt().."'",callback);

		if (amx_free_vip==true and os.time() <= amx_free_vipt and not ply.p_VIP) then
			check_inif(ply)
		end

	end
	timer.Remove("VIP_CHECK_TASK")
	timer.Create("VIP_CHECK_TASK",DELAY_CHECK_VIP,1,function() check_inis(ply) end)
end
/*
function insert_ses(vid,ip)
	if (vid>0 and connected) then
		if (check_ses(vid,true)) then
			query("INSERT INTO "..DB_SES.." VALUES('"..vid.."','"..lua_vip_server:GetInt().."','"..ip.."','"..os.time().."')")
 		else
 			query("UPDATE "..DB_SES.." SET date='"..os.time().."', ip='"..ip.."' WHERE vid='"..vid.."'")
 		end
 	end
end

function check_ses(vid,insert)
	local ret = false;
	if (insert) then ret = true; end
	if (vid>0 and connected) then
    	local q = db:query( "SELECT * FROM "..DB_SES.." WHERE vid='"..vid.."'" )
		q:start();
		q:wait();
		local data = q:getData();
   		if table.Count(data or {})!=0 then
   			ret = false;
   		else
			ret = true;
   		end
	end

	return ret;
end

function remove_ses(vid)
	if (vid>0 && connected) then
    	query("DELETE FROM "..DB_SES.." WHERE vid='"..vid.."'");
	end
end

function clean_ses2()
    query("DELETE FROM "..DB_SES.." WHERE date<='"..(os.time()-60*7).."'");
end

function clean_ses()
    query("DELETE FROM "..DB_SES.." WHERE server='"..lua_vip_server:GetInt().."' OR date<='"..(os.time()-60*7).."'",function() end);
end
*/
function reload_vips(ply)
	if(IsValid(ply) and not ply:IsAdmin()) then return end

	SQL_Settings()

	if (IsValid(ply)) then ply:PrintMessage(HUD_PRINTCONSOLE, "[LUA] Reload vips comleted."); end
end
concommand.Add("lua_reloadvips",function(ply) reload_vips(ply) end)

hook.Add("PlayerSay", "VIP.Player.Chat", function(ply,txt)

	if (txt=="!vip"||txt=="!vips") then
		if (not vip_enabled) then
			net.Start("VIP.Player.Chat");
			net.WriteInt(0,8);
			net.Send(ply);
			return false
		end

		if (txt=="!vip") then
			net.Start("VIP.Player.Chat");
			net.WriteInt(1,8);
			net.WriteBit(ply.p_VIP)
			net.WriteString(ply.t_VIP)
			net.WriteBit(ply.f_VIP:find("u"))
			net.WriteInt(ply.s_VIP,8)
			net.Send(ply);
		else
			local tbl = {};
			for k,v in pairs(player.GetHumans()) do
				if (v:IsVIP()) then
					table.insert(tbl,v:Name());
				end
			end
			net.Start("VIP.Player.Chat");
			net.WriteInt(2,8);
			net.WriteTable(tbl)
			net.Send(ply);
		end
	elseif(txt=="!vipinfo"||txt=="!vipcommands") then
		net.Start("VIP.Player.Chat");
		net.WriteInt(3,8);
		net.WriteInt(lua_vip_server:GetInt(),8);
		net.WriteBit((txt!="!vipinfo"))
		net.Send(ply);
	end
end)

hook.Add("PlayerSpawn","VIP.Player.Spawn",function(ply)
	timer.Simple(0.1,function()
		if (IsValid(ply)) then
			SetPlayerTeam(ply);
		end
	end)
end)

db:connect();

hook.Add("PlayerInitialSpawn","VIP.Player.Init",function(ply)
	check_ini(ply);
end)
/*
hook.Add("ShutDown","VIP.ShutDown",function()
	clean_ses()
end)*/

local meta = FindMetaTable("Player")

function meta:IsVIP()
	if (IsValid(self) and self:IsConnected() and self.p_VIP == true and not self.f_VIP:find("z")) then return true; end
	return false;
end

function meta:VIPHasFlag(flag,ignore)
	if (IsValid(self) and (self:IsVIP() or ignore) and self.f_VIP:find(flag)) then
		return true;
	end
	return false;
end

function meta:VIPHasOption(opt)
	if (IsValid(self) and self:IsVIP() and self.o_VIP:find(opt)) then
		return true;
	end
	return false;
end