/*

This plugin send to website online players and in-game chat
Other part of it is:
 infusions/personal/api/update.php - for online player list
 extra\monitoring_with_ingame_chat_php-fusion_v7.02\includes\sv_api\chat.php - for chat sync

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
local players = {}

local api_key = "someKey"

local function send_data(ply,connect)
	if (not IsValid(ply) or not ply:IsPlayer() or ply:IsBot()) then return end
	local url = "http://localhost/infusions/personal/api/update.php?key="..api_key.."&sid="..ply:SteamID64()
	if (connect) then url = url.."&stage=connect" end
	http.Post( url, {		["time"] = tostring(ply:GetUTimeTotalTime()),
		["frags"] = tostring(ply:Frags()),
		["death"] = tostring(ply:Deaths()),
		["name"] = ply:Name(),
		["server"] = "1"	})--,function(body) print(body) end)
end

hook.Add("PlayerInitialSpawn","BotovNET.WebUpdate",function(ply)
	timer.Simple(1,function()
		if (not IsValid(ply)) then return end
		send_data(ply,true);
		players[ply] = true
	end)
end)

hook.Add("PlayerDisconnected","BotovNET.WebUpdate",function(ply)
	send_data(ply);
	players[ply] = nil
end)

hook.Add("ShutDown","BotovNET.WebUpdate",function()
	for k,v in pairs(player.GetHumans()) do
		send_data(v);
	end
end)

timer.Create("BotovNet.WebUpdate",300.0,0,function()
	for k,v in pairs(player.GetHumans()) do
		if (players[v]) then
			send_data(v);
		end
	end
end)

for k,v in pairs(player.GetHumans()) do
	if (v:IsConnected()) then
		send_data(v);
		players[v] = true;
	end
end

hook.Add("PlayerSay","BotovNET.WebUpdate",function(ply,text)
	local url = "http://localhost/includes/sv_api/chat.php?key="..api_key
	local col = team.GetColor(ply:Team());
	http.Post( url, {
		["name"] = ply:Name(),
		["message"] = text,
		["color"] = col.r..","..col.g..","..col.b,
		["server"] = "1",
		["time"] = tostring(os.time())
	})--,function(body) print(body) end)
end)