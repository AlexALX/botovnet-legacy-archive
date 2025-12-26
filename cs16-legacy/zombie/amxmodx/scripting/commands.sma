/*  
 * This plugin was created for Botov-NET Project
 * Just show a moth with server commands (redirect to web page)
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

static const PLUGIN_NAME[] = "Commands help"
static const PLUGIN_AUTHOR[] = "AlexALX"
static const PLUGIN_VERSION[] = "1.2"

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_clcmd("say /commands", "cmd_helpmotd")
	register_clcmd("say /command", "cmd_helpmotd")
	register_clcmd("say commands", "cmd_helpmotd")
	register_clcmd("say command", "cmd_helpmotd")
	register_clcmd("/commands", "cmd_helpmotd")
	register_clcmd("/command", "cmd_helpmotd")
	register_clcmd("commands", "cmd_helpmotd")
	register_clcmd("command", "cmd_helpmotd")
	register_clcmd("say /comands", "cmd_helpmotd")
	register_clcmd("say /команды", "cmd_helpmotd")
	register_clcmd("say /comand", "cmd_helpmotd")
	register_clcmd("say comands", "cmd_helpmotd")
	register_clcmd("say comand", "cmd_helpmotd")
	register_clcmd("/comands", "cmd_helpmotd")
	register_clcmd("/команды", "cmd_helpmotd")
	register_clcmd("/comand", "cmd_helpmotd")
	register_clcmd("comands", "cmd_helpmotd")
	register_clcmd("comand", "cmd_helpmotd")
	register_clcmd("say /rules", "cmd_helpmotd_r")
	register_clcmd("say /правила", "cmd_helpmotd_r")
	register_clcmd("say rules", "cmd_helpmotd_r")
	register_clcmd("/rules", "cmd_helpmotd_r")
	register_clcmd("/правила", "cmd_helpmotd_r")
	register_clcmd("rules", "cmd_helpmotd_r")
	/*
	register_clcmd("say /help", "cmd_helpmotd_h")
	register_clcmd("say /помощь", "cmd_helpmotd_h")
	register_clcmd("say help", "cmd_helpmotd_h")
	register_clcmd("/help", "cmd_helpmotd_h")
	register_clcmd("/помощь", "cmd_helpmotd_h")
	register_clcmd("help", "cmd_helpmotd_h")*/

	register_clcmd("amx_commands", "cmd_helpmotd_a", ADMIN_ALL)
	register_clcmd("amx_usercmd", "cmd_user", ADMIN_LEVEL_A, "<nick or #userid> [num]")
	register_dictionary("commands.txt")

	return PLUGIN_CONTINUE

}

public cmd_helpmotd(id)
{
	static motd[2048]
	formatex(motd, 2047, "%L", id, "HELP_MOTD_C")

	show_motd(id, motd, "Server Commands")

	return PLUGIN_CONTINUE
}

public cmd_helpmotd_r(id)
{
	static motd[5012]
	formatex(motd, 5011, "%L", id, "HELP_MOTD_R")

	show_motd(id, motd, "Server Rules")

	return PLUGIN_CONTINUE
}

public cmd_helpmotd_h(id)
{
	static motd[5012]
	formatex(motd, 5011, "%L", id, "HELP_MOTD_H")

	show_motd(id, motd, "Server Help")

	return PLUGIN_CONTINUE
}

public cmd_helpmotd_a(id,level,cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	if(!(get_vip_flags(id) & VIP_FLAG_C))
		return PLUGIN_HANDLED_MAIN

	if(get_vip_flags(id) & VIP_FLAG_C) {
		static motd[2048]
		formatex(motd, 2047, "%L", id, "HELP_MOTD_VIP")
	else {
		static motd[2048]
		formatex(motd, 2047, "%L", id, "HELP_MOTD_A")
	}

	show_motd(id, motd, "Admin Commands")

	return PLUGIN_CONTINUE
}

public cmd_user(id,level,cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static arg1[32]
	read_argv(1, arg1, 31)

	static target
	target = cmd_target(id, arg1, (CMDTARGET_ALLOW_SELF))

	if(!is_user_connected(target))
		return PLUGIN_HANDLED_MAIN

	new cmd[32],arg3[32]
  	read_argv(2, cmd, 31)
	read_argv(3, arg3, 31)

  	new cmd_user = str_to_num(cmd)

	new authid[32], authid2[32], name2[32], name[32], userid2, player = target

	get_user_authid(id, authid, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(player, name2, 31)
	get_user_name(id, name, 31)
	userid2 = get_user_userid(player)

	if (cmd_user == 1) {
  		client_cmd(target,"say /commands")
  		show_activity_key("TEXT3", "TEXT4", name, name2, "/commands");
  	} else if (cmd_user == 2) {
  		client_cmd(target,"say /rules")
  		show_activity_key("TEXT3", "TEXT4", name, name2, "/rules");
  	} else if (cmd_user == 3) {
		client_cmd(target,"say %s",arg3)
  		show_activity_key("TEXT3", "TEXT4", name, name2, "/help");
	} else if (cmd_user == 4) {
		client_cmd(target,"say %s",arg3)
  		//show_activity_key("TEXT3", "TEXT4", name, name2, "/help");
	} else if (cmd_user == 5) {
		client_cmd(target,arg3)
  		//show_activity_key("TEXT3", "TEXT4", name, name2, "/help");
	} else {
		client_cmd(target,"say /help")
  		show_activity_key("TEXT3", "TEXT4", name, name2, "/help");
	}
	log_amx("Laser: ^"%s<%d><%s><>^" use usercmd ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)

	return PLUGIN_CONTINUE
}