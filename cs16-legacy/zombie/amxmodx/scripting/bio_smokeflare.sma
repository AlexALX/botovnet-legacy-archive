/*  
 * This plugin was created for Botov-NET Project
 * It changes some grenade into smore flare
 *
 * Copyring by AlexALX (c) 2015
 *
 * Original author - mini_midget/cheap_suit
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
#tryinclude <biohazard>
#include <engine>

#if !defined _biohazard_included
        #assert Biohazard functions file required!
#endif

#define pev_flare pev_iuser4
#define flare_id 1337
#define is_ent_flare(%1) (pev(%1, pev_flare) == flare_id) ? 1 : 0

new const g_flare_model[] = "models/smokeflare-bio_botovnetua.mdl" //"models/w_flare.mdl"

new cvar_smokeflare, cvar_smokeflare_dur
public plugin_init()
{
	register_plugin("smoke flare", "0.1", "mini_midget/cheap_suit")
	is_biomod_active() ? plugin_init2() : pause("ad")
}

public plugin_precache()
	precache_model(g_flare_model)

public plugin_init2()
{
	register_forward(FM_SetModel, "fwd_setmodel")
	register_forward(FM_Think, "fwd_think")
	cvar_smokeflare = register_cvar("bh_flare_enable",   "1")
	cvar_smokeflare_dur = register_cvar("bh_flare_duration", "999.9")
	register_event("HLTV", "newround", "a", "1=0", "2=0")
	register_concmd("amx_fld", "cmd_del", ADMIN_BAN, "<ct> <t>")
}

public fwd_setmodel(ent, const model[])
{
	if(!pev_valid(ent) || !equal(model[9], "smokegrenade.mdl"))
		return FMRES_IGNORED

	static classname[32]; pev(ent, pev_classname, classname, 31)
	if(equal(classname, "grenade") && get_pcvar_num(cvar_smokeflare))
	{
		//new rgb[3]
		//rgb[0] = 128 // r
		//rgb[1] = 128 // g
		//rgb[2] = 128 // b

		engfunc(EngFunc_SetModel, ent, g_flare_model)
		set_pev(ent, pev_effects, EF_BRIGHTLIGHT)
		set_pev(ent, pev_flare,   flare_id)
		set_pev(ent, pev_nextthink, get_gametime() + get_pcvar_float(cvar_smokeflare_dur))
		//set_pev(ent, pev_punchangle, rgb)
		//fm_set_rendering(ent, kRenderFxGlowShell, 150, 150, 250, kRenderNormal, 16)

		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public fwd_think(ent) if(pev_valid(ent) && is_ent_flare(ent))
	return
	//engfunc(EngFunc_RemoveEntity, ent)

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]; color[2] = float(b), color[0] = float(r), color[1] = float(g)

	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode,  render)
	set_pev(entity, pev_renderamt,   float(amount))

	return 1
}

public newround() {

	if(!get_pcvar_num(cvar_smokeflare))
		return PLUGIN_CONTINUE

	new iCurrent
	while((iCurrent = find_ent_by_model(iCurrent, "grenade", g_flare_model)) != 0) {
		if(pev_valid(iCurrent) && is_ent_flare(iCurrent))
			engfunc(EngFunc_RemoveEntity, iCurrent)
	}
	return 1

}

public cmd_del(id, level, cid)
{

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	if(!get_pcvar_num(cvar_smokeflare))
		return PLUGIN_CONTINUE

	new iCurrent
	while((iCurrent = find_ent_by_model(iCurrent, "grenade", g_flare_model)) != 0) {
		if(pev_valid(iCurrent) && is_ent_flare(iCurrent))
			engfunc(EngFunc_RemoveEntity, iCurrent)
	}
	return PLUGIN_HANDLED_MAIN

}