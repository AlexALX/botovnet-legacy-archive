/*	Copyright © 2008, ConnorMcLeod

 * This plugin was modified for Botov-NET Project
 * Support for biohazard mod and VIPS system

 * Copyring by AlexALX (c) 2015

	Custom Flashligh is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Custom Flashligh; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

/*
* v0.5.4 (10.20.09)
* attempt to fix the bug when you can re-activate fl when empty
*
* v0.5.3 (09/01/09)
* -fixed little errors due to version change
* -added player range check in death event
*
* v0.5.2 (07/23/09)
* -fixed inverted teams colors
*
* v0.5.1 (04/04/09)
* -haven't realised i can remove FM include
*
* v0.5.0 (04/03/09)
* - use register_think instead of FM_CmdStart
* - use client_PreThink instead of FM_PlayerPreThink
* - use get_user_origin mode 1 and 3 instead of fakemeta stock
* - replaced some FM natives+enums with amxx natives (emit_sound, write_coord)
*
* v0.4.0 (07/27/08)
* - replaced cvars with commands
* - .ini file now supports prefix/per map configs
*
* v0.3.1 (06/29/08)
* - fixed bug when you could have seen normal flashlight
*
* v0.3.0 (06/21/08)
*
* - some code optimizations (thanks to simon logic and jim_yang)
* - changes cvars flashlight_drainfreq and flashlight_chargefreq to
*  flashlight_fulldrain_time and flashlight_fullcharge_time
*  (simon logic suggestion)
* - moved random colors into $CONFIGSDIR/flashlight_colors.ini
*
* v0.2.0
* First public release
*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <biohazard>
#include <money_ul>
#include <hamsandwich>
#include <vip>

#define PLUGIN "Custom Flashlight"
#define AUTHOR "ConnorMcLeod & AlexALX"
#define VERSION "0.5.4"

/* **************************** CUSTOMIZATION AREA ******************************** */

new const SOUND_FLASHLIGHT_ON[] = "items/flashlight1.wav"
new const SOUND_FLASHLIGHT_OFF[] = "items/flashlight1.wav"

#define LIFE	1	// try 2 if light is flickering

/* ******************************************************************************** */

enum
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T,
	CS_TEAM_CT,
	CS_TEAM_SPECTATOR
}

#define MAX_PLAYERS	32

enum {
	Red,
	Green,
	Blue
}

new Array:g_aColors
new g_iColorsNum

new g_iMaxPlayers

new bool:g_bFlashLight[MAX_PLAYERS+1]
new bool:g_dFlashLight[MAX_PLAYERS+1]
new bool:g_cFlashLight[MAX_PLAYERS+1]
new g_iFlashBattery[MAX_PLAYERS+1]
new Float:g_flFlashLightTime[MAX_PLAYERS+1]
//new bool:g_cFlashLight[MAX_PLAYERS+1]

new g_iColor[MAX_PLAYERS+1][3]
//new g_iTeamColor[2][3]

new g_msgidFlashlight, g_msgidFlashBat

new g_bEnabled = true
new g_iShowAll = 1
new g_iColorType = 0
new g_iAttenuation = 5
new g_iDistanceMax = 2000

// Стандартный фонарик
new g_sColor[3] = {48,32,14};
new g_sRadius = 7
new Float:g_sflDrain = 0.45 // 1.2
new Float:g_sflCharge = 10000.0 // 0.2
new g_batcost // 50

// Улученный фонарик
new g_bColor[3] = {192,192,192};
new g_bRadius = 9
new Float:g_bflDrain = 1.3 // 1.2
new Float:g_bflCharge = 10000.0 // 0.2
new g_bflashcost // 100

// Цветной фонарик
new g_cRadius = 9
new Float:g_cflDrain = 1.0 // 1.2
new Float:g_cflCharge = 10000.0 // 0.2
new g_cflashcost // 150

const KEYS_M = MENU_KEY_0 | MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9;

public plugin_precache()
{
	precache_sound(SOUND_FLASHLIGHT_ON)
	precache_sound(SOUND_FLASHLIGHT_OFF)
}

public plugin_init()
{
	register_plugin( PLUGIN, VERSION, AUTHOR )

	g_batcost = register_cvar("amx_flc_batcost", "50")
	g_cflashcost = register_cvar("amx_flc_ccost", "150")
	g_bflashcost = register_cvar("amx_flc_bcost", "100")

	//register_concmd("flashlight_set", "plugin_settings", ADMIN_CFG)

	register_impulse(100, "Impulse_100")

	register_menucmd( register_menuid( "Flashlight" ), KEYS_M, "menu_shop" )
	register_clcmd( "say buy_colorflashlight", "ColorFlashLight" );
	register_clcmd( "say buy_cfl", "ColorFlashLight" );
	register_clcmd( "say buy_flashlight", "BuyFlashLight" );
	register_clcmd( "say buy_fl", "BuyFlashLight" );
	register_clcmd( "say buy_batteryflashlight", "BatteryFlashLight" );
	register_clcmd( "say buy_bfl", "BatteryFlashLight" );
	register_clcmd( "say /buy_colorflashlight", "ColorFlashLight" );
	register_clcmd( "say /buy_cfl", "ColorFlashLight" );
	register_clcmd( "say /buy_flashlight", "BuyFlashLight" );
	register_clcmd( "say /buy_fl", "BuyFlashLight" );
	register_clcmd( "say /buy_batteryflashlight", "BatteryFlashLight" );
	register_clcmd( "say /buy_bfl", "BatteryFlashLight" );
	register_clcmd( "buy_colorflashlight", "ColorFlashLight" );
	register_clcmd( "buy_cfl", "ColorFlashLight" );
	register_clcmd( "buy_flashlight", "BuyFlashLight" );
	register_clcmd( "buy_fl", "BuyFlashLight" );
	register_clcmd( "buy_batteryflashlight", "BatteryFlashLight" );
	register_clcmd( "buy_bfl", "BatteryFlashLight" );
	register_clcmd( "/buy_colorflashlight", "ColorFlashLight" );
	register_clcmd( "/buy_cfl", "ColorFlashLight" );
	register_clcmd( "/buy_flashlight", "BuyFlashLight" );
	register_clcmd( "/buy_fl", "BuyFlashLight" );
	register_clcmd( "/buy_batteryflashlight", "BatteryFlashLight" );
	register_clcmd( "/buy_bfl", "BatteryFlashLight" );
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1)

	register_dictionary("flashlight.txt")
	register_dictionary("user.txt")

	register_event("HLTV", "Event_HLTV_newround", "a", "1=0", "2=0")
	register_event("TextMsg", "restartround", "a", "2=#Game_will_restart_in")
	register_logevent("restartround",2,"1=Game_Commencing")
	register_event("DeathMsg", "Event_DeathMsg", "a")

	plugin_precfg()
}

public plugin_natives()
{
	//register_library("flashlight");
	register_native("reset_flash","native_reset",1);
}

public native_reset(index) {
	reset(index)
	FlashlightTurnOff(index,false)
	message_begin(MSG_ONE_UNRELIABLE, g_msgidFlashBat, _, index)
	write_byte(g_iFlashBattery[index])
	message_end()
}

plugin_precfg()
{

	g_msgidFlashlight = get_user_msgid("Flashlight")
	g_msgidFlashBat = get_user_msgid("FlashBat")

	g_iMaxPlayers = get_maxplayers()

	new szConfigFile[128], szCurMap[64], szConfigDir[128], i, szTemp[128]

	get_localinfo("amxx_configsdir", szConfigDir, charsmax(szConfigDir))
	formatex(szConfigFile, 127, "%s/flashlight_colors.ini", szConfigDir)
	get_mapname(szCurMap, 63)

	while(szCurMap[i] != '_' && szCurMap[i++] != '^0') {/*do nothing*/}

	if (szCurMap[i]=='_')
	{
		// this map has a prefix
		szCurMap[i]='^0';
		formatex(szTemp, 127, "%s/flashlight/prefix_%s.ini", szConfigDir, szCurMap)
		if(file_exists(szTemp))
		{
			copy(szConfigFile, 127, szTemp)
		}
	}

	get_mapname(szCurMap, 63)
	formatex(szTemp, 127, "%s/flashlight/%s.ini", szConfigDir, szCurMap)
	if (file_exists(szTemp))
	{
		copy(szConfigFile, 127, szTemp)
	}

	new iFile = fopen(szConfigFile, "rt")
	if(!iFile)
	{
		return
	}

	g_aColors = ArrayCreate(3)

	new szColors[12], szRed[4], szGreen[4], szBlue[4], iColor[3]
	while(!feof(iFile))
	{
		fgets(iFile, szColors, 11)
		trim(szColors)
		if(!szColors[0] || szColors[0] == ';' || (szColors[0] == '/' && szColors[1] == '/'))
			continue
		parse(szColors, szRed, 3, szGreen, 3, szBlue, 3)
		iColor[Red] = str_to_num(szRed)
		iColor[Green] = str_to_num(szGreen)
		iColor[Blue] = str_to_num(szBlue)
		ArrayPushArray(g_aColors, iColor)
	}
	fclose(iFile)

	g_iColorsNum = ArraySize(g_aColors)
}
/*
public plugin_settings(id, level, cid)
{
	if( !cmd_access(id, level, cid, 3) )
	{
		return PLUGIN_HANDLED
	}

	new szCommand[8], szValue[10]
	read_argv(1, szCommand, 7)
	read_argv(2, szValue, 9)
	switch( szCommand[0] )
	{
		case 'a': g_iAttenuation = str_to_num(szValue)
		case 'c':
		{
			switch( szCommand[5] )
			{
				case 'c':
				{
					new iColor
					iColor = str_to_num(szValue)
					g_iTeamColor[0][Red] = (iColor / 1000000)
					iColor %= 1000000
					g_iTeamColor[0][Green] = (iColor / 1000)
					g_iTeamColor[0][Blue] = (iColor % 1000)
				}
				case 'e': g_flCharge = str_to_float(szValue) / 100
				case 'm': g_bEnabled = str_to_num(szValue)
				case 't':
				{
					if( szCommand[6] == 'e' )
					{
						new iColor
						iColor = str_to_num(szValue)
						g_iTeamColor[1][Red] = (iColor / 1000000)
						iColor %= 1000000
						g_iTeamColor[1][Green] = (iColor / 1000)
						g_iTeamColor[1][Blue] = (iColor % 1000)
					}
					else
					{
						g_iColorType = str_to_num(szValue)
					}
				}
			}
		}
		case 'd':
		{
			if( szCommand[1] == 'i' )
			{
				g_iDistanceMax = str_to_num(szValue)
			}
			else
			{
				g_flDrain = str_to_float(szValue) / 100
			}
		}
		case 'r': g_iRadius = str_to_num(szValue)
		case 's': g_iShowAll = str_to_num(szValue)
	}
	return PLUGIN_HANDLED
}*/

public client_putinserver(id)
{
	reset(id)
	g_cFlashLight[id] = false
	g_bFlashLight[id] = false
}

public client_disconnect(id)
{
	g_iFlashBattery[id] = 100
	g_flFlashLightTime[id] = 0.0
	g_cFlashLight[id] = false
	g_bFlashLight[id] = false
}

public Event_HLTV_newround()
{
	for(new id=1; id<=g_iMaxPlayers; id++)
	{
		reset(id)
	}
}

public player_spawn(id) {

	if (get_vip_flags( id ) & VIP_FLAG_C && !g_bFlashLight[id] && !g_cFlashLight[id]) {
		g_bFlashLight[id] = true;
		if (g_dFlashLight[id]) {
			FlashlightTurnOff(id,false)
			FlashlightTurnOn(id,false)
		}
	}

}

public Event_DeathMsg()
{
	reset(read_data(2))
	g_cFlashLight[read_data(2)] = false
	g_bFlashLight[read_data(2)] = false
	g_dFlashLight[read_data(2)] = false
}

reset(id)
{
	if( 1 <= id <= g_iMaxPlayers )
	{
		g_iFlashBattery[id] = 100
		g_dFlashLight[id] = false
		g_flFlashLightTime[id] = 0.0
	}
}

public Impulse_100( id )
{
	if( g_bEnabled )
	{
		if(is_user_alive(id) && !is_user_zombie(id))
		{
			if( g_dFlashLight[id] )
			{
				FlashlightTurnOff(id)
			}
			else if( g_iFlashBattery[id] )
			{
				FlashlightTurnOn(id)
			} else if (g_iFlashBattery[id] == 0) {
            	FlashShop(id)
			}
		}
		return PLUGIN_HANDLED_MAIN
	}
	return PLUGIN_CONTINUE
}

public client_PreThink(id)
{
	static Float:flTime
	flTime = get_gametime()

	if((g_sflDrain && !g_bFlashLight[id] && !g_cFlashLight[id] || g_bflDrain && g_bFlashLight[id] || g_cflDrain && g_cFlashLight[id]) && g_flFlashLightTime[id] && g_flFlashLightTime[id] <= flTime)
	{
		if(g_dFlashLight[id])
		{
			if(g_iFlashBattery[id])
			{
				new Float:g_zflDrain
				if (!g_bFlashLight[id] && !g_cFlashLight[id])
					g_zflDrain = g_sflDrain;
				else if (g_bFlashLight[id])
					g_zflDrain = g_bflDrain;
				else if (g_cFlashLight[id])
					g_zflDrain = g_cflDrain;
				g_flFlashLightTime[id] = g_zflDrain + flTime
				g_iFlashBattery[id]--

				if(!g_iFlashBattery[id])
				{
					FlashlightTurnOff(id)
				}
			}
		}
		else
		{
			if(g_iFlashBattery[id] < 100)
			{
				new Float:g_zflCharge
				if (!g_bFlashLight[id] && !g_cFlashLight[id])
					g_zflCharge = g_sflCharge;
				else if (g_bFlashLight[id])
					g_zflCharge = g_bflCharge;
				else if (g_cFlashLight[id])
					g_zflCharge = g_cflCharge;
				g_flFlashLightTime[id] = g_zflCharge + flTime
				g_iFlashBattery[id]++
			}
			else
				g_flFlashLightTime[id] = 0.0
		}

		message_begin(MSG_ONE_UNRELIABLE, g_msgidFlashBat, _, id)
		write_byte(g_iFlashBattery[id])
		message_end()

	}
	if(g_dFlashLight[id])
	{
		Make_FlashLight(id)
	}
}

Make_FlashLight(id)
{
	static iOrigin[3], iAim[3], iDist
	get_user_origin(id, iOrigin, 1)
	get_user_origin(id, iAim, 3)

	iDist = get_distance(iOrigin, iAim)

	if( iDist > g_iDistanceMax )
		return

	static iDecay, iAttn

	iDecay = iDist * 255 / g_iDistanceMax
	iAttn = 256 + iDecay * g_iAttenuation // barney/dontaskme

	if( g_iShowAll )
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	}
	else
	{
		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
	}
	write_byte( TE_DLIGHT )
	write_coord( iAim[0] )
	write_coord( iAim[1] )
	write_coord( iAim[2] )
	if (g_bFlashLight[id])
		write_byte( g_bRadius )
	else if (g_cFlashLight[id])
		write_byte( g_cRadius )
	else
		write_byte( g_sRadius )
	write_byte( (g_iColor[id][Red]<<8) / iAttn )
	write_byte( (g_iColor[id][Green]<<8) / iAttn )
	write_byte( (g_iColor[id][Blue]<<8) / iAttn )
	write_byte( LIFE )
	write_byte( iDecay )
	message_end()
}

FlashlightTurnOff(id, bool:sound=true)
{
	if (sound == true) emit_sound(id, CHAN_WEAPON, SOUND_FLASHLIGHT_OFF, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	g_dFlashLight[id] = false

	FlashlightHudDraw(id, 0)
	new Float:g_zflCharge
	if (!g_bFlashLight[id] && !g_cFlashLight[id])
		g_zflCharge = g_sflCharge;
	else if (g_bFlashLight[id])
		g_zflCharge = g_bflCharge;
	else if (g_cFlashLight[id])
		g_zflCharge = g_cflCharge;

	g_flFlashLightTime[id] = g_zflCharge + get_gametime()
}

FlashlightTurnOn(id, bool:sound=true)
{
	if (sound == true) emit_sound(id, CHAN_WEAPON, SOUND_FLASHLIGHT_ON, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	g_dFlashLight[id] = true

	FlashlightHudDraw(id, 1)

	if( g_iColorType || !g_iColorsNum || !g_cFlashLight[id] && !g_bFlashLight[id])
	{
		g_iColor[id] = g_sColor;
	}
	else if (g_bFlashLight[id])
	{
		g_iColor[id] = g_bColor;
	}
	else if (g_cFlashLight[id])
	{
		ArrayGetArray(g_aColors, random(g_iColorsNum), g_iColor[id]);
	}

	new Float:g_zflDrain
	if (!g_bFlashLight[id] && !g_cFlashLight[id])
		g_zflDrain = g_sflDrain;
	else if (g_bFlashLight[id])
		g_zflDrain = g_bflDrain;
	else if (g_cFlashLight[id])
		g_zflDrain = g_cflDrain;

	g_flFlashLightTime[id] = g_zflDrain + get_gametime()
}

FlashlightHudDraw(id, iFlag) {
	if( g_iShowAll )
	{
		emessage_begin(MSG_ONE_UNRELIABLE, g_msgidFlashlight, _, id)
		ewrite_byte(iFlag)
		ewrite_byte(g_iFlashBattery[id])
		emessage_end()
	} else {
		message_begin(MSG_ONE_UNRELIABLE, g_msgidFlashlight, _, id)
		write_byte(iFlag)
		write_byte(g_iFlashBattery[id])
		message_end()
	}
}

public BatteryFlashLight( id ) {

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", id, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	if (is_user_zombie(id)) {
		client_print(id, print_chat, "%L", id, "FLC_ZOMBIE")
		return PLUGIN_CONTINUE
	}

	if (g_iFlashBattery[id] >= 20) {
		client_print(id, print_chat, "%L", id, "FLC_BATHAVE")
		return PLUGIN_CONTINUE
	}

	new cost = get_pcvar_num(g_batcost)
	new money = cs_get_user_money_ul(id)
	if ( money < cost )
	{
		client_print(id, print_chat, "%L", id, "FLC_NOBCOST", cost)
		return PLUGIN_CONTINUE
	}

	cs_set_user_money_ul(id, money - cost)
	client_print(id, print_chat, "%L", id, "FLC_BATBUY")

	if (g_dFlashLight[id]) {
		g_iFlashBattery[id] = 100;
		g_flFlashLightTime[id] = 0.0;
		FlashlightTurnOff(id,false)
		FlashlightTurnOn(id,false)
	} else {
		reset(id)
		message_begin(MSG_ONE_UNRELIABLE, g_msgidFlashBat, _, id)
		write_byte(g_iFlashBattery[id])
		message_end()
	}
	return PLUGIN_CONTINUE;
}

public BuyFlashLight( id ) {

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", id, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	if (is_user_zombie(id)) {
		client_print(id, print_chat, "%L", id, "FLC_ZOMBIE")
		return PLUGIN_CONTINUE
	}

	if (g_bFlashLight[id]) {
		client_print(id, print_chat, "%L", id, "FLC_BHAVE")
		return PLUGIN_CONTINUE
	}

	new cost = get_pcvar_num(g_bflashcost)
	new money = cs_get_user_money_ul(id)
	if ( money < cost )
	{
		client_print(id, print_chat, "%L", id, "FLC_BNOCOST", cost)
		return PLUGIN_CONTINUE
	}

	cs_set_user_money_ul(id, money - cost)
	client_print(id, print_chat, "%L", id, "FLC_BBUY")

	g_bFlashLight[id] = true;
	g_cFlashLight[id] = false;
	if (g_dFlashLight[id]) {
		g_iFlashBattery[id] = 100;
		g_flFlashLightTime[id] = 0.0;
		FlashlightTurnOff(id,false)
		FlashlightTurnOn(id,false)
	} else {
		reset(id)
		message_begin(MSG_ONE_UNRELIABLE, g_msgidFlashBat, _, id)
		write_byte(g_iFlashBattery[id])
		message_end()
	}
	return PLUGIN_CONTINUE;
}

public ColorFlashLight( id ) {

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", id, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	if (is_user_zombie(id)) {
		client_print(id, print_chat, "%L", id, "FLC_ZOMBIE")
		return PLUGIN_CONTINUE
	}

	if (g_cFlashLight[id]) {
		client_print(id, print_chat, "%L", id, "FLC_CHAVE")
		return PLUGIN_CONTINUE
	}

	new cost = get_pcvar_num(g_cflashcost)
	new money = cs_get_user_money_ul(id)
	if ( money < cost )
	{
		client_print(id, print_chat, "%L", id, "FLC_CNOCOST", cost)
		return PLUGIN_CONTINUE
	}

	cs_set_user_money_ul(id, money - cost)
	client_print(id, print_chat, "%L", id, "FLC_СBUY")

	g_cFlashLight[id] = true;
	g_bFlashLight[id] = false;
	if (g_dFlashLight[id]) {
		g_iFlashBattery[id] = 100;
		g_flFlashLightTime[id] = 0.0;
		FlashlightTurnOff(id,false)
		FlashlightTurnOn(id,false)
	} else {
		reset(id)
		message_begin(MSG_ONE_UNRELIABLE, g_msgidFlashBat, _, id)
		write_byte(g_iFlashBattery[id])
		message_end()
	}
	return PLUGIN_CONTINUE;
}

public FlashShop( id )
{

	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "%L", id, "FLC_BMENU", get_pcvar_num(g_batcost) );
	new menu = menu_create( szText, "menu_shop" )

	formatex( szText, charsmax( szText ), "%L", id, "FLC_BMENU1");
	menu_additem( menu, szText, "1", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "FLC_BMENU2");
	menu_additem( menu, szText, "2", 0 );
	menu_setprop( menu, MPROP_PERPAGE, 0);

	menu_display( id, menu, 0 );

	return PLUGIN_CONTINUE;

}

public menu_shop( id, menu, item )
{
	new data[ 6 ], iName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

	new key = str_to_num( data );

	switch( key )
	{
		case 1:
		{
			new cost = get_pcvar_num(g_batcost)
			new money = cs_get_user_money_ul(id)
			if ( money < cost )
			{
				client_print(id, print_chat, "%L", id, "FLC_NOBCOST", cost)
				return PLUGIN_CONTINUE
			}
			cs_set_user_money_ul(id, money - cost)
			client_print(id, print_chat, "%L", id, "FLC_BATBUY")
			reset(id)
			FlashlightHudDraw(id, 0)
			menu_destroy( menu );
		}
		case 2:
		{
			menu_destroy( menu );
		}
	}
	return PLUGIN_HANDLED;
}

public restartround()
{
	for (new i=1; i<33; i++) {
		if (is_user_connected(i)) {
			reset(i)
			if (get_vip_flags( i ) & VIP_FLAG_C)
				g_bFlashLight[i] = true
			else
				g_bFlashLight[i] = false
			g_cFlashLight[i] = false
		}
	}
}