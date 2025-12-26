/*  
 * This plugin was created for Botov-NET Project
 * It allow to change server language and show ip
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

static const PLUGIN_NAME[] = "Show IP & Change Lang"
static const PLUGIN_AUTHOR[] = "AlexALX"
static const PLUGIN_VERSION[] = "1.0"

public plugin_init()
{

	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	register_concmd("amx_ip", "show_ip",_,"<nick or #userid>")
	register_concmd("amx_showip", "show_ip",_,"<nick or #userid>")
	register_concmd("/lang", "change_lang",_,"")
	register_concmd("lang", "change_lang",_,"")
	//register_concmd("say /lang", "change_lang2",_,"")
	//register_concmd("say lang", "change_lang2",_,"")
	register_concmd("/language", "change_lang",_,"")
	register_concmd("language", "change_lang",_,"")
	//register_concmd("say /language", "change_lang2",_,"")
	//register_concmd("say language", "change_lang2",_,"")
	register_concmd("say", "say_lang",_,"")

}

public show_ip(id, level, cid)
{

	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED_MAIN

	static arg1[32]
	read_argv(1, arg1, 31)

	static target
	target = cmd_target(id, arg1, (CMDTARGET_OBEY_IMMUNITY|CMDTARGET_ALLOW_SELF))

	if (!target)
		return PLUGIN_HANDLED_MAIN

	new name[32],ip[32],authid[32]
	get_user_name(target, name, 31)
	get_user_ip(target, ip, 31, 1)
	get_user_authid(target, authid, 31)
	console_print(id, "^"%s^" IP: %s STEAMID: %s", name,ip,authid)
	client_print(id, print_chat, "^"%s^" IP: %s STEAMID: %s", name,ip,authid)

	return PLUGIN_HANDLED
}

public say_lang(id) {

	new args[128]
	read_args(args, 127)
	remove_quotes(args)

	if (equali(args, "lang ru") || equali(args, "/lang ru") || equali(args, "language ru") || equali(args, "/language ru")) {
		client_cmd(id,"lang ru");
	} else if (equali(args, "lang en") || equali(args, "/lang en") || equali(args, "language en") || equali(args, "/language en")) {
		client_cmd(id,"lang en");
	} else if (equali(args, "lang") || equali(args, "/lang") || equali(args, "language") || equali(args, "/language")) {
		client_cmd(id,"lang");
	}

	return PLUGIN_CONTINUE

}

public change_lang(id)
{
	new arg1[32];
	read_argv(1, arg1, 31);

	if (equali(arg1,"en")) {
		client_cmd(id,"setinfo lang en");
		client_print(id, print_chat, "You change language of server to English.");
	} else if (equali(arg1,"ru")) {
		client_cmd(id,"setinfo lang ru");
		client_print(id, print_chat, "Вы изменили язык сервера на Русский.");
	} else {
		client_print(id, print_chat, "USE: /lang en - English, /lang ru - Russian.");
	}

	return PLUGIN_HANDLED;
}
/*
public change_lang2(id)
{
	new arg1[32];
	read_argv(2, arg1, 31);

	if (equali(arg1,"en")) {
		client_cmd(id,"setinfo lang en");
		client_print(id, print_chat, "You change language of server to English.");
	} else if (equali(arg1,"ru")) {
		client_cmd(id,"setinfo lang ru");
		client_print(id, print_chat, "Вы изменили язык сервера на Русский.");
	} else {
		client_print(id, print_chat, "USE: /lang en - English, /lang ru - Russian.");
	}

	return PLUGIN_HANDLED;
}*/