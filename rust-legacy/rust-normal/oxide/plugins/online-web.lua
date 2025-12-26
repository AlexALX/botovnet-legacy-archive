/*

This plugin used for display player lists and chat on web-page.
User on Botov-NET rust servers.

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

PLUGIN.Title = "PlayersWebService"
PLUGIN.Description = "Publishes player list to a website"
PLUGIN.Author = "AlexALX"
PLUGIN.Version      = V(0, 0, 1)
PLUGIN.HasConfig    = false
--PLUGIN.ResourceID   = 676

-- SERVER-ID For monitoring page
local SERVER = 3
local SV_URL = ""
-- protection key, must match configuration
local api_key = "someKey"

function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function urlencode(str)
if (str) then
str = string.gsub (str, "\n", "\r\n")
str = string.gsub (str, "([^%w ])",
function (c) return string.format ("%%%02X", string.byte(c)) end)
str = string.gsub (str, " ", "+")
end
return str
end

local function cmdList(self)

local names = ""
local itPlayerList = global.BasePlayer.activePlayerList:GetEnumerator()

while itPlayerList:MoveNext() do
    if (names~="") then names = names .. "||,||" end
   	names = names .. itPlayerList.Current.displayName
end

webrequests.EnqueuePost("http://localhost/sv_files/rust/online.php?key="..api_key..SV_URL,"list=" .. urlencode(names), function(code, content)
	if(code == 200) then
		--print(content)
	end
	end,self.Plugin)

end

function PLUGIN:OnServerInitialized()
	cmdList(self);
end

function PLUGIN:Init()
--oxmin_mod = cs.findplugin("oxmin")
--oxmin_mod:AddExternalOxminChatCommand(self, "online", {}, cmdList)

	cmdList(self);

--print_r(global.server)

	self.Timer = {}
	self.Timer = timer.Repeat (300 , 0 , function() self:SavePlayers( ) end )

end

--[[
function PLUGIN:OnPlayerDisconnected()
timer.Once(1,function() cmdList(self) end);
--cmdList(self);
end

function PLUGIN:OnPlayerInit(ply)
cmdList(self);
end
         ]]
function PLUGIN:OnPlayerChat(arg)
    if not arg then return end
    if not arg.connection then return end
    if not arg.connection.player then return end
    local player = arg.connection.player
    local chat = arg:GetString(0, "text")
	if (chat=="") then return end
	webrequests.EnqueuePost("http://localhost/includes/sv_api/chat.php?key="..api_key,"name="..urlencode(player.displayName).."&server="..SERVER.."&message="..urlencode(chat).."&time="..time.GetUnixTimestamp().."&color=78,156,233", function(code, content)
	--if(code == 200) then
	--	print(content)
	--end
	end,self.Plugin)
end

ONLINE_PLAYERS = ONLINE_PLAYERS or {}

function PLUGIN:OnPlayerInit( ply )
	cmdList(self);

	local sid = rust.UserIDFromPlayer(ply)

	ONLINE_PLAYERS[sid] = time.GetUnixTimestamp()

	webrequests.EnqueuePost("http://localhost/infusions/personal/api/update.php?key="..api_key.."&stage=connect&sid="..sid,"name="..urlencode(ply.displayName).."&server="..SERVER.."&time=0", function(code, content) end,self.Plugin)

	--webrequests.EnqueuePost("http://localhost/includes/sv_api/chat.php?key="..api_key,"msg=1&server="..SERVER.."&message="..urlencode(allusermsg).."&time="..time.GetUnixTimestamp().."&color=0,0,0", function(code, content)
	--if(code == 200) then
	--	print(content)
	--end
	--end,self.Plugin)
end

function PLUGIN:OnPlayerDisconnected(ply,connection)

	timer.Once(1,function() cmdList(self) end);

	if (ply.displayName) then
	local sid = rust.UserIDFromPlayer(ply)
	local dat = time.GetUnixTimestamp()

	if (ONLINE_PLAYERS[sid]) then
		webrequests.EnqueuePost("http://localhost/infusions/personal/api/update.php?key="..api_key.."&sid="..sid,"name="..urlencode(ply.displayName).."&server="..SERVER.."&time="..(dat-ONLINE_PLAYERS[sid]), function(code, content) end,self.Plugin)
		ONLINE_PLAYERS[sid] = nil
	end

	--webrequests.EnqueuePost("http://localhost/includes/sv_api/chat.php?key="..api_key,"msg=1&server="..SERVER.."&message="..urlencode(allusermsg).."&time="..time.GetUnixTimestamp().."&color=0,0,0", function(code, content)
	--if(code == 200) then
	--	print(content)
	--end
	--end,self.Plugin)
	else return
	end
end

function PLUGIN:SavePlayers()

local itPlayerList = global.BasePlayer.activePlayerList:GetEnumerator()

while itPlayerList:MoveNext() do
	local sid = rust.UserIDFromPlayer(itPlayerList.Current)
	local dat = time.GetUnixTimestamp()

	if (ONLINE_PLAYERS[sid]) then
		webrequests.EnqueuePost("http://localhost/infusions/personal/api/update.php?key="..api_key.."&sid="..sid,"name="..urlencode(itPlayerList.Current.displayName).."&server="..SERVER.."&time="..(dat-ONLINE_PLAYERS[sid]),
		function(code, content)
		if (content=="OK") then
			ONLINE_PLAYERS[sid] = time.GetUnixTimestamp()
		end
		end,self.Plugin)
	else
		ONLINE_PLAYERS[sid] = time.GetUnixTimestamp()
	end
end

end

function PLUGIN:Unload()
	if self.Timer then self.Timer:Destroy() end

	webrequests.EnqueuePost("http://localhost/sv_files/rust/online.php?key="..api_key,"list=", function(code, content)
	if(code == 200) then
		--print(content)
	end
	end,self.Plugin)
end