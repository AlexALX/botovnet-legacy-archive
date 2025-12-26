/* AMX Mod X script.
*
*   Original - Deathrun Shop
*   Copyright (C) 2009 tuty
*
* This plugin was modified for Botov-NET Project
* It adds unique Biohazard Shop with tons of features
* Eg - longjump with overheating functionality, buy hp/zombie/vaccine and other
* It also merge some other plugins into one
* 
* Copyring for MODIFICATIONS and NEW features by AlexALX (c) 2015
* 
* Rest are authors of other plugins, they are listed on this repository as separate plugins
* If some author missing - feel free to contact me, i'll add you to list exclusively 
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
*/

#include <amxmodx>
#include <money_ul>
#include <amxmisc>
#include <biohazard>
#include <engine>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <vip>
#include <drug>
#include <lm>

#define PLUGIN "Biohazard Shop/Menu"
#define VERSION "1.5"
#define VERSION_MENU "1.2.1"
#define VERSION_PLUG "1.4.1"
#define AUTHOR "AlexALX"

//#pragma semicolon 1
#define G_PICKUP_SND	"items/9mmclip1.wav"

new PcvarCostZ,PcvarCostH,PcvarCostG,PcvarCostL,pScanCost,pCloakCost,c_flCost,c_cflCost,c_bflCost,g_xtime;
const KEYS_M = MENU_KEY_0 | MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9;

enum
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T,
	CS_TEAM_CT,
	CS_TEAM_SPECTATOR
}

// LongJump

#define LJ_PICKUP_SND		"items/gunpickup2.wav"

new bool:g_hasLongJump[33],bool:g_hasLongJumpVip[33],bool:g_hasLongJumpFree[33],g_LongJumpEnergy[33],bool:g_LongJumpLowEnergy[33],g_LongJumpEnergyTime[33]
new lPcvarMode
new lPcvarCost
new gMsgItemPickup
new lPayback

new g_IconStatus

// NightVision
new bool:g_hasNV[33], c_nvCost
#define OFFSET_NVG 129
#define HAS_NVGS		(1<<0)
#define USES_NVGS		(1<<8)
#define get_user_nvg(%1)    	(get_pdata_int(%1,m_iNvg) & HAS_NVGS)
/* --| Offsets for nvg */
const m_iNvg = 129;
const m_iLinuxDiff = 5;
new gMessageNVG

// Hp/Armor

#define HEALTH_SOUND		"items/smallmedkit1.wav"
#define ARMOR_SOUND		"items/ammopickup2.wav"

new c_Mod, g_Mod, c_Amount, g_Amount, b_Amount, v_Amount
new c_Cost, g_Cost, b_Cost, v_Cost, round_hp[33]
new max_hp, max_ap

// Shield

#define OFFSET_PRIMARYWEAPON 116
#define OFFSET_SECONDARYWEAPON 117

//#define OFFSET_SHIELD   510
//#define OFFSET_SHIELD_AMD64 559

#define OFFSET_LASTSEC 369
#define fm_lastsecondry(%1) get_pdata_cbase(id, OFFSET_LASTSEC)

new s_Cost, s2_Cost, s_act
new s_have[33]
new sNull = 0

// Parachute

new bool:has_parachute[33],bool:free_parachute[33], bool:g_spawn_protect[33]
new para_ent[33]
new pDetach, pFallSpeed, pEnabled, pCost, pPayback

#define PAR_SOUND		"items/ammopickup1.wav"
#define PARACHUTE_LEVEL ADMIN_LEVEL_A

// shootGrenades

enum _:Grenade
{
	Flashbang,
	He,
	Smoke,
	C4
}

new Cvars[Grenade]

new CvarsNames[Grenade][] =
{
	"flash",
	"he",
	"smoke",
	"c4"
}

const m_flC4Blow = 100

new MaxPlayers

#define FLASH_PICKUP_SND		"weapons/flashbang-2.wav"
new gMsgScreenFade

// customflashlight

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

// FragMoney

new gFragMoney, gFragMoneyLast

//

new g_eb[33], c_ebCost

new fire_Cost,CostSnark

public plugin_init()
{
	register_plugin( PLUGIN, VERSION_PLUG, AUTHOR );

	register_clcmd( "say /shop", "BiohazardShop" );
	register_clcmd( "say_team /shop", "BiohazardShop" );
	register_clcmd( "say shop", "BiohazardShop" );
	register_clcmd( "say_team shop", "BiohazardShop" );
	register_clcmd( "say /магазин", "BiohazardShop" );
	register_clcmd( "say магазин", "BiohazardShop" );
	register_clcmd( "/shop", "BiohazardShop" );
	register_clcmd( "shop", "BiohazardShop" );
	register_clcmd( "/магазин", "BiohazardShop" );
	register_clcmd( "магазин", "BiohazardShop" );
	register_clcmd( "buy_grenades", "buy_grenades" );
	register_clcmd( "/buy_grenades", "buy_grenades" );
	register_clcmd( "say buy_grenades", "buy_grenades" );
	register_clcmd( "say /buy_grenades", "buy_grenades" );
	register_clcmd( "buy_life", "buy_life" );
	register_clcmd( "/buy_life", "buy_life" );
	register_clcmd( "say buy_life", "buy_life" );
	register_clcmd( "say /buy_life", "buy_life" );
	register_clcmd( "hpshop", "HpShop" );
	register_clcmd( "/hpshop", "HpShop" );
	register_clcmd( "flshop", "FlShop" );
	register_clcmd( "/flshop", "FlShop" );
	register_clcmd( "itemshop", "ItemShop" );
	register_clcmd( "/itemshop", "ItemShop" );

	//register_clcmd( "+commandmenu", "MainMenu" );
	register_clcmd( "say /menu", "MainMenu" );
	register_clcmd( "say menu", "MainMenu" );
	register_clcmd( "say /меню", "MainMenu" );
	register_clcmd( "say меню", "MainMenu" );
	register_clcmd( "say /mainmenu", "MainMenu" );
	register_clcmd( "say mainmenu", "MainMenu" );
	register_clcmd( "say /biomenu", "MainMenu" );
	register_clcmd( "say biomenu", "MainMenu" );
	register_clcmd( "say /biohazardmenu", "MainMenu" );
	register_clcmd( "say biohazardmenu", "MainMenu" );
	register_clcmd( "/menu", "MainMenu" );
	register_clcmd( "menu", "MainMenu" );
	register_clcmd( "/меню", "MainMenu" );
	register_clcmd( "меню", "MainMenu" );
	register_clcmd( "/mainmenu", "MainMenu" );
	register_clcmd( "mainmenu", "MainMenu" );
	register_clcmd( "/biomenu", "MainMenu" );
	register_clcmd( "biomenu", "MainMenu" );
	register_clcmd( "/biohazardmenu", "MainMenu" );
	register_clcmd( "biohazardmenu", "MainMenu" );

	register_clcmd("chooseteam", "cmd_jointeam")

	register_menucmd( register_menuid( "Biohazard Shop" ), KEYS_M, "menu_shop" );
	register_menucmd( register_menuid( "HP Shop" ), KEYS_M, "hp_shop" );
	register_menucmd( register_menuid( "FL Shop" ), KEYS_M, "fl_shop" );
	register_menucmd( register_menuid( "Main Menu" ), KEYS_M, "main_menu" );

	//pCost = register_cvar("parachute_cost", "1000");
	//PcvarCost = register_cvar("amx_longjump_cost","6000");
	//c_Amount = register_cvar("bhp_amount","60");
	//c_Cost = register_cvar("bhp_cost","1250");
	//s_Cost = register_cvar("shield_cost","500");
	PcvarCostZ = register_cvar("amx_buy_zombie","5000");
	PcvarCostH = register_cvar("amx_buy_antivirus","7000");
	PcvarCostG = register_cvar("shop_grenades","3000");
	PcvarCostL = register_cvar("shop_life","3000");
	//b_Amount = register_cvar("bap_amount","75");
	//b_Cost = register_cvar("bap_cost","750");
	pScanCost = register_cvar("amx_scan_cost","500");
	pCloakCost = register_cvar("amx_cloak_cost","1500");
	c_bflCost = register_cvar("amx_flc_batcost", "50");
	c_cflCost = register_cvar("amx_flc_ccost", "150");
	c_flCost = register_cvar("amx_flc_bcost", "100");
	//gMaxPlayers = get_maxplayers();
	//pPayback = register_cvar("parachute_payback", "75");
	//lPayback = register_cvar("amx_longjump_sell","75");
	g_xtime = register_cvar( "amx_lasermine_xtime", "1" )

	register_dictionary("shop.txt");
	register_dictionary("alexalx.txt");
	register_dictionary("user.txt");

	//register_event("ResetHUD", "newround", "b")
	register_event("HLTV", "newround", "a", "1=0", "2=0")
	register_event("TextMsg", "restartround", "a", "2=#Game_will_restart_in")
	register_logevent("restartround",2,"1=Game_Commencing")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	register_event("DeathMsg", "death", "a")
	register_event("Health", "health", "b")
	gMsgItemPickup = get_user_msgid( "ItemPickup" );

    // NV
	register_dictionary("nv.txt")

	c_nvCost = register_cvar("amx_nv_cost","2000")
	gMessageNVG = get_user_msgid( "NVGToggle" )

	register_concmd("say buy_nightvision", "buy_nv")
	register_concmd("say buy_nv", "buy_nv")
 	register_concmd("buy_nightvision", "buy_nv")
	register_concmd("buy_nv", "buy_nv")

 	register_concmd("say /buy_nightvision", "buy_nv")
	register_concmd("say /buy_nv", "buy_nv")
 	register_concmd("/buy_nightvision", "buy_nv")
	register_concmd("/buy_nv", "buy_nv")

 	register_concmd("say sell_nightvision", "sell_nv")
	register_concmd("say sell_nv", "sell_nv")
 	register_concmd("sell_nightvision", "sell_nv")
	register_concmd("sell_nv", "sell_nv")

 	register_concmd("say /sell_nightvision", "sell_nv")
	register_concmd("say /sell_nv", "sell_nv")
 	register_concmd("/sell_nightvision", "sell_nv")
	register_concmd("/sell_nv", "sell_nv")

	// Explosive bullets
	register_dictionary("eb.txt")
	c_ebCost = register_cvar("amx_eb_cost","3000")

	register_concmd("say buy_eb", "buy_eb")
	register_concmd("buy_eb", "buy_eb")
	register_concmd("say /buy_eb", "buy_eb")
	register_concmd("/buy_eb", "buy_eb")

	// LongJump
	register_dictionary("jump.txt")

	register_concmd("say buy_longjump", "buy_longjump")
	register_concmd("say buy_lj", "buy_longjump")
	register_concmd("say buylongjump", "buy_longjump")
	register_concmd("say buy_jumppack", "buy_longjump")
	register_concmd("say buyjumppack", "buy_longjump")
	register_concmd("buy_longjump", "buy_longjump")
	register_concmd("buylongjump", "buy_longjump")
	register_concmd("buy_jumppack", "buy_longjump")
	register_concmd("buyjumppack", "buy_longjump")
	register_concmd("buy_lj", "buy_longjump")

	register_concmd("say /buy_longjump", "buy_longjump")
	register_concmd("say /buy_lj", "buy_longjump")
	register_concmd("say /buylongjump", "buy_longjump")
	register_concmd("say /buy_jumppack", "buy_longjump")
	register_concmd("say /buyjumppack", "buy_longjump")
	register_concmd("/buy_longjump", "buy_longjump")
	register_concmd("/buylongjump", "buy_longjump")
	register_concmd("/buy_jumppack", "buy_longjump")
	register_concmd("/buyjumppack", "buy_longjump")
	register_concmd("/buy_lj", "buy_longjump")

	register_concmd("say sell_longjump", "sell_longjump")
	register_concmd("say sell_lj", "sell_longjump")
	register_concmd("say selllongjump", "sell_longjump")
	register_concmd("say sell_jumppack", "sell_longjump")
	register_concmd("say selljumppack", "sell_longjump")
	register_concmd("sell_longjump", "sell_longjump")
	register_concmd("selllongjump", "sell_longjump")
	register_concmd("sell_jumppack", "sell_longjump")
	register_concmd("selljumppack", "sell_longjump")
	register_concmd("sell_lj", "sell_longjump")

	register_concmd("say /sell_longjump", "sell_longjump")
	register_concmd("say /sell_lj", "sell_longjump")
	register_concmd("say /selllongjump", "sell_longjump")
	register_concmd("say /sell_jumppack", "sell_longjump")
	register_concmd("say /selljumppack", "sell_longjump")
	register_concmd("/sell_longjump", "sell_longjump")
	register_concmd("/selllongjump", "sell_longjump")
	register_concmd("/sell_jumppack", "sell_longjump")
	register_concmd("/selljumppack", "sell_longjump")
	register_concmd("/sell_lj", "sell_longjump")

	register_concmd("amx_lj", "cmd_give", ADMIN_RCON, "<nick or #userid or @all>")
	register_concmd("amx_longjump", "cmd_give", ADMIN_RCON, "<nick or #userid or @all>")

	register_concmd("amx_dlj", "cmd_del", ADMIN_RCON, "<nick or #userid or @all>")
	register_concmd("amx_dellongjump", "cmd_del", ADMIN_RCON, "<nick or #userid or @all>")

	lPcvarMode = register_cvar("sv_longjump", "1")
	lPcvarCost = register_cvar("amx_longjump_cost","6000")
	lPayback = register_cvar("amx_longjump_sell","75")

	RegisterHam(Ham_Player_Jump, "player", "Player_Jump")
	set_task(0.5, "task_longjump", _, _, _, "b")
	g_IconStatus = get_user_msgid("StatusIcon")

	// Hp/Armor

	register_dictionary("hp.txt")
	c_Mod = register_cvar("sv_buyhp","1")
	c_Amount = register_cvar("bhp_amount","60")
	c_Cost = register_cvar("bhp_cost","1250")
	v_Amount = register_cvar("bap_amount","75")
	v_Cost = register_cvar("bap_cost","750")
	max_hp = register_cvar("bhp_max","255")
	max_ap = register_cvar("bap_max","100")

	register_clcmd("say buy_hp","cmd_buy")
	register_clcmd("say /buy_hp","cmd_buy")
	register_clcmd("buy_hp","cmd_buy")
	register_clcmd("/buy_hp","cmd_buy")

	register_clcmd("say buy_ap","cmd_buy2")
	register_clcmd("say /buy_ap","cmd_buy2")
	register_clcmd("buy_ap","cmd_buy2")
	register_clcmd("/buy_ap","cmd_buy2")

	register_concmd("amx_hp", "cmd_hp", ADMIN_RCON, "<nick or #userid or @all>")
	register_concmd("amx_ap", "cmd_ap", ADMIN_RCON, "<nick or #userid or @all>")

	// Shield

	register_dictionary("shield.txt")
	s_Cost = register_cvar("shield_cost","500")
	s_act = register_cvar("sv_shield","1")

	register_clcmd("say buy_shield","cmd_buy_shut")
	register_clcmd("say /buy_shield","cmd_buy_shut")
	register_clcmd("say buy_shut","cmd_buy_shut")
	register_clcmd("say /buy_shut","cmd_buy_shut")
	register_clcmd("buy_shield","cmd_buy_shut")
	register_clcmd("/buy_shield","cmd_buy_shut")
	register_clcmd("buy_shut","cmd_buy_shut")
	register_clcmd("/buy_shut","cmd_buy_shut")

	register_clcmd("drop","check_drop")

	// Parachute

	pEnabled = register_cvar("sv_parachute", "1" )
	pFallSpeed = register_cvar("parachute_fallspeed", "100")
	pDetach = register_cvar("parachute_detach", "1")

	register_dictionary("parachute.txt")

	pCost = register_cvar("parachute_cost", "1000")
	pPayback = register_cvar("parachute_payback", "75")

	register_concmd("amx_parachute", "admin_give_parachute", PARACHUTE_LEVEL, "<nick, #userid or @all>" )
	register_concmd("amx_pr", "admin_give_parachute", PARACHUTE_LEVEL, "<nick, #userid or @all>" )
	register_concmd("amx_delparachute", "admin_took_parachute", PARACHUTE_LEVEL, "<nick, #userid or @all>" )
	register_concmd("amx_dpr", "admin_took_parachute", PARACHUTE_LEVEL, "<nick, #userid or @all>" )

	register_clcmd("say", "HandleSay")
	register_clcmd("say_team", "HandleSay")
	register_clcmd("say buy_parachute", "buy_parachute")
	register_clcmd("say /buy_parachute", "buy_parachute")
	register_clcmd("say sell_parachute", "sell_parachute")
	register_clcmd("say /sell_parachute", "sell_parachute")
	register_clcmd("say give_parachute", "give_parachute")
	register_clcmd("say /give_parachute", "give_parachute")
	register_clcmd("buy_parachute", "buy_parachute")
	register_clcmd("/buy_parachute", "buy_parachute")
	register_clcmd("sell_parachute", "sell_parachute")
	register_clcmd("/sell_parachute", "sell_parachute")
	register_clcmd("give_parachute", "give_parachute")
	register_clcmd("/give_parachute", "give_parachute")
	register_clcmd("say buy_pr", "buy_parachute")
	register_clcmd("say /buy_pr", "buy_parachute")
	register_clcmd("say sell_pr", "sell_parachute")
	register_clcmd("say /sell_pr", "sell_parachute")
	register_clcmd("say give_pr", "give_parachute")
	register_clcmd("say /give_pr", "give_parachute")
	register_clcmd("buy_pr", "buy_parachute")
	register_clcmd("/buy_pr", "buy_parachute")
	register_clcmd("sell_pr", "sell_parachute")
	register_clcmd("/sell_pr", "sell_parachute")
	register_clcmd("give_pr", "give_parachute")
	register_clcmd("/give_pr", "give_parachute")

	RegisterHam(Ham_Spawn, "player", "newSpawn", 1)
	//register_event("ResetHUD", "newSpawn", "be")
	//register_event("DeathMsg", "death_event", "a")
	//register_event("TextMsg", "restartround", "a", "2=#Game_will_restart_in")
	//register_logevent("restartround",2,"1=Game_Commencing")

	//Setup jtp10181 CVAR
	new cvarString[256], shortName[16]
	copy(shortName,15,"chute")

	register_cvar("jtp10181","",FCVAR_SERVER|FCVAR_SPONLY)
	get_cvar_string("jtp10181",cvarString,255)

	if (strlen(cvarString) == 0) {
		formatex(cvarString,255,shortName)
		set_cvar_string("jtp10181",cvarString)
	}
	else if (contain(cvarString,shortName) == -1) {
		format(cvarString,255,"%s,%s",cvarString, shortName)
		set_cvar_string("jtp10181",cvarString)
	}

	// shootGrenades

	new const Version[] = "1.0"
	RegisterHam(Ham_TraceAttack,"worldspawn","globalTraceAttack")
	gMsgScreenFade = get_user_msgid("ScreenFade");
	register_cvar("shootGrenades_version",Version,FCVAR_SERVER|FCVAR_SPONLY)

	// customflashlight

	g_batcost = register_cvar("amx_flc_batcost", "50")
	g_cflashcost = register_cvar("amx_flc_ccost", "150")
	g_bflashcost = register_cvar("amx_flc_bcost", "100")

	//register_concmd("flashlight_set", "plugin_settings", ADMIN_CFG)

	register_impulse(100, "Impulse_100")

	register_menucmd( register_menuid( "Flashlight" ), KEYS_M, "menuf_shop" )
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
	//RegisterHam(Ham_Spawn, "player", "player_spawn", 1)

	register_dictionary("flashlight.txt")

	//register_event("HLTV", "Event_HLTV_newround", "a", "1=0", "2=0")
	//register_event("TextMsg", "restartround", "a", "2=#Game_will_restart_in")
	//register_logevent("restartround",2,"1=Game_Commencing")
	//register_event("DeathMsg", "Event_DeathMsg", "a")

	plugin_precfg()

	// FragMoney

	gFragMoney = register_cvar( "amx_frag_money", "1500" )
	gFragMoneyLast = register_cvar( "amx_frag_money_last", "2000" )

	//

	fire_Cost = register_cvar("fire_cost","2500")
	CostSnark = register_cvar( "bio_costsnark"           , "1000"   );

}

stock is_predator(id) {
	if (is_user_zombie(id) && (get_class(id, "StrongPredator") || get_class(id, "RegenPredator") || get_class(id, "Predator")))
		return true;
	return false;
}

stock is_noburn(id) {
	if (is_user_zombie(id) && (get_class(id,"FireLeaper") || get_class(id,"Diablo") || get_class(id, "Nurse")))
		return true;
	return false;
}

public plugin_cfg()
{
	new cvarName[15]

	for(new i=0;i<Grenade;i++)
	{
		formatex(cvarName,charsmax(cvarName),"shoot_%s",CvarsNames[i])
		Cvars[i] = register_cvar(cvarName,"1")
	}

	MaxPlayers = get_maxplayers()
}

public plugin_natives()
{
	register_native("has_par","native_haspar",1)
	register_native("reset_par","native_resetpar",1)
	register_native("para_ent","native_para_ent",1)
	register_native("flash_user","Flash",1)
	register_native("reset_flash","native_reset",1);
	register_native("spawn_protect","native_spawnprotect",1);
	register_native("has_nv","native_nv",1);
	register_native("has_eb","native_eb",1);
}

public native_spawnprotect(id)
	return g_spawn_protect[id];

public cmd_jointeam(id) {

	if(get_user_team(id) == CS_TEAM_SPECTATOR || get_user_team(id) == CS_TEAM_UNASSIGNED)
		return PLUGIN_CONTINUE

	client_cmd(id, "menu");
	return PLUGIN_HANDLED
}

public plugin_precache()
{
	precache_sound( G_PICKUP_SND );
	precache_sound( LJ_PICKUP_SND );
	precache_sound( HEALTH_SOUND );
	precache_sound( ARMOR_SOUND );
	precache_model("models/parachute.mdl")
	precache_sound( PAR_SOUND );
	precache_sound( FLASH_PICKUP_SND );
	precache_sound(SOUND_FLASHLIGHT_ON)
	precache_sound(SOUND_FLASHLIGHT_OFF)
}

public restartround()
{

	new players[32], num
	get_players(players, num)

	for (new i=0; i<num; i++) {
		//if (is_user_connected(players[i])) {
		g_hasLongJump[players[i]] = false
		g_hasLongJumpVip[players[i]] = false
		g_hasLongJumpFree[players[i]] = false
		g_LongJumpEnergy[players[i]] = 0
		g_LongJumpLowEnergy[players[i]] = false
		g_LongJumpEnergyTime[players[i]] = 0
		s_have[players[i]] = 0
		g_hasNV[players[i]] = false
		if (is_user_vip(players[i]))
			round_hp[players[i]] = 150
		else
			round_hp[players[i]] = 100
		parachute_reset(players[i])
		reset(players[i])
		if (get_vip_flags( players[i] ) & VIP_FLAG_C)
			g_bFlashLight[players[i]] = true
		else
			g_bFlashLight[players[i]] = false
		g_cFlashLight[players[i]] = false
		g_eb[players[i]] = false
		set_cloak(players[i],false)
		//}
	}
}

// autoreload_on_newround
#define m_pNext	42
#define m_fInReload	54

#define m_flNextAttack			83
#define m_rgpPlayerItems_Slot1	368
#define m_rgpPlayerItems_Slot2	369
//

public native_para_ent(id) {
	if( !is_user_alive(id) ) return 0
	return para_ent[id]
}

public newSpawn(id)
{

	if( !is_user_alive(id) )
	{
		return
	}

	if(para_ent[id] > 0) {
		//parachute_reset(id)
		remove_entity(para_ent[id])
		//set_user_gravity(id, 1.0)
		para_ent[id] = 0
	}

	if (get_vip_flags(id) & VIP_FLAG_C || /*access(id,PARACHUTE_LEVEL) ||*/ get_pcvar_num(pCost) <= 0) {
		has_parachute[id] = true
		//set_view(id, CAMERA_3RDPERSON)
	}

	if (get_vip_flags(id) & VIP_FLAG_C)
		free_parachute[id] = true
	else
		free_parachute[id] = false

	if (get_vip_flags( id ) & VIP_FLAG_C && !g_bFlashLight[id] && !g_cFlashLight[id]) {
		g_bFlashLight[id] = true;
		if (g_dFlashLight[id]) {
			FlashlightTurnOff(id,false)
			FlashlightTurnOn(id,false)
		}
	}

	if (!game_started()) {
		if (is_user_vip(id) && round_hp[id]<150)
			set_user_health(id,150)
		else
			set_user_health(id,round_hp[id])

		if (is_terminator(id)&&round_hp[id]<700)
			set_user_health(id,700)
	}

	set_pdata_float(id, m_flNextAttack, -0.001, 5)

	new iWeapon
	for(new i=m_rgpPlayerItems_Slot1; i<=m_rgpPlayerItems_Slot2; i++)
	{
		iWeapon = get_pdata_cbase(id, i, 5)
		while( pev_valid(iWeapon) )
		{
			set_pdata_int(iWeapon, m_fInReload, 1, 4)
			ExecuteHamB(Ham_Item_PostFrame, iWeapon)
			iWeapon = get_pdata_cbase(iWeapon, m_pNext, 4)
		}
	}

	g_spawn_protect[id] = false;

}

public client_connect(id)
{
	g_hasLongJump[id] = false
	g_hasLongJumpVip[id] = false
	g_hasLongJumpFree[id] = false
	g_LongJumpEnergy[id] = 0
	g_LongJumpEnergyTime[id] = 0
	g_LongJumpLowEnergy[id] = false
	g_spawn_protect[id] = false
	s_have[id] = 0
	round_hp[id] = 100
	g_hasNV[id] = false
	g_eb[id] = false
	parachute_reset(id)
	//return PLUGIN_HANDLED
}

public client_putinserver(id)
{
	reset(id)
	g_cFlashLight[id] = false
	g_bFlashLight[id] = false
	g_spawn_protect[id] = false
	set_cloak(id,false)
}

public client_disconnect(id)
{
	g_hasLongJump[id] = false
	g_hasLongJumpVip[id] = false
	g_hasLongJumpFree[id] = false
	g_LongJumpEnergy[id] = 0
	g_LongJumpEnergyTime[id] = 0
	g_LongJumpLowEnergy[id] = false
	s_have[id] = 0
	round_hp[id] = 100
	parachute_reset(id)
	g_iFlashBattery[id] = 100
	g_flFlashLightTime[id] = 0.0
	g_cFlashLight[id] = false
	g_bFlashLight[id] = false
	g_spawn_protect[id] = false
	g_hasNV[id] = false
	g_eb[id] = false
	//return PLUGIN_HANDLED
}

public newround() {
	set_task(0.1,"newround_init")
}

public newround_init() {

	new players[32], num
	get_players(players, num)

	for (new id=0;id<num;id++) {
		//if (is_user_connected(id)) {
		if (g_hasLongJump[players[id]] || g_hasLongJumpFree[players[id]]) {
			set_longjump(players[id],false,g_hasLongJumpFree[players[id]]);
		}
		s_have[players[id]] = 0
		reset(players[id])

		if (get_vip_flags(id) & VIP_FLAG_C || /*access(id,PARACHUTE_LEVEL) ||*/ get_pcvar_num(pCost) <= 0) {
			has_parachute[id] = true
			//set_view(id, CAMERA_3RDPERSON)
		}
		//}
	}

}

public logevent_round_end() {

	new players[32], num
	get_players(players, num)

	for (new i=0;i<num;i++) {
		//if (is_user_connected(i)) {
		if (is_user_zombie(players[i]) || !is_user_alive(players[i]) || get_user_health(players[i]) < 100 && !is_user_vip(players[i]))
			round_hp[players[i]] = 100;
		else if (is_user_zombie(players[i]) || !is_user_alive(players[i]) || get_user_health(players[i]) < 150 && is_user_vip(players[i]))
			round_hp[players[i]] = 150;
		else
			round_hp[players[i]] = get_user_health(players[i]);
		//}
	}

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

	//parachute.mdl animation information
	//0 - deploy - 84 frames
	//1 - idle - 39 frames
	//2 - detach - 29 frames
	if (!get_pcvar_num(pEnabled)) return
	if (!is_user_alive(id) || !has_parachute[id]) return
	new Float:grav
	if (drug_grav(id) == 0.0) {
		grav = get_class_data(get_user_class(id), DATA_GRAVITY);
		if (!is_user_zombie(id)) grav = 1.0;
	} else {
		grav = drug_grav(id);
	}

	new Float:fallspeed = get_pcvar_float(pFallSpeed) * -1.0
	new Float:frame

	new button = get_user_button(id)
	new oldbutton = get_user_oldbutton(id)
	new flags = get_entity_flags(id)

	if (para_ent[id] > 0 && (flags & FL_ONGROUND)) {

		if (get_pcvar_num(pDetach)) {

			if (get_user_gravity(id) == 0.1) set_user_gravity(id, grav)

			if (entity_get_int(para_ent[id],EV_INT_sequence) != 2) {
				entity_set_int(para_ent[id], EV_INT_sequence, 2)
				entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
				entity_set_float(para_ent[id], EV_FL_frame, 0.0)
				entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
				entity_set_float(para_ent[id], EV_FL_animtime, 0.0)
				entity_set_float(para_ent[id], EV_FL_framerate, 0.0)
				return
			}

			frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 2.0
			entity_set_float(para_ent[id],EV_FL_fuser1,frame)
			entity_set_float(para_ent[id],EV_FL_frame,frame)

			if (frame > 254.0) {
				remove_entity(para_ent[id])
				para_ent[id] = 0
			}
		}
		else {
			remove_entity(para_ent[id])
			set_user_gravity(id, grav)
			para_ent[id] = 0
		}

		return
	}

	if (button & IN_USE) {

		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)

		if (velocity[2] < 0.0) {

			if(para_ent[id] <= 0) {
				para_ent[id] = create_entity("info_target")
				if(para_ent[id] > 0) {
					entity_set_string(para_ent[id],EV_SZ_classname,"parachute")
					entity_set_edict(para_ent[id], EV_ENT_aiment, id)
					entity_set_edict(para_ent[id], EV_ENT_owner, id)
					entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW)
					entity_set_model(para_ent[id], "models/parachute.mdl")
					entity_set_int(para_ent[id], EV_INT_sequence, 0)
					entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
					entity_set_float(para_ent[id], EV_FL_frame, 0.0)
					entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
				}
			}

			if (para_ent[id] > 0) {

				entity_set_int(id, EV_INT_sequence, 3)
				entity_set_int(id, EV_INT_gaitsequence, 1)
				entity_set_float(id, EV_FL_frame, 1.0)
				entity_set_float(id, EV_FL_framerate, 1.0)
				set_user_gravity(id, 0.1)

				velocity[2] = (velocity[2] + 40.0 < fallspeed) ? velocity[2] + 40.0 : fallspeed
				entity_set_vector(id, EV_VEC_velocity, velocity)

				if (entity_get_int(para_ent[id],EV_INT_sequence) == 0) {

					frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 1.0
					entity_set_float(para_ent[id],EV_FL_fuser1,frame)
					entity_set_float(para_ent[id],EV_FL_frame,frame)

					if (frame > 100.0) {
						entity_set_float(para_ent[id], EV_FL_animtime, 0.0)
						entity_set_float(para_ent[id], EV_FL_framerate, 0.4)
						entity_set_int(para_ent[id], EV_INT_sequence, 1)
						entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
						entity_set_float(para_ent[id], EV_FL_frame, 0.0)
						entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
					}
				}
			}
		}
		else if (para_ent[id] > 0) {
			remove_entity(para_ent[id])
			set_user_gravity(id, grav)
			para_ent[id] = 0
		}
	}
	else if ((oldbutton & IN_USE) && para_ent[id] > 0 ) {
		remove_entity(para_ent[id])
		set_user_gravity(id, grav)
		para_ent[id] = 0
	}
}

public event_infect(id) {
	s_have[id] = 0
}

public death()
{
	new id = read_data(2)
	g_hasLongJump[id] = false
	g_hasLongJumpVip[id] = false
	g_hasLongJumpFree[id] = false
	g_LongJumpEnergy[id] = 0
	g_LongJumpEnergyTime[id] = 0
	g_LongJumpLowEnergy[id] = false
	s_have[id] = 0
	if (is_user_vip(id))
		round_hp[id] = 150
	else
		round_hp[id] = 100
	parachute_reset(id)
	reset(id)
	g_cFlashLight[id] = false
	g_bFlashLight[id] = false
	g_dFlashLight[id] = false

	g_hasNV[id] = false
	g_eb[id] = false

	message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, id)
	write_byte(0)
	write_string("item_longjump")
	write_byte(0)
	write_byte(0)
	write_byte(0)
	message_end()

	static a, v
	a = read_data(1) //attacker
	v = read_data(2) //victim
	if(a != v && 0 < a < 33 && 0 < v < 33 && is_user_alive(a) && cs_get_user_team(a) != cs_get_user_team(v) && !is_user_zombie(a) && is_user_zombie(v)) {
		if (maxzombies())
			set_task(0.1,"money2",a);
		else
			set_task(0.1,"money",a);
	}
}

public health(id)
{
	if (!game_started()) {
	if (is_user_zombie(id) || get_user_health(id) < 100 && !is_user_vip(id))
		round_hp[id] = 100
	else if (is_user_zombie(id) || get_user_health(id) < 150 && is_user_vip(id))
		round_hp[id] = 150
	else
		round_hp[id] = get_user_health(id)
	}
}

public MainMenu( id )
{

	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "\rBiohazard Menu \yv%s", VERSION_MENU );
	new menu = menu_create( szText, "main_menu" );

	formatex( szText, charsmax( szText ), "%L", id, "SHOP4_1");
	menu_additem( menu, szText, "1", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "SHOP4_2");
	menu_additem( menu, szText, "2", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "SHOP4_3");
	menu_additem( menu, szText, "3", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "SHOP4_4");
	menu_additem( menu, szText, "4", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "SHOP4_5");
	menu_additem( menu, szText, "5", 0 );


	if (get_user_team(id) != CS_TEAM_SPECTATOR && get_user_team(id) != CS_TEAM_UNASSIGNED) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP4_6");
		menu_additem( menu, szText, "6", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP4_6");
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "6", ADMIN_ADMIN );
	}

	formatex( szText, charsmax( szText ), "%L", id, "SHOP4_7");
	menu_additem( menu, szText, "7", 0 );

	if (is_user_alive(id) && game_started()) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP4_8");
		menu_additem( menu, szText, "8", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP4_8");
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "8", ADMIN_ADMIN );
	}

	formatex( szText, charsmax( szText ), "%L", id, "SHOP4_9");
	menu_additem( menu, szText, "9", 0 );

	//menu_addblank(menu,1);

	formatex( szText, charsmax( szText ), "%L", id, "SHOP_EXIT");
	menu_additem( menu, szText, "0", 0 );

	//menu_setprop( menu, MPROP_EXIT, MEXIT_ALL); //, MEXIT_ALL
	//new string[100];
	//formatex( string, sizeof string - 1, "%L", id, "SHOP_EXIT" );
	//menu_setprop( menu, MPROP_EXITNAME, string );

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
			client_cmd(id, "/class");
			menu_destroy( menu );
		}
		case 3:
		{
			client_cmd(id, "/guns");
			menu_destroy( menu );
		}
		case 4:
		{
			client_cmd(id, "/help");
			menu_destroy( menu );
		}
		case 5:
		{
			client_cmd(id, "/commands");
			menu_destroy( menu );
		}
		case 6:
		{
			if (get_user_team(id) != CS_TEAM_SPECTATOR && get_user_team(id) != CS_TEAM_UNASSIGNED) {
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
			client_cmd(id, "/rules");
			menu_destroy( menu );
		}
		case 8:
		{
			client_cmd(id, "unstuck");
			menu_destroy( menu );
		}
		case 9:
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
		case 0:
		{
			menu_destroy( menu );
		}
	}
	return PLUGIN_HANDLED;
}

public HpShop( id )
{

	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "\rBiohazard Shop \yv%s", VERSION );
	new menu = menu_create( szText, "hp_shop" );

	new h_Cost
	new hp = get_user_health(id)
	new new_hp = hp+get_pcvar_num( c_Amount )
	new back_hp = 0
	if (new_hp>get_pcvar_num( max_hp ))
	{
		back_hp = (new_hp-get_pcvar_num( max_hp ))*(get_pcvar_num(c_Cost)/get_pcvar_num( c_Amount ))
	}

	if (back_hp!=0)
		h_Cost = get_pcvar_num(c_Cost)-back_hp
	else
		h_Cost = get_pcvar_num(c_Cost)

	if (get_user_health(id) < get_pcvar_num( max_hp ) && !is_user_zombie(id) && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP2_1", get_pcvar_num( c_Amount ), get_pcvar_num( max_hp ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(h_Cost * 0.8) : h_Cost));
		menu_additem( menu, szText, "1", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP2_1", get_pcvar_num( c_Amount ), get_pcvar_num( max_hp ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num(c_Cost) * 0.8) : get_pcvar_num( c_Cost )));
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "1", ADMIN_ADMIN );
	}

	new b_Cost
	new ap = get_user_armor(id)
	new new_ap = ap+get_pcvar_num( v_Amount )
	new back_ap = 0
	if (new_ap>get_pcvar_num( max_ap ))
	{
		back_ap = (new_ap-get_pcvar_num( max_ap ))*(get_pcvar_num(v_Cost)/get_pcvar_num( v_Amount ))
	}

	if (back_ap!=0)
		b_Cost = get_pcvar_num(v_Cost)-back_ap
	else
		b_Cost = get_pcvar_num(v_Cost)

	if (get_user_armor(id) < get_pcvar_num( max_ap ) && !is_user_zombie(id) && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP2_2", get_pcvar_num( v_Amount ), get_pcvar_num( max_ap ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(b_Cost * 0.8) : b_Cost));
		menu_additem( menu, szText, "2", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP2_2", get_pcvar_num( v_Amount ), get_pcvar_num( max_ap ), (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num(v_Cost) * 0.8) : get_pcvar_num( v_Cost )));
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "2", ADMIN_ADMIN );
	}

	if (is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP2_3");
		menu_additem( menu, szText, "3", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP2_3");
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "3", ADMIN_ADMIN );
	}

	formatex( szText, charsmax( szText ), "%L", id, "SHOP_BACK");
	menu_additem( menu, szText, "9", 0 );

	//menu_addblank(menu,1);

	formatex( szText, charsmax( szText ), "%L", id, "SHOP_EXIT");
	menu_additem( menu, szText, "0", 0 );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL); //, MEXIT_ALL
	new string[100];
	formatex( string, sizeof string - 1, "%L", id, "SHOP_EXIT" );
	menu_setprop( menu, MPROP_EXITNAME, string );

	new num = 0;
	menu_setprop( menu, MPROP_PERPAGE, num);

	//formatex( szText, charsmax( szText ), "%L", id, "SHOP_END" );
	menu_display( id, menu, 0 );

	return PLUGIN_HANDLED;
}

public hp_shop( id, menu, item )
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
			//client_cmd(id, "buy_hp");
			cmd_buy(id)
			client_cmd(id, "hpshop");
			menu_destroy( menu );
		}
		case 2:
		{
			//client_cmd(id, "buy_ap");
			cmd_buy2(id)
			client_cmd(id, "hpshop");
			menu_destroy( menu );
		}
		case 3:
		{
			client_cmd(id, "stim_menu");
			menu_destroy( menu );
		}
		case 9:
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

public FlShop( id )
{

	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "\rBiohazard Shop \yv%s", VERSION );
	new menu = menu_create( szText, "fl_shop" );

	if (!is_user_zombie(id) && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP3_1", get_pcvar_num( c_flCost ));
		menu_additem( menu, szText, "1", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP3_1", get_pcvar_num( c_flCost ));
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "1", ADMIN_ADMIN );
	}

	if (!is_user_zombie(id) && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP3_2", get_pcvar_num( c_cflCost ));
		menu_additem( menu, szText, "2", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP3_2", get_pcvar_num( c_cflCost ));
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "2", ADMIN_ADMIN );
	}

	if (!is_user_zombie(id) && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP3_3", get_pcvar_num( c_bflCost ));
		menu_additem( menu, szText, "3", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP3_3", get_pcvar_num( c_bflCost ));
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "3", ADMIN_ADMIN );
	}

	formatex( szText, charsmax( szText ), "%L", id, "SHOP_BACK");
	menu_additem( menu, szText, "9", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "SHOP_EXIT");
	menu_additem( menu, szText, "0", 0 );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL); //, MEXIT_ALL
	new string[100];
	formatex( string, sizeof string - 1, "%L", id, "SHOP_EXIT" );
	menu_setprop( menu, MPROP_EXITNAME, string );

	new num = 0;
	menu_setprop( menu, MPROP_PERPAGE, num);

	//formatex( szText, charsmax( szText ), "%L", id, "SHOP_END" );
	menu_display( id, menu, 0 );

	return PLUGIN_HANDLED;
}

public fl_shop( id, menu, item )
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
			client_cmd(id, "buy_fl");
			client_cmd(id, "flshop");
			menu_destroy( menu );
		}
		case 2:
		{
			client_cmd(id, "buy_cfl");
			client_cmd(id, "flshop");
			menu_destroy( menu );
		}
		case 3:
		{
			client_cmd(id, "buy_bfl");
			client_cmd(id, "flshop");
			menu_destroy( menu );
		}
		case 9:
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

public ItemShop( id )
{

	new pCostnull = 0;
	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "\rBiohazard Shop \yv%s", VERSION );
	new menu = menu_create( szText, "item_shop" );

	if (is_user_alive(id) && get_pcvar_num(pEnabled)) {
		if (has_parachute[id] && !free_parachute[id]) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_1B", (get_vip_flags(id) & VIP_FLAG_C ? pCostnull : floatround(get_pcvar_num(pCost) * (get_pcvar_num(pPayback) / 100.0))));
			menu_additem( menu, szText, "1", 0 );
		} else if (has_parachute[id] && free_parachute[id]) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_1B", (get_vip_flags(id) & VIP_FLAG_C ? pCostnull : floatround(get_pcvar_num(pCost) * (get_pcvar_num(pPayback) / 100.0))));
			replace_all(szText, charsmax( szText ), "\w", "");
			replace_all(szText, charsmax( szText ), "\r", "");
			replace_all(szText, charsmax( szText ), "\y", "");
			menu_additem( menu, szText, "1", ADMIN_ADMIN );
		} else {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_1A", (get_vip_flags(id) & VIP_FLAG_C ? pCostnull : get_pcvar_num( pCost )));
			menu_additem( menu, szText, "1", 0 );
		}
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_1A", (get_vip_flags(id) & VIP_FLAG_C ? pCostnull : get_pcvar_num( pCost )));
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "1", ADMIN_ADMIN );
	}

	if (is_user_alive(id) && get_pcvar_num(lPcvarMode)) {
		if (g_hasLongJump[id] && !g_hasLongJumpFree[id]) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_2B", (get_vip_flags(id) & VIP_FLAG_C || g_hasLongJumpVip[id] ? floatround((get_pcvar_num( lPcvarCost ) * 0.7) * (get_pcvar_num(lPayback) / 100.0)) : floatround(get_pcvar_num(lPcvarCost) * (get_pcvar_num(lPayback) / 100.0))));
			menu_additem( menu, szText, "2", 0 );
		} else if (g_hasLongJump[id] && g_hasLongJumpFree[id]) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_2B", (get_vip_flags(id) & VIP_FLAG_C || g_hasLongJumpVip[id] ? floatround((get_pcvar_num( lPcvarCost ) * 0.7) * (get_pcvar_num(lPayback) / 100.0)) : floatround(get_pcvar_num(lPcvarCost) * (get_pcvar_num(lPayback) / 100.0))));
			replace_all(szText, charsmax( szText ), "\w", "");
			replace_all(szText, charsmax( szText ), "\r", "");
			replace_all(szText, charsmax( szText ), "\y", "");
			menu_additem( menu, szText, "2", ADMIN_ADMIN );
		} else {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_2A", (get_vip_flags(id) & VIP_FLAG_C ? floatround(get_pcvar_num( lPcvarCost ) * 0.7) : get_pcvar_num( lPcvarCost )));
			menu_additem( menu, szText, "2", 0 );
		}
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_2A", (get_vip_flags(id) & VIP_FLAG_C ? floatround(get_pcvar_num( lPcvarCost ) * 0.7) : get_pcvar_num( lPcvarCost )));
		//formatex( szText, charsmax( szText ), "Steam error: 0x000%i346%i",random_num(0,9),random_num(0,9))
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "2", ADMIN_ADMIN );
	}

	if (!is_user_zombie(id) && is_user_alive(id)) {
		if (g_hasNV[id]) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_I2b", get_pcvar_num( c_nvCost )/2);
			menu_additem( menu, szText, "3", 0 );
		} else {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_I2", get_pcvar_num( c_nvCost ));
			menu_additem( menu, szText, "3", 0 );
		}
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_I2", get_pcvar_num( c_nvCost ));
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "3", ADMIN_ADMIN );
	}

	formatex( szText, charsmax( szText ), "%L", id, "SHOP_BACK");
	menu_additem( menu, szText, "9", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "SHOP_EXIT");
	menu_additem( menu, szText, "0", 0 );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL); //, MEXIT_ALL
	new string[100];
	formatex( string, sizeof string - 1, "%L", id, "SHOP_EXIT" );
	menu_setprop( menu, MPROP_EXITNAME, string );

	new num = 0;
	menu_setprop( menu, MPROP_PERPAGE, num);

	//formatex( szText, charsmax( szText ), "%L", id, "SHOP_END" );
	menu_display( id, menu, 0 );

	return PLUGIN_HANDLED;
}

public item_shop( id, menu, item )
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
			if (native_haspar(id)) {
				client_cmd(id, "sell_parachute");
			} else {
				client_cmd(id, "buy_parachute");
			}
			//client_cmd(id, "shop");
			menu_destroy( menu );
		}
		case 2:
		{
			if (g_hasLongJump[id] || g_hasLongJumpFree[id]) {
				//client_cmd(id, "sell_longjump");
				sell_longjump(id)
			} else {
				//client_cmd(id, "buy_longjump");
				buy_longjump(id)
			}
			//client_cmd(id, "shop");
			menu_destroy( menu );
		}
		case 3:
		{
			if (g_hasNV[id]) {
				client_cmd(id, "sell_nv");
			} else {
				client_cmd(id, "buy_nv");
			}
			//client_cmd(id, "itemshop");
			menu_destroy( menu );
		}
		case 9:
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

public BiohazardShop( id )
{

	new pCostnull = 0;
	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "\rBiohazard Shop \yv%s", VERSION );
	new menu = menu_create( szText, "menu_shop" );

	if (is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_I0");
		menu_additem( menu, szText, "1", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_I0");
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "1", ADMIN_ADMIN );
	}

	/*if (is_user_zombie(id)) {
		if (get_class(id,"Gonome") || get_class(id,"FastGonome")) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_I3b", 2000);
		} else {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_I3", 2000);
		}
	} else {*/
	formatex( szText, charsmax( szText ), "%L", id, "SHOP_I1", get_pcvar_num(c_ebCost));
	//}
	if (!is_user_alive(id) || is_user_zombie(id)) {
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "2", ADMIN_ADMIN );
	} else {
		menu_additem( menu, szText, "2", 0 );
	}

	//formatex( szText, charsmax( szText ), "Steam error: 0x000%i346%i",random_num(0,9),random_num(0,9))

	if (!is_user_zombie(id) && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_3");
		menu_additem( menu, szText, "3", 0 );
	} else if (is_user_zombie(id) && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP2_3");
		menu_additem( menu, szText, "3", 0 );
	} else if (get_user_team(id) == CS_TEAM_T || get_user_team(id) == CS_TEAM_CT) {
		if (!is_user_alive(id) && game_started()) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_3d", get_pcvar_num( PcvarCostL ));
			menu_additem( menu, szText, "3", 0 );
		} else if (is_user_alive(id) && is_user_zombie(id)) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_3");
			replace_all(szText, charsmax( szText ), "\w", "");
			replace_all(szText, charsmax( szText ), "\r", "");
			replace_all(szText, charsmax( szText ), "\y", "");
			menu_additem( menu, szText, "3", ADMIN_ADMIN );
		} else {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_3d", get_pcvar_num( PcvarCostL ));
			replace_all(szText, charsmax( szText ), "\w", "");
			replace_all(szText, charsmax( szText ), "\r", "");
			replace_all(szText, charsmax( szText ), "\y", "");
			menu_additem( menu, szText, "3", ADMIN_ADMIN );
		}
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_3d", get_pcvar_num( PcvarCostL ));
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "3", ADMIN_ADMIN );
	}

	if (!is_user_zombie(id) && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_4");
		menu_additem( menu, szText, "4", 0 );
	} else if (is_user_zombie(id) && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_3z", get_pcvar_num( fire_Cost ));
		if (is_noburn(id)) {
			replace_all(szText, charsmax( szText ), "\w", "");
			replace_all(szText, charsmax( szText ), "\r", "");
			replace_all(szText, charsmax( szText ), "\y", "");
			menu_additem( menu, szText, "4", ADMIN_ADMIN );
		} else {
			menu_additem( menu, szText, "4", 0 );
		}
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP2_3");
		menu_additem( menu, szText, "4", 0 );
	}

	if (get_pcvar_num(s_act) && !is_user_zombie(id) && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_5", (get_vip_flags(id) & VIP_FLAG_C ? pCostnull : get_pcvar_num( s_Cost )));
		menu_additem( menu, szText, "5", 0 );
	} else if (is_user_zombie(id) && is_user_alive(id)) {
		if (get_class_id("Alien") == get_user_class(id)) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_5a", (get_vip_flags(id) & VIP_FLAG_C ? 100 : 125));
			menu_additem( menu, szText, "5", 0 );
		} else {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_5z", (get_vip_flags(id) & VIP_FLAG_C ? floatround(get_pcvar_num(CostSnark) * 0.8) : get_pcvar_num( CostSnark )));
			menu_additem( menu, szText, "5", 0 );
		}
	} else {
		if (!is_user_zombie(id))
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_5", (get_vip_flags(id) & VIP_FLAG_C ? pCostnull : get_pcvar_num( s_Cost )));
		else
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_5z", (get_vip_flags(id) & VIP_FLAG_C ? floatround(get_pcvar_num(CostSnark) * 0.8) : get_pcvar_num( CostSnark )));
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "5", ADMIN_ADMIN );
	}

	new mhours[6]
	get_time("%H", mhours, 5)
	new hrs = str_to_num(mhours)

	if (get_cvar_num("amx_lasermine") && game_started() && !((hrs >= 23 || hrs < 6) && get_pcvar_num(g_xtime) == 1 || get_pcvar_num(g_xtime) == 2) && lm_count(id)>0) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_6");
		formatex( szText, charsmax( szText ), "%s \y+%d$", szText, lm_cost(id));
		menu_additem( menu, szText, "6", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_6");
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		if (get_cvar_num("amx_lasermine")) if ((hrs >= 23 || hrs < 6) && get_pcvar_num(g_xtime) == 1 || get_pcvar_num(g_xtime) == 2)
			formatex( szText, charsmax( szText ), "%s \r(x-time)", szText);
		else if (lm_count(id)>0) {
			formatex( szText, charsmax( szText ), "%s +%d$", szText, lm_cost(id));
		}
		menu_additem( menu, szText, "6", ADMIN_ADMIN );
	}

	if (is_user_alive(id)) {
		if (is_user_zombie(id)) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_7A", get_pcvar_num( PcvarCostH ) );
			menu_additem( menu, szText, "7", 0 );
		} else {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_7B", get_pcvar_num( PcvarCostZ ) );
			menu_additem( menu, szText, "7", 0 );
		}
	} else {
		if (is_user_zombie(id)) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_7A", get_pcvar_num( PcvarCostH ) );
			replace_all(szText, charsmax( szText ), "\w", "");
			replace_all(szText, charsmax( szText ), "\r", "");
			replace_all(szText, charsmax( szText ), "\y", "");
			menu_additem( menu, szText, "7", ADMIN_ADMIN );
		} else {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_7B", get_pcvar_num( PcvarCostZ ) );
			replace_all(szText, charsmax( szText ), "\w", "");
			replace_all(szText, charsmax( szText ), "\r", "");
			replace_all(szText, charsmax( szText ), "\y", "");
			menu_additem( menu, szText, "7", ADMIN_ADMIN );
		}
	}

	if (!is_user_zombie(id) && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_8", get_pcvar_num( PcvarCostG ) );
		menu_additem( menu, szText, "8", 0 );
	} else {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_8", get_pcvar_num( PcvarCostG ) );
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "8", ADMIN_ADMIN );
	}

	if (!game_started() && is_user_alive(id)) {
		formatex( szText, charsmax( szText ), "%L", id, "SHOP_9", (get_vip_flags(id) & VIP_FLAG_C ? get_pcvar_num( pScanCost )/2 : get_pcvar_num( pScanCost )));
		menu_additem( menu, szText, "9", 0 );
	} else if (game_started() && is_user_alive(id) && !get_cloak(id)) {
		formatex( szText, charsmax( szText ), "%L", id, (is_predator(id) ? "SHOP_9sb" : "SHOP_9s"), (get_vip_flags(id) & VIP_FLAG_C ? floatround(get_pcvar_num( pCloakCost )*0.7) : get_pcvar_num( pCloakCost ) ));
		menu_additem( menu, szText, "9", 0 );
	} else if (game_started() && is_user_alive(id) && get_cloak(id)) {
		formatex( szText, charsmax( szText ), "%L", id, (is_predator(id) ? "SHOP_9s2b" : "SHOP_9s2"), floatround((get_vipcloak(id) ? floatround(get_pcvar_num( pCloakCost )*0.7 * 75 / 100.0) : get_pcvar_num( pCloakCost )) * 75 / 100.0) );
		menu_additem( menu, szText, "9", 0 );
	} else {
		if (game_started()) {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_9s", (get_vip_flags(id) & VIP_FLAG_C ? floatround(get_pcvar_num( pCloakCost )*0.7) : get_pcvar_num( pCloakCost ) ));
		} else {
			formatex( szText, charsmax( szText ), "%L", id, "SHOP_9", (get_vip_flags(id) & VIP_FLAG_C ? get_pcvar_num( pScanCost )/2 : get_pcvar_num( pScanCost )));
		}
		replace_all(szText, charsmax( szText ), "\w", "");
		replace_all(szText, charsmax( szText ), "\r", "");
		replace_all(szText, charsmax( szText ), "\y", "");
		menu_additem( menu, szText, "9", ADMIN_ADMIN );
	}

	//formatex( szText, charsmax( szText ), "");
	//menu_additem( menu, szText, "0", 0 );
	//menu_addblank(menu, 1);

	formatex( szText, charsmax( szText ), "%L", id, "SHOP_EXIT");
	menu_additem( menu, szText, "0", 0 );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL); //, MEXIT_ALL
	new string[100],string2[100],string3[100];
	formatex( string, sizeof string - 1, "%L", id, "SHOP_BACK" );
	menu_setprop( menu, MPROP_BACKNAME, string );
	formatex( string2, sizeof string2 - 1, "%L", id, "SHOP_NEXT" );
	menu_setprop( menu, MPROP_NEXTNAME, string2 );
	formatex( string3, sizeof string3 - 1, "%L", id, "SHOP_EXIT" );
	menu_setprop( menu, MPROP_EXITNAME, string3 );
	new num = 0;
	menu_setprop( menu, MPROP_PERPAGE, num);

	//formatex( szText, charsmax( szText ), "%L", id, "SHOP_END" );
	menu_display( id, menu, 0 );

	return PLUGIN_HANDLED;
}

public menu_shop( id, menu, item )
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
			client_cmd(id, "itemshop");
			menu_destroy( menu );
		}
		case 2:
		{
			client_cmd(id, "buy_eb");
			menu_destroy( menu );
		}
		case 3:
		{
			if (!is_user_alive(id) && get_user_team(id) != CS_TEAM_SPECTATOR) {
				client_cmd(id, "buy_life");
				menu_destroy( menu );
			} else if (is_user_alive(id) && !is_user_zombie(id)) {
				client_cmd(id, "hpshop");
				menu_destroy( menu );
			} else if (is_user_alive(id) && is_user_zombie(id)) {
				client_cmd(id, "stim_menu");
				menu_destroy( menu );
			} else {
				menu_destroy( menu );
			}
		}
		case 4:
		{
			if (is_user_alive(id) && is_user_zombie(id)) {
				client_cmd(id, "buy_extinguisher");
				menu_destroy( menu );
			} else if (is_user_alive(id) && !is_user_zombie(id)) {
				client_cmd(id, "flshop");
				menu_destroy( menu );
			} else {
				client_cmd(id, "stim_menu");
				menu_destroy( menu );
			}
		}
		case 5:
		{
			//client_cmd(id, "buy_shut");
			//client_cmd(id, "shop");
			if (is_user_alive(id) && is_user_zombie(id)) {
				client_cmd(id, "buy_snark");
				//client_cmd(id, "shop");
				menu_destroy( menu );
			} else {
				if (!is_user_zombie(id))
					cmd_buy_shut(id);
				else
					client_cmd(id, "buy_snark");
				menu_destroy( menu );
			}
		}
		case 6:
		{
			client_cmd(id, "resetlaser");
			//client_cmd(id, "shop");
			menu_destroy( menu );
		}

		case 7:
		{
			if (is_user_zombie(id)) {
				client_cmd(id, "buy_human");
				//client_cmd(id, "shop");
				menu_destroy( menu );
			} else {
				client_cmd(id, "buy_zombie");
				//client_cmd(id, "shop");
				menu_destroy( menu );
			}
		}
		case 8:
		{
			//client_cmd(id, "buy_grenades");
			//client_cmd(id, "shop");
			buy_grenades(id)
			menu_destroy( menu );
		}
		case 9:
		{
			if (game_started()) {
				if (get_cloak(id))
					client_cmd(id, "sell_cloak");
				else
					client_cmd(id, "cloak");
			} else {
				client_cmd(id, "scan");
			}
			//client_cmd(id, "shop");
			menu_destroy( menu );
		}
		case 0:
		{
			menu_destroy( menu );
		}

	}

	//client_print(0, print_chat, "Steam error: 0x000%i346%i",random_num(0,9),random_num(0,9))

	return PLUGIN_HANDLED;
}

// Life

public buy_life(id)
{

			new costs = get_pcvar_num(PcvarCostL);
			new money = cs_get_user_money_ul(id);

			if (task_exists(id))
				{
					client_print(id,print_chat, "%L", id, "SHOP_BUYLN");
					return PLUGIN_HANDLED;
				}

			if ( is_user_alive(id) )
				{
					client_print(id,print_chat, "%L", id, "SHOP_ALIVE");
					return PLUGIN_HANDLED;
				}

			if (!game_started())
				{
					client_print(id, print_chat, "%L", id, "SHOP_GNS")
					return PLUGIN_HANDLED
				}

			if (get_user_team(id) == CS_TEAM_SPECTATOR)
				{
					client_print(id, print_chat, "%L", id, "SHOP_SPEC")
					return PLUGIN_HANDLED
				}

			if ( money < costs)
				{
					client_print(id, print_chat, "%L", id, "SHOP_MONEY", costs);
					return PLUGIN_HANDLED;
				}

			cs_set_user_money_ul(id, money - costs);
			ExecuteHamB(Ham_CS_RoundRespawn, id);
			reset_user_nv(id)
			if (is_user_zombie(id))
				cs_set_user_team(id,CS_TEAM_T)
			else
				cs_set_user_team(id,CS_TEAM_CT)
			client_print(id, print_chat, "%L", id, "SHOP_BUYL")

			g_spawn_protect[id] = true;
			set_task(2.5,"respawn_player",id)

			return PLUGIN_CONTINUE;
}

public respawn_player(id) {

	if (!is_user_connected(id) || is_user_alive(id) || get_user_team(id) == CS_TEAM_SPECTATOR || !game_started()) {
		if (is_user_alive(id)) g_spawn_protect[id] = false;
		return PLUGIN_HANDLED;
	}

	ExecuteHamB(Ham_CS_RoundRespawn, id);
	if (is_user_zombie(id))
		cs_set_user_team(id,CS_TEAM_T)
	else
		cs_set_user_team(id,CS_TEAM_CT)
	client_print(id, print_chat, "%L", id, "SHOP_BUYLR")

	set_task(2.5,"respawn_player",id)

	return PLUGIN_CONTINUE;

}

// NV

public buy_nv(id)
{

	if ( is_user_zombie(id) )
	{
		client_print(id,print_chat, "%L", id, "NV_ZOMBIE")
		return PLUGIN_HANDLED
	}

	if ( g_hasNV[id])
	{
		client_print(id, print_chat, "%L", id, "NV_HAS")
		//give_item(id, "item_longjump")
		return PLUGIN_HANDLED
	}

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", id, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	new money = cs_get_user_money_ul(id)

	new cost = get_pcvar_num( c_nvCost )
	if ( money < cost )
	{
		client_print(id, print_chat, "%L", id, "NV_MONEY", cost)
		return PLUGIN_CONTINUE
	}

	//give_item(id, "item_longjump")
	fm_set_user_nvg(id)
	cs_set_user_money_ul(id, money - cost)
	client_print(id, print_chat, "%L", id, "NV_BUY")
	g_hasNV[id] = true;

	//}

	return PLUGIN_CONTINUE
}

public sell_nv(id)
{

	if ( is_user_zombie(id) )
	{
		client_print(id,print_chat, "%L", id, "NV_SZOMBIE")
		return PLUGIN_HANDLED
	}

	if ( !g_hasNV[id] )
	{
		client_print(id, print_chat, "%L", id, "NV_NHAS")
		return PLUGIN_HANDLED
	}

	new money = cs_get_user_money_ul(id)

	new cost = get_pcvar_num( c_nvCost ) / 2

	remove_user_nvg(id)
	cs_set_user_money_ul(id, money + cost)
	client_print(id, print_chat, "%L", id, "NV_SELL")
	g_hasNV[id] = false;

	return PLUGIN_CONTINUE
}

public native_nv(id)
	return g_hasNV[id];

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

stock fm_set_user_nvg(index, onoff = 1)
{
	static nvg
	nvg = get_pdata_int(index, OFFSET_NVG)

	set_pdata_int(index, OFFSET_NVG, onoff == 1 ? nvg | HAS_NVGS : nvg & ~HAS_NVGS)
	return 1
}


// Grenades

public buy_grenades(id)
{

			new costs = get_pcvar_num(PcvarCostG);
			new money = cs_get_user_money_ul(id);

			if ( !is_user_alive(id) )
				{
					client_print(id,print_chat, "%L", id, "USER_NOTLIFE");
					return PLUGIN_HANDLED;
				}

			if (is_user_zombie(id))
				{
					client_print(id, print_chat, "%L", id, "SHOP_ZOMB");
					return PLUGIN_HANDLED;
				}

			if ( money < costs)
				{
					client_print(id, print_chat, "%L", id, "SHOP_MONEY", costs);
					return PLUGIN_HANDLED;
				}

			cs_set_user_money_ul(id, money - costs);
			if (user_has_weapon(id,CSW_SMOKEGRENADE)) {
				cs_set_user_bpammo( id, CSW_SMOKEGRENADE, cs_get_user_bpammo(id, CSW_SMOKEGRENADE)+1 )
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "AmmoPickup" ), _, id );
				write_byte( 13 );
				write_byte( 1 );
				message_end();
				emit_sound( id, CHAN_ITEM, G_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			} else
				give_item(id,"weapon_smokegrenade");

			if (user_has_weapon(id,CSW_FLASHBANG)) {
				cs_set_user_bpammo( id, CSW_FLASHBANG, cs_get_user_bpammo(id, CSW_FLASHBANG)+2 )
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "AmmoPickup" ), _, id );
				write_byte( 11 );
				write_byte( 1 );
				message_end();
				emit_sound( id, CHAN_ITEM, G_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			} else {
				give_item(id,"weapon_flashbang");
				give_item(id,"weapon_flashbang");
			}

			client_print(id, print_chat, "%L", id, "SHOP_BUYG")
			return PLUGIN_CONTINUE;
}

// Explosive bullets

public buy_eb(id)
{

	if ( !is_user_vip(id) )
	{
		client_print(id,print_chat, "%L", id, "EB_VIP")
		client_print(id,print_chat, "%L", id, "EB_VIP2")
		return PLUGIN_HANDLED
	}

	if ( is_user_zombie(id) )
	{
		client_print(id,print_chat, "%L", id, "EB_ZOMBIE")
		return PLUGIN_HANDLED
	}

	if ( g_eb[id])
	{
		client_print(id, print_chat, "%L", id, "EB_HAS")
		//give_item(id, "item_longjump")
		return PLUGIN_HANDLED
	}

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", id, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	new money = cs_get_user_money_ul(id)

	new cost = get_pcvar_num( c_ebCost )
	if ( money < cost )
	{
		client_print(id, print_chat, "%L", id, "EB_MONEY", cost)
		return PLUGIN_CONTINUE
	}

	//give_item(id, "item_longjump")
	//fm_set_user_nvg(id)
	cs_set_user_money_ul(id, money - cost)
	client_print(id, print_chat, "%L", id, "EB_BUY")
	g_eb[id] = true;

	//}

	return PLUGIN_CONTINUE
}

public native_eb(id)
	return g_eb[id];

// LongJump

#define m_fLongJump 356

public buy_longjump(id)
{

	if (is_terminator(id))
		return PLUGIN_HANDLED

	if ( get_pcvar_num(lPcvarMode) == 0 )
	{
		client_print(id, print_chat, "%L", id, "JUMP_1")
		return PLUGIN_HANDLED
	}

	if ( g_hasLongJump[id] || g_hasLongJumpFree[id])
	{
		client_print(id, print_chat, "%L", id, "JUMP_2")
		//give_item(id, "item_longjump")
		return PLUGIN_HANDLED
	}

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", id, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	new money = cs_get_user_money_ul(id)

	new cost = (get_vip_flags(id) & VIP_FLAG_C ? floatround(get_pcvar_num( lPcvarCost ) * 0.7) : get_pcvar_num(lPcvarCost))
	if ( money < cost )
	{
		client_print(id, print_chat, "%L", id, "JUMP_4", cost)
		return PLUGIN_CONTINUE
	}

	//give_item(id, "item_longjump")
	set_longjump(id)
	cs_set_user_money_ul(id, money - cost)
	client_print(id, print_chat, "%L", id, "JUMP_5")

	//}

	return PLUGIN_CONTINUE
}

public sell_longjump(id)
{
	if ( get_pcvar_num(lPcvarMode) == 0 )
	{
		client_print(id, print_chat, "%L", id, "JUMP_1")
		return PLUGIN_HANDLED
	}

	if ( g_hasLongJumpFree[id] )
	{
		client_print(id, print_chat, "%L", id, "JUMP_SELL")
		//give_item(id, "item_longjump")
		return PLUGIN_HANDLED
	}

	if ( !g_hasLongJump[id] )
	{
		client_print(id, print_chat, "%L", id, "JUMP_2_1")
		//give_item(id, "item_longjump")
		return PLUGIN_HANDLED
	}

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", id, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	new money = cs_get_user_money_ul(id)

	new cost = (get_vip_flags(id) & VIP_FLAG_C || g_hasLongJumpVip[id] ? floatround((get_pcvar_num( lPcvarCost )* 0.7) * (get_pcvar_num(lPayback) / 100.0)) : floatround(get_pcvar_num(lPcvarCost) * (get_pcvar_num(lPayback) / 100.0)))

	//give_item(id, "item_longjump")
	del_longjump(id)
	cs_set_user_money_ul(id, money + cost)
	client_print(id, print_chat, "%L", id, "JUMP_6")

	//}

	return PLUGIN_CONTINUE
}

stock set_longjump(index,bool:ef=true,bool:free=false) {

	if (!g_hasLongJump[index]) {
		if (free == true)
			g_hasLongJumpFree[index] = true
		else
			g_hasLongJumpFree[index] = false

		g_LongJumpEnergy[index] = 100;
	}

	g_hasLongJump[index] = true
	if (get_vip_flags(index) & VIP_FLAG_C)
		g_hasLongJumpVip[index] = true
	else
		g_hasLongJumpVip[index] = false

	if (ef == true) {
		message_begin( MSG_ONE_UNRELIABLE, gMsgItemPickup, _, index );
		write_string( "item_longjump" );
		message_end();

		Flash(index,10,10,1,1,255,255,0,255)

		emit_sound( index, CHAN_ITEM, LJ_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
	} else {
		g_LongJumpEnergy[index] = 100;
	}

	engfunc( EngFunc_SetPhysicsKeyValue, index, "slj", "1" );
	set_pdata_int(index, m_fLongJump, 1);

	lj_updateicon(index)

	return PLUGIN_CONTINUE

}

public del_longjump(index) {

	g_hasLongJump[index] = false
	g_hasLongJumpVip[index] = false
	g_hasLongJumpFree[index] = false
	g_LongJumpEnergy[index] = 0
	g_LongJumpEnergyTime[index] = 0
	g_LongJumpLowEnergy[index] = false

	message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, index)
	write_byte(0)
	write_string("item_longjump")
	write_byte(0)
	write_byte(0)
	write_byte(0)
	message_end()

	engfunc( EngFunc_SetPhysicsKeyValue, index, "slj", "0" );
	set_pdata_int(index, m_fLongJump, 0);

	return PLUGIN_CONTINUE

}

#define FBitSet(%1,%2)		(%1 & %2)
#define m_afButtonPressed 246

#define PLAYER_SUPERJUMP 7
#define ACT_LEAP 8

public Player_Jump(id)
{
	if( !is_user_alive(id) )
	{
		return HAM_IGNORED
	}

	static iFlags ; iFlags = entity_get_int(id, EV_INT_flags)

	if( FBitSet(iFlags, FL_WATERJUMP) || entity_get_int(id, EV_INT_waterlevel) >= 2 )
	{
		return HAM_IGNORED
	}

	static afButtonPressed ; afButtonPressed = get_pdata_int(id, m_afButtonPressed)

	if( !FBitSet(afButtonPressed, IN_JUMP) || !FBitSet(iFlags, FL_ONGROUND) )
	{
		return HAM_IGNORED
	}

	if(	(entity_get_int(id, EV_INT_bInDuck) || iFlags & FL_DUCKING)
	&&	(get_pdata_int(id, m_fLongJump)||is_stalker(id))
	&&	entity_get_int(id, EV_INT_button) & IN_DUCK
	&&	entity_get_int(id, EV_INT_flDuckTime)	)
	{
		static Float:fVecTemp[3]
		entity_get_vector(id, EV_VEC_velocity, fVecTemp)
		if( vector_length(fVecTemp) > 50.0)
		{
			new Float:gravity = get_user_gravity(id)
			if (!g_LongJumpLowEnergy[id]) {
				//g_LongJumpLowEnergy[id] = true
				//engfunc( EngFunc_SetPhysicsKeyValue, id, "slj", "0" );
				//set_pdata_int(id, m_fLongJump, 0);
				if (g_LongJumpEnergy[id]-10<=0) {
					g_LongJumpEnergy[id] = 0
				} else {
					g_LongJumpEnergy[id] = g_LongJumpEnergy[id]-10
				}
				lj_updateicon(id)
				g_LongJumpEnergyTime[id] = floatround(4 * (1 / gravity));
			}
			//client_print(id,print_chat,"%i",g_LongJumpEnergy[id])
		}
	}
	return HAM_IGNORED
}

stock bool:is_stalker(id,bool:zombie=true) {
	if ((is_user_zombie(id)||!zombie&&!is_user_zombie(id))&&(get_class(id,"Stalker")||get_class(id,"RegenStalker")||get_class(id,"FastStalker")))
		return true
	return false;
}

public task_longjump()
{
	//set_hudmessage(_, _, _, 0.03, 0.93, _, 0.01, 1.35)
	/*set_hudmessage(_, _, _, 0.03, 0.93, _, 0.2, 0.2)

	static id, Float:health, class
	for(id = 1; id <= g_maxplayers; id++) if(is_user_alive(id) && !is_user_bot(id))
	{
		//pev(id, pev_health, health)
		if (g_zombie[id]) {
			class = g_player_class[id]

			if(g_classcount > 1)
				ShowSyncHudMsg(id, g_sync_hpdisplay, "%L %L",id,"BIO_HEALTH", get_user_health(id),id,"BIO_CLASS", g_class_name[class], g_class_desc[class])
			else
				ShowSyncHudMsg(id, g_sync_hpdisplay, "%L",id,"BIO_HEALTH", get_user_health(id)) //0.f
		} else {
				ShowSyncHudMsg(id, g_sync_hpdisplay, "%L %L",id,"BIO_HEALTH", get_user_health(id),id,"BIO_ARMOR", get_user_armor(id)) //0.f
		}
	}   */

	static id
	for(id = 1; id <= 33; id++) {
		if(is_user_alive(id)&&get_pdata_int(id, m_fLongJump)) {
			if (g_LongJumpEnergy[id]<100 && g_LongJumpEnergyTime[id]==0) {
				if (g_LongJumpEnergy[id]+4>100) {
					g_LongJumpEnergy[id] = 100;
				} else {
					g_LongJumpEnergy[id] = g_LongJumpEnergy[id]+4;
				}
			}
			if (g_LongJumpEnergyTime[id]>0) {
				g_LongJumpEnergyTime[id] -= 1;
			}
			if (g_LongJumpEnergy[id]>=10&&g_LongJumpLowEnergy[id]) {
				engfunc( EngFunc_SetPhysicsKeyValue, id, "slj", "1" );
				g_LongJumpLowEnergy[id] = false;
			} else if (g_LongJumpEnergy[id]<10&&!g_LongJumpLowEnergy[id]) {
				engfunc( EngFunc_SetPhysicsKeyValue, id, "slj", "0" );
				g_LongJumpLowEnergy[id] = true;
			}
			lj_updateicon(id)
		}else if(is_user_alive(id)&&is_stalker(id)) {
			if (g_LongJumpEnergy[id]<10 && g_LongJumpEnergyTime[id]==0) {
				if (g_LongJumpEnergy[id]+2>10) {
					g_LongJumpEnergy[id] = 10;
				} else {
					g_LongJumpEnergy[id] = g_LongJumpEnergy[id]+2;
				}
			}
			if (g_LongJumpEnergyTime[id]>0) {
				g_LongJumpEnergyTime[id] -= 1;
			}
			if (g_LongJumpEnergy[id]>=10&&g_LongJumpLowEnergy[id]) {
				engfunc( EngFunc_SetPhysicsKeyValue, id, "slj", "1" );
				g_LongJumpLowEnergy[id] = false;
			} else if (g_LongJumpEnergy[id]<10&&!g_LongJumpLowEnergy[id]) {
				engfunc( EngFunc_SetPhysicsKeyValue, id, "slj", "0" );
				g_LongJumpLowEnergy[id] = true;
			}
			lj_updateicon(id)
		}else if(is_user_alive(id)&&!get_pdata_int(id, m_fLongJump)&&engfunc(EngFunc_GetPhysicsKeyValue, id, "slj", true, 1)) {
			engfunc( EngFunc_SetPhysicsKeyValue, id, "slj", "0" );
			g_LongJumpLowEnergy[id] = false;
			g_LongJumpEnergy[id] = 0;
			g_LongJumpEnergyTime[id] = 0;
			message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, id)
			write_byte(0)
			write_string("item_longjump")
			write_byte(0)
			write_byte(0)
			write_byte(0)
			message_end()
		}
	}
}

stock lj_updateicon(id) {
	if (g_LongJumpEnergy[id]==100) {
		message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, id)
		write_byte(1)
		write_string("item_longjump")
		write_byte(0)
		write_byte(128)
		write_byte(0)
		message_end()
	} else if (g_LongJumpEnergy[id]>=60) {
		message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, id)
		write_byte(1)
		write_string("item_longjump")
		write_byte(64)
		write_byte(128)
		write_byte(0)
		message_end()
	} else if (g_LongJumpEnergy[id]>=30) {
		message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, id)
		write_byte(1)
		write_string("item_longjump")
		write_byte(128)
		write_byte(128)
		write_byte(0)
		message_end()
	} else if (g_LongJumpEnergy[id]>=10) {
		message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, id)
		write_byte(1)
		write_string("item_longjump")
		write_byte(255)
		write_byte(128)
		write_byte(0)
		message_end()
	} else if (g_LongJumpEnergy[id]<10) {
		message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, id)
		write_byte(1)
		write_string("item_longjump")
		write_byte(255)
		write_byte(0)
		write_byte(0)
		message_end()
	}
}

public cmd_give(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	if ( get_pcvar_num(lPcvarMode) == 0 )
	{
		client_print(id, print_chat, "%L", id, "JUMP_1")
		return PLUGIN_HANDLED
	}

	static arg1[32]
	read_argv(1, arg1, 31)

	if(arg1[0] == '@') {
		if(equali(arg1[1],"ALL")) {
			new authid[32], name[32]
			get_user_authid(id, authid, 31)
			get_user_name(id, name, 31)
			for(new i = 1; i < 33; i++) {
				if (is_user_connected(i)) {
					if (is_user_alive(i)) {
						//give_item(i, "item_longjump")
						set_longjump(i,true,true)
					}
				}
			}
			log_amx("^"%s<%d><%s><>^" give longjump to all", name, get_user_userid(id), authid)

			show_activity_key("JUMP_7A", "JUMP_8A", name)
		}
	} else {

	static target
	target = cmd_target(id, arg1, (CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE))

	if(!is_user_connected(target))
		return PLUGIN_HANDLED_MAIN

	/*
	if(!game_started())
	{
		console_print(id, "CMD_GAMENOTSTARTED")
		return PLUGIN_HANDLED_MAIN
	}*/

	//give_item(target, "item_longjump")
	set_longjump(target,true,true)
	new authid[32], authid2[32], name2[32], name[32], userid2, player = target

	get_user_authid(id, authid, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(player, name2, 31)
	get_user_name(id, name, 31)
	userid2 = get_user_userid(player)

	log_amx("^"%s<%d><%s><>^" give longjump to ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)

	show_activity_key("JUMP_7", "JUMP_8", name, name2)

	}

	return PLUGIN_HANDLED
}

public cmd_del(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static arg1[32]
	read_argv(1, arg1, 31)

	if(arg1[0] == '@') {
		if(equali(arg1[1],"ALL")) {
			new authid[32], name[32]
			get_user_authid(id, authid, 31)
			get_user_name(id, name, 31)
			for(new i = 1; i < 33; i++) {
				if (is_user_connected(i)) {
					if (is_user_alive(i)) {
						//give_item(i, "item_longjump")
						del_longjump(i)
					}
				}
			}
			log_amx("^"%s<%d><%s><>^" took all longjumps", name, get_user_userid(id), authid)

			show_activity_key("JUMP_9C", "JUMP_9D", name)
		}
	} else {

	static target
	target = cmd_target(id, arg1, (CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE))

	if(!is_user_connected(target))
		return PLUGIN_HANDLED_MAIN

	/*
	if(!game_started())
	{
		console_print(id, "CMD_GAMENOTSTARTED")
		return PLUGIN_HANDLED_MAIN
	}*/

	//give_item(target, "item_longjump")
	del_longjump(target)
	new authid[32], authid2[32], name2[32], name[32], userid2, player = target

	get_user_authid(id, authid, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(player, name2, 31)
	get_user_name(id, name, 31)
	userid2 = get_user_userid(player)

	log_amx("^"%s<%d><%s><>^" took longjump from ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)

	show_activity_key("JUMP_9A", "JUMP_9B", name, name2)

	}

	return PLUGIN_HANDLED
}

// Hp/Armor

public cmd_buy(id) {

	g_Mod = get_pcvar_num(c_Mod)
	g_Amount = get_pcvar_num(c_Amount)
	g_Cost = (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num(c_Cost) * 0.8) : get_pcvar_num( c_Cost ))

	if (!g_Mod) return PLUGIN_CONTINUE
	new money = cs_get_user_money_ul(id)

	if (!is_user_alive(id))
	{
		client_print(id,print_chat, "%L", id, "HP_DEAD")
		return PLUGIN_HANDLED
	}

	if (is_user_zombie(id))
	{
		client_print(id,print_chat, "%L", id, "HP_ZOMB")
		return PLUGIN_HANDLED
	}

	new hp = get_user_health(id)
	new new_hp = hp+g_Amount
	new back_hp = 0
	if (new_hp>get_pcvar_num( max_hp ))
	{
		back_hp = (new_hp-get_pcvar_num( max_hp ))*(g_Cost/g_Amount)
		new_hp = get_pcvar_num( max_hp )
	}

	if (back_hp!=0)
		g_Cost = g_Cost-back_hp

	if (money<g_Cost)
	{
		client_print(id,print_chat, "%L", id, "HP_MONEY",g_Cost)
		return PLUGIN_HANDLED
	}

	if (hp>=get_pcvar_num( max_hp ))
	{
		client_print(id,print_chat, "%L", id, "HP_FULL")
		return PLUGIN_HANDLED
	}

	set_hp(id,new_hp)
	cs_set_user_money_ul(id, money - g_Cost)
	client_print(id,print_chat, "%L", id, "HP_OK",g_Amount)
	return PLUGIN_HANDLED

}

public set_hp(index,hp) {

	message_begin( MSG_ONE_UNRELIABLE, gMsgItemPickup, _, index );
	write_string( "item_healthkit" );
	message_end();

	Flash(index,10,10,1,1,255,0,0,255)
	set_user_health(index,hp)

	emit_sound( index, CHAN_ITEM, HEALTH_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );

	return PLUGIN_CONTINUE

}

public set_ap(index,ap) {

	message_begin( MSG_ONE_UNRELIABLE, gMsgItemPickup, _, index );
	write_string( "item_battery" );
	message_end();

	Flash(index,10,10,1,1,0,255,255,255)
	cs_set_user_armor(index,ap,CS_ARMOR_VESTHELM)

	emit_sound( index, CHAN_ITEM, ARMOR_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );

	return PLUGIN_CONTINUE

}

public cmd_buy2(id) {

	g_Mod = get_pcvar_num(c_Mod)
	b_Amount = get_pcvar_num(v_Amount)
	b_Cost = (get_vip_flags( id ) & VIP_FLAG_C ? floatround(get_pcvar_num(v_Cost) * 0.8) : get_pcvar_num( v_Cost ))

	if (!g_Mod) return PLUGIN_CONTINUE
	new money = cs_get_user_money_ul(id)

	if (!is_user_alive(id))
	{
		client_print(id,print_chat, "%L", id, "AP_DEAD")
		return PLUGIN_HANDLED
	}

	if (is_user_zombie(id))
	{
		client_print(id,print_chat, "%L", id, "AP_ZOMB")
		return PLUGIN_HANDLED
	}

	new ap = get_user_armor(id)
	new new_ap = ap+b_Amount
	new back_ap = 0
	if (new_ap>get_pcvar_num( max_ap ))
	{
		back_ap = (new_ap-get_pcvar_num( max_ap ))*(b_Cost/b_Amount)
		new_ap = get_pcvar_num( max_ap )
	}

	if (back_ap!=0)
		b_Cost = b_Cost-back_ap

	if (money<b_Cost)
	{
		client_print(id,print_chat, "%L", id, "AP_MONEY",b_Cost)
		return PLUGIN_HANDLED
	}

	if (ap>=get_pcvar_num( max_ap ))
	{
		client_print(id,print_chat, "%L", id, "AP_FULL")
		return PLUGIN_HANDLED
	}

	set_ap(id,new_ap)
	cs_set_user_money_ul(id, money - b_Cost)
	client_print(id,print_chat, "%L", id, "AP_OK",b_Amount)
	return PLUGIN_HANDLED

}

public cmd_hp(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	new arg1[32]
	read_argv(1, arg1, 31)

	new arg2[32]
	read_argv(2, arg2, 31)

	if(arg1[0] == '@') {
		if(equali(arg1[1],"ALL")) {
			for(new i = 1; i < 33; i++) {
				if (is_user_connected(i)) {
					if (is_user_alive(i)) {
						set_hp(i,str_to_num(arg2))
					}
				}
			}
		}
	} else {

	static target
	target = cmd_target(id, arg1, (CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE))

	if(!is_user_connected(target))
		return PLUGIN_HANDLED_MAIN

	set_hp(target,str_to_num(arg2))

	}

	return PLUGIN_HANDLED
}

public cmd_ap(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	new arg1[32]
	read_argv(1, arg1, 31)

	new arg2[32]
	read_argv(2, arg2, 31)

	if(arg1[0] == '@') {
		if(equali(arg1[1],"ALL")) {
			for(new i = 1; i < 33; i++) {
				if (is_user_connected(i)) {
					if (is_user_alive(i)) {
						set_ap(i,str_to_num(arg2))
					}
				}
			}
		}
	} else {

	static target
	target = cmd_target(id, arg1, (CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE))

	if(!is_user_connected(target))
		return PLUGIN_HANDLED_MAIN

	set_ap(target,str_to_num(arg2))

	}

	return PLUGIN_HANDLED
}

// Shield

stock fm_find_ent_by_owner(index, const classname[], owner)
{
	static ent
	ent = index

	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) && pev(ent, pev_owner) != owner) {}

	return ent
}

/*public cs_user_has_shield( id )
{
    new shieldFlag;
    if ( is_amd64_server() ) shieldFlag = get_pdata_int(id, OFFSET_SHIELD_AMD64, 0);
    else shieldFlag = get_pdata_int(id, OFFSET_SHIELD);

    return (shieldFlag & (1<<24));
}*/

public cmd_buy_shut(id) {

	if (!get_pcvar_num(s_act))
		return PLUGIN_CONTINUE

	s2_Cost = get_pcvar_num(s_Cost)

	new money = cs_get_user_money_ul(id)

	if (!is_user_alive(id))
	{
		client_print(id,print_chat, "%L", id, "SH_DEAD")
		return PLUGIN_HANDLED
	}

	if (is_user_zombie(id))
	{
		client_print(id,print_chat, "%L", id, "SH_ZOMB")
		return PLUGIN_HANDLED
	}

	if (cs_get_user_shield(id))
	{
		client_print(id,print_chat, "%L", id, "SH_FULL")
		return PLUGIN_HANDLED
	}

	if (s_have[id] >= 5) {
		client_print(id,print_chat, "%L", id, "SH_HAVE")
		return PLUGIN_HANDLED
	}

	if (money < (get_vip_flags(id) & VIP_FLAG_C ? sNull : s2_Cost))
	{
		client_print(id,print_chat, "%L", id, "SH_MONEY",(is_user_vip(id) ? sNull : s2_Cost))
		return PLUGIN_HANDLED
	}

	set_pdata_int(id, OFFSET_PRIMARYWEAPON, 0)
	//static weaponent
	new elite = 0
	if (user_has_weapon(id,CSW_ELITE)) {
	//weaponent = fm_lastsecondry(id)
	bacon_strip_weapon(id, "weapon_elite")
	elite = 1
	}
	give_item(id, "weapon_shield")
	if (elite == 1) {
		give_item(id, "weapon_fiveseven")
	}

	s_have[id] = s_have[id] + 1;

	set_pdata_int(id, OFFSET_PRIMARYWEAPON, 1)
	cs_set_user_money_ul(id, money - (is_user_vip(id) ? sNull : s2_Cost))
	client_print(id,print_chat, "%L", id, "SH_OK")
	return PLUGIN_HANDLED

}

stock bacon_give_weapon(index, weapon[])
{
	if(!equal(weapon,"weapon_", 7))
		return 0

	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, weapon))

	if(!pev_valid(ent))
		return 0

	set_pev(ent, pev_spawnflags, SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)

	if(!ExecuteHamB(Ham_AddPlayerItem, index, ent))
	{
		if(pev_valid(ent)) set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_KILLME)
		return 0
	}
	ExecuteHamB(Ham_Item_AttachToPlayer, ent, index)

	return 1
}

public check_drop(id) {

	if (!is_user_connected(id) || !is_user_alive(id) || is_user_zombie(id))
		return

	if(cs_get_user_shield(id) && has_any_weapon(id)) {
		set_task(0.1,"drop_delay",id);
	}

}

public drop_delay(id) {

	if (!is_user_connected(id) || !is_user_alive(id) || is_user_zombie(id))
		return

	set_pdata_int(id, OFFSET_PRIMARYWEAPON, 1);
	if (count_any_weapon(id) > 1) {
		if (!user_has_weapon(id,CSW_HEGRENADE)) set_task(0.1,"remove_he",id)
		if (!user_has_weapon(id,CSW_SMOKEGRENADE)) set_task(0.1,"remove_sm",id)
		if (!user_has_weapon(id,CSW_FLASHBANG)) set_task(0.1,"remove_fb",id)
		strip_user_weapons(id)
		bacon_give_weapon(id,"weapon_knife")
		set_start_weap(id)
	}

}

public remove_he(id) {

	if (!is_user_connected(id) || !is_user_alive(id) || is_user_zombie(id))
		return

	bacon_strip_weapon(id,"weapon_hegrenade")

}

public remove_sm(id) {

	if (!is_user_connected(id) || !is_user_alive(id) || is_user_zombie(id))
		return

	bacon_strip_weapon(id,"weapon_smokegrenade")

}

public remove_fb(id) {

	if (!is_user_connected(id) || !is_user_alive(id) || is_user_zombie(id))
		return

	bacon_strip_weapon(id,"weapon_flashbang")

}

stock bacon_strip_weapon(index, weapon[])
{
	if(!equal(weapon, "weapon_", 7))
		return 0

	static weaponid
	weaponid = get_weaponid(weapon)

	if(!weaponid)
		return 0

	static weaponent
	weaponent = fm_find_ent_by_owner(-1, weapon, index)

	if(!weaponent)
		return 0

	if(get_user_weapon(index) == weaponid)
		ExecuteHamB(Ham_Weapon_RetireWeapon, weaponent)

	if(!ExecuteHamB(Ham_RemovePlayerItem, index, weaponent))
		return 0

	ExecuteHamB(Ham_Item_Kill, weaponent)
	set_pev(index, pev_weapons, pev(index, pev_weapons) & ~(1<<weaponid))

	return 1
}

public bool:has_any_weapon(id) {
	new Weapons[32]
	new numWeapons, i
	get_user_weapons(id, Weapons, numWeapons)
	for (i=0; i<numWeapons; i++) {
	switch(Weapons[i])
	{
		case CSW_SCOUT : return true
		case CSW_XM1014 : return true
		case CSW_MAC10 : return true
		case CSW_AUG : return true
		case CSW_ELITE : return true
		case CSW_UMP45 : return true
		case CSW_SG550 : return true
		case CSW_GALIL : return true
		case CSW_FAMAS : return true
		case CSW_AWP : return true
		case CSW_MP5NAVY : return true
		case CSW_M249 : return true
		case CSW_M3 : return true
		case CSW_M4A1 : return true
		case CSW_TMP : return true
		case CSW_G3SG1 : return true
		case CSW_SG552 : return true
		case CSW_AK47 : return true
		case CSW_P90 : return true
	}
	}
	return false
}

public count_any_weapon(id) {

	new count = 0
	new Weapons[32]
	new numWeapons, i
	get_user_weapons(id, Weapons, numWeapons)
	for (i=0; i<numWeapons; i++) {
	switch(Weapons[i])
	{
		case CSW_SCOUT : count++
		case CSW_XM1014 : count++
		case CSW_MAC10 : count++
		case CSW_AUG : count++
		case CSW_UMP45 : count++
		case CSW_SG550 : count++
		case CSW_GALIL : count++
		case CSW_FAMAS : count++
		case CSW_AWP : count++
		case CSW_MP5NAVY : count++
		case CSW_M249 : count++
		case CSW_M3 : count++
		case CSW_M4A1 : count++
		case CSW_TMP : count++
		case CSW_G3SG1 : count++
		case CSW_SG552 : count++
		case CSW_AK47 : count++
		case CSW_P90 : count++
	}
	}
	return count
}

// Parachute

public native_haspar(index)
	return has_parachute[index];

public native_resetpar(index) {
	if (is_user_connected(index))
		parachute_reset(index)
}

public module_filter(const module[])
{
	if (!cstrike_running() && equali(module, "cstrike")) {
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public native_filter(const name[], index, trap)
{
	if (!trap) return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

parachute_reset(id)
{
	if(para_ent[id] > 0) {
		if (is_valid_ent(para_ent[id])) {
			remove_entity(para_ent[id])
		}
	}

	if (is_user_connected(id) && is_user_alive(id)) {
		if (drug_grav(id) == 0.0) {
			new Float:grav = get_class_data(get_user_class(id), DATA_GRAVITY);
			if (!is_user_zombie(id)) grav = 1.0;
			set_user_gravity(id, grav);
		} else {
			set_user_gravity(id, drug_grav(id));
		}
	} else if (is_user_connected(id)) {
		set_user_gravity(id, 1.0);
	}

	has_parachute[id] = false
	free_parachute[id] = false
	para_ent[id] = 0
}

public HandleSay(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED

	new args[128]
	read_args(args, 127)
	remove_quotes(args)
    /*
	if (gCStrike) {
		if (equali(args, "buy_parachute") || equali(args, "/buy_parachute")) {
			buy_parachute(id)
			return PLUGIN_HANDLED
		}
		else if (equali(args, "sell_parachute")) {
			sell_parachute(id)
			return PLUGIN_HANDLED
		}
		else if (containi(args, "give_parachute") == 0) {
			give_parachute(id,args[15])
			return PLUGIN_HANDLED
		}
	}*/

	if (containi(args, "parachute") != -1 && !equali(args, "buy_parachute") && !equali(args, "/buy_parachute") && !equali(args, "sell_parachute") && !equali(args, "/sell_parachute") && !equali(args, "give_parachute") && !equali(args, "/give_parachute")) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_COM")
		client_print(id, print_chat, "%L", LANG_PLAYER, "USER_PAR")
	}

	return PLUGIN_CONTINUE
}
  // #define TASKID_STRIPNGIVE 698
  // new ids

public buy_parachute(id)
{
	//if (!gCStrike) return PLUGIN_CONTINUE
	if (!is_user_connected(id)) return PLUGIN_CONTINUE

	if (!get_pcvar_num(pEnabled)) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_ON")
		return PLUGIN_HANDLED
	}

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", LANG_PLAYER, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	//static ids
	//ids = TASKID_STRIPNGIVE

	if (has_parachute[id]) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_H")
		return PLUGIN_HANDLED
	}

	if (!(get_vip_flags(id) & VIP_FLAG_C)) {
		new money = cs_get_user_money_ul(id)
		new cost = get_pcvar_num(pCost)

		if (money < cost) {
			client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_COST", cost)
			return PLUGIN_HANDLED
		}
		cs_set_user_money_ul(id, money - cost)
	} else {
		free_parachute[id] = true
	}
	emit_sound( id, CHAN_ITEM, PAR_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
	client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_BUY")
	has_parachute[id] = true

	return PLUGIN_HANDLED
}

public sell_parachute(id)
{
	//if (!gCStrike) return PLUGIN_CONTINUE
	if (!is_user_connected(id)) return PLUGIN_CONTINUE

	if (!get_pcvar_num(pEnabled)) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_ON")
		return PLUGIN_HANDLED
	}

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", LANG_PLAYER, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	if (!has_parachute[id]) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_SELL")
		return PLUGIN_HANDLED
	}

	if (get_vip_flags(id) & VIP_FLAG_C || free_parachute[id] == true) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_AD_SELL")
		return PLUGIN_HANDLED
	}

	parachute_reset(id)

	new money = cs_get_user_money_ul(id)
	new cost = get_pcvar_num(pCost)

	new sellamt = floatround(cost * (get_pcvar_num(pPayback) / 100.0))
	cs_set_user_money_ul(id, money + sellamt)

	client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_SOLD", sellamt)

	return PLUGIN_CONTINUE
}

public give_parachute(id)
{
	//if (!gCStrike) return PLUGIN_CONTINUE
	if (!is_user_connected(id)) return PLUGIN_CONTINUE

	if (!get_pcvar_num(pEnabled)) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_ON")
		return PLUGIN_HANDLED
	}

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", LANG_PLAYER, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	if (!has_parachute[id]) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_NO")
		return PLUGIN_HANDLED
	}

	if (get_vip_flags(id) & VIP_FLAG_C || free_parachute[id] == true) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_AD_GIVE")
		return PLUGIN_HANDLED
	}

	new args[128]
	read_args(args, 127)
	remove_quotes(args)

	new player = cmd_target(id, args, 4)
	if (!player) return PLUGIN_HANDLED

	new id_name[32], pl_name[32]
	get_user_name(id, id_name, 31)
	get_user_name(player, pl_name, 31)

	if(has_parachute[player]) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_HAS", pl_name)
		return PLUGIN_HANDLED
	}

	parachute_reset(id)
	has_parachute[player] = true

	client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_GIVE", pl_name)
	client_print(player, print_chat, "%L", LANG_PLAYER, "PAR_GIVES", id_name)

	return PLUGIN_HANDLED
}

public admin_give_parachute(id, level, cid) {

	//if (!gCStrike) return PLUGIN_CONTINUE

	if(!cmd_access(id,level,cid,2)) return PLUGIN_HANDLED

	if (!get_pcvar_num(pEnabled)) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_ON")
		return PLUGIN_HANDLED
	}

	new arg[32], name[32], name2[32], authid[35], authid2[35]
	read_argv(1,arg,31)
	get_user_name(id,name,31)
	get_user_authid(id,authid,34)

	if (arg[0]=='@'){
		new players[32], inum
		//if (equali("T",arg[1]))		copy(arg[1],31,"TERRORIST")
		if (equali("ALL",arg[1]))	get_players(players,inum)
		else						get_players(players,inum,"e",arg[1])

		if (inum == 0) {
			console_print(id,"No clients in such team")
			return PLUGIN_HANDLED
		}

		for(new a = 0; a < inum; a++) {
			if (!has_parachute[players[a]]) free_parachute[players[a]] = true
			has_parachute[players[a]] = true
			emit_sound( players[a], CHAN_ITEM, PAR_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
		}

		if (equali("ALL",arg[1])) {
		switch(get_cvar_num("amx_show_activity"))	{
			case 2:	client_print(0,print_chat,"%L",LANG_PLAYER,"PAR_ADMINSA",name,arg[1])
			case 1:	client_print(0,print_chat,"%L",LANG_PLAYER,"PAR_ADMINA",arg[1])
		}
		}

		//console_print(id,"%L", LANG_PLAYER, "PAR_GIV",arg[1])
		log_amx("^"%s<%d><%s><>^" gave a parachute to ^"%s^"", name,get_user_userid(id),authid,arg[1])
	}
	else {

		new player = cmd_target(id,arg,6)
		if (!player) return PLUGIN_HANDLED

		if (!has_parachute[player]) free_parachute[player] = true
		has_parachute[player] = true
		emit_sound( player, CHAN_ITEM, PAR_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
		get_user_name(player,name2,31)
		get_user_authid(player,authid2,34)

		switch(get_cvar_num("amx_show_activity")) {
			case 2:	client_print(0,print_chat,"%L",LANG_PLAYER,"PAR_ADMINS",name,name2)
			case 1:	client_print(0,print_chat,"%L",LANG_PLAYER,"PAR_ADMIN",name2)
		}

		//console_print(id,"[AMXX] You gave a parachute to ^"%s^"", name2)
		log_amx("^"%s<%d><%s><>^" gave a parachute to ^"%s<%d><%s><>^"", name,get_user_userid(id),authid,name2,get_user_userid(player),authid2)
	}
	return PLUGIN_HANDLED
}

public admin_took_parachute(id, level, cid) {

	//if (!gCStrike) return PLUGIN_CONTINUE

	if(!cmd_access(id,level,cid,2)) return PLUGIN_HANDLED

	if (!get_pcvar_num(pEnabled)) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "PAR_ON")
		return PLUGIN_HANDLED
	}

	new arg[32], name[32], name2[32], authid[35], authid2[35]
	read_argv(1,arg,31)
	get_user_name(id,name,31)
	get_user_authid(id,authid,34)

	if (arg[0]=='@'){
		new players[32], inum
		//if (equali("T",arg[1]))		copy(arg[1],31,"TERRORIST")
		if (equali("ALL",arg[1]))	get_players(players,inum)
		else						get_players(players,inum,"e",arg[1])

		if (inum == 0) {
			console_print(id,"No clients in such team")
			return PLUGIN_HANDLED
		}

		for(new a = 0; a < inum; a++) {
			parachute_reset(players[a])
			//emit_sound( players[a], CHAN_ITEM, ARMOR_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
		}

		if (equali("ALL",arg[1])) {
		switch(get_cvar_num("amx_show_activity"))	{
			case 2:	client_print(0,print_chat,"%L",LANG_PLAYER,"PAR_ADMINSA2",name,arg[1])
			case 1:	client_print(0,print_chat,"%L",LANG_PLAYER,"PAR_ADMINA2",arg[1])
		}
		}

		//console_print(id,"%L", LANG_PLAYER, "PAR_GIV",arg[1])
		log_amx("^"%s<%d><%s><>^" took a parachute from ^"%s^"", name,get_user_userid(id),authid,arg[1])
	}
	else {

		new player = cmd_target(id,arg,6)
		if (!player) return PLUGIN_HANDLED

		parachute_reset(player)
		//emit_sound( player, CHAN_ITEM, ARMOR_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
		get_user_name(player,name2,31)
		get_user_authid(player,authid2,34)

		switch(get_cvar_num("amx_show_activity")) {
			case 2:	client_print(0,print_chat,"%L",LANG_PLAYER,"PAR_ADMINS2",name,name2)
			case 1:	client_print(0,print_chat,"%L",LANG_PLAYER,"PAR_ADMIN2",name2)
		}

		//console_print(id,"[AMXX] You gave a parachute to ^"%s^"", name2)
		log_amx("^"%s<%d><%s><>^" took a parachute from ^"%s<%d><%s><>^"", name,get_user_userid(id),authid,name2,get_user_userid(player),authid2)
	}
	return PLUGIN_HANDLED
}

// shootGrenades

public globalTraceAttack(this,attackerID,Float:damage,Float:direction[3],tracehandle,damagebits)
{
	if(1 <= attackerID <= MaxPlayers)
	{
		static Float:origin[3]
		pev(attackerID,pev_origin,origin)

		static Float:end[3]
		get_tr2(tracehandle,TR_vecEndPos,end)

		new trace = create_tr2()

		new grenade = -1

		while((grenade = find_ent_by_class(grenade,"grenade")))
		{
			engfunc(EngFunc_TraceModel,origin,end,HULL_POINT,grenade,trace)

			if(get_tr2(trace,TR_pHit) == grenade)
			{
				new id = fm_cs_get_grenade_type_myid(grenade)

				if(id == Smoke)
				{
					if(get_pcvar_num(Cvars[id]))
					{
							//if (!g_hasfake[attackerID]) {
							set_pev(grenade,pev_flags,pev(grenade,pev_flags) | FL_ONGROUND)
							napalm_explode(grenade,attackerID)

							// get origin of explosion
							new Float:origin[3];
							pev(grenade,pev_origin,origin);

							// send the light flash
							message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
							write_byte(27); // TE_DLIGHT
							write_coord(floatround(origin[0])); // x
							write_coord(floatround(origin[1])); // y
							write_coord(floatround(origin[2])); // z
							write_byte(40); // radius
							write_byte(255);	// r
							write_byte(255); // g
							write_byte(255); // b
							write_byte(8); // life
							write_byte(60); // decay rate
							message_end();

							engfunc(EngFunc_RemoveEntity, grenade)
							/*} else {
							set_pdata_int(grenade, 114, 3, 5)
							set_pev(grenade,pev_dmgtime,0.0)
							dllfunc(DLLFunc_Think,grenade)
							} */

						// Connor
						//new en[12] = "flash"
						//set_pdata_int(grenade, 114, 25)
						//set_pev(grenade,pev_dmgtime,0.0)
						//dllfunc(DLLFunc_Think,grenade)
						//client_print(attackerID, print_chat, "%i",id)
					}
				}
		}
		}

		free_tr2(trace)
	}
}

// VEN
fm_cs_get_grenade_type_myid(index)
{
	if(get_pdata_int(index, 96) & (1<<8))
	{
		return 3
	}

	return get_pdata_int(index, 114) & 3
}

// Napalm Grenade Explosion
napalm_explode(ent,attacker)
{
	// Get attacker and its team
	//static attacker//, attacker_team
	//attacker = pev(ent, pev_owner)
	//attacker_team = pev(ent, pev_team)

	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)

	// Custom explosion effect
	//create_blast2(originF)

	// Napalm explosion sound
	//engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, grenade_fire[random_num(0, sizeof grenade_fire - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)

	// Collisions
	static victim
	victim = -1
    //new iGrenade = create_entity( "func_breakable" );
    //set_pev(iGrenade, pev_origin, originF);
 	//set_pev(iGrenade,pev_dmgtime,0.0)
	//dllfunc(DLLFunc_Think,iGrenade)

	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, 500.0)) != 0)
	{
		// Only effect alive players
		if (!is_user_alive(victim))
			continue;

		if (is_user_zombie(victim)) {
			if (get_class_id("FlashLeaper") == get_user_class(victim) || get_class_id("Nurse") == get_user_class(victim) || get_user_godmode(victim))
				emit_sound(victim,CHAN_BODY, "weapons/flashbang-2.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
			else
				Flash(victim,11,9,3,0,255,255,255,255)
		} else {
			Flash(victim,13,11,4,0,255,255,255,220)
		}

	}
	if (is_user_zombie(attacker)) {
		if (get_class_id("FlashLeaper") == get_user_class(attacker) || get_class_id("Nurse") == get_user_class(attacker) || get_user_godmode(attacker))
			emit_sound(attacker,CHAN_BODY, "weapons/flashbang-2.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
		else
			Flash(attacker,11,9,3,0,255,255,255,255)
	} else {
		Flash(attacker,13,11,4,0,255,255,255,220)
	}
}

public Flash(id,time,time2,time3,time4,color_r,color_g,color_b,color_a) {
	message_begin(MSG_ONE,gMsgScreenFade,{0,0,0},id)
	write_short( 1<<time )
	write_short( 1<<time2 )
	write_short( 1<<time3 )
	write_byte( color_r )
	write_byte( color_g )
	write_byte( color_b )
	write_byte( color_a )
	message_end()
	if (time4 == 0) emit_sound(id,CHAN_BODY, FLASH_PICKUP_SND, 1.0, ATTN_NORM, 0, PITCH_HIGH)
}

// customflashlight

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

public reset(id)
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

Make_FlashLight(id)
{
	if (!is_user_alive(id))
		return
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
	new menu = menu_create( szText, "menuf_shop" )

	formatex( szText, charsmax( szText ), "%L", id, "FLC_BMENU1");
	menu_additem( menu, szText, "1", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "FLC_BMENU2");
	menu_additem( menu, szText, "2", 0 );
	menu_setprop( menu, MPROP_PERPAGE, 0);

	menu_display( id, menu, 0 );

	return PLUGIN_CONTINUE;

}

public menuf_shop( id, menu, item )
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

// FragMoney

public maxzombies() {
	new count = 0

	for(new i = 0; i < 33; i++)
	{
		if (is_user_connected(i)) {
			if (is_user_alive(i) && is_user_zombie(i)) count++ //get_user_team(i) == CS_TEAM_T
		}
	}

	return (count == 0) ? true : false
}
/*
public player_death(){
	static a, v
	a = read_data(1) //attacker
	v = read_data(2) //victim
	if(a != v && 0 < a < 33 && 0 < v < 33 && is_user_alive(a) && cs_get_user_team(a) != cs_get_user_team(v) && !is_user_zombie(a) && is_user_zombie(v)) {
		if (maxzombies())
			set_task(0.1,"money2",a);
		else
			set_task(0.1,"money",a);
	}
	return PLUGIN_CONTINUE
}*/

public money(id) {
	cs_set_user_money_ul(id, cs_get_user_money_ul(id) - 300)
	cs_set_user_money_ul(id, cs_get_user_money_ul(id) + get_pcvar_num(gFragMoney))
}

public money2(id) {
	cs_set_user_money_ul(id, cs_get_user_money_ul(id) - 300)
	cs_set_user_money_ul(id, cs_get_user_money_ul(id) + get_pcvar_num(gFragMoneyLast))
}

//