/*  
 * This plugin was created for Botov-NET Project
 * Allowed to have unbanned users when banned shared ip
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

#include <amxmodx>
#include <amxmisc>
#include <cstrike>

#define PLUGIN "UNBAN users"
#define VERSION "1.0"
#define AUTHOR "AlexALX"

#define MAXPLAYERS 33

new amx_user_field
new bool:p_UNBAN[MAXPLAYERS]
new gmsgSayText

new line,text[64],num,Systext[128][64]

public plugin_init() {

	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /user", "user_unban", -1, "")
	register_clcmd("say user", "user_unban", -1, "")
	register_clcmd("say /users", "user_unbans", -1, "")
	register_clcmd("say users", "user_unbans", -1, "")

	register_clcmd("amx_reloadunban", "reload_unban", ADMIN_BAN, "")

	register_dictionary( "unbanusers.txt" )
	gmsgSayText = get_user_msgid("SayText")
	amx_user_field = register_cvar("amx_user_field", "_pw-user")

}

public plugin_natives()
{
	register_library("unbanusers")
	register_native("is_user_unban", "is_user_unban", 1)
}

get_inipath(path[],len)
{

	get_configsdir( path , len )
	format(path , len , "%s/users-unban.ini",path)

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

	//new szLine[101]
	//new line
	//new len = 0

	//while(read_file(szFile, line ++ , szLine , 100 , len)) {

	for(line=0;read_file(szFile,line,text,sizeof(text)-1,num);line++) {
		//if(text[0] == ';' || !num) continue
		Systext[line]=text
	}

}

public client_connect(id) {
	p_UNBAN[id] = false
	check_ini(id)
}

public client_authorized(id) {
	set_task(0.2, "check_ini", id)
}

public client_disconnect(id) {
	p_UNBAN[id] = false
}

public client_infochanged(id) {
	set_task(0.1, "check_ini", id)
}

public check_ini(id) {

	if(!is_user_connected(id))
		return PLUGIN_HANDLED_MAIN

	//new szFile[66]
	//get_inipath (szFile,65)

	//new szLine[64]
	//new line
	//new len = 0
	p_UNBAN[id] = false
	//new szLine = line
	//while(read_file(szFile, line ++ , szLine , 100 , len)) {
	for(new szLine=0;szLine<line+1;szLine++) {

		if(Systext[szLine][0] == ';') continue

		new auth[32]
		new pass[32]

		new name[32]
		get_user_name(id, name, 31)

		new password[32], passfield[32]

		parse(Systext[szLine], auth , 31 , pass, 31)

		get_pcvar_string(amx_user_field, passfield, 31)
		get_user_info(id, passfield, password, 31)
		//new msg[92]
		if (equal(name,auth)) {
		//if (check_auth(id,auth)) {
			//formatex(msg, 91, "Proverka proshla!")
			//print_message(id,msg)
			p_UNBAN[id] = true
			if (!is_user_bot(id) && !equal(pass, password)) {
				server_cmd("kick #%d You password for unban USER is incorrect.",get_user_userid(id))
				return PLUGIN_HANDLED_MAIN
			}
		}

	}

	return PLUGIN_CONTINUE

}
public user_unban(id) {
	new msg[92]
	if (is_unban(id)) {
		formatex(msg, 91, "^x04%L", id, "YOU_UNBANUSER")
		print_message(id,msg)
	} else {
		formatex(msg, 91, "^x04%L", id, "YOU_NUNBANUSER")
		print_message(id,msg)
	}

	return PLUGIN_CONTINUE

}

public user_unbans(id) {
	print_unbanlist(id)
	return PLUGIN_CONTINUE
}

public print_unbanlist(user)
{
	new unbannames[33][32]
	new message[256]
	new id, count, x, len

	for(id = 1 ; id <= MAXPLAYERS ; id++)
		if(is_user_connected(id))
			if(is_unban(id))
				get_user_name(id, unbannames[count++], 31)

	len = format(message, 255, "^x04%L: ^x01",user,"UNBANUSERS")
	if(count > 0) {
		for(x = 0 ; x < count ; x++) {
			len += format(message[len], 255-len, "%s%s ", unbannames[x], x < (count-1) ? ", ":"")
			if(len > 96 ) {
				print_message(user, message)
				len = format(message, 255, "")
			}
		}
		print_message(user, message)
	}
	else {
		len += format(message[len], 255-len, "%L",user,"UNBANUSERS_NO")
		print_message(user, message)
	}

	return PLUGIN_CONTINUE
}

public is_user_unban(index) {
	return (is_user_connected(index) && p_UNBAN[index] == true) ? 1 : 0
}

public is_unban(index) {
	return (is_user_connected(index) && p_UNBAN[index] == true) ? 1 : 0
}

print_message(id, msg[]) {
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}

public reload_unban(id,level,cid) {

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	read_config()
	for (new i=1; i <= MAXPLAYERS; i++) {
		if (is_user_connected(i)) {
			check_ini(i)
		}
	}
	console_print(id, "[AMXX] Reload unban users comleted.");
	return PLUGIN_HANDLED

}