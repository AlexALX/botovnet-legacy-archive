/*

This plugin fixes sq_quadrants and gm_galactic_rc1 map issues with stargate
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

if (game.GetMap():find("sb_")==nil and game.GetMap()!="sg_quadrants" and game.GetMap()!="gm_galactic_rc1") then return end

SB_Entities = SB_Entities or {}

timer.Simple(10.0,function()
	for k,v in pairs(ents.FindByClass("base_sb_*")) do
		v:SetRenderMode(1);
		v:SetColor(Color(0,0,0,0));
		--SB_Entities[v] = duplicator.Copy(v);
		table.insert(SB_Entities,v);
	end
end)

timer.Create("SB_Entities_Fix",10.0,0,function()
	local reload = false;
	for k,v in pairs(SB_Entities) do
		if (not IsValid(v)) then

			timer.Simple(3.0,function()
				for k,v in pairs(ents.FindByClass("base_sb_*")) do
					v:SetRenderMode(1);
					v:SetColor(Color(0,0,0,0));
					--SB_Entities[v] = duplicator.Copy(v);
					table.insert(SB_Entities,v);
				end
			end)

			SB_Entities = {};

			return SB__AutoStart();

			/*if (v.Entities) then
				local ent
				for b,e in pairs(v.Entities) do
					ent = ents.Create(e.Class);
					if ( e.Model ) then ent:SetModel( e.Model ) end
					if ( e.Angle ) then ent:SetAngles( e.Angle ) end
					if ( e.Pos ) then ent:SetPos( e.Pos ) end
					if ( e.ColGroup ) then ent:SetCollisionGroup( e.ColGroup ) end
					if ( e.Name ) then ent:SetName( e.Name ) end
					if ( e.sbenvironment ) then ent.sbenvironment = e.sbenvironment end
					if ( e.caf ) then ent.sbenvironment = e.caf end
					ent:Spawn();
				end
				if (IsValid(ent)) then
					reload = true;
					SB_Entities[k] = nil;
					SB_Entities[ent] = duplicator.Copy(ent);
				end
			end      */
			--duplicator.Paste( Entity(1), SB_Entities, v )
			--duplicator.CreateEntityFromTable(Entity(1),v);
		end
	end

	if (table.Count(SB_Entities)==0) then
		timer.Simple(3.0,function()
			for k,v in pairs(ents.FindByClass("base_sb_*")) do
				v:SetRenderMode(1);
				v:SetColor(Color(0,0,0,0));
				--SB_Entities[v] = duplicator.Copy(v);
				table.insert(SB_Entities,v);
			end
		end)

		return SB__AutoStart();
	end

	 /*
	if (reload) then
		SB__AutoStart();
	end    */
end);