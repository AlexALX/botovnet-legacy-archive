/*

This plugin is part of VIP system for gmod and website based on PHP-Fusion
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

local URL_PREFIX = "http://botov.net.ua/"
local MESSAGES = {	["ru"] = {
		["YOU_VIP"] = "Ваш VIP активен до:",
		["YOU_VIPFREE"] = "Вы имеете бесплатный VIP аккаунт до:",
		["YOU_NVIP"] = "Вы не VIP!",
		["YOU_NVIP2"] = "Напишите ",
		["YOU_NVIP3"] = " для более подробной информации.",
		["YOU_BVIP"] = "Ваш VIP аккаунт заблокирован!",
		["YOU_FVIP"] = "Ваш VIP аккаунт заморожен!",
		["YOU_EVIP"] = "Вы уже не VIP! Дата окончания VIP'а:",
		["YOU_DVIP"] = "VIP система отключена!",
		["VIP_UNL"] = "неограничено",
		["VIPS"] = "VIP'ы онлайн",
		["VIPS_NO"] = "Нет онлайн VIP'ов.",
		["VIP_INFO"] = "Информация о VIP",
		["VIP_CMDS"] = "VIP Команды"
	},
	["en"] = {		["YOU_VIP"] = "You VIP are active to:",
		["YOU_VIPFREE"] = "You FREE VIP are active to:",
		["YOU_NVIP"] = "You are not VIP!",
		["YOU_NVIP2"] = "Type ",
		["YOU_NVIP3"] = " for view more information. (only for russian!)",
		["YOU_BVIP"] = "Your VIP account is blocked!",
		["YOU_FVIP"] = "Your VIP account is unactive!",
		["YOU_EVIP"] = "You are not VIP! End Date:",
		["VIP_UNL"] = "unlimined",
		["VIPS"] = "VIPs online",
		["VIPS_NO"] = "No vips online.",
		["VIP_INFO"] = "VIP Information",
		["VIP_CMDS"] = "VIP Commands"
	}
}

local lang = GetConVarString("gmod_language");
if (lang=="ua") then lang = "ru"; end
if (lang!="ru") then lang = "en"; end
net.Receive("VIP.Player.Chat",function(len)
	local type = net.ReadInt(8);
	if (type==0) then
		chat.AddText(Color(210,0,0),MESSAGES[lang]["YOU_DVIP"]);
	elseif (type==2) then
		local tbl = net.ReadTable();
		local count = table.Count(tbl);
		chat.AddText(Color(0,210,0),MESSAGES[lang]["VIPS"]);
		if (count>0) then
			local vips = "";
			local i = 0
			for k,v in pairs(tbl) do
				if (i!=0) then vips = vips..", "; end
				vips = vips..v;
				i = i + 1;
			end
			chat.AddText(Color(255,255,255),vips);
		else
			chat.AddText(Color(255,255,255),MESSAGES[lang]["VIPS_NO"]);
		end
	elseif (type==3) then
		local serv = net.ReadInt(8);
		local cmds = util.tobool(net.ReadBit());
		if (cmds) then
			VIP_ShowMotd(MESSAGES[lang]["VIP_CMDS"],URL_PREFIX.."infusions/personal/motd.php?commands="..serv)
		else
			VIP_ShowMotd(MESSAGES[lang]["VIP_INFO"],URL_PREFIX.."infusions/personal/motd.php?server="..serv)
		end
	else
		local vip = util.tobool(net.ReadBit());
		local time = tonumber(net.ReadString());
		local free = util.tobool(net.ReadBit());
		local status = net.ReadInt(8);

		if (vip) then
			local msg = MESSAGES[lang]["YOU_VIP"];
			if (free) then
				msg = MESSAGES[lang]["YOU_VIPFREE"];
			end
			local date = os.date("%d/%m/%Y %H:%M:%S",time)
			if (time==0) then date = MESSAGES[lang]["VIP_UNL"] end
			chat.AddText(Color(0,210,0),msg," ",Color(255,255,255),date);
		else
			if (status==1 and time!=0 and time!=-1) then
				local date = os.date("%d/%m/%Y %H:%M:%S",time)
				if (time==0) then date = MESSAGES[lang]["VIP_UNL"] end
				chat.AddText(Color(210,0,0),MESSAGES[lang]["YOU_EVIP"]," ",Color(255,255,255),date);
			elseif (status==0) then
				chat.AddText(Color(0,210,210),MESSAGES[lang]["YOU_FVIP"]);
			elseif (status==2) then
				chat.AddText(Color(210,0,0),MESSAGES[lang]["YOU_BVIP"]);
			else
				chat.AddText(Color(210,0,0),MESSAGES[lang]["YOU_NVIP"]);
				chat.AddText(Color(255,255,255),MESSAGES[lang]["YOU_NVIP2"],Color(0,210,0),"!vipinfo",Color(255,255,255),MESSAGES[lang]["YOU_NVIP3"]);
			end
		end
	end
end)

function VIP_ShowMotd(title,url)
	local window = vgui.Create( "DFrame" )
	if ScrW() > 640 then -- Make it larger if we can.
		window:SetSize( ScrW()*0.9, ScrH()*0.9 )
	else
		window:SetSize( 640, 480 )
	end
	window:Center()
	window:SetTitle( title or "" )
	window:SetVisible( true )
	window:MakePopup()

	local html = vgui.Create( "HTML", window )

	local button = vgui.Create( "DButton", window )
	button:SetText( "Close" )
	button.DoClick = function() window:Close() end
	button:SetSize( 100, 40 )
	button:SetPos( (window:GetWide() - button:GetWide()) / 2, window:GetTall() - button:GetTall() - 10 )

	html:SetSize( window:GetWide() - 20, window:GetTall() - button:GetTall() - 50 )
	html:SetPos( 10, 30 )
	html:OpenURL( url )
end