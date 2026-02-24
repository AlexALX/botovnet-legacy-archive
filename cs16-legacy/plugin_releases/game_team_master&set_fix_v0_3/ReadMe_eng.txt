Entity game_team_master & game_team_set fix plugin for CS 1.6

Description:
This plugin fix game_team_master and game_team_set entities for CS 1.6.
Without this plugin, these entities are always activated, regardless of the team player.

Modules:
Ñstrike
Fakemeta
Hamsandwich

How to use:
For game_team_master specify team in team index:
* -1 - anyone can activate
* 1 - only Terrorist can activate
* 2 - only CT can activate
For game_team_set is now possible to specify a team to change for game_team_master:
* -1 - changes team to all
* 0 - changes team to activator team (default)
* 1 - changes team to Terrorist
* 2 - changes team to CT
For specify team you must disable SmartEdit in Valve Hammer Editor and add manualy this:
Key: team, Value: 2 (or other).
(see image)
Attention! Do not fix error in Valve Hammer Editor (alt+p):
Entity (game_team_set) has unused keyvalues.
See test map, which shows an example of work. I hope everything is understood.

Copyright and thanks:
Created by AlexALX (c) 2010 http://alex-php.net/
Created special for map deathrun_skills_edited
Big thanks Arkshine (http://forums.alliedmods.net/member.php?u=7779)
For help in creating plugin.

Created special for map deathrun_skills_edited.

ChangeLog:
[15.09.10 - v0.3]
* Completely changed the code (thanks Arkshine), the function now works as on HL SDK (except for the added new option "team" for the game_team_set entity).
[28.08.10 - v0.2]
* Updated test map.
* Now for specify team for game_team_set you need disable SmartEdit in Valve Hammer Editor and add manualy: Key: team, Value: 2 (or other).
* Now teamindex is work, do not need use Yaw.
* You want to change the field Yaw on teamindex (for game_team_master) or team (for game_team_set). Otherwise Entites stop working on the map.
[27.08.10 - v0.1]
* First release.