/*  
 * This plugin was created for Botov-NET Project
 * It allow respawn any player for admins
 *
 * Copyring by AlexALX (c) 2015
 *
 * -------------
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>
#include <cstrike>
#include <hamsandwich>
//#include <biohazard>

//new Array:g_infsettings;
new g_menuOption[33]
new g_menuSettings[33]
new g_menuPosition[33]
new g_menuPlayers[33][32]
new g_menuPlayersNum[33]
new g_coloredMenus

enum {
	FM_TEAM_UNASSIGNED,
	FM_TEAM_T,
	FM_TEAM_CT,
	FM_TEAM_SPECTATOR
};

public plugin_init() {
	register_plugin("Spawn", "1.0", "AlexALX")
	register_dictionary("common.txt")
	register_dictionary("admincmd.txt")
	register_dictionary("plmenu.txt")
	//register_dictionary("alexalx.txt")
	//register_dictionary("biohazard.txt")
	//register_dictionary("user.txt")

	register_menucmd(register_menuid("Spawn Menu"), 1023, "actionSpawnMenu")

	register_concmd("amx_spawn", "cmd_spawn", ADMIN_RCON, "<nick or #userid>")
	register_clcmd("amx_spawnmenu", "cmdSpawnMenu", ADMIN_RCON, "- display spawn menu")

	/*g_infsettings = ArrayCreate()

	ArrayPushCell(g_infsettings, 0)
	ArrayPushCell(g_infsettings, 1)
	*/

	g_coloredMenus = colored_menus()

	return PLUGIN_HANDLED

}

public cmd_spawn(id, level, cid) {

   if (!cmd_access(id,level,cid,2))
      return PLUGIN_HANDLED

	new arg[32]

	read_argv(1, arg, 31)
	new player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF)

	if (!player)
		return PLUGIN_HANDLED;

	if (id!=0) {
		new name[32], name2[32]
		get_user_name(id,name,31)
		get_user_name(player,name2,31)
		//show_activity_key("ALX_CMD_SPAWN_AD", "ALX_CMD_SPAWN_AD2", name, name2)
	}

	user_kill(player);

	set_task(0.5, "spawn", player)


	return PLUGIN_HANDLED
}

public spawn(ids) {
	ExecuteHamB(Ham_CS_RoundRespawn, ids);
	//reset_user_nv(ids);
	//if (cs_get_user_team == FM_TEAM_SPECTATOR) fm_set_user_team(ids,FM_TEAM_CT);

}

public actionSpawnMenu(id, key)
{
	switch (key)
	{
		case 7:
		{
			++g_menuOption[id]

			//g_menuOption[id] %= ArraySize(g_infsettings);

			//g_menuSettings[id] = ArrayGetCell(g_infsettings, g_menuOption[id]);

			displaySpawnMenu(id, g_menuPosition[id]);
		}
		case 8: displaySpawnMenu(id, ++g_menuPosition[id])
		case 9: displaySpawnMenu(id, --g_menuPosition[id])
		default:
		{
			new player = g_menuPlayers[id][g_menuPosition[id] * 7 + key]
			new name2[32]

			get_user_name(player, name2, 31)
			/*
			if (is_user_alive(player))
			{
				//client_print(id, print_chat, "%L", id, "CANT_PERF_DEAD", name2)
				displaySpawnMenu(id, g_menuPosition[id])
				return PLUGIN_HANDLED
			}*/

			new authid[32], authid2[32], name[32]

			get_user_authid(id, authid, 31)
			get_user_authid(player, authid2, 31)
			get_user_name(id, name, 31)
			/*
			if (g_menuOption[id] != 0)
			{
				log_amx("Cmd: ^"%s<%d><%s><>^" make human ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2)

				show_activity_key("HUMAN1", "HUMAN2", name, name2, g_menuSettings[id])
			} else {
				log_amx("Cmd: ^"%s<%d><%s><>^" make zombie ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2)

				show_activity_key("ZOMBI1", "ZOMBI2", name, name2, g_menuSettings[id])
			}
			*/
				client_cmd(id,"amx_spawn #%d",get_user_userid(player))

			displaySpawnMenu(id, g_menuPosition[id])
		}
	}

	return PLUGIN_HANDLED
}

displaySpawnMenu(id, pos)
{
	if (pos < 0)
		return

	get_players(g_menuPlayers[id], g_menuPlayersNum[id])

	new menuBody[512]
	new b = 0
	new i
	new name[32], team[4]
	new start = pos * 7

	if (start >= g_menuPlayersNum[id])
		start = pos = g_menuPosition[id] = 0

	new len = format(menuBody, 511, g_coloredMenus ? "\ySpawn Menu\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, pos + 1, (g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0)))
	new end = start + 7
	new keys = MENU_KEY_0|MENU_KEY_8

	if (end > g_menuPlayersNum[id])
		end = g_menuPlayersNum[id]

	for (new a = start; a < end; ++a)
	{
		i = g_menuPlayers[id][a]
		get_user_name(i, name, 31)
	/*
		if (is_user_alive(i))
		{
			++b

			if (g_coloredMenus)
				len += format(menuBody[len], 511-len, "\d%d. %s\R%s^n\w", b, name, team)
			else
				len += format(menuBody[len], 511-len, "#. %s   %s^n", name, team)
		} else {
			keys |= (1<<b)
			//++b
			*/
			keys |= (1<<b)
                   			if (is_user_admin(i)) {
				if (is_user_alive(i)) {
					len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s \r* *\y\R%s^n\w" : "%d. %s *   %s^n", ++b, name, team)
				} else {
					len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s \r*\y\R%s^n\w" : "%d. %s *   %s^n", ++b, name, team)
				}
			} else {
				if (is_user_alive(i)) {
					len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s *\y\R%s^n\w" : "%d. %s *   %s^n", ++b, name, team)
				} else {
					len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s \y\R%s^n\w" : "%d. %s *   %s^n", ++b, name, team)
				}
			}
		//}
	}
	/*
	if (g_menuOption[id] == 1)
		len += format(menuBody[len], 511-len, "^n8. SLAY %s^n", id)
	else
		len += format(menuBody[len], 511-len, "^n8. SPAWN^n", id)
	*/
	if (end != g_menuPlayersNum[id])
	{
		format(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
		keys |= MENU_KEY_9
	}
	else
		format(menuBody[len], 511-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

	show_menu(id, keys, menuBody, -1, "Spawn Menu")
}

public cmdSpawnMenu(id, level, cid)
{
   //if (!cmd_access(id,level,cid,2))
    //  return PLUGIN_HANDLED
	/*
	g_menuOption[id] = 0
	if (ArraySize(g_infsettings) > 0)
	{
		g_menuSettings[id] = ArrayGetCell(g_infsettings, g_menuOption[id]);
	}
	else
	{
		// should never happen, but failsafe
		g_menuSettings[id] = 0
	}*/

	if (cmd_access(id, level, cid, 1))
		displaySpawnMenu(id, g_menuPosition[id] = 0)

	return PLUGIN_HANDLED

	//displaySpawnMenu(id, g_menuPosition[id] = 0)

	//return PLUGIN_HANDLED
}

stock fm_set_user_team(client, team) {
	set_pdata_int(client, 114, team);
	/*
	message_begin(MSG_ALL, g_msgTeamInfo);
	write_byte(client);
	write_string(TeamInfo[team]);
	message_end();*/
}