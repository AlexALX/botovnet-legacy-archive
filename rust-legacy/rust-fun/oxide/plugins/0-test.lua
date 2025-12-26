/*

This plugin changes default stack sizes for fun (easy) server
Also have feature to block unwanted players with emulate "steam connect errors" 
So target feels like have an connection issue (and not banned)
Used on Botov-NET rust servers

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
 	local tbl = { 		["bone_fragments"] = 10000,
 		["charcoal"] = 10000,
 		["cloth"] = 10000,
 		["fat_animal"] = 10000,
 		["gunpowder"] = 10000,
 		["lowgradefuel"] = 10000,
 		["metal_fragments"] = 25000,
		["metal_refined"] = 10000,
		["paper"] = 1000,
		["stones"] = 25000,
		["sulfur"] = 25000,
		["sulfur_ore"] = 25000,
		["metal_ore"] = 25000,
		["wood"] = 25000,
		["wolfmeat_raw"] = 500,
		["syringe_medical"] = 2,
		["bandage"] = 2,
		["largemedkit"] = 2,
		["ammo_rifle"] = 128,
		["ammo_rifle_explosive"] = 128,
		["ammo_rifle_incendiary"] = 128,
		["ammo_rifle_hv"] = 128,
		["ammo_pistol"] = 128,
		["ammo_pistol_fire"] = 128,
		["ammo_pistol_hv"] = 128, 	}
	
	for k,v in pairs(tbl) do
 		local item = global.ItemManager.CreateByName(k,1);
 		item.info.stackable = v;
 	end
end

local function rand_real(a, b)
    return a + (b - a) * math.random()
end
--[[
function PLUGIN:OnGather(dispenser, entity, item)
    if entity:ToPlayer() then
		--print(entity.svActiveItem.condition)
		--print(dispenser.fractionRemaining)
		
		--local test = function(ent) print(ent) end

		dispenser.containedItems:ForEach(test)
		
        if tonumber( item.amount ) then
			local orm = item.amount
			item.amount = item.amount*(rand_real(9.5,10.5))
			entity.svActiveItem.condition = entity.svActiveItem.condition-2
			
			for v=0,dispenser.containedItems.Count-1 do
				local it = dispenser.containedItems[v]
				if (it.itemid==item.info.itemid) then
					--print(it.amount)
					it.amount = it.amount-item.amount/2
					--if (it.amount<0) then
						item.amount = orm;
						--dispenser.health = 0;
						dispenser:GetComponent("BaseEntity"):KillMessage()
						return false
					end 
				end
			end

        end
    end
end
]]
function PLUGIN:OnItemCraft( ItemCraftTask )
    local item            = ItemCraftTask.blueprint.targetItem.displayName.translated
    local duration        = ItemCraftTask.blueprint.time
    local endTimeModifier = duration
    local player          = ItemCraftTask.owner

    --endTimeModifier = duration * 0.33

    --print(endTimeModifier)

    --if endTimeModifier == 0 then
        ItemCraftTask.blueprint.time = 0
    --end
    --print(ItemCraftTask.endTime)
	--print(UnityEngine.Time.get_time())
    --ItemCraftTask.endTime =  UnityEngine.Time.get_time() + endTimeModifier
end

					--[[for v=0,dispenser.containedItems.Count-1 do
						local it = dispenser.containedItems[v]
						if (it.itemid==item.info.itemid) then
							print(it.amount)
							it.amount = it.amount+orm-item.amount
							if (it.amount<0) then
								item.amount = orm;
								--dispenser.health = 0;
								dispenser:GetComponent("BaseEntity"):KillMessage()
								return false
							end
						end
					end]]

function PLUGIN:OnPlayerSpawn(player)
	local inv = player.inventory;
	--inv:Strip()
	--self:GiveItem(inv,"burlap_trousers",1,"wear")
	self:GiveItem(inv,"attire.hide.pants",1,"wear")
end

function PLUGIN:randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function PLUGIN:OnQuarryGather(quarry, item)
	item.amount = item.amount*self:randomFloat(4.5,5.2);
end

function PLUGIN:OnItemPickup(player, item)
	if (item.info.shortname=="mushroom") then item.amount = item.amount*math.random(1,3);
	else item.amount = item.amount*self:randomFloat(3.5,4.2); end
end

function PLUGIN:OnSurveyGather(surveyCharge, item)
	item.amount = item.amount*self:randomFloat(4.5,5.2);
end

local function getItem(iname)
	if(string.sub(string.lower(iname),-3) == " bp") then
		return string.sub(string.lower(iname),0,-4), true
	end
	return string.lower(iname), false
end

function PLUGIN:GiveItem(inv,rawname,amount,type)
	local itemname = false
	name, isBP = getItem(rawname)
	--if(Table[name]) then
	--	itemname = Table[name]
	--else
			itemname = name
	--end
	if(tonumber(amount) == nil) then
		return false, "amount is not valid"
	end
	local container
	if(type == "belt") then
		container = inv.containerBelt
	elseif(type == "main") then
		container = inv.containerMain
	elseif(type == "wear") then
		container = inv.containerWear
	else
		return false, "wrong type: belt, main or wear"
	end
	arr = util.TableToArray( { itemname } )
	definition = global.ItemManager.FindItemDefinition.methodarray[1]:Invoke(nil, arr )
	if(not definition) then
		return false, "Invalid item: " .. tostring(itemname)
	end
	local giveitem = global.ItemManager.CreateByItemID(definition.itemid,amount,isBP)
	if(not giveitem) then
		return false, itemname .. " is not a valid item name"
	end
	inv:GiveItem(giveitem,container);
	return giveitem
end

local timerTbl = {}
// ADD blocked steam ids here
local badIds = {
	["76560000000000xxx"]=true
}

function PLUGIN:OnPlayerConnected(packet)
    if not packet then return end
    if not packet.connection then return end
    local connection = packet.connection
	local steamId = tostring(rust.UserIDFromConnection(connection))
	if (badIds[steamId]) then
		timer.Once(1,function() 
			local rand = math.random(0,12)
			if (rand==1) then  
				Network.Net.sv:Kick(connection, "Unresponsive")
			elseif (rand==2) then
				Network.Net.sv:Kick(connection, "Steam Auth Startup:k_EBeginAuthSessionResultInvalidTicket")
			elseif (rand==4) then
				Network.Net.sv:Kick(connection, "You are already connected!")
			elseif (rand==5) then
				Network.Net.sv:Kick(connection, "Steam Auth: k_EAuthSessionResponseNoLicenseOrExpired")
			elseif (rand==7) then
				Network.Net.sv:Kick(connection, "Steam Auth: k_EAuthSessionResponseVACCheckTimedOut")
			elseif (rand==8) then
				Network.Net.sv:Kick(connection, "Steam Auth Timeout")
			elseif (rand==10) then
				Network.Net.sv:Kick(connection, "Steam: k_EAuthSessionResponseAuthTicketCanceled")
			elseif (rand==12) then
				Network.Net.sv:Kick(connection, "EAC: unconnected")
			else  
				timerTbl[steamId] = timer.Once(math.random(300,1200),function() 
					if (connection) then Network.Net.sv:Kick(connection, "Unresponsive") end
				end, self.Plugin);
			end
		end, self.Plugin);
	end
end

function PLUGIN:OnPlayerDisconnected(player)
	local steamId = tostring(player.userID);
	if (timerTbl[steamId]) then
		timerTbl[steamId]:Destroy();
	end
end