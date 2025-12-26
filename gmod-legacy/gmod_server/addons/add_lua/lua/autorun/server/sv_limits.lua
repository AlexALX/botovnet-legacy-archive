/*

This plugin adding some limitations for players and SWEP setup on spawn
Used for controll also guns for VIPs on spawn and some other stuff

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


hook.Add("PlayerSpawnSENT","LM.PlayerSpawnSENT",function(ply,class)
	if (not ply:IsVIP()) then
		local disabled = {"sent_webradio"}
		if (table.HasValue(disabled,class)) then
			ply:SendLua("GAMEMODE:AddNotify(\"This entity is not allowed for you rank!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return false;
		end
	end
end)

local PlayerSpawnSWEP = function(ply,class)
	if (type(class)!="string") then class = class:GetClass() end
	if (ply:IsUserGroup("user")) then
		local disabled = {"weapon_smg1","weapon_frag","weapon_crossbow","weapon_shotgun","weapon_357","weapon_rpg",
		"weapon_ar2","weapon_annabelle","weapon_slam","manhack_welder","flechette_gun","manhack_welder"}
		if (table.HasValue(disabled,class) or class:find("ptp_")) then
			ply:SendLua("GAMEMODE:AddNotify(\"This weapon is not allowed for you rank!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return false;
		end
	elseif (ply:IsUserGroup("player")) then
		local disabled = {"weapon_crossbow","weapon_shotgun","weapon_rpg","weapon_ar2","weapon_annabelle"}
		if (table.HasValue(disabled,class)) then
			ply:SendLua("GAMEMODE:AddNotify(\"This weapon is not allowed for you rank!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return false;
		end
	end
end

hook.Add("PlayerSpawnSWEP","LM.PlayerSpawnSWEP",PlayerSpawnSWEP)
hook.Add("PlayerGiveSWEP","LM.PlayerGiveSWEP",PlayerSpawnSWEP)
hook.Add("PlayerCanPickupWeapon","LM.PlayerCanPickupWeapon",PlayerSpawnSWEP);

hook.Add("PlayerSpawnNPC","LM.PlayerSpawnNPC",function(ply,class)
	if (IsValid(ply) and ply:IsUserGroup("user")) then
		ply:SendLua("GAMEMODE:AddNotify(\"You can't spawn npc with current rank!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return false;
	end
end)

hook.Add("PlayerSpawnProp","LM.PlayerSpawnProp",function(ply,model)
	if (ply:IsUserGroup("user")) then
	    if (ply:GetCount("props")>=30) then
			ply:SendLua("GAMEMODE:AddNotify(\"You can't spawn more 30 props with current rank!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return false;
	    end
	    if (model=="models/props_c17/oildrum001_explosive.mdl") then
			ply:SendLua("GAMEMODE:AddNotify(\"You can't spawn this prop with current rank!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return false;
	    end
	end
end)

hook.Add("PlayerSpawnVehicle","LM.PlayerSpawnVehicle",function(ply,class)
	--if (not ply:IsUserGroup("user")) then
	--	return false;
	--end
end)

hook.Add("CanTool","LM.CanTool",function(ply,tr,class)
	if (ply:IsUserGroup("user")) then
		local disabled = {"resizer","ragdollresizer","modelmanipulator","nocollideworld","dynamite","wire_explosive","wire_simple_explosive","wire_field_device","wire_turret","pewpew"}
		if (table.HasValue(disabled,class)) then
			ply:SendLua("GAMEMODE:AddNotify(\"This tool is not allowed for you rank!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return false;
		end
	elseif (ply:IsUserGroup("player")) then
		local disabled = {"modelmanipulator","wire_field_device"}
		if (table.HasValue(disabled,class)) then
			ply:SendLua("GAMEMODE:AddNotify(\"This tool is not allowed for you rank!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return false;
		end
	end
	/*
	if (not ply:IsAdmin() and IsValid(tr.Entity) and (tr.Entity.IsSGVehicle or tr.Entity:GetClass()=="puddle_jumper" or tr.Entity:GetClass()=="sg_vehicle_daedalus")) then
		local disabled = {"nocollideworld","precision"}
		if (table.HasValue(disabled,class)) then
			ply:SendLua("GAMEMODE:AddNotify(\"This tool is not allowed for this entity!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return false;
		end
	end*/
end)
/*
hook.Add("CanDrive","LM.CanDrive",function(ply,ent)
	if (ply:IsUserGroup("user")) then
		ply:SendLua("GAMEMODE:AddNotify(\"Driving is not allowed for you rank!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return false;
	end
end)
*/
local PlayerSpawn = function(ply)
	if (not IsValid(ply)) then return end
	if (ply:IsUserGroup("user")) then
		timer.Remove("LM.PlayerSpawn"..ply:EntIndex())
		timer.Create("LM.PlayerSpawn"..ply:EntIndex(),0.1,1,function()
			if (IsValid(ply)) then
				ply:GiveAmmo( 36,	"Pistol", 		true )
			end
		end)
		ply:Give( "weapon_crowbar" )
		ply:Give( "weapon_pistol" )
		ply:Give( "weapon_physcannon" )
	elseif (ply:IsUserGroup("player")) then
		timer.Remove("LM.PlayerSpawn"..ply:EntIndex())
		timer.Create("LM.PlayerSpawn"..ply:EntIndex(),0.1,1,function()
			if (IsValid(ply)) then
				ply:GiveAmmo( 72,	"Pistol", 		true )
				ply:GiveAmmo( 2,	"grenade", 		true )
				ply:GiveAmmo( 12,	"357", 			true )
				ply:GiveAmmo( 256,	"SMG1", 		true )
			end
		end)

		ply:Give( "weapon_crowbar" )
		ply:Give( "weapon_pistol" )
		ply:Give( "weapon_smg1" )
		ply:Give( "weapon_357" )
		ply:Give( "weapon_frag" )
		ply:Give( "weapon_physcannon" )
	else
		timer.Remove("LM.PlayerSpawn"..ply:EntIndex())
		timer.Create("LM.PlayerSpawn"..ply:EntIndex(),0.1,1,function()
			if (IsValid(ply)) then
				ply:GiveAmmo( 256,	"Pistol", 		true )
				ply:GiveAmmo( 256,	"SMG1", 		true )
				ply:GiveAmmo( 5,	"grenade", 		true )
				ply:GiveAmmo( 64,	"Buckshot", 	true )
				ply:GiveAmmo( 32,	"357", 			true )
				ply:GiveAmmo( 32,	"XBowBolt", 	true )
				ply:GiveAmmo( 6,	"AR2AltFire", 	true )
				ply:GiveAmmo( 100,	"AR2", 			true )
				ply:GiveAmmo( 5,	"RPG_Round", 	true )
			end
		end)

		ply:Give( "weapon_crowbar" )
		ply:Give( "weapon_pistol" )
		ply:Give( "weapon_smg1" )
		ply:Give( "weapon_frag" )
		ply:Give( "weapon_physcannon" )
		ply:Give( "weapon_crossbow" )
		ply:Give( "weapon_shotgun" )
		ply:Give( "weapon_357" )
		ply:Give( "weapon_rpg" )
		ply:Give( "weapon_ar2" )
	end
end

hook.Add("PlayerInitialSpawn","LM.PlayerInit",function(ply)
	timer.Simple(0.5,function()
		if (IsValid(ply)) then
			ply:StripWeapons()
			PlayerSpawn(ply)
			ply:Give( "gmod_tool" )
			ply:Give( "gmod_camera" )
			ply:Give( "weapon_physgun" )

			ply:SwitchToDefaultWeapon()
		end
	end);
end)
hook.Add("PlayerSpawn","LM.PlayerSpawn",PlayerSpawn)

timer.Create("LM.ProtectionThink",3.0,0,function()
	for k,v in pairs(player.GetHumans()) do
		if (not v:Alive() or v:IsAdmin()) then continue end
		if (not v:IsInWorld()) then
			v:Kill();
		end
	end
end)