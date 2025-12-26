/*  
 * Admin Chat Plugin by faenix
 * Replaces original chat plugin with one that displays green admin names
 *
 * This plugin was edited for Botov-NET project
 * added VIP support and utf8 support
 * Copyring by AlexALX (c) 2015
 *
 * -------------
 *
 *  License of original plugin is unknown.
 *  My modifications are licensed under GNU GPL License.
 *
 *  If you are the author and want to clarify licensing, 
 *  please contact the repository owner.
 */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <engine>

#define VIP true

#if defined VIP
	#include <vip>
#endif

//new g_msgSayText
new funcType[32], funcCallType[32]
new normalChat[32] // handle recursiveness, to temporarily switch back to normal chat using /

new TeamInfo;
new SayText;

/*
enum Color
{
	YELLOW = 1, // Yellow
	GREEN, // Green Color
	TEAM_COLOR, // Red, grey, blue
	GREY, // grey
	RED, // Red
	BLUE // Blue
}*/

enum Color
{
	YELLOW = 1, // Yellow
	GREEN, // Green Color
	TEAM_COLOR, // Red, grey, blue
	GREY, // grey
	RED, // Red
	BLUE, // Blue
}

enum
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T,
	CS_TEAM_CT,
	CS_TEAM_SPECTATOR
};

new TeamName[][] =
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

#define MAXSLOTS 32
new MaxSlots;
new bool:IsConnected[MAXSLOTS + 1];
//new bool:death[32]

new g_playersTeam[33]

new bool:g_playersConnected[33]
new bool:g_playersAlive[33]

public plugin_init() {
	register_plugin("RussianChat", "1.2.6", "AlexALX")

	//register_concmd("amx_say", "adminSay", ADMIN_CHAT, "<text> - Displays colored admin message to all")
	//register_concmd("amx_chat", "adminChat", ADMIN_CHAT, "<text> - Displays colored message only to other admins")
	//register_concmd("amx_psay", "adminPSay", ADMIN_CHAT, "<name or #userid> <text> - Send a message to only one user")
	register_concmd("amx_namegreen", "toggleGreen", ADMIN_RCON, "<1 or 0> - Should regular chat of an admin be green")

	register_clcmd("say", "chatSay", 0, "!<text> - Displays colored admin message to all")
	register_clcmd("say_team", "chatTeamSay", 0, "!<text> - Diplays colored message only to you team")

	register_cvar("sv_namegreen", "1")

	//g_msgSayText = get_user_msgid("SayText")
	TeamInfo = get_user_msgid("TeamInfo");
	SayText = get_user_msgid("SayText");

	MaxSlots = get_maxplayers();
	RegisterHam(Ham_Killed, "player", "EventDeath");
	RegisterHam(Ham_Spawn, "player", "EventSpawn",1);
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")

	register_message(get_user_msgid("TeamInfo"), "msgTeamInfo")
}

#if !defined VIP
#define VIP_FLAG_C (1<<2)	// flag "c"
public get_vip_flags(index) {
	return false;
}
#endif

public event_newround() {
	new players[32], numPlayers
	get_players(players, numPlayers, "c")
	for (new i = 0; i <= numPlayers; i++) {
		if (is_user_connected(players[i]))
			set_task(0.2,"update_team",players[i])
	}
}

public client_putinserver(id)
{
	g_playersConnected[id] = true;
	IsConnected[id] = true;
	g_playersAlive[id] = false;
}

public client_disconnect(id)
{
	g_playersConnected[id] = false
	IsConnected[id] = false;
	g_playersAlive[id] = false;
}

public fwdSpawn(id)
{
	if (is_user_alive(id)) {
		g_playersAlive[id] = true
		new players[32], numPlayers
		get_players(players, numPlayers, "c")
		for (new i = 0; i <= numPlayers; i++) {
			if (is_user_connected(players[i]))
				set_task(0.2,"update_team",players[i])
		}
	}
}
public fwdKilled(id, idattacker, shouldgib)
{
	g_playersAlive[id] = false
	new players[32], numPlayers
	get_players(players, numPlayers, "c")
	for (new i = 0; i <= numPlayers; i++) {
		if (is_user_connected(players[i]))
			set_task(0.2,"update_team",players[i])
	}
}

public EventDeath( id , killer, shouldgib ) {

	g_playersAlive[id] = false
	new players[32], numPlayers
	get_players(players, numPlayers, "c")
	for (new i = 0; i <= numPlayers; i++) {
		if (is_user_connected(players[i]))
			set_task(0.2,"update_team",players[i])
	}
	return HAM_IGNORED;
}

public EventSpawn( id ) {

	if (is_user_alive(id)) {
		g_playersAlive[id] = true
		new players[32], numPlayers
		get_players(players, numPlayers, "c")
		for (new i = 0; i <= numPlayers; i++) {
			if (is_user_connected(players[i]))
				set_task(0.2,"update_team",players[i])
		}
	}
	return HAM_IGNORED;
}

#define OFFSET_TEAM 114
#define fm_get_user_team(%1) get_pdata_int(%1, OFFSET_TEAM)
new const g_teaminfo[][] =
{
	"UNASSIGNED",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}
public update_team(id)
{
	if(!is_user_connected(id))
		return

	static team
	team = fm_get_user_team(id)

	//if(team == CS_TEAM_T || team == CS_TEAM_CT)
	//{
	emessage_begin(MSG_ALL, TeamInfo)
	ewrite_byte(id)
	ewrite_string(g_teaminfo[team])
	emessage_end()
	//}

	//client_print(0,print_chat,"Team Update %i",g_teaminfo[team]);
}

public msgTeamInfo()
{
	new team[32], player
	get_msg_arg_string(2, team, 31)

	player = get_msg_arg_int(1)
	if (equal(team, "TERRORIST"))
		g_playersTeam[player] = 1
	else if (equal(team, "CT"))
		g_playersTeam[player] = 2
	else if (equal(team, "SPECTATOR"))
		g_playersTeam[player] = 0
	else
		g_playersTeam[player] = 0

	//client_print(0,print_chat,"Team %i",g_playersTeam[player]);
}
/*
public kills(id) {
	ExecuteHamB(Ham_CS_RoundRespawn, id);
	death[id] = true;
	user_kill(id);
}
*/

public showAdminChat(id) {
	new message[192], players[32], numPlayers, adminName[32]
	read_args(message, 191)
	remove_quotes(message)
	get_players(players, numPlayers, "c") // skip bots
	get_user_name(id, adminName, 31)

	new adminMsg[192]
	if (funcType[id] == 0) // called using say or amx_say
		format(adminMsg, 191, "^x01(ALL) ^x04%s ^x01: %s", adminName, message[funcCallType[id]])
	else // called using say_team or amx_chat
		format(adminMsg, 191, "^x01(ADMINS) ^x04%s ^x01: %s", adminName, message[funcCallType[id]])

	for (new i = 0; i <= numPlayers; i++) {
		if (!is_user_connected(players[i]))
			continue

		// if say_team or amx_chat, send only to other admins
		if (funcType[id] == 1 && !(get_user_flags(players[i]) & ADMIN_CHAT))
			continue

		message_begin(MSG_ONE, SayText, {0,0,0}, players[i])
		write_byte(players[i])
		write_string(adminMsg)
		message_end()
	}

	return PLUGIN_HANDLED_MAIN
}

public chatSay(id) {
	//if (!access(id, ADMIN_CHAT)) return PLUGIN_CONTINUE

	if (normalChat[id]) {
		normalChat[id] = 0
		return PLUGIN_CONTINUE
	}

	funcCallType[id] = 1 // function called with say
	funcType[id] = 0 // tell function we are sending message to all

	new chat[1],chats[10]
	read_argv(1, chat, 1)
	read_args(chats, 9)
	//if (chat[0] == '@' && access(id, ADMIN_CHAT)) {
	//	showAdminChat(id)
	//	return PLUGIN_HANDLED_MAIN
	//}

	//client_print(0, print_chat, "Steam error: 0x0%i0%i%i%i%i%i",random_num(0,1),random_num(0,9),random_num(0,9),random_num(0,9),random_num(0,9),random_num(0,9))
	//client_print(0, print_chat, "DEBUG Message: %s",chats)
	//return PLUGIN_HANDLED_MAIN

	if (get_cvar_num("sv_namegreen")) {
		if (((chat[0] == '!' || chats[0] == '!') || chats[0] == '>' && chats[1] == ' ' && chats[2] == '!') && (access(id, ADMIN_CHAT)||get_vip_flags(id) & VIP_FLAG_C)) {
				greenChat(id)
		} else {
			normChat(id)

			//new message[192]
			//read_args(message, 191)
			//remove_quotes(message)
			//normalChat[id] = 1
			//client_cmd(id, "say %s", message[1]) // recursive
			//return PLUGIN_HANDLED_MAIN
		}
		return PLUGIN_HANDLED_MAIN
	}

	return PLUGIN_CONTINUE
}

public chatTeamSay(id) {
	//if (!access(id, ADMIN_CHAT)) return PLUGIN_CONTINUE

	if (normalChat[id]) {
		normalChat[id] = 0
		return PLUGIN_CONTINUE
	}

	funcCallType[id] = 1 // function called with say
	funcType[id] = 1 // tell function we are sending message to all

	new chat[1],chats[10]
	read_argv(1, chat, 1)
	read_args(chats, 9)
	//if (chat[0] == '@' && access(id, ADMIN_CHAT)) {
	//	showAdminChat(id)
	//	return PLUGIN_HANDLED_MAIN
	//}

	//client_print(0, print_chat, "Steam error: 0x0%i0%i%i%i%i%i",random_num(0,1),random_num(0,9),random_num(0,9),random_num(0,9),random_num(0,9),random_num(0,9))
	//client_print(0, print_chat, "DEBUG Message: %s",chats)
	//return PLUGIN_HANDLED_MAIN

	if (get_cvar_num("sv_namegreen")) {
		if (((chat[0] == '!' || chats[0] == '!') || chats[0] == '>' && chats[1] == ' ' && chats[2] == '!') && (access(id, ADMIN_CHAT)||get_vip_flags(id) & VIP_FLAG_C)) {
				greenChat(id)
		} else {
			normChat(id)

			//new message[192]
			//read_args(message, 191)
			//remove_quotes(message)
			//normalChat[id] = 1
			//client_cmd(id, "say %s", message[1]) // recursive
			//return PLUGIN_HANDLED_MAIN
		}
		return PLUGIN_HANDLED_MAIN
	}

	return PLUGIN_CONTINUE
}

public adminSay(id, level, cid) {
	if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED_MAIN

	funcCallType[id] = 0 // function called with amx_say
	funcType[id] = 0 // tell function we are sending message to all
	showAdminChat(id)
	return PLUGIN_HANDLED_MAIN
}

public adminChat(id, level, cid) {
	if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED_MAIN

	funcCallType[id] = 0 // function called with amx_chat
	funcType[id] = 1 // tell function we are sending message only to admins
	showAdminChat(id)
	return PLUGIN_HANDLED_MAIN
}

public adminPSay(id, level, cid) {
	if (!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED_MAIN
	new name[32], length
	read_argv(1, name, 31)
	length = strlen(name) + 1

	new msgId = cmd_target(id, name, 0)
	if (!msgId) return PLUGIN_HANDLED_MAIN

	new message[192], msgToName[32], adminName[32]
	read_args(message, 191)
	format(message, 191, "%s", message[length])
	remove_quotes(message)
	get_user_name(msgId, msgToName, 31)
	get_user_name(id, adminName, 31)

	new showTo[192], showFrom[192]
	format(showTo, 191, "^x01(PRIVATE TO) ^x03%s ^x01: %s", msgToName, message)
	format(showFrom, 191, "^x01(PRIVATE FROM) ^x04%s ^x01: %s", adminName, message)

	message_begin(MSG_ONE, SayText, {0,0,0}, id)
	write_byte(id)
	write_string(showTo)
	message_end()

	message_begin(MSG_ONE, SayText, {0,0,0}, msgId)
	write_byte(msgId)
	write_string(showFrom)
	message_end()

	return PLUGIN_HANDLED_MAIN
}

public greenChat(id) {
	new adminMsg[192], message[192], players[32], numPlayers, adminName[32], adminTeam, isAlive
	read_args(message, 191)
	remove_quotes(message)
	replace_all(message, 191,"","")
	replace_all(message, 191,"","")
	replace_all(message, 191,"","")
	if (strlen(message) == 0) return PLUGIN_HANDLED_MAIN
	get_players(players, numPlayers, "c") // skip bots
	get_user_name(id, adminName, 31)
	isAlive = g_playersAlive[id]
	adminTeam = g_playersTeam[id]
	if (adminTeam == 3)
		adminTeam = 0;

	/*if ((get_user_team(id) != CS_TEAM_CT && get_user_team(id) != CS_TEAM_T)) {
		funcType[id] = 0;
	}*/

	if (funcType[id]) { // Sent a team message
		if (adminTeam == 1)
			format(adminMsg, 191, "^x01(Terrorist)")
		else if (adminTeam == 2)
			format(adminMsg, 191, "^x01(Counter-Terrorist)")
		else if (isAlive)
			format(adminMsg, charsmax(adminMsg), "^x01(Spectator)")
	}

	if (!isAlive) {
		if (adminTeam != 1 && adminTeam != 2) {
			if (funcType[id])
				format(adminMsg, 191, "^x01(Spectator)%s", adminMsg)
			else
				format(adminMsg, 191, "^x01*SPEC*%s", adminMsg)
		} else
			format(adminMsg, 191, "^x01*DEAD*%s", adminMsg)
	}
	replace_all(message, charsmax( message ), "%s", "%%s");
	new chat[2]
	read_argv(1, chat, 2)
	new i,t;
	if (chat[0] == '!' && (chat[1] == 'g'||chat[1] == 't') || message[0] == '!' && (message[1] == 'g'||message[1] == 't')) {
		if (message[1] == 't')
			t = 1;
		else
			t = 0;
		i = 2
	} else if (chat[0] == '!' || message[0] == '!') {
		i = 1
	} else {
		return PLUGIN_HANDLED_MAIN
	}
	if (strlen(message[i]) == 0) return PLUGIN_HANDLED_MAIN
	if (strlen(adminMsg) == 0) {
		if (i==2&&t==1) {
			format(adminMsg, 191, "^x01^x03%s :  %s", adminName, message[i])
		} else if(i==2&&t==0) {
			format(adminMsg, 191, "^x01^x04%s :  %s", adminName, message[i])
		} else {
			format(adminMsg, 191, "^x01^x04%s ^x01:  %s", adminName, message[i])
		}
	} else {
		if (i==2&&t==1) {
			format(adminMsg, 191, "^x01%s ^x03%s :  %s", adminMsg, adminName, message[i])
		} else if(i==2&&t==0) {
			format(adminMsg, 191, "^x01%s ^x04%s :  %s", adminMsg, adminName, message[i])
		} else {
			format(adminMsg, 191, "^x01%s ^x04%s ^x01:  %s", adminMsg, adminName, message[i])
		}
	}

	new copymsg[256]
	format(copymsg, 255, "%s", adminMsg)
	remove_quotes(copymsg)
	replace_all(copymsg, 255,"^x01","")
	replace_all(copymsg, 255,"^x03","")
	replace_all(copymsg, 255,"^x04","")
	for (new i = 0; i <= numPlayers; i++) {
		if (!is_user_connected(players[i]))
			continue

		//if (isAlive != is_user_alive(players[i]) && !access(players[i], ADMIN_CHAT))
		//	continue

		if (funcType[id] == 1 && g_playersTeam[players[i]] != adminTeam && !access(players[i], ADMIN_CHAT))
			continue

		message_begin(MSG_ONE, SayText, {0,0,0}, players[i])
		write_byte(players[i])
		write_string(adminMsg)
		message_end()
		console_print(players[i], "[chat] %s (utf8)", copymsg)
	}
	log_amx("%s", copymsg)
	return PLUGIN_HANDLED_MAIN
}

public normChat(id) {
	new adminMsg[256], message[256], players[32], numPlayers, adminName[32], adminTeam, isAlive
	read_argv(0, message, charsmax(message))
	read_args(message, charsmax(message))
	remove_quotes(message)
	replace_all(message, charsmax(message),"","")
	replace_all(message, charsmax(message),"","")
	replace_all(message, charsmax(message),"","")
	if (strlen(message) == 0) return PLUGIN_HANDLED_MAIN
	get_players(players, numPlayers, "c") // skip bots
	get_user_name(id, adminName, 31)
	isAlive = g_playersAlive[id]
	adminTeam = g_playersTeam[id]
	if (adminTeam == 3)
		adminTeam = 0;

	new msgFlag = 0

	if (funcType[id])
		msgFlag |= adminTeam
	//else
	if (funcType[id]&&adminTeam == 0)
		msgFlag = 3
	else if(adminTeam == 0)
		msgFlag = 0

	if (!isAlive && (adminTeam == 1||adminTeam == 2)) //(1 <= adminTeam <= 2)
		msgFlag |= 4

	if (!isAlive && adminTeam != 1 && adminTeam != 2)
	{
		if (funcType[id])
			msgFlag = 3
		else
			msgFlag = 7
	}

	static const messages[8][] =
	{
		"#Cstrike_Chat_All",
		"#Cstrike_Chat_T",
		"#Cstrike_Chat_CT",
		"#Cstrike_Chat_Spec",
		"#Cstrike_Chat_AllDead",
		"#Cstrike_Chat_T_Dead",
		"#Cstrike_Chat_CT_Dead",
		"#Cstrike_Chat_AllSpec"
	}

	if (funcType[id]) { // Sent a team message
		if (adminTeam == 1)
			format(adminMsg, charsmax(adminMsg), "(Terrorist)")
		else if (adminTeam == 2)
			format(adminMsg, charsmax(adminMsg), "(Counter-Terrorist)")
		else if (isAlive)
			format(adminMsg, charsmax(adminMsg), "(Spectator)")
	}

	if (!isAlive) {
		if (adminTeam != 1 && adminTeam != 2) {
			if (funcType[id])
				format(adminMsg, charsmax(adminMsg), "(Spectator)%s", adminMsg)
			else
				format(adminMsg, charsmax(adminMsg), "*SPEC*%s", adminMsg)
		} else
			format(adminMsg, charsmax(adminMsg), "*DEAD*%s", adminMsg)
	}

	if (strlen(adminMsg) == 0)
		format(adminMsg, charsmax(adminMsg), "%s : %s", adminName, message)
	else
		format(adminMsg, charsmax(adminMsg), "%s %s : %s", adminMsg, adminName, message)
	//replace_all(message, charsmax( message ), "%s", "%%s");
	remove_quotes(adminMsg)

	for (new i = 0; i <= numPlayers; i++) {
		if (!is_user_connected(players[i]))
			continue

		//if (isAlive != is_user_alive(players[i]) && !access(players[i], ADMIN_CHAT))
		//	continue

		if (funcType[id] == 1 && g_playersTeam[players[i]] != adminTeam && !access(players[i], ADMIN_CHAT))
			continue

		message_begin(MSG_ONE, SayText, _, players[i])
		write_byte(id)
		write_string(messages[msgFlag])
		write_string("")
		write_string(message)
		message_end()
		console_print(players[i], "[chat] %s (utf8)", adminMsg)
	}
	log_amx("%s", adminMsg)
	return PLUGIN_HANDLED_MAIN
}

/*
public task_say_console(arr[],player) {
	if (!is_user_connected(player))
		return PLUGIN_HANDLED;

	console_print(player, "[chat] %s (utf8)", arr)
	return PLUGIN_HANDLED;
}

public task_say_red(arr[],player) {
	if (!is_user_connected(player))
		return PLUGIN_HANDLED;

	ColorChat(player, RED, "%s", arr);
	return PLUGIN_HANDLED;
}

public task_say_blue(arr[],player) {
	if (!is_user_connected(player))
		return PLUGIN_HANDLED;

	ColorChat(player, BLUE, "%s", arr);
	return PLUGIN_HANDLED;
}

public task_say_grey(arr[],player) {
	if (!is_user_connected(player))
		return PLUGIN_HANDLED;

	ColorChat(player, GREY, "%s", arr);
	return PLUGIN_HANDLED;
}*/

public toggleGreen(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN
	new val[1], numval
	read_argv(1,val,1)
	numval = str_to_num(val)
	set_cvar_num("sv_namegreen", numval)

	if (numval == 0)
		console_print(id, "[AMXX] Green admin names have been turned off")
	else if (numval == 1)
		console_print(id, "[AMXX] Green admin names is now enabled")

	return PLUGIN_HANDLED_MAIN
}

public ColorChat(id, Color:type, const msg[], {Float,Sql,Result,_}:...)
{
	static message[256];

	switch(type)
	{
		case YELLOW: // Yellow
		{
			message[0] = 0x01;
		}
		case GREEN: // Green
		{
			message[0] = 0x04;
		}
		default: // White, Red, Blue
		{
			message[0] = 0x03;
		}
	}

	vformat(message[1], 251, msg, 4);

	// Make sure message is not longer than 192 character. Will crash the server.
	message[192] = '^0';

	new team, ColorChange, index, MSG_Type;

	if(!id)
	{
		index = FindPlayer();
		MSG_Type = MSG_ALL;

	} else {
		MSG_Type = MSG_ONE;
		index = id;
	}

	team = get_user_team(index);
	ColorChange = ColorSelection(index, MSG_Type, type);

	ShowColorMessage(index, MSG_Type, message);

	if(ColorChange)
	{
		Team_Info(index, MSG_Type, TeamName[team]);
	}
}

ShowColorMessage(id, type, message[])
{
	message_begin(type, SayText, _, id);
	write_byte(id)
	write_string(message);
	message_end();
}

Team_Info(id, type, team[])
{
	message_begin(type, TeamInfo, _, id);
	write_byte(id);
	write_string(team);
	message_end();

	return 1;
}

ColorSelection(index, type, Color:Type)
{
	switch(Type)
	{
		case RED:
		{
			return Team_Info(index, type, TeamName[1]);
		}
		case BLUE:
		{
			return Team_Info(index, type, TeamName[2]);
		}
		case GREY:
		{
			return Team_Info(index, type, TeamName[3]);
		}
	}

	return 0;
}

FindPlayer()
{
	new i = -1;

	while(i <= MaxSlots)
	{
		if(IsConnected[++i])
		{
			return i;
		}
	}

	return -1;
}