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

local matRefraction	= Material("refract_ring")
matRefraction:SetInt("$noclull", 1)

function EFFECT:Init(data)
	self.StartPos 	= data:GetOrigin()
	self.Scale	= data:GetScale()
	self.Init 	= CurTime()
	self.Aim	= {Angle(90, 0, 0), data:GetAngles()}
	self.Time 	= self.Init
	self.Relative	= 0
	self.Vis	= util.GetPixelVisibleHandle()
	self.Emitter = ParticleEmitter(self.StartPos)
	self.Parent = data:GetEntity();

	self.Entity:SetModel(Model("models/zup/shields/1024_shield.mdl"))
	self.Entity:SetPos(self.StartPos)
	self.Entity:SetRenderBounds(-1*Vector(1,1,1)*100000,Vector(1,1,1)*100000)
	self.Size = 0;
end

function EFFECT:Think()
	if (not IsValid(self.Parent)) then return false end
	self.Time = CurTime()
	self.Relative = self.Time-self.Init
	self.StartPos = self.Parent:GetPos()+Vector(0,0,10);
	/*
	if (self.Relative<4) then
		self.Size = self.Size + 3;	
	elseif (self.Relative<5) then
		self.Size = self.Size + 1.5;	
	elseif (self.Relative<6) then
		self.Size = self.Size + 0;	
	elseif (self.Relative<8) then
		self.Size = self.Size - 1.5;	
	else
		self.Size = self.Size - 3;	
	end
	*/
	local mul = self.Relative/5.5;
	if (mul>1) then mul = mul-(mul-1)*2; end
	if (mul<0) then mul = 0; end
	
	if (mul>0.95) then 
		mul = 0.95;
	end
	
	self.Size = mul*2;
	
	if self.Relative > 12 or self.Size<0 then return false end
	return true
end

function EFFECT:Render()
	local eye = EyePos()
	local Distance = eye:Distance(self.StartPos)
	local Pos = self.StartPos+(eye-self.StartPos):GetNormal()--*math.sin(self.Relative/10)*1.1*Distance
	matRefraction:SetFloat( "$refractamount", math.sin(self.Relative/2)*0.2)
	render.SetMaterial(matRefraction)
	render.UpdateRefractTexture()
	render.DrawSprite(Pos, self.Size*self.Scale, self.Size*self.Scale)
end
