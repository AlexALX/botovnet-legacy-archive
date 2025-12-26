/*

This plugin displays welcome messages in global chat when player connect/disconnect
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

if SERVER then

AddCSLuaFile()

util.AddNetworkString("Welcome.Player");

local function welcome_player(ply)
	net.Start("Welcome.Player");
	net.WriteInt(1,8);
	net.Send(ply);
	net.Start("Welcome.Player");
	net.WriteInt(2,8);
	net.WriteEntity(ply)
	net.WriteColor(team.GetColor(ply:Team()))
	net.Broadcast();
end

local joined = {};

hook.Add("KeyPress","Welcome.Player.Connect",
	function(p,key)
		if(not joined[p] and (key == IN_FORWARD or key == IN_BACK or key == IN_ATTACK)) then
			joined[p] = true; -- Do not call this hook twice!
			welcome_player(p);
		end
	end
);

hook.Add("PlayerDisconnected","Welcome.Player.Disconnect",function(ply)
	net.Start("Welcome.Player");
	net.WriteInt(3,8);
	net.WriteString(ply:Name())
	net.WriteColor(team.GetColor(ply:Team()))
	net.Broadcast();
	joined[ply] = nil;
end)

else

local MESSAGES = {
	["ru"] = {
		["WELCOME"] = "Приветствую! Добро пожаловать на сервер звёздных врат!",
		["WELCOME_ALL"] = "Привествуем %s! Добро пожаловать на сервер!",
		["EXIT"] = "Игрок %s ушёл с сервера!",
	},
	["en"] = {
		["WELCOME"] = "Welcome to the stargate server!",
		["WELCOME_ALL"] = "Welcome to the server, %s!",
		["EXIT"] = "Player %s has left the server!",
	}
}

local lang = GetConVarString("gmod_language");
if (lang=="ua") then lang = "ru"; end
if (lang!="ru") then lang = "en"; end
net.Receive("Welcome.Player",function(len)
	local type = net.ReadInt(8);
	if (type==1) then
		chat.AddText(Color(0,255,0),MESSAGES[lang]["WELCOME"]);
	elseif (type==2) then
		local ply = net.ReadEntity();
		if (not IsValid(ply) or ply==LocalPlayer()) then return end
		local color = net.ReadColor();
		chat.AddText(color,Format(MESSAGES[lang]["WELCOME_ALL"],ply:Name()));
	elseif (type==3) then
		local name = net.ReadString();
		local color = net.ReadColor();
		local h,s,v = ColorToHSV(color);
		color = HSVToColor(h,s,v*0.7);
		chat.AddText(color,Format(MESSAGES[lang]["EXIT"],name));
	end
end)

end