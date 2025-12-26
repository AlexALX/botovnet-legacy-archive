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

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.Author = "AlexALX"
ENT.Spawnable = false
ENT.AdminSpawnable = false

--ENT.RenderGroup = RENDERGROUP_BOTH;

ENT.Untouchable = true
ENT.CAP_NotSave = true
ENT.NotTeleportable = true
ENT.SpawnProtect = true

AddCSLuaFile();

if (pewpew and pewpew.NeverEverList and not table.HasValue(pewpew.NeverEverList,"spawn_protection")) then table.insert(pewpew.NeverEverList,"spawn_protection"); end -- pewpew support

if SERVER then

ENT.Allowed = {	"prop_door_rotating",
	"logic_case",
	"info_player_start",
	"physgun_beam",
	"gmod_ghost",
	"phys_magnet",
}

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON);
	self:SetMoveType(MOVETYPE_NONE);
	self.CAP_NoBlackHole = true;

	local phys = self:GetPhysicsObject();
	if (IsValid(phys)) then
		phys:EnableMotion(false)
	end

	--self:SetColor(Color(255,255,255,0));
	--self:SetRenderMode(1);
	--self:SetNoDraw(true);
	self:DrawShadow(false);
	--self:SetMaterial("models/effects/vol_light001");
	--self:SetRenderMode(RENDERMODE_NONE);

	self.Effect = CurTime();
end

function ENT:ShowEffect()
	if (CurTime()<=self.Effect) then return end
	local fx = EffectData();
	fx:SetOrigin(self:GetPos());
	fx:SetScale(10); -- A type of refect ammount. As bigger the Entity is, as less energy-zaps
	fx:SetEntity(self);
	util.Effect("zat_impact",fx,true);
	self.Effect = CurTime()+1;
end

function ENT:OnTakeDamage()
	self:ShowEffect();
end
/*
function ENT:StartTouch(ent)
	if (ent:IsPlayer()) then
		ent.__HasGodMD = ent:HasGodMode();
		ent:GodEnable();
	end
end
*/
function ENT:Touch(ent)
	if (ent.__GBSP or ent.SpawnProtect or ent:IsPlayer() or ent:CreatedByMap() or ent:IsWorld() or ent.GateSpawnerSpawned or (not IsValid(ent:GetPhysicsObject()) or ent:GetClass()=="gmod_cameraprop"/* or ent:GetMoveType()==MOVETYPE_NONE*/) and not ent:IsNPC() or table.HasValue(self.Allowed,ent:GetClass()) ) then return end
	ent.__GBSP = true;
	self:DissolveEntities(ent);
	self:ShowEffect();
end
/*
function ENT:EndTouch(ent)
	if (ent:IsPlayer()) then
		if (not ent.__HasGodMD) then
			ent:GodDisable();
		end
	end
end
*/
--################# Dissolving entities @TetaBonita & aVoN
function ENT:DissolveEntities(ent)
	local name = "SP_DISSOLVE_"..self:EntIndex();
	local phys = ent:GetPhysicsObject();
	if (IsValid(phys)) then
		phys:EnableMotion();
		/*phys:SetVelocity(phys:GetVelocity()*0.04);
		phys:EnableGravity(false);*/
	elseif (not ent:IsNPC()) then
		return false;
	end

	local npcs = {"npc_hunter","npc_manhack","npc_combinedropship","npc_strider","npc_turret_floor","npc_helicopter","npc_rollermine","npc_zombie"};

	if (ent:IsNPC() and not table.HasValue(npcs,ent:GetClass())) then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage( 100 )
		dmginfo:SetDamageType( bit.bor(DMG_DISSOLVE, DMG_BLAST) )
		dmginfo:SetAttacker( self )
		dmginfo:SetInflictor( self )
		ent:TakeDamageInfo(dmginfo);
		timer.Simple(2.0,function()
			if (IsValid(ent)) then
				ent:Remove();
			end
		end)
		return false;
	end

	ent:SetKeyValue("targetname",name);
	-- Start the real cool dissolving effect
	local e = ents.Create("env_entity_dissolver");
	e:SetKeyValue("dissolvetype",3);
	e:SetKeyValue("magnitude",0);
	e:SetPos(ent:GetPos());
	e:SetKeyValue("target",name);
	e:Spawn();
	e:Fire("Dissolve",name,0);
	e:Fire("kill","",0.1);
	-- just to be sure
	timer.Simple(2.0,function()
		if (IsValid(ent)) then
			ent:Remove();
		end
	end)
end

function ENT:Think()
	local min,max = self:GetModelBounds();
	for k,v in pairs(ents.FindInBox(self:LocalToWorld(min),self:LocalToWorld(max))) do
		self:Touch(v);
	end
	self.Entity:NextThink(CurTime()+2.0)
	return true;
end

function ENT:PostEntityPaste()
	self:Remove();
	return
end

end

if CLIENT then
	language.Add("spawn_protection","Spawn Protection")
end