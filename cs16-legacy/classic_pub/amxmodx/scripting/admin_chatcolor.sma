/* * * * * * * * * * * * * * * * * * * * * * * *
 *   Admin_chatcolor, by BlueRaja (AMX Mod X)  *
 *                                             * 
 * Modified for Botov-NET project              *
 * Added VIP support                           *
 * Copyring by AlexALX (c) 2015                *
 *                                             *
 *      Special thanks to Damaged Soul         *
 * - not just for helping me when I needed it, *
 *    but for putting up with all my shit ^_^  *
 *                                             *
 *************I hate asterisks.*****************
 *                                             *
 *           (c) Copyright 2005                *
 * This file is provided as is (no warranties) *
 * * * * * * * * * * * * * * * * * * * * * * * */

//Use !T for team-color (sorry, can't use red when on CT, and vice-versa)
//!G for green, and !W for normal (it's more of a tan than a white...)


//Includes
#include <amxmodx>
#include <cstrike>
#include <vip>

//Defines
#if defined ACCESS_LEVEL
	#undef ACCESS_LEVEL
#endif
//#define ACCESS_LEVEL ADMIN_CHAT	//UNCOMMENT THIS LINE to allow only admins (with ADMIN_CHAT) to use colors

//Messages
new gmsgSayText

//Globals


//Initialization
public plugin_init()
{
	gmsgSayText = get_user_msgid("SayText")
	register_clcmd("say", "CatchSay")
	register_clcmd("say_team", "CatchSay")
	register_plugin("Admin Chat Color","1.0","BlueRaja")
	return PLUGIN_CONTINUE
}

//Functions
public CatchSay(id)
{
	//#if defined ACCESS_LEVEL

	//#endif

	if( !(get_user_flags(id)&ADMIN_CHAT) && !(get_vip_flags(id)&VIP_FLAG_C)) return PLUGIN_CONTINUE

	new message[129]
	read_argv(1,message,128)

	if ( containi(message,"!t")==-1 &&
	     containi(message,"!w")==-1 &&
	     containi(message,"!g")==-1 )
	{
		return PLUGIN_CONTINUE
	}

	new szCommand[9]
	read_argv(0,szCommand,8)

	new CsTeams:team = cs_get_user_team(id)
	new isAlive = is_user_alive(id)

	new playerList[32]//players to send message to
	new playerCount

	new message_to_send[129] = "^x01"

	new szFlags[4] = ""
	if(isAlive){
		add(szFlags,3,"a")//Only alive players
	} else {
		add(szFlags,3,"b")//Only dead players
		add(message_to_send,128,"*DEAD*")
	}
	add(szFlags,3,"c")//skip bots

	if(equal(szCommand,"say_team")) {
		add(szFlags,3,"e")//Match with passed teamname
		if(team==CS_TEAM_T){
			get_players(playerList,playerCount,szFlags,"TERRORIST")
			add(message_to_send,128,"(Terrorist) ^x03")
		} else if(team==CS_TEAM_CT) {
			get_players(playerList,playerCount,szFlags,"CT")
			add(message_to_send,128,"(Counter-terrorist) ^x03")
		} else { //assume Spectator
			get_players(playerList,playerCount,szFlags,"SPECTATOR")
			add(message_to_send,128,"(Spectator) ^x03")
		}
	} else { //assume "say"
		get_players(playerList,playerCount,szFlags)
		if(isAlive)
		{
			add(message_to_send,128,"^x03")
		} else {
			add(message_to_send,128," ^x03")
		}
	}

	new username[129]
	get_user_name(id,username,128)
	add(message_to_send,128,username)
	add(message_to_send,128,"^x01 :  ")

	add( message_to_send,128,message,(128-strlen(message_to_send)) )

	while(containi(message_to_send,"!t") != -1)
	{
		replace(message_to_send,128,"!T","^x03")
		replace(message_to_send,128,"!t","^x03")
	}
	while(containi(message_to_send,"!g") != -1)
	{
		replace(message_to_send,128,"!G","^x04")
		replace(message_to_send,128,"!g","^x04")
	}
	while(containi(message_to_send,"!w") != -1)
	{
		replace(message_to_send,128,"!W","^x01")
		replace(message_to_send,128,"!w","^x01")
	}


	for(new i=0; i<playerCount; i++)
	{
		message_begin(MSG_ONE, gmsgSayText, {0,0,0}, playerList[i])
		write_byte(playerList[i])
		write_string(message_to_send)
		message_end()
	}

	return PLUGIN_HANDLED
}