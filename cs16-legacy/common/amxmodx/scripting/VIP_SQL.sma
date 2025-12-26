/*  
 * This plugin was created for Botov-NET Project
 * This makes custom VIP system MySQL Version - for php-fusion v6.01 plugin
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
//#include <cstrike>
#include <unixtime>
//#include <hamsandwich>
#include <sqlx>

#define PLUGIN "VIP users"
#define VERSION "2.0.0"
#define AUTHOR "AlexALX"

#define DB_VIPS "fusion_csvips"
#define DB_SETTINGS "fusion_csvips_set"
#define DB_SES "fusion_csvips_ses"
#define URL_PREFIX "http://botov.net.ua"

#define MAXPLAYERS 33
#define DELAY_CHECK_VIP 300.0 // seconds

new amx_vip_field
new bool:p_VIP[MAXPLAYERS]
new t_VIP[MAXPLAYERS][32]
new f_VIP[MAXPLAYERS][32]
new o_VIP[MAXPLAYERS][32]
new s_VIP[MAXPLAYERS]
new tp_VIP[MAXPLAYERS]
new v_VIP[MAXPLAYERS]
new gmsgSayText

#define CLEAN_SES_ID 453513

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

new VIP_TYPE[3][32] = {"Name","SteamID","IP"};

new bool:vip_enabled=false,bool:amx_free_vip=false,amx_free_vipt,amx_vip_server;

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
	amx_vip_server = register_cvar("amx_vip_server", "0")

}

public plugin_natives()
{
	register_library("vip")
	register_native("is_user_vip", "is_user_vip", 1)
	register_native("get_vip_flags", "get_vip_flags", 1)
	register_native("get_sysvip_flags", "get_sysvip_flags", 1)
	register_native("get_vip_options", "get_vip_options", 1)
}

public plugin_cfg() {
	set_task(0.5, "SQL_Init_Connect")
	set_task(0.7, "reload_vips", -1)
}

new Handle:g_h_Sql, Handle:g_h_Sql_Connect, bool:g_b_Connected_SQL = false

public SQL_Init_Connect()
{
    new s_Error[128], i_Error

    g_h_Sql = SQL_MakeDbTuple("localhost", "dbuser", "dbpass", "dbname")

    g_h_Sql_Connect = SQL_Connect(g_h_Sql, i_Error, s_Error, charsmax(s_Error))

    if (g_h_Sql_Connect == Empty_Handle)
    {
        server_print("Can't connect to MySQL, error: %s", s_Error)
        return PLUGIN_HANDLED
    }
    else
        g_b_Connected_SQL = true

    if (g_b_Connected_SQL) {
		set_task(360.0,"clean_ses2",CLEAN_SES_ID,_,_,"b");
    }

    return PLUGIN_CONTINUE
}

public plugin_end()
{
    clean_ses()
    remove_task(CLEAN_SES_ID)
    SQL_FreeHandle(g_h_Sql_Connect)
    SQL_FreeHandle(g_h_Sql)
}

public SQL_Settings()
{
    if (g_b_Connected_SQL)
    {
        new Handle:h_Query, s_Error[128];

        h_Query = SQL_PrepareQuery(g_h_Sql_Connect, "SELECT * FROM %s", DB_SETTINGS)

        if (!SQL_Execute(h_Query))
        {
            SQL_QueryError(h_Query, s_Error, charsmax(s_Error))
            server_print("Can't execute MySQL query, error: %s", s_Error)
        }
        else
        {
            new enabled, servers[32], free_vip, free_vipt;

            while (SQL_MoreResults(h_Query))
            {
                enabled = SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "enabled"))
                SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "servers"), servers, charsmax(servers))
                free_vip = SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "free_vip"))
                free_vipt = SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "free_vipt"))

                new server[32],serv = get_pcvar_num(amx_vip_server);
                format(server, charsmax(servers), ".%d.", serv)

                if (enabled==0||serv==0) {
					vip_enabled = false;
                } else {
					vip_enabled = true;
					if (free_vip==1&&free_vipt>0&&contain(servers,server)!=-1) {
						amx_free_vip = true;
						amx_free_vipt = free_vipt;
					}
                }

                SQL_NextRow(h_Query)
            }

            SQL_FreeHandle(h_Query)
        }
        clean_ses();
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
	o_VIP[id] = "z"
	s_VIP[id] = -1;
	tp_VIP[id] = 0;
	v_VIP[id] = 0;
}

public client_authorized(id) {
	set_task(0.2, "check_ini", id)
}

public client_disconnect(id) {
	if (v_VIP[id]>0) remove_ses(v_VIP[id]);
	p_VIP[id] = false
	t_VIP[id] = "0"
	f_VIP[id] = "z"
	o_VIP[id] = "z"
	s_VIP[id] = -1;
	tp_VIP[id] = 0;
	v_VIP[id] = 0;
}

public client_infochanged(id) {
	if (v_VIP[id]>0) remove_ses(v_VIP[id])
	set_task(0.1, "check_ini", id)
}

public check_inif(id) {

	if(!is_user_connected(id))
		return PLUGIN_HANDLED_MAIN

	if (get_systime() <= amx_free_vipt) {
		p_VIP[id] = true
		num_to_str(amx_free_vipt,t_VIP[id],31)
		f_VIP[id] = "cu"
		o_VIP[id] = "z"
		s_VIP[id] = 1
		tp_VIP[id] = 0;
		v_VIP[id] = 0;
	} else {
		p_VIP[id] = false
		t_VIP[id] = "0"
		f_VIP[id] = "z"
		o_VIP[id] = "z"
		s_VIP[id] = -1
		tp_VIP[id] = 0;
		v_VIP[id] = 0;
	}

	return PLUGIN_CONTINUE

}

public check_inis(id) {

	if(!is_user_connected(id))
		return PLUGIN_HANDLED_MAIN

	check_ini(id,true);
	return PLUGIN_CONTINUE;
}

public check_ini(id,bool:nomsg) {

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
	o_VIP[id] = "z"
	s_VIP[id] = -1
	tp_VIP[id] = 0;
	v_VIP[id] = 0;
	//new szLine = line
	//while(read_file(szFile, line ++ , szLine , 100 , len)) {

	if (vip_enabled!=true)
		return PLUGIN_HANDLED;

	if (amx_free_vip==true) {
		check_inif(id)
	}

	if (g_b_Connected_SQL)
	{
        new Handle:h_Query, s_Error[128];

        h_Query = SQL_PrepareQuery(g_h_Sql_Connect, "SELECT vid,type,name,password,time,flags,options,status FROM %s WHERE server='0' OR server='%d'", DB_VIPS, get_pcvar_num(amx_vip_server))

        if (!SQL_Execute(h_Query))
        {
            SQL_QueryError(h_Query, s_Error, charsmax(s_Error))
            server_print("Can't execute MySQL query, error: %s", s_Error)
        }
        else
        {
            new password[32], passfield[32], name[32], steamid[32], ip[32];
            get_user_name(id, name, 31)
            get_user_authid(id, steamid, 31)
            get_pcvar_string(amx_vip_field, passfield, 31)
            get_user_info(id, passfield, password, 31)
            get_user_ip(id, ip, 31, 1)

            new text[32],pass[32],type,time[32],status,vid;

            while (SQL_MoreResults(h_Query))
            {
                SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "name"), text, charsmax(text))
                SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "password"), pass, charsmax(pass))
                type = SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "type"))
                status = SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "status"))
                SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "time"), time, charsmax(time))
                vid = SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "vid"))

                if ((type==0 && equali(text,name) && equal(pass,password)
				|| type==1 && equal(text,steamid) && (equal(pass,"") || equal(pass,password))
				|| type==2 && equal(text,ip) && equal(pass,password)) && (type==1||nomsg||check_ses(vid,false))) {
					if (status==1) {
						if (equal(time, "0") || get_systime() <= str_to_num(time)) {
							p_VIP[id] = true
							t_VIP[id] = time
							SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "flags"), f_VIP[id], 31)
							SQL_ReadResult(h_Query, SQL_FieldNameToNum(h_Query, "options"), o_VIP[id], 31)
							s_VIP[id] = status
							tp_VIP[id] = type
							if (type!=1) {
								v_VIP[id] = vid;
								insert_ses(vid,ip)
							}
							if (!nomsg) {
								log_amx("Login: ^"%s<%d><%d>^" vip (account type ^"%s^") (flags ^"%s^") (address ^"%s^")", name, get_user_userid(id), status, VIP_TYPE[type], f_VIP[id], ip)
								client_cmd(id, "echo ^"* VIP Autorized^"");
							}
						} else {
							p_VIP[id] = false
							t_VIP[id] = time
							f_VIP[id] = "z"
							o_VIP[id] = "z"
							s_VIP[id] = status
							tp_VIP[id] = type
							v_VIP[id] = 0
							if (!nomsg) {
								log_amx("Unactive login: ^"%s<%d><%d>^" vip (account type ^"%s^") (flags ^"%s^") (address ^"%s^")", name, get_user_userid(id), status, VIP_TYPE[type], f_VIP[id], ip)
								client_cmd(id, "echo ^"* Warning: VIP Expired^"");
							}
						}
					} else {
						p_VIP[id] = false
						t_VIP[id] = time
						f_VIP[id] = "z"
						o_VIP[id] = "z"
						s_VIP[id] = status
						tp_VIP[id] = type
						v_VIP[id] = 0
						if (!nomsg) log_amx("Unactive login: ^"%s<%d><%d>^" vip (account type ^"%s^") (flags ^"%s^") (address ^"%s^")", name, get_user_userid(id), status, VIP_TYPE[type], f_VIP[id], ip)
					}
                }
                /*if (!is_user_bot(id) && status==1 && (!equal(pass, "")&&type==1||type!=1) && !equal(pass, password) ) {
					server_cmd("kick #%d You password for VIP is incorrect. Ваш пароль для VIP не правильный.",get_user_userid(id))
					return PLUGIN_HANDLED_MAIN
                }*/

                SQL_NextRow(h_Query)
            }

            SQL_FreeHandle(h_Query)
        }
	}
	remove_task(id)
	set_task(DELAY_CHECK_VIP, "check_inis", id)

	return PLUGIN_CONTINUE

}

public insert_ses(vid,ip[]) {
	if (vid>0 && g_b_Connected_SQL)
	{
		new Handle:h_Query, s_Error[128];
		if (check_ses(vid,true)) {
 			h_Query = SQL_PrepareQuery(g_h_Sql_Connect, "INSERT INTO %s VALUES('%d','%d','%s','%d')",DB_SES,vid,get_pcvar_num(amx_vip_server),ip,get_systime())
	 		if (!SQL_Execute(h_Query))
	        {
	        	SQL_QueryError(h_Query, s_Error, charsmax(s_Error))
	        	server_print("Can't execute MySQL query, error: %s", s_Error)
	 		} else {
	        	SQL_FreeHandle(h_Query)
	 		}
 		} else {
	 		h_Query = SQL_PrepareQuery(g_h_Sql_Connect, "UPDATE %s SET date='%d', ip='%s' WHERE vid='%d'",DB_SES,get_systime(),ip,vid)
	 		if (!SQL_Execute(h_Query))
	        {
	        	SQL_QueryError(h_Query, s_Error, charsmax(s_Error))
	        	server_print("Can't execute MySQL query, error: %s", s_Error)
	 		} else {
	        	SQL_FreeHandle(h_Query)
	 		}
 		}
 	}
}

public bool:check_ses(vid,bool:insert) {
	new bool:ret = false;
	if (insert) ret = true;
	if (vid>0 && g_b_Connected_SQL)
    {
        new Handle:h_Query, s_Error[128];

        h_Query = SQL_PrepareQuery(g_h_Sql_Connect, "SELECT * FROM %s WHERE vid='%d'", DB_SES, vid)

        if (!SQL_Execute(h_Query))
        {
            SQL_QueryError(h_Query, s_Error, charsmax(s_Error))
            server_print("Can't execute MySQL query, error: %s", s_Error)
            if (insert) ret = true;
            else ret = false;
        }
        else
        {
            if (SQL_NumResults(h_Query)!=0) {
				ret = false;
            } else {
				ret = true;
            }
            SQL_FreeHandle(h_Query)
        }
	}
	return ret;
}

public remove_ses(vid) {
	if (vid>0 && g_b_Connected_SQL)
    {
        new Handle:h_Query, s_Error[128];

        h_Query = SQL_PrepareQuery(g_h_Sql_Connect, "DELETE FROM %s WHERE vid='%d'", DB_SES, vid)

        if (!SQL_Execute(h_Query))
        {
            SQL_QueryError(h_Query, s_Error, charsmax(s_Error))
            server_print("Can't execute MySQL query, error: %s", s_Error)
        }
        else
        {
            SQL_FreeHandle(h_Query)
        }
	}
}

public clean_ses2() {
	if (g_b_Connected_SQL)
    {
        new Handle:h_Query, s_Error[128];

        h_Query = SQL_PrepareQuery(g_h_Sql_Connect, "DELETE FROM %s WHERE date<='%d'", DB_SES, get_pcvar_num(amx_vip_server), get_systime()-60*6)

        if (!SQL_Execute(h_Query))
        {
            SQL_QueryError(h_Query, s_Error, charsmax(s_Error))
            server_print("Can't execute MySQL query, error: %s", s_Error)
        }
        else
        {
            SQL_FreeHandle(h_Query)
        }
	}
}

public clean_ses() {
	if (g_b_Connected_SQL)
    {
        new Handle:h_Query, s_Error[128];

        h_Query = SQL_PrepareQuery(g_h_Sql_Connect, "DELETE FROM %s WHERE server='%d' OR date<='%d'", DB_SES, get_pcvar_num(amx_vip_server), get_systime()-60*7)

        if (!SQL_Execute(h_Query))
        {
            SQL_QueryError(h_Query, s_Error, charsmax(s_Error))
            server_print("Can't execute MySQL query, error: %s", s_Error)
        }
        else
        {
            SQL_FreeHandle(h_Query)
        }
	}
}

public get_vip_flags(id) {
	if (is_user_vip(id)) {
		return read_flags(f_VIP[id])
	}
	return VIP_FLAG_Z
}

public get_vip_options(id) {
	if (get_vip_flags(id)&VIP_FLAG_F) {
		return read_flags(o_VIP[id])
	}
	return VIP_FLAG_Z
}

public get_sysvip_flags(id) {
		return read_flags(f_VIP[id])
}

public user_vip(id) {

	new msg[92]
	if (vip_enabled==false) {
		formatex(msg, 91, "^x04%L", id, "YOU_DVIP")
		print_message(id,msg)
		return PLUGIN_CONTINUE
	}

	if (is_user_vip(id)) {
		new iMonth, iDay, iYear, iHour, iMinute, iSecond
		new date[32]
		UnixToTime( str_to_num(t_VIP[id])+7200 , iYear , iMonth , iDay , iHour , iMinute , iSecond )
		if (equal(t_VIP[id],"0"))
			formatex(date, 31, "^x01%L",id,"VIP_UNL")
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
		if (s_VIP[id]==1&&!equal(t_VIP[id],"0")&&!equal(t_VIP[id],"-1")) {
			new iMonth2, iDay2, iYear2, iHour2, iMinute2, iSecond2
			new date2[32]
			UnixToTime( str_to_num(t_VIP[id]) , iYear2 , iMonth2 , iDay2 , iHour2 , iMinute2 , iSecond2 )
			formatex(date2, 31, "^x01%02d/%02d/%02d %02d:%02d", iDay2,iMonth2,iYear2,iHour2,iMinute2)
			formatex(msg, 91, "^x04%L", id, "YOU_EVIP",date2)
			print_message(id,msg)
		} else if (s_VIP[id]==0) {
			formatex(msg, 91, "^x04%L", id, "YOU_FVIP")
			print_message(id,msg)
		} else if (s_VIP[id]==2) {
			formatex(msg, 91, "^x04%L", id, "YOU_BVIP")
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
	if (vip_enabled==false) {
		new msg[92]
		formatex(msg, 91, "^x04%L", id, "YOU_DVIP")
		print_message(id,msg)
		return PLUGIN_CONTINUE
	}
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
			if(is_user_vip(id))
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

	new szFiles[512]
	formatex(szFiles,511,"<html> \
	<head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'> \
	<META HTTP-EQUIV='refresh' CONTENT='0; URL=%s/infusions/vips/motd.php?server=%d'> \
		<style type='text/css'> \
			pre \
			{ \
				font-family:Verdana,Tahoma; \
				color:#FFF; \
			} \
			body \
			{ \
				background:#000; \
				margin-left:8px; \
				margin-top:0px; \
			} \
		</style> \
	</head> \
	<body> \
	</body> \
</html>",URL_PREFIX,get_pcvar_num(amx_vip_server))
	show_motd(id, szFiles, "VIP Info")

	return PLUGIN_CONTINUE

}

public commands_vip(id) {

	new szFiles[512]
	formatex(szFiles,511,"<html> \
	<head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'> \
	<META HTTP-EQUIV='refresh' CONTENT='0; URL=%s/infusions/vips/motd.php?commands=%d'> \
		<style type='text/css'> \
			pre \
			{ \
				font-family:Verdana,Tahoma; \
				color:#FFF; \
			} \
			body \
			{ \
				background:#000; \
				margin-left:8px; \
				margin-top:0px; \
			} \
		</style> \
	</head> \
	<body> \
	</body> \
</html>",URL_PREFIX,get_pcvar_num(amx_vip_server))
	show_motd(id, szFiles, "VIP Commands")

	return PLUGIN_CONTINUE

}

public is_user_vip(index) {
	return (is_user_connected(index) && p_VIP[index] == true && !(read_flags(f_VIP[index]) & VIP_FLAG_Z)) ? 1 : 0
}

print_message(id, msg[]) {
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}

public reload_vips(id,level,cid) {

	if(id>0&&!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	SQL_Settings()
	for (new i=1; i <= MAXPLAYERS; i++) {
		if (is_user_connected(i)) {
			check_ini(i,false)
		}
	}
	if (id!=-1) console_print(id, "[AMXX] Reload vips comleted.");
	return PLUGIN_HANDLED

}