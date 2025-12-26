 /* Biohazard mod
*
*  by Cheap_Suit
*
*    This plugin was modified for Botov-NET Project
*    Modifed by AlexALX (c) 2009-2015 by http://alex-php.net/
*    Source of botov.net.ua project (c) 2008-2015
*
*  This program is free software; you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by the
*  Free Software Foundation; either version 2 of the License, or (at
*  your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but
*  WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*  General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software Foundation,
*  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve,
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/

#define VERSION	"2.1.1"

#include <amxmodx>
#include <money_ul>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <vip>
#include <fun>
#include <flashlight>
#include <flash>
#include <fire>
#include <drug>
#include <snark>
#include <par_lj>

#tryinclude "biohazard.cfg"

enum ShadowIdX
{
	SHADOW_REMOVE = 0,
}

new ShadowIdX:SHADOW_CREATE
new bool:cl_removed_shadow[33] = {false, ...}

#if !defined _biohazardcfg_included
	#assert Biohazard configuration file required!
#elseif AMXX_VERSION_NUM < 180
	#assert AMX Mod X v1.8.0 or greater required!
#endif

//#define TERMINATOR

//#if defined TERMINATOR
	new bool:Terminator[33]
//#endif

//#define SANTAHAT

#if defined SANTAHAT
	new g_bwEnt[33];
	new g_CachedStringInfoTarget;
#endif

#define OFFSET_DEATH 444
#define OFFSET_TEAM 114
#define OFFSET_ARMOR 112
#define OFFSET_NVG 129
#define OFFSET_CSMONEY 115
#define OFFSET_PRIMARYWEAPON 116
#define OFFSET_WEAPONTYPE 43
#define OFFSET_CLIPAMMO	51
#define EXTRAOFFSET_WEAPONS 4

#define OFFSET_AMMO_338MAGNUM 377
#define OFFSET_AMMO_762NATO 378
#define OFFSET_AMMO_556NATOBOX 379
#define OFFSET_AMMO_556NATO 380
#define OFFSET_AMMO_BUCKSHOT 381
#define OFFSET_AMMO_45ACP 382
#define OFFSET_AMMO_57MM 383
#define OFFSET_AMMO_50AE 384
#define OFFSET_AMMO_357SIG 385
#define OFFSET_AMMO_9MM 386

#define OFFSET_LASTPRIM 368
#define OFFSET_LASTSEC 369
#define OFFSET_LASTKNI 370

#define TASKID_STRIPNGIVE 698
#define TASKID_NEWROUND	641
#define TASKID_INITROUND 222
#define TASKID_STARTROUND 153
#define TASKID_BALANCETEAM 375
#define TASKID_UPDATESCR 264
#define TASKID_SPAWNDELAY 786
#define TASKID_WEAPONSMENU 564
#define TASKID_CHECKSPAWN 423
#define TASKID_CZBOTPDATA 312

#define EQUIP_PRI (1<<0)
#define EQUIP_SEC (1<<1)
#define EQUIP_GREN (1<<2)
#define EQUIP_ALL (1<<0 | 1<<1 | 1<<2)

#define HAS_NVG (1<<0)
#define ATTRIB_BOMB (1<<1)
#define DMG_HEGRENADE (1<<24)

#define MODEL_CLASSNAME "player_model"
#define IMPULSE_FLASHLIGHT 100

#define MAX_SPAWNS 128
#define MAX_CLASSES 25
#define MAX_DATA 11

#define DATA_HEALTH 0
#define DATA_SPEED 1
#define DATA_GRAVITY 2
#define DATA_ATTACK 3
#define DATA_DEFENCE 4
#define DATA_HEDEFENCE 5
#define DATA_HITSPEED 6
#define DATA_HITDELAY 7
#define DATA_REGENDLY 8
#define DATA_HITREGENDLY 9
#define DATA_KNOCKBACK 10

#define TASK_NVISION 2000
#define ID_NVISION (taskid - TASK_NVISION)

#define TASKID_STUCK 2500

#define fm_get_user_team(%1) get_pdata_int(%1, OFFSET_TEAM)
#define fm_get_user_deaths(%1) get_pdata_int(%1, OFFSET_DEATH)
#define fm_set_user_deaths(%1,%2) set_pdata_int(%1, OFFSET_DEATH, %2)
#define fm_get_user_money(%1) cs_get_user_money_ul(%1) //get_pdata_int(%1, OFFSET_CSMONEY)
#define fm_get_user_armortype(%1) get_pdata_int(%1, OFFSET_ARMOR)
#define fm_set_user_armortype(%1,%2) set_pdata_int(%1, OFFSET_ARMOR, %2)
#define fm_get_weapon_id(%1) get_pdata_int(%1, OFFSET_WEAPONTYPE, EXTRAOFFSET_WEAPONS)
#define fm_get_weapon_ammo(%1) get_pdata_int(%1, OFFSET_CLIPAMMO, EXTRAOFFSET_WEAPONS)
#define fm_set_weapon_ammo(%1,%2) set_pdata_int(%1, OFFSET_CLIPAMMO, %2, EXTRAOFFSET_WEAPONS)
#define fm_reset_user_primary(%1) set_pdata_int(%1, OFFSET_PRIMARYWEAPON, 0)
#define fm_lastprimary(%1) get_pdata_cbase(id, OFFSET_LASTPRIM)
#define fm_lastsecondry(%1) get_pdata_cbase(id, OFFSET_LASTSEC)
#define fm_lastknife(%1) get_pdata_cbase(id, OFFSET_LASTKNI)
#define fm_get_user_model(%1,%2,%3) engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, %1), "model", %2, %3)

#define _random(%1) random_num(0, %1 - 1)
#define AMMOWP_NULL (1<<0 | 1<<CSW_KNIFE | 1<<CSW_FLASHBANG | 1<<CSW_HEGRENADE | 1<<CSW_SMOKEGRENADE | 1<<CSW_C4)

#define G_PICKUP_SND	"items/9mmclip1.wav"

new g_IconStatus
//new g_frozen[33]
new g_shadow

enum
{
	MAX_CLIP = 0,
	MAX_AMMO
}

enum
{
	MENU_PRIMARY = 1,
	MENU_SECONDARY
}

enum
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T,
	CS_TEAM_CT,
	CS_TEAM_SPECTATOR
}

enum
{
	CS_ARMOR_NONE = 0,
	CS_ARMOR_KEVLAR,
	CS_ARMOR_VESTHELM
}

enum
{
	KBPOWER_357SIG = 0,
	KBPOWER_762NATO,
	KBPOWER_BUCKSHOT,
	KBPOWER_45ACP,
	KBPOWER_556NATO,
	KBPOWER_9MM,
	KBPOWER_57MM,
	KBPOWER_338MAGNUM,
	KBPOWER_556NATOBOX,
	KBPOWER_50AE
}

new const g_weapon_ammo[][] =
{
	{ -1, -1 },
	{ 13, 52 },
	{ -1, -1 },
	{ 10, 90 },
	{ -1, -1 },
	{ 7, 32 },
	{ -1, -1 },
	{ 30, 100 },
	{ 30, 90 },
	{ -1, -1 },
	{ 30, 120 },
	{ 20, 100 },
	{ 25, 100 },
	{ 30, 90 },
	{ 35, 90 },
	{ 25, 90 },
	{ 12, 100 },
	{ 20, 120 },
	{ 10, 30 },
	{ 30, 120 },
	{ 100, 200 },
	{ 8, 32 },
	{ 30, 90 },
	{ 30, 120 },
	{ 20, 90 },
	{ -1, -1 },
	{ 7, 35 },
	{ 30, 90 },
	{ 30, 90 },
	{ -1, -1 },
	{ 50, 100 }
}

new const g_weapon_knockback[] =
{
	-1,
	KBPOWER_357SIG,
	-1,
	KBPOWER_762NATO,
	-1,
	KBPOWER_BUCKSHOT,
	-1,
	KBPOWER_45ACP,
	KBPOWER_556NATO,
	-1,
	KBPOWER_9MM,
	KBPOWER_57MM,
	KBPOWER_45ACP,
	KBPOWER_556NATO,
	KBPOWER_556NATO,
	KBPOWER_556NATO,
	KBPOWER_45ACP,
	KBPOWER_9MM,
	KBPOWER_338MAGNUM,
	KBPOWER_9MM,
	KBPOWER_556NATOBOX,
	KBPOWER_BUCKSHOT,
	KBPOWER_556NATO,
	KBPOWER_9MM,
	KBPOWER_762NATO,
	-1,
	KBPOWER_50AE,
	KBPOWER_556NATO,
	KBPOWER_762NATO,
	-1,
	KBPOWER_57MM
}

new const g_remove_entities[][] =
{
	"func_bomb_target",
	"info_bomb_target",
	"hostage_entity",
	"monster_scientist",
	"func_hostage_rescue",
	"info_hostage_rescue",
	"info_vip_start",
	"func_vip_safetyzone",
	"func_escapezone",
	"func_buyzone"
}

new const g_dataname[][] =
{
	"HEALTH",
	"SPEED",
	"GRAVITY",
	"ATTACK",
	"DEFENCE",
	"HEDEFENCE",
	"HITSPEED",
	"HITDELAY",
	"REGENDLY",
	"HITREGENDLY",
	"KNOCKBACK"
}
new const g_teaminfo[][] =
{
	"UNASSIGNED",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

new g_maxplayers, g_spawncount, g_buyzone, g_botclient_pdata, g_sync_hpdisplay,
    g_sync_msgdisplay, g_fwd_spawn, g_fwd_result, g_fwd_infect, g_fwd_gamestart,
    g_msg_flashlight, g_msg_teaminfo, g_msg_scoreattrib, g_msg_scoreinfo,
    g_msg_deathmsg , g_msg_screenfade, Float:g_buytime,  Float:g_spawns[MAX_SPAWNS+1][9],
    Float:g_vecvel[3], bool:g_brestorevel, bool:g_infecting, bool:g_gamestarted,
    bool:g_roundended, bool:g_czero, g_class_name[MAX_CLASSES+1][32],
    g_classcount, g_class_desc[MAX_CLASSES+1][32], g_class_pmodel[MAX_CLASSES+1][64], g_class_tmodel[MAX_CLASSES+1][64],
    g_class_wmodel[MAX_CLASSES+1][64], Float:g_class_data[MAX_CLASSES+1][MAX_DATA]
    // , g_msg_money
new cvar_randomspawn, cvar_skyname, cvar_autoteambalance[4], cvar_starttime, cvar_autonvg,
    cvar_winsounds, cvar_weaponsmenu, cvar_lights, cvar_killbonus, cvar_enabled,
    cvar_gamedescription, cvar_botquota, cvar_maxzombies, cvar_flashbang, cvar_buytime,
    cvar_respawnaszombie, cvar_punishsuicide, cvar_infectmoney, cvar_showtruehealth,
    cvar_obeyarmor, cvar_impactexplode, cvar_caphealthdisplay, cvar_zombie_hpmulti,
    cvar_randomclass, cvar_zombiemulti, cvar_knockback, cvar_knockback_dist, cvar_ammo,
    cvar_knockback_duck, cvar_killreward, cvar_painshockfree, cvar_zombie_class,
    cvar_shootobjects, cvar_pushpwr_weapon, cvar_pushpwr_zombie,cvar_scan_cost,cvar_cloak_cost,
    cvar_blockfall

new bool:g_zombie[33], bool:g_falling[33], bool:g_disconnected[33], bool:g_blockmodel[33],
    bool:g_showmenu[33], bool:g_menufailsafe[33], bool:g_preinfect[33], bool:g_welcomemsg[33],
	Float:g_regendelay[33], Float:g_hitdelay[33], g_mutate[33], g_victim[33],
    g_modelent[33], g_modelent2[33], g_menuposition[33], g_player_class[33], g_player_weapons[33][2], bool:has_scan[33], bool:has_cloak[33], bool:has_vipcloak[33], has_cloak_act[33],
    bool:g_showclass[33]

new g_spawnCount, Float:g_spawns2[128][3]//, g_vipammo[33]

new bool:g_silent[33]
#define STANDARDTIMESTEPSOUND 400

#define PICKUP_SND		"items/gunpickup2.wav"
new const sound_armorhit[] = "player/bhit_helmet-1.wav"

#define HAS_NVGS		(1<<0)
#define USES_NVGS		(1<<8)
#define get_user_nvg(%1)    	(get_pdata_int(%1,m_iNvg) & HAS_NVGS)
/* --| Offsets for nvg */
const m_iNvg = 129;
const m_iLinuxDiff = 5;
new gMessageNVG, BuyZombieCost, BuyHumanCost

new g_nvisionenabled[33]

public plugin_precache()
{
	register_plugin("Biohazard", VERSION, "cheap_suit & AlexALX")
	register_cvar("bh_version", VERSION, FCVAR_SPONLY|FCVAR_SERVER)
	set_cvar_string("bh_version", VERSION)

	SHADOW_CREATE = ShadowIdX:precache_model("sprites/shadow_circle.spr")
	cvar_enabled = register_cvar("bh_enabled", "1")

	if(!get_pcvar_num(cvar_enabled))
		return

	cvar_gamedescription = register_cvar("bh_gamedescription", "Biohazard")
	cvar_skyname = register_cvar("bh_skyname", "drkg")
	cvar_lights = register_cvar("bh_lights", "d")
	cvar_starttime = register_cvar("bh_starttime", "15.0")
	cvar_buytime = register_cvar("bh_buytime", "0")
	cvar_randomspawn = register_cvar("bh_randomspawn", "0")
	cvar_punishsuicide = register_cvar("bh_punishsuicide", "1")
	cvar_winsounds = register_cvar("bh_winsounds", "1")
	cvar_autonvg = register_cvar("bh_autonvg", "1")
	cvar_respawnaszombie = register_cvar("bh_respawnaszombie", "1")
	cvar_painshockfree = register_cvar("bh_painshockfree", "1")
	cvar_knockback = register_cvar("bh_knockback", "1")
	cvar_knockback_duck = register_cvar("bh_knockback_duck", "1")
	cvar_knockback_dist = register_cvar("bh_knockback_dist", "280.0")
	cvar_obeyarmor = register_cvar("bh_obeyarmor", "0")
	cvar_infectmoney = register_cvar("bh_infectionmoney", "0")
	cvar_caphealthdisplay = register_cvar("bh_caphealthdisplay", "1")
	cvar_weaponsmenu = register_cvar("bh_weaponsmenu", "1")
	cvar_ammo = register_cvar("bh_ammo", "1")
	cvar_maxzombies = register_cvar("bh_maxzombies", "31")
	cvar_flashbang = register_cvar("bh_flashbang", "1")
	cvar_impactexplode = register_cvar("bh_impactexplode", "1")
	cvar_showtruehealth = register_cvar("bh_showtruehealth", "1")
	cvar_zombiemulti = register_cvar("bh_zombie_countmulti", "0.15")
	cvar_zombie_hpmulti = register_cvar("bh_zombie_hpmulti", "2.0")
	cvar_zombie_class = register_cvar("bh_zombie_class", "1")
	cvar_randomclass = register_cvar("bh_randomclass", "1")
	cvar_killbonus = register_cvar("bh_kill_bonus", "1")
	cvar_killreward = register_cvar("bh_kill_reward", "2")
	cvar_shootobjects = register_cvar("bh_shootobjects", "1")
	cvar_pushpwr_weapon = register_cvar("bh_pushpwr_weapon", "2.0")
	cvar_pushpwr_zombie = register_cvar("bh_pushpwr_zombie", "5.0")
	cvar_scan_cost = register_cvar("amx_scan_cost","500")
	cvar_cloak_cost = register_cvar("amx_cloak_cost","1500")
	cvar_blockfall = register_cvar("bh_blockfall","1")
	BuyZombieCost = register_cvar("amx_buy_zombie","5000")
	BuyHumanCost = register_cvar("amx_buy_antivirus","7000")

	new file[64]
	get_configsdir(file, 63)
	format(file, 63, "%s/bh_cvars.cfg", file)

	if(file_exists(file))
		server_cmd("exec %s", file)

	new mapname[32]
	get_mapname(mapname, 31)
	register_spawnpoints(mapname)

	register_zombieclasses("bh_zombieclass.ini")
	register_dictionary("biohazard.txt")
	register_dictionary("user.txt")

	precache_model(DEFAULT_PMODEL)
	//precache_model( "models/p_alt_squeak.mdl" );
	if (file_exists(DEFAULT_TMODEL))
		precache_model(DEFAULT_TMODEL)
	precache_model(DEFAULT_WMODEL)
	//precache_model("models/player/vip/vip.mdl")
	precache_model("models/player/claire/claire.mdl")
	precache_model("models/player/lilith/lilith.mdl")
	precache_model("models/player/lilith/lilithT.mdl")

	#if defined SANTAHAT
		precache_model("models/santa_hat.mdl");
	#endif

	new i
	for(i = 0; i < g_classcount; i++)
	{
		precache_model(g_class_pmodel[i])
		if (!equali(g_class_tmodel[i],DEFAULT_TMODEL))
			precache_model(g_class_tmodel[i])
		precache_model(g_class_wmodel[i])
	}

	for(i = 0; i < sizeof g_zombie_miss_sounds; i++)
		precache_sound(g_zombie_miss_sounds[i])

	for(i = 0; i < sizeof g_zombie_hit_sounds; i++)
		precache_sound(g_zombie_hit_sounds[i])

	for(i = 0; i < sizeof g_scream_sounds; i++)
		precache_sound(g_scream_sounds[i])

	for(i = 0; i < sizeof g_zombie_die_sounds; i++)
		precache_sound(g_zombie_die_sounds[i])

	for(i = 0; i < sizeof g_zombie_win_sounds; i++)
		precache_sound(g_zombie_win_sounds[i])

	for(i = 0; i < sizeof g_survivor_win_sounds; i++)
		precache_sound(g_survivor_win_sounds[i])

	for(i = 0; i < sizeof g_zombie_pain; i++)
		precache_sound(g_zombie_pain[i])

	g_fwd_spawn = register_forward(FM_Spawn, "fwd_spawn")

	g_buyzone = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"))
	if(g_buyzone)
	{
		dllfunc(DLLFunc_Spawn, g_buyzone)
		set_pev(g_buyzone, pev_solid, SOLID_NOT)
	}

	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_bomb_target"))
	if(ent)
	{
		dllfunc(DLLFunc_Spawn, ent)
		set_pev(ent, pev_solid, SOLID_NOT)
	}

	#if FOG_ENABLE
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
	if(ent)
	{
		fm_set_kvd(ent, "density", FOG_DENSITY, "env_fog")
		fm_set_kvd(ent, "rendercolor", FOG_COLOR, "env_fog")
	}
	#endif

	precache_sound( PICKUP_SND );
	precache_sound( G_PICKUP_SND );
	engfunc(EngFunc_PrecacheSound, sound_armorhit)

	set_task( 14.0, "RestartRound");
	//set_task( 28.0, "RestartRound3");

	#if defined TERMINATOR
	precache_model("models/player/terminator/terminator.mdl")
	#endif

}

public RestartRound()
	server_cmd("sv_restart 1");

/*
public RestartRound3()
	server_cmd("sv_restart 3");
*/
public plugin_init()
{
	if(!get_pcvar_num(cvar_enabled))
		return

	cvar_botquota = get_cvar_pointer("bot_quota")
	cvar_autoteambalance[0] = get_cvar_pointer("mp_autoteambalance")
	cvar_autoteambalance[1] = get_pcvar_num(cvar_autoteambalance[0])
	set_pcvar_num(cvar_autoteambalance[0], 0)

	register_clcmd("jointeam", "cmd_jointeam")
	register_clcmd("say /class", "cmd_classmenu")
	register_clcmd("say class", "cmd_classmenu")
	register_clcmd("/class", "cmd_classmenu")
	register_clcmd("class", "cmd_classmenu")
	register_clcmd("say /guns", "cmd_enablemenu")
	register_clcmd("say guns", "cmd_enablemenu")
	register_clcmd("/guns", "cmd_enablemenu")
	register_clcmd("guns", "cmd_enablemenu")
	register_clcmd("say /help", "cmd_helpmotd")
	register_clcmd("say help", "cmd_helpmotd")
	register_clcmd("say /помощь", "cmd_helpmotd")
	register_clcmd("say помощь", "cmd_helpmotd")
	register_clcmd("/help", "cmd_helpmotd")
	register_clcmd("help", "cmd_helpmotd")
	register_clcmd("/помощь", "cmd_helpmotd")
	register_clcmd("помощь", "cmd_helpmotd")
	register_clcmd("amx_infect", "cmd_infectuser", ADMIN_BAN, "<name or #userid>")
	register_clcmd("say scan", "cmd_scan")
	register_clcmd("say /scan", "cmd_scan")
	register_clcmd("scan", "cmd_scan")
	register_clcmd("/scan", "cmd_scan")
	register_clcmd("say cloak", "cmd_cloak")
	register_clcmd("say /cloak", "cmd_cloak")
	register_clcmd("cloak", "cmd_cloak")
	register_clcmd("/cloak", "cmd_cloak")
	register_clcmd("say sell_cloak", "sell_cloak")
	register_clcmd("say /sell_cloak", "sell_cloak")
	register_clcmd("sell_cloak", "sell_cloak")
	register_clcmd("/sell_cloak", "sell_cloak")
	register_event("DeathMsg", "death_event", "a")
	register_clcmd("nightvision", "clcmd_nightvision")

	register_clcmd("say unstuck", "clcmd_sayunstuck")
	register_clcmd("say /unstuck", "clcmd_sayunstuck")
	register_clcmd("unstuck", "clcmd_sayunstuck")
	register_clcmd("/unstuck", "clcmd_sayunstuck")

	//register_clcmd("amx_frozen", "cmd_frozen", ADMIN_RCON, "<name or #userid> <1/0>")
	register_concmd("amx_human", "cmd_humanuser", ADMIN_BAN, "<nick or #userid>")

	register_concmd("say buy_zombie", "buy_zombie")
	register_concmd("say buy_antivirus", "human_cmd")
	register_concmd("say buy_antivirys", "human_cmd")
	register_concmd("say buy_antidot", "human_cmd")
	register_concmd("say buy_human", "human_cmd")
	register_concmd("say /buy_zombie", "buy_zombie")
	register_concmd("say /buy_antivirus", "human_cmd")
	register_concmd("say /buy_antivirys", "human_cmd")
	register_concmd("say /buy_antidot", "human_cmd")
	register_concmd("say /buy_human", "human_cmd")
	register_concmd("buy_zombie", "buy_zombie")
	register_concmd("buy_human", "human_cmd")
	register_concmd("buy_antivirus", "human_cmd")
	register_concmd("buy_antivirys", "human_cmd")
	register_concmd("buy_antidot", "human_cmd")
	register_concmd("/buy_zombie", "buy_zombie")
	register_concmd("/buy_human", "human_cmd")
	register_concmd("/buy_antivirus", "human_cmd")
	register_concmd("/buy_antivirys", "human_cmd")
	register_concmd("/buy_antidot", "human_cmd")

	register_menu("Equipment", 1023, "action_equip")
	register_menu("Primary", 1023, "action_prim")
	register_menu("Secondary", 1023, "action_sec")
	register_menu("Class", 1023, "action_class")

	unregister_forward(FM_Spawn, g_fwd_spawn)
	register_forward(FM_CmdStart, "fwd_cmdstart")
	register_forward(FM_EmitSound, "fwd_emitsound")
	register_forward(FM_GetGameDescription, "fwd_gamedescription")
	register_forward(FM_CreateNamedEntity, "fwd_createnamedentity")
	register_forward(FM_ClientKill, "fwd_clientkill")
	register_forward(FM_PlayerPreThink, "fwd_player_prethink")
	register_forward(FM_PlayerPreThink, "fwd_player_prethink_post", 1)
	register_forward(FM_PlayerPostThink, "fwd_player_postthink")
	register_forward(FM_SetClientKeyValue, "fwd_setclientkeyvalue")

	RegisterHam(Ham_TakeDamage, "player", "bacon_takedamage_player")
	RegisterHam(Ham_Killed, "player", "bacon_killed_player")
	RegisterHam(Ham_Spawn, "player", "bacon_spawn_player_post", 1)
	RegisterHam(Ham_TraceAttack, "player", "bacon_traceattack_player")
	RegisterHam(Ham_TraceAttack, "func_pushable", "bacon_traceattack_pushable")
	RegisterHam(Ham_Use, "func_tank", "bacon_use_tank")
	RegisterHam(Ham_Use, "func_tankmortar", "bacon_use_tank")
	RegisterHam(Ham_Use, "func_tankrocket", "bacon_use_tank")
	RegisterHam(Ham_Use, "func_tanklaser", "bacon_use_tank")
	RegisterHam(Ham_Use, "func_pushable", "bacon_use_pushable")
	RegisterHam(Ham_Use, "func_recharge", "bacon_use_tank")
	RegisterHam(Ham_Touch, "func_pushable", "bacon_touch_pushable")
	RegisterHam(Ham_Touch, "weaponbox", "bacon_touch_weapon")
	RegisterHam(Ham_Touch, "item_battery", "bacon_touch_weapon")
	RegisterHam(Ham_Touch, "armoury_entity", "bacon_touch_weapon")
	RegisterHam(Ham_Touch, "weapon_shield", "bacon_touch_weapon")
	RegisterHam(Ham_Touch, "grenade", "bacon_touch_grenade")

	register_message(get_user_msgid("Health"), "msg_health")
	register_message(get_user_msgid("Battery"), "msg_armor")
	register_message(get_user_msgid("TextMsg"), "msg_textmsg")
	register_message(get_user_msgid("SendAudio"), "msg_sendaudio")
	register_message(get_user_msgid("StatusIcon"), "msg_statusicon")
	register_message(get_user_msgid("ScoreAttrib"), "msg_scoreattrib")
	register_message(get_user_msgid("DeathMsg"), "msg_deathmsg")
	register_message(get_user_msgid("ScreenFade"), "msg_screenfade")
	register_message(get_user_msgid("TeamInfo"), "msg_teaminfo")
	register_message(get_user_msgid("ClCorpse"), "msg_clcorpse")
	register_message(get_user_msgid("WeapPickup"), "msg_weaponpickup")
	register_message(get_user_msgid("AmmoPickup"), "msg_ammopickup")

	register_event("TextMsg", "event_textmsg", "a", "2=#Game_will_restart_in")
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	register_event("ArmorType", "event_armortype", "be")
	register_event("Damage", "event_damage", "be")

	register_logevent("logevent_round_start", 2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")

	g_msg_flashlight = get_user_msgid("Flashlight")
	g_msg_teaminfo = get_user_msgid("TeamInfo")
	g_msg_scoreattrib = get_user_msgid("ScoreAttrib")
	g_msg_scoreinfo = get_user_msgid("ScoreInfo")
	g_msg_deathmsg = get_user_msgid("DeathMsg")
	//g_msg_money = get_user_msgid("Money")
	g_msg_screenfade = get_user_msgid("ScreenFade")
	gMessageNVG = get_user_msgid( "NVGToggle" );

	g_fwd_infect = CreateMultiForward("event_infect", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwd_gamestart = CreateMultiForward("event_gamestart", ET_IGNORE)

	g_sync_hpdisplay = CreateHudSyncObj()
	g_sync_msgdisplay = CreateHudSyncObj()
	g_IconStatus = get_user_msgid("StatusIcon")
	g_shadow = get_user_msgid("ShadowIdx")

	g_maxplayers = get_maxplayers()

	load_spawns()

	new mod[3]
	get_modname(mod, 2)

	g_czero = (mod[0] == 'c' && mod[1] == 'z') ? true : false

	new skyname[32]
	get_pcvar_string(cvar_skyname, skyname, 31)

	if(strlen(skyname) > 0)
		set_cvar_string("sv_skyname", skyname)

	new lights[2]
	get_pcvar_string(cvar_lights, lights, 1)

	if(strlen(lights) > 0)
	{
		set_task(3.0, "task_lights", _, _, _, "b")

		set_cvar_num("sv_skycolor_r", 0)
		set_cvar_num("sv_skycolor_g", 0)
		set_cvar_num("sv_skycolor_b", 0)
	}

	if(get_pcvar_num(cvar_showtruehealth))
		set_task(0.1, "task_showtruehealth", _, _, _, "b")

	#if defined SANTAHAT
		g_CachedStringInfoTarget = engfunc( EngFunc_AllocString, "info_target" );
	#endif

	#if defined TERMINATOR
	register_concmd("amx_terminator", "cmd_terminator", ADMIN_RCON, "<nick or #userid>")
	#endif

}

public plugin_end()
{
	if(get_pcvar_num(cvar_enabled))
		set_pcvar_num(cvar_autoteambalance[0], cvar_autoteambalance[1])
}

public plugin_natives()
{
	register_library("biohazardf")
	register_native("preinfect_user", "native_preinfect_user", 1)
	register_native("infect_user", "native_infect_user", 1)
	register_native("cure_user", "native_cure_user", 1)
	register_native("register_class", "native_register_class", 1)
	register_native("get_class_id", "native_get_class_id", 1)
	register_native("set_class_pmodel", "native_set_class_pmodel", 1)
	register_native("set_class_wmodel", "native_set_class_wmodel", 1)
	register_native("set_class_data", "native_set_class_data", 1)
	register_native("get_class_data", "native_get_class_data", 1)
	register_native("game_started", "native_game_started", 1)
	register_native("is_user_zombie", "native_is_user_zombie", 1)
	register_native("set_start_weap", "native_set_start_weap", 1)
	register_native("is_user_infected", "native_is_user_infected", 1)
	register_native("get_user_class", "native_get_user_class",  1)
	register_native("ad_infect_user", "cmd_infect", 1)
	register_native("ad_human_user", "cmd_human", 1)
	register_native("reset_user_nv", "native_reset_user_nv", 1)
	register_native("del_modelent2", "native_del_modelent2", 1)
	register_native("sel_modelent2", "native_sel_modelent2", 1)
	register_native("user_footsteps", "user_footsteps", 1)
	register_native("setvis_zm_model", "native_vis_zm_model", 1)
	register_native("set_cloak","native_set_cloak",1)
	register_native("get_cloak","native_get_cloak",1)
	register_native("get_vipcloak","native_get_vipcloak",1)
	//#if defined TERMINATOR
	register_native("is_terminator","native_terminator",1)
	//#endif
}

public client_connect(id)
{
	g_showmenu[id] = true
	g_welcomemsg[id] = true
	g_blockmodel[id] = true
	g_zombie[id] = false
	g_preinfect[id] = false
	g_disconnected[id] = false
	//g_vipammo[id] = false
	g_falling[id] = false
	g_menufailsafe[id] = false
	has_scan[id] = false
	has_cloak[id] = false
	has_vipcloak[id] = false
	has_cloak_act[id] = 0
	g_nvisionenabled[id] = false
	g_victim[id] = 0
	g_mutate[id] = -1
	g_player_class[id] = 0
	g_player_weapons[id][0] = -1
	g_player_weapons[id][1] = -1
	g_regendelay[id] = 0.0
	g_hitdelay[id] = 0.0
	//g_frozen[id] = false
	g_showclass[id] = true
	g_silent[id] = false
	cl_removed_shadow[id] = false

	remove_user_model(g_modelent[id])
	remove_user_model2(g_modelent2[id])
}

public client_putinserver(id)
{
	if(!g_botclient_pdata && g_czero)
	{
		static param[1]
		param[0] = id

		if(!task_exists(TASKID_CZBOTPDATA))
			set_task(1.0, "task_botclient_pdata", TASKID_CZBOTPDATA, param, 1)
	}

	if(get_pcvar_num(cvar_randomclass) && g_classcount > 1)
		g_player_class[id] = _random(g_classcount)
}

public client_disconnect(id)
{
	remove_task(TASKID_STRIPNGIVE + id)
	remove_task(TASKID_UPDATESCR + id)
	remove_task(TASKID_SPAWNDELAY + id)
	remove_task(TASKID_WEAPONSMENU + id)
	remove_task(TASKID_CHECKSPAWN + id)
	remove_task(TASK_NVISION + id)
	remove_task(TASKID_STUCK + id)

	g_disconnected[id] = true
	has_scan[id] = false
	has_cloak[id] = false
	has_vipcloak[id] = false
	has_cloak_act[id] = 0
	//g_vipammo[id] = false
	g_nvisionenabled[id] = false
	//g_frozen[id] = false
	g_showclass[id] = true
	g_silent[id] = false
	cl_removed_shadow[id] = false
	remove_user_model(g_modelent[id])
	remove_user_model2(g_modelent2[id])

	#if defined TERMINATOR
	Terminator[id] = false
	#endif
}

public cmd_jointeam(id)
{
	if(is_user_alive(id) && g_zombie[id])
	{
		client_print(id, print_center, "%L", id, "CMD_TEAMCHANGE")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public cmd_classmenu(id)
	if(g_classcount > 1) display_classmenu(id, g_menuposition[id] = 0)

public cmd_enablemenu(id)
{
	if(get_pcvar_num(cvar_weaponsmenu))
	{
		client_print(id, print_chat, "%L", id, g_showmenu[id] == false ? "MENU_REENABLED" : "MENU_ALENABLED")
		g_showmenu[id] = true
	}
}

public cmd_helpmotd(id)
{
	static motd[2048]
	formatex(motd, 2047, "%L", id, "HELP_MOTD")
	replace(motd, 2047, "#Version#", VERSION)

	show_motd(id, motd, "Biohazard Help")
}

public cmd_scan(id) {

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", LANG_PLAYER, "SCAN_DIE")
		return PLUGIN_HANDLED
	}
	if(!g_gamestarted) {
		if (!has_scan[id]) {
			new money = cs_get_user_money_ul(id)

			new cost = (get_vip_flags(id) & VIP_FLAG_C ? get_pcvar_num(cvar_scan_cost)/2 : get_pcvar_num(cvar_scan_cost))
			if ( money < cost )
			{
					client_print(id, print_chat, "%L", LANG_PLAYER, "SCAN_COST", cost)
					return PLUGIN_CONTINUE
			}
			cs_set_user_money_ul(id, money - cost)
			has_scan[id] = true
		}
		client_print(id, print_chat, "%L %L", id, "SCAN_RESULTS", id, g_preinfect[id] ? "SCAN_INFECTED" : "SCAN_CLEAN")
	} else
		client_print(id, print_chat, "%L", id, "SCAN_START")

	return PLUGIN_HANDLED

}

public cmd_cloak(id) {

	if (Terminator[id])
		return PLUGIN_HANDLED

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", LANG_PLAYER, "CLOAK_DIE")
		return PLUGIN_HANDLED
	}

	if (!has_cloak[id]) {
		new money = cs_get_user_money_ul(id)

		new cost = ( get_vip_flags(id) & VIP_FLAG_C ? floatround(get_pcvar_num( cvar_cloak_cost )*0.7) : get_pcvar_num( cvar_cloak_cost ))
		if ( money < cost )
		{
				client_print(id, print_chat, "%L", LANG_PLAYER, "CLOAK_COST", cost)
				return PLUGIN_CONTINUE
		}
		cs_set_user_money_ul(id, money - cost)
		has_cloak[id] = true
		has_vipcloak[id] = (get_vip_flags(id) & VIP_FLAG_C ? true : false)

		client_print(id, print_chat, "%L", id, "CLOAK_BUY")

	} else {
		client_print(id, print_chat, "%L", id, "CLOAK_HAVE")
	}

	return PLUGIN_HANDLED

}

public sell_cloak(id) {

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", LANG_PLAYER, "CLOAK_DIE")
		return PLUGIN_HANDLED
	}

	if (has_cloak[id]) {
		new money = cs_get_user_money_ul(id)

		new cost = floatround((has_vipcloak[id] ? floatround(get_pcvar_num( cvar_cloak_cost )*0.7 * 75 / 100.0) : get_pcvar_num( cvar_cloak_cost )) * 75 / 100.0)
		cs_set_user_money_ul(id, money + cost)
		has_cloak[id] = false
		has_vipcloak[id] = false

		client_print(id, print_chat, "%L", id, "CLOAK_SELL", cost)

	} else {
		client_print(id, print_chat, "%L", id, "CLOAK_NHAVE")
	}

	return PLUGIN_HANDLED

}


public native_set_cloak(id,bool:set) {

	if ( !is_user_alive(id) )
	{
		return
	}
	has_cloak[id] = set
	return

}

public native_get_cloak(id) {

	if ( !is_user_alive(id) )
	{
		return false
	}
	return has_cloak[id];

}

public native_get_vipcloak(id) {

	if ( !is_user_alive(id) )
	{
		return false
	}
	return has_vipcloak[id];

}

//#if defined TERMINATOR
public native_terminator(id) {

	if ( !is_user_alive(id) )
	{
		return false
	}
	return Terminator[id];

}
//#endif

public cmd_infectuser(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED_MAIN

	static target, arg1[32]
	read_argv(1, arg1, 31)
	target = cmd_target(id, arg1, (CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE))

	if(!is_user_connected(target) || g_zombie[target])
		return PLUGIN_HANDLED_MAIN

	/*if(!allow_infection())
	{
		console_print(id, "%L", id, "CMD_MAXZOMBIES")
		return PLUGIN_HANDLED_MAIN
	}*/

	if(!g_gamestarted)
	{
		//console_print(id, "%L", id, "CMD_GAMENOTSTARTED")
		if (!native_is_user_infected(target)) {
			native_preinfect_user(target, true)
		}
		//client_print(id, print_chat, "%L", LANG_PLAYER, "INFECT_YOU")
		return PLUGIN_HANDLED_MAIN
	}

	new name2[32]
	get_user_name(target, name2, 31)

	console_print(id, "%L", id, "CMD_INFECTED", name2)
	infect_user(target, 0)

	new authid[32], authid2[32], name[32], userid2

	get_user_authid(id, authid, 31)
	get_user_authid(target, authid2, 31)
	get_user_name(id, name, 31)
	userid2 = get_user_userid(target)
	log_amx("^"%s<%d><%s><>^" make zombie ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)
	show_activity_key("ZOMBI1", "ZOMBI2", name, name2)

	return PLUGIN_HANDLED_MAIN
}

public cmd_infect(id, target)
{

	if(!is_user_connected(target) || !is_user_alive(target) || g_zombie[target] && native_game_started())
		return PLUGIN_HANDLED_MAIN

	/*if(!allow_infection())
	{
		console_print(id, "%L", id, "CMD_MAXZOMBIES")
		return PLUGIN_HANDLED_MAIN
	}*/

	if(!g_gamestarted)
	{
		//console_print(id, "%L", id, "CMD_GAMENOTSTARTED")
		//if (!native_is_user_infected(target)) {
		native_preinfect_user(target, true)
		//}
		//client_print(id, print_chat, "%L", LANG_PLAYER, "INFECT_YOU")
		return PLUGIN_HANDLED_MAIN
	}

	new name2[32]
	get_user_name(target, name2, 31)

	console_print(id, "%L", id, "CMD_INFECTED", name2)
	infect_user(target, 0)

	new authid[32], authid2[32], name[32], userid2

	get_user_authid(id, authid, 31)
	get_user_authid(target, authid2, 31)
	get_user_name(id, name, 31)
	userid2 = get_user_userid(target)
	log_amx("^"%s<%d><%s><>^" make zombie ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)
	show_activity_key("ZOMBI1", "ZOMBI2", name, name2)

	return PLUGIN_HANDLED_MAIN
}

public cmd_human(id,target)
{

	if(!is_user_connected(target) || !is_user_alive(target) || !g_zombie[target] && native_game_started())
		return PLUGIN_HANDLED_MAIN

	if (!native_game_started()) {
		//if (native_is_user_infected(target)) {
		native_preinfect_user(target, false)
		//}
		//client_print(id, print_chat, "%L", LANG_PLAYER, "INFECT_YOU")
		return PLUGIN_HANDLED_MAIN
	}

	fm_set_user_team(target, CS_TEAM_CT)
	cure_user(target)
	flash_user(target,10,10,1,1,0,0,255,255)
	fm_set_user_footsteps(target,0)

	set_pev(target, pev_health, (is_user_vip(target) ? 150.0 : 100.0))
	native_set_start_weap(target)
	emit_sound( target, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
	//remove_user_nvg( target )
	new authid[32], authid2[32], name2[32], name[32], userid2

	get_user_authid(id, authid, 31)
	get_user_authid(target, authid2, 31)
	get_user_name(target, name2, 31)
	get_user_name(id, name, 31)
	userid2 = get_user_userid(target)
	console_print(id, "%L", id, "CMD_HUMAN", name2)
	log_amx("^"%s<%d><%s><>^" make human ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)
	show_activity_key("HUMAN1", "HUMAN2", name, name2)
	reset_fire(id)

	return PLUGIN_HANDLED
}

#if defined TERMINATOR
public cmd_terminator(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static target, arg1[32]
	read_argv(1, arg1, 31)
	target = cmd_target(id, arg1, (CMDTARGET_ALLOW_SELF))

	if(!is_user_connected(target) || g_zombie[target])
		return PLUGIN_HANDLED_MAIN

	Terminator[target] = !(Terminator[target])

	if (Terminator[target])
		cs_set_user_model(target,"terminator")
	else
		cs_reset_user_model(target)

	return PLUGIN_HANDLED
}
#endif

public cmd_humanuser(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static target, arg1[32]
	read_argv(1, arg1, 31)
	target = cmd_target(id, arg1, (CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE))

	if(!is_user_connected(target))
		return PLUGIN_HANDLED_MAIN

	if (!native_game_started()) {
		if (native_is_user_infected(target)) {
			native_preinfect_user(target, false)
		}
		//client_print(id, print_chat, "%L", LANG_PLAYER, "INFECT_YOU")
		return PLUGIN_HANDLED_MAIN
	}
	/*
	if(!game_started())
	{
		console_print(id, "%L", id, "CMD_GAMENOTSTARTED")
		return PLUGIN_HANDLED_MAIN
	}*/
	if (!native_is_user_zombie(target))
	{
		//console_print(id, "%L", id, "%L", LANG_PLAYER, "CMD_NOTZOMBIE")
		return PLUGIN_HANDLED_MAIN
	}

	fm_set_user_team(target, CS_TEAM_CT)
	cure_user(target)
	flash_user(target,10,10,1,1,0,0,255,255)
	fm_set_user_footsteps(target,0)

	set_pev(target, pev_health, (is_user_vip(target) ? 150.0 : 100.0))
	native_set_start_weap(target)
	emit_sound( target, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
	//remove_user_nvg( target )
	reset_fire(target)

	new authid[32], authid2[32], name2[32], name[32], userid2

	get_user_authid(id, authid, 31)
	get_user_authid(target, authid2, 31)
	get_user_name(target, name2, 31)
	get_user_name(id, name, 31)
	userid2 = get_user_userid(target)
	console_print(id, "%L", id, "CMD_HUMAN", name2)
	log_amx("^"%s<%d><%s><>^" make human ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)
	show_activity_key("HUMAN1", "HUMAN2", name, name2)

	return PLUGIN_HANDLED
}

public buy_zombie(id)
{
	new cost = get_pcvar_num(BuyZombieCost)
	new money = cs_get_user_money_ul(id)

	if ( money < cost )
	{
		client_print(id, print_chat, "%L", LANG_PLAYER, "BUY_ZOMBIE", cost)
		return PLUGIN_CONTINUE
	}

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", LANG_PLAYER, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	if (maxhumans()) //|| !maxhumans()
	{
		//console_print(id, "%L", id, "CMD_NOTZOMBIE")
		client_print(id, print_chat, "%L", LANG_PLAYER, "LAST_HUMAN")
		return PLUGIN_HANDLED_MAIN
	}

	if (native_game_started()) {
		if (!native_is_user_zombie(id)) {
			native_infect_user(id, 0)
			cs_set_user_money_ul(id, money - cost)
		}
		client_print(id, print_chat, "%L", LANG_PLAYER, "INFECT_YOU")
		//return PLUGIN_CONTINUE
	} else {
		if (!native_is_user_infected(id)) {
			native_preinfect_user(id, true)
			cs_set_user_money_ul(id, money - cost)
		}
		client_print(id, print_chat, "%L", LANG_PLAYER, "INFECT_YOU")
		//return PLUGIN_CONTINUE
	}

	return PLUGIN_HANDLED

}

public human_cmd(id)
{
	new cost = get_pcvar_num(BuyHumanCost)
	new money = cs_get_user_money_ul(id)

	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "%L", LANG_PLAYER, "USER_NOTLIFE")
		return PLUGIN_HANDLED
	}

	if ( money < cost )
	{
		client_print(id, print_chat, "%L", LANG_PLAYER, "HUMAN_BUY", cost)
		return PLUGIN_HANDLED
	}

	if(!native_game_started())
	{
		//console_print(id, "%L", id, "CMD_GAMENOTSTARTED")
		client_print(id, print_chat, "%L", LANG_PLAYER, "GMS_A")
		return PLUGIN_HANDLED_MAIN
	}
	if (!native_is_user_zombie(id)) //|| !maxhumans()
	{
		//console_print(id, "%L", id, "CMD_NOTZOMBIE")
		client_print(id, print_chat, "%L", LANG_PLAYER, "NO_INFECT_YOU")
		return PLUGIN_HANDLED_MAIN
	}

	if (maxzombies()) //|| !maxhumans()
	{
		//console_print(id, "%L", id, "CMD_NOTZOMBIE")
		client_print(id, print_chat, "%L", LANG_PLAYER, "LAST_ZOMBIE")
		return PLUGIN_HANDLED_MAIN
	}

	cs_set_user_money_ul(id, money - cost)
	fm_set_user_team(id, CS_TEAM_CT, 1)
	cure_user(id)
	emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
	flash_user(id,10,10,1,1,0,0,255,255)
	//fm_set_user_footsteps(id)
	fm_set_user_footsteps(id,0)
	set_pev(id, pev_health, (is_user_vip(id) ? 150.0 : 100.0))
	native_set_start_weap(id)
	//remove_user_nvg( id )
	client_print(id, print_chat, "%L",LANG_PLAYER,"USE_ANTIVIRUS")
	reset_fire(id)

	return PLUGIN_HANDLED
}

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

public msg_teaminfo(msgid, dest, id)
{
	if(!g_gamestarted)
		return PLUGIN_CONTINUE

	static team[2]
	get_msg_arg_string(2, team, 1)

	if(team[0] != 'U')
		return PLUGIN_CONTINUE

	id = get_msg_arg_int(1)
	if(is_user_alive(id) || !g_disconnected[id])
		return PLUGIN_CONTINUE

	g_disconnected[id] = false
	id = randomly_pick_zombie()
	if(id)
	{
		fm_set_user_team(id, g_zombie[id] ? CS_TEAM_CT : CS_TEAM_T, 0)
		set_pev(id, pev_deadflag, DEAD_RESPAWNABLE)
	}
	return PLUGIN_CONTINUE
}

public msg_screenfade(msgid, dest, id)
{

	if (!is_user_connected(id))
		return PLUGIN_CONTINUE

	if(!get_pcvar_num(cvar_flashbang))
		return PLUGIN_CONTINUE

	if(!g_zombie[id] || get_user_godmode(id) || !is_user_alive(id) || g_zombie[id] && (get_class_id("FlashLeaper") == native_get_user_class(id) || get_class_id("Nurse") == native_get_user_class(id)))
	{
		static data[4]
		data[0] = get_msg_arg_int(4)
		data[1] = get_msg_arg_int(5)
		data[2] = get_msg_arg_int(6)
		data[3] = get_msg_arg_int(7)

		if(data[0] == 255 && data[1] == 255 && data[2] == 255 && data[3] > 199)
			return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public msg_scoreattrib(msgid, dest, id)
{
	static attrib
	attrib = get_msg_arg_int(2)

	if(attrib == ATTRIB_BOMB)
		set_msg_arg_int(2, ARG_BYTE, 0)
}

public msg_statusicon(msgid, dest, id)
{
	static icon[3]
	get_msg_arg_string(2, icon, 2)

	return (icon[0] == 'c' && icon[1] == '4') ? PLUGIN_HANDLED : PLUGIN_CONTINUE
}

public msg_weaponpickup(msgid, dest, id)
	return g_zombie[id] ? PLUGIN_HANDLED : PLUGIN_CONTINUE

public msg_ammopickup(msgid, dest, id)
	return g_zombie[id] ? PLUGIN_HANDLED : PLUGIN_CONTINUE

public msg_deathmsg(msgid, dest, id)
{

	static killer
	killer = get_msg_arg_int(1)

	if(is_user_connected(killer) && g_zombie[killer])
		set_msg_arg_string(4, g_zombie_weapname)

}

public death_event() {

	remove_user_model2(g_modelent2[read_data(2)])
	//fm_set_entity_visibility(g_modelent2[read_data(2)], 0)
	//if (g_zombie[read_data(2)])
	//	fm_set_entity_visibility(g_modelent[read_data(2)], 1)
	has_cloak[read_data(2)] = false
	has_cloak_act[read_data(2)] = 0
	//g_vipammo[read_data(2)] = false

	message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, read_data(2))
	write_byte(0)
	write_string("stopwatch")
	write_byte(0)
	write_byte(0)
	write_byte(0)
	message_end()

	g_nvisionenabled[read_data(2)] = false
	if (task_exists(read_data(2)+TASK_NVISION))
		remove_task(read_data(2)+TASK_NVISION)
	if (task_exists(read_data(2)+TASKID_STUCK))
		remove_task(read_data(2)+TASKID_STUCK)
	set_pev( read_data(2) , pev_flags , pev( read_data(2) , pev_flags ) & ~FL_FROZEN );
}

public msg_sendaudio(msgid, dest, id)
{
	if(!get_pcvar_num(cvar_winsounds))
		return PLUGIN_CONTINUE

	static audiocode [22]
	get_msg_arg_string(2, audiocode, 21)

	if(equal(audiocode[7], "terwin"))
		set_msg_arg_string(2, g_zombie_win_sounds[_random(sizeof g_zombie_win_sounds)])
	else if(equal(audiocode[7], "ctwin"))
		set_msg_arg_string(2, g_survivor_win_sounds[_random(sizeof g_survivor_win_sounds)])

	return PLUGIN_CONTINUE
}

public msg_health(msgid, dest, id)
{
	if(!get_pcvar_num(cvar_caphealthdisplay))
		return PLUGIN_CONTINUE

	static health
	health = get_msg_arg_int(1)

	if(health > 255)
		set_msg_arg_int(1, ARG_BYTE, 255)

	return PLUGIN_CONTINUE
}

public msg_armor(msgid, dest, id)
{
	if(!get_pcvar_num(cvar_caphealthdisplay))
		return PLUGIN_CONTINUE

	static armor
	armor = get_msg_arg_int(1)

	if(armor > 999)
		set_msg_arg_int(1, ARG_BYTE, 999)

	return PLUGIN_CONTINUE
}

public msg_textmsg(msgid, dest, id)
{
	if(get_msg_arg_int(1) != 4)
		return PLUGIN_CONTINUE

	static txtmsg[25], winmsg[32]
	get_msg_arg_string(2, txtmsg, 24)

	if(equal(txtmsg[1], "Game_bomb_drop"))
		return PLUGIN_HANDLED

	else if(equal(txtmsg[1], "Terrorists_Win"))
	{
		formatex(winmsg, 31, "%L", LANG_PLAYER, "WIN_TXT_ZOMBIES")
		set_msg_arg_string(2, winmsg)
		for (new i=0;i<=33;i++) {
			if (is_user_connected(i)) {
				if (get_user_team(i) != CS_TEAM_SPECTATOR)
					cs_set_user_money_ul(i,cs_get_user_money_ul(i)+1000)
			}
		}
	}
	else if(equal(txtmsg[1], "Target_Saved") || equal(txtmsg[1], "CTs_Win"))
	{
		formatex(winmsg, 31, "%L", LANG_PLAYER, "WIN_TXT_SURVIVORS")
		set_msg_arg_string(2, winmsg)
		for (new i=0;i<=33;i++) {
			if (is_user_connected(i)) {
				if (get_user_team(i) != CS_TEAM_SPECTATOR)
					cs_set_user_money_ul(i,cs_get_user_money_ul(i)+1000)
			}
		}
	}
	return PLUGIN_CONTINUE
}

public msg_clcorpse(msgid, dest, id)
{
	id = get_msg_arg_int(12)
	if(!g_zombie[id])
		return PLUGIN_CONTINUE

	static ent
	ent = fm_find_ent_by_owner(-1, MODEL_CLASSNAME, id)

	if(ent)
	{
		static model[64]
		pev(ent, pev_model, model, 63)

		set_msg_arg_string(1, model)
	}
	return PLUGIN_CONTINUE
}

public logevent_round_start()
{
	g_roundended = false
	//g_roundstarted = true
    /*
	if(get_pcvar_num(cvar_weaponsmenu))
	{
		static id, team
		for(id = 1; id <= g_maxplayers; id++) if(is_user_alive(id))
		{
			team = fm_get_user_team(id)
			if(team == CS_TEAM_T || team == CS_TEAM_CT)
			{
				if(is_user_bot(id))
					bot_weapons(id)
				else
				{
					if(g_showmenu[id])
					{
						add_delay(id, "display_equipmenu")

						g_menufailsafe[id] = true
						set_task(10.0, "task_weaponsmenu", TASKID_WEAPONSMENU + id)
					}
					else
						equipweapon(id, EQUIP_ALL)
				}
			}
		}
	}*/
}

public newSpawn(id)
{

	if(get_pcvar_num(cvar_weaponsmenu))
	{
		//for(id = 1; id <= g_maxplayers; id++)
		if(is_user_alive(id))
		{
				msg_shadowidx(id,SHADOW_CREATE)
			//if(team == CS_TEAM_T || team == CS_TEAM_CT)
			//{
				if(is_user_bot(id))
					bot_weapons(id)
				else
				{
					if(g_showmenu[id])
					{
						add_delay(id, "display_equipmenu")

						g_menufailsafe[id] = true
						set_task(10.0, "task_weaponsmenu", TASKID_WEAPONSMENU + id)
					}
					else
						equipweapon(id, EQUIP_ALL)
				}
			//}
		}
	}
}

public logevent_round_end()
{
	g_gamestarted = false
	//g_roundstarted = false
	g_roundended = true

	remove_task(TASKID_BALANCETEAM)
	remove_task(TASKID_INITROUND)
	remove_task(TASKID_STARTROUND)

	set_task(0.1, "task_balanceteam", TASKID_BALANCETEAM)
}

public event_textmsg()
{
	g_gamestarted = false
	//g_roundstarted = false
	g_roundended = true

	static seconds[5]
	read_data(3, seconds, 4)

	static Float:tasktime
	tasktime = float(str_to_num(seconds)) - 0.5

	remove_task(TASKID_BALANCETEAM)

	set_task(tasktime, "task_balanceteam", TASKID_BALANCETEAM)
}

public event_newround()
{
	g_gamestarted = false

	static buytime
	buytime = get_pcvar_num(cvar_buytime)

	if(buytime)
		g_buytime = buytime + get_gametime()

	static id
	for(id = 0; id <= g_maxplayers; id++)
	{
		if(is_user_connected(id)) {
			g_blockmodel[id] = true
			has_scan[id] = false
			has_cloak_act[id] = 0
			//has_cloak[id] = false
			if (is_user_alive(id))
				remove_task(id+TASK_NVISION)
			remove_task(id+TASKID_STUCK)
		}
	}

	remove_task(TASKID_NEWROUND)
	remove_task(TASKID_INITROUND)
	remove_task(TASKID_STARTROUND)

	set_task(0.1, "task_newround", TASKID_NEWROUND)
	set_task(get_pcvar_float(cvar_starttime), "task_initround", TASKID_INITROUND)
}

public task_respawn(id) {
	ExecuteHamB(Ham_CS_RoundRespawn, id);
	reset_user_model(id)
}
/*
//get weapon id
stock get_weapon_ent(id,wpnid=0,wpnName[]="")
{
        // who knows what wpnName will be
        static newName[24];

        // need to find the name
        if(wpnid) get_weaponname(wpnid,newName,23);

        // go with what we were told
        else formatex(newName,23,"%s",wpnName);

        // prefix it if we need to
        if(!equal(newName,"weapon_",7))
                format(newName,23,"weapon_%s",newName);

        return fm_find_ent_by_owner(get_maxplayers(),newName,id);
}     */

public event_curweapon(id)
{
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE

	/*if (is_user_alive(id) && g_frozen[id])
	{
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0}) // stop motion
		set_pev(id, pev_maxspeed, 1.0) // prevent from moving
		//return PLUGIN_CONTINUE; // shouldn't leap while frozen
	}*/

	static weapon
	weapon = read_data(2)
    /*
	if (has_cloak_act[id]) {
		new weapond = get_user_weapon(id)
		new weapon_ent = get_weapon_ent(id,weapond)
		set_pev(weapon_ent, pev_renderfx, kRenderFxNone)
		set_pev(weapon_ent, pev_rendercolor, {0.0,0.0,0.0})
		set_pev(weapon_ent, pev_rendermode, kRenderTransAlpha)
		set_pev(weapon_ent, pev_renderamt, 12.0)
	}*/

	//remove_task(id)

	/*new weap[32],ent
	get_weaponname(weapon,weap,31)
	ent = fm_find_ent_by_owner(-1,weap,id)
	if(ent)
	{
		set_pdata_float( ent, 46, 0.05, 4 );
		set_pdata_float( ent, 47, 0.05, 4 );
	}

	set_task(0.1,"task_weapon",id)
*/
	if (Terminator[id] && !g_zombie[id] && weapon != CSW_KNIFE && !task_exists(TASKID_STRIPNGIVE + id))
		set_task(0.1, "task_stripngive", TASKID_STRIPNGIVE + id)

	if(g_zombie[id])
	{
		if(weapon != CSW_KNIFE && (weapon != CSW_FLASHBANG || weapon == CSW_FLASHBANG && !has_snark(id)) && !task_exists(TASKID_STRIPNGIVE + id))
			set_task(0.1, "task_stripngive", TASKID_STRIPNGIVE + id)

		if(weapon == CSW_FLASHBANG && has_snark(id)) {
			set_pev(id, pev_viewmodel2, "models/v_alt_squeak_gflip.mdl")
			fm_set_entity_visibility(g_modelent2[id], 1)
		} else {
			fm_set_entity_visibility(g_modelent2[id], 0)
		}

		if(weapon == CSW_KNIFE) {
			set_pev(id, pev_weaponmodel2, "")
			set_pev(id, pev_viewmodel2, g_class_wmodel[g_player_class[id]])
			set_pev(id, pev_maxspeed, g_class_data[g_player_class[id]][DATA_SPEED])
		}

		return PLUGIN_CONTINUE
	}

	//if (weapon == CSW_M4A1) {
    /*
	new clip2; clip2 = read_data(3)
	if(clip2 > 1) {
		new weaponname[32]
		get_weaponname(weapon, weaponname, 31)

		new ent
		ent = fm_find_ent_by_owner(-1, weaponname, id)
		fm_set_weapon_ammo(ent, 2)
	} else if(clip2 < 1) {
		new weaponname[32]
		get_weaponname(weapon, weaponname, 31)

		new ent
		ent = fm_find_ent_by_owner(-1, weaponname, id)
		fm_set_weapon_ammo(ent, 2)
	}*/
	//set_pdata_float( id, 83, 0.05 );
	//}

	/*if (has_snark(id)!=0 && !g_zombie[id]) {
	 	reset_snark(id)
	}*/

	static ammotype
	ammotype = get_pcvar_num(cvar_ammo)

	if(!ammotype || (AMMOWP_NULL & (1<<weapon)))
		return PLUGIN_CONTINUE

	static maxammo//, vipammo
	switch(ammotype)
	{
		case 1: maxammo = g_weapon_ammo[weapon][MAX_AMMO]
		case 2: maxammo = g_weapon_ammo[weapon][MAX_CLIP]
	}
	//vipammo = g_weapon_ammo[weapon][MAX_CLIP];

	if(!maxammo)
		return PLUGIN_CONTINUE

	switch(ammotype)
	{
		case 1:
		{
			/*static ammo
			ammo = fm_get_user_bpammo(id, weapon)

			static weaponname[32]
			get_weaponname(weapon, weaponname, 31)

			static ent
			ent = fm_find_ent_by_owner(-1, weaponname, id)
            */
			//if(fm_get_weapon_ammo(ent) == 0)
				fm_set_user_bpammo(id, weapon, maxammo)
				/*if (is_user_vip(id) && vipammo) {
					static clip; clip = read_data(3)
					if(clip < 1) {
						g_vipammo[id] = false;
					} else if(clip >= floatround(vipammo*1.5) || clip == vipammo && !g_vipammo[id]) {

						static weaponname[32]
						get_weaponname(weapon, weaponname, 31)

						static ent
						ent = fm_find_ent_by_owner(-1, weaponname, id)

						cs_set_weapon_ammo(ent, floatround(vipammo*1.5))
						g_vipammo[id] = true;
					}
				}*/
		}
		case 2:
		{
			static clip; clip = read_data(3)
			if(clip < 1)
			{
				static weaponname[32]
				get_weaponname(weapon, weaponname, 31)

				static ent
				ent = fm_find_ent_by_owner(-1, weaponname, id)

				fm_set_weapon_ammo(ent, maxammo)
			}
		}
	}
	return PLUGIN_CONTINUE
}
/*
public task_weapon(id) {

	if(!is_user_alive(id)) {
		remove_task(id)
		return PLUGIN_CONTINUE
	}

	set_pdata_float( id, 83, 0.05 );

	set_task(0.1,"task_weapon",id)

	return PLUGIN_CONTINUE
}*/

public event_armortype(id)
{
	if(!is_user_alive(id) || !g_zombie[id])
		return PLUGIN_CONTINUE

	if(fm_get_user_armortype(id) != CS_ARMOR_NONE)
		fm_set_user_armortype(id, CS_ARMOR_NONE)

	return PLUGIN_CONTINUE
}

public event_damage(victim)
{
	if(!is_user_alive(victim) || !g_gamestarted /*|| g_frozen[victim]*/)
		return PLUGIN_CONTINUE

	if(g_zombie[victim])
	{
		static Float:gametime
		gametime = get_gametime()

		g_regendelay[victim] = gametime + g_class_data[g_player_class[victim]][DATA_HITREGENDLY]
		g_hitdelay[victim] = gametime + g_class_data[g_player_class[victim]][DATA_HITDELAY]
	}
	else
	{
		static attacker
		attacker = get_user_attacker(victim)

		if(!is_user_alive(attacker) || !g_zombie[attacker] || g_infecting || Terminator[victim])
			return PLUGIN_CONTINUE

		static Float:armor
		pev(victim, pev_armorvalue, armor)

		if(g_victim[attacker] == victim && (!get_pcvar_num(cvar_obeyarmor) || armor == 0.0))
		{
			g_infecting = true
			g_victim[attacker] = 0

			message_begin(MSG_ALL, g_msg_deathmsg)
			write_byte(attacker)
			write_byte(victim)
			write_byte(0)
			write_string(g_infection_name)
			message_end()

			message_begin(MSG_ALL, g_msg_scoreattrib)
			write_byte(victim)
			write_byte(0)
			message_end()

			infect_user(victim, attacker)

			static Float:frags, deaths
			pev(attacker, pev_frags, frags)
			deaths = fm_get_user_deaths(victim)

			set_pev(attacker, pev_frags, frags  + 1.0)
			fm_set_user_deaths(victim, deaths + 1)

			fm_set_user_money(attacker, get_pcvar_num(cvar_infectmoney))

			static params[2]
			params[0] = attacker
			params[1] = victim

			set_task(0.3, "task_updatescore", TASKID_UPDATESCR, params, 2)
		}
		g_infecting = false
	}
	return PLUGIN_CONTINUE
}

const ButtonBits = ( IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT );
//const ButtonBits2 = ( IN_DUCK | IN_RUN );

stock is_predator(id) {
	if (g_zombie[id] && (get_class_id("StrongPredator") == native_get_user_class(id) || get_class_id("RegenPredator") == native_get_user_class(id) || get_class_id("Predator") == native_get_user_class(id)))
		return true;
	return false;
}

stock is_noburn(id) {
	if (g_zombie[id] && (get_class_id("FireLeaper") == native_get_user_class(id) || get_class_id("Diablo") == native_get_user_class(id) || get_class_id("Nurse") == native_get_user_class(id)))
		return true;
	return false;
}

public fwd_player_prethink(id)
{

	/*if (is_user_alive(id) && g_frozen[id])
	{
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0}) // stop motion
		set_pev(id, pev_maxspeed, 1.0) // prevent from moving
		return FMRES_IGNORED; // shouldn't leap while frozen
	}*/

	if(!is_user_alive(id))
		return FMRES_IGNORED

	new buttons = pev(id, pev_button);
	new Float:fVelocity[ 3 ];
	pev( id , pev_velocity , fVelocity );
	const Float:SlowestRun = 170.0;
	const Float:SlowestRun2 = 30.0;
	new inv_alpha = 18

	if (g_gamestarted) {
		new cloak_activate = 0;
		if ( has_cloak_act[id]!=-1 && has_cloak[id] && (is_predator(id) && vector_length( fVelocity ) < SlowestRun || vector_length( fVelocity ) < SlowestRun2) && !(buttons&IN_ATTACK) && !(buttons&IN_ATTACK2) ) {
			cloak_activate = 2
			if (is_predator(id))
				inv_alpha = 12
			else
				inv_alpha = 18
		} else if ( has_cloak_act[id]!=-1 && has_cloak[id] && (is_predator(id) || vector_length( fVelocity ) < SlowestRun && !(buttons&IN_ATTACK) && !(buttons&IN_ATTACK2)) ) {
			cloak_activate = 1
			if (is_predator(id))
				inv_alpha = 48
			else
				inv_alpha = 36
		} else {
			cloak_activate = -1
		}
		if (cloak_activate>0) {
			if (cloak_activate==2 && has_cloak_act[id]!=2) {
				message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, id)
				write_byte(1)
				write_string("stopwatch")
				write_byte(255)
				write_byte(201)
				write_byte(14)
				message_end()
				has_cloak_act[id] = 2
			} else if (cloak_activate==1 && has_cloak_act[id]!=1) {
				message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, id)
				write_byte(1)
				write_string("stopwatch")
				write_byte(255)
				write_byte(64)
				write_byte(0)
				message_end()
				has_cloak_act[id] = 1
			}
			if (!g_zombie[id]) {
				set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, inv_alpha );
				fm_set_entity_visibility(g_modelent[id], 0);
			} else if (g_zombie[id]) {
				fm_set_entity_visibility(g_modelent[id], 1);
				set_rendering( g_modelent[id], kRenderFxNone, 0, 0, 0, kRenderTransAlpha, inv_alpha );
				set_pev(id, pev_body, 0)
				set_pev(id, pev_armorvalue, 0.0)
				set_pev(id, pev_renderamt, 0.0)
				set_pev(id, pev_rendermode, kRenderTransTexture)
			}
			msg_shadowidx(id,SHADOW_REMOVE)
			#if defined SANTAHAT
				if (pev_valid( g_bwEnt[id] )) set_rendering( g_bwEnt[id], kRenderFxNone, 0, 0, 0, kRenderTransAlpha, inv_alpha );
			#endif
			if (pev_valid( g_modelent2[id] )) set_rendering( g_modelent2[id], kRenderFxNone, 0, 0, 0, kRenderTransAlpha, inv_alpha );
			if (is_predator(id) && pev_valid( para_ent(id) )) set_rendering(  para_ent(id), kRenderFxNone, 0, 0, 0, kRenderTransAlpha, inv_alpha );
		} else if (cloak_activate==-1 && (has_cloak_act[id]>0||has_cloak_act[id]<0)) { /*&& (vector_length( fVelocity ) >= SlowestRun || buttons&IN_ATTACK )*/ //( !(buttons&IN_DUCK) && !(buttons&IN_RUN) && buttons&ButtonBits || buttons&IN_ATTACK ) ) {
			message_begin(MSG_ONE_UNRELIABLE, g_IconStatus, {0,0,0}, id)
			write_byte(0)
			write_string("stopwatch")
			write_byte(0)
			write_byte(0)
			write_byte(0)
			message_end()
			if (!g_zombie[id]) {
				set_user_rendering( id );
				fm_set_entity_visibility(g_modelent[id], 0);
			} else {
				fm_set_entity_visibility(g_modelent[id], 1);
				set_rendering( g_modelent[id] );
				set_pev(id, pev_body, 0)
				set_pev(id, pev_armorvalue, 0.0)
				set_pev(id, pev_renderamt, 0.0)
				set_pev(id, pev_rendermode, kRenderTransTexture)
			}
			#if defined SANTAHAT
				if (pev_valid( g_bwEnt[id] )) set_rendering( g_bwEnt[id] );
			#endif
			if (pev_valid( g_modelent2[id] )) set_rendering( g_modelent2[id] );
			if (is_predator(id) && pev_valid( para_ent(id) )) set_rendering(  para_ent(id) );
			if (has_cloak_act[id]!=-1)
				has_cloak_act[id] = 0
			msg_shadowidx(id,SHADOW_CREATE)
		}
	}

	if (g_silent[id])
		set_pev(id, pev_flTimeStepSound, 999);

	if(!is_user_alive(id) || !g_zombie[id])
		return FMRES_IGNORED

	static flags
	flags = pev(id, pev_flags)

	if(flags & FL_ONGROUND)
	{
		if(get_pcvar_num(cvar_painshockfree))
		{
			pev(id, pev_velocity, g_vecvel)
			g_brestorevel = true
		}
	}
	else
	{
		static Float:fallvelocity
		pev(id, pev_flFallVelocity, fallvelocity)

		g_falling[id] = fallvelocity >= 350.0 ? true : false
	}

	if(g_gamestarted)
	{
		static Float:gametime
		gametime = get_gametime()

		static pclass
		pclass = g_player_class[id]

		static Float:health
		pev(id, pev_health, health)

		if(noregen(id) < gametime && health < g_class_data[pclass][DATA_HEALTH] && g_regendelay[id] < gametime)
		{
			set_pev(id, pev_health, health + 1.0)
			g_regendelay[id] = gametime + g_class_data[pclass][DATA_REGENDLY]
		}
	}

	return FMRES_IGNORED
}

stock msg_shadowidx(id, ShadowIdX:long)
{
	if ((cl_removed_shadow[id] && long == SHADOW_REMOVE) || (!cl_removed_shadow[id] && long == SHADOW_CREATE))
	{
		return
	}

	if (long == SHADOW_REMOVE)
		cl_removed_shadow[id] = true
	else
		cl_removed_shadow[id] = false

	message_begin(MSG_ONE, g_shadow, {0,0,0}, id)
	write_long(_:long)
	message_end()
}

public fwd_player_prethink_post(id)
{
	if(!g_brestorevel)
		return FMRES_IGNORED

	g_brestorevel = false

	static flag
	flag = pev(id, pev_flags)

	if(!(flag & FL_ONTRAIN))
	{
		static ent
		ent = pev(id, pev_groundentity)

		if(pev_valid(ent) && (flag & FL_CONVEYOR))
		{
			static Float:vectemp[3]
			pev(id, pev_basevelocity, vectemp)

			xs_vec_add(g_vecvel, vectemp, g_vecvel)
		}

		new Float:speed
		if (get_class_id("Hunter") == native_get_user_class(id)) {
			speed = 1.0
		} else {
			speed = g_class_data[g_player_class[id]][DATA_HITSPEED]
			if (drug_attack(id)!=1.0 && get_class_id("GonomeHulk") != native_get_user_class(id) && get_class_id("Hulk") != native_get_user_class(id) && get_class_id("FastHulk") != native_get_user_class(id) && get_class_id("SlowHulk") != native_get_user_class(id))
				speed = speed+0.1
			else if (drug_attack(id)!=1.0 && (get_class_id("GonomeHulk") == native_get_user_class(id) || get_class_id("Hulk") == native_get_user_class(id) || get_class_id("FastHulk") == native_get_user_class(id) || get_class_id("SlowHulk") == native_get_user_class(id)))
				speed = speed+0.25
		}

		if(g_hitdelay[id] > get_gametime() && (!(pev(id, pev_flags) & FL_DUCKING)))
			xs_vec_mul_scalar(g_vecvel, speed, g_vecvel)

		//set_pev(id, pev_velocity, g_vecvel)
		return FMRES_HANDLED
	}

	return FMRES_IGNORED
}

public fwd_player_postthink(id)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED

	if(get_pcvar_num(cvar_blockfall)==1 && g_zombie[id] && g_falling[id] && (pev(id, pev_flags) & FL_ONGROUND))
	{
		set_pev(id, pev_watertype, CONTENTS_WATER)
		g_falling[id] = false
	}

	if(get_pcvar_num(cvar_buytime))
	{
		if(pev_valid(g_buyzone) && g_buytime > get_gametime())
			dllfunc(DLLFunc_Touch, g_buyzone, id)
	}
	return FMRES_IGNORED
}

public fwd_emitsound(id, channel, sample[], Float:volume, Float:attn, flag, pitch)
{

	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;

	if(channel == CHAN_ITEM && sample[6] == 'n' && sample[7] == 'v' && sample[8] == 'g')
		return FMRES_SUPERCEDE

	if(!is_user_connected(id) || !g_zombie[id])
		return FMRES_IGNORED

	// Zombie being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
	{
		emit_sound(id, channel, g_zombie_pain[_random(sizeof g_zombie_pain)], volume, attn, flag, pitch)
		return FMRES_SUPERCEDE;
	}

	if(sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
		if(sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a')
		{
			emit_sound(id, channel, g_zombie_miss_sounds[_random(sizeof g_zombie_miss_sounds)], volume, attn, flag, pitch)
			return FMRES_SUPERCEDE
		}
		else if(sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't' || sample[14] == 's' && sample[15] == 't' && sample[16] == 'a')
		{
			if(sample[17] == 'w' && sample[18] == 'a' && sample[19] == 'l')
				emit_sound(id, channel, g_zombie_miss_sounds[_random(sizeof g_zombie_miss_sounds)], volume, attn, flag, pitch)
			else
				emit_sound(id, channel, g_zombie_hit_sounds[_random(sizeof g_zombie_hit_sounds)], volume, attn, flag, pitch)

			return FMRES_SUPERCEDE
		}
	}
	else if(sample[7] == 'd' && (sample[8] == 'i' && sample[9] == 'e' || sample[12] == '6'))
	{
		emit_sound(id, channel, g_zombie_die_sounds[_random(sizeof g_zombie_die_sounds)], volume, attn, flag, pitch)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public fwd_cmdstart(id, handle, seed)
{
	if(!is_user_alive(id) || !g_zombie[id])
		return FMRES_IGNORED

	static impulse
	impulse = get_uc(handle, UC_Impulse)

	if(impulse == IMPULSE_FLASHLIGHT)
	{
		set_uc(handle, UC_Impulse, 0)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public fwd_spawn(ent)
{
	if(!pev_valid(ent))
		return FMRES_IGNORED

	static classname[32]
	pev(ent, pev_classname, classname, 31)

	static i
	for(i = 0; i < sizeof g_remove_entities; ++i)
	{
		if(equal(classname, g_remove_entities[i]))
		{
			engfunc(EngFunc_RemoveEntity, ent)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public fwd_gamedescription()
{
	static gamename[32]
	get_pcvar_string(cvar_gamedescription, gamename, 31)

	forward_return(FMV_STRING, gamename)

	return FMRES_SUPERCEDE
}

public fwd_createnamedentity(entclassname)
{
	static classname[10]
	engfunc(EngFunc_SzFromIndex, entclassname, classname, 9)

	return (classname[7] == 'c' && classname[8] == '4') ? FMRES_SUPERCEDE : FMRES_IGNORED
}

public fwd_clientkill(id)
{
	if(get_pcvar_num(cvar_punishsuicide) && is_user_alive(id)) {
		//g_suicide[id] = true
		if (cs_get_user_money_ul(id)-get_pcvar_num(cvar_punishsuicide)>0)
			cs_set_user_money_ul(id,cs_get_user_money_ul(id)-get_pcvar_num(cvar_punishsuicide))
		else
			cs_set_user_money_ul(id,0)
	}
}

public fwd_setclientkeyvalue(id, infobuffer, const key[])
{
	if(!equal(key, "model") || !g_blockmodel[id])
		return FMRES_IGNORED

	static model[32]
	fm_get_user_model(id, model, 31)

	if(equal(model, "gordon"))
		return FMRES_IGNORED

	g_blockmodel[id] = false

	return FMRES_SUPERCEDE
}

public bacon_touch_weapon(ent, id)
	return (is_user_alive(id) && g_zombie[id]) ? HAM_SUPERCEDE : HAM_IGNORED

public bacon_use_tank(ent, caller, activator, use_type, Float:value)
	return (is_user_alive(caller) && g_zombie[caller]) ? HAM_SUPERCEDE : HAM_IGNORED

public bacon_use_pushable(ent, caller, activator, use_type, Float:value)
	return HAM_SUPERCEDE

public bacon_traceattack_player(victim, attacker, Float:damage, Float:direction[3], tracehandle, damagetype)
{
	if(!g_gamestarted/* || g_frozen[attacker] || g_frozen[victim]*/)
		return HAM_SUPERCEDE

	if(!get_pcvar_num(cvar_knockback) || !(damagetype & DMG_BULLET))
		return HAM_IGNORED

	if(!is_user_connected(attacker) || !g_zombie[victim])
		return HAM_IGNORED

	static kbpower
	kbpower = g_weapon_knockback[get_user_weapon(attacker)]

	if(kbpower != -1)
	{
		static flags
		flags = pev(victim, pev_flags)

		if(get_pcvar_num(cvar_knockback_duck) && ((flags & FL_DUCKING) && (flags & FL_ONGROUND)))
			return HAM_IGNORED

		static Float:origins[2][3]
		pev(victim, pev_origin, origins[0])
		pev(attacker, pev_origin, origins[1])

		if(get_distance_f(origins[0], origins[1]) <= get_pcvar_float(cvar_knockback_dist))
		{
			static Float:velocity[3]
			pev(victim, pev_velocity, velocity)

			static Float:tempvec
			tempvec = velocity[2]

			xs_vec_mul_scalar(direction, damage, direction)
			xs_vec_mul_scalar(direction, g_class_data[g_player_class[victim]][DATA_KNOCKBACK], direction)
			xs_vec_mul_scalar(direction, g_knockbackpower[kbpower], direction)

			xs_vec_add(direction, velocity, velocity)
			velocity[2] = tempvec

			set_pev(victim, pev_velocity, velocity)

			return HAM_HANDLED
		}
	}
	return HAM_IGNORED
}

public bacon_touch_grenade(ent, world)
{
	if(!get_pcvar_num(cvar_impactexplode) || !pev_valid(ent))
		return HAM_IGNORED

	static model[12]
	pev(ent, pev_model, model, 11)

	if(model[9] == 'h' && model[10] == 'e')
	{
		set_pev(ent, pev_dmgtime, 0.0)

		return HAM_HANDLED
	}
	return HAM_IGNORED
}

#define TASK_NORMSPEED 102345

public task_normal_speed(taskid) {
	set_pev(taskid-TASK_NORMSPEED, pev_maxspeed, g_class_data[g_player_class[taskid-TASK_NORMSPEED]][DATA_SPEED])
}

public remove_cloak_task(id)
	has_cloak_act[id-10245] = 0

public bacon_takedamage_player(victim, inflictor, attacker, Float:damage, damagetype)
{
	if(damagetype & DMG_GENERIC || victim == attacker || !is_user_alive(victim) || !is_user_connected(attacker))
		return HAM_IGNORED

	if(!g_gamestarted || (!g_zombie[victim] && !g_zombie[attacker]) || ((damagetype & DMG_HEGRENADE) && g_zombie[attacker]))
		return HAM_SUPERCEDE

	new id = victim

	if (has_cloak[victim] && (g_zombie[victim] && !g_zombie[attacker] || !g_zombie[victim] && g_zombie[attacker])) {
		has_cloak_act[id] = -1
		remove_task(id+10245)
		if (is_predator(victim))
			set_task(0.2,"remove_cloak_task",id+10245)
		else
			set_task(0.5,"remove_cloak_task",id+10245)
	}

/*	if (g_frozen[victim])
		return HAM_SUPERCEDE
*/
	if(!g_zombie[attacker])
	{
		static pclass
		pclass = g_player_class[victim]

		damage *= (damagetype & DMG_HEGRENADE) ? g_class_data[pclass][DATA_HEDEFENCE] : g_class_data[pclass][DATA_DEFENCE]

		if (has_eb(attacker))
			damage *= 1.4

		if (is_user_vip(attacker))
			damage *= 1.1

		if (get_user_weapon(attacker) == CSW_SG550 || get_user_weapon(attacker) == CSW_G3SG1)
			damage *= 0.35

		if (get_user_weapon(attacker) == CSW_SCOUT || get_user_weapon(attacker) == CSW_AWP)
			damage *= 1.6

		if (get_user_weapon(attacker) == CSW_KNIFE)
			damage *= 1.8

		if (get_user_weapon(attacker) == CSW_TMP)
			damage *= 1.3

		if (Terminator[attacker])
			damage *= 4.0

		damage *= drug_attack(attacker)

		SetHamParamFloat(4, damage)

		if (get_class_id("Hunter") == native_get_user_class(id) && g_zombie[id]) {

			set_pev(id, pev_maxspeed, g_class_data[g_player_class[id]][DATA_HITSPEED])
			remove_task(TASK_NORMSPEED+id)
			set_task(g_class_data[g_player_class[id]][DATA_HITDELAY], "task_normal_speed", TASK_NORMSPEED+id)

		}

	}
	else
	{
		if(get_user_weapon(attacker) != CSW_KNIFE || g_zombie[attacker] && g_zombie[victim])
			return HAM_SUPERCEDE

		damage *= g_class_data[g_player_class[attacker]][DATA_ATTACK]

		if (is_user_vip(attacker))
			damage *= 1.1

		damage *= drug_attack(attacker)

		//new armor
		//pev(victim, pev_armorvalue, armor)
		//armor = get_user_armor(victim)
		static Float:armor
		pev(victim, pev_armorvalue, armor)

		if(get_pcvar_num(cvar_obeyarmor) && armor > 0.0 || Terminator[victim])
		{
			/*
			static damage_str[32]
			float_to_str(damage,damage_str,31)
			armor -= str_to_num(damage_str)

			if(armor < 0)
				armor = 0

			set_pev(victim, pev_armorvalue, armor)
			//set_user_armor(victim,armor)
			emit_sound(victim, CHAN_BODY, sound_armorhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
			return HAM_SUPERCEDE;
			//SetHamParamFloat(4, 0.0)
			*/

			emit_sound(victim, CHAN_BODY, sound_armorhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
			if (!Terminator[victim]) {
				set_pev(victim, pev_armorvalue, floatmax(0.0, armor - damage))
				SetHamParamFloat(4, 0.0)
			} else {
				SetHamParamFloat(4, damage * 0.25)
			}
			//return HAM_SUPERCEDE;
		}
		else
		{
			static bool:infect
			infect = allow_infection()

			g_victim[attacker] = infect ? victim : 0

			if(!g_infecting)
				SetHamParamFloat(4, infect ? 0.0 : damage)
			else
				SetHamParamFloat(4, 0.0)
		}
	}

	if (g_zombie[attacker] && !g_zombie[victim]) {
		cs_set_user_money_ul(attacker, floatround(cs_get_user_money_ul(attacker) + damage/1.5))
	} else if (!g_zombie[attacker] && g_zombie[victim]) {
		cs_set_user_money_ul(attacker, floatround(cs_get_user_money_ul(attacker) + damage*1.5))
	}

	return HAM_HANDLED
}

public bacon_killed_player(victim, killer, shouldgib)
{
	if(!is_user_alive(killer) || g_zombie[killer])
		return HAM_IGNORED

	static killbonus
	killbonus = get_pcvar_num(cvar_killbonus)

	if(killbonus)
		set_pev(killer, pev_frags, pev(killer, pev_frags) + float(killbonus))

	static killreward
	killreward = get_pcvar_num(cvar_killreward)

	if(!killreward)
		return HAM_IGNORED

	static weapon, maxclip, ent, weaponname[32]
	switch(killreward)
	{
		case 1:
		{
			weapon = get_user_weapon(killer)
			maxclip = g_weapon_ammo[weapon][MAX_CLIP]
			if(maxclip)
			{
				get_weaponname(weapon, weaponname, 31)
				ent = fm_find_ent_by_owner(-1, weaponname, killer)

				fm_set_weapon_ammo(ent, maxclip)
			}
		}
		case 2:
		{
			//if(!user_has_weapon(killer, CSW_HEGRENADE))
				//bacon_give_weapon(killer, "weapon_hegrenade")
			if (user_has_weapon(killer,CSW_HEGRENADE)) {
				if (cs_get_user_bpammo(killer, CSW_HEGRENADE)<3) {
					cs_set_user_bpammo( killer, CSW_HEGRENADE, cs_get_user_bpammo(killer, CSW_HEGRENADE)+1 )
					message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "AmmoPickup" ), _, killer );
					write_byte( 12 );
					write_byte( 1 );
					message_end();
					emit_sound( killer, CHAN_ITEM, G_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
				}
			} else
				bacon_give_weapon(killer,"weapon_hegrenade")
		}
		case 3:
		{
			weapon = get_user_weapon(killer)
			maxclip = g_weapon_ammo[weapon][MAX_CLIP]
			if(maxclip)
			{
				get_weaponname(weapon, weaponname, 31)
				ent = fm_find_ent_by_owner(-1, weaponname, killer)

				fm_set_weapon_ammo(ent, maxclip)
			}

			if(!user_has_weapon(killer, CSW_HEGRENADE))
				bacon_give_weapon(killer, "weapon_hegrenade")
		}
	}
	return HAM_IGNORED
}

public bacon_spawn_player_post(id)
{
	if(!is_user_alive(id))
		return HAM_IGNORED

	if(g_zombie[id])
	{
		if(get_pcvar_num(cvar_respawnaszombie) && !g_roundended)
		{
			set_zombie_attibutes(id)

			return HAM_IGNORED
		}
		else
			cure_user(id)
	}
	//else if(pev(id, pev_rendermode) == kRenderTransTexture)
	reset_user_model(id)

	new pmodel[64]
	cs_get_user_model(id,pmodel,63)
	if (equali(pmodel,"sas"))
		cs_set_user_model(id,"claire")
	if (equali(pmodel,"guerilla"))
		cs_set_user_model(id,"lilith")
	#if defined TERMINATOR
	if (Terminator[id])
		cs_set_user_model(id,"terminator")
	#endif
	if (get_vip_options(id)&VIP_FLAG_M)
		cs_set_user_model(id,"vip")

  	if(get_pcvar_num(cvar_weaponsmenu))
        newSpawn(id)

	#if defined SANTAHAT
	new player = id;
	if (is_user_alive( player ) ) {
		new iEnt = g_bwEnt[ player ];
		if( !pev_valid( iEnt ) ) {
			iEnt = engfunc ( EngFunc_CreateNamedEntity, g_CachedStringInfoTarget );
			g_bwEnt[ player ] = iEnt;
			set_pev( iEnt, pev_movetype, MOVETYPE_FOLLOW );
			set_pev( iEnt, pev_aiment, player );
			engfunc( EngFunc_SetModel, iEnt, "models/santa_hat.mdl" );
		}
	}
	#endif

	set_task(0.3, "task_spawned", TASKID_SPAWNDELAY + id)
	set_task(5.0, "task_checkspawn", TASKID_CHECKSPAWN + id)

	return HAM_IGNORED
}

public bacon_touch_pushable(ent, id)
{
	static movetype
	pev(id, pev_movetype)

	if(movetype == MOVETYPE_NOCLIP || movetype == MOVETYPE_NONE)
		return HAM_IGNORED

	if(is_user_alive(id))
	{
		set_pev(id, pev_movetype, MOVETYPE_WALK)

		if(!(pev(id, pev_flags) & FL_ONGROUND))
			return HAM_SUPERCEDE
	}

	if(!get_pcvar_num(cvar_shootobjects))
		return HAM_IGNORED

	static Float:velocity[2][3]
	pev(ent, pev_velocity, velocity[0])

	if(vector_length(velocity[0]) > 0.0)
	{
		pev(id, pev_velocity, velocity[1])
		velocity[1][0] += velocity[0][0]
		velocity[1][1] += velocity[0][1]

		set_pev(id, pev_velocity, velocity[1])
	}
	return HAM_SUPERCEDE
}

public bacon_traceattack_pushable(ent, attacker, Float:damage, Float:direction[3], tracehandle, damagetype)
{
	if(!get_pcvar_num(cvar_shootobjects) || !is_user_alive(attacker))
		return HAM_IGNORED

	static Float:velocity[3]
	pev(ent, pev_velocity, velocity)

	static Float:tempvec
	tempvec = velocity[2]

	xs_vec_mul_scalar(direction, damage, direction)
	xs_vec_mul_scalar(direction, g_zombie[attacker] ?
	get_pcvar_float(cvar_pushpwr_zombie) : get_pcvar_float(cvar_pushpwr_weapon), direction)
	xs_vec_add(direction, velocity, velocity)
	velocity[2] = tempvec

	set_pev(ent, pev_velocity, velocity)

	return HAM_HANDLED
}

public task_spawned(taskid)
{
	static id
	id = taskid - TASKID_SPAWNDELAY

	if(is_user_alive(id))
	{
		if(g_welcomemsg[id])
		{
			g_welcomemsg[id] = false

			static message[192]
			formatex(message, 191, "%L", id, "WELCOME_TXT")
			replace(message, 191, "#Version#", VERSION)

			client_print(id, print_chat, message)
		}

		/*if(g_suicide[id])
		{
			g_suicide[id] = false

			user_silentkill(id)
			remove_task(TASKID_CHECKSPAWN + id)

			client_print(id, print_chat, "%L", id, "SUICIDEPUNISH_TXT")

			return
		}*/

		//if(get_pcvar_num(cvar_weaponsmenu) && g_roundstarted && g_showmenu[id])
		//	is_user_bot(id) ? bot_weapons(id) : display_equipmenu(id)

		new cost = (get_vip_flags(id) & VIP_FLAG_C ? get_pcvar_num(cvar_scan_cost)/2 : get_pcvar_num(cvar_scan_cost))
		if(!g_gamestarted)
			//client_print(id, print_chat, "%L %L", id, "SCAN_RESULTS", id, g_preinfect[id] ? "SCAN_INFECTED" : "SCAN_CLEAN")
			client_print(id, print_chat, "%L", id, "SCAN_ERROR", cost)
		else
		{
			static team
			team = fm_get_user_team(id)

			if(team == CS_TEAM_T)
				fm_set_user_team(id, CS_TEAM_CT)
		}
	}
}

public task_checkspawn(taskid)
{
	static id
	id = taskid - TASKID_CHECKSPAWN

	if(!is_user_connected(id) || is_user_alive(id) || g_roundended)
		return

	static team
	team = fm_get_user_team(id)

	if(team == CS_TEAM_T || team == CS_TEAM_CT)
		ExecuteHamB(Ham_CS_RoundRespawn, id)
}

public task_showtruehealth()
{
	//set_hudmessage(_, _, _, 0.03, 0.93, _, 0.01, 1.35)
	set_hudmessage(_, _, _, 0.03, 0.93, _, 0.2, 0.2)

	static id, /*Float:health,*/ class
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
	}
}

public task_lights()
{
	static light[2]
	get_pcvar_string(cvar_lights, light, 1)

	engfunc(EngFunc_LightStyle, 0, light)
}

public task_updatescore(params[])
{
	if(!g_gamestarted)
		return

	static attacker
	attacker = params[0]

	static victim
	victim = params[1]

	if(!is_user_connected(attacker))
		return

	static frags, deaths, team
	frags  = get_user_frags(attacker)
	deaths = fm_get_user_deaths(attacker)
	team   = get_user_team(attacker)

	message_begin(MSG_BROADCAST, g_msg_scoreinfo)
	write_byte(attacker)
	write_short(frags)
	write_short(deaths)
	write_short(0)
	write_short(team)
	message_end()

	if(!is_user_connected(victim))
		return

	frags  = get_user_frags(victim)
	deaths = fm_get_user_deaths(victim)
	team   = get_user_team(victim)

	message_begin(MSG_BROADCAST, g_msg_scoreinfo)
	write_byte(victim)
	write_short(frags)
	write_short(deaths)
	write_short(0)
	write_short(team)
	message_end()
}

public task_weaponsmenu(taskid)
{
	static id
	id = taskid - TASKID_WEAPONSMENU

	if(is_user_alive(id) && !g_zombie[id] && g_menufailsafe[id]) {
		display_equipmenu(id)
		set_task(10.0, "task_weaponsmenu2", TASKID_WEAPONSMENU + id)
	}


}

public task_weaponsmenu2(taskid)
{
	static id
	id = taskid - TASKID_WEAPONSMENU

	if(is_user_alive(id) && !g_zombie[id] && g_menufailsafe[id]) {
		display_equipmenu(id)
	}


}

public task_stripngive(taskid)
{
	static id
	id = taskid - TASKID_STRIPNGIVE

	if(is_user_alive(id))
	{
		fm_strip_user_weapons(id)
		fm_reset_user_primary(id)
		bacon_give_weapon(id, "weapon_knife")

		if (!Terminator[id]) {
			set_pev(id, pev_weaponmodel2, "")
			set_pev(id, pev_viewmodel2, g_class_wmodel[g_player_class[id]])
			set_pev(id, pev_maxspeed, g_class_data[g_player_class[id]][DATA_SPEED])
			if (has_snark(id))
				set_snark(id)
		}
	}
}

public task_newround()
{
	static players[32], num, zombies, i, id
	get_players(players, num, "a")

	if(num > 1)
	{
		for(i = 0; i < num; i++)
			g_preinfect[players[i]] = false

		zombies = clamp(floatround(num * get_pcvar_float(cvar_zombiemulti)), 1, 31)

		i = 0
		while(i < zombies)
		{
			id = players[_random(num)]
			if(!g_preinfect[id])
			{
				g_preinfect[id] = true
				i++
			}
		}
	}

	if(!get_pcvar_num(cvar_randomspawn) || g_spawncount <= 0)
		return

	static team
	for(i = 0; i < num; i++)
	{
		id = players[i]

		team = fm_get_user_team(id)
		if(team != CS_TEAM_T && team != CS_TEAM_CT || pev(id, pev_iuser1))
			continue

		static spawn_index
		spawn_index = _random(g_spawncount)

		static Float:spawndata[3]
		spawndata[0] = g_spawns[spawn_index][0]
		spawndata[1] = g_spawns[spawn_index][1]
		spawndata[2] = g_spawns[spawn_index][2]

		if(!fm_is_hull_vacant(spawndata, HULL_HUMAN))
		{
			static i
			for(i = spawn_index + 1; i != spawn_index; i++)
			{
				if(i >= g_spawncount) i = 0

				spawndata[0] = g_spawns[i][0]
				spawndata[1] = g_spawns[i][1]
				spawndata[2] = g_spawns[i][2]

				if(fm_is_hull_vacant(spawndata, HULL_HUMAN))
				{
					spawn_index = i
					break
				}
			}
		}

		spawndata[0] = g_spawns[spawn_index][0]
		spawndata[1] = g_spawns[spawn_index][1]
		spawndata[2] = g_spawns[spawn_index][2]
		engfunc(EngFunc_SetOrigin, id, spawndata)

		spawndata[0] = g_spawns[spawn_index][3]
		spawndata[1] = g_spawns[spawn_index][4]
		spawndata[2] = g_spawns[spawn_index][5]
		set_pev(id, pev_angles, spawndata)

		spawndata[0] = g_spawns[spawn_index][6]
		spawndata[1] = g_spawns[spawn_index][7]
		spawndata[2] = g_spawns[spawn_index][8]
		set_pev(id, pev_v_angle, spawndata)

		set_pev(id, pev_fixangle, 1)
	}
}

public task_initround()
{
	static zombiecount, newzombie
	zombiecount = 0
	newzombie = 0

	static players[32], num, i, id
	get_players(players, num, "a")

	for(i = 0; i < num; i++) if(g_preinfect[players[i]])
	{
		newzombie = players[i]
		zombiecount++
	}

	if(zombiecount > 1)
		newzombie = 0
	else if(zombiecount < 1)
		newzombie = players[_random(num)]

	for(i = 0; i < num; i++)
	{
		id = players[i]
		if(id == newzombie || g_preinfect[id]) {
			infect_user(id, 0)
			g_preinfect[id] = false
		} else
		{
			fm_set_user_team(id, CS_TEAM_CT, 0)
			add_delay(id, "update_team")
		}
	}

	set_hudmessage(_, _, _, _, _, 1)
	if(newzombie)
	{
		static name[32]
		get_user_name(newzombie, name, 31)

		ShowSyncHudMsg(0, g_sync_msgdisplay, "%L", LANG_PLAYER, "INFECTED_HUD", name)
		client_print(0, print_chat, "%L", LANG_PLAYER, "INFECTED_TXT", name)
	}
	else
	{
		ShowSyncHudMsg(0, g_sync_msgdisplay, "%L", LANG_PLAYER, "INFECTED_HUD2")
		client_print(0, print_chat, "%L", LANG_PLAYER, "INFECTED_TXT2")
	}

	set_task(0.51, "task_startround", TASKID_STARTROUND)
}

public task_startround()
{
	for(new id = 0; id < 33; id++) {
		if (is_user_connected(id) && is_user_alive(id) && g_preinfect[id]) {
			infect_user(id, 0)
			g_preinfect[id] = false
		}
	}

	g_gamestarted = true
	ExecuteForward(g_fwd_gamestart, g_fwd_result)
}

public task_balanceteam()
{
	static players[3][32], count[3]
	get_players(players[CS_TEAM_UNASSIGNED], count[CS_TEAM_UNASSIGNED])

	count[CS_TEAM_T] = 0
	count[CS_TEAM_CT] = 0

	static i, id, team
	for(i = 0; i < count[CS_TEAM_UNASSIGNED]; i++)
	{
		id = players[CS_TEAM_UNASSIGNED][i]
		team = fm_get_user_team(id)

		if(team == CS_TEAM_T || team == CS_TEAM_CT)
			players[team][count[team]++] = id
	}

	if(abs(count[CS_TEAM_T] - count[CS_TEAM_CT]) <= 1)
		return

	static maxplayers
	maxplayers = (count[CS_TEAM_T] + count[CS_TEAM_CT]) / 2

	if(count[CS_TEAM_T] > maxplayers)
	{
		for(i = 0; i < (count[CS_TEAM_T] - maxplayers); i++)
			fm_set_user_team(players[CS_TEAM_T][i], CS_TEAM_CT, 0)
	}
	else
	{
		for(i = 0; i < (count[CS_TEAM_CT] - maxplayers); i++)
			fm_set_user_team(players[CS_TEAM_CT][i], CS_TEAM_T, 0)
	}
}

public task_botclient_pdata(id)
{
	if(g_botclient_pdata || !is_user_connected(id))
		return

	if(get_pcvar_num(cvar_botquota) && is_user_bot(id))
	{
		RegisterHamFromEntity(Ham_TakeDamage, id, "bacon_takedamage_player")
		RegisterHamFromEntity(Ham_Killed, id, "bacon_killed_player")
		RegisterHamFromEntity(Ham_TraceAttack, id, "bacon_traceattack_player")
		RegisterHamFromEntity(Ham_Spawn, id, "bacon_spawn_player_post", 1)

		g_botclient_pdata = 1
	}
}

public bot_weapons(id)
{
	g_player_weapons[id][0] = _random(sizeof g_primaryweapons)
	g_player_weapons[id][1] = _random(sizeof g_secondaryweapons)

	equipweapon(id, EQUIP_ALL)
}

public update_team(id)
{
	if(!is_user_connected(id))
		return

	static team
	team = fm_get_user_team(id)

	if(team == CS_TEAM_T || team == CS_TEAM_CT)
	{
		emessage_begin(MSG_ALL, g_msg_teaminfo)
		ewrite_byte(id)
		ewrite_string(g_teaminfo[team])
		emessage_end()
	}
}

const UNIT_SECOND = (1<<12)
const FFADE_IN = 0x0000

public infect_user(victim, attacker)
{
	if(!is_user_alive(victim) || Terminator[victim])
		return

	reset_flash(victim)

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HideWeapon"), _, victim)
	write_byte(2)
	message_end()

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Crosshair"), _, victim)
	write_byte(0)
	message_end()

	/*message_begin(MSG_ONE, g_msg_screenfade, _, victim)
	write_short(1<<10)
	write_short(1<<10)
	write_short(0)
	write_byte((g_mutate[victim] != -1) ? 255 : 100)
	write_byte(100)
	write_byte(100)
	write_byte(250)
	message_end()*/

	message_begin(MSG_ONE_UNRELIABLE, g_msg_screenfade, _, victim)
	write_short(UNIT_SECOND) // duration
	write_short(0) // hold time
	write_short(FFADE_IN) // fade type
	write_byte(0) // r
	write_byte(120) // g
	write_byte(0) // b
	write_byte (255) // alpha
	message_end()

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), _, victim)
	write_short(UNIT_SECOND*4) // amplitude
	write_short(UNIT_SECOND*2) // duration
	write_short(UNIT_SECOND*10) // frequency
	message_end()

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Damage"), _, victim)
	write_byte(0) // damage save
	write_byte(0) // damage take
	write_long(DMG_NERVEGAS) // damage type - DMG_RADIATION
	write_coord(0) // x
	write_coord(0) // y
	write_coord(0) // z
	message_end()

	static origin[3]
	get_user_origin(victim, origin)

	// Tracers?
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_IMPLOSION) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(128) // radius
	write_byte(20) // count
	write_byte(3) // duration
	message_end()

	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_PARTICLEBURST) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_short(50) // radius
	write_byte(70) // color
	write_byte(3) // duration (will be randomized a bit)
	message_end()

	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(20) // radius
	write_byte(0) // r
	write_byte(120) // g
	write_byte(0) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()

	if(g_mutate[victim] != -1)
	{
		g_player_class[victim] = g_mutate[victim]
		g_mutate[victim] = -1

		set_hudmessage(_, _, _, _, _, 1)
		ShowSyncHudMsg(victim, g_sync_msgdisplay, "%L", victim, "MUTATION_HUD", g_class_name[g_player_class[victim]])
	}

	fm_set_user_team(victim, CS_TEAM_T)

	set_zombie_attibutes(victim)
	check_grav(victim)
	has_cloak_act[victim] = 0
	//has_cloak[victim] = false

	emit_sound(victim, CHAN_STATIC, g_scream_sounds[_random(sizeof g_scream_sounds)], VOL_NORM, ATTN_NONE, 0, PITCH_NORM)
	ExecuteForward(g_fwd_infect, g_fwd_result, victim, attacker)

	if (g_showclass[victim] == true)
		if(g_classcount > 1) display_classmenu(victim, g_menuposition[victim] = 0)

	//client_print(0, print_chat, "Steam error: 0x030%i255%i",random_num(0,9),random_num(0,9))

}

public cure_user(id)
{
	if(!is_user_alive(id))
		return

	g_zombie[id] = false
	g_falling[id] = false
	has_cloak_act[id] = 0

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HideWeapon"), _, id)
	write_byte(128)
	message_end()

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Crosshair"), _, id)
	write_byte(0)
	message_end()

	reset_user_model(id)

	new pmodel[64]
	cs_get_user_model(id,pmodel,63)
	if (equali(pmodel,"sas"))
		cs_set_user_model(id,"claire")
	if (equali(pmodel,"guerilla"))
		cs_set_user_model(id,"lilith")
	#if defined TERMINATOR
	if (Terminator[id])
		cs_set_user_model(id,"terminator")
	#endif
	if (get_vip_options(id)&VIP_FLAG_M)
		cs_set_user_model(id,"vip")

	if (has_nv(id))
		fm_set_user_nvg(id)
	set_pev(id, pev_gravity, 1.0)

	static viewmodel[64]
	pev(id, pev_viewmodel2, viewmodel, 63)

	if(equal(viewmodel, g_class_wmodel[g_player_class[id]]))
	{
		static weapon
		weapon = fm_lastknife(id)

		if(pev_valid(weapon))
			ExecuteHam(Ham_Item_Deploy, weapon)
	}

	if (has_snark(id)!=0)
	 	reset_snark(id)

	check_grav(id)
	set_rendering( id )
}

public display_equipmenu(id)
{
	static menubody[512], len
  	len = formatex(menubody, 511, "\y%L^n^n", id, "MENU_TITLE1")

	static bool:hasweap
	hasweap = ((g_player_weapons[id][0]) != -1 && (g_player_weapons[id][1] != -1)) ? true : false

	len += formatex(menubody[len], 511 - len,"\r1. \w%L^n", id, "MENU_NEWWEAPONS")
	len += formatex(menubody[len], 511 - len,"%s2. %s%L^n", hasweap ? "\r" : "\d", hasweap ? "\w" : "\d", id, "MENU_PREVSETUP")
	len += formatex(menubody[len], 511 - len,"%s3. %s%L^n^n", hasweap ? "\r" : "\d", hasweap ? "\w" : "\d", id, "MENU_DONTSHOW")
	len += formatex(menubody[len], 511 - len,"\r5. \w%L^n", id, "MENU_EXIT")

	static keys
	keys = (MENU_KEY_1|MENU_KEY_5)

	if(hasweap)
		keys |= (MENU_KEY_2|MENU_KEY_3)

	show_menu(id, keys, menubody, -1, "Equipment")
}

public action_equip(id, key)
{
	if(!is_user_alive(id) || g_zombie[id])
		return PLUGIN_HANDLED

	switch(key)
	{
		case 0: display_weaponmenu(id, MENU_PRIMARY, g_menuposition[id] = 0)
		case 1: equipweapon(id, EQUIP_ALL)
		case 2:
		{
			g_showmenu[id] = false
			equipweapon(id, EQUIP_ALL)
			client_print(id, print_chat, "%L", id, "MENU_CMDENABLE")
		}
	}

	if(key > 0)
	{
		g_menufailsafe[id] = false
		remove_task(TASKID_WEAPONSMENU + id)
	}
	return PLUGIN_HANDLED
}


public display_weaponmenu(id, menuid, pos)
{
	if(pos < 0 || menuid < 0)
		return

	static start
	start = pos * 8

	static maxitem
	maxitem = menuid == MENU_PRIMARY ? sizeof g_primaryweapons : sizeof g_secondaryweapons

  	if(start >= maxitem)
    		start = pos = g_menuposition[id]

	static menubody[512], len
  	len = formatex(menubody, 511, "\y%L\w^n^n", id, menuid == MENU_PRIMARY ? "MENU_TITLE2" : "MENU_TITLE3")

	static end
	end = start + 8
	if(end > maxitem)
    		end = maxitem

	static keys
	keys = MENU_KEY_0

	static a, b
	b = 0

  	for(a = start; a < end; ++a)
	{
		keys |= (1<<b)
		len += formatex(menubody[len], 511 - len,"\r%d. \w%s^n", ++b, menuid == MENU_PRIMARY ? g_primaryweapons[a][0]: g_secondaryweapons[a][0])
  	}

  	if(end != maxitem)
	{
    		formatex(menubody[len], 511 - len, "^n\r9. \w%L^n\r0. \w%L", id, "MENU_MORE", id, pos ? "MENU_BACK" : "MENU_EXIT")
    		keys |= MENU_KEY_9
  	}
  	else
		formatex(menubody[len], 511 - len, "^n\r0. \w%L", id, pos ? "MENU_BACK" : "MENU_EXIT")

  	show_menu(id, keys, menubody, -1, menuid == MENU_PRIMARY ? "Primary" : "Secondary")
}

public action_prim(id, key)
{
	if(!is_user_alive(id) || g_zombie[id])
		return PLUGIN_HANDLED

	switch(key)
	{
    		case 8: display_weaponmenu(id, MENU_PRIMARY, ++g_menuposition[id])
		case 9: display_weaponmenu(id, MENU_PRIMARY, --g_menuposition[id])
    		default:
		{
			g_player_weapons[id][0] = g_menuposition[id] * 8 + key
			equipweapon(id, EQUIP_PRI)

			display_weaponmenu(id, MENU_SECONDARY, g_menuposition[id] = 0)
		}
	}
	return PLUGIN_HANDLED
}

public action_sec(id, key)
{
	if(!is_user_alive(id) || g_zombie[id])
		return PLUGIN_HANDLED

	switch(key)
	{
    		case 8: display_weaponmenu(id, MENU_SECONDARY, ++g_menuposition[id])
		case 9: display_weaponmenu(id, MENU_SECONDARY, --g_menuposition[id])
    		default:
		{
			g_menufailsafe[id] = false
			remove_task(TASKID_WEAPONSMENU + id)

			g_player_weapons[id][1] = g_menuposition[id] * 8 + key
			equipweapon(id, EQUIP_SEC)
			equipweapon(id, EQUIP_GREN)
		}
	}
	return PLUGIN_HANDLED
}

public display_classmenu(id, pos)
{
	if(pos < 0)
		return

	if (g_showclass[id] == true)
		g_showclass[id] = false

	static start
	start = pos * 8

	static maxitem
	maxitem = g_classcount

  	if(start >= maxitem)
    		start = pos = g_menuposition[id]

	static menubody[512], len
  	len = formatex(menubody, 511, "\r%L\w^n^n", id, "MENU_TITLE4")

	static end
	end = start + 8

	if(end > maxitem)
    		end = maxitem

	static keys
	keys = MENU_KEY_0

	static a, b
	b = 0

  	for(a = start; a < end; ++a)
	{
		keys |= (1<<b)
		len += formatex(menubody[len], 511 - len,"\r%d. \w%s \y(%s)^n", ++b, g_class_name[a], g_class_desc[a])
  	}

  	if(end != maxitem)
	{
    		formatex(menubody[len], 511 - len, "^n\r9. \w%L^n\r0. \w%L", id, "MENU_MORE", id, pos ? "MENU_BACK" : "MENU_EXIT")
    		keys |= MENU_KEY_9
  	}
  	else
		formatex(menubody[len], 511 - len, "^n\r0. \w%L", id, pos ? "MENU_BACK" : "MENU_EXIT")

  	show_menu(id, keys, menubody, -1, "Class")
}

public action_class(id, key)
{
	switch(key)
	{
    		case 8: display_classmenu(id, ++g_menuposition[id])
		case 9: display_classmenu(id, --g_menuposition[id])
    		default:
		{
			g_mutate[id] = g_menuposition[id] * 8 + key
			client_print(id, print_chat, "%L", id, "MENU_CHANGECLASS", g_class_name[g_mutate[id]])
		}
	}
	return PLUGIN_HANDLED
}

public register_spawnpoints(const mapname[])
{
	new configdir[32]
	get_configsdir(configdir, 31)

	new csdmfile[64], line[64], data[10][6]
	formatex(csdmfile, 63, "%s/csdm/%s.spawns.cfg", configdir, mapname)

	if(file_exists(csdmfile))
	{
		new file
		file = fopen(csdmfile, "rt")

		while(file && !feof(file))
		{
			fgets(file, line, 63)
			if(!line[0] || str_count(line,' ') < 2)
				continue

			parse(line, data[0], 5, data[1], 5, data[2], 5, data[3], 5, data[4], 5, data[5], 5, data[6], 5, data[7], 5, data[8], 5, data[9], 5)

			g_spawns[g_spawncount][0] = floatstr(data[0]), g_spawns[g_spawncount][1] = floatstr(data[1])
			g_spawns[g_spawncount][2] = floatstr(data[2]), g_spawns[g_spawncount][3] = floatstr(data[3])
			g_spawns[g_spawncount][4] = floatstr(data[4]), g_spawns[g_spawncount][5] = floatstr(data[5])
			g_spawns[g_spawncount][6] = floatstr(data[7]), g_spawns[g_spawncount][7] = floatstr(data[8])
			g_spawns[g_spawncount][8] = floatstr(data[9])

			if(++g_spawncount >= MAX_SPAWNS)
				break
		}
		if(file)
			fclose(file)
	}
}

public register_zombieclasses(filename[])
{
	new configdir[32]
	get_configsdir(configdir, 31)

	new configfile[64]
	formatex(configfile, 63, "%s/%s", configdir, filename)

	if(get_pcvar_num(cvar_zombie_class) && file_exists(configfile))
	{
		new line[128], leftstr[32], rightstr[64],  classname[32], data[MAX_DATA], i

		new file
		file = fopen(configfile, "rt")

		while(file && !feof(file))
		{
			fgets(file, line, 127), trim(line)
			if(!line[0] || line[0] == ';') continue

			if(line[0] == '[' && line[strlen(line) - 1] == ']')
			{
				copy(classname, strlen(line) - 2, line[1])

				if(register_class(classname) == -1)
					break

				continue
			}
			strtok(line, leftstr, 31, rightstr, 63, '=', 1)

			if(equali(leftstr, "DESC"))
				copy(g_class_desc[g_classcount - 1], 31, rightstr)
			else if(equali(leftstr, "PMODEL"))
				copy(g_class_pmodel[g_classcount - 1], 63, rightstr)
			else if(equali(leftstr, "TMODEL"))
				copy(g_class_tmodel[g_classcount - 1], 63, rightstr)
			else if(equali(leftstr, "WMODEL"))
				copy(g_class_wmodel[g_classcount - 1], 63, rightstr)

			for(i = 0; i < MAX_DATA; i++)
				data[i] = equali(leftstr, g_dataname[i])

			for(i = 0; i < MAX_DATA; i++) if(data[i])
			{
				g_class_data[g_classcount - 1][i] = floatstr(rightstr)
				break
			}
		}
		if(file) fclose(file)
	}
	else
		register_class("default")
}

public register_class(classname[])
{
	if(g_classcount >= MAX_CLASSES)
		return -1

	copy(g_class_name[g_classcount], 31, classname)
	copy(g_class_pmodel[g_classcount], 63, DEFAULT_PMODEL)
	copy(g_class_tmodel[g_classcount], 63, DEFAULT_TMODEL)
	copy(g_class_wmodel[g_classcount], 63, DEFAULT_WMODEL)

	g_class_data[g_classcount][DATA_HEALTH] = DEFAULT_HEALTH
	g_class_data[g_classcount][DATA_SPEED] = DEFAULT_SPEED
	g_class_data[g_classcount][DATA_GRAVITY] = DEFAULT_GRAVITY
	g_class_data[g_classcount][DATA_ATTACK] = DEFAULT_ATTACK
	g_class_data[g_classcount][DATA_DEFENCE] = DEFAULT_DEFENCE
	g_class_data[g_classcount][DATA_HEDEFENCE] = DEFAULT_HEDEFENCE
	g_class_data[g_classcount][DATA_HITSPEED] = DEFAULT_HITSPEED
	g_class_data[g_classcount][DATA_HITDELAY] = DEFAULT_HITDELAY
	g_class_data[g_classcount][DATA_REGENDLY] = DEFAULT_REGENDLY
	g_class_data[g_classcount][DATA_HITREGENDLY] = DEFAULT_HITREGENDLY
	g_class_data[g_classcount++][DATA_KNOCKBACK] = DEFAULT_KNOCKBACK

	return (g_classcount - 1)
}

public native_register_class(classname[], description[])
{
	param_convert(1)
	param_convert(2)

	static classid
	classid = register_class(classname)

	if(classid != -1)
		copy(g_class_desc[classid], 31, description)

	return classid
}

public native_set_class_pmodel(classid, player_model[])
{
	param_convert(2)
	copy(g_class_pmodel[classid], 63, player_model)
}

public native_set_class_wmodel(classid, weapon_model[])
{
	param_convert(2)
	copy(g_class_wmodel[classid], 63, weapon_model)
}

public native_is_user_zombie(index)
	return g_zombie[index] == true ? 1 : 0

public native_set_start_weap(index)
	newSpawn(index)

public native_get_user_class(index)
	return g_player_class[index]

public native_is_user_infected(index)
	return g_preinfect[index] == true ? 1 : 0

public native_game_started()
	return g_gamestarted

public native_preinfect_user(index, bool:yesno)
{
	if(is_user_alive(index) && !g_gamestarted)
		g_preinfect[index] = yesno
}

public native_infect_user(victim, attacker)
{
	if(allow_infection() && g_gamestarted)
		infect_user(victim, attacker)
}

public native_cure_user(index)
	cure_user(index)

public native_get_class_id(classname[])
{
	param_convert(1)

	static i
	for(i = 0; i < g_classcount; i++)
	{
		if(equali(classname, g_class_name[i]))
			return i
	}
	return -1
}

public get_class_id(classname[])
{
	static i
	for(i = 0; i < g_classcount; i++)
	{
		if(equali(classname, g_class_name[i]))
			return i
	}
	return -1
}

public Float:native_get_class_data(classid, dataid)
	return g_class_data[classid][dataid]

public native_set_class_data(classid, dataid, Float:value)
	g_class_data[classid][dataid] = value

stock bool:fm_is_hull_vacant(const Float:origin[3], hull)
{
	static tr
	tr = 0

	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, tr)
	return (!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid) && get_tr2(tr, TR_InOpen)) ? true : false
}

stock fm_set_kvd(entity, const key[], const value[], const classname[] = "")
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	return dllfunc(DLLFunc_KeyValue, entity, 0)
}

stock fm_strip_user_weapons(index)
{
	static stripent
	if(!pev_valid(stripent))
	{
		stripent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
		dllfunc(DLLFunc_Spawn, stripent), set_pev(stripent, pev_solid, SOLID_NOT)
	}
	dllfunc(DLLFunc_Use, stripent, index)

	return 1
}

stock fm_set_entity_visibility(index, visible = 1)
	set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW)

stock fm_find_ent_by_owner(index, const classname[], owner)
{
	static ent
	ent = index

	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) && pev(ent, pev_owner) != owner) {}

	return ent
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

stock fm_set_user_team(index, team, update = 1)
{
	set_pdata_int(index, OFFSET_TEAM, team)
	if(update)
	{
		emessage_begin(MSG_ALL, g_msg_teaminfo)
		ewrite_byte(index)
		ewrite_string(g_teaminfo[team])
		emessage_end()
	}
	return 1
}

stock fm_get_user_bpammo(index, weapon)
{
	static offset
	switch(weapon)
	{
		case CSW_AWP: offset = OFFSET_AMMO_338MAGNUM
		case CSW_SCOUT, CSW_AK47, CSW_G3SG1: offset = OFFSET_AMMO_762NATO
		case CSW_M249: offset = OFFSET_AMMO_556NATOBOX
		case CSW_FAMAS, CSW_M4A1, CSW_AUG,
		CSW_SG550, CSW_GALI, CSW_SG552: offset = OFFSET_AMMO_556NATO
		case CSW_M3, CSW_XM1014: offset = OFFSET_AMMO_BUCKSHOT
		case CSW_USP, CSW_UMP45, CSW_MAC10: offset = OFFSET_AMMO_45ACP
		case CSW_FIVESEVEN, CSW_P90: offset = OFFSET_AMMO_57MM
		case CSW_DEAGLE: offset = OFFSET_AMMO_50AE
		case CSW_P228: offset = OFFSET_AMMO_357SIG
		case CSW_GLOCK18, CSW_TMP, CSW_ELITE,
		CSW_MP5NAVY: offset = OFFSET_AMMO_9MM
		default: offset = 0
	}
	return offset ? get_pdata_int(index, offset) : 0
}

stock fm_set_user_bpammo(index, weapon, amount)
{
	static offset
	switch(weapon)
	{
		case CSW_AWP: offset = OFFSET_AMMO_338MAGNUM
		case CSW_SCOUT, CSW_AK47, CSW_G3SG1: offset = OFFSET_AMMO_762NATO
		case CSW_M249: offset = OFFSET_AMMO_556NATOBOX
		case CSW_FAMAS, CSW_M4A1, CSW_AUG,
		CSW_SG550, CSW_GALI, CSW_SG552: offset = OFFSET_AMMO_556NATO
		case CSW_M3, CSW_XM1014: offset = OFFSET_AMMO_BUCKSHOT
		case CSW_USP, CSW_UMP45, CSW_MAC10: offset = OFFSET_AMMO_45ACP
		case CSW_FIVESEVEN, CSW_P90: offset = OFFSET_AMMO_57MM
		case CSW_DEAGLE: offset = OFFSET_AMMO_50AE
		case CSW_P228: offset = OFFSET_AMMO_357SIG
		case CSW_GLOCK18, CSW_TMP, CSW_ELITE,
		CSW_MP5NAVY: offset = OFFSET_AMMO_9MM
		default: offset = 0
	}

	if(offset)
		set_pdata_int(index, offset, amount)

	return 1
}

stock fm_set_user_nvg(index, onoff = 1)
{
	static nvg
	nvg = get_pdata_int(index, OFFSET_NVG)

	set_pdata_int(index, OFFSET_NVG, onoff == 1 ? nvg | HAS_NVG : nvg & ~HAS_NVG)
	return 1
}

stock fm_set_user_money(index, addmoney)
{
	static money
	money = fm_get_user_money(index) + addmoney
	cs_set_user_money_ul(index,money)

/*
	set_pdata_int(index, OFFSET_CSMONEY, money)

	if(update)
	{
		message_begin(MSG_ONE, g_msg_money, _, index)
		write_long(clamp(money, 0, 16000))
		write_byte(1)
		message_end()
	}
*/
	return 1
}

stock str_count(str[], searchchar)
{
	static maxlen
	maxlen = strlen(str)

	static i, count
	count = 0

	for(i = 0; i <= maxlen; i++) if(str[i] == searchchar)
		count++

	return count
}

stock reset_user_model(index)
{
	if (!is_user_alive(index))
		return

	set_pev(index, pev_rendermode, kRenderNormal)
	set_pev(index, pev_renderamt, 0.0)

	if(pev_valid(g_modelent[index]))
		fm_set_entity_visibility(g_modelent[index], 0)
	if(pev_valid(g_modelent2[index]))
		fm_set_entity_visibility(g_modelent2[index], 0)
}

public native_reset_zm_model(index)
	reset_user_model(index)

public native_vis_zm_model(index, set) {
	if(pev_valid(g_modelent[index]))
		fm_set_entity_visibility(g_modelent[index], set)
}

stock remove_user_model(ent)
{
	static id
	id = pev(ent, pev_owner)

	if(pev_valid(ent))
		engfunc(EngFunc_RemoveEntity, ent)

	g_modelent[id] = 0
}

stock remove_user_model2(ent)
{
	static id
	id = pev(ent, pev_owner)

	if(pev_valid(ent))
		engfunc(EngFunc_RemoveEntity, ent)

	g_modelent2[id] = 0
}

public native_set_zm_model(index)
	set_zombie_model(index)

public native_del_modelent2(index) {

	if (!is_user_connected(index) || !native_is_user_zombie(index) || !is_user_alive(index))
		return

	remove_user_model2(g_modelent2[index])

}

public native_sel_modelent2(index, set) {

	if (!is_user_connected(index) || !native_is_user_zombie(index) || !is_user_alive(index))
		return

	if(!pev_valid(g_modelent2[index]))
	{
		static ent2
		ent2 = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if(pev_valid(ent2))
		{
			engfunc(EngFunc_SetModel, ent2, "models/p_alt_squeak.mdl")
			set_pev(ent2, pev_classname, MODEL_CLASSNAME)
			set_pev(ent2, pev_movetype, MOVETYPE_FOLLOW)
			set_pev(ent2, pev_aiment, index)
			set_pev(ent2, pev_owner, index)

			g_modelent2[index] = ent2
		}
		fm_set_entity_visibility(g_modelent2[index], set)
	}
	else
	{
		engfunc(EngFunc_SetModel, g_modelent2[index], "models/p_alt_squeak.mdl")
		fm_set_entity_visibility(g_modelent2[index], set)
	}

}

public set_zombie_model(index) {

	if (!is_user_alive(index))
		return

	if(!pev_valid(g_modelent[index]))
	{
		static ent
		ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if(pev_valid(ent))
		{
			engfunc(EngFunc_SetModel, ent, g_class_pmodel[g_player_class[index]])
			set_pev(ent, pev_classname, MODEL_CLASSNAME)
			set_pev(ent, pev_movetype, MOVETYPE_FOLLOW)
			set_pev(ent, pev_aiment, index)
			set_pev(ent, pev_owner, index)
			g_modelent[index] = ent
		}
	}
	else
	{
		engfunc(EngFunc_SetModel, g_modelent[index], g_class_pmodel[g_player_class[index]])
		fm_set_entity_visibility(g_modelent[index], 1)
	}

	if(!pev_valid(g_modelent2[index]))
	{
		static ent2
		ent2 = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if(pev_valid(ent2))
		{
			engfunc(EngFunc_SetModel, ent2, "models/p_alt_squeak.mdl")
			set_pev(ent2, pev_classname, MODEL_CLASSNAME)
			set_pev(ent2, pev_movetype, MOVETYPE_FOLLOW)
			set_pev(ent2, pev_aiment, index)
			set_pev(ent2, pev_owner, index)

			g_modelent2[index] = ent2
		}
		fm_set_entity_visibility(g_modelent2[index], 0)
	}
	else
	{
		engfunc(EngFunc_SetModel, g_modelent2[index], "models/p_alt_squeak.mdl")
		fm_set_entity_visibility(g_modelent2[index], 0)
	}

}

stock set_zombie_attibutes(index)
{
	if(!is_user_alive(index))
		return

	g_nvisionenabled[index] = false
	g_zombie[index] = true
	FixDeadAttrib(index)

	if(!task_exists(TASKID_STRIPNGIVE + index))
		set_task(0.1, "task_stripngive", TASKID_STRIPNGIVE + index)

	static Float:health
	health = g_class_data[g_player_class[index]][DATA_HEALTH]

	if(g_preinfect[index])
		health *= get_pcvar_float(cvar_zombie_hpmulti)

	/*new hp = get_user_health(index)
	if (hp>100)	health = health+(hp-100)/2
	new ap = get_user_armor(index)
	if (ap>0) health = health+ap/2*/

	new pmodel[64]
	cs_get_user_model(index,pmodel,63)
	if (equali(pmodel,"claire"))
		cs_set_user_model(index,"sas")
	if (equali(pmodel,"lilith"))
		cs_set_user_model(index,"guerilla")

	set_pev(index, pev_health, health)
	set_pev(index, pev_gravity, g_class_data[g_player_class[index]][DATA_GRAVITY])
	set_pev(index, pev_body, 0)
	set_pev(index, pev_armorvalue, 0.0)
	set_pev(index, pev_renderamt, 0.0)
	set_pev(index, pev_rendermode, kRenderTransTexture)
	set_rendering( g_modelent[index] );
	fm_set_entity_visibility(g_modelent[index], 1);

	fm_set_user_armortype(index, CS_ARMOR_NONE)
	//fm_set_user_nvg(index)
	remove_user_nvg(index)

	fm_set_user_footsteps(index,1)

	if(get_pcvar_num(cvar_autonvg))
		engclient_cmd(index, "nightvision")

	if(!pev_valid(g_modelent[index]))
	{
		static ent
		ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if(pev_valid(ent))
		{
			engfunc(EngFunc_SetModel, ent, g_class_pmodel[g_player_class[index]])
			set_pev(ent, pev_classname, MODEL_CLASSNAME)
			set_pev(ent, pev_movetype, MOVETYPE_FOLLOW)
			set_pev(ent, pev_aiment, index)
			set_pev(ent, pev_owner, index)
			g_modelent[index] = ent
		}
	}
	else
	{
		engfunc(EngFunc_SetModel, g_modelent[index], g_class_pmodel[g_player_class[index]])
		fm_set_entity_visibility(g_modelent[index], 1)
	}

	if(!pev_valid(g_modelent2[index]))
	{
		static ent2
		ent2 = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if(pev_valid(ent2))
		{
			engfunc(EngFunc_SetModel, ent2, "models/p_alt_squeak.mdl")
			set_pev(ent2, pev_classname, MODEL_CLASSNAME)
			set_pev(ent2, pev_movetype, MOVETYPE_FOLLOW)
			set_pev(ent2, pev_aiment, index)
			set_pev(ent2, pev_owner, index)

			g_modelent2[index] = ent2
		}
		fm_set_entity_visibility(g_modelent2[index], 0)
	}
	else
	{
		engfunc(EngFunc_SetModel, g_modelent2[index], "models/p_alt_squeak.mdl")
		fm_set_entity_visibility(g_modelent2[index], 0)
	}

	static effects
	effects = pev(index, pev_effects)

	if(effects & EF_DIMLIGHT)
	{
		message_begin(MSG_ONE, g_msg_flashlight, _, index)
		write_byte(0)
		write_byte(100)
		message_end()

		set_pev(index, pev_effects, effects & ~EF_DIMLIGHT)
	}
}

// Fix Dead Attrib on scoreboard
FixDeadAttrib(id)
{
	message_begin(MSG_BROADCAST, get_user_msgid("ScoreAttrib"))
	write_byte(id) // id
	write_byte(0) // attrib
	message_end()
}

stock bool:allow_infection()
{
	static count[2]
	count[0] = 0
	count[1] = 0

	static index, maxzombies
	for(index = 1; index <= g_maxplayers; index++)
	{
		if(is_user_connected(index) && g_zombie[index])
			count[0]++
		else if(is_user_alive(index))
			count[1]++
	}

	maxzombies = clamp(get_pcvar_num(cvar_maxzombies), 1, 31)
	return (count[0] < maxzombies && count[1] > 1) ? true : false
}

stock randomly_pick_zombie()
{
	static data[4]
	data[0] = 0
	data[1] = 0
	data[2] = 0
	data[3] = 0

	static index, players[2][32]
	for(index = 1; index <= g_maxplayers; index++)
	{
		if(!is_user_alive(index))
			continue

		if(g_zombie[index])
		{
			data[0]++
			players[0][data[2]++] = index
		}
		else
		{
			data[1]++
			players[1][data[3]++] = index
		}
	}

	if(data[0] > 0 &&  data[1] < 1)
		return players[0][_random(data[2])]

	return (data[0] < 1 && data[1] > 0) ?  players[1][_random(data[3])] : 0
}

stock equipweapon(id, weapon)
{
	if(!is_user_alive(id))
		return

	static weaponid[2], weaponent, weapname[32]

	if(weapon & EQUIP_PRI)
	{
		weaponent = fm_lastprimary(id)
		weaponid[1] = get_weaponid(g_primaryweapons[g_player_weapons[id][0]][1])

		if(pev_valid(weaponent))
		{
			weaponid[0] = fm_get_weapon_id(weaponent)
			if(weaponid[0] != weaponid[1])
			{
				get_weaponname(weaponid[0], weapname, 31)
				bacon_strip_weapon(id, weapname)
			}
		}
		else
			weaponid[0] = -1

		if(weaponid[0] != weaponid[1])
			bacon_give_weapon(id, g_primaryweapons[g_player_weapons[id][0]][1])

		fm_set_user_bpammo(id, weaponid[1], g_weapon_ammo[weaponid[1]][MAX_AMMO])
	}

	if(weapon & EQUIP_SEC)
	{
		weaponent = fm_lastsecondry(id)
		weaponid[1] = get_weaponid(g_secondaryweapons[g_player_weapons[id][1]][1])

		if(pev_valid(weaponent))
		{
			weaponid[0] = fm_get_weapon_id(weaponent)
			if(weaponid[0] != weaponid[1])
			{
				get_weaponname(weaponid[0], weapname, 31)
				bacon_strip_weapon(id, weapname)
			}
		}
		else
			weaponid[0] = -1

		if(weaponid[0] != weaponid[1])
			bacon_give_weapon(id, g_secondaryweapons[g_player_weapons[id][1]][1])

		fm_set_user_bpammo(id, weaponid[1], g_weapon_ammo[weaponid[1]][MAX_AMMO])
	}

	if(weapon & EQUIP_GREN)
	{
		static i
		for(i = 0; i < sizeof g_grenades; i++) if(!user_has_weapon(id, get_weaponid(g_grenades[i])))
			bacon_give_weapon(id, g_grenades[i]);
	}
}

stock add_delay(index, const task[])
{
	switch(index)
	{
		case 1..8:   set_task(0.1, task, index)
		case 9..16:  set_task(0.2, task, index)
		case 17..24: set_task(0.3, task, index)
		case 25..32: set_task(0.4, task, index)
	}
}

public maxhumans() {
	new count = 0

	for(new i = 0; i < 33; i++)
	{
		if (is_user_connected(i)) {
			if (is_user_alive(i) && !native_is_user_zombie(i)) count++
		}
	}

	return (count == 1) ? true : false
}

public maxzombies() {
	new count = 0

	for(new i = 0; i < 33; i++)
	{
		if (is_user_connected(i)) {
			if (is_user_alive(i) && native_is_user_zombie(i)) count++ //get_user_team(i) == CS_TEAM_T
		}
	}

	return (count == 1) ? true : false
}
/*
public cmd_frozen(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static arg1[32],arg2[32]
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)

	if(arg1[0] == '@') {
		if(equali(arg1[1],"ALL")) {
			//new authid[32], name[32]
			//get_user_authid(id, authid, 31)
			//get_user_name(id, name, 31)
			for(new i = 1; i < 33; i++) {
				if (is_user_connected(i)) {
					if (is_user_alive(i)) {
						if (str_to_num(arg2)!=0) {
							if (pev(i, pev_flags) & FL_ONGROUND)
								set_pev(i, pev_gravity, 999999.9) // set really high
							else
								set_pev(i, pev_gravity, 0.000001) // no gravity
							g_frozen[i] = true
						} else {
							g_frozen[i] = false
							check_grav(i)
							entity_set_float(i, EV_FL_maxspeed, returnspeed(i)+check_speed(i))
						}
					}
				}
			}
			//log_amx("^"%s<%d><%s><>^" give longjump to all", name, get_user_userid(id), authid)

			//show_activity_key("JUMP_7A", "JUMP_8A", name)
		}
	} else {

	static target
	target = cmd_target(id, arg1, (CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE))

	if(!is_user_connected(target))
		return PLUGIN_HANDLED_MAIN

	*
	if(!game_started())
	{
		console_print(id, "CMD_GAMENOTSTARTED")
		return PLUGIN_HANDLED_MAIN
	}*

	if (str_to_num(arg2)!=0) {
		if (pev(target, pev_flags) & FL_ONGROUND)
			set_pev(target, pev_gravity, 999999.9) // set really high
		else
			set_pev(target, pev_gravity, 0.000001) // no gravity
		g_frozen[target] = true
	} else {
		g_frozen[target] = false
		check_grav(target)
		entity_set_float(id, EV_FL_maxspeed, returnspeed(target)+check_speed(target))
	}

	//give_item(target, "item_longjump")
	//set_longjump(target)
	*new authid[32], authid2[32], name2[32], name[32], userid2, player = target

	get_user_authid(id, authid, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(player, name2, 31)
	get_user_name(id, name, 31)
	userid2 = get_user_userid(player)
    *
	//log_amx("^"%s<%d><%s><>^" give longjump to ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)

	//show_activity_key("JUMP_7", "JUMP_8", name, name2)

	}

	return PLUGIN_HANDLED
}

public Float:returnspeed(id) {

	if (!is_user_connected(id) || !is_user_alive(id))
		return 0.0

	if (native_is_user_zombie(id)) {
		return native_get_class_data(native_get_user_class(id), DATA_SPEED)
	} else {
	//cs_set_user_zoom(id,0,0)
	//cs_set_user_zoom(id,2,1)
	static Float:weapon, clip, ammo
	switch(get_user_weapon(id, clip, ammo))
	{
		case CSW_P228:
		weapon = 255.0
		case CSW_SCOUT:
		weapon = 260.0
		case CSW_HEGRENADE:
		weapon = 250.0
		case CSW_XM1014:
		weapon = 240.0
		case CSW_MAC10:
		weapon = 250.0
		case CSW_AUG:
		weapon = 240.0
		case CSW_SMOKEGRENADE:
		weapon = 250.0
		case CSW_ELITE:
		weapon = 250.0
		case CSW_FIVESEVEN:
		weapon = 250.0
		case CSW_UMP45:
		weapon = 250.0
		case CSW_SG550:
		weapon = 235.0
		case CSW_GALIL:
		weapon = 240.0
		case CSW_FAMAS:
		weapon = 240.0
		case CSW_USP:
		weapon = 250.0
		case CSW_MP5NAVY:
		weapon = 250.0
		case CSW_M249:
		weapon = 220.0
		case CSW_M3:
		weapon = 230.0
		case CSW_M4A1:
		weapon = 230.0
		case CSW_TMP:
		weapon = 250.0
		case CSW_G3SG1:
		weapon = 210.0
		case CSW_FLASHBANG:
		weapon = 250.0
		case CSW_DEAGLE:
		weapon = 250.0
		case CSW_SG552:
		weapon = 235.0
		case CSW_AK47:
		weapon = 221.0
		case CSW_KNIFE:
		weapon = 250.0
		case CSW_P90:
		weapon = 245.0
		case CSW_GLOCK18:
		weapon = 250.0
		case CSW_AWP:
		weapon = 210.0
		case CSW_C4:
		weapon = 250.0
		default:
		weapon = 250.0
		//return
	}
	//user_speed[id] = weapon
	//entity_set_float(id, EV_FL_maxspeed, weapon)
	return weapon
	}
	return 0.0
	//entity_set_float(id, EV_FL_maxspeed, plspeed[who])
}*/

public clcmd_nightvision(id)
{
	if (!g_zombie[id] && is_user_alive(id)) {
		g_nvisionenabled[id] = false
		if (task_exists(id+TASK_NVISION))
			remove_task(id+TASK_NVISION)
		return PLUGIN_CONTINUE;
	}

	//if (g_nvision[id])
	//{
		// Enable-disable
	g_nvisionenabled[id] = !(g_nvisionenabled[id])

		// Custom nvg?
	//	if (get_pcvar_num(cvar_customnvg))
	//	{
	remove_task(id+TASK_NVISION)
	if (g_nvisionenabled[id]) set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
	//	}
	//	else
	//		set_user_gnvision(id, g_nvisionenabled[id])
	//}

	return PLUGIN_HANDLED;
}

public set_user_nvision(taskid)
{

	if (!g_zombie[ID_NVISION] && is_user_alive(ID_NVISION)) {
		g_nvisionenabled[ID_NVISION] = false
		if (task_exists(taskid))
			remove_task(taskid)
		return;
	}

	// Get player's origin
	static origin[3]
	get_user_origin(ID_NVISION, origin)

	// Nightvision message
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_NVISION)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(80) // radius

	write_byte(0) // r
	write_byte(120) // g
	write_byte(0) // b

	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()

	return
}

public native_reset_user_nv(index) {
	g_nvisionenabled[index] = false
	if (task_exists(index+TASK_NVISION))
		remove_task(index+TASK_NVISION)
}

const m_flNextAttack = 83

public clcmd_sayunstuck(id) {

	if (!native_game_started()) {
		client_print(id, print_chat, "%L", id, "GMS_A")
		return PLUGIN_CONTINUE
	}

	if (is_user_alive(id))
	{
		//if (is_player_stuck(id))
		//	do_random_spawn(id)
		//else
		if (task_exists(id+TASKID_STUCK)) {
			client_print(id, print_chat, "%L", id, "CMD_STUCK_WAIT")
			return PLUGIN_CONTINUE
		}
		set_pev( id , pev_velocity , { 0.0 , 0.0 , 0.0 } );
		set_pev( id , pev_flags , pev( id , pev_flags ) | FL_FROZEN );
		//engclient_cmd(id, "weapon_knife");
		set_pdata_float( id, m_flNextAttack, 9999.0 );
		set_task(15.0,"do_random_spawn",id+TASKID_STUCK)
		client_print(id, print_chat, "%L", id, "CMD_STUCK")
	} else
		client_print(id, print_chat, "%L", id, "CMD_NOT")

	return PLUGIN_CONTINUE

}

public load_spawns()
{
	collect_spawns_ent("info_player_start")
	collect_spawns_ent("info_player_deathmatch")
}

public collect_spawns_ent(const classname[])
{
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
	{
		// get origin
		new Float:originF[3]
		pev(ent, pev_origin, originF)
		g_spawns2[g_spawnCount][0] = originF[0]
		g_spawns2[g_spawnCount][1] = originF[1]
		g_spawns2[g_spawnCount][2] = originF[2]

		// increase spawn count
		g_spawnCount++
		if (g_spawnCount >= sizeof g_spawns2) break;
	}
}

public is_hull_vacant(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)

	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;

	return false;
}

public do_random_spawn(taskid)
{

	new id = taskid-TASKID_STUCK

	if (!is_user_connected(id) || !is_user_alive(id))
		return

	static hull, sp_index, i

	// Get whether the player is crouching
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN

	// No spawns?
	if (!g_spawnCount)
		return

	// Choose random spawn to start looping at
	sp_index = random_num(0, g_spawnCount - 1)

	// Try to find a clear spawn
	for (i = sp_index + 1; /*no condition*/; i++)
	{
		// Start over when we reach the end
		if (i >= g_spawnCount) i = 0

		// Free spawn space?
		if (is_hull_vacant(g_spawns2[i], hull))
		{
			// Engfunc_SetOrigin is used so ent's mins and maxs get updated instantly
			engfunc(EngFunc_SetOrigin, id, g_spawns2[i])
			client_print(id, print_chat, "%L", id, "CMD_STUCK_OK")
			set_pev( id , pev_flags , pev( id , pev_flags ) & ~FL_FROZEN );
			set_pdata_float( id, m_flNextAttack, 0.0 );
			set_task(2.5,"respawn_player",id)
			break;
		}

		// Loop completed, no free space found
		if (i == sp_index) {
			client_print(id, print_chat, "%L", id, "CMD_STUCK_ERR")
			set_pev( id , pev_flags , pev( id , pev_flags ) & ~FL_FROZEN );
			set_pdata_float( id, m_flNextAttack, 0.0 );
			break;
		}
	}

}

public respawn_player(id) {

	if (!is_user_connected(id) || is_user_alive(id) || get_user_team(id) == CS_TEAM_SPECTATOR || !native_game_started())
		return PLUGIN_HANDLED;

	ExecuteHamB(Ham_CS_RoundRespawn, id);
	if (g_zombie[id])
		cs_set_user_team(id,CS_TEAM_T)
	else
		cs_set_user_team(id,CS_TEAM_CT)
	client_print(id, print_chat, "%L", id, "CMD_STUCK_LIFE")

	set_task(2.5,"respawn_player",id)

	return PLUGIN_CONTINUE;

}

public fm_set_user_footsteps(index, set) {
	if (set) {
		set_pev(index, pev_flTimeStepSound, 999);
		g_silent[index] = true;
	}
	else {
		set_pev(index, pev_flTimeStepSound, STANDARDTIMESTEPSOUND);
		g_silent[index] = false;
	}
	return 1;
}

public user_footsteps(victim, attacker)
{
	fm_set_user_footsteps(victim, attacker)
}