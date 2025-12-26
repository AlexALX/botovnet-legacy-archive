/*  
 * This plugin was created for Botov-NET Project
 * Allow access cetrain players (or VIPS) when subnet is banned
 * Maybe was used with amxbans or not sure
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

#define VIP true
#define UNBAN true

#include <amxmodx>
#include <amxmisc>
#include <regex>

#if defined VIP
 #include <vip>
#endif

#if defined UNBAN
 #include <users>
#endif

new line,text[64],num,Systext[128][64]

#define MAXPLAYERS 33

public plugin_init()
{
	register_plugin("Access on ban", "1.2.1", "AlexALX")
	register_concmd("amx_reloadips", "reload_ips", ADMIN_BAN, "")
	//register_concmd("amx_ipban", "add_ban", ADMIN_RCON, "<ip> [comment]")

	register_event("MOTD","check_motd","b")
}

get_inipath(path[],len)
{

	get_configsdir( path , len )
	format(path , len , "%s/ipaccess.ini",path)

	if (!file_exists(path)){
		write_file (path,"",-1)
	}
}

public plugin_cfg() {
	read_config()
}

public read_config() {

	new szFile[66]
	get_inipath (szFile,65)

	for(line=0;line<=(sizeof(Systext)-1);line++) {
		format(Systext[line],63,"")
	}

	for(line=0;read_file(szFile,line,text,sizeof(text)-1,num);line++) {
		Systext[line]=text
	}

}

public check_motd(id) {

	if (get_user_team(id)!=0)
		return PLUGIN_CONTINUE;

	set_task(0.2,"check_ini",id)
	return PLUGIN_HANDLED;

}

public client_infochanged(id) {

	new newname[32], oldname[32]

	get_user_name(id, oldname, 31)
	get_user_info(id, "name", newname, 31)

	if (!equali(oldname, "") && !equali(newname, oldname))
		set_task(0.2,"check_ini",id)

	return PLUGIN_CONTINUE
}

#if !defined VIP
#define VIP_FLAG_B (1<<1)	// flag "b"
public get_sysvip_flags(index) {
	return false;
}
#endif

#if !defined UNBAN
public is_user_unban(index) {
	return false;
}
#endif

public check_ini(id) {

		new ip[16]
		get_user_ip(id,ip,15,1)


		for(new szLine=0;szLine<line+1;szLine++) {

			if(Systext[szLine][0] == ';') continue

			new ips[16];
			parse (Systext[szLine], ips , 15);
			//client_print(id,print_chat,"%s %s",ip,ips)
			if (contain( ip, ips ) != -1 && !access(id, ADMIN_RESERVATION) && !(get_sysvip_flags(id) & VIP_FLAG_B) && !is_user_unban(id)) {
				server_cmd("kick #%d Your network is banned from this server. Ваша сеть забанена на данном сервере, посетите http://botov.net.ua/unban", get_user_userid(id))
			}
		}

}

public reload_ips(id,level,cid) {

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	read_config()
	for (new i=1; i <= MAXPLAYERS; i++) {
		if (is_user_connected(i)) {
			check_ini(i)
		}
	}
	console_print(id, "[AMXX] Reload ips comleted.");
	return PLUGIN_HANDLED

}

public add_ban(id,level,cid) {

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	new arg[16],arg2[32]
	read_argv(1, arg, 15)
	read_argv(2, arg2, 31)

	new pattern[64]
	format( pattern, charsmax( pattern ), "[0-9]{1,3}[.][0-9]{1,3}[.]([1-9]{1}[0-9]{1,2}){0,1}[.]{0,1}([1-9]{1}[0-9]{1,2}){0,1}" );

	new num, error[32]
	new Regex:re = regex_match(arg, pattern, num, error, 31)    //,flags

	if (re >= REGEX_OK) {
		regex_free(re)
	} else {
		console_print(id, "[BANIP] This ip is incorrect.");
		return PLUGIN_HANDLED
	}

	for(new szLine=0;szLine<line+1;szLine++) {

		if(Systext[szLine][0] == ';') continue

		new ips[16];
		parse (Systext[szLine], ips , 15);
		if (contain( arg, ips )!=-1) {
			console_print(id, "[BANIP] This ip already banned.");
			return PLUGIN_HANDLED
		}

	}

	new szFile[66]
	get_inipath (szFile,65)

	new linetoadd[512]
	formatex(linetoadd, 511, "^r^n^"%s^"", arg)

	if (!equali(arg2,""))
		formatex(linetoadd, 511, "%s ; %s", linetoadd, arg2)

	if (!write_file(szFile, linetoadd))
		console_print(id, "[BANUIP] Failed writing to %s!", szFile)

	read_config()
	return PLUGIN_HANDLED
}