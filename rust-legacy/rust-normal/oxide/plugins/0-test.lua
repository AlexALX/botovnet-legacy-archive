/*

This plugin changes default stack sizes for normal (not easy) server

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

PLUGIN.Title = "Test Botov-NET"
PLUGIN.Version = V(0, 0, 1)
PLUGIN.Description = "AlexALX"
PLUGIN.Author = "AlexALX"
PLUGIN.HasConfig = false


function PLUGIN:Init()
	self:SetStackSizes();
end

function PLUGIN:OnServerInitialized()
	self:SetStackSizes();
end

--[[
function PLUGIN:OnPlayerAttack(attacker, hitinfo)
	--print(hitinfo.HitEntity.resourceDispenser.fractionRemaining)
	--hitinfo.HitEntity.health = 0
	--hitinfo.damageTypes = new(Rust.DamageTypeList._type, nil)
	--return true
end]]

function PLUGIN:SetStackSizes()
 	local tbl = { 		["bone_fragments"] = 3000,
 		["charcoal"] = 1500,
 		["cloth"] = 3000,
 		["fat_animal"] = 3000,
 		["gunpowder"] = 3000,
 		["lowgradefuel"] = 3000,
 		["metal_fragments"] = 3000,
		["metal_refined"] = 3000,
		["paper"] = 3000,
		["stones"] = 3000,
		["sulfur"] = 3000,
		["sulfur_ore"] = 3000,
		["metal_ore"] = 3000,
		["wood"] = 3000, 	}

	for k,v in pairs(tbl) do
 		local item = global.ItemManager.CreateByName(k,1);
 		item.info.stackable = v;
 	end
end