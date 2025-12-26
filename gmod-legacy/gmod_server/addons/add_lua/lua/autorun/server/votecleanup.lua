/*

This plugin adding !votecleanup chat command and admin !abortclean
If vote successfull - map will be cleaned
Uses ULib/ULX permission system

Used on Botov-NET gmod server
Copyright (c) 2015 by AlexALX

-----------

Since it used code part from ULX, this plugin uses different license: 

ULX is brought to you by..

    Brett "Megiddo" Smith - Contact: mailto:megiddo@ulyssesmod.net
    JamminR - Contact: mailto:jamminr@ulyssesmod.net
    Stickly Man! - Contact: mailto:sticklyman@ulyssesmod.net
    MrPresident - Contact: mailto:mrpresident@ulyssesmod.net

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

*/
local blocked = false;

local function callback(t)
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	local str
	if not winner then
		str = "Vote results: No option won because no one voted!"
	else
		str = "Vote results: Option '" .. t.options[ winner ] .. "' won. (" .. winnernum .. "/" .. t.voters .. ")"
	end
	ULib.tsay( _, str ) -- TODO, color?
	ulx.logString( str )
	Msg( str .. "\n" )

	if (winner==1) then
		local sec = 15;
		ULib.tsay( _, "Warning: cleanup within "..sec.." seconds." );
		timer.Create("Global_VoteCleanup",1.0,14,function()
			sec = sec-1;
			ULib.tsay( _, "Warning: cleanup within "..sec.." seconds." );
		end);
		timer.Create("Global_Vote_DoCleanup",15.0,1,function()
			ULib.tsay( _, "Cleanup everything..." );
			RunConsoleCommand("gmod_admin_cleanup");
			timer.Simple(1.0,function()
				ULib.tsay( _, "Cleanup completed!" );
			end)
			blocked = false;
		end);
	else
		blocked = false;
	end
end

local last = 0;

local function playerSay(ply,txt)
	if !IsValid(ply) then return "" end
	txt = string.lower(txt)
	local texttbl = string.Explode(" ",txt)
	if texttbl[1] == "!votecleanup" then
		if (last>=CurTime() and not ply:IsAdmin()) then
			local sec = math.ceil(last-CurTime());
			if (sec>=60) then
				local time = string.FormattedTime(sec);
				ULib.tsay( ply, "You can't start vote for cleanup again in "..time.m.." minutes "..time.s.." seconds." );
			else
				ULib.tsay( ply, "You can't start vote for cleanup again in "..sec.." seconds." );
			end
		elseif (blocked) then
			ULib.tsay( ply, "You can't start vote at this time." );
		else
			blocked = true;
			ulx.doVote( "Cleanup everything?", {"Yes","No"}, callback );
			print( "Cleanup vote started" )
			last = CurTime()+600;
		end
	elseif texttbl[1] == "!abortclean" and ply:IsAdmin() then
		timer.Remove("Global_Vote_DoCleanup")
		timer.Remove("Global_VoteCleanup")
		ULib.tsay( _, "Cleanup canceled!" );
		blocked = false;
	elseif texttbl[1] == "!restart" and ply:IsAdmin() then
		RunConsoleCommand("changelevel",game.GetMap());
	end
end

hook.Add("PlayerSay", "Global_VoteCleanup",playerSay);

concommand.Add("votecleanup",function(ply)
	if (IsValid(ply) and not ply:IsAdmin()) then return end

	if (blocked) then
		print( "You can't start vote at this time." );
	else
		blocked = true;
		ulx.doVote( "Cleanup everything?", {"Yes","No"}, callback );
		print( "Cleanup vote started" )
		last = CurTime()+600;
	end
end);

concommand.Add("abortclean",function(ply)
	if (IsValid(ply) and not ply:IsAdmin()) then return end

	timer.Remove("Global_Vote_DoCleanup")
	timer.Remove("Global_VoteCleanup")
	ULib.tsay( _, "Cleanup canceled!" );
	blocked = false;
end);

concommand.Add("restart_",function(ply)
	if (IsValid(ply) and not ply:IsAdmin()) then return end

	RunConsoleCommand("changelevel",game.GetMap());
end);