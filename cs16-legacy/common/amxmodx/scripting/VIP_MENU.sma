/*  
 * This plugin was created for Botov-NET Project
 * This uses custom VIP system, and making extra menu for VIPS
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
#include <vip>
#include <cstrike>

new g_menuPosition[33]
new g_menuPlayers[33][32]
new g_menuPlayersNum[33]
new g_menuOption[33]
new g_menuSettings[33]

new g_coloredMenus

new Array:g_slapsettings;

const KEYS_M = MENU_KEY_0 | MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9;

#define VERSION "1.0"

public plugin_init() {

	register_plugin("VIP Menu", VERSION, "AlexALX")
	register_dictionary("common.txt")
	register_dictionary("admincmd.txt")
	register_dictionary("plmenu.txt")
	register_dictionary("vip.txt")
	register_dictionary("adminvote.txt")

	register_clcmd("amx_vip_banmenu", "cmdSlapMenu", ADMIN_ALL, "- displays vip vote kick/ban menu")
	register_menucmd(register_menuid("Kick/Ban Menu"), 1023, "actionSlapMenu")

	register_clcmd("amx_vipsmenu","menu_vip")
	register_clcmd("amx_vipmenu","menu_vip")
	register_clcmd("amx_vips_menu","menu_vip")
	register_clcmd("amx_vip_menu","menu_vip")
	register_clcmd("say vipmenu","menu_vip")
	register_clcmd("say /vipmenu","menu_vip")
	register_clcmd("say vipsmenu","menu_vip")
	register_clcmd("say /vipsmenu","menu_vip")
	register_menucmd( register_menuid( "VIP Menu" ), KEYS_M, "menu_vip" );

	g_slapsettings = ArrayCreate();
	ArrayPushCell(g_slapsettings, 0); // First option is ignored - it is slay
	ArrayPushCell(g_slapsettings, 0); // slap 0 damage

	g_coloredMenus = colored_menus()

}

public menu_vip( id )
{
	if (id!=0&&!(get_vip_flags(id) & VIP_FLAG_E) && !(get_vip_flags(id) & VIP_FLAG_D)) {
		client_print(id, print_chat,"%L",id,"VIP_FORB");
		return PLUGIN_HANDLED
	}

	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "\r%L \yv%s", id, "VIP_MENU_TITLE", VERSION );
	new menu = menu_create( szText, "vip_menu" );

	if (get_vip_flags(id) & VIP_FLAG_D) {
		formatex( szText, charsmax( szText ), "%L", id, "VIP_MENU_KB");
		menu_additem( menu, szText, "1", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "VIP_MENU_KB");
		menu_additem( menu, szText, "1", ADMIN_ADMIN );
	}

	if (get_vip_flags(id) & VIP_FLAG_E) {
		formatex( szText, charsmax( szText ), "%L", id, "VIP_MENU_CM");
		menu_additem( menu, szText, "2", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "VIP_MENU_CM");
		menu_additem( menu, szText, "2", ADMIN_ADMIN );
	}

	menu_addblank(menu,1);
	menu_addblank(menu,1);

	formatex( szText, charsmax( szText ), "%L", id, "VIP_MENU_EXIT");
	menu_additem( menu, szText, "0", 0 );

	formatex( szText, charsmax( szText ), "\yhttp://botov.net.ua/");
	menu_addtext(menu,szText,0);

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL); //, MEXIT_ALL
	new string[100];
	formatex( string, sizeof string - 1, "%L", id, "VIP_MENU_EXIT" );
	menu_setprop( menu, MPROP_EXITNAME, string );

	new num = 0;
	menu_setprop( menu, MPROP_PERPAGE, num);

	menu_display( id, menu, 0 );

	return PLUGIN_HANDLED;
}

public vip_menu( id, menu, item )
{

	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}

	new data[ 6 ], iName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

	new key = str_to_num( data );

	new Name[ 32 ];
	get_user_name( id, Name, 31 );

	switch( key )
	{
		case 1:
		{
			client_cmd(id, "amx_vip_banmenu");
			menu_destroy( menu );
		}
		case 2:
		{
			client_cmd(id, "amx_votemapmenu");
			menu_destroy( menu );
		}
		case 0:
		{
			menu_destroy( menu );
		}
	}
	return PLUGIN_HANDLED;
}

public actionSlapMenu(id, key)
{
	switch (key)
	{
		case 7:
		{
			++g_menuOption[id]

			g_menuOption[id] %= ArraySize(g_slapsettings);

			g_menuSettings[id] = ArrayGetCell(g_slapsettings, g_menuOption[id]);

			displaySlapMenu(id, g_menuPosition[id]);
		}
		case 8: displaySlapMenu(id, ++g_menuPosition[id])
		case 9: displaySlapMenu(id, --g_menuPosition[id])
		default:
		{
			new player = g_menuPlayers[id][g_menuPosition[id] * 7 + key]

			if (!is_user_connected(player))
			{
				return PLUGIN_HANDLED
			}

			new Float:voting = get_cvar_float("amx_last_voting")
			if (voting > get_gametime())
			{
				client_print(id, print_chat, "%L", id, "ALREADY_VOTING")
				return PLUGIN_HANDLED
			}

			if (voting && voting + (get_vip_flags(id) & VIP_FLAG_D && !is_user_admin(id) ? get_cvar_float("amx_vote_delay_vip") : get_cvar_float("amx_vote_delay")) > get_gametime())
			{
				client_print(id, print_chat, "%L", id, "VOTING_NOT_ALLOW")
				return PLUGIN_HANDLED
			}

			if (g_menuOption[id])
				client_cmd(id, "amx_voteban #%d", get_user_userid(player))
			else
				client_cmd(id, "amx_votekick #%d", get_user_userid(player))
		}
	}

	return PLUGIN_HANDLED
}

displaySlapMenu(id, pos)
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

	new len = format(menuBody, 511, g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, "VIP_MENU_KB", pos + 1, (g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0)))
	new end = start + 7
	new keys = MENU_KEY_0|MENU_KEY_8

	if (end > g_menuPlayersNum[id])
		end = g_menuPlayersNum[id]

	for (new a = start; a < end; ++a)
	{
		i = g_menuPlayers[id][a]
		get_user_name(i, name, 31)

		if (cs_get_user_team(i) == CS_TEAM_T)
		{
			copy(team, 3, "TE")
		}
		else if (cs_get_user_team(i) == CS_TEAM_CT)
		{
			copy(team, 3, "CT")
		} else {
			get_user_team(i, team, 3)
		}

		if (is_user_vip(i)&&!access(id, ADMIN_VOTE) || (access(i, ADMIN_IMMUNITY) && i != id))
		{
			++b

			if (g_coloredMenus)
				len += format(menuBody[len], 511-len, "\d%d. %s\R%s^n\w", b, name, team)
			else
				len += format(menuBody[len], 511-len, "#. %s   %s^n", name, team)
		} else {
			keys |= (1<<b)

			if (is_user_admin(i))
				len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s \r*\y\R%s^n\w" : "%d. %s *   %s^n", ++b, name, team)
			else if (is_user_vip(i))
				len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s \y*\y\R%s^n\w" : "%d. %s *   %s^n", ++b, name, team)
			else
				len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s\y\R%s^n\w" : "%d. %s   %s^n", ++b, name, team)
		}
	}

	if (g_menuOption[id])
		len += format(menuBody[len], 511-len, "^n8. %L^n", id, "VIP_MENU_BAN")
	else
		len += format(menuBody[len], 511-len, "^n8. %L^n", id, "VIP_MENU_KICK")

	if (end != g_menuPlayersNum[id])
	{
		format(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
		keys |= MENU_KEY_9
	}
	else
		format(menuBody[len], 511-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

	show_menu(id, keys, menuBody, -1, "Kick/Ban Menu")
}

public cmdSlapMenu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	if (!(get_vip_flags(id) & VIP_FLAG_D)&&get_vip_flags(id) & VIP_FLAG_U) {
		client_print(id,print_chat,"%L",id,"VIP_FULLONLY");
		client_print(id,print_chat,"%L",id,"YOU_NVIP2");
		console_print(id,"%L",id,"VIP_FULLONLY");
		console_print(id,"%L",id,"YOU_NVIP2");
		return PLUGIN_HANDLED;
	}

	if (id!=0&&!(get_vip_flags(id) & VIP_FLAG_D)) {
		console_print(id,"%L",id,"VIP_FORB");
		return PLUGIN_HANDLED
	}

	g_menuOption[id] = 0
	if (ArraySize(g_slapsettings) > 0)
	{
		g_menuSettings[id] = ArrayGetCell(g_slapsettings, g_menuOption[id]);
	}
	else
	{
		// should never happen, but failsafe
		g_menuSettings[id] = 0
	}

	displaySlapMenu(id, g_menuPosition[id] = 0)

	return PLUGIN_HANDLED
}