/*

This plugin is custom mape spawn protection ZONE for users on my server

Had nice hit effects from Stargate Carter Addon Pack
Will not work without it probably

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
local GlobalSpawnProtect = {}
local GlobalCustomSpawnProtect = {}

local map_models = {
	["gm_flatgrass"] = {"models/hunter/blocks/cube4x4x4.mdl",Vector(0,0,40)},
	["sb_gooniverse"] = {"models/hunter/blocks/cube8x8x8.mdl",Vector(0,0,0)},
	["gm_wireconstruct_bna"] = {"models/hunter/blocks/cube4x4x4.mdl",Vector(0,0,40)},
	["gm_galactic_rc1"] = {"models/hunter/blocks/cube1x2x1.mdl",Vector(0,0,45),Angle(0,0,90)},
	["gm_excess_construct_13"] = {"models/hunter/blocks/cube4x4x4.mdl",Vector(0,0,40)},
	["gm_mobenix_v3_final"] = {"models/hunter/blocks/cube4x4x4.mdl",Vector(0,0,40)},
	--["gm_rockside_rails_beta"] = {"models/hunter/blocks/cube1x2x1.mdl",Vector(0,0,45),Angle(0,0,90)},
	["gm_sgc_to_atlantis"] = {"models/hunter/blocks/cube1x2x1.mdl",Vector(0,0,45),Angle(0,0,90)},
	["gm_botmap_v3"] = {"models/hunter/blocks/cube1x2x1.mdl",Vector(0,0,45),Angle(0,0,90)},
}
local def_model = "models/hunter/blocks/cube6x6x6.mdl";
local map = string.lower(game.GetMap());

-- Custom map spawns

local disable_points = {
	["rp_stargate_v5"] = true,
	["gm_stargateworlds_parody_beta3"] = true,
	["sg1_the_fifth_race"] = true,
	["rp_stargateworldsv3"] = true,
	["rp_stargateworldsv4_b2"] = true,
}

local custom_points = {
	["rp_stargate_v5"] = {
		{"models/hunter/blocks/cube4x6x4.mdl",Vector(236,-285,-13850),Angle(0,90,0)},
		{"models/hunter/blocks/cube4x6x4.mdl",Vector(-237,-285,-13850),Angle(0,90,0)},
		{"models/hunter/blocks/cube4x4x4.mdl",Vector(0,-285,-13779),Angle(90,-90,180)},
		{"models/hunter/blocks/cube4x6x4.mdl",Vector(279,-47,-13850),Angle(0,-180,0)},
		{"models/hunter/blocks/cube4x6x4.mdl",Vector(-280,-47,-13850),Angle(0,0,0)},
		{"models/hunter/blocks/cube4x4x4.mdl",Vector(-279,190,-13779),Angle(0,0,0)},
		{"models/hunter/blocks/cube4x4x4.mdl",Vector(279,190,-13779),Angle(0,-90,0)},
	},
	["gm_stargateworlds_parody_beta3"] = {
		{"models/hunter/blocks/cube8x8x4.mdl",Vector(-7008,7803,-13314),Angle(0,-180,0)},
		{"models/hunter/blocks/cube8x8x4.mdl",Vector(-7008,7423,-13314),Angle(0,-180,0)},
		{"models/hunter/blocks/cube8x8x4.mdl",Vector(-7008,7042,-13314),Angle(0,-180,0)},
		{"models/hunter/blocks/cube8x8x4.mdl",Vector(-7388,7803,-13314),Angle(0,-180,0)},
		{"models/hunter/blocks/cube8x8x4.mdl",Vector(-7388,7423,-13314),Angle(0,-180,0)},
		{"models/hunter/blocks/cube8x8x4.mdl",Vector(-7388,7043,-13314),Angle(0,-180,0)},
	},
	["sg1_the_fifth_race"] = {
		{"models/hunter/blocks/cube8x8x8.mdl",Vector(-7702,10510,-14176),Angle(0,-180,0)},
		{"models/hunter/blocks/cube8x8x8.mdl",Vector(-7692,12014,-14176),Angle(0,-91,0)},
	},
	["rp_stargateworldsv3"] = {
		{"models/hunter/blocks/cube4x4x4.mdl",Vector(632,-8576,4182),Angle(0,0,0)},
		{"models/hunter/blocks/cube4x4x4.mdl",Vector(632,-8292,4182),Angle(0,0,0)},
		{"models/hunter/blocks/cube4x4x2.mdl",Vector(632,-8434,4182),Angle(90,90,180)},
		{"models/hunter/blocks/cube4x4x2.mdl",Vector(792,-8434,4182),Angle(90,-90,180)},
		{"models/hunter/blocks/cube4x4x4.mdl",Vector(792,-8576,4182),Angle(0,180,0)},
		{"models/hunter/blocks/cube4x4x4.mdl",Vector(792,-8292,4182),Angle(0,180,0)},
		{"models/hunter/blocks/cube4x6x2.mdl",Vector(1029,-8217,4182),Angle(90,90,180)},
		{"models/hunter/blocks/cube4x6x2.mdl",Vector(1029,-8658,4182),Angle(90,81,-9)},
	},
	["rp_stargateworldsv4_b2"] = {
		{"models/hunter/blocks/cube8x8x4.mdl",Vector(-223,330,78),Angle(0,0,0)},
	},
}

local function SpawnProtect(v,custom,key)
	if not IsValid(v) and custom==nil then return end
	local ent = ents.Create("spawn_protection");
	if (not IsValid(ent)) then return end
	if (custom!=nil) then
		ent:SetModel(custom[1]);
		ent:SetPos(custom[2]);
		if (custom[3]) then ent:SetAngles(custom[3]); end
		if (key) then GlobalCustomSpawnProtect[key] = ent; end
	else
		if (map_models[map]) then
			ent:SetModel(map_models[map][1]);
			ent:SetPos(v:GetPos()+map_models[map][2]);
			if (map_models[map][3]!=nil) then ent:SetAngles(v:GetAngles()+map_models[map][3]);
			else ent:SetAngles(v:GetAngles()); end
		else
			ent:SetModel(def_model);
			ent:SetPos(v:GetPos());
			ent:SetAngles(v:GetAngles());
		end
		GlobalSpawnProtect[v:EntIndex()] = ent;
	end
	ent:Spawn();
end

local function init()
	for k,v in pairs(ents.FindByClass("spawn_protection")) do
		v:Remove();
	end

	if (not disable_points[map]) then
		local ent_tbl = {ents.FindByClass("info_player_start"),ents.FindByClass("info_player_counterterrorist"),ents.FindByClass("info_player_terrorist")}
		for n,e in pairs(ent_tbl) do
			for k,v in pairs(e) do
				timer.Simple(0.01*k*n,function()
					if not IsValid(v) then return end
					SpawnProtect(v);
				end);
			end
		end
	end

	if (custom_points[map]) then
		for k,v in pairs(custom_points[map]) do
			timer.Simple(0.01*k,function()
				SpawnProtect(nil,v,k);
			end);
		end
	end

end

--hook.Add( "Initialize", "GlobalSpawnProtect", init);

init();

timer.Create("GlobalSpawnProtect.AutoRespawn",5,0,function()
	if (not disable_points[map]) then
		local ent_tbl = {ents.FindByClass("info_player_start"),ents.FindByClass("info_player_counterterrorist"),ents.FindByClass("info_player_terrorist")}

		for n,e in pairs(ent_tbl) do
			for k,v in pairs(e) do
				if (not IsValid(GlobalSpawnProtect[v:EntIndex()])) then
					SpawnProtect(v);
				end
			end
		end
	end

	if (custom_points[map]) then
		for k,v in pairs(custom_points[map]) do
			if (not IsValid(GlobalCustomSpawnProtect[k])) then
				SpawnProtect(nil,v,k);
			end
		end
	end
end);

concommand.Add("spawn_protection_create",function(ply)
	if (IsValid(ply) and not ply:IsAdmin()) then return end

	for k,v in pairs(ents.FindByClass("prop_physics")) do
		if (not v:CreatedByMap()) then
			local pos = v:GetPos()-Vector(0,0,10);
			local angle = v:GetAngles();
			print("		{\""..v:GetModel().."\",Vector("..math.Round(pos.x)..","..math.Round(pos.y)..","..math.Round(pos.z).."),Angle("..math.Round(angle.p)..","..math.Round(angle.y)..","..math.Round(angle.r)..")},");
		end
	end
end);

concommand.Add("spawn_protection_transform",function(ply)
	if (IsValid(ply) and not ply:IsAdmin()) then return end

	for k,v in pairs(ents.FindByClass("prop_physics")) do
		if (not v:CreatedByMap()) then
			SpawnProtect(nil,{v:GetModel(),v:GetPos(),v:GetAngles()});
			v:Remove();
		end
	end
end);

concommand.Add("spawn_protection_props",function(ply,cmd,args)
	if (IsValid(ply) and not ply:IsAdmin()) then return end

	for k,v in pairs(ents.FindByClass("spawn_protection")) do

		local ent = ents.Create("prop_physics");
		if (not IsValid(ent)) then return end
		ent:SetModel(v:GetModel());
		if (args[1]) then
			ent:SetPos(v:GetPos());
		else
			ent:SetPos(v:GetPos()+Vector(0,0,10));
		end
		ent:SetAngles(v:GetAngles());
		ent:Spawn();
		ent:PhysicsInit(SOLID_VPHYSICS);
		ent:SetMoveType(MOVETYPE_VPHYSICS);
		ent:SetSolid(SOLID_VPHYSICS);

		local phys = ent:GetPhysicsObject();
		phys:EnableMotion(false);

		v:Remove();
	end

	timer.Remove("GlobalSpawnProtect.AutoRespawn");
	timer.Remove("GlobalSpawnProtect.Draw");
end);

concommand.Add("spawn_protection_disable",function(ply)
	if (IsValid(ply) and not ply:IsAdmin()) then return end

	for k,v in pairs(ents.FindByClass("spawn_protection")) do
		v:Remove();
	end

	timer.Remove("GlobalSpawnProtect.AutoRespawn");
	timer.Remove("GlobalSpawnProtect.Draw");
end);

concommand.Add("spawn_protection_enable",function(ply)
	if (IsValid(ply) and not ply:IsAdmin()) then return end
	init();
	timer.Remove("GlobalSpawnProtect.Draw");
end);

concommand.Add("spawn_protection_draw",function(ply,cmd,args)
	if (IsValid(ply) and not ply:IsAdmin()) then return end

	local num = tonumber(args[1] or 1);
	if (num>=0) then

		for k,v in pairs(ents.FindByClass("spawn_protection")) do
			v:ShowEffect();
		end

		if (num>1) then
			timer.Create("GlobalSpawnProtect.Draw",1.2,num-1,function()
				for k,v in pairs(ents.FindByClass("spawn_protection")) do
					v:ShowEffect();
				end
			end);
		elseif(num==0) then
			timer.Create("GlobalSpawnProtect.Draw",1.2,0,function()
				for k,v in pairs(ents.FindByClass("spawn_protection")) do
					v:ShowEffect();
				end
			end);
		end
	else
		timer.Remove("GlobalSpawnProtect.Draw");
	end
end);

-- Protect

local function PlayerFunc(ent)
	if (not IsValid(ent)) then return end
	for k,v in pairs(ents.FindInSphere(ent:GetPos(),1)) do
		if (v:GetClass()=="spawn_protection") then
			return false;
		end
	end
end

local function EntFunc(ent)
	if (not IsValid(ent)) then return end
	if (ent:GetClass()=="spawn_protection") then return false end
	if (not ent:IsPlayer()) then return end
	for k,v in pairs(ents.FindInSphere(ent:GetPos(),1)) do
		if (v:GetClass()=="spawn_protection") then
			return false;
		end
	end
end

local function EntDamageFunc(ent)
	if (not IsValid(ent)) then return end
	if (ent:GetClass()=="spawn_protection") then
		if (math.random(1,50)==1) then
			ent:ShowEffect();
		end
		return false
	end
	for k,v in pairs(ents.FindInSphere(ent:GetPos(),1)) do
		if (v:GetClass()=="spawn_protection") then
			return false;
		end
	end
end

hook.Add("StarGate.HandDevice.Push","GlobalSpawnProtect.HandDevice",function(ent)
	return PlayerFunc(ent);
end)

hook.Add("StarGate.GateNuke.KillPlayer","GlobalSpawnProtect.GateNuke",function(ent)
	return EntFunc(ent);
end)

hook.Add("StarGate.BlackHole.DamageEnt","GlobalSpawnProtect.BlackHole",function(ent)
	return EntFunc(ent);
end)

hook.Add("StarGate.BlackHole.PushEnt","GlobalSpawnProtect.BlackHole.Push",function(ent)
	return EntFunc(ent);
end)

hook.Add("StarGate.GateNuke.DamageEnt","GlobalSpawnProtect.GateNukeDMG",function(ent)
	return EntDamageFunc(ent);
end)

hook.Add("StarGate.SatBlast.DamageEnt","GlobalSpawnProtect.SatBlastDMG",function(ent)
	return EntDamageFunc(ent);
end)

hook.Add("StarGate.Transporter.TeleportEnt","GlobalSpawnProtect.Transporter",function(ent)
	return EntFunc(ent);
end)

hook.Add("StarGate.WraithBomb.Stun","GlobalSpawnProtect.WraithBomb.Stun",function(ent)
	return PlayerFunc(ent);
end)

hook.Add("StarGate.Player.Stun","GlobalSpawnProtect.PlayerStun",function(ent)
	return PlayerFunc(ent);
end)

hook.Add("PlayerShouldTakeDamage","GlobalSpawnProtect.DMG",function(ent)
	return PlayerFunc(ent);
end)

hook.Add("StarGate.DarakaWave.Disintegrate","GlobalSpawnProtect.DakaraWave",function(ent)
	return EntFunc(ent);
end)

hook.Add("StarGate.Jumper.KillPlayer","GlobalSpawnProtect.Jumper.Kill",function(ent)
	return PlayerFunc(ent);
end)

hook.Add("StarGate.Tac.DamagePlayer","GlobalSpawnProtect.Tac.Kill",function(ent)
	return PlayerFunc(ent);
end)

hook.Add("StarGate.Tac.StunPlayer","GlobalSpawnProtect.Tac.Stun",function(ent)
	return PlayerFunc(ent);
end)

hook.Add("StarGate.Tac.KillOrDamage","GlobalSpawnProtect.Tac.Damage",function(ent)
	return EntFunc(ent);
end)

local player_hooks = {"PlayerSpawnEffect","PlayerSpawnNPC","PlayerSpawnObject","PlayerSpawnProp","PlayerSpawnRagdoll","PlayerSpawnSENT","PlayerSpawnSWEP","PlayerSpawnVehicle"}

for s,h in pairs(player_hooks) do
	hook.Add(h,"GlobalSpawnProtect."..h,function(ply)
		for k,v in pairs(ents.FindInSphere(ply:GetPos(),1)) do
			if (v:GetClass()=="spawn_protection") then
				ply:ChatPrint("Spawn Protection: you can't spawn here.");
				return false;
			end
		end
	end)
end