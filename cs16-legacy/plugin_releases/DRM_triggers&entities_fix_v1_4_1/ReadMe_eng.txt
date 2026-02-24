[DeathRun] Triggers & Entities Fix v1.4.1

Description:
This plugin fixed activation of some Triggers and Entities for semiclip players (built semiclip in DeathRun Manager).
Also includes func_breakable rendering fix (by xPaw) and func_train/func_rotating rendering fix for Linux Servers (by ConnorMcLeod).

Modules:
Fakemeta
Hamsandwich

List of Triggers & Entities that are fixed:
trigger_hurt - full fix, unlike the original pligun, fix working properly for trigger_hurt's what have names (can be switched on/off).
trigger_push, trigger_teleport, trigger_gravity, trigger_multiple, trigger_once, trigger_counter - full fix.
func_breakable - fix activation "Stand on pressed" and "Touch" flags for semiclip players. func_breakable rendering fix by xPaw: "If on breakable flag touch break is set, then player can run on breakable, it will destroy, but you still will see it. this plugin fixes that".
func_button - fix activation "touch activates" flag for semiclip players.
item_healthkit, item_battery, item_longjump, armoury_entity - fixed pickup.
func_door, func_door_rotating - Causes damage to the semiclip player if he got blocked this entity, and fix opening doors by semiclip players (not always work, such as cs_militia does not work for doors in the house).
momentary_door, func_vehicle, func_tracktrain, func_pendulum - Causes damage to the semiclip player if he got blocked this entity.
func_train, func_rotating - Causes damage to the semiclip player if he got blocked this entity, and fix rendering on Linux Servers.

Attention! Important information for mappers!
Do not group few brashes in one trigger_* entity! This creates an issue and that can not be corrected. Added individually each brush in Entity. See test_map for details. Jump to red place and you are killed, jump to yellow place and you remain alive. This problem is also observed in the original plugin (DRM_trigger_hurt_fix).

Cvars:
Default - 1 (enabled)
* semiclip_fix_hurt <1/0> - Enable/Disable trigger_hurt activation fix.
* semiclip_fix_push <1/0> - Enable/Disable trigger_push activation fix.
* semiclip_fix_teleport <1/0> - Enable/Disable trigger_teleport activation fix.
* semiclip_fix_gravity <1/0> - Enable/Disable trigger_gravity activation fix.
* semiclip_fix_multiple <1/0> - Enable/Disable trigger_multiple activation fix.
* semiclip_fix_once <1/0> - Enable/Disable trigger_once activation fix.
* semiclip_fix_counter <1/0> - Enable/Disable trigger_counter activation fix.
* semiclip_fix_breakable <1/0> - Enable/Disable func_breakable activation fix.
* semiclip_fix_breakable_render <1/0> - Enable/Disable func_breakable rendering fix.
* semiclip_fix_button <1/0> - Enable/Disable func_button activation fix.
* semiclip_fix_button_delay <sec> - default 2.0 seconds, delay to update coordinates of a button. The lower the value - the higher the load for CPU. The higher the value - the lower the load for CPU. 0 - disable, but then fix will not work for moved buttons.
* semiclip_fix_item <1/0> - Enable/Disable item_healthkit, item_battery, item_longjump, armoury_entity pickup fix.
* semiclip_fix_item_delay <sec> - default 2.0 seconds, delay to update coordinates of a entities (weapon/healthkit/armor/longjump). The lower the value - the higher the load for CPU. The higher the value - the lower the load for CPU. 0 - disable, but then fix will not work for moved entities.
* semiclip_fix_door <1/0> - Enable/Disable func_door blocking fix.
* semiclip_fix_door_open <1/0> - Enable/Disable opening func_door by semiclip player fix.
* semiclip_fix_door_rotating <1/0> - Enable/Disable func_door_rotating blocking fix.
* semiclip_fix_door_rotating_open <1/0> - Enable/Disable opening func_door_rotating by semiclip player fix.
* semiclip_fix_momentary_door <1/0> - Enable/Disable momentary_door blocking fix.
* semiclip_fix_train <1/0> - Enable/Disable func_train blocking fix.
* semiclip_fix_train_render <1/0> - Enable/Disable func_train rendering fix (only for Linux servers).
* semiclip_fix_vehicle <1/0> - Enable/Disable func_vehicle blocking fix.
* semiclip_fix_tracktrain <1/0> - Enable/Disable func_tracktrain blocking fix.
* semiclip_fix_rotating <1/0> - Enable/Disable func_rotating blocking fix.
* semiclip_fix_rotating_render <1/0> - Enable/Disable func_rotating rendering fix (only for Linux servers).
* semiclip_fix_pendulum <1/0> - Enable/Disable func_pendulum blocking fix.
* semiclip_fix_block <1/0> - Enable/Disable the block door/train/vehicle with semiclip player. When you turn off this option, the door/train/vehicle will not blocked (trains/vehicles will continue to drive without stopping, and the doors will not be slide back), when stuck in them semiclip players.
You must restart the map to apply the cvars.

Tip:
You can use each map its own settings.
To do this, go to the folder amxmodx/configs/maps (if not exists - create) and create a file map_name.cfg with such content (example):
semiclip_fix_teleport 0
And save the file. It is also important not to forget to add in amxmodx/configs/amxx.cfg following:
semiclip_fix_teleport 1
Otherwise, when the map changes to another, setting and will remain disabled.

FAQ:
Question: What this plugin does?
Answer: Fixes some problems for semiclip players.

Question: Which semiclip this plugin works?
Answer: Correct work is guaranteed only with built semiclip in DeathRun Manager v3.0.3 (on earlier versions not tested).

Question: The plugin works with Automatic Unstuck?
Answer: Yes, with Automatic Unstuck v1.5 worked for me.

Question: Do I need an original trigger_hurt (by xPaw) fix?
Answer: No, you must disable it to my plugin works fine.

Question: The plugin will work with func_breakable fix (by xPaw)?
Answer: Yes, but this fix is integrated into my plugin, and better disable the func_breakable fix (by xPaw), not to create an additional cpu load.

Question: Will this plugin work with deathrun maps fixer?
Answer: Yes, all perfectly works.

Question: The plugin will work with Linux func_rotating bug fixer?
Answer: Yes, but this fix is integrated into my plugin, and better disable the Linux func_rotating bug fixer, not to create an additional cpu load.

Question: Do I need to disable the rendering fix of func_train/func_rotating (semiclip_fix_train_render/semiclip_fix_rotating_render) on windows server?
Answer: No, these settings have no meaning for windows server.

Question: I have a problem - triggers are activated is not where should!
Answer: This problem occurs most likely, because mapper add few brashes into one entity. In this case, you can try disabling fix for this trigger on this map. More I can not help you - contact with map author and ask them to fix this problem (give a link to this plugin and explain the problem, let him look a test map).

Copyright and thanks:
Created By AlexALX (c) 2010-2011 http://alex-php.net/

DRM: Triggers & Entities Fix is free software;
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
------------------------
Created By AlexALX (c) 2010-2011 http://alex-php.net/
Based on DRM_trigger_hurt_fix
Original plugin authors:
coderiz / xPaw
Thanks:
ConnorMcLeod (CTriggerPush_Touch, func_rotating rendering fix plugin)
Monyak (idea how to fix the doors and some help)
xPaw (use him func_breakable rendering fix plugin)
Lt.RAT (small help with plugin optimization)

ChangeLog:
[21.03.11 - v1.4.1]
* Fixed some errors.
[30.09.10 - v1.4]
* Improved algorithm of fix pickup weapons/items (now works for moved entities).
* Now semiclip players can pickup weapons after drop.
* Improved algorithm of fix "touch activates" flag for buttons (now works for moved entities).
* Added fix for open doors by semiclip players (not always work, such as cs_militia does not work for doors in the house).
* Added new cvars.
* Fixed work cvars with using amxbans v6.
* Added function of automatic pause plugins that should be disabled when using this plugin (eg linux func_rotating fix).
* Code Optimization.
[24.09.10 - v1.3.2]
* Included Linux func_rotating/func_train rendering fix.
* Added new cvars.
[19.09.10 - v1.3.1]
* Fixed bug with the work doors/trains/vehicles fix under some conditions.
* Minor changes.
[14.09.10 - v1.3]
* Added new cvars.
* Code Optimization.
* Improved fix the problem with false activation triggers a close passage of the semiclip player.
[12.09.10 - v1.2]
* Now when semiclip player stuck in the door/train and etc - it is blocked.
* Added semiclip_fix_block cvar.
* Added FAQ.
[09.09.10 - v1.1.1]
* Some code optimization.
* Deleted CBaseTrigger_ToggleUse function (it was not needed, do not remember what it was doing).
* Now if a player does not semiclip, it can normally pass through triggers with few brashes as one entity (who i block this? don't remember ).
* Added FAQ.
[08.09.10 - v1.1b]
* Included func_breakable rendering fix plugin by xPaw.
* Added cvars.
* Fixed a problem with the triggers when the player is very close (eg trigger_hurt killed player).
* Improved method of detection the stuck semiclip player in the doors/train etc - now it works almost always.
* Code optimization.
* Small changes.
[07.09.10 - v1.0b]
* First release.