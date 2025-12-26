/*

This is special admin device made for Stargate Carter Addon Pack 
It absorbs ALL energy from ALL CAP devices and turn OFF everything like stargate rings in specified radius (check wire inputs)

Mostly made just for fun

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
if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Energy absorber"
ENT.WireDebugName = "Energy absorber"
ENT.Author = "AlexALX"
ENT.Instructions= ""

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

ENT.Spawnable = false;
ENT.AdminOnly = true;

ENT.NoDissolve = true
ENT.CAP_NotSave = true
ENT.NotTeleportable = true
ENT.IgnoreTouch = true
ENT.CAP_EH_NoTouch = true

ENT.Sounds = {
	Loop = Sound("tech/background_loop.wav"),
}

if SERVER then

AddCSLuaFile()

function ENT:Initialize()

	self.Entity:SetModel("models/Madman07/anti_priest/anti_priest.mdl");

	self.Entity:SetName("Energy absorber");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE);

	self.IsOn = false;
	self.Radius = 800;
	self:SetNWBool("IsOn",self.IsOn);
	self:SetNWInt("Radius",self.Radius);
	if WireAddon then
		self:CreateWireInputs("Activate","Disable Use","Immunity Mode","Radius");
		self:CreateWireOutputs("Activated");
	end

	self.Immunity = -1;

	if (pewpew and pewpew.NeverEverList and not table.HasValue(pewpew.NeverEverList,self.Entity:GetClass())) then table.insert(pewpew.NeverEverList,self.Entity:GetClass()); end -- pewpew support

	hook.Add("PlayerUse","EnergyAbsorber.Use",function(ply,ent)
		if (!IsValid( ent ) or ent:GetClass()=="energy_absorber" or ent:GetClass()=="naquadah_bomb") then return end

		for k,v in pairs(ents.FindByClass("energy_absorber")) do
			if (v.IsOn and v:GetPos():Distance(ent:GetPos())<v.Radius) then
				return false;
			end
		end
	end)

	local ENT = scripted_ents.Get( "gate_nuke" )
	ENT.__Setup = ENT.__Setup or ENT.Setup
	function ENT:Setup( pos, scale )
		for k,v in pairs(ents.FindByClass("energy_absorber")) do
			if (v.IsOn and v:GetPos():Distance(pos)<v.Radius) then
				scale = 0.5; break;
			end
		end
		ENT.__Setup( self, pos, scale )
	end
	scripted_ents.Register( ENT, "gate_nuke" )


	hook.Add("PlayerNoClip","EnergyAbsorber.Noclip",function(ply)
		if (!IsValid( ply )) then return end

		for k,v in pairs(ents.FindByClass("energy_absorber")) do
			if (v.IsOn and v:GetPos():Distance(ply:GetPos())<v.Radius) then
				return false;
			end
		end
	end)

	hook.Add("OnEntityCreated","EnergyAbsorber.Ent",function(ent)
		if (!IsValid( ent ) or ent:GetClass()!="energy_pulse") then return end
		timer.Simple(0,function()
		if (!IsValid(ent)) then return end
		for k,v in pairs(ents.FindByClass("energy_absorber")) do
			if (v.IsOn and v:GetPos():Distance(ent:GetPos())<v.Radius) then
				ent:Remove(); return false;
			end
		end
		end)
	end)

	hook.Add("StarGate.BlackHole.RemoveEnt","EnergyAbsorber.BH",function(ent)
		if (!IsValid( ent ) or ent:GetClass()=="energy_absorber") then return false end
	end)

	hook.Add("StarGate.GateNuke.DamageEnt","EnergyAbsorber.GN",function(ent)
		if (!IsValid( ent ) or ent:GetClass()=="energy_absorber") then return false end
	end)

	hook.Add("StarGate.SatBlast.DamageEnt","EnergyAbsorber.SB",function(ent)
		if (!IsValid( ent ) or ent:GetClass()=="energy_absorber") then return false end
	end)

	hook.Add("CanProperty","EnergyAbsorber.CanProperty",function(ply,tool,ent)
		if (!IsValid( ent ) or ent:GetClass()=="energy_absorber") then return end

		for k,v in pairs(ents.FindByClass("energy_absorber")) do
			if (v.IsOn and v:GetPos():Distance(ent:GetPos())<v.Radius) then
				return false;
			end
		end
	end)

	hook.Add("CanDrive","EnergyAbsorber.CanDrive",function(ply,ent)
		if (!IsValid( ent ) or ent:GetClass()=="energy_absorber") then return end

		for k,v in pairs(ents.FindByClass("energy_absorber")) do
			if (v.IsOn and v:GetPos():Distance(ent:GetPos())<v.Radius) then
				return false;
			end
		end
	end)

	hook.Add("PlayerInitialSpawn","EnergyAbsorber.PlySpawn",function(ply)
		umsg.Start("EB.Effect",ply);
		umsg.End();
	end)

	umsg.Start("EB.Effect");
	umsg.End();

end

function ENT:SpawnFunction( ply, tr )
	if (!tr.Hit) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("energy_absorber");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then phys:EnableMotion(false); end

	return ent;
end

function ENT:Use()
	if (self:GetWire("Disable Use")==1) then return end
	if self.IsOn==false then
		self.IsOn=true;
		self:SetWire("Activated",1);
	else
		self.IsOn=false;
		self:SetWire("Activated",0);
	end
	self:SetNWBool("IsOn",self.IsOn);
end

function ENT:TriggerInput(variable, value)
	if (variable == "Activate") then
		self.IsOn = util.tobool(value)
		if (self.IsOn) then
			self:SetWire("Activated",1);
		else
			self:SetWire("Activated",0);
		end
		self:SetNWBool("IsOn",self.IsOn);
	elseif(variable=="Immunity Mode") then
		self.Immunity = math.Clamp(value,-1,1);
		self:SetNWInt("Immunity",self.Immunity);
	elseif(variable=="Radius") then
		self.Radius = value;
		self:SetNWInt("Radius",self.Radius);
	end
end

function ENT:EffectInit()
	if (self.Effect and CurTime()<self.Effect) then return end
	self.Effect = CurTime()+5.5;
    local effect = EffectData()
	effect:SetOrigin(self.Entity:GetPos())
	effect:SetScale(self.Radius)
	effect:SetEntity(self)
	util.Effect("energy_absorber", effect, true, true)
end

function ENT:Think()
	if self.IsOn==true then
		local e = ents.FindInSphere(self:GetPos(), self.Radius);
			for _,v in pairs(e) do
				if (self.Immunity<0 or v.CPPIGetOwner and v:CPPIGetOwner() != self.Owner) then
					if v:IsPlayer() and v:GetMoveType() == MOVETYPE_NOCLIP then
						v:SetMoveType(MOVETYPE_WALK)
					end
					if (v:IsPlayer()) then
						local dist = self:GetPos():Distance(v:GetPos());
						local mul = self.Radius/dist-4;
						if (mul>0) then
							--local mul = v:Health()/200*mul;
							if (v:Health()>100) then mul = v:Health()/300*mul; else mul = 0.03*mul; end
							v:TakeDamage(mul);
						end
					end
					local energy = RD.GetResourceAmount(v,"energy") or 0;
					if (energy>0) then
						RD.ConsumeResource(v,"energy",RD.GetUnitCapacity(v,"energy"));
					end
					if (v.IsZPM and v.Energy>0) then
						v.Energy = v.Energy*0.65;
						if (v.Energy<1000000) then
							v.Energy = 0;
						end
						if (v:GetClass()=="tampered_zpm") then
							v.Detonate = function() end
						end
					elseif (v:GetClass()=="naquadah_bottle" and v.Naquadah>0) then
						v.Naquadah = 0;
						v.Boom = function() end
					elseif (v:GetClass()=="naquadah_generator" and v.Energy>0) then
						v.Energy = 0;
						v.Boom = function() end
					elseif (v:GetClass()=="naq_gen_mk2" and v.Naquadah>0) then
						v.Naquadah = 0;
						v.Bang = function() end
					--elseif (v:GetClass()=="naquadah_bomb" and v.yield>1) then
					--	v.yield = 0.5;
					elseif (v:GetClass()=="kino_ball" and not v.Ignore) then
						v:PrepareRemove();
						v.Ignore = true;
					elseif (v:GetClass()=="wraith_harvester" or v:GetClass()=="dart_harvester") then
						v:TurnOn(false);
					elseif(v:GetClass()=="personal_shield") then
						if (IsValid(v:GetOwner())) then
							v:GetOwner():SetNWFloat("PShieldStrength", 0)
						end
					elseif (v.IsStargate) then
						/*if (v.__FindPowerDHD==nil) then
							v.__FindPowerDHD = v.FindPowerDHD;
							v.FindPowerDHD = function(sg)
								if IsValid(self) and self.IsOn then
									return {}
								elseif (not IsValid(self) or not self.IsOn) then
									sg.FindPowerDHD = sg.__FindPowerDHD; sg.__FindPowerDHD = nil;
									return sg:FindPowerDHD()
								else
									return sg:__FindPowerDHD()
								end
							end
						end*/
						if (v.IsOpen) then
							v:Flicker(1);
							v:AbortDialling();
						end
					/*elseif (v.IsDHD and v.__FindGate==nil) then
						v.__FindGate = v.FindGate;
						v.FindGate = function(sg)
							if IsValid(self) and self.IsOn then
								return NULL;
							elseif (not IsValid(self) or not self.IsOn) then
								sg.FindGate = sg.__FindGate; sg.__FindGate = nil;
								return sg:FindGate();
							else
								return sg:__FindGate()
							end
						end*/
					elseif (v.IsRings and v.__Busy==nil) then
						v.__Busy = v.Busy;
						local busy = v.Busy;
						v.Busy = true;
						local id = v:EntIndex()
						local ent = v;
						timer.Create("EB_RINGS"..id,1.0,0,function()
							if (IsValid(ent) and (not IsValid(self) or not self.IsOn or ent:GetPos():Distance(self:GetPos())>self.Radius)) then
								v.Busy = busy;
								v.__Busy = nil;
								timer.Remove("EB_RINGS"..id);
							elseif (not IsValid(ent)) then
								timer.Remove("EB_RINGS"..id);
							end
						end);
					elseif(v:IsPlayer() and v:InVehicle()) then
						v:ExitVehicle();
					elseif(v.IsEnabled) then
						v.IsEnabled = false;
					elseif(v:GetClass()=="black_hole_power") then
						v.blackHoleMass = v.blackHoleMass*0.97;
						if (v.blackHoleMass<500) then
							v.blackHoleMass = 0;
						end
						if (v.blackHoleMass<=0) then v:Remove(); end
					elseif(v:GetClass()=="gmod_light") then
						v:SetOn( false )
					elseif(v:GetClass()=="gmod_wire_light") then
						v.R, v.G, v.B = 0,0,0
						--v.brightness = 0
						--v:SetBrightness( 0 )
						v:UpdateLight()
					elseif(v:GetClass()=="gmod_lamp" or v:GetClass()=="gmod_wire_lamp") then
						v:Switch( false )
					elseif(v.__TriggerInput==nil and v!=self) then
						v.__TriggerInput = v.TriggerInput;
						v.TriggerInput = function(ent,key,value)
							if (IsValid(self) and self.IsOn and v:GetPos():Distance(self:GetPos())<self.Radius) then
								return false;
							elseif (not IsValid(self) or not self.IsOn or v:GetPos():Distance(self:GetPos())>self.Radius) then
								v.TriggerInput = v.__TriggerInput; v.__TriggerInput = nil;
								return v:TriggerInput(key,value);
							end
							return false;
						end
					elseif(v:GetClass()=="energy_pulse" or v:GetClass()=="pewpew_base_bullet") then
						v:Remove();
					elseif(v:GetClass()=="drone" or v:GetClass()=="mini_drone") then
						v.Fuel = 0;
					elseif(v:GetClass()=="puddle_jumper" and IsValid(v.Pilot)) then
						v:ExitJumper(v.Pilot)
					elseif(v.IsSGVehicle and IsValid(v.Pilot)) then
						v:Exit()
					elseif(v:GetClass()=="gyropod_advanced" and v.SystemOn) then
						v.SystemOn = false
					elseif(v:GetClass()=="malp" and v.Control) then
						if(v.Control) then
							if(v.FirstPerson) then
								v:StopSpectate(v.Controler)
							end
							v:UnControl(v.Controler)
						end
					elseif(v:GetClass()=="telchak" and v.Active) then
						if v.LoopSound then
							v.LoopSound:FadeOut(2);
						end

						v.Entity:SetNWBool("healing", false);
						v.Active = false;
						if IsValid(v.Light) then
							v.Light:Fire("TurnOn","","0");
							v.Light:Remove();
							v.Light = nil;
						end
						v.Entity:SetMaterial("");
					/*elseif(v.__Gravity==nil and v:GetClass()=="prop_physics") then
						local phys = v:GetPhysicsObject();
						if (IsValid(phys)) then
							v.__Gravity = phys:IsGravityEnabled();
							phys:EnableGravity(false);
							local id = v:EntIndex()
							local ent = v;
							timer.Create("EB_GRAV"..id,1.0,0,function()
								if (IsValid(self) and IsValid(ent) and self.IsOn and ent:GetPos():Distance(self:GetPos())<self.Radius) then
									return false;
								elseif (IsValid(ent) and (not IsValid(self) or not self.IsOn or ent:GetPos():Distance(self:GetPos())>self.Radius)) then
									phys:EnableGravity(ent.__Gravity);
									ent.__Gravity = nil;
									timer.Remove("EB_GRAV"..id);
								elseif (not IsValid(ent)) then
									timer.Remove("EB_GRAV"..id);
								end
							end);
						end
					/*elseif (v.eb__Use==nil and v!=self) then
						v.eb__Use = v.Use;
						v.Use = function(sg)
							/*if IsValid(self) and self.IsOn then
								return false;
							elseif (not IsValid(self) or not self.IsOn) then
								sg.Use = sg.eb__Use; sg.eb__Use = nil;
							else
								return sg:eb__Use(...)
							end
							return false;
						end*/
					end
				end
			end
	end

	if self.IsOn==true then
		self.Entity:Fire("skin",1);
		self:EffectInit();
		if (not self.LoopSound) then
			self.LoopSound = CreateSound(self.Entity, self.Sounds.Loop);
			if self.LoopSound then
				self.LoopSound:PlayEx(1,70);
				self.LoopSound:SetSoundLevel(140);
			end
		end
	else
		self.Entity:Fire("skin",0);
		if (self.LoopSound) then
			self.LoopSound:Stop();
			self.LoopSound = nil;
		end
	end

	self.Entity:NextThink(CurTime() + 0.05)
	return true
end

function ENT:OnRemove()
	StarGate.WireRD.OnRemove(self);
	if self.LoopSound then
		self.LoopSound:Stop();
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	self.Entity:Remove(); return
end

end

if CLIENT then

--usermessage.Hook("EB.Effect", function()
	hook.Add( "RenderScreenspaceEffects", "EB.Effect", function()

		local min_mul = 0;
		local max_mul = 0;
		local last_max = 0;
		for k,v in pairs(ents.FindByClass("energy_absorber")) do
			if (v:GetNWBool("IsOn",false)) then
				if (v:GetPos():Distance(EyePos())<v:GetNWInt("Radius")) then
					local dis = v:GetPos():Distance(EyePos());
					local mul = v:GetNWInt("Radius",0)/dis-3;
					--if (mul>min_mul) then min_mul = mul end
					if (mul>0) then min_mul = mul+min_mul; end
				end
				if (v:GetPos():Distance(EyePos())<v:GetNWInt("Radius")*1.1) then
					local dis = v:GetPos():Distance(EyePos());
					local mul = dis/v:GetNWInt("Radius",0);
					if (mul>1) then mul = 1-(((mul-1)*2)*5);
					elseif (mul>0.9 and mul<=1) then mul = 1-(((1-mul)*2)*5);-- if (mul<0.1) then mul = 0.1 end
					--elseif (mul<=0.9) then mul = 0.1;
					else mul = 0; end
					--if (mul<last_max) then last_max = mul; end
					--if (mul<max_mul) then max_mul = mul; end
					if (mul>0) then max_mul = mul+max_mul; end
					--if (dis<v:GetNWInt("Radius")*0.9) then max_mul = 0 end
				end
			end
		end

		local mul = min_mul; --radius/dist-3;
		--if (mul<0) then mul = 0 end

		local ret = false;

		if (mul>0) then
			DrawSharpen(5*mul,5.2*mul)
			DrawMaterialOverlay("effects/strider_pinch_dudv",0.005*mul)
			ret = true
		end

		local mul = max_mul;

		if (mul>0) then
			--DrawMaterialOverlayAlpha("models/props_lab/tank_glass001",-0.1,mul)
			if (mul<last_max) then mul = last_max end
			DrawSharpen(1,10*mul)
			ret = true
		end

	end)

--end)

end