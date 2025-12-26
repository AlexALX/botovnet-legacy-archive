/*
* This plugin was modified for Botov-NET Project
* It changes lasermines to be visually blocked by players of same team
* Also it doesn't kill instantly, allowing zombie with HIGH HP pass thought if quick
* And also add more things i don't remember
*
* Copyring for MODIFICATIONS and NEW features by AlexALX (c) 2015
* Original author - +ARUKARI- 
*
*  License of original plugin is unknown.
*  My modifications are licensed under GNU GPL License.
*
*  If you are the author and want to clarify licensing, 
*  please contact the repository owner.

-=LaserMine Entity=-

Each player can set LaserMine on the wall.

================================================

-=VERSIONS=-

Releaseed(Time in JP)	Version 	comment
------------------------------------------------
2006/03/21		1.0		FirstRelease
================================================

-=INSTALLATION=-

Compile and install plugin. (configs/plugins.ini)

================================================

-=USAGE=-

Client command / +setlaser
- ex) bind v +setlaser
- can set lasermine on the wall

Server command(CVAR SETTING)
- amx_lasermine_ammo //The setup of ammo (default 2 max 10)
- amx_lasermine_fragmoney //A setup for the reward (default 300 min 100)
- amx_lasermine_cost //The settlement of the cost (default 500 min 100 max 16000)
- amx_lasermine_health //The settlement of the degree of durability (default 500 min 1 max 800)
- amx_lasermine_dmg //The setup of the damage (default 10000 min 1)

================================================

-=SpecialThanks=-
Tester	justice
	snake21jpn

================================================
*/
#include <amxmodx>
#include <money_ul>
#include <amxmisc>
#include <engine>
#include <cstrike>
#include <fun>
#include <biohazard>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <vip>
#include <drug>
#include <par_lj>

const KEYS_M = MENU_KEY_0 | MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9;

#define TASK_PLANT		15100
#define TASK_NOTICE		15300
#define TASK_MSG		15600

#define LASERMINE_INT_TEAM	EV_INT_iuser1
#define LASERMINE_OWNER		EV_INT_iuser3
#define DMG_BULLET		(1<<1)
#define MAX_MINES		50

new MINE_MDL_CT[] = "models/botovnetua_tripmine.mdl"
new MINE_MDL_T[] = "models/botovnetua_tripmine2.mdl"

new const
	ENT_CLASS_NAME[]	= "lasermine"

new MINE_COST
new FRAGMONEY
new LASER_HIT_DMG
new MINE_HEALTH
new MAX_MINES_CVAR
new LASER_SETUP

enum
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T,
	CS_TEAM_CT,
	CS_TEAM_SPECTATOR
}

new beam, boom
new player_mines_ent[33][MAX_MINES]
new player_mines_count[33]
new bool:g_settinglaser[33]
new g_msgDeathMsg
new g_msgScoreInfo
new g_msgDamage
//new g_msgStatusText
new Float:plspeed[33]
new plsetting[33]
new g_sync_hpdisplay
new g_xtime, g_kill_bonus, h_kill_bonus, g_kill_minus, h_kill_minus

#define OFFSET_TEAM 114

#define fm_get_user_team(%1) get_pdata_int(%1, OFFSET_TEAM)
#define RemoveEntity(%1) engfunc(EngFunc_RemoveEntity,%1)

new bool:g_detonate[33];
new bool:z_detonate[33];
new bool:a_detonate[33];

#define G_PICKUP_SND	"items/9mmclip1.wav"

public plugin_cfg() {

	g_xtime = register_cvar( "amx_lasermine_xtime", "1" )
	g_kill_bonus = register_cvar( "amx_lasermine_kill_bo", "1500" )
	h_kill_bonus = register_cvar( "amx_lasermine_kill_bo2", "500" )
	g_kill_minus = register_cvar( "amx_lasermine_de_kill_bo", "750" )
	h_kill_minus = register_cvar( "amx_lasermine_de_kill_bo2", "750" )

}

public hTakeDamage(this, inflictor, idattacker, Float:damage, damagebits)
{
	if(!pev_valid(this) || !is_user_connected(idattacker))
		return HAM_IGNORED

	if (entity_get_int(this,LASERMINE_OWNER)) {
		if (fm_get_user_team(idattacker) == CS_TEAM_CT && entity_get_int(this,LASERMINE_INT_TEAM) == CS_TEAM_CT) {
			client_print(idattacker, print_chat, "%L", LANG_PLAYER, "AK_BB")
			return HAM_SUPERCEDE
		}

		if (get_pcvar_num(g_xtime)) {
			new mhours[6]
			get_time("%H", mhours, 5)
			new hrs = str_to_num(mhours)
			if ((hrs >= 23 || hrs < 6) || get_pcvar_num(g_xtime) == 2) {
				if (fm_get_user_team(idattacker) == CS_TEAM_CT && entity_get_int(this,LASERMINE_INT_TEAM) == CS_TEAM_T) {
					client_print(idattacker, print_chat, "%L", LANG_PLAYER, "AK_XTIME")
					return HAM_SUPERCEDE
				}
			}
		}

		if (entity_get_float(this, EV_FL_health)-damage <= float(0)) {
			set_msg_block(g_msgDeathMsg, BLOCK_SET)
			detonate_mine(this, idattacker)
			set_msg_block(g_msgDeathMsg, BLOCK_NOT)
			LaserMineThink()
			//RemoveEntity(this)
			//return HAM_SUPERCEDE
		}

	}

	return HAM_IGNORED
}

detonate_mine(iCurrent, iHit) {

	// Get origin
	static Float:originF[3]
	//pev(iCurrent, pev_origin, originF)
	entity_get_vector(iCurrent, EV_VEC_origin, originF)

	static victim
	victim = -1

	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, 300.0)) != 0)
	{
		if (!is_user_alive(victim))
			continue;

		//if (victim == iHit)
		//	continue;

		g_detonate[victim] = true;
		if (is_user_zombie(victim))
			z_detonate[victim] = true;
		else
			z_detonate[victim] = false;

	}

	if (!is_user_alive(iHit))
		a_detonate[iHit] = true;
	else
		a_detonate[iHit] = false;
	g_detonate[iHit] = true;
	if (is_user_zombie(iHit))
		z_detonate[iHit] = true;
	else
		z_detonate[iHit] = false;

	new Float:vOrigin[3]
	entity_get_vector(iCurrent, EV_VEC_origin, vOrigin)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(99) //99 = KillBeam
	write_short(iCurrent)
	message_end()

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(3)
	write_coord(floatround(vOrigin[0]))
	write_coord(floatround(vOrigin[1]))
	write_coord(floatround(vOrigin[2]))
	write_short(boom)
	write_byte(50)
	write_byte(15)
	write_byte(0)
	message_end()

	radius_damage(vOrigin, 1, 50)
	new id,slot

	//id = Entvars_Get_Edict(iCurrent, EV_ENT_owner)
	//remove_entity(iCurrent)
	task_kill(iHit)
	// clear this from the list of live lasermines

	if (a_detonate[iHit] || entity_get_int(iCurrent,LASERMINE_OWNER) == iHit)
		iHit = -1

	for (id=1;id<33;id++) {

		for (slot=0;slot<MAX_MINES;slot++) {
			if (player_mines_ent[id][slot] == iCurrent) {
				player_mines_ent[id][slot] = -1
				player_mines_count[id] = player_mines_count[id] - 1

				if (iHit == -1){
					client_print(id, print_chat, "%L", LANG_PLAYER, "DET_LM")
				} else if (iHit != -2) {
					new szNetName[32]
					entity_get_string(iHit, EV_SZ_netname, szNetName, 32)
					client_print(id, print_chat, "%L", LANG_PLAYER, "DET_LM2", szNetName)
				}
				break
			}
		}
	}

	if (get_pcvar_num(g_xtime)) {
		new mhours[6]
		get_time("%H", mhours, 5)
		new hrs = str_to_num(mhours)
		if ((hrs >= 23 || hrs < 6) || get_pcvar_num(g_xtime) == 2) {
			new ent
			ent = -1

			while ((ent = engfunc(EngFunc_FindEntityInSphere, ent, originF, 14.0)) != 0)
			{
				if(!pev_valid(ent)||ent==iCurrent) continue
				new szClassName[32]
				entity_get_string(ent, EV_SZ_classname, szClassName, 32)
				if (equali(szClassName,"lasermine")&&entity_get_int(ent,LASERMINE_OWNER)) {
					new player = entity_get_int(ent,LASERMINE_OWNER)
					if(!is_user_connected(player)) continue
					update_mines(player,ent)
					RemoveEntity(ent)
				}
			}
		}
	}

}

public task_kill(iHit) {

	new bool:g_hit=false

	for (new id=1;id<33;id++) {

		if (is_user_connected(id) && !is_user_alive(id) && g_detonate[id] && id != iHit) {
			static params[2]
			params[0] = iHit
			params[1] = id
			set_task(0.1,"set_msg",TASK_MSG,params,2)
			if (z_detonate[iHit] && !z_detonate[id]) {
				cs_set_user_money_ul(iHit,cs_get_user_money_ul(iHit)+get_pcvar_num(g_kill_bonus))
				set_user_frags(iHit, get_user_frags(iHit) + 1)
				g_hit=true
			} else if (z_detonate[iHit] && z_detonate[id]) {
				if (cs_get_user_money_ul(iHit)-get_pcvar_num(g_kill_minus) >= 0) cs_set_user_money_ul(iHit,cs_get_user_money_ul(iHit)-get_pcvar_num(g_kill_minus))
				set_user_frags(iHit, get_user_frags(iHit) - 1)
			} else if (!z_detonate[iHit] && z_detonate[id]) {
				cs_set_user_money_ul(iHit,cs_get_user_money_ul(iHit)+get_pcvar_num(h_kill_bonus))
				set_user_frags(iHit, get_user_frags(iHit) + 1)
				g_hit=true
			} else if (!z_detonate[iHit] && !z_detonate[id]) {
				if (cs_get_user_money_ul(iHit)-get_pcvar_num(h_kill_minus) >= 0) cs_set_user_money_ul(iHit,cs_get_user_money_ul(iHit)-get_pcvar_num(h_kill_minus))
				set_user_frags(iHit, get_user_frags(iHit) - 1)
			}

		}

		g_detonate[id] = false
		z_detonate[id] = false

		set_task(0.3, "task_updatescore", id)

	}

	if (!is_user_alive(iHit) && !a_detonate[iHit]) set_task(0.1,"set_msg2",iHit)

	if (g_hit==true && !is_user_alive(iHit) && !a_detonate[iHit]) set_user_frags(iHit, get_user_frags(iHit) + 1)
	a_detonate[iHit] = false
	g_detonate[iHit] = false
	z_detonate[iHit] = false
}

public set_msg(params[]) {

	static attacker
	attacker = params[0]

	static victim
	victim = params[1]

	if(!is_user_connected(victim) || !is_user_connected(attacker))
		return

	message_begin(MSG_ALL, g_msgDeathMsg, {0, 0, 0} ,0)
	write_byte(attacker)
	write_byte(victim)
	write_byte(0)
	write_string("lasermine explode")
	message_end()

}

public set_msg2(victim) {

	if(!is_user_connected(victim))
		return

	message_begin(MSG_ALL, g_msgDeathMsg, {0, 0, 0} ,0)
	write_byte(0)
	write_byte(victim)
	write_byte(0)
	write_string("lasermine explode")
	message_end()

}

public task_updatescore(id)
{

	if(!is_user_connected(id))
		return

	static frags, deaths, team
	frags  = get_user_frags(id)
	deaths = get_user_deaths(id)
	team   = get_user_team(id)

	message_begin(MSG_BROADCAST, g_msgScoreInfo)
	write_byte(id)
	write_short(frags)
	write_short(deaths)
	write_short(0)
	write_short(team)
	message_end()

}

	new cl_r = 0
	new cl_g = 0
	new cl_b = 255
	new cl2_r = 255
	new cl2_g = 0
	new cl2_b = 0
	//new cl3_r = 255
	//new cl3_g = 255
	//new cl3_b = 255
	new cl_a = 255
	new cl2_a = 255
	new wave = 0
	new wave2 = 0
	new life = 3
	new life2 = 3
	new width = 5
	new width2 = 5
	new lm_exa = 0
	new lm_exa2 = 0
	new lm_exb = 0
	new lm_exb2 = 0

public cmd_exa(id, level, cid)
{

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static arg1[32],arg2[32]
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	lm_exa = str_to_num(arg1)
	lm_exa2 = str_to_num(arg2)

	return PLUGIN_HANDLED

}

public cmd_exb(id, level, cid)
{

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static arg1[32],arg2[32]
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	lm_exb = str_to_num(arg1)
	lm_exb2 = str_to_num(arg2)

	return PLUGIN_HANDLED

}

public cmd_life(id, level, cid)
{

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static arg1[32],arg2[32]
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	life = str_to_num(arg1)
	life2 = str_to_num(arg2)

	return PLUGIN_HANDLED

}

public cmd_width(id, level, cid)
{

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static arg1[32],arg2[32]
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	width = str_to_num(arg1)
	width2 = str_to_num(arg2)

	return PLUGIN_HANDLED

}

public cmd_wave(id, level, cid)
{

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static arg1[32],arg2[32]
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	wave = str_to_num(arg1)
	wave2 = str_to_num(arg2)

	return PLUGIN_HANDLED

}

public cmd_a(id, level, cid)
{

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static arg1[32],arg2[32]
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	cl_a = str_to_num(arg1)
	cl2_a = str_to_num(arg2)

	return PLUGIN_HANDLED

}

public cmd_color(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static arg1[32],arg2[32]//,arg3[32]
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	//read_argv(3, arg3, 31)

	new color = str_to_num(arg1)
	new color2 = str_to_num(arg2)
	//new color3 = str_to_num(arg3)

	if (color == 1) { // red
		cl_r = 255
		cl_g = 0
		cl_b = 0
	} else if (color == 2) { // green
		cl_r = 0
		cl_g = 255
		cl_b = 0
	} else if (color == 3) { // blue
		cl_r = 0
		cl_g = 0
		cl_b = 255
	} else if (color == 4) { // yellow
		cl_r = 255
		cl_g = 255
		cl_b = 0
	} else if (color == 5) { // purple
		cl_r = 255
		cl_g = 0
		cl_b = 255
	} else if (color == 6) { // sky-blue
		cl_r = 0
		cl_g = 255
		cl_b = 255
	} else if (color == 7) { // white
		cl_r = 255
		cl_g = 255
		cl_b = 255
	} else if (color == 8) { // dark
		cl_r = 0
		cl_g = 0
		cl_b = 0
	} else {
		cl_r = 0
		cl_g = 0
		cl_b = 255
	}

	if (color2 == 1) { // red
		cl2_r = 255
		cl2_g = 0
		cl2_b = 0
	} else if (color2 == 2) { // green
		cl2_r = 0
		cl2_g = 255
		cl2_b = 0
	} else if (color2 == 3) { // blue
		cl2_r = 0
		cl2_g = 0
		cl2_b = 255
	} else if (color2 == 4) { // yellow
		cl2_r = 255
		cl2_g = 255
		cl2_b = 0
	} else if (color2 == 5) { // purple
		cl2_r = 255
		cl2_g = 0
		cl2_b = 255
	} else if (color2 == 6) { // sky-blue
		cl2_r = 0
		cl2_g = 255
		cl2_b = 255
	} else if (color2 == 7) { // white
		cl2_r = 255
		cl2_g = 255
		cl2_b = 255
	} else if (color2 == 8) { // dark
		cl2_r = 0
		cl2_g = 0
		cl2_b = 0
	} else {
		cl2_r = 255
		cl2_g = 0
		cl2_b = 0
	}
    /*
	if (color3 == 1) { // red
		cl3_r = 255
		cl3_g = 0
		cl3_b = 0
	} else if (color3 == 3) { // green
		cl3_r = 0
		cl3_g = 255
		cl3_b = 0
	} else if (color3 == 3) { // blue
		cl3_r = 0
		cl3_g = 0
		cl3_b = 255
	} else if (color3 == 4) { // yellow
		cl3_r = 255
		cl3_g = 255
		cl3_b = 0
	} else if (color3 == 5) { // purple
		cl3_r = 255
		cl3_g = 0
		cl3_b = 255
	} else if (color3 == 6) { // sky-blue
		cl3_r = 0
		cl3_g = 255
		cl3_b = 255
	} else if (color3 == 7) { // white
		cl3_r = 255
		cl3_g = 255
		cl3_b = 255
	} else if (color3 == 8) { // dark
		cl3_r = 0
		cl3_g = 0
		cl3_b = 0
	} else {
		cl3_r = 255
		cl3_g = 255
		cl3_b = 255
	}*/

	return PLUGIN_HANDLED
}
/*
	new lm_bag = 0

public cmd_bag(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	static arg1[32]
	read_argv(1, arg1, 31)

	new bag = str_to_num(arg1)

	if (bag == 1) {
		lm_bag = 1
	} else if (bag == 2) {
		lm_bag = 2
	} else {
		lm_bag = 0
	}

	return PLUGIN_HANDLED
} */

public CreateLaserMine_Progress(id){

	if (!CreateCheck(id))
		return PLUGIN_HANDLED
	g_settinglaser[id] = true
	//
	// Progress Bar (Activate) -- This was taken almost directly from xeroblood!
	//
	message_begin( MSG_ONE, 108, {0,0,0}, id )
	write_byte(LASER_SETUP)   // duration
	write_byte(0)   // duration
	message_end()


	new PID[1]
	PID[0] = id
	set_task(float(LASER_SETUP), "CreateLaserMine", (TASK_PLANT + id), PID, 1)

	return PLUGIN_HANDLED;
}

public StopCreateLaserMine(id)
{
	if (task_exists((TASK_PLANT + id)))
	{
		remove_task((TASK_PLANT + id))
	}
	g_settinglaser[id] = false
	standing(id)
	//
	// Progress Bar (Terminate)
	//
	message_begin(MSG_ONE, 108, {0,0,0}, id)
	write_byte(0) // duration
	write_byte(0) // duration
	message_end()

	return PLUGIN_HANDLED
}

public bool:CreateCheck(id){
	new Status = get_cvar_num( "amx_lasermine" )
	if( Status != 1  ){
		client_print(id, print_chat, "%L", LANG_PLAYER, "LM_ON")
		return false
	}

	if (is_terminator(id))
		return false

	if (g_settinglaser[id])
		return false

	if(entity_get_int(id, EV_INT_deadflag) != 0)
		return false

	if(is_user_alive(id) == 0)
		return false

	if(player_mines_count[id] >= MAX_MINES_CVAR) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "LM_MAX")
		return false
	}
	if (cs_get_user_money_ul(id) < (get_vip_flags(id) & VIP_FLAG_C ? MINE_COST/2 : MINE_COST)) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "LM_BUY", (get_vip_flags(id) & VIP_FLAG_C ? MINE_COST/2 : MINE_COST))
		return false
	}

	if (!game_started()) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "GMS_LS")
		return false
	}

	new tgt,body//,Float:vo[3],Float:to[3];
	get_user_aiming(id,tgt,body);

	new EntityName[32];
	pev(tgt, pev_classname, EntityName, 31);
	if(equali(EntityName, "player") || equali(EntityName, "lasermine")) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "WALL_LS")
		return false;
	}

	new Float:vOrigin[3]
	new Float:vAngles[3]
	new NewEnt
	new Float:MinBox[3]
	new Float:MaxBox[3]
	new Float:vNormal[3]
	new Float:vTraceDirection[3]
	new Float:vTraceEnd[3]
	new Float:vTraceResult[3]

	entity_get_vector(id, EV_VEC_origin, vOrigin)
	entity_get_vector(id, EV_VEC_v_angle, vAngles)

	NewEnt = create_entity("info_target")

	if(NewEnt == 0) {
		return false
	}

	entity_set_string(NewEnt, EV_SZ_classname, "lasermine")

	entity_set_int(NewEnt, EV_INT_movetype, 5) //5 = movetype_fly, No grav, but collides.
	entity_set_int(NewEnt, EV_INT_solid, 0)

	if (fm_get_user_team(id) == CS_TEAM_CT)
		entity_set_model(NewEnt, MINE_MDL_CT)
	else
		entity_set_model(NewEnt, MINE_MDL_T)

	entity_set_float(NewEnt, EV_FL_frame, 0.0)
	entity_set_int(NewEnt, EV_INT_body, 3)
	entity_set_int(NewEnt, EV_INT_sequence, 7) // 7 = TRIPMINE_WORLD
	entity_set_float(NewEnt, EV_FL_framerate, 0.0)

	entity_set_float(NewEnt, EV_FL_takedamage, 1.0)
	entity_set_float(NewEnt, EV_FL_dmg, 100.0)
	entity_set_float(NewEnt, EV_FL_health, float(MINE_HEALTH))

	entity_set_int(NewEnt, EV_INT_iuser2, 0) //0 Will be for inactive.


	MinBox[0] = -8.0
	MinBox[1] = -8.0
	MinBox[2] = -8.0
	MaxBox[0] = 8.0
	MaxBox[1] = 8.0
	MaxBox[2] = 8.0

	entity_set_vector(NewEnt, EV_VEC_mins, MinBox)
	entity_set_vector(NewEnt, EV_VEC_maxs, MaxBox)


	velocity_by_aim(id, 64, vTraceDirection)

	vTraceEnd[0] = vTraceDirection[0] + vOrigin[0]
	vTraceEnd[1] = vTraceDirection[1] + vOrigin[1]
	vTraceEnd[2] = vTraceDirection[2] + vOrigin[2]

	trace_line(id, vOrigin, vTraceEnd, vTraceResult)

	if(trace_normal(id, vOrigin, vTraceEnd, vNormal) == 0) {
		remove_entity(NewEnt)
		client_print(id, print_chat, "%L", LANG_PLAYER, "WALL_LS")
		g_settinglaser[id] = false
		return false
	}
	remove_entity(NewEnt)

	return true
}

public CreateLaserMine(PID[]){
	new id = PID[0]

	if (cs_get_user_money_ul(id) < (get_vip_flags(id) & VIP_FLAG_C ? MINE_COST/2 : MINE_COST)) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "LM_BUY", (get_vip_flags(id) & VIP_FLAG_C ? MINE_COST/2 : MINE_COST))
		return false
	}

	new Float:vOrigin[3]
	new Float:vAngles[3]
	entity_get_vector(id, EV_VEC_origin, vOrigin)
	entity_get_vector(id, EV_VEC_v_angle, vAngles)

	new NewEnt
	NewEnt = create_entity("func_breakable"/*"info_target"*/)

	if(NewEnt == 0) {
		return PLUGIN_HANDLED_MAIN
	}

	entity_set_string(NewEnt, EV_SZ_classname, "lasermine")

	entity_set_int(NewEnt, EV_INT_movetype, 5) //5 = movetype_fly, No grav, but collides.
	entity_set_int(NewEnt, EV_INT_solid, 0)

	if (fm_get_user_team(id) == CS_TEAM_CT)
		entity_set_model(NewEnt, MINE_MDL_CT)
	else
		entity_set_model(NewEnt, MINE_MDL_T)

	entity_set_float(NewEnt, EV_FL_frame, 0.0)
	entity_set_int(NewEnt, EV_INT_body, 3)
	entity_set_int(NewEnt, EV_INT_sequence, 7) // 7 = TRIPMINE_WORLD
	entity_set_float(NewEnt, EV_FL_framerate, 0.0)

	entity_set_float(NewEnt, EV_FL_takedamage, 1.0)
	entity_set_float(NewEnt, EV_FL_dmg, 100.0)
	entity_set_float(NewEnt, EV_FL_health, float(MINE_HEALTH))

	entity_set_int(NewEnt, EV_INT_iuser2, 0) //0 Will be for inactive.

	new Float:MinBox[3]
	new Float:MaxBox[3]
                       // 8
	MinBox[0] = -6.0
	MinBox[1] = -6.0
	MinBox[2] = -6.0
	MaxBox[0] = 6.0
	MaxBox[1] = 6.0
	MaxBox[2] = 6.0

	fm_entity_set_size(NewEnt,MinBox,MaxBox)
	entity_set_vector(NewEnt, EV_VEC_mins, MinBox)
	entity_set_vector(NewEnt, EV_VEC_maxs, MaxBox)

	new Float:vNewOrigin[3]
	new Float:vNormal[3]
	new Float:vTraceDirection[3]
	new Float:vTraceEnd[3]
	new Float:vTraceResult[3]
	new Float:vEntAngles[3]

	velocity_by_aim(id, 64, vTraceDirection)

	vTraceEnd[0] = vTraceDirection[0] + vOrigin[0]
	vTraceEnd[1] = vTraceDirection[1] + vOrigin[1]
	vTraceEnd[2] = vTraceDirection[2] + vOrigin[2]

	trace_line(id, vOrigin, vTraceEnd, vTraceResult)

	if(trace_normal(id, vOrigin, vTraceEnd, vNormal) == 0) {
		remove_entity(NewEnt)
		g_settinglaser[id] = false
		client_print(id, print_chat, "%L", LANG_PLAYER, "WALL_LS")
		return PLUGIN_HANDLED_MAIN
	}

	new tgt,body;
	get_user_aiming(id,tgt,body);

	new EntityName[32];
	pev(tgt, pev_classname, EntityName, 31);
	if(equali(EntityName, "player") || equali(EntityName, "lasermine")) {
		remove_entity(NewEnt)
		g_settinglaser[id] = false
		client_print(id, print_chat, "%L", LANG_PLAYER, "WALL_LS")
		return PLUGIN_HANDLED_MAIN;
	}

	new slot = 0;
	for (slot = 0; slot < MAX_MINES; slot++) {
		if (player_mines_ent[id][slot] == -1)
			break;
	}
	if (slot >= MAX_MINES)  //unhandled error
		return PLUGIN_HANDLED_MAIN

	player_mines_ent[id][slot] = NewEnt
	player_mines_count[id] = player_mines_count[id] + 1

	vNewOrigin[0] = vTraceResult[0] + (vNormal[0] * 6.0)
	vNewOrigin[1] = vTraceResult[1] + (vNormal[1] * 6.0)
	vNewOrigin[2] = vTraceResult[2] + (vNormal[2] * 6.0)

	entity_set_origin(NewEnt, vNewOrigin)
	vector_to_angle(vNormal, vEntAngles)

	entity_set_vector(NewEnt, EV_VEC_angles, vEntAngles)

	new Float:vBeamEnd[3]
	//new Float:vTracedBeamEnd[3]
	vBeamEnd[0] = vNewOrigin[0] + (vNormal[0] * 8192)
	vBeamEnd[1] = vNewOrigin[1] + (vNormal[1] * 8192)
	vBeamEnd[2] = vNewOrigin[2] + (vNormal[2] * 8192)
	//trace_line(-1, vNewOrigin, vBeamEnd, vTracedBeamEnd)
	//new ptr = create_tr2()
	//engfunc(EngFunc_TraceLine,vNewOrigin,vBeamEnd, IGNORE_MISSILE|IGNORE_MONSTERS|IGNORE_GLASS,NewEnt,ptr)
	//get_tr2(ptr, TR_vecEndPos, vTracedBeamEnd)
	//free_tr2(ptr)
	entity_set_vector(NewEnt, EV_VEC_vuser1, vBeamEnd)  //Traced

	emit_sound(NewEnt, CHAN_WEAPON, "weapons/mine_deploy.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(NewEnt, CHAN_VOICE, "weapons/mine_charge.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

	new args[4]
	num_to_str(NewEnt,args,4)

	entity_set_int(NewEnt, LASERMINE_INT_TEAM, int:cs_get_user_team(id))
	entity_set_int(NewEnt, LASERMINE_OWNER,id)
	//entity_set_int(NewEnt, IT_IS_LASERMINE,bool:true)
	g_settinglaser[id] = false
	cs_set_user_money_ul(id,cs_get_user_money_ul(id) - (get_vip_flags(id) & VIP_FLAG_C ? MINE_COST/2 : MINE_COST))
	//ShowAmmo(id)
	set_task(3.0, "LaserMine_Activate", 0, args, 4)

	return PLUGIN_HANDLED_MAIN
}

public task_showammo()
{

	//new ammo[51]
	//format(ammo, 50, "LaserMines: %i", MAX_MINES_CVAR - player_mines_count[id])

	set_hudmessage(_, _, _, 0.03, 0.945, _, 0.01, 1.3);
   	for(new id = 1; id <= 33; id++) {
   		if (is_user_connected(id) && is_user_alive(id) && !is_user_bot(id) && game_started())
			ShowSyncHudMsg(id, g_sync_hpdisplay, "%L",id,"LM_HUDINFO", MAX_MINES_CVAR - player_mines_count[id]);
    }
	//message_begin(MSG_ONE, g_msgStatusText, {0,0,0}, id)
	//write_byte(0)
	//write_string(ammo)
	//message_end()
	//return PLUGIN_CONTINUE
}

public LaserMine_Activate(MineID[]) {

	new EntID = str_to_num(MineID)
	new iCurrent = find_ent_by_model(-1,"lasermine",MINE_MDL_CT)
	new iCurrent2 = find_ent_by_model(-1,"lasermine",MINE_MDL_T)
	//new iCurrent = find_ent_by_model(-1,"lasermine",MINE_MDL)
	if(iCurrent == 0 && iCurrent2 == 0)
		return PLUGIN_CONTINUE

	if (!is_valid_ent(EntID))
		return PLUGIN_CONTINUE

	new id = entity_get_int(EntID, LASERMINE_OWNER)
	if ((MAX_MINES_CVAR - player_mines_count[id]) < 0) { //unhandled error
		reset_laser(id,0)
		return PLUGIN_CONTINUE
	}
    /*
	if (!is_user_zombie(id)) {
		new pmodel[64]
		cs_get_user_model(id,pmodel,63)
		if (equali(pmodel,"claire")) {
			cl_r = 255
			cl_g = 0
			cl_b = 255
		} else {
			cl_r = 0
			cl_g = 0
			cl_b = 255
		}
	}*/

	new Float:vOrigin[3]
	entity_get_vector(EntID, EV_VEC_origin, vOrigin)

	new Float:vBeamEnd[3], Float:vEnd[3], ptr = create_tr2()
	entity_get_vector(EntID, EV_VEC_vuser1, vBeamEnd)

	engfunc(EngFunc_TraceLine,vOrigin,vBeamEnd,DONT_IGNORE_MONSTERS,EntID,ptr)
	get_tr2(ptr, TR_vecEndPos, vEnd)
	free_tr2(ptr)
	new teamid = entity_get_int(EntID, LASERMINE_INT_TEAM)
	if(teamid == CS_TEAM_T){
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(0)
			write_coord(floatround(vOrigin[0]))
			write_coord(floatround(vOrigin[1]))
			write_coord(floatround(vOrigin[2]))
			write_coord(floatround(vEnd[0])) //Random
			write_coord(floatround(vEnd[1])) //Random
			write_coord(floatround(vEnd[2])) //Random
			write_short(beam)
			write_byte(lm_exa2)
			write_byte(lm_exb2)
			write_byte(life2) //Life 3
			write_byte(width2) //Width 5
			write_byte(wave2)//wave 0
			write_byte(cl2_r) // r 255
			write_byte(cl2_g) // g 0
			write_byte(cl2_b) // b 0
			write_byte(cl2_a) // 255
			write_byte(0)
			message_end()
	}else{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(0)
			write_coord(floatround(vOrigin[0]))
			write_coord(floatround(vOrigin[1]))
			write_coord(floatround(vOrigin[2]))
			write_coord(floatround(vEnd[0])) //Random
			write_coord(floatround(vEnd[1])) //Random
			write_coord(floatround(vEnd[2])) //Random
			write_short(beam)
			write_byte(lm_exa)
			write_byte(lm_exb)
			write_byte(life) //Life
			write_byte(width) //Width
			write_byte(wave)//wave
			write_byte(cl_r) // r
			write_byte(cl_g) // g
			write_byte(cl_b) // b
			write_byte(cl_a)
			write_byte(0)
			message_end()
	}
	entity_set_int(EntID, EV_INT_iuser2, 1) //1 Will be for active.
	entity_set_int(EntID, EV_INT_solid, 2) //1 Will be for active.
	if(teamid == CS_TEAM_CT)
    	set_rendering(EntID, kRenderFxGlowShell, cl_r, cl_g, cl_b, kRenderNormal, 1);
	else
		set_rendering(EntID, kRenderFxGlowShell, cl2_r, cl2_g, cl2_b, kRenderNormal, 1);

	emit_sound(EntID, CHAN_VOICE, "weapons/mine_activate.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	return PLUGIN_CONTINUE
}
/*
public LaserMineSparks() {

	if(get_cvar_num( "amx_lasermine" ) != 1)
		return PLUGIN_HANDLED

	new iCurrent
	iCurrent = find_ent_by_class(-1, "lasermine")
	while(iCurrent != 0){
		if(entity_get_int(iCurrent, EV_INT_iuser2) == 1){

			new Float:health[1]
			health[0] = entity_get_float(iCurrent, EV_FL_health)

			new Float:vOrigin[3]
			entity_get_vector(iCurrent, EV_VEC_origin, vOrigin)

			if (health[0]>0 && health[0] <= 75) {
				engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0)
				write_byte(TE_SPARKS) // TE id
				engfunc(EngFunc_WriteCoord, vOrigin[0]) // x
				engfunc(EngFunc_WriteCoord, vOrigin[1]) // y
				engfunc(EngFunc_WriteCoord, vOrigin[2]) // z
				message_end()
			}

		}
	}
	return PLUGIN_CONTINUE
}*/

public LaserMineThink() {
	if(get_cvar_num( "amx_lasermine" ) != 1)
		return PLUGIN_HANDLED

	new iCurrent
	iCurrent = find_ent_by_class(-1, "lasermine")
	while(iCurrent != 0) {
		if(entity_get_int(iCurrent, EV_INT_iuser2) == 1) {
			new Float:vOrigin[3]
			entity_get_vector(iCurrent, EV_VEC_origin, vOrigin)

			new Float:vEnd[3]
			entity_get_vector(iCurrent, EV_VEC_vuser1, vEnd)

			new Float:vTrace[3]
			new iHit
			iHit = trace_line(iCurrent, vOrigin, vEnd, vTrace)

			new Float:health[1]
			health[0] = entity_get_float(iCurrent, EV_FL_health)

			new teamid = entity_get_int(iCurrent, LASERMINE_INT_TEAM)

			if (iHit > 0 && health[0] > 0) {
				new szClassName[32]
				entity_get_string(iHit, EV_SZ_classname, szClassName, 32)
				if (equali(szClassName,"lasermine")&&fm_entity_range(iCurrent,iHit)<=18.0) {
					new player = entity_get_int(iHit,LASERMINE_OWNER)
					update_mines(player,iHit)
					remove_entity(iHit)
					if ( is_user_alive(player) )
						cs_set_user_money_ul(player,cs_get_user_money_ul(player) + (get_vip_flags(player) & VIP_FLAG_C ? MINE_COST/2 : MINE_COST))
					else
						cs_set_user_money_ul(player,cs_get_user_money_ul(player) + (get_vip_flags(player) & VIP_FLAG_C ? floatround(MINE_COST/2 * 0.3) : floatround(MINE_COST * 0.3)))
				}
			}

			if (health[0] <= 0) {
				//detonate_mine(iCurrent,-1)
				remove_entity(iCurrent)
			}else{

				if(!game_started())
					return PLUGIN_CONTINUE

				if(iHit > 0 ) {
					new szClassName[32]
					entity_get_string(iHit, EV_SZ_classname, szClassName, 32)
					if(equal(szClassName, "player")){
						if(is_user_alive(iHit) && !get_user_godmode(iHit) && !spawn_protect(iHit) && !is_terminator(iHit)){
							new iHitTeam = int:cs_get_user_team(iHit)
							new iHitHP = get_user_health(iHit) - LASER_HIT_DMG
							new id = entity_get_int(iCurrent,LASERMINE_OWNER)//, szNetName[32]
							if(iHitHP <= 0){
								new hitscore
								if (get_cvar_num("mp_friendlyfire") == 0){
									if(iHitTeam != teamid){
										if (iHit != id)
											hitscore = 1
										else
											hitscore = 0
										if (iHit != id) cs_set_user_money_ul(id,cs_get_user_money_ul(id) + FRAGMONEY)
										//set_user_health(iHit, 0)
										//entity_set_float(iHit, EV_FL_health,0.0)
										emit_sound(iHit, CHAN_WEAPON, "debris/beamstart9.wav", 1.0, ATTN_NORM, 0, PITCH_NORM )
										set_score(id,iHit,hitscore,iHitHP)
										//entity_get_string(iHit, EV_SZ_netname, szNetName, 32)
									}
								}else{
									if(iHitTeam != teamid){
										hitscore = 1
										cs_set_user_money_ul(id,cs_get_user_money_ul(id) + FRAGMONEY)
									}else{
										hitscore = -1
										cs_set_user_money_ul(id,cs_get_user_money_ul(id) - FRAGMONEY)
									}
									//set_user_health(iHit, 0)
									//entity_set_float(iHit, EV_FL_health, 0.0)
									emit_sound(iHit, CHAN_WEAPON, "debris/beamstart9.wav", 1.0, ATTN_NORM, 0, PITCH_NORM )
									set_score(id,iHit,hitscore,iHitHP)
									//entity_get_string(iHit, EV_SZ_netname, szNetName, 32)
									//client_print(id, print_chat, "KILLED_LS2",szNetName)
								}
							}else{
								if (get_cvar_num("mp_friendlyfire") == 0){
									if(iHitTeam != teamid){
								set_user_health(iHit, iHitHP)
								message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, {0,0,0}, iHit)
								write_byte(LASER_HIT_DMG)
								write_byte(LASER_HIT_DMG)
								write_long(DMG_BULLET)
								write_coord(floatround(vOrigin[0]))
								write_coord(floatround(vOrigin[1]))
								write_coord(floatround(vOrigin[2]))
								message_end()
									}
								} else {
								set_user_health(iHit, iHitHP)
								message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, {0,0,0}, iHit)
								write_byte(LASER_HIT_DMG)
								write_byte(LASER_HIT_DMG)
								write_long(DMG_BULLET)
								write_coord(floatround(vOrigin[0]))
								write_coord(floatround(vOrigin[1]))
								write_coord(floatround(vOrigin[2]))
								message_end()
								}
							}
						}
					}
				}
			}
		}

		iCurrent =  find_ent_by_class(iCurrent, "lasermine")
	}
	return PLUGIN_CONTINUE
}

public LaserMine_LaserThink() {
	if(get_cvar_num( "amx_lasermine" ) != 1  )
		return PLUGIN_HANDLED

	new iCurrent
	iCurrent = find_ent_by_class(-1, "lasermine")
	while(iCurrent != 0){
		if(entity_get_int(iCurrent, EV_INT_iuser2) == 1){

			new Float:vOrigin[3]
			entity_get_vector(iCurrent, EV_VEC_origin, vOrigin)

			new Float:vBeamEnd[3], Float:vEnd[3], ptr = create_tr2()
			entity_get_vector(iCurrent, EV_VEC_vuser1, vBeamEnd)

			engfunc(EngFunc_TraceLine,vOrigin,vBeamEnd,DONT_IGNORE_MONSTERS,iCurrent,ptr)
			get_tr2(ptr, TR_vecEndPos, vEnd)
			free_tr2(ptr)

			new teamid = entity_get_int(iCurrent, LASERMINE_INT_TEAM)    /*
			client_print(0,print_chat,"or 0 %d| 1 %d| 2 %d",floatround(vOrigin[0]),floatround(vOrigin[1]),floatround(vOrigin[2]))
            client_print(0,print_chat,"ve 0 %d| 1 %d| 2 %d",floatround(vTracedBeamEnd[0]),floatround(vTracedBeamEnd[1]),floatround(vTracedBeamEnd[2]))
            client_print(0,print_chat,"ve2 0 %d| 1 %d| 2 %d",floatround(vEntAngles[0]),floatround(vEntAngles[1]),floatround(vEntAngles[2]))  */
			if(teamid == CS_TEAM_T){
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(0)
				write_coord(floatround(vOrigin[0]))
				write_coord(floatround(vOrigin[1]))
				write_coord(floatround(vOrigin[2]))
				write_coord(floatround(vEnd[0])) //Random
				write_coord(floatround(vEnd[1])) //Random
				write_coord(floatround(vEnd[2])) //Random
				write_short(beam)
				write_byte(lm_exa2)
				write_byte(lm_exb2)
				write_byte(life2) //Life 3
				write_byte(width2) //Width 5
				write_byte(wave2)//wave 0
				write_byte(cl2_r) // r 255
				write_byte(cl2_g) // g 0
				write_byte(cl2_b) // b 0
				write_byte(cl2_a) // 255
				write_byte(0)
				message_end()
				//client_print(0,print_chat,"0 %d| 1 %d| 2 %d",floatround(vEnd[0]),floatround(vEnd[1]),floatround(vEnd[2]))
			}else{
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(0)
				write_coord(floatround(vOrigin[0]))
				write_coord(floatround(vOrigin[1]))
				write_coord(floatround(vOrigin[2]))
				write_coord(floatround(vEnd[0])) //Random
				write_coord(floatround(vEnd[1])) //Random
				write_coord(floatround(vEnd[2])) //Random
				write_short(beam)
				write_byte(lm_exa)
				write_byte(lm_exb)
				write_byte(life) //Life
				write_byte(width) //Width
				write_byte(wave)//wave
				write_byte(cl_r) // r
				write_byte(cl_g) // g
				write_byte(cl_b) // b
				write_byte(cl_a)
				write_byte(0)
				message_end()
			}
		}
		iCurrent =  find_ent_by_class(iCurrent, "lasermine")
	}
	return PLUGIN_CONTINUE
}

public set_score(id,target,hitscore,HP){

//	entity_set_float(id, EV_FL_frags, entity_get_float(id, EV_FL_frags) + hitscore)
//	entity_set_float(target, EV_FL_frags, entity_get_float(target, EV_FL_frags) + 1.0)

	//if (lm_bag == 2)
	//	return PLUGIN_HANDLED

	new idfrags = get_user_frags(id) + hitscore
	set_user_frags(id, idfrags)

	new tarfrags = get_user_frags(target) + 1
	set_user_frags(target,tarfrags)

	new idteam = int:cs_get_user_team(id)
	new iddeaths = get_user_deaths(id)

	if (is_user_alive(id) && !is_user_zombie(id)) {
		if (user_has_weapon(id,CSW_HEGRENADE)) {
			if (cs_get_user_bpammo(id, CSW_HEGRENADE)<3) {
				cs_set_user_bpammo( id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE)+1 )
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "AmmoPickup" ), _, id );
				write_byte( 12 );
				write_byte( 1 );
				message_end();
				emit_sound( id, CHAN_ITEM, G_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			}
		} else
			give_item(id,"weapon_hegrenade")
	}

	message_begin(MSG_ALL, g_msgDeathMsg, {0, 0, 0} ,0)
	write_byte(id)
	write_byte(target)
	write_byte(0)
	write_string("lasermine")
	message_end()

	message_begin(MSG_ALL, g_msgScoreInfo)
	write_byte(id)
	write_short(idfrags)
	write_short(iddeaths)
	write_short(0)
	write_short(idteam)
	message_end()

	set_msg_block(g_msgDeathMsg, BLOCK_ONCE)

	//entity_set_float(target, EV_FL_health,float(HP))
	set_user_health(target, HP)

	return PLUGIN_CONTINUE

}

public standing(id) {
	if (!g_settinglaser[id])
		return PLUGIN_CONTINUE

	entity_set_float(id, EV_FL_maxspeed, 1.0)
//	ShowAmmo(id)

	return PLUGIN_CONTINUE
}

public client_PostThink(id) {
	if (!g_settinglaser[id] && plsetting[id]){
		resetspeed(id)
	}
	else if (g_settinglaser[id] && !plsetting[id]) {
		cs_set_user_zoom(id,0,0)
		//plspeed[id] = entity_get_float(id, EV_FL_maxspeed)
		entity_set_float(id, EV_FL_maxspeed, 1.0)
	}
	plsetting[id] = g_settinglaser[id]
	return PLUGIN_CONTINUE
}

public resetspeed(id) {

	if (!is_user_alive(id))
		return

	new Float:drugspeed

	if (check_speed(id) != 0.0) {
		drugspeed = Float:check_speed(id)
	} else {
		drugspeed = 0.0
	}

	if (is_user_zombie(id)) {
		entity_set_float(id, EV_FL_maxspeed, get_class_data(get_user_class(id), DATA_SPEED)+drugspeed)
	} else {
	cs_set_user_zoom(id,0,0)
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
	}
	//user_speed[id] = weapon
	entity_set_float(id, EV_FL_maxspeed, weapon+drugspeed)

	}
	return

	//entity_set_float(id, EV_FL_maxspeed, plspeed[who])
}

public client_connect(id){
	new j
	for (j=0;j<MAX_MINES;j++) {
		player_mines_ent[id][j] = -1
		player_mines_count[id] = 0
	}
	g_settinglaser[id] = false
	return PLUGIN_CONTINUE
}

public client_disconnect(id){
	if(get_cvar_num( "amx_lasermine" ) != 1  )
		return PLUGIN_CONTINUE

	reset_laser(id,0)
	g_settinglaser[id] = false
	return PLUGIN_CONTINUE
}

public newround() {
	if(get_cvar_num( "amx_lasermine" ) != 1 || game_started())
		return PLUGIN_CONTINUE

	for(new i = 1; i < 33; i++) {
		if (is_user_connected(i)) {
			reset_laser(i,0)
			g_settinglaser[i] = false
		}
	}
	//reset_laser(id,0)
	//g_settinglaser[id] = false

	return PLUGIN_CONTINUE
}


public DeathEvent(){
	if(get_cvar_num( "amx_lasermine" ) != 1  )
		return PLUGIN_CONTINUE

	//new mhours[6]
	//get_time("%H", mhours, 5)
	//new hrs = str_to_num(mhours)

	new id = read_data(2)

	if (task_exists(id))
		remove_task(id)
	plspeed[id] = entity_get_float(id, EV_FL_maxspeed)
	//if (hrs >= 23 || hrs < 6)
	//	reset_laser(id,0)
	g_settinglaser[id] = false
	set_task(0.1,"LaserMenuReset",id)

	return PLUGIN_CONTINUE
}

public reset_laser(id,cost){
	if(get_cvar_num( "amx_lasermine" ) != 1  )
		return PLUGIN_CONTINUE

	new j, iCurrent
	player_mines_count[id] = 0

	for (j=0;j<MAX_MINES;j++) {
		if (player_mines_ent[id][j] != -1) {

			iCurrent = player_mines_ent[id][j]

			new Float:vOrigin[3]
			entity_get_vector(iCurrent, EV_VEC_origin, vOrigin)

			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(99) //99 = KillBeam
			write_short(iCurrent)
			message_end()
			remove_entity(iCurrent)
			LaserMine_LaserThink()

			player_mines_ent[id][j] = -1
			if (cost == 1) {
				new mcost = MINE_COST / 2
				if ( is_user_alive(id) )
					cs_set_user_money_ul(id,cs_get_user_money_ul(id) + (get_vip_flags(id) & VIP_FLAG_C ? mcost/2 : mcost))
				else
					cs_set_user_money_ul(id,cs_get_user_money_ul(id) + (get_vip_flags(id) & VIP_FLAG_C ? floatround(MINE_COST/2 * 0.3) : floatround(MINE_COST * 0.3)))
			}
  		}
	}

	if (task_exists(id))
		remove_task(id)

	return PLUGIN_CONTINUE
}

	/*
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(3)
			write_coord(floatround(vOrigin[0]))
			write_coord(floatround(vOrigin[1]))
			write_coord(floatround(vOrigin[2]))
			write_short(boom)
			write_byte(50)
			write_byte(15)
			write_byte(0)
			message_end()

			radius_damage(vOrigin, 1, 50)
	*/

public check_cvars(){
	if (get_cvar_num("amx_lasermine_ammo") > 10000) {
		server_print("[Lasermines] amx_lasermine_ammo can't be greater than 10, setting cvar to 10 now.")
		set_cvar_num("amx_lasermine_ammo", 10000)
	}
	if (get_cvar_num("amx_lasermine_ammo") < 1) {
		server_print("[Lasermines] amx_lasermine_ammo can't be less than 1, setting cvar to 1 now.")
		set_cvar_num("amx_lasermine_ammo", 1)
	}
	if (get_cvar_num("amx_lasermine_health") > 800){
		server_print("[Lasermines] amx_lasermine_health can't be greater than 800, setting cvar to 800 now.")
		set_cvar_num("amx_lasermine_health", 800)
	}
	if (get_cvar_num("amx_lasermine_health") < 1) {
		server_print("[Lasermines] amx_lasermine_health can't be less than 1, setting cvar to 1 now.")
		set_cvar_num("amx_lasermine_health", 1)
	}
	if (get_cvar_num("amx_lasermine_cost") > 16000){
		server_print("[Lasermines] amx_lasermine_cost can't be greater than 16000, setting cvar to 16000 now.")
		set_cvar_num("amx_lasermine_cost", 16000)
	}
	if (get_cvar_num("amx_lasermine_cost") < 0) {
		server_print("[Lasermines] amx_lasermine_cost can't be less than 100, setting cvar to 100 now.")
		set_cvar_num("amx_lasermine_cost", 0)
	}
	if (get_cvar_num("amx_lasermine_dmg") < 1) {
		server_print("[Lasermines] amx_lasermine_dmg can't be less than 1, setting cvar to 1 now.")
		set_cvar_num("amx_lasermine_dmg", 1)
	}
	if (get_cvar_num("amx_lasermine_fragmoney") < 100) {
		server_print("[Lasermines] amx_lasermine_dmg can't be less than 100, setting cvar to 100 now.")
		set_cvar_num("amx_lasermine_dmg", 100)
	}

	MAX_MINES_CVAR = get_cvar_num("amx_lasermine_ammo")
	FRAGMONEY = get_cvar_num("amx_lasermine_fragmoney")
	MINE_COST = get_cvar_num("amx_lasermine_cost")
	MINE_HEALTH = get_cvar_num("amx_lasermine_health")
	LASER_HIT_DMG = get_cvar_num("amx_lasermine_dmg")

	LASER_SETUP = get_cvar_num("amx_lasermine_setup")

	//g_xtime = get_cvar_num("amx_lasermine_xtime")
	//g_kill_bonus = get_cvar_num("amx_lasermine_kill")
	//g_kill_hbonus = get_cvar_num("amx_lasermine_hkill")
	//g_kill_minus = get_cvar_num("amx_lasermine_dkill")
	//g_kill_hminus = get_cvar_num("amx_lasermine_dhkill")
	/*LM_R = get_cvar_num("amx_lm_r")
	LM_G = get_cvar_num("amx_lm_g")
	LM_B = get_cvar_num("amx_lm_b")
	LM_R2 = get_cvar_num("amx_lm_r2")
	LM_G2 = get_cvar_num("amx_lm_g2")
	LM_B2 = get_cvar_num("amx_lm_b2") */

}

public server_changelevel(map[]){

	MAX_MINES_CVAR = get_cvar_num("amx_lasermine_ammo")
	FRAGMONEY = get_cvar_num("amx_lasermine_fragmoney")
	MINE_COST = get_cvar_num("amx_lasermine_cost")
	MINE_HEALTH = get_cvar_num("amx_lasermine_health")
	LASER_HIT_DMG = get_cvar_num("amx_lasermine_dmg")

	LASER_SETUP = get_cvar_num("amx_lasermine_setup")

	//g_xtime = get_cvar_num("amx_lasermine_xtime")
	//g_kill_bonus = get_cvar_num("amx_lasermine_kill")
	//g_kill_hbonus = get_cvar_num("amx_lasermine_hkill")
	//g_kill_minus = get_cvar_num("amx_lasermine_dkill")
	//g_kill_hminus = get_cvar_num("amx_lasermine_dhkill")
	/*LM_R = get_cvar_num("amx_lm_r")
	LM_G = get_cvar_num("amx_lm_g")
	LM_B = get_cvar_num("amx_lm_b")
	LM_R2 = get_cvar_num("amx_lm_r2")
	LM_G2 = get_cvar_num("amx_lm_g2")
	LM_B2 = get_cvar_num("amx_lm_b2")
	BAG = get_cvar_num("amx_lm_bag")
	BAG2 = get_cvar_num("amx_lm_bag2")*/

}

public plugin_precache() {
	precache_sound("weapons/mine_deploy.wav")
	precache_sound("weapons/mine_charge.wav")
	precache_sound("weapons/mine_activate.wav")
	precache_sound("debris/beamstart9.wav")
	precache_sound("debris/glass2.wav")
	precache_sound("debris/glass1.wav")
	precache_model(MINE_MDL_CT)
	precache_model(MINE_MDL_T)
	beam = precache_model("sprites/laserbeam.spr")
	boom = precache_model("sprites/zerogxplode.spr")
	precache_sound( G_PICKUP_SND );

	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin("LaserMine Entity","1.1","AlexALX/+ARUKARI-")
	register_dictionary("lasermine.txt")

	register_clcmd("+setlaser","CreateLaserMine_Progress")
	register_clcmd("-setlaser","StopCreateLaserMine")

	register_clcmd("+dellaser","del_info")
	register_clcmd("-dellaser","del_info")

	register_clcmd("say /lm","lm_info")
	register_clcmd("say lm","lm_info")

	register_clcmd("say /lminfo","ReturnCheck")
	register_clcmd("say lminfo","ReturnCheck")
	register_clcmd("say /lm_info","ReturnCheck")
	register_clcmd("say lm_info","ReturnCheck")
	register_clcmd("say /lmi","ReturnCheck")
	register_clcmd("say lmi","ReturnCheck")
	register_clcmd("/lminfo","ReturnCheck")
	register_clcmd("lminfo","ReturnCheck")
	register_clcmd("/lm_info","ReturnCheck")
	register_clcmd("lm_info","ReturnCheck")
	register_clcmd("/lmi","ReturnCheck")
	register_clcmd("lmi","ReturnCheck")

	register_concmd("say /del_lm", "resetlaser")
	register_concmd("say /dellm", "resetlaser")
	register_concmd("say resetlm", "resetlaser")
	register_concmd("say reset_lm", "resetlaser")
	register_concmd("say del_lm", "resetlaser")
	register_concmd("say dellm", "resetlaser")
	register_concmd("say /resetlm", "resetlaser")
	register_concmd("say /resetlaser", "resetlaser")
	register_concmd("say resetlaser", "resetlaser")
	register_concmd("say /reset_lm", "resetlaser")
	register_concmd("/resetlaser", "resetlaser")
	register_concmd("resetlaser", "resetlaser")
    /*
	register_concmd("say /ex_lm", "explodelaser")
	register_concmd("say /exlm", "explodelaser")
	register_concmd("say exlm", "explodelaser")
	register_concmd("say ex_lm", "explodelaser")
	register_concmd("say /explode_lm", "explodelaser")
	register_concmd("say /explode_laser", "explodelaser")
	register_concmd("say explodelaser", "explodelaser")
	register_concmd("say /explodelm", "explodelaser")
	register_concmd("/explodelaser", "explodelaser")
	register_concmd("explodelaser", "explodelaser")
	register_concmd("/exlm", "explodelaser")
	register_concmd("exlm", "explodelaser")
    */
	register_concmd("amx_rl", "cmd_reset", ADMIN_LEVEL_A, "<nick or #userid or @all>")
	register_concmd("amx_resetlaser", "cmd_reset", ADMIN_LEVEL_A, "<nick or #userid or @all>")
	register_concmd("amx_lmcolor", "cmd_color", ADMIN_LEVEL_A, "<ct> <t>")
	register_concmd("amx_lmwave", "cmd_wave", ADMIN_LEVEL_A, "<ct> <t>")
	register_concmd("amx_lmlife", "cmd_life", ADMIN_LEVEL_A, "<ct> <t>")
	register_concmd("amx_lmwidth", "cmd_width", ADMIN_LEVEL_A, "<ct> <t>")
	register_concmd("amx_lmalpha", "cmd_a", ADMIN_LEVEL_A, "<ct> <t>")
	register_concmd("amx_lmexa", "cmd_exa", ADMIN_LEVEL_A, "<ct> <t>")
	register_concmd("amx_lmexb", "cmd_exb", ADMIN_LEVEL_A, "<ct> <t>")
	//register_concmd("amx_lmbag", "cmd_bag", ADMIN_LEVEL_A)
	register_concmd("amx_el", "cmd_explode", ADMIN_LEVEL_A, "<nick or #userid or @all>")
	register_concmd("amx_explode", "cmd_explode", ADMIN_LEVEL_A, "<nick or #userid or @all>")
	//RegisterHam(Ham_Think, "func_breakable", "Minekill")

	register_cvar( "amx_lasermine", "1", FCVAR_UNLOGGED )

	register_event("DeathMsg", "DeathEvent", "a")
	register_event("CurWeapon", "standing", "be", "1=1")
	register_event("ResetHUD", "newround", "bc")
	register_cvar("amx_lasermine_ammo","2")
	register_cvar("amx_lasermine_dmg","10000")
	register_cvar("amx_lasermine_cost","500")
	register_cvar("amx_lasermine_fragmoney","300")
	register_cvar("amx_lasermine_health","500")
	register_cvar("amx_lasermine_setup","2.0")

	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgDamage = get_user_msgid("Damage")
	//g_msgStatusText = get_user_msgid("StatusText")

	register_menucmd( register_menuid( "Lasermine" ), KEYS_M, "menu_shop" )
	register_menucmd( register_menuid( "Resetlaser" ), KEYS_M, "menu_shop_reset" )

	set_task(0.02, "LaserMineThink", 0, "", 0, "b")
	set_task(0.02, "LaserMine_LaserThink", 0, "", 0, "b")
	//set_task(2.0, "LaserMineSparks", 0, "", 0, "b")
	set_task(5.0,"check_cvars",0,"",0,"b")
	g_sync_hpdisplay = CreateHudSyncObj()

	RegisterHam(Ham_TakeDamage, "func_breakable", "hTakeDamage")
	//RegisterHam(Ham_Killed, "func_breakable", "lKilled")

	set_task(0.5, "task_showammo", _, _, _, "b")

	return PLUGIN_CONTINUE
}

public del_info(id) {
 	if(get_cvar_num( "amx_lasermine" ) != 1  )
		return PLUGIN_HANDLED_MAIN

	client_print(id, print_chat, "%L", LANG_PLAYER, "LM_DELINFO")
	client_print(id, print_chat, "%L", LANG_PLAYER, "LM_DELINFO2")
	return PLUGIN_CONTINUE
}

public lm_info(id) {
 	if(get_cvar_num( "amx_lasermine" ) != 1  )
		return PLUGIN_HANDLED_MAIN

	client_print(id, print_chat, "%L", LANG_PLAYER, "LM_NOTBUYS")

	static motd[2048]
	formatex(motd, 2047, "<html><head><title>LaserMine</title><style type='text/css'>pre{font-family:Verdana,Tahoma;color:#FFFFFF;}body{background:#000000;margin-left:8px;margin-top:0px;}a{text-decoration:underline;color:#FFFFFF;}</style><meta http-equiv='Content-Type' content='text/html; charset=utf-8'></head><body scroll='no'><pre><b><span style='font-size: 16pt; color: red' align='center'>%L</span></b></pre></body></html>", id, "LM_NOTBUYS2");

	show_motd(id, motd, "LaserMine");

	return PLUGIN_CONTINUE
}

/*
public explodelaser(id) {
 	if(get_cvar_num( "amx_lasermine" ) != 1  )
		return PLUGIN_HANDLED_MAIN

	if (!game_started()) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "GMS_LS")
		return PLUGIN_HANDLED_MAIN
	}

	//new mcost = MINE_COST / 2
	//cs_set_user_money_ul(id,cs_get_user_money_ul(id) + mcost)
	new mhours[6]
	get_time("%H", mhours, 5)
	new hrs = str_to_num(mhours)
	if (hrs >= 23 || hrs < 6) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "X_TIME_RESET")
		return PLUGIN_CONTINUE
	} else {
		client_print(id, print_chat, "%L", LANG_PLAYER, "EXP_LS")
		new iCurrent
		while((iCurrent = find_ent_by_class(iCurrent, "lasermine")) != 0) {
			if(entity_get_int(iCurrent,LASERMINE_OWNER) == id) detonate_mine(iCurrent, -2)
		}
	}

	return PLUGIN_CONTINUE

}

public event_infect(id) {
	reset_laser(id,1)
}*/

public resetlaser(id) {
 	if(get_cvar_num( "amx_lasermine" ) != 1  )
		return PLUGIN_CONTINUE

	if (!game_started()) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "GMS_LS")
		return PLUGIN_HANDLED_MAIN
	}

	//new mcost = MINE_COST / 2
	//cs_set_user_money_ul(id,cs_get_user_money_ul(id) + mcost)
	new mhours[6]
	get_time("%H", mhours, 5)
	new hrs = str_to_num(mhours)
	if (((hrs >= 23 || hrs < 6) || get_pcvar_num(g_xtime) == 2) && get_pcvar_num(g_xtime)) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "X_TIME_RESET")
		return PLUGIN_CONTINUE
	} else {
		if (native_lm_count(id)!=0) {
			client_print(id, print_chat, "%L", LANG_PLAYER, "SOLD_LS")
			reset_laser(id,1)
		} else {
			client_print(id, print_chat, "%L", LANG_PLAYER, "NSOLD_LS")
		}
	}

	return PLUGIN_CONTINUE

}

public cmd_explode(id, level, cid)
{

 	if(get_cvar_num( "amx_lasermine" ) != 1  )
		return PLUGIN_HANDLED_MAIN

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	if (!game_started()) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "GMS_LS")
		return PLUGIN_HANDLED_MAIN
	}

	static arg1[32]
	read_argv(1, arg1, 31)

	if(arg1[0] == '@') {
		if(equali(arg1[1],"ALL")) {
				new authid[32], name[32]
				get_user_authid(id, authid, 31)
				get_user_name(id, name, 31)

				new iCurrent
				while((iCurrent = find_ent_by_class(iCurrent, "lasermine")) != 0) {
					set_msg_block(g_msgDeathMsg, BLOCK_SET)
					detonate_mine(iCurrent, id)
					set_msg_block(g_msgDeathMsg, BLOCK_NOT)
					RemoveEntity(iCurrent)
					LaserMineThink()
				}

				log_amx("Laser: ^"%s<%d><%s><>^" explode all lasers", name, get_user_userid(id), authid)

				show_activity_key("TEXT2EB", "TEXT2EC", name)
		}
	} else {

	static target
	target = cmd_target(id, arg1, (CMDTARGET_ALLOW_SELF))

	if(!is_user_connected(target))
		return PLUGIN_HANDLED_MAIN

	/*
	if(!game_started())
	{
		console_print(id, "CMD_GAMENOTSTARTED")
		return PLUGIN_HANDLED_MAIN
	}*/

	new iCurrent
	while((iCurrent = find_ent_by_class(iCurrent, "lasermine")) != 0) {
		if(entity_get_int(iCurrent,LASERMINE_OWNER) == target) {
			set_msg_block(g_msgDeathMsg, BLOCK_SET)
			detonate_mine(iCurrent, id)
			set_msg_block(g_msgDeathMsg, BLOCK_NOT)
			RemoveEntity(iCurrent)
			LaserMineThink()
		}
	}

	new authid[32], authid2[32], name2[32], name[32], userid2, player = target

	get_user_authid(id, authid, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(player, name2, 31)
	get_user_name(id, name, 31)
	userid2 = get_user_userid(player)

	log_amx("Laser: ^"%s<%d><%s><>^" explode lasers ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)

	show_activity_key("TEXT2E", "TEXT2EA", name, name2)

	}

	return PLUGIN_HANDLED
}
/*
public cmd_explode(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN
	new iCurrent
	while((iCurrent = find_ent_by_class(iCurrent, "lasermine")) != 0) {
			detonate_mine(iCurrent, -1)
	}

	return PLUGIN_CONTINUE

} */

public ReturnCheck( id )
{

 	if(get_cvar_num( "amx_lasermine" ) != 1  )
		return PLUGIN_HANDLED_MAIN

	new tgt,body//,Float:vo[3],Float:to[3];
	get_user_aiming(id,tgt,body);
	if(!pev_valid(tgt)) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "LM_OWNER2")
		return PLUGIN_HANDLED;
	}
	//pev(id,pev_origin,vo);
	//pev(tgt,pev_origin,to);
	//if(get_distance_f(vo,to) > 70.0)
	//	return PLUGIN_HANDLED;

	new EntityName[32];
	pev(tgt, pev_classname, EntityName, 31);
	if(!equal(EntityName, ENT_CLASS_NAME)) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "LM_OWNER2")
		return PLUGIN_HANDLED;
	}

	new name[32], ip[32], authid[32]
	new player = entity_get_int(tgt,LASERMINE_OWNER)

	get_user_name(player, name, 31)
	get_user_ip(player, ip, 31, 1)
	get_user_authid(player, authid, 31)

	client_print(id, print_chat, "%L", LANG_PLAYER, "LM_OWNER", name)

	if (!access(player, ADMIN_KICK) || access(id, ADMIN_KICK) || player == id) {
		client_print(id, print_chat, "[LaserMines] IP: %s STEAMID: %s", ip, authid)
	}

	if (access(id, ADMIN_LEVEL_A))
		LaserMenu(id,tgt)

	return PLUGIN_CONTINUE;
}

new ent_menu[33]

public LaserMenu( id , ent)
{

	if(!access(id, ADMIN_LEVEL_A) || !pev_valid(ent))
		return PLUGIN_HANDLED_MAIN

	ent_menu[id] = 0

	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "%L", id, "LM_MENU01" );
	new menu = menu_create( szText, "menu_shop" )

	formatex( szText, charsmax( szText ), "%L", id, "LM_MENU02");
	menu_additem( menu, szText, "1", ADMIN_KICK );

	formatex( szText, charsmax( szText ), "%L", id, "LM_MENU03");
	menu_additem( menu, szText, "2", ADMIN_KICK );

	formatex( szText, charsmax( szText ), "%L", id, "LM_MENU04");
	menu_additem( menu, szText, "3", ADMIN_KICK );

	formatex( szText, charsmax( szText ), "%L", id, "LM_MENU05");
	menu_additem( menu, szText, "4", ADMIN_KICK );

	menu_addblank(menu,0)

	new name[32], ip[32], authid[32]

	new player = entity_get_int(ent,LASERMINE_OWNER)

	get_user_name(player, name, 31)
	get_user_ip(player, ip, 31, 1)
	get_user_authid(id, authid, 31)

	formatex( szText, charsmax( szText ), "\r%L\y %s", id, "LM_MENU06", name);
	menu_addtext(menu,szText,0)

	formatex( szText, charsmax( szText ), "\r%L\y %s", id, "LM_MENU07", ip);
	menu_addtext(menu,szText,0)

	formatex( szText, charsmax( szText ), "\r%L\y %s", id, "LM_MENU08", authid);
	menu_addtext(menu,szText,0)

	menu_addblank(menu,0)

	formatex( szText, charsmax( szText ), "%L", id, "LM_MENUEX");
	menu_additem( menu, szText, "0", ADMIN_KICK );

	menu_setprop( menu, MPROP_PERPAGE, 0);

	ent_menu[id] = ent
	menu_display( id, menu, 0 );

	return PLUGIN_CONTINUE;

}

public menu_shop( id, menu, item )
{

	if(!access(id, ADMIN_LEVEL_A) || !pev_valid(ent_menu[id]))
		return PLUGIN_HANDLED_MAIN

	new data[ 6 ], iName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

	new key = str_to_num( data );
	new ent = ent_menu[id]

	switch( key )
	{
		case 1:
		{
			new player = entity_get_int(ent,LASERMINE_OWNER)

			new mcost = MINE_COST / 2
			if ( is_user_alive(player) )
				cs_set_user_money_ul(player,cs_get_user_money_ul(player) + (get_vip_flags(player) & VIP_FLAG_C ? mcost/2 : mcost))
			else
				cs_set_user_money_ul(player,cs_get_user_money_ul(player) + (get_vip_flags(player) & VIP_FLAG_C ? floatround(MINE_COST/2 * 0.3) : floatround(MINE_COST * 0.3)))

			new authid[32], authid2[32], name2[32], name[32], userid2

			remove_entity(ent)
			update_mines(player,ent)
			LaserMineThink()

			get_user_authid(id, authid, 31)
			get_user_authid(player, authid2, 31)
			get_user_name(player, name2, 31)
			get_user_name(id, name, 31)
			userid2 = get_user_userid(player)

			log_amx("Laser: ^"%s<%d><%s><>^" unset laser(s) ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)

			show_activity_key("TEXT1", "TEXT2", name, name2)
			menu_destroy( menu );
		}
		case 2:
		{
			new player = entity_get_int(ent,LASERMINE_OWNER)
			reset_laser(player,1)
			new authid[32], authid2[32], name2[32], name[32], userid2

			get_user_authid(id, authid, 31)
			get_user_authid(player, authid2, 31)
			get_user_name(player, name2, 31)
			get_user_name(id, name, 31)
			userid2 = get_user_userid(player)

			log_amx("Laser: ^"%s<%d><%s><>^" unset laser(s) ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)

			show_activity_key("TEXT1", "TEXT2", name, name2)
			menu_destroy( menu );
		}
		case 3:
		{
			new player = entity_get_int(ent,LASERMINE_OWNER)
			set_msg_block(g_msgDeathMsg, BLOCK_SET)
			detonate_mine(ent, id)
			set_msg_block(g_msgDeathMsg, BLOCK_NOT)
			RemoveEntity(ent)
			LaserMineThink()

			new authid[32], authid2[32], name2[32], name[32], userid2

			get_user_authid(id, authid, 31)
			get_user_authid(player, authid2, 31)
			get_user_name(player, name2, 31)
			get_user_name(id, name, 31)
			userid2 = get_user_userid(player)

			log_amx("Laser: ^"%s<%d><%s><>^" explode laser(s) ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)

			show_activity_key("TEXT2E", "TEXT2EA", name, name2)
			menu_destroy( menu );
		}
		case 4:
		{
			new player = entity_get_int(ent,LASERMINE_OWNER)
			new iCurrent
			while((iCurrent = find_ent_by_class(iCurrent, "lasermine")) != 0) {
				if(entity_get_int(iCurrent,LASERMINE_OWNER) == player) {
					set_msg_block(g_msgDeathMsg, BLOCK_SET)
					detonate_mine(iCurrent, id)
					set_msg_block(g_msgDeathMsg, BLOCK_NOT)
					RemoveEntity(iCurrent)
					LaserMineThink()
				}
			}

			new authid[32], authid2[32], name2[32], name[32], userid2

			get_user_authid(id, authid, 31)
			get_user_authid(player, authid2, 31)
			get_user_name(player, name2, 31)
			get_user_name(id, name, 31)
			userid2 = get_user_userid(player)

			log_amx("Laser: ^"%s<%d><%s><>^" explode laser(s) ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)

			show_activity_key("TEXT2E", "TEXT2EA", name, name2)
			menu_destroy( menu );
		}
		case 0:
		{
			menu_destroy( menu );
		}
	}
	return PLUGIN_HANDLED;
}

public update_mines(id,iCurrent) {

	for (new slot=0;slot<MAX_MINES;slot++) {
		if (player_mines_ent[id][slot] == iCurrent) {
			player_mines_ent[id][slot] = -1
			player_mines_count[id] = player_mines_count[id] - 1
		}
	}

}

public plugin_natives()
{
	register_native("lm_cost","native_lm_cost",1)
	register_native("lm_count","native_lm_count",1)
}

public native_lm_cost(id) {

	if (!is_user_connected(id))	return 0;

	new cost
	new mcost = MINE_COST / 2
	if ( is_user_alive(id) )
		cost = player_mines_count[id]*(get_vip_flags(id) & VIP_FLAG_C ? mcost/2 : mcost);
	else
		cost = player_mines_count[id]*(get_vip_flags(id) & VIP_FLAG_C ? floatround(MINE_COST/2 * 0.3) : floatround(MINE_COST * 0.3));

	if (cost<0) return 0;
	return cost;
}

public native_lm_count(id) {
	if (!is_user_connected(id))	return 0;
	return player_mines_count[id];
}

public LaserMenuReset( id )
{

	if(!is_user_connected(id) || !game_started() || player_mines_count[id]<=0)
		return PLUGIN_HANDLED_MAIN

	new mhours[6]
	get_time("%H", mhours, 5)
	new hrs = str_to_num(mhours)
	if (((hrs >= 23 || hrs < 6) || get_pcvar_num(g_xtime) == 2) && get_pcvar_num(g_xtime))
		return PLUGIN_HANDLED;

	new cost = player_mines_count[id]*(get_vip_flags(id) & VIP_FLAG_C ? floatround(MINE_COST/2 * 0.3) : floatround(MINE_COST * 0.3));

	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "%L", id, "LM_MENU_01", cost );
	new menu = menu_create( szText, "menu_shop_reset" )

	formatex( szText, charsmax( szText ), "%L", id, "LM_MENU_YES");
	menu_additem( menu, szText, "1", 0 );

	formatex( szText, charsmax( szText ), "%L", id, "LM_MENU_NO");
	menu_additem( menu, szText, "2", 0 );
	menu_setprop( menu, MPROP_PERPAGE, 0);

	menu_display( id, menu, 0 );

	return PLUGIN_CONTINUE;

}

public menu_shop_reset( id, menu, item )
{
	new data[ 6 ], iName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

	new key = str_to_num( data );

	switch( key )
	{
		case 1:
		{
			resetlaser(id)
			menu_destroy( menu );
		}
		case 2:
		{
			menu_destroy( menu );
		}
	}
	return PLUGIN_HANDLED;
}

        /*
public ReturnLaserMine_Progress(id)
{

	ReturnCheck(id);
	return PLUGIN_CONTINUE;

}*/

public cmd_reset(id, level, cid)
{

 	if(get_cvar_num( "amx_lasermine" ) != 1  )
		return PLUGIN_HANDLED_MAIN

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	if (!game_started()) {
		client_print(id, print_chat, "%L", LANG_PLAYER, "GMS_LS")
		return PLUGIN_HANDLED_MAIN
	}

	static arg1[32]
	read_argv(1, arg1, 31)

	if(arg1[0] == '@') {
		if(equali(arg1[1],"ALL")) {
				new authid[32], name[32]
				get_user_authid(id, authid, 31)
				get_user_name(id, name, 31)

				for (new i = 1; i < 33; i++)
				{
					if (is_user_connected(i))
						reset_laser(i,1)
				}

				log_amx("Laser: ^"%s<%d><%s><>^" unset all lasers", name, get_user_userid(id), authid)

				show_activity_key("TEXT1A", "TEXT2A", name)
		}
	} else {

	static target
	target = cmd_target(id, arg1, (CMDTARGET_ALLOW_SELF))

	if(!is_user_connected(target))
		return PLUGIN_HANDLED_MAIN

	/*
	if(!game_started())
	{
		console_print(id, "CMD_GAMENOTSTARTED")
		return PLUGIN_HANDLED_MAIN
	}*/

	reset_laser(target,1)

	new authid[32], authid2[32], name2[32], name[32], userid2, player = target

	get_user_authid(id, authid, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(player, name2, 31)
	get_user_name(id, name, 31)
	userid2 = get_user_userid(player)

	log_amx("Laser: ^"%s<%d><%s><>^" unset laser(s) ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)

	show_activity_key("TEXT1", "TEXT2", name, name2)

	}

	return PLUGIN_HANDLED
}
                   /*
public evn_damage(victim) {

new weapon,attacker = get_user_attacker(victim, weapon)

new names[32],names2[32]

get_user_name(victim, names, 31)
get_user_name(attacker, names2, 31)
client_print(0, print_chat, "test %s ||| %s", names, names2)

}                    */


       /*
public Minekill(victim, attacker, corpse) {
	new names[32]
	get_user_name(attacker, names, 31)
	client_print(0, print_chat, "test %s", names)
    return HAM_HANDLED
}        */