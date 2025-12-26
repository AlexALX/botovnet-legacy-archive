/*

This plugin adding lua_random_map command, which uses mapcycle.txt to load random map
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

local rnd_maps = {}

if file.Exists("mapcycle.txt","DATA") then
	local maps = file.Read("mapcycle.txt","DATA")
	local mapcycle = string.Explode("\n", maps:Replace("\r\n","\n"))
	local sv_map = game.GetMap();
	for k,line in pairs(mapcycle) do
		local tbl = string.Explode(" ", line)
		if (sv_map!=tbl[1]) then
			table.insert(rnd_maps,tbl[1])
		end
	end
end

concommand.Add("lua_random_map",function(ply,cmd,args)
	if(IsValid(ply) and not ply:IsAdmin()) then return end
	local c = table.Count(rnd_maps);
	if (c>1) then
		local map = rnd_maps[math.random( 1, c )];
		game.ConsoleCommand("changelevel "..map.."\n");
	end
end)