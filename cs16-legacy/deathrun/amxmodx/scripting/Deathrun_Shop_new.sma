/* AMX Mod X script.
*
*   Deathrun Shop
*   Copyright (C) 2009 tuty
*
*   This program is free software; you can redistribute it and/or
*   modify it under the terms of the GNU General Public License
*   as published by the Free Software Foundation; either version 2
*   of the License, or (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program; if not, write to the Free Software
*   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
*   In addition, as a special exception, the author gives permission to
*   link the code of this program with the Half-Life Game Engine ("HL
*   Engine") and Modified Game Libraries ("MODs") developed by Valve,
*   L.L.C ("Valve"). You must obey the GNU General Public License in all
*   respects for all of the code used other than the HL Engine and MODs
*   from Valve. If you modify this file, you may extend this exception
*   to your version of the file, but you are not obligated to do so. If
*   you do not wish to do so, delete this exception statement from your
*   version.
*
* 	Credits:
* 	--------
* 		- xPaw ( for menu because new amxx menu doesnt suport cvars... thank you )
*		- connor ( sugestion )
*
* --------------------------------------
*
*    Copyright (c) 2015 by AlexALX
*    This plugin have changes what was made for project with VIP support
*    Used on Botov-NET project for CS 1.6 servers
*/

//#define SANTAHAT

#include <amxmodx>
#include <cstrike>
#include <engine>
#include <money_ul>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <hamsandwich>
#include <vip>
#if defined SANTAHAT
	#include <santahat>
#endif

#define PLUGIN "Deathrun Shop"
#define VERSION "2.4.2"
#define VERSION_MENU "1.0.3"
#define AUTHOR "tuty/AlexALX"

#define OFFSET_PRIMARYWEAPON 116

//#pragma semicolon 1
#define PICKUP_SND	"items/gunpickup2.wav"
#define SOUND_NVGOFF "items/nvg_off.wav"
#define HEALTH_SOUND	"items/smallmedkit1.wav"
#define ARMOR_SOUND		"items/ammopickup2.wav"

#define OFFSET_MONEY	115

#define HAS_NVGS		(1<<0)
#define USES_NVGS		(1<<8)
#define get_user_nvg(%1)    	(get_pdata_int(%1,m_iNvg) & HAS_NVGS)

new gDrShopOn;
new gHeCost;
new gHe2Cost;
new gBothGrenadesCost;
new gSilentCost;
new gHealthCost;
new gArmorCost;
new gSpeedCost;
new gGravityCost;
new gInvisCost;
//new gMsgMoney;
//new gMaxPlayers;
new gSpeedCvar;
new gGravityCvar;
//new gJetCost;
//new gJetTime;
new gDeagleCost;
new gAwpCost;
new gShieldCost;
new gAdvertiseCvar;
new gHealthPointCvar;
new gArmorPointCvar;
new gAdvertiseTimeCvar;
new HasHe[ 33 ];
new HasHe2[ 33 ];
new HasBothGren[ 33 ];
new HasSilent[ 33 ];
new HasHealth[ 33 ];
new HasArmor[ 33 ];
new HasSpeed[ 33 ];
new HasGravity[ 33 ];
new HasInvis[ 33 ];
new bool:bSilent[ 33 ];
//new HasJet[ 33 ];
//new HasNoclip[ 33 ];
new HasNVG[ 33 ];
new HasDeagle[ 33 ];
new HasAwp[ 33 ];
new HasShield[ 33 ];
new gJetSprite;
new gWhave;
new gNvgCost;
//new gNoclipCost;
//new gNoclipTime;
new pCostnull = 0;
new gMessageNVG;
new gSuiciderCostCvar;
new gMsgItemPickup, gMsgScreenFade;

/* --| Offsets for nvg */
const m_iNvg = 129;
const m_iLinuxDiff = 5;

const KEYS_M = MENU_KEY_0 | MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9;
new drshop_gren = 1, drshop_grenh = 1, drshop_lj = 1, drshop_silent = 1, drshop_hp = 1, drshop_ap = 1, drshop_speed = 1, drshop_grav = 1, drshop_invis = 1,/* drshop_jet = 1, drshop_noclip = 1,*/ drshop_deagle = 1, drshop_shield = 1, drshop_nvg = 1, drshop_awp = 1;

// cs_set_user_bpammo( id, CSW_FLASHBANG, get_pcvar_num( g_pFlashbangs ) )

enum
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T,
	CS_TEAM_CT,
	CS_TEAM_SPECTATOR
}

new g_sync_hpdisplay, g_iMaxplayers,g_iMsgSayText, g_iMsgTeamInfo;

// Colorchat
enum Color {
	NORMAL = 1,
	GREEN,
	RED,
	BLUE,
	GRAY
};

new TeamName[ ][ ] = {
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};

new bool:block_spawn[33];


new bool:g_free, bool:g_invis
new bool:timer[33] = false

public plugin_init()
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_cvar( "drshop_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY );

	//register_forward( FM_PlayerPreThink, "forward_player_prethink" );

	//register_logevent( "logevent_round_start", 2, "1=Round_Start" );
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	//register_event( "DeathMsg", "Hook_Deathmessage", "a" );
	RegisterHam(Ham_Killed, "player", "Hook_Deathmessage",1)
	register_event( "CurWeapon", "HookCurWeapon", "be", "1=1" );
	//RegisterHam( Ham_Player_Jump, "player", "bacon_playerJumping" );
	register_forward( FM_ClientKill, "forward_kill" );
	//g_fwd_invis = CreateMultiForward("event_invis", ET_IGNORE);

	register_message(get_user_msgid("ShowMenu"), "message_show_menu");
	register_message(get_user_msgid("VGUIMenu"), "message_vgui_menu");
	register_clcmd("chooseteam", "cmd_jointeam");
	RegisterHam(Ham_Spawn, "player", "FwdPlayerSpawn", 1);

	//register_message(get_user_msgid("ShowMenu"), "MainMenu");
	register_clcmd( "say /menu", "MainMenu" );
	register_clcmd( "say menu", "MainMenu" );
	register_clcmd( "say /меню", "MainMenu" );
	register_clcmd( "say меню", "MainMenu" );
	register_clcmd( "say /mainmenu", "MainMenu" );
	register_clcmd( "say mainmenu", "MainMenu" );
	register_clcmd( "say /drmenu", "MainMenu" );
	register_clcmd( "say drmenu", "MainMenu" );
	register_clcmd( "say /drmenu", "MainMenu" );
	register_clcmd( "say drmenu", "MainMenu" );
	register_clcmd( "/меню", "MainMenu" );
	register_clcmd( "меню", "MainMenu" );
	register_clcmd( "/menu", "MainMenu" );
	register_clcmd( "menu", "MainMenu" );
	register_clcmd( "/mainmenu", "MainMenu" );
	register_clcmd( "mainmenu", "MainMenu" );
	register_clcmd( "/drmenu", "MainMenu" );
	register_clcmd( "drmenu", "MainMenu" );
	register_clcmd( "/drmenu", "MainMenu" );
	register_clcmd( "drmenu", "MainMenu" );
	register_menucmd( register_menuid( "Main Menu" ), KEYS_M, "main_menu" );
	register_menucmd( register_menuid( "Life SubMenu" ), KEYS_M, "life_submenu" );
	register_clcmd( "lifeshop", "LifeSubMenu" );

	register_clcmd( "say /drshop", "DeathrunShop" );
	register_clcmd( "say_team /drshop", "DeathrunShop" );
	register_clcmd( "say drshop", "DeathrunShop" );
	register_clcmd( "say_team drshop", "DeathrunShop" );
	register_clcmd( "/drshop", "DeathrunShop" );
	register_clcmd( "drshop", "DeathrunShop" );
	register_clcmd( "say /shop", "DeathrunShop" );
	register_clcmd( "say_team /shop", "DeathrunShop" );
	register_clcmd( "say shop", "DeathrunShop" );
	register_clcmd( "say_team shop", "DeathrunShop" );
	register_clcmd( "/shop", "DeathrunShop" );
	register_clcmd( "shop", "DeathrunShop" );
	register_clcmd( "say /магазин", "DeathrunShop" );
	register_clcmd( "say магазин", "DeathrunShop" );
	register_clcmd( "/магазин", "DeathrunShop" );
	register_clcmd( "магазин", "DeathrunShop" );
	register_clcmd( "amx_invis", "cmd_invis", ADMIN_BAN, "<nick or #userid>");
	register_menucmd( register_menuid( "Deathrun Shop" ), KEYS_M, "menu_shop" );
	//register_clcmd( "amx_shop", "cmd_shop", ADMIN_BAN, "<option> <on/off>");

	//RegisterHam( Ham_Spawn,      "player", "FwdHamPlayerSpawn", 1 );

	register_message(get_user_msgid("Health"), "msg_health");
	register_message(get_user_msgid("Battery"), "msg_armor");

	gDrShopOn = register_cvar( "deathrun_shop", "1" );
	gHeCost = register_cvar( "deathrun_he_cost", "1500" );
	gHe2Cost = register_cvar( "deathrun_he2_cost", "2500" );
	gBothGrenadesCost = register_cvar( "deathrun_bothgrenades_cost", "8000" );
	gSilentCost = register_cvar( "deathrun_silent_cost", "3000" );
	gHealthCost = register_cvar( "deathrun_health_cost", "4000" );
	gArmorCost = register_cvar( "deathrun_armor_cost", "4000" );
	gSpeedCost = register_cvar( "deathrun_speed_cost", "8000" );
	gGravityCost = register_cvar( "deathrun_gravity_cost", "8000" );
	gInvisCost = register_cvar( "deathrun_invisibility_cost", "10000" );
	gSpeedCvar = register_cvar( "deathrun_speed_power", "350.0" );
	gGravityCvar = register_cvar( "deathrun_gravity_power", "0.5" );
	gAdvertiseCvar = register_cvar( "deathrun_advertise_message", "1" );
	gHealthPointCvar = register_cvar( "deathrun_health_points", "255" );
	gArmorPointCvar = register_cvar( "deathrun_armor_points", "255" );
	gAdvertiseTimeCvar = register_cvar( "deathrun_advertise_time", "7.0" );
	//gJetTime = register_cvar( "deathrun_jetpack_duration", "15" );
	//gJetCost = register_cvar( "deathrun_jetpack_cost", "10000" );
//	gNoclipTime = register_cvar( "deathrun_noclip_duration", "5" );
//	gNoclipCost = register_cvar( "deathrun_noclip_cost", "12000" );
	gDeagleCost = register_cvar( "deathrun_deagle_cost", "12000" );
	gAwpCost = register_cvar( "deathrun_awp_cost", "11000" );
	gShieldCost = register_cvar( "deathrun_shield_cost", "1000" );
	gNvgCost = register_cvar( "deathrun_nvg_cost", "7000" );
	gSuiciderCostCvar = register_cvar( "deathrun_suicider_loose_cost", "2000" );

	//gMsgMoney = get_user_msgid( "Money" );
	//gMaxPlayers = get_maxplayers();
	gMessageNVG = get_user_msgid( "NVGToggle" );
	gMsgItemPickup = get_user_msgid( "ItemPickup" );
	gMsgScreenFade = get_user_msgid("ScreenFade");
	register_dictionary( "deathrunshop.txt" );

	if( get_pcvar_num( gDrShopOn ) != 0 )
	{
		check_ini("gren.ini");
		check_ini("grenh.ini");
		check_ini("lj.ini");
		check_ini("silent.ini");
		check_ini("hp.ini");
		check_ini("ap.ini");
		check_ini("speed.ini");
		check_ini("grav.ini");
		check_ini("invis.ini");
		//check_ini("jet.ini");
		check_ini("deagle.ini");
		check_ini("shield.ini");
		check_ini("nvg.ini");
		check_ini("awp.ini");
	}

	g_sync_hpdisplay = CreateHudSyncObj();
	set_task(0.1, "task_showtruehealth", _, _, _, "b");
	g_iMaxplayers    = get_maxplayers( );
	g_iMsgSayText    = get_user_msgid( "SayText" );
	g_iMsgTeamInfo   = get_user_msgid( "TeamInfo" );


	// Free

	register_clcmd("say /knife", "cmdFree")
	register_clcmd("say /free", "cmdFree")
	register_clcmd("say /invis", "cmdInvis")
	RegisterHam(Ham_Touch, "armoury_entity", "fwdTouch")
	RegisterHam(Ham_Touch, "weaponbox", "fwdTouch")
	RegisterHam(Ham_Use, "func_button", "fwdUse")

}

public fwdTouch(ent, id) {
      if (is_user_alive(id) && g_free)
       return HAM_SUPERCEDE

      return HAM_IGNORED
}

public fwdUse(ent, idcaller, idactivator, use_type, Float:value) {
      if (is_user_alive(idactivator) && (g_free || g_invis) && get_user_team(idactivator) == 1) {
       if (HasInvis[idactivator])
        ColorChat(idactivator, RED, "%L", idactivator, "DR_INVIS");
       else
        ColorChat(idactivator, RED, "%L", idactivator, "DR_FREE");
       return HAM_SUPERCEDE
      }

      return HAM_IGNORED
}

public cmdFree(id) {
      if (get_user_team(id) != 1) {
        ColorChat(id, RED, "%L", id, "DR_TRONLY" )
        return
      }
      if (g_free==true) {
       ColorChat(id, RED, "%L", id, "DR_ALR_ACT_FREE2" )
       return
      }
      if (g_invis==true) {
       ColorChat(id, RED, "%L", id, "DR_ALR_ACT_INVIS" )
       return
      }
      if(timer[id] == false) {

       new players[32], plNum
       get_players(players, plNum, "ace", "TERRORIST")

       g_free = true

       set_hudmessage(0, 255, 0, 0.02, -1.0, 0, 6.0, 12.0, 0.1, 0.2, 4)
       show_hudmessage(0, "Free and knife")

       new i
       get_players(players, plNum, "ah")
       for (i = 0; i < plNum; i++) {
        fm_strip_user_weapons(players[i])
        fm_give_item(players[i], "weapon_knife")
        set_user_rendering( players[i], _, 0, 0, 0, _, 0 )
        if (HasInvis[players[i]]) ColorChat(players[i], RED, "%L", players[i], "DR_FREE2");
       }
      }
      else if (get_user_team(id) == 1) {
			ColorChat(id, RED, "%L", id, "DR_FREE1" )
      }

}

public plugin_natives()
{
	register_native("deathrun_free","native_drfree",1)
	register_native("drshop_invis","native_drinvis",1)
}

public native_drfree()
	return g_free;

public native_drinvis(id)
	return HasInvis[ id ];

public cmdInvis(id) {
		if (get_user_team(id) != 1) {
			ColorChat(id, RED, "%L", id, "DR_TRONLY" )
			return PLUGIN_CONTINUE;
		}
		if (g_free==true) {
			ColorChat(id, RED, "%L", id, "DR_ALR_ACT_FREE" )
			return PLUGIN_CONTINUE;
		}
		if (g_invis==true) {
			ColorChat(id, RED, "%L", id, "DR_ALR_ACT_INVIS2" )
			return PLUGIN_CONTINUE;
		}
		if(timer[id] == false) {
			if (drshop_invis != 1||g_free==true||g_invis==true) {
				return PLUGIN_CONTINUE;
			}
			if( HasInvis[ id ] )
			{
				allready_have( id );
				return PLUGIN_CONTINUE;
			}
			if( get_user_team( id ) == 2)
			{
				//client_print( id, print_chat, "%L", id, "DRSHOP_ONLY_T" );
				ColorChat(id, RED, "%L", id, "DRSHOP_ONLY_T" );
				return PLUGIN_CONTINUE;
			}
			new whichmoney = fm_get_user_money( id );
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gInvisCost )/1.5,floatround_ceil) : get_pcvar_num( gInvisCost )) )
			{
				ColorChat(id, RED, "%L", id, "DRSHOP_DONTHAVE_MONEY2", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gInvisCost )/1.5,floatround_ceil) : get_pcvar_num( gInvisCost )))
				return PLUGIN_CONTINUE;
			}
			set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );
			//client_print( id, print_chat, "%L", id, "DRSHOP_INVISIBILITY_ITEM" );
			ColorChat(id, GRAY, "%L", id, "DRSHOP_INVISIBILITY_ITEM" );
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gInvisCost )/1.5,floatround_ceil) : get_pcvar_num( gInvisCost )) );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasInvis[ id ] = true;
			set_client_effect( id );

			new players[32], plNum
			get_players(players, plNum, "ace", "TERRORIST")

			g_invis = true

			set_hudmessage(0, 255, 0, 0.02, -1.0, 0, 6.0, 12.0, 0.1, 0.2, 4)
			show_hudmessage(0, "Free and invis")

			new i
			get_players(players, plNum, "ah")
			for (i = 0; i < plNum; i++) {
				if (get_user_team( players[i] ) != 1) fm_give_item( players[i], "ammo_45acp" )
			}
		} else if (get_user_team(id) == 1) {
			ColorChat(id, RED, "%L", id, "DR_INVIS1" )
		}
		return PLUGIN_CONTINUE

}

public cmd_jointeam(id) {
	if(get_user_team(id) != CS_TEAM_SPECTATOR && get_user_team(id) != CS_TEAM_UNASSIGNED)
	{
		client_cmd(id, "menu");
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public message_show_menu(msgid, dest, id) {
	static team_select[] = "#Terrorist_S"
	static menu_text_code[sizeof team_select]
	get_msg_arg_string(4, menu_text_code, sizeof menu_text_code - 1)
	if (equali(menu_text_code, team_select))
		block_spawn[id] = true;
	return PLUGIN_CONTINUE
}

public FwdPlayerSpawn(id)
{
    if( block_spawn[id] && is_user_alive(id) && get_user_team(id)==CS_TEAM_T) {
		user_silentkill(id);
		block_spawn[id] = false;
		cs_set_user_team(id,CS_TEAM_CT);
		client_print(id,print_center,"%L",id,"SELECT_TEAM");
		ColorChat(id, RED, "\TEM[DeathRun] \YEL%L", id, "SELECT_TEAM");
		cs_reset_user_model(id)
		set_task(0.1,"task_spawn",id)
    } else if (block_spawn[id] && is_user_alive(id)) {
		block_spawn[id] = false;
    }
}

public message_vgui_menu(msgid, dest, id) {

	if (get_msg_arg_int(1) == 26 && !access(id,ADMIN_RCON))
		block_spawn[id] = true;

	return PLUGIN_CONTINUE
}

public MainMenu( id )
{

	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "\rDeathRun Menu \yv%s", VERSION_MENU );
	new menu = menu_create( szText, "main_menu" );

	formatex( szText, charsmax( szText ), "%L", id, "DRMENU_1");
	menu_additem( menu, szText, "1", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "DRMENU_2");
	menu_additem( menu, szText, "2", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "DRMENU_3");
	menu_additem( menu, szText, "3", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "DRMENU_4");
	menu_additem( menu, szText, "4", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "DRMENU_7");
	menu_additem( menu, szText, "5", 0 );

	if (get_user_team(id) != CS_TEAM_SPECTATOR) {
		formatex( szText, charsmax( szText ), "%L", id, "DRMENU_6");
		menu_additem( menu, szText, "6", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRMENU_6");
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "6", ADMIN_ADMIN );
	}

	formatex( szText, charsmax( szText ), "%L", id, "DRMENU_8");
	menu_additem( menu, szText, "7", 0 );

	if (access(id,ADMIN_RCON)) {
		if (get_user_team(id) != CS_TEAM_SPECTATOR) {
			if (get_user_team(id) == CS_TEAM_CT) {
				formatex( szText, charsmax( szText ), "%L", id, "DRMENU_9");
			} else {
				formatex( szText, charsmax( szText ), "%L", id, "DRMENU_9t");
			}
			menu_additem( menu, szText, "8", 0 );
		} else {
			formatex( szText, charsmax( szText ), "%L", id, "DRMENU_9");
			replace_all(szText, charsmax( szText ), "\w", "");
			replace_all(szText, charsmax( szText ), "\r", "");
			replace_all(szText, charsmax( szText ), "\y", "");
			menu_additem( menu, szText, "8", ADMIN_ADMIN );
		}
	} else if (is_user_admin(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "DRMENU_9");
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "8", ADMIN_ADMIN );
	}

	if (!is_user_admin(id))
		menu_addblank(menu,1)
	menu_addblank(menu,1)

	formatex( szText, charsmax( szText ), "%L", id, "DRMENU_EXIT");
	menu_additem( menu, szText, "0", 0 );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL); //, MEXIT_ALL
	new string[100];
	formatex( string, sizeof string - 1, "%L", id, "DRMENU_EXIT" );
	menu_setprop( menu, MPROP_EXITNAME, string );

	new num = 0;
	menu_setprop( menu, MPROP_PERPAGE, num);

	//formatex( szText, charsmax( szText ), "%L", id, "SHOP_END" );
	menu_display( id, menu, 0 );

	return PLUGIN_HANDLED;
}

public main_menu( id, menu, item )
{

	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		//client_print( id, print_chat, "%L", id, "DRSHOP_MENU_CLOSED" );
		return PLUGIN_HANDLED;
	}

	new data[ 6 ], iName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

	new key = str_to_num( data );

	switch( key )
	{
		case 1:
		{
			client_cmd(id, "shop");
			menu_destroy( menu );
		}
		case 2:
		{
			client_cmd(id, "/help");
			menu_destroy( menu );
		}
		case 3:
		{
			client_cmd(id, "/commands");
			menu_destroy( menu );
		}
		case 4:
		{
			client_cmd(id, "/rules");
			menu_destroy( menu );
		}
		case 5:
		{
			new langsmenu[32];
			get_user_info(id, "lang", langsmenu, 31);
			if (equali(langsmenu,"ru"))
				client_cmd(id, "/lang en");
			else if (equali(langsmenu,"en"))
				client_cmd(id, "/lang ru");
			else
				client_cmd(id, "/lang en");
			menu_destroy( menu );
		}
		case 6:
		{
			if (get_user_team(id) != CS_TEAM_SPECTATOR) {
				if (is_user_alive(id))
				{
					new deaths = cs_get_user_deaths(id)
					user_silentkill(id)
					cs_set_user_deaths(id, deaths)
				}
				cs_set_user_team(id, CS_TEAM_SPECTATOR)
				cs_reset_user_model(id)
			}
			menu_destroy( menu );
		}
		case 7:
		{
			client_cmd(id, "server");
			menu_destroy( menu );
		}
		case 8:
		{
			if (get_user_team(id) != CS_TEAM_SPECTATOR) {
				if (is_user_alive(id))
				{
					new deaths = cs_get_user_deaths(id)
					user_silentkill(id)
					cs_set_user_deaths(id, deaths)
				}
				if (get_user_team(id) == CS_TEAM_CT)
					cs_set_user_team(id, CS_TEAM_T)
				else
					cs_set_user_team(id, CS_TEAM_CT)
				cs_reset_user_model(id)
				set_task(0.1,"task_spawn",id)
			}
			menu_destroy( menu );
		}
		case 0:
		{
			menu_destroy( menu );
		}
	}
	return PLUGIN_HANDLED;
}

public task_spawn(id) {
	if (is_user_connected(id) && !is_user_alive(id))
		ExecuteHamB( Ham_CS_RoundRespawn, id );
}

public check_ini(file[]) {

		new iCfgDir[ 32 ], iFile[ 192 ];
		get_configsdir( iCfgDir, charsmax( iCfgDir ) );
		formatex( iFile, charsmax( iFile ), "%s/deathrun/%s", iCfgDir, file );

		if( !file_exists( iFile ) )
		{
			write_file( iFile, "" );
		}

		new szMapName[ 64 ];
		get_mapname( szMapName, 63 );

		new szLine[101];
		new line;
		new len = 0;

		while(read_file(iFile, line ++ , szLine , 100 , len) ) {

			if(szLine[0] == ';' || !len) continue;

			new mapname[64], constain[3];
			parse (szLine, mapname , 63 , constain , 2);

			if (equali( szMapName, mapname ) && (equali(constain,"") || equali(constain,"0")) || containi( szMapName, mapname ) != -1 && equali(constain,"1")) {
				if (equal( file, "gren.ini")) drshop_gren = 0;
				else if (equal( file, "grenh.ini")) drshop_grenh = 0;
				else if (equal( file, "lj.ini")) drshop_lj = 0;
				else if (equal( file, "silent.ini")) drshop_silent = 0;
				else if (equal( file, "hp.ini")) drshop_hp = 0;
				else if (equal( file, "ap.ini")) drshop_ap = 0;
				else if (equal( file, "speed.ini")) drshop_speed = 0;
				else if (equal( file, "grav.ini")) drshop_grav = 0;
				else if (equal( file, "invis.ini")) drshop_invis = 0;
				//else if (equal( file, "jet.ini")) drshop_jet = 0;
				else if (equal( file, "deagle.ini")) drshop_deagle = 0;
				else if (equal( file, "shield.ini")) drshop_shield = 0;
				else if (equal( file, "nvg.ini")) drshop_nvg = 0;
				else if (equal( file, "awp.ini")) drshop_awp = 0;
			}
		}

}

public plugin_precache()
{
	gJetSprite = precache_model( "sprites/explode1.spr" );
	gWhave = precache_model( "sprites/shockwave.spr" );
	precache_sound( PICKUP_SND );
	precache_sound( SOUND_NVGOFF );
	precache_sound( HEALTH_SOUND );
	precache_sound( ARMOR_SOUND );
}

public plugin_cfg()
{
	if( get_pcvar_num( gDrShopOn ) != 0 )
	{
		new iCfgDir[ 32 ], iFile[ 192 ];
		get_configsdir( iCfgDir, charsmax( iCfgDir ) );
		formatex( iFile, charsmax( iFile ), "%s/deathrun/deathrun_shop.cfg", iCfgDir );

		if( !file_exists( iFile ) )
		{
			server_print( "*** File %s doesn't exist! ***", iFile );
			server_print( "*** Creating a deafult Configuration file! ***" );

			write_file( iFile, "// DeathrunShop Configuration file!" );
			write_file( iFile, "// visit http://forums.alliedmods.net/showthread.php?t=87536 for info!" );
			write_file( iFile, "// You can edit the cvars like u want :D" );
			write_file( iFile, " " );
			write_file( iFile, " " );
			write_file( iFile, "// DeathrunShop enabled? Set 0 to disable de plugin" );
			write_file( iFile, "deathrun_shop ^"1^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Cost for single he grenade item" );
			write_file( iFile, "deathrun_he_cost ^"2500^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Cost for both grenades. FB+SM" );
			write_file( iFile, "deathrun_bothgrenades_cost ^"5000^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Cost for both grenades. HE" );
			write_file( iFile, "deathrun_he2_cost ^"3000^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Cost for silent-footsteps" );
			write_file( iFile, "deathrun_silent_cost ^"4000^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Cost for Health Points item" );
			write_file( iFile, "deathrun_health_cost ^"6000^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Cost for Armor Points item" );
			write_file( iFile, "deathrun_armor_cost ^"6000^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Cost for Speed item" );
			write_file( iFile, "deathrun_speed_cost ^"16000^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Cost for Gravity item" );
			write_file( iFile, "deathrun_gravity_cost ^"8000^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Cost for invisibility item. Only terrorist's can have this item!" );
			write_file( iFile, "deathrun_invisibility_cost ^"16000^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Set here the speed power. Default 400.0" );
			write_file( iFile, "deathrun_speed_power ^"400.0^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Set here the gravity power. Default is 0.5" );
			write_file( iFile, "deathrun_gravity_power ^"0.5^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Enable / disable the advertise message when a player join the server" );
			write_file( iFile, "// Default is 1" );
			write_file( iFile, "deathrun_advertise_message ^"1^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Set here the Health Points. Default 255" );
			write_file( iFile, "deathrun_health_points ^"255^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Set here the Armor Points. Default 255" );
			write_file( iFile, "deathrun_armor_points ^"255^"" );
			write_file( iFile, " " );
			write_file( iFile, "// Set here the advertise message time. Default is 7.0" );
			write_file( iFile, "deathrun_advertise_time ^"7.0^"" );
			write_file( iFile, " " );
		}
		server_cmd( "exec %s", iFile );
	}
}

public client_connect( id )
{
	HasHe[ id ] = false;
	HasHe2[ id ] = false;
	HasBothGren[ id ] = false;
	HasSilent[ id ] = false;
	HasHealth[ id ] = false;
	HasArmor[ id] = false;
	HasSpeed[ id ] = false;
	HasGravity[ id ] = false;
	HasInvis[ id ] = false;
	//HasJet[ id ] = false;
	//HasNoclip[ id ] = false;
	HasDeagle[ id ] = false;
	HasShield[ id ] = false;
	HasNVG[ id ] = false;
	HasAwp[id] = false;
}
public client_disconnect( id )
{
	bSilent[ id ] = false;
	HasHe[ id ] = false;
	HasHe2[ id ] = false;
	HasBothGren[ id ] = false;
	HasSilent[ id ] = false;
	HasHealth[ id ] = false;
	HasArmor[ id] = false;
	HasSpeed[ id ] = false;
	HasGravity[ id ] = false;
	HasInvis[ id ] = false;
	//HasJet[ id ] = false;
	//HasNoclip[ id ] = false;
	HasDeagle[ id ] = false;
	HasShield[ id ] = false;
	HasNVG[ id ] = false;
	HasAwp[ id ] = false;
	block_spawn[id] = false;
}

public client_putinserver( id )
{
	if( get_pcvar_num( gAdvertiseCvar ) != 0 )
	{
		set_task( get_pcvar_float( gAdvertiseTimeCvar ), "ShowPlayerInfo", id );
	}
}
/*
public forward_player_prethink( id )
{
	if( bSilent[ id ] )
	{
		set_pev( id, pev_flTimeStepSound, 999 );
	}
}*/

public LifeSubMenu( id )
{

	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "\rDeathrun Shop \yv%s^n^n", VERSION );
	new menu = menu_create( szText, "life_submenu" );

	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_L1", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_cvar_num( "deathrun_lifecost" )/1.5,floatround_ceil) : get_cvar_num( "deathrun_lifecost" )));
	menu_additem( menu, szText, "1", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_L2", (get_vip_flags( id ) & VIP_FLAG_C ? floatround((get_cvar_num( "deathrun_lifecost" )/1.5)*0.6,floatround_ceil) : floatround(get_cvar_num( "deathrun_lifecost" )*0.6,floatround_ceil)));
	menu_additem( menu, szText, "2", 0 );

	if( !is_user_alive(id) && get_user_team( id ) == CS_TEAM_CT ) {
		formatex( szText, charsmax( szText ), "%L", id, "DRMENU_5");
		menu_additem( menu, szText, "3", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRMENU_5");
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "3", ADMIN_ADMIN );
	}

	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_L3");
	menu_additem( menu, szText, "4", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "DRMENU_EXIT");
	menu_additem( menu, szText, "0", 0 );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL); //, MEXIT_ALL
	new string[100];
	formatex( string, sizeof string - 1, "%L", id, "DRMENU_EXIT" );
	menu_setprop( menu, MPROP_EXITNAME, string );

	new num = 0;
	menu_setprop( menu, MPROP_PERPAGE, num);

	//formatex( szText, charsmax( szText ), "%L", id, "SHOP_END" );
	menu_display( id, menu, 0 );

	return PLUGIN_HANDLED;
}

public life_submenu( id, menu, item )
{

	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		//client_print( id, print_chat, "%L", id, "DRSHOP_MENU_CLOSED" );
		return PLUGIN_HANDLED;
	}

	new data[ 6 ], iName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

	new key = str_to_num( data );

	switch( key )
	{
		case 1:
		{
			client_cmd(id, "buylife");
			if( get_cvar_num( "deathrun_lifesystem" ) && cs_get_user_money_ul( id ) >= (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_cvar_num( "deathrun_lifecost" )/1.5,floatround_ceil) : get_cvar_num( "deathrun_lifecost" ) ) )
			{
				emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
				if (!HasInvis[id] && is_user_alive(id)) set_client_effect( id );
			}
			client_cmd(id, "lifeshop");
			menu_destroy( menu );
		}
		case 2:
		{
			client_cmd(id, "soldlife");
			client_cmd(id, "lifeshop");
			menu_destroy( menu );
		}
		case 3:
		{
			client_cmd(id, "uselife");
			menu_destroy( menu );
		}
		case 4:
		{
			client_cmd(id, "shop");
			menu_destroy( menu );
		}
		case 0:
		{
			menu_destroy( menu );
		}
	}
	return PLUGIN_HANDLED;
}

new m_iMenuCode = 205

public DeathrunShop( id )
{
	if( get_pcvar_num( gDrShopOn ) != 1 )
	{
		client_print( id, print_chat, "%L", id, "DRSHOP_DISABLED" );
		return PLUGIN_HANDLED;
	}

	/*if( !is_user_alive( id ) )
	{
		client_print( id, print_chat, "%L", id, "DRSHOP_ONLY_ALIVE" );
		return PLUGIN_HANDLED;
	}*/

	/*new arg[32],arg2[32];

	read_argv(1, arg, 31);
	read_argv(2, arg2, 31);*/

	new szText[ 400 char ];
	formatex( szText, charsmax( szText ), "\rDeathrun Shop \yv%s^n^n", VERSION );
	new menu = menu_create( szText, "menu_shop" );
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_1L" );
	menu_additem( menu, szText, "1", 0 );
	if (drshop_gren == 1 && is_user_alive(id) && !HasHe[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_1", (get_vip_flags( id ) & VIP_FLAG_C ? pCostnull : get_pcvar_num( gHeCost )) );
		menu_additem( menu, szText, "2", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_1", (get_vip_flags( id ) & VIP_FLAG_C ? pCostnull : get_pcvar_num( gHeCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "2", ADMIN_ADMIN );
	}
	if (drshop_grenh == 1 && is_user_alive(id) && !HasHe2[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_2", (get_vip_flags( id ) & VIP_FLAG_C ? pCostnull : get_pcvar_num( gHe2Cost )) );
		menu_additem( menu, szText, "3", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_2", (get_vip_flags( id ) & VIP_FLAG_C ? pCostnull : get_pcvar_num( gHe2Cost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "3", ADMIN_ADMIN );
	}
	if (drshop_lj == 1 && is_user_alive(id) && !HasBothGren[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_3", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gBothGrenadesCost )/1.5,floatround_ceil) : get_pcvar_num( gBothGrenadesCost )) );
		menu_additem( menu, szText, "4", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_3", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gBothGrenadesCost )/1.5,floatround_ceil) : get_pcvar_num( gBothGrenadesCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "4", ADMIN_ADMIN );
	}
	if (drshop_silent == 1 && is_user_alive(id) && !HasSilent[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_4", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gSilentCost )/1.5,floatround_ceil) : get_pcvar_num( gSilentCost )) );
		menu_additem( menu, szText, "5", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_4", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gSilentCost )/1.5,floatround_ceil) : get_pcvar_num( gSilentCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "5", ADMIN_ADMIN );
	}
	if (drshop_hp == 1 && is_user_alive(id) && !HasHealth[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_5", get_pcvar_num( gHealthPointCvar ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gHealthCost )/1.5,floatround_ceil) : get_pcvar_num( gHealthCost )) );
		menu_additem( menu, szText, "6", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_5", get_pcvar_num( gHealthPointCvar ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gHealthCost )/1.5,floatround_ceil) : get_pcvar_num( gHealthCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "6", ADMIN_ADMIN );
	}
	if (drshop_ap == 1 && is_user_alive(id) && !HasArmor[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_6", get_pcvar_num( gArmorPointCvar ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gArmorCost )/1.5,floatround_ceil) : get_pcvar_num( gArmorCost )) );
		menu_additem( menu, szText, "7", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_6", get_pcvar_num( gArmorPointCvar ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gArmorCost )/1.5,floatround_ceil) : get_pcvar_num( gArmorCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "7", ADMIN_ADMIN );
	}
	if (drshop_speed == 1 && is_user_alive(id) && !HasSpeed[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_7", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gSpeedCost )/1.5,floatround_ceil) : get_pcvar_num( gSpeedCost )) );
		menu_additem( menu, szText, "8", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_7", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gSpeedCost )/1.5,floatround_ceil) : get_pcvar_num( gSpeedCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "8", ADMIN_ADMIN );
	}
	if (drshop_grav == 1 && is_user_alive(id) && !HasGravity[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_8", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gGravityCost )/1.5,floatround_ceil) : get_pcvar_num( gGravityCost )) );
		menu_additem( menu, szText, "9", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_8", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gGravityCost )/1.5,floatround_ceil) : get_pcvar_num( gGravityCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "9", ADMIN_ADMIN );
	}
	if (drshop_invis == 1 && get_user_team( id ) == 1 && is_user_alive(id) && !g_free && !HasInvis[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_9", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gInvisCost )/1.5,floatround_ceil) : get_pcvar_num( gInvisCost )) );
		menu_additem( menu, szText, "10", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_9", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gInvisCost )/1.5,floatround_ceil) : get_pcvar_num( gInvisCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "10", ADMIN_ADMIN );
	}
	/*if (drshop_jet == 1) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_10", get_pcvar_num( gJetTime ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gJetCost )/1.5,floatround_ceil) : get_pcvar_num( gJetCost )) );
		menu_additem( menu, szText, "11", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_10d", get_pcvar_num( gJetTime ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gJetCost )/1.5,floatround_ceil) : get_pcvar_num( gJetCost )) );
		menu_additem( menu, szText, "11", ADMIN_ADMIN );
	}
	if (drshop_noclip == 1) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_11", get_pcvar_num( gNoclipTime ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gNoclipCost )/1.5,floatround_ceil) : get_pcvar_num( gNoclipCost )) );
		menu_additem( menu, szText, "12", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_11d", get_pcvar_num( gNoclipTime ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gNoclipCost )/1.5,floatround_ceil) : get_pcvar_num( gNoclipCost )) );
		menu_additem( menu, szText, "12", ADMIN_ADMIN );
	}*/

	if (drshop_deagle == 1 && is_user_alive(id) && !g_free && !HasDeagle[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_12", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gDeagleCost )/1.5,floatround_ceil) : get_pcvar_num( gDeagleCost )) );
		menu_additem( menu, szText, "11", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_12", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gDeagleCost )/1.5,floatround_ceil) : get_pcvar_num( gDeagleCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "11", ADMIN_ADMIN );
	}

	if (drshop_awp == 1 && is_user_alive(id) && !g_free && !HasAwp[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_13", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gAwpCost )/1.5,floatround_ceil) : get_pcvar_num( gAwpCost )) );
		menu_additem( menu, szText, "12", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_13", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gAwpCost )/1.5,floatround_ceil) : get_pcvar_num( gAwpCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "12", ADMIN_ADMIN );
	}

	if (drshop_shield == 1 && is_user_alive(id) && !HasShield[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_14", (get_vip_flags( id ) & VIP_FLAG_C ? pCostnull : get_pcvar_num( gShieldCost )) );
		menu_additem( menu, szText, "13", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_14", (get_vip_flags( id ) & VIP_FLAG_C ? pCostnull : get_pcvar_num( gShieldCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "13", ADMIN_ADMIN );
	}

	if (drshop_nvg == 1 && is_user_alive(id) && !HasNVG[ id ]) {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_15", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gNvgCost )/1.5,floatround_ceil) : get_pcvar_num( gNvgCost )) );
		menu_additem( menu, szText, "14", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_15", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gNvgCost )/1.5,floatround_ceil) : get_pcvar_num( gNvgCost )) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "14", ADMIN_ADMIN );
	}
	/*
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_10", get_pcvar_num( gNoclipTime ), get_pcvar_num( gNoclipCost ) );
	menu_additem( menu, szText, "10", 0 );
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_11", get_pcvar_num( gJetTime ), get_pcvar_num( gJetPackCost ) );
	menu_additem( menu, szText, "11", 0 );
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_12", get_pcvar_num( gDeagleCost ) );
	menu_additem( menu, szText, "12", 0 );
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_13", get_pcvar_num( gLongJumpTime ), get_pcvar_num( gLongJumpCost ) );
	menu_additem( menu, szText, "13", 0 );
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_14", get_pcvar_num( gGlowCost ) );
	menu_additem( menu, szText, "14", 0 );
	*/

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL);
	new string[100],string2[100],string3[100];
	formatex( string, sizeof string - 1, "%L", id, "DRSHOP_BACK" );
	menu_setprop( menu, MPROP_BACKNAME, string );
	formatex( string2, sizeof string2 - 1, "%L", id, "DRSHOP_NEXT" );
	menu_setprop( menu, MPROP_NEXTNAME, string2 );
	formatex( string3, sizeof string3 - 1, "%L", id, "DRSHOP_EXIT" );
	menu_setprop( menu, MPROP_EXITNAME, string3 );

	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_END" );
	menu_display( id, menu, 0 );
	set_pdata_int(id, m_iMenuCode, 0)

	return PLUGIN_HANDLED;
}

public menu_shop( id, menu, item )
{

	if( get_pcvar_num( gDrShopOn ) != 1 )
	{
		//client_print( id, print_chat, "%L", id, "DRSHOP_DISABLED" );
		ColorChat(id, NORMAL, "%L", id, "DRSHOP_DISABLED");
		return PLUGIN_HANDLED;
	}

	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		//client_print( id, print_chat, "%L", id, "DRSHOP_MENU_CLOSED" );
		return PLUGIN_HANDLED;
	}

	new data[ 6 ], iName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

	new key = str_to_num( data );

	if( !is_user_alive( id ) && key != 1)
	{
		//client_print( id, print_chat, "%L", id, "DRSHOP_ONLY_ALIVE" );
		ColorChat(id, RED, "%L", id, "DRSHOP_ONLY_ALIVE");
		return PLUGIN_HANDLED;
	}

	new whichmoney = fm_get_user_money( id );
	switch( key )
	{
		case 1:
		{
			client_cmd(id, "lifeshop");
			menu_destroy( menu );
		}
		case 2:
		{
			if (drshop_gren != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasHe[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney <  (get_vip_flags( id ) & VIP_FLAG_C ? pCostnull : get_pcvar_num( gHeCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			give_item( id, "weapon_smokegrenade" );
			give_item( id, "weapon_flashbang" );
			//client_print( id, print_chat, "%L", id, "DRSHOP_GRENADE_ITEM" );
			ColorChat(id, BLUE, "%L", id, "DRSHOP_GRENADE_ITEM" );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			fm_set_user_money( id, whichmoney - (is_user_vip(id) ? pCostnull : get_pcvar_num( gHeCost )) );
			HasHe[ id ] = true;
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}
		case 3:
		{
			if (drshop_grenh != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasHe2[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? pCostnull : get_pcvar_num( gHe2Cost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			give_item( id, "weapon_hegrenade" );
			//client_print( id, print_chat, "%L", id, "DRSHOP_HEGRENADE_ITEM" );
			ColorChat(id, RED, "%L", id, "DRSHOP_HEGRENADE_ITEM" );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? pCostnull : get_pcvar_num( gHe2Cost )) );
			HasHe2[ id ] = true;
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}
		case 4:
		{
			if (drshop_lj != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasBothGren[ id ] )
			{
				allready_have( id );
				//give_item( id, "item_longjump" );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gBothGrenadesCost )/1.5,floatround_ceil) : get_pcvar_num( gBothGrenadesCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			//client_print( id, print_chat, "%L", id, "DRSHOP_BOTHGREN_ITEM" );
			ColorChat(id, BLUE, "%L", id, "DRSHOP_BOTHGREN_ITEM" );
			//give_item( id, "item_longjump" );
			set_longjump(id)
			fm_set_user_money( id, whichmoney -  (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gBothGrenadesCost )/1.5,floatround_ceil) : get_pcvar_num( gBothGrenadesCost )) );
			//emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasBothGren[ id ] = true;
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}
		case 5:
		{
			if (drshop_silent != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasSilent[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gSilentCost )/1.5,floatround_ceil) : get_pcvar_num( gSilentCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			set_user_footsteps(id, 1); //fm_set_user_footsteps( id, 1 );
			//client_print( id, print_chat, "%L", id, "DRSHOP_SILENTWALK_ITEM" );
			ColorChat(id, BLUE, "%L", id, "DRSHOP_SILENTWALK_ITEM" );
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gSilentCost )/1.5,floatround_ceil) : get_pcvar_num( gSilentCost )) );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasSilent[ id ] = true;
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}
		case 6:
		{
			if (drshop_hp != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasHealth[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gHealthCost )/1.5,floatround_ceil) : get_pcvar_num( gHealthCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			//fm_set_user_health( id, get_user_health( id ) + get_pcvar_num( gHealthPointCvar ) );
			//set_user_health( id, get_user_health( id ) + get_pcvar_num( gHealthPointCvar ) );
			set_hp(id, get_user_health( id ) + get_pcvar_num( gHealthPointCvar ) )
			//client_print( id, print_chat, "%L", id, "DRSHOP_HEALTH_ITEM", get_pcvar_num( gHealthPointCvar ) );
			ColorChat(id, RED, "%L", id, "DRSHOP_HEALTH_ITEM", get_pcvar_num( gHealthPointCvar ));
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gHealthCost )/1.5,floatround_ceil) : get_pcvar_num( gHealthCost )) );
			//emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasHealth[ id ] = true;
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}
		case 7:
		{
			if (drshop_ap != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasArmor[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gArmorCost )/1.5,floatround_ceil) : get_pcvar_num( gArmorCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			//fm_set_user_armor( id, get_user_armor( id ) + get_pcvar_num( gArmorPointCvar ) );
			//set_user_armor( id, get_user_armor( id ) + get_pcvar_num( gArmorPointCvar ) );
			set_ap(id, get_user_armor( id ) + get_pcvar_num( gArmorPointCvar ) );
			//client_print( id, print_chat, "%L", id, "DRSHOP_ARMOR_ITEM", get_pcvar_num( gArmorPointCvar ) );
			ColorChat(id, BLUE, "%L", id, "DRSHOP_ARMOR_ITEM", get_pcvar_num( gArmorPointCvar ) );
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gArmorCost )/1.5,floatround_ceil) : get_pcvar_num( gArmorCost )) );
			//emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasArmor[ id ] = true;
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}
		case 8:
		{
			if (drshop_speed != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasSpeed[ id ] )
			{
				allready_have( id );
				set_user_maxspeed( id, get_pcvar_float( gSpeedCvar ) );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gSpeedCost )/1.5,floatround_ceil) : get_pcvar_num( gSpeedCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			//fm_set_user_maxspeed( id, get_pcvar_float( gSpeedCvar ) );
			set_user_maxspeed( id, get_pcvar_float( gSpeedCvar ) );
			//client_print( id, print_chat, "%L", id, "DRSHOP_SPEED_ITEM" );
			ColorChat(id, BLUE, "%L", id, "DRSHOP_SPEED_ITEM" );
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gSpeedCost )/1.5,floatround_ceil) : get_pcvar_num( gSpeedCost )) );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			//set_task(2.0, "SpeedCheck",id,_,_, "b");

			HasSpeed[ id ] = true;
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}
		case 9:
		{
			if (drshop_grav != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasGravity[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gGravityCost )/1.5,floatround_ceil) : get_pcvar_num( gGravityCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			set_user_gravity( id, get_pcvar_float( gGravityCvar ) );
			//client_print( id, print_chat, "%L", id, "DRSHOP_GRAVITY_ITEM" );
			ColorChat(id, RED, "%L", id, "DRSHOP_GRAVITY_ITEM" );
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gGravityCost )/1.5,floatround_ceil) : get_pcvar_num( gGravityCost )) );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasGravity[ id ] = true;
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}
		case 10:
		{
			if (drshop_invis != 1 || g_free || g_invis) {
				return PLUGIN_HANDLED;
			}
			if( HasInvis[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( get_user_team( id ) == 2)
			{
				//client_print( id, print_chat, "%L", id, "DRSHOP_ONLY_T" );
				ColorChat(id, RED, "%L", id, "DRSHOP_ONLY_T" );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gInvisCost )/1.5,floatround_ceil) : get_pcvar_num( gInvisCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );
			//client_print( id, print_chat, "%L", id, "DRSHOP_INVISIBILITY_ITEM" );
			ColorChat(id, GRAY, "%L", id, "DRSHOP_INVISIBILITY_ITEM" );
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gInvisCost )/1.5,floatround_ceil) : get_pcvar_num( gInvisCost )) );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasInvis[ id ] = true;
			set_client_effect( id );
			//ExecuteForward(g_fwd_invis, id);
			#if defined SANTAHAT
				event_invis_rm(id);
			#endif
			menu_destroy( menu );

		}
        /*
		case 10:
		{
			if (drshop_jet != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasJet[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gJetCost )/1.5,floatround_ceil) : get_pcvar_num( gJetCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			set_task( float( get_pcvar_num( gJetTime ) ), "remove_jetpack", id );
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gJetCost )/1.5,floatround_ceil) : get_pcvar_num( gJetCost )) );
			client_print( id, print_chat, "%L", id, "DRSHOP_JETPACK_ITEM" );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasJet[ id ] = true;
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}

		case 11:
		{
			if (drshop_noclip != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasNoclip[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < get_pcvar_num( gNoclipCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			set_task( float( get_pcvar_num( gNoclipTime ) ), "remove_noclip", id );
			set_user_noclip( id, 1 );
			client_print( id, print_chat, "%L", id, "DRSHOP_NOCLIP_ITEM" );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasNoclip[ id ] = true;
			fm_set_user_money( id, whichmoney - get_pcvar_num( gNoclipCost ) );
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}*/

		case 11:
		{
			if (drshop_deagle != 1 || g_free) {
				return PLUGIN_HANDLED;
			}
			if( HasDeagle[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gDeagleCost )/1.5,floatround_ceil) : get_pcvar_num( gDeagleCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			give_item( id, "weapon_deagle" );
			new weapon_id = find_ent_by_owner(-1, "weapon_deagle", id);
			if(weapon_id) cs_set_weapon_ammo(weapon_id, 4);
			cs_set_user_bpammo(id, CSW_DEAGLE, 4);
			ColorChat(id, RED, "%L", id, "DRSHOP_DEAGLE_ITEM" );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasDeagle[ id ] = true;
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gDeagleCost )/1.5,floatround_ceil) : get_pcvar_num( gDeagleCost )) );
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}

		case 12:
		{
			if (drshop_awp != 1 || g_free) {
				return PLUGIN_HANDLED;
			}
			if( HasAwp[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gAwpCost )/1.5,floatround_ceil) : get_pcvar_num( gAwpCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			give_item( id, "weapon_awp" );
			new weapon_id = find_ent_by_owner(-1, "weapon_awp", id);
			if(weapon_id) cs_set_weapon_ammo(weapon_id, 1);
			cs_set_user_bpammo(id, CSW_AWP, 1)
			ColorChat(id, RED, "%L", id, "DRSHOP_AWP_ITEM" );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasAwp[ id ] = true;
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gAwpCost )/1.5,floatround_ceil) : get_pcvar_num( gAwpCost )) );
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}

		case 13:
		{
			if (drshop_shield != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasShield[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? pCostnull : get_pcvar_num( gShieldCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			set_pdata_int(id, OFFSET_PRIMARYWEAPON, 0);
			give_item(id, "weapon_shield");
			set_pdata_int(id, OFFSET_PRIMARYWEAPON, 1);
			//client_print( id, print_chat, "%L", id, "DRSHOP_SHIELD_ITEM" );
			ColorChat(id, BLUE, "%L", id, "DRSHOP_SHIELD_ITEM" );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasShield[ id ] = true;
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? pCostnull : get_pcvar_num( gShieldCost )) );
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}

		case 14:
		{
			if (drshop_nvg != 1) {
				return PLUGIN_HANDLED;
			}
			if( HasNVG[ id ] || get_user_nvg( id ))
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			if( whichmoney < (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gNvgCost )/1.5,floatround_ceil) : get_pcvar_num( gNvgCost )) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			set_user_nvg( id, 1 );

			//client_print( id, print_chat, "%L", id, "DRSHOP_NVG_ITEM" );
			ColorChat(id, GRAY, "%L", id, "DRSHOP_NVG_ITEM" );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			HasNVG[ id ] = true;
			fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gNvgCost )/1.5,floatround_ceil) : get_pcvar_num( gNvgCost )) );
			if (!HasInvis[id]) set_client_effect( id );
			menu_destroy( menu );
		}

		/*
		case 10:
		{
			set_user_rendering( id, kRenderFxGlowShell, random( 256 ), random( 256 ), random( 256 ), kRenderNormal, random( 256 ) );
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_GLOW_ITEM" );
			client_sound_play( id );
			HasGlow[ id ] = true;
			set_client_effect( id );
			menu_destroy( menu );
		}
		case 12:
		{
			strip_user_weapons( id );
			give_item( id, "weapon_knife" );
			give_item( id, "weapon_deagle" );
			//cs_set_user_bpammo(id, CSW_DEAGLE, 2);
			ns_set_weap_clip(CSW_DEAGLE, 2);
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_DEAGLE_ITEM" );
			client_sound_play( id );
			HasDeagle[ id ] = true;
			set_client_effect( id );
			menu_destroy( menu );
		}     */

	}
	return PLUGIN_HANDLED;
}

public ShowPlayerInfo( id )
{
	set_hudmessage( 0, 183, 255, -1.0, 0.82, 0, 6.0, 12.0 );
	show_hudmessage( id, "%L", id, "DRSHOP_HUD_INFO" );
}

public cmd_invis(id, level, cid) {

	new flags[32] = "g";
	if (!cmd_access(id, level, cid, 1) || !is_user_admin(id) || !has_flag(id,flags))
		return PLUGIN_HANDLED;

	new arg[32],arg2[32];

	read_argv(1, arg, 31);
	read_argv(2, arg2, 31);
	new invis = str_to_num(arg2);
	if(arg[0] == '@') {
		if(equali(arg[1],"ALL")) {

		for(new i = 1; i < get_playersnum()+1; i++) {
	if (is_user_connected(i) && is_user_alive(i)) {

	if (!invis) set_user_rendering( i, _, 0, 0, 0, _, 0 );
	else set_user_rendering( i, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );
            }
	}
		}
	} else {
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE);

	if (!player)
		return PLUGIN_HANDLED;

	if (!invis) set_user_rendering( player, _, 0, 0, 0, _, 0 );
	else set_user_rendering( player, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );
	}
	return PLUGIN_HANDLED;

}
/*
public bacon_playerJumping( id )
{
	if( get_pcvar_num( gDrShopOn ) != 0 && HasJet[ id ] )
	{
		new iOrigin[ 3 ];
		get_user_origin( id, iOrigin, 0 );

		iOrigin[ 2 ] -= 10;

		new Float:fVelocity[ 3 ];
		pev( id, pev_velocity, fVelocity );

		fVelocity[ 2 ] += 12; //93

		set_pev( id, pev_velocity, fVelocity );
		create_flame( iOrigin );
	}
}*/
/*
public task_give_gren(index) {
	give_item( index, "weapon_smokegrenade" );
	give_item( index, "weapon_flashbang" );
	HasHe[ index ] = true;
}*/
/*
public task_give_grenh(index) {
	give_item( index, "weapon_hegrenade" );
	HasHe2[ index ] = true;
}*/

public HookCurWeapon( id )
{
	/* --| If plugin is on, and user has speed item, let's set the speed again */
	if( get_pcvar_num( gDrShopOn ) != 0 && HasSpeed[ id ] )
	{
		set_user_maxspeed( id, get_pcvar_float( gSpeedCvar ) );
	}
}

public event_newround() //logevent_round_start()
{
	g_free = false
	g_invis = false
	if( get_pcvar_num( gDrShopOn ) == 1 )
	{
		for( new id = 1; id <= 33; id++ )
		{
			if (is_user_connected(id)) {
			HasHe[ id ] = false;
			HasHe2[ id ] = false;
			HasBothGren[ id ] = false;
			HasSilent[ id ] = false;
			HasHealth[ id ] = false;
			HasArmor[ id] = false;
			HasSpeed[ id ] = false;
			HasGravity[ id ] = false;
			HasInvis[ id ] = false;
			//HasJet[ id ] = false;
			//HasNoclip[ id ] = false;
			HasDeagle[ id ] = false;
			HasShield[ id ] = false;
			HasNVG[ id ] = false;
			HasAwp[ id ] = false;

			del_longjump(id)
			set_user_rendering( id, _, 0, 0, 0, _, 0 );
			set_user_gravity( id, 1.0 );
			set_user_maxspeed( id, 0.0 );
			set_user_footsteps(id, 0); //fm_set_user_footsteps( id, 0 );
			//set_user_noclip( id, 0 );
			remove_user_nvg( id );
			cs_set_user_armor(id,0,CS_ARMOR_NONE)
			//remove_task( id );
			//PlayerSpawn(id);
			remove_task(id+999)
			set_task(20.0, "functask", id+999)
			timer[id] = false
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public functask(id) {
	if (is_user_connected(id-999))
     timer[id-999] = true
}

public Hook_Deathmessage(victim, killer, shouldgib)
{
	if( get_pcvar_num( gDrShopOn ) == 1 )
	{
		new id = victim; //read_data( 2 );
		if (is_user_connected(id)) {
		HasHe[ id ] = false;
		HasHe2[ id ] = false;
		HasBothGren[ id ] = false;
		HasSilent[ id ] = false;
		HasHealth[ id ] = false;
		HasArmor[ id] = false;
		HasSpeed[ id ] = false;
		HasGravity[ id ] = false;
		HasInvis[ id ] = false;
		//HasJet[ id ] = false;
		//HasNoclip[ id ] = false;
		HasDeagle[ id ] = false;
		HasShield[ id ] = false;
		HasNVG[ id ] = false;
		HasAwp[ id ] = false;

		set_user_rendering( id, _, 0, 0, 0, _, 0 );
		set_user_gravity( id, 1.0 );
		set_user_maxspeed( id, 0.0 );
		set_user_footsteps(id, 0); //fm_set_user_footsteps( id, 0 );
		//set_user_noclip( id, 0 );
		remove_user_nvg( id );
		//remove_task( id );
		}
	}
	return PLUGIN_CONTINUE;
}

public forward_kill( id )
{
	/* --| Check if plugin is on, and user is alive */
	if( get_pcvar_num( gDrShopOn ) == 1 && is_user_alive( id ) && get_user_team( id ) != 1)
	{
		/* --| Set player points with suicide cvar */
		//client_print( id, print_chat, "%L", id, "DRSHOP_SHOW_LOOSER", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gSuiciderCostCvar )/1.5,floatround_ceil) : get_pcvar_num( gSuiciderCostCvar )) );
		ColorChat(id, RED, "%L", id, "DRSHOP_SHOW_LOOSER", (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gSuiciderCostCvar )/1.5,floatround_ceil) : get_pcvar_num( gSuiciderCostCvar )) );
		new whichmoney = fm_get_user_money( id );
		//gKillerPoints[ id ] -= get_pcvar_num( gSuicideCostCvar );
		fm_set_user_money( id, whichmoney - (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num( gSuiciderCostCvar )/1.5,floatround_ceil) : get_pcvar_num( gSuiciderCostCvar )) );
	}
}

/*
public remove_noclip( id )
{
	HasNoclip[ id ] = false;
	set_user_noclip( id, 0 );
	client_print( id, print_chat, "%L", id, "DRSHOP_NOCLIP_OFF", get_pcvar_num( gNoclipTime ) );
}*/
/*
public remove_jetpack( id )
{
	HasJet[ id ] = false;
	client_print( id, print_chat, "%L", id, "DRSHOP_JETPACK_OFF", get_pcvar_num( gJetTime ) );
}*/

stock create_flame( origin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, origin );
	write_byte( TE_SPRITE );
	write_coord( origin[ 0 ] );
	write_coord( origin[ 1 ] );
	write_coord( origin[ 2 ] );
	write_short( gJetSprite );
	write_byte( 3 );
	write_byte( 99 );
	message_end();
}

stock set_client_effect( index )
{
	new iOrigin[ 3 ];
	get_user_origin( index, iOrigin );

	message_begin( MSG_PAS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + 8 );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + 10 + 50 );
	write_short( gWhave );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 4 );
	write_byte( 50 );
	write_byte( 0 );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 0 );
	write_byte( 200 );
	write_byte( 0 );
	message_end();
}

stock allready_have( id)
{
	//client_print( id, print_chat, "%L", id, "DRSHOP_ALLREADY_HAVE" );
	ColorChat(id, RED, "%L", id, "DRSHOP_ALLREADY_HAVE");
}
stock dont_have( id )
{
	//client_print( id, print_chat, "%L", id, "DRSHOP_DONTHAVE_MONEY" );
	ColorChat(id, RED, "%L", id, "DRSHOP_DONTHAVE_MONEY");
}
/*stock client_sound_play( index )
{
	client_cmd( index, "speak %s", PICKUP_SND );
}*/
stock fm_get_user_money( index )
{
	//new money = get_pdata_int( index, OFFSET_MONEY );
	new money = cs_get_user_money_ul(index);
	return money;
}
stock fm_set_user_money( index, money )
{
	//set_pdata_int( index, OFFSET_MONEY, money );
	//fm_set_money( index, money, flash );
	cs_set_user_money_ul(index, money);
	//return true;
}         /*
stock fm_set_money( index, money, flash )
{
	message_begin( MSG_ONE_UNRELIABLE, gMsgMoney, {0, 0, 0}, index );
	write_long( money );
	write_byte( flash ? 1 : 0 );
	message_end();
}
stock fm_set_user_footsteps( index, set )
{
	if( set == 1 )
	{
		set_pev( index, pev_flTimeStepSound, 999 );
		bSilent[ index ] = true;
	}
	else
	{
		set_pev( index, pev_flTimeStepSound, 400 );
		bSilent[ index ] = false;
	}
	return 1;
} */

/* --| Stock for setting user nightvision */
/* --| This stock is more good than cstrike native( give errors ) */
stock set_user_nvg( index, nvgoggles = 1 )
{
	if( nvgoggles )
	{
		set_pdata_int( index, m_iNvg, get_pdata_int( index, m_iNvg ) | HAS_NVGS );
	}

	else
	{
		set_pdata_int( index, m_iNvg, get_pdata_int( index, m_iNvg ) & ~HAS_NVGS );
	}
}

/* --| Stock for removing turned on nightvision from players. Let's call, force remove nvg :) */
stock remove_user_nvg( index )
{
	new iNvgs = get_pdata_int( index, m_iNvg, m_iLinuxDiff );

	if( !iNvgs )
	{
		return;
	}

	if( iNvgs & USES_NVGS )
	{
		//emit_sound( index, CHAN_ITEM, SOUND_NVGOFF, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

		emessage_begin( MSG_ONE_UNRELIABLE, gMessageNVG, _, index );
		ewrite_byte( 0 );
		emessage_end();
	}

	set_pdata_int( index, m_iNvg, 0, m_iLinuxDiff );
}

public set_hp(index,hp) {

	message_begin( MSG_ONE_UNRELIABLE, gMsgItemPickup, _, index );
	write_string( "item_healthkit" );
	message_end();

	flash_user(index,10,10,1,1,255,0,0,255)
	set_user_health(index,hp)

	emit_sound( index, CHAN_ITEM, HEALTH_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );

	return PLUGIN_CONTINUE

}

public set_ap(index,ap) {

	message_begin( MSG_ONE_UNRELIABLE, gMsgItemPickup, _, index );
	write_string( "item_battery" );
	message_end();

	flash_user(index,10,10,1,1,0,255,255,255)
	cs_set_user_armor(index,ap,CS_ARMOR_VESTHELM)

	emit_sound( index, CHAN_ITEM, ARMOR_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );

	return PLUGIN_CONTINUE

}

stock set_longjump(index) {

	message_begin( MSG_ONE_UNRELIABLE, gMsgItemPickup, _, index );
	write_string( "item_longjump" );
	message_end();

	flash_user(index,10,10,1,1,255,255,0,255)

	emit_sound( index, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );

	engfunc( EngFunc_SetPhysicsKeyValue, index, "slj", "1" );
	return PLUGIN_CONTINUE

}

public del_longjump(index) {

	engfunc( EngFunc_SetPhysicsKeyValue, index, "slj", "0" );

	return PLUGIN_CONTINUE

}

public flash_user(id,time,time2,time3,time4,color_r,color_g,color_b,color_a) {
	message_begin(MSG_ONE,gMsgScreenFade,{0,0,0},id)
	write_short( 1<<time )
	write_short( 1<<time2 )
	write_short( 1<<time3 )
	write_byte( color_r )
	write_byte( color_g )
	write_byte( color_b )
	write_byte( color_a )
	message_end()
	if (time4 == 0) emit_sound(id,CHAN_BODY, "weapons/flashbang-2.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
}

public msg_health(msgid, dest, id)
{

	static health;
	health = get_msg_arg_int(1);

	if(health > 255)
		set_msg_arg_int(1, ARG_BYTE, 255);

	return PLUGIN_CONTINUE;
}

public msg_armor(msgid, dest, id)
{

	static armor;
	armor = get_msg_arg_int(1);

	if(armor > 999)
		set_msg_arg_int(1, ARG_BYTE, 999);

	return PLUGIN_CONTINUE;
}

public task_showtruehealth()
{
	//set_hudmessage(_, _, _, 0.03, 0.93, _, 0.01, 1.35)
	set_hudmessage(_, _, _, 0.03, 0.93, _, 0.2, 0.2);

	new players[32], num;
	get_players(players, num);
	for (new i=0; i<num; i++)
		if(is_user_connected(players[i]) && is_user_alive(players[i]) && !is_user_bot(players[i]))
			ShowSyncHudMsg(players[i], g_sync_hpdisplay, "%L %L",players[i],"DR_HEALTH", get_user_health(players[i]),players[i],"DR_ARMOR", get_user_armor(players[i])); //0.f
}

// COLORCHAT
/////////////////////////////////////////////
ColorChat( id, Color:type, const szMessage[], {Float,Sql,Result,_}:... ) {
	if( !get_playersnum( ) ) return;

	new message[ 256 ];

	switch( type ) {
		case NORMAL: message[0] = 0x01;
		case GREEN: message[0] = 0x04;
		default: message[0] = 0x03;
	}

	vformat( message[ 1 ], 251, szMessage, 4 );

	message[ 192 ] = '^0';

	replace_all( message, 191, "\YEL", "^1" );
	replace_all( message, 191, "\GRN", "^4" );
	replace_all( message, 191, "\TEM", "^3" );

	new iTeam, ColorChange, index, MSG_Type;

	if( id ) {
		MSG_Type = MSG_ONE_UNRELIABLE;
		index = id;
	} else {
		index = CC_FindPlayer();
		MSG_Type = MSG_BROADCAST;
	}

	iTeam = get_user_team( index );
	ColorChange = CC_ColorSelection(index, MSG_Type, type);

	CC_ShowColorMessage(index, MSG_Type, message);

	if( ColorChange )
		CC_Team_Info(index, MSG_Type, TeamName[iTeam]);
}

CC_ShowColorMessage( id, type, message[] ) {
	message_begin( type, g_iMsgSayText, _, id );
	write_byte( id );
	write_string( message );
	message_end( );
}

CC_Team_Info( id, type, team[] ) {
	message_begin( type, g_iMsgTeamInfo, _, id );
	write_byte( id );
	write_string( team );
	message_end( );

	return 1;
}

CC_ColorSelection( index, type, Color:Type ) {
	switch( Type ) {
		case RED: return CC_Team_Info( index, type, TeamName[ 1 ] );
		case BLUE: return CC_Team_Info( index, type, TeamName[ 2 ] );
		case GRAY: return CC_Team_Info( index, type, TeamName[ 3 ] );
	}

	return 0;
}

CC_FindPlayer( ) {
	for( new i = 1; i <= g_iMaxplayers; i++ )
		if( is_user_connected(i) )
			return i;

	return -1;
}