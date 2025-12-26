/*  
 * This plugin was created for Botov-NET Project
 * This makes custom VIP system NO-SQL (just ini file version)
 * VIP features are depend on other plugins and must be coded separately
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
#include <unixtime>
#include <hamsandwich>

#define PLUGIN "VIP users"
#define VERSION "1.1.3"
#define AUTHOR "AlexALX"

#define MAXPLAYERS 33
#define DELAY_CHECK_VIP 300.0 // seconds

new amx_vip_field
new bool:p_VIP[MAXPLAYERS]
new t_VIP[MAXPLAYERS][32]
new f_VIP[MAXPLAYERS][32]
new gmsgSayText

#define VIP_FLAG_ALL 0	// everyone
#define VIP_FLAG_A (1<<0)	// flag "a"
#define VIP_FLAG_B (1<<1)	// flag "b"
#define VIP_FLAG_C (1<<2)	// flag "c"
#define VIP_FLAG_D (1<<3)	// flag "d"
#define VIP_FLAG_E (1<<4)	// flag "e"
#define VIP_FLAG_F (1<<5)	// flag "f"
#define VIP_FLAG_G (1<<6)	// flag "g"
#define VIP_FLAG_H (1<<7)	// flag "h"
#define VIP_FLAG_I (1<<8)	// flag "i"
#define VIP_FLAG_J (1<<9)	// flag "j"
#define VIP_FLAG_K (1<<10)	// flag "k"
#define VIP_FLAG_L (1<<11)	// flag "l"
#define VIP_FLAG_M (1<<12)	// flag "m"
#define VIP_FLAG_N (1<<13)	// flag "n"
#define VIP_FLAG_O (1<<14)	// flag "o"
#define VIP_FLAG_P (1<<15)	// flag "p"
#define VIP_FLAG_Q (1<<16)	// flag "q"
#define VIP_FLAG_R (1<<17)	// flag "r"
#define VIP_FLAG_S (1<<18)	// flag "s"
#define VIP_FLAG_T (1<<19)	// flag "t"
#define VIP_FLAG_U (1<<20)	// flag "u"
#define VIP_FLAG_Y (1<<24)	// flag "y"
#define VIP_FLAG_Z (1<<25)	// reserved to not VIP user
/*
#define VIP_FLAG_KICK			(1<<0)	// flag "a"
#define VIP_FLAG_TAG			(1<<1)	// flag "b"
#define VIP_FLAG_AUTHID			(1<<2)	// flag "c"
#define VIP_FLAG_IP				(1<<3)	// flag "d"
#define VIP_FLAG_NOPASS			(1<<4)	// flag "e"
#define VIP_FLAG_CASE_SENSITIVE (1<<10)	// flag "k"
*/
new line,text[64],num,Systext[128][64],amx_free_vip,amx_free_vipt

public plugin_init() {

	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /vip", "user_vip", -1, "")
	register_clcmd("say /вип", "user_vip", -1, "")
	register_clcmd("say вип", "user_vip", -1, "")
	register_clcmd("say vip", "user_vip", -1, "")
	register_clcmd("say /vips", "user_vips", -1, "")
	register_clcmd("say /випы", "user_vips", -1, "")
	register_clcmd("say випы", "user_vips", -1, "")
	register_clcmd("say vips", "user_vips", -1, "")
	register_clcmd("say /vipinfo", "info_vip", -1, "")
	register_clcmd("say /випинфо", "info_vip", -1, "")
	register_clcmd("say випинфо", "info_vip", -1, "")
	register_clcmd("say vipinfo", "info_vip", -1, "")
	register_clcmd("say /vipcommands", "commands_vip", -1, "")
	register_clcmd("say /vipcomands", "commands_vip", -1, "")
	register_clcmd("say /випкоманды", "commands_vip", -1, "")
	register_clcmd("say випкоманды", "commands_vip", -1, "")
	register_clcmd("say vipcommands", "commands_vip", -1, "")
	register_clcmd("say vipcomands", "commands_vip", -1, "")
	register_concmd("amx_reloadvips", "reload_vips", ADMIN_BAN, "")
	//register_clcmd("say flag", "check_flag", -1, "")
	register_message(get_user_msgid("ScoreAttrib"), "Message_ScoreAttrib")

	register_dictionary( "vip.txt" )
	gmsgSayText = get_user_msgid("SayText")
	amx_vip_field = register_cvar("amx_vip_field", "_vip")
	amx_free_vip = register_cvar("amx_free_vip", "0")
	amx_free_vipt = register_cvar("amx_free_vipt", "0")

}

public plugin_natives()
{
	register_library("vip")
	register_native("is_user_vip", "is_user_vip", 1)
	register_native("get_vip_flags", "get_vip_flags", 1)
	register_native("get_sysvip_flags", "get_sysvip_flags", 1)
}

get_inipath(path[],len)
{

	get_configsdir( path , len )
	format(path , len , "%s/vips.ini",path)

	if (!file_exists(path)){
		write_file (path,"",-1)
	}
}

get_notdpath(path[],len,id)
{

	get_configsdir( path , len )
	format(path , len , "%L",id,"VIP_FILE",path)

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

	//new null[2]
	//while(read_file(szFile, line ++ , szLine , 100 , len)) {
	//arrayset(Systext[127],null[1],63)

	for(line=0;line<=(sizeof(Systext)-1);line++) {
		format(Systext[line],63,"")
	}

	for(line=0;read_file(szFile,line,text,sizeof(text)-1,num);line++) {
		//if(text[0] == ';' || !num) continue
		Systext[line]=text
	}

}

#define SCOREATTRIB_VIP            (1<<2)

public Message_ScoreAttrib(osef2talife, osef3talife, osef4talife)
{
    new id = get_msg_arg_int(1)

    if( !get_msg_arg_int(2) )
    {
        if( get_vip_flags(id) & VIP_FLAG_C )
        {
            set_msg_arg_int(2, ARG_BYTE, SCOREATTRIB_VIP)
        }
    }
}

public client_connect(id) {
	p_VIP[id] = false
	t_VIP[id] = "0"
	f_VIP[id] = "z"
}

public client_authorized(id) {
	set_task(0.2, "check_ini", id)
}

public client_disconnect(id) {
	p_VIP[id] = false
	t_VIP[id] = "0"
	f_VIP[id] = "z"
}

public client_infochanged(id) {
	set_task(0.1, "check_ini", id)
}
/*
public check_auth(id, AuthData[]) {

	new name[32]
	get_user_name(id, name, 32)
	//new msg[92]
	//formatex(msg, 91, "Proverka!")
	//print_message(id,msg)
	if (equali(name, AuthData))
		return true
	else
		return false

	return false

	equali(szName, nick)
	new szName[32]
	get_user_name(id, szName, 31)

}*/


public check_inif(id) {

	if(!is_user_connected(id))
		return PLUGIN_HANDLED_MAIN

	if (get_pcvar_num(amx_free_vipt) == 0 || get_systime() <= get_pcvar_num(amx_free_vipt)) {
		p_VIP[id] = true
		get_pcvar_string(amx_free_vipt, t_VIP[id], 31)
		f_VIP[id] = "cu"
	} else {
		p_VIP[id] = false
		t_VIP[id] = "0"
		f_VIP[id] = "z"
	}

	return PLUGIN_CONTINUE

}

public check_ini(id) {

	if(!is_user_connected(id))
		return PLUGIN_HANDLED_MAIN

	//new szFile[66]
	//get_inipath (szFile,65)

	//new szLine[64]
	//new line
	//new len = 0
	p_VIP[id] = false
	t_VIP[id] = "0"
	f_VIP[id] = "z"
	//new szLine = line
	//while(read_file(szFile, line ++ , szLine , 100 , len)) {

	if (get_pcvar_num(amx_free_vip)!=0) {
		check_inif(id)
	}

	for(new szLine=0;szLine<line+1;szLine++) {

		if(Systext[szLine][0] == ';') continue

		new auth[32]
		new pass[32]
		new time[32]
		new flag[32]
		//new flags[32]

		new name[32]
		get_user_name(id, name, 31)

		new password[32], passfield[32]

		parse(Systext[szLine], auth , 31 , pass , 31, time , 31, flag, 31)

		get_pcvar_string(amx_vip_field, passfield, 31)
		get_user_info(id, passfield, password, 31)
		//new msg[92]
		if (equal(name,auth)) {
		//if (check_auth(id,auth)) {
			//formatex(msg, 91, "Proverka proshla!")
			//print_message(id,msg)
			if (equal(time, "0") || get_systime() <= str_to_num(time)) {
				p_VIP[id] = true
				t_VIP[id] = time
				f_VIP[id] = flag
			} else {
				if (get_pcvar_num(amx_free_vip)!=0 && (get_pcvar_num(amx_free_vipt) == 0 || get_systime() <= get_pcvar_num(amx_free_vipt))) {
					p_VIP[id] = true
					get_pcvar_string(amx_free_vipt, t_VIP[id], 31)
					f_VIP[id] = "cu"
				} else {
					p_VIP[id] = false
					t_VIP[id] = time
					f_VIP[id] = "z"
				}
			}
			if (!is_user_bot(id) && !equal(pass, password)) {
				server_cmd("kick #%d You password for VIP is incorrect.",get_user_userid(id))
				return PLUGIN_HANDLED_MAIN
			}
		}

	}
	remove_task(id)
	set_task(DELAY_CHECK_VIP, "check_ini", id)

	return PLUGIN_CONTINUE

}

public get_vip_flags(id) {
	if (is_user_vip(id)) {
		return read_flags(f_VIP[id])
	}
	return VIP_FLAG_Z
}

public get_sysvip_flags(id) {
		return read_flags(f_VIP[id])
}

/*
public get_sys_flags(id,flag[],bool:vip) {
	if (is_user_vip(id) && vip == true) {
		return read_flags(flag)
	} else if (vip == false) {
		return read_flags(flag)
	}
	return false
}


public check_flag(id) {
	new msg[92]

	if (get_vip_flags(id) & VIP_FLAG_A) {
		formatex(msg, 91, "Uvejet flag A!")
		print_message(id,msg)
	}
	if (get_vip_flags(id) & VIP_FLAG_Z) {
		formatex(msg, 91, "Uvejet flag Z!")
		print_message(id,msg)
	}

	if (get_sysvip_flags(id) & VIP_FLAG_A) {
		formatex(msg, 91, "Uvejet sysflag A!")
		print_message(id,msg)
	}

}  */

public user_vip(id) {
	new msg[92]
	if (is_vip(id)) {
		new iMonth, iDay, iYear, iHour, iMinute, iSecond
		new date[32]
		UnixToTime( str_to_num(t_VIP[id])+7200 , iYear , iMonth , iDay , iHour , iMinute , iSecond )
		if (equal(t_VIP[id],"0"))
			formatex(date, 31, "^x01---")
		else
			formatex(date, 31, "^x01%02d/%02d/%02d %02d:%02d", iDay,iMonth,iYear,iHour,iMinute)
		if (get_vip_flags(id) & VIP_FLAG_U) {
			formatex(msg, 91, "^x04%L", id, "YOU_VIPFREE",date)
			print_message(id,msg)
		} else {
			formatex(msg, 91, "^x04%L", id, "YOU_VIP",date)
			print_message(id,msg)
		}
		formatex(msg, 91, "^x01%L", id, "YOU_NVIP2")
		print_message(id,msg)
	} else {
		if (!equal(t_VIP[id],"0")) {
			new iMonth2, iDay2, iYear2, iHour2, iMinute2, iSecond2
			new date2[32]
			UnixToTime( str_to_num(t_VIP[id]) , iYear2 , iMonth2 , iDay2 , iHour2 , iMinute2 , iSecond2 )
			formatex(date2, 31, "^x01%02d/%02d/%02d %02d:%02d", iDay2,iMonth2,iYear2,iHour2,iMinute2)
			formatex(msg, 91, "^x04%L", id, "YOU_EVIP",date2)
			print_message(id,msg)
		} else {
			formatex(msg, 91, "^x04%L", id, "YOU_NVIP")
			print_message(id,msg)
			formatex(msg, 91, "^x01%L", id, "YOU_NVIP2")
			print_message(id,msg)
		}
	}

	return PLUGIN_CONTINUE

}

public user_vips(id) {
	print_viplist(id)
	return PLUGIN_CONTINUE
}

public print_viplist(user)
{
	new vipnames[33][32]
	new message[256]
	new id, count, x, len

	for(id = 1 ; id <= MAXPLAYERS ; id++)
		if(is_user_connected(id))
			if(is_vip(id))
				get_user_name(id, vipnames[count++], 31)

	len = format(message, 255, "^x04%L: ^x01",user,"VIPS")
	if(count > 0) {
		for(x = 0 ; x < count ; x++) {
			len += format(message[len], 255-len, "%s%s ", vipnames[x], x < (count-1) ? ", ":"")
			if(len > 96 ) {
				print_message(user, message)
				len = format(message, 255, "")
			}
		}
		print_message(user, message)
	}
	else {
		len += format(message[len], 255-len, "%L",user,"VIPS_NO")
		print_message(user, message)
	}

	return PLUGIN_CONTINUE
}

public info_vip(id) {

	new szFiles[66]
	get_notdpath (szFiles,65,id)
	show_motd(id, szFiles, "VIP Info")

	return PLUGIN_CONTINUE

}

public commands_vip(id) {

	new motd[2048]
	formatex(motd, 2047, "%L", id, "VIP_MOTD")
	show_motd(id, motd, "VIP Commands")

	return PLUGIN_CONTINUE

}

public is_user_vip(index) {
	return (is_user_connected(index) && p_VIP[index] == true && !(read_flags(f_VIP[index]) & VIP_FLAG_Z)) ? 1 : 0
}

public is_vip(index) {
	return (is_user_connected(index) && p_VIP[index] == true && !(read_flags(f_VIP[index]) & VIP_FLAG_Z)) ? 1 : 0
}

print_message(id, msg[]) {
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}

public reload_vips(id,level,cid) {

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	read_config()
	for (new i=1; i <= MAXPLAYERS; i++) {
		if (is_user_connected(i)) {
			check_ini(i)
		}
	}
	console_print(id, "[AMXX] Reload vips comleted.");
	return PLUGIN_HANDLED

}