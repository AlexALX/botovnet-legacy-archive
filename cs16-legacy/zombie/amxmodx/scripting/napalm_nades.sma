/*================================================================================

* This plugin was modified for Botov-NET Project
* It adds extinguisher and may add something else
* Copyring for MODIFICATIONS and NEW features by AlexALX (c) 2015 

*
*  License of original plugin is unknown.
*  My modifications are licensed under GNU GPL License.
*
*  If you are the author and want to clarify licensing, 
*  please contact the repository owner.

	------------------------
	-*- Napalm Nades 1.2 -*-
	------------------------

	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~

	This plugin turns one of the default grenades into a napalm bomb that
	can set players on fire. Basically a CS port of the "fire grenades"
	I originally developed for Zombie Plague, at the request of some people
	and since there were no similiar plugins around. Have fun!

	~~~~~~~~~~~~~~~~
	- Requirements -
	~~~~~~~~~~~~~~~~

	* Mods: Counter-Strike 1.6 or Condition-Zero
	* AMXX: Version 1.8.0 or later
	* Modules: FakeMeta, HamSandwich

	~~~~~~~~~~~~~~~~
	- Installation -
	~~~~~~~~~~~~~~~~

	* Extract .amxx file to your plugins folder, and add its name to plugins.ini
	* Extract flame.spr to the "sprites" folder on your server
	* To change models or sounds, open up the .sma with any text editor and look
	   for the customization section. When you're done, recompile.

	~~~~~~~~~~~~
	- Commands -
	~~~~~~~~~~~~

	* say /napalm - Buy a napalm grenade (when override is off)

	~~~~~~~~~
	- CVARS -
	~~~~~~~~~

	* napalm_on <0/1> - Enable/Disable Napalm Nades
	* napalm_affect <1/2/3> - Which nades should be napalms (1-HE // 2-FB // 3-SG)
	* napalm_team <0/1/2> - Determines which team can buy/use napalm nades
	   (0-both teams // 1-Terrorists only // 2-CTs only)
	* napalm_override <0/1> - If enabled, grenades will automatically become
	   napalms without players having to buy them
	* napalm_price <1000> - Money needed to buy a napalm (when override is off)
	* napalm_buyzone <0/1> - If enabled, players need to be in a buyzone to
	   purchase a napalm (when override is off)

	* napalm_radius <240> - Napalm explosion radius
	* napalm_hitself <0/1> - If enabled, napalms will also affect their owner
	* napalm_ff <0/1> - If enabled, napalms will also affect teammates
	* napalm_spread <0/1> - If enabled, players will be able to catch fire
	   from others when they touch
	* napalm_keepexplosion <0/1> - Wether to keep the default CS explosion

	* napalm_duration <5> - How long the burning lasts in seconds
	* napalm_damage <2> - How much damage the burning does (every 0.2 secs)
	* napalm_cankill <0/1> - If set, burning will be able to kill the victim
	* napalm_slowdown <0.5> - Burning slow down, set between: 0.1 (slower) and
	   0.9 (faster). Use 0 to disable.
	* napalm_screamrate <20> - How often players will scream when on fire
	   (lower values = more screams). Use 0 to disable.

	~~~~~~~~~~~~~
	- Changelog -
	~~~~~~~~~~~~~

	* v1.0: (Jul 26, 2008)
	   - First release

	* v1.1: (Aug 15, 2008)
	   - Grenades now explode based on their pev_dmgtime (means the
	      plugin is now compatible with Nade Modes)
	   - Changed method to identify napalm nades when override is off
	   - Fire spread feature now fully working with CZ bots

	* v1.1b: (Aug 23, 2008)
	   - Optimized bandwidth usage for temp entity messages

	* v1.1c: (Aug 26, 2008)
	   - Fixed possible bugs with plugins that change a player's team
	      after throwing a napalm nade

	* v1.2: (Oct 05, 2008)
	   - Added a few cvars that allow more customization
	   - Optimized the code a bit
	   - Fixed a bug where buying 2 napalms too quick would sometimes
	      result in the second acting as a normal nade

================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <money_ul>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <fun>
#include <biohazard>
#include <cstrike>
#include <engine>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

// Uncomment the following if you wish to set custom models for napalms
// winter mode - changes model and effect colors
//#define USE_NAPALM_CUSTOM_MODELS

#if defined USE_NAPALM_CUSTOM_MODELS // Then set your custom models here
new const g_model_napalm_view[] = "models/snowgren/v_hegrenade.mdl"
new const g_model_napalm_player[] = "models/snowgren/p_hegrenade.mdl"
new const g_model_napalm_world[] = "models/snowgren/w_hegrenade.mdl"
#endif

// Explosion sounds
new const grenade_fire[][] = { "weapons/hegrenade-1.wav" } //{ "snowgren/impalehit.wav" }
new const grenade_firedown[][] = { "biohazard/grenade_down.wav" }

// Player burning sounds
#if defined USE_NAPALM_CUSTOM_MODELS
	new const grenade_fire_player[][] = { "scientist/scream14.wav", "scientist/scream15.wav", "scientist/scream16.wav", "scientist/scream18.wav", "scientist/scream19.wav", "scientist/scream09.wav" }
#else
	new const grenade_fire_player[][] = { "scientist/botov.net.ua/hu/sci_fear8.wav", "scientist/botov.net.ua/hu/sci_pain1.wav", "scientist/botov.net.ua/hu/scream02.wav", "scientist/botov.net.ua/hu/scream07.wav", "scientist/botov.net.ua/hu/scream22.wav" }
#endif

//new const grenade_fire_player_zm[][] = { "scientist/botov.net.ua/zm/zombie_burn3.wav", "scientist/botov.net.ua/zm/zombie_burn4.wav", "scientist/botov.net.ua/zm/zombie_burn5.wav", "scientist/botov.net.ua/zm/zombie_burn6.wav", "scientist/botov.net.ua/zm/zombie_burn7.wav" }

// Grenade sprites
#if defined USE_NAPALM_CUSTOM_MODELS
	new const sprite_grenade_fire[] = "sprites/firesnow.spr"
#else
	new const sprite_grenade_fire[] = "sprites/fire_botov.net.ua.spr"
#endif
new const sprite_grenade_smoke[] = "sprites/black_smoke3.spr"
new const sprite_grenade_trail[] = "sprites/laserbeam.spr"
new const sprite_grenade_ring[] = "sprites/shockwave.spr"

// Glow and trail colors (red, green, blue)
#if defined USE_NAPALM_CUSTOM_MODELS
	const NAPALM_R = 0 // 200
	const NAPALM_G = 0 // 0
	const NAPALM_B = 200 // 0
#else
	const NAPALM_R = 200 // 200
	const NAPALM_G = 0 // 0
	const NAPALM_B = 0 // 0
#endif

/*===============================================================================*/

// Burning task
const TASK_BURN = 1000
#define ID_BURN (taskid - TASK_BURN)

// Flame task
#define FLAME_DURATION args[0]
#define FLAME_ATTACKER args[1]

// CS Offsets
#if cellbits == 32
const OFFSET_CSTEAMS = 114
const OFFSET_CSMONEY = 115
const OFFSET_MAPZONE = 235
#else
const OFFSET_CSTEAMS = 139
const OFFSET_CSMONEY = 140
const OFFSET_MAPZONE = 268
#endif
const OFFSET_LINUX = 5 // offsets +5 in Linux builds

// Some constants
const PLAYER_IN_BUYZONE = (1<<0)

// pev_ field used to store custom nade types and their values
const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_NAPALM = 681856

// Weapons that can be napalms
new const AFFECTED_NAMES[][] = { "HE", "FB", "SG" }
new const AFFECTED_CLASSNAMES[][] = { "weapon_hegrenade", "weapon_flashbang", "weapon_smokegrenade" }
new const AFFECTED_MODELS[][] = { "w_he", "w_fl", "w_sm" }
#if defined USE_NAPALM_CUSTOM_MODELS
new const AFFECTED_WEAPONS[] = { CSW_HEGRENADE, CSW_FLASHBANG, CSW_SMOKEGRENADE }
#endif

// Whether ham forwards are registered for CZ bots
new g_hamczbots

// Precached sprites indices
new g_flameSpr, g_smokeSpr, g_trailSpr, g_exploSpr

// Messages
new g_msgDamage, g_msgMoney, g_msgBlinkAcct,g_msgDeathMsg, g_msgScoreInfo

// CVAR pointers
new cvar_radius, cvar_price, cvar_hitself, cvar_duration, cvar_slowdown, cvar_override,
cvar_damage, cvar_on, cvar_buyzone, cvar_ff, cvar_cankill, cvar_spread, cvar_botquota,
cvar_teamrestrict, cvar_screamrate, cvar_keepexplosion, cvar_affect

new fire_Cost, bool:g_havefire[33]//, g_usefire[33]

#define G_PICKUP_SND	"items/9mmclip1.wav"

new const gWeaponCommand [] = "weapon_hegrenade";
new bool:gWeaponActive[ 33 ];
//new gWeaponIndex[ 33 ];

// Precache all custom stuff
public plugin_precache()
{
	#if defined USE_NAPALM_CUSTOM_MODELS
	engfunc(EngFunc_PrecacheModel, g_model_napalm_view)
	engfunc(EngFunc_PrecacheModel, g_model_napalm_player)
	engfunc(EngFunc_PrecacheModel, g_model_napalm_world)
	#endif

	new i
	for (i = 0; i < sizeof grenade_fire; i++)
		engfunc(EngFunc_PrecacheSound, grenade_fire[i])
	for (i = 0; i < sizeof grenade_firedown; i++)
		engfunc(EngFunc_PrecacheSound, grenade_firedown[i])
	for (i = 0; i < sizeof grenade_fire_player; i++)
		engfunc(EngFunc_PrecacheSound, grenade_fire_player[i])
	//for (i = 0; i < sizeof grenade_fire_player_zm; i++)
	//	engfunc(EngFunc_PrecacheSound, grenade_fire_player_zm[i])

	g_flameSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_fire)
	g_smokeSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_smoke)
	g_trailSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_trail)
	g_exploSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_ring)

	precache_sound( G_PICKUP_SND );
}

public plugin_init()
{
	// Register plugin call
	register_plugin("Napalm Nades", "1.2", "MeRcyLeZZ")

	// Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	#if defined USE_NAPALM_CUSTOM_MODELS
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	#endif

	// Forwards
	register_forward(FM_SetModel, "fw_SetModel")
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	RegisterHam(Ham_Touch, "player", "fw_TouchPlayer")
	#if defined USE_NAPALM_CUSTOM_MODELS
	RegisterHam(Ham_Touch, "grenade", "fw_TouchGrenade")
	#endif

	register_concmd("amx_burn", "setburn", ADMIN_RCON, "<nick or #userid or @all> <attacker>")

	// Client commands
	register_clcmd("say napalm", "buy_napalm")
	register_clcmd("say /napalm", "buy_napalm")

	register_clcmd("say buy_extinguisher", "buy_fire")
	register_clcmd("say /buy_extinguisher", "buy_fire")
	register_clcmd("buy_extinguisher", "buy_fire")
	register_clcmd("/buy_extinguisher", "buy_fire")
	register_clcmd("say buy_exg", "buy_fire")
	register_clcmd("say /buy_exg", "buy_fire")
	register_clcmd("buy_exg", "buy_fire")
	register_clcmd("/buy_exg", "buy_fire")

	RegisterHam( Ham_Item_Deploy , gWeaponCommand, "grenade_Deploy", 1 );
	RegisterHam( Ham_Item_Holster, gWeaponCommand, "grenade_Holster", 1 );

	// CVARS
	cvar_on = register_cvar("napalm_on", "1")
	cvar_affect = register_cvar("napalm_affect", "1")
	cvar_teamrestrict = register_cvar("napalm_team", "0")
	cvar_override = register_cvar("napalm_override", "0")
	cvar_price = register_cvar("napalm_price", "1000")
	cvar_buyzone = register_cvar("napalm_buyzone", "1")

	cvar_radius = register_cvar("napalm_radius", "240")
	cvar_hitself = register_cvar("napalm_hitself", "1")
	cvar_ff = register_cvar("napalm_ff", "0")
	cvar_spread = register_cvar("napalm_spread", "1")
	cvar_keepexplosion = register_cvar("napalm_keepexplosion", "0")

	cvar_duration = register_cvar("napalm_duration", "5")
	cvar_damage = register_cvar("napalm_damage", "2")
	cvar_cankill = register_cvar("napalm_cankill", "1")
	cvar_slowdown = register_cvar("napalm_slowdown", "0.5")
	cvar_screamrate = register_cvar("napalm_screamrate", "20")

	cvar_botquota = get_cvar_pointer("bot_quota")

	// Message ids
	g_msgDamage = get_user_msgid("Damage")
	g_msgMoney = get_user_msgid("Money")
	g_msgBlinkAcct = get_user_msgid("BlinkAcct")
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgScoreInfo = get_user_msgid("ScoreInfo")

	fire_Cost = register_cvar("fire_cost","2500")
	register_dictionary("napalm.txt")
	register_event("DeathMsg", "death", "a")

}

public plugin_natives()
{
	register_native("reset_fire","native_reset_fire",1)
}

public client_connect(id) {
	g_havefire[id] = false;
	//g_usefire[id] = 0;
	gWeaponActive{ id } = false;
	//gWeaponIndex{ id } = 0;
	return PLUGIN_CONTINUE;
}

public client_disconnect(id) {
	g_havefire[id] = false;
	//g_usefire[id] = 0;
	gWeaponActive{ id } = false;
	//gWeaponIndex{ id } = 0;
	return PLUGIN_CONTINUE;
}

public death()
{
	new id = read_data(2)
	g_havefire[id] = false
	//g_usefire[id] = 0
	gWeaponActive{ id } = false;
	//gWeaponIndex{ id } = 0;
	return PLUGIN_CONTINUE;
}

public buy_fire(id) {

	if (!is_user_connected(id))
		return PLUGIN_HANDLED;

	if (!is_user_alive(id)) {
		client_print(id, print_chat, "%L", id, "NAPALM_ALIVE")
		return PLUGIN_HANDLED;
	}

	if (!is_user_zombie(id)) {
		client_print(id, print_chat, "%L", id, "NAPALM_HUMAN")
		return PLUGIN_HANDLED;
	}

	if (is_user_zombie(id) && (get_class_id("Diablo") == get_user_class(id) || get_class_id("FireLeaper") == get_user_class(id) || get_class_id("Nurse") == get_user_class(id))) {
		client_print(id, print_chat, "%L", id, "NAPALM_ZOMBS")
		return PLUGIN_HANDLED;
	}

	//if (g_usefire[id] >= 2) {
	//	client_print(id, print_chat, "%L", id, "NAPALM_HAVE")
	//	return PLUGIN_HANDLED;
	//}

	new money = cs_get_user_money_ul(id)

	if ( money < get_pcvar_num( fire_Cost ) )
	{
		client_print(id, print_chat, "%L", id, "NAPALM_MONEY", get_pcvar_num( fire_Cost ))
		return PLUGIN_HANDLED
	}

	if (!task_exists(id+TASK_BURN)){
		client_print(id, print_chat, "%L", id, "NAPALM_NOFIRE")
		return PLUGIN_HANDLED;
	}

	cs_set_user_money_ul(id, money - get_pcvar_num( fire_Cost ));
	client_print(id, print_chat, "%L", id, "NAPALM_BUY")

	g_havefire[id] = true;
	//g_usefire[id] += 1;
	set_task(3.5,"reset_fire",id);
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, grenade_firedown[random_num(0, sizeof grenade_firedown - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)

	return PLUGIN_CONTINUE;

}

        const m_flNextAttack        = 83    // Player.
        const m_pActiveWeapon       = 373;  // Player.
        const m_pPlayer             = 41;   // Weapon.
        const m_flNextPrimaryAttack = 46;   // Weapon.

public event_gamestart ()
{
	new id
	for (id = 1; id <= 32; id++) {
        if ( is_user_connected(id) && gWeaponActive{ id } )
        {
            gWeaponActive{ id } = false;
            //set_pdata_float( gWeaponIndex{ id }, m_flNextPrimaryAttack, , 4 );
            set_pdata_float( id, m_flNextAttack, 0.0 );
        }
	}
}

public grenade_Deploy ( const Weapon )
{
        // --| Get the knife's owner index.
        new Player = get_pdata_cbase( Weapon, m_pPlayer, 4 );

        if ( Player && !game_started() )
        {
            // --| Block the primary attack.
            //set_pdata_float( Weapon, m_flNextPrimaryAttack, 9999.0, 4 );
            set_pdata_float( Player, m_flNextAttack, 9999.0 );

            // --| We are holding the weapon.
            gWeaponActive{ Player } = true;
            //gWeaponIndex{ Player } = Weapon;
        }
}

public grenade_Holster ( const Weapon )
{
        // --| Get the knife's owner index.
        new Player = get_pdata_cbase( Weapon, m_pPlayer, 4 );

        if ( Player && gWeaponActive{ Player } )
        {
            // --| We are not holding the weapon anymore.
            gWeaponActive{ Player } = false;
            set_pdata_float( Player, m_flNextAttack, get_gametime() + 0.5 );
            //gWeaponIndex{ Player } = 0;
        }
}

public native_reset_fire(id) {
	//g_usefire[id] = 0;
	g_havefire[id] = false;
	return PLUGIN_CONTINUE;
}

public reset_fire(id)
	if (is_user_connected(id))
		g_havefire[id] = false;

// Round Start Event
public event_round_start()
{
	// Stop any burning tasks on players
	static id
	for (id = 1; id <= 32; id++) {
		remove_task(id+TASK_BURN);
		//g_usefire[id] = 0;
		g_havefire[id] = false;
	}
}

#if defined USE_NAPALM_CUSTOM_MODELS
// Current Weapon Event
public event_curweapon(id)
{
	// Napalm grenades disabled
	if (!get_pcvar_num(cvar_on))
		return;

	// Get affected grenades setting
	static affect
	affect = get_pcvar_num(cvar_affect)

	// Not an affected grenade
	if (read_data(2) != AFFECTED_WEAPONS[affect-1])
		return;

	// Not a napalm grenade (because the weapon entity of its owner doesn't have the flag set)
	if (!get_pcvar_num(cvar_override) && pev(fm_get_napalm_entity(id, affect), PEV_NADE_TYPE) != NADE_TYPE_NAPALM)
		return;

	// Get team restriction setting
	static allowed_team
	allowed_team = get_pcvar_num(cvar_teamrestrict)

	// Player is on a restricted team
	if (allowed_team > 0 && allowed_team != fm_get_user_team(id))
		return;

	// Replace models
	set_pev(id, pev_viewmodel2, g_model_napalm_view)
	set_pev(id, pev_weaponmodel2, g_model_napalm_player)
}
#endif

// Client joins the game
public client_putinserver(id)
{
	// CZ bots seem to use a different "classtype" for player entities
	// (or something like that) which needs to be hooked separately
	if (!g_hamczbots && cvar_botquota && is_user_bot(id))
	{
		// Set a task to let the private data initialize
		set_task(0.1, "register_ham_czbots", id)
	}
}

// Set Model Forward
public fw_SetModel(entity, const model[])
{
	// Napalm grenades disabled
	if (!get_pcvar_num(cvar_on))
		return FMRES_IGNORED;

	// Get affected grenades setting
	static affect
	affect = get_pcvar_num(cvar_affect)

	// Not an affected grenade
	if (!equal(model[7], AFFECTED_MODELS[affect-1], 4))
		return FMRES_IGNORED;

	// Get damage time of grenade
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)

	// Grenade not yet thrown
	if (dmgtime == 0.0)
		return FMRES_IGNORED;

	// Get owner of grenade
	static owner
	owner = pev(entity, pev_owner)

	// Not a napalm grenade (because the weapon entity of its owner doesn't have the flag set)
	if (!get_pcvar_num(cvar_override) && pev(fm_get_napalm_entity(owner, affect), PEV_NADE_TYPE) != NADE_TYPE_NAPALM)
		return FMRES_IGNORED;

	// Get team restriction setting
	static allowed_team
	allowed_team = get_pcvar_num(cvar_teamrestrict)

	// Player is on a restricted team
	if (allowed_team > 0 && allowed_team != fm_get_user_team(owner))
		return FMRES_IGNORED;

	// Give it a glow
	fm_set_rendering(entity, kRenderFxGlowShell, NAPALM_R, NAPALM_G, NAPALM_B, kRenderNormal, 16)

	// And a colored trail
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // TE id
	write_short(entity) // entity
	write_short(g_trailSpr) // sprite
	write_byte(10) // life
	write_byte(10) // width
	write_byte(NAPALM_R) // r
	write_byte(NAPALM_G) // g
	write_byte(NAPALM_B) // b
	write_byte(200) // brightness
	message_end()

	// Remove napalm flag from the owner's weapon entity (fixes an
	// exploit when the grenade can carry multiple ammo, e.g. flashbang)
	set_pev(fm_get_napalm_entity(owner, affect), PEV_NADE_TYPE, 0)

	// Set grenade type on the thrown grenade entity
	set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_NAPALM)

	// Set owner's team on the thrown grenade entity
	set_pev(entity, pev_team, fm_get_user_team(owner))

	#if defined USE_NAPALM_CUSTOM_MODELS
	// Set custom model and supercede the original forward
	engfunc(EngFunc_SetModel, entity, g_model_napalm_world)
	return FMRES_SUPERCEDE;
	#else
	return FMRES_IGNORED;
	#endif
}

// Grenade Think Forward
public fw_ThinkGrenade(entity)
{
	if (!pev_valid(entity))
		return HAM_IGNORED;

	// Get damage time of grenade
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)

	// Check if it's time to go off
	if (dmgtime > get_gametime())
		return HAM_IGNORED;

	// Not a napalm grenade
	if (pev(entity, PEV_NADE_TYPE) != NADE_TYPE_NAPALM)
		return HAM_IGNORED;

	// Explode event
	napalm_explode(entity)

	// Keep the original explosion?
	//if (get_pcvar_num(cvar_keepexplosion))
	//{
		set_pev(entity, PEV_NADE_TYPE, 0)
	//	return HAM_IGNORED;
	//}

	// Get rid of the grenade
	//engfunc(EngFunc_RemoveEntity, entity)

	//return HAM_SUPERCEDE;
	return HAM_IGNORED;
}

#if defined USE_NAPALM_CUSTOM_MODELS
// Player Touch Forward
public fw_TouchGrenade(entity, other)
{
	if (!pev_valid(entity))
		return HAM_IGNORED;

	// Not a napalm grenade
	if (pev(entity, PEV_NADE_TYPE) != NADE_TYPE_NAPALM)
		return HAM_IGNORED;

	napalm_explode(entity)
	set_pev(entity, PEV_NADE_TYPE, 0)
	set_pdata_int(entity, 114, 3, 5)
	set_pev(entity,pev_dmgtime,0.0)
	dllfunc(DLLFunc_Think,entity)
	//set_rendering( entity, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );
	//engfunc(EngFunc_RemoveEntity, entity)

	//return HAM_SUPERCEDE;
	return HAM_IGNORED;

}
#endif

// Player Touch Forward
public fw_TouchPlayer(self, other)
{
	// Spread cvar disabled or not on fire
	if (!get_pcvar_num(cvar_spread) || !task_exists(self+TASK_BURN))
		return;

	// Not touching a player or player already on fire
	if (!is_user_alive(other) || task_exists(other+TASK_BURN))
		return;

	// Check if friendly fire is allowed
	if (!get_pcvar_num(cvar_ff) && fm_get_user_team(self) == fm_get_user_team(other))
		return;

	// Heat icon
	message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, other)
	write_byte(0) // damage save
	write_byte(0) // damage take
	write_long(DMG_BURN) // damage type
	write_coord(0) // x
	write_coord(0) // y
	write_coord(0) // z
	message_end()

	// Our task params
	static params[2]
	params[0] = get_pcvar_num(cvar_duration)*2 // duration (reduced a bit)
	params[1] = self // attacker

	// Set burning task on victim
	set_task(0.1, "burning_flame", other+TASK_BURN, params, sizeof params)
}

// Say hook
public buy_napalm(id)
{
	// Napalm grenades disabled
	if (!get_pcvar_num(cvar_on))
		return PLUGIN_CONTINUE;

	// Check that player is alive
	if (!is_user_alive(id))
	{
		client_print(id, print_center, "You can't buy when you're dead!")
		return PLUGIN_HANDLED;
	}

	// Get team restriction setting
	static allowed_team
	allowed_team = get_pcvar_num(cvar_teamrestrict)

	// Check if the player is on a restricted team
	if (allowed_team > 0 && allowed_team != fm_get_user_team(id))
	{
		client_print(id, print_center, "Your team cannot buy napalm nades!")
		return PLUGIN_HANDLED;
	}

	// Get affected grenades setting
	static affect
	affect = get_pcvar_num(cvar_affect)

	// Check if override setting is enabled instead
	if (get_pcvar_num(cvar_override))
	{
		client_print(id, print_center, "Just buy a %s grenade and get a napalm automatically!", AFFECTED_NAMES[affect-1])
		return PLUGIN_HANDLED;
	}

	// Check if player needs to be in a buyzone
	if (get_pcvar_num(cvar_buyzone) && !fm_get_user_buyzone(id))
	{
		client_print(id, print_center, "You are not in a buyzone!")
		return PLUGIN_HANDLED;
	}

	// Check that player has the money
	if (fm_get_user_money(id) < get_pcvar_num(cvar_price))
	{
		client_print(id, print_center, "#Cstrike_TitlesTXT_Not_Enough_Money")

		// Blink money
		message_begin(MSG_ONE_UNRELIABLE, g_msgBlinkAcct, _, id)
		write_byte(2) // times
		message_end()

		return PLUGIN_HANDLED;
	}

	// Check that player doesn't have a napalm already
	if (fm_get_napalm_entity(id, affect) != 0)
	{
		client_print(id, print_center, "#Cstrike_Already_Own_Weapon")
		return PLUGIN_HANDLED;
	}

	// Give napalm
	fm_give_item(id, AFFECTED_CLASSNAMES[affect-1])

	// Set napalm flag on the weapon entity
	set_pev(fm_get_napalm_entity(id, affect), PEV_NADE_TYPE, NADE_TYPE_NAPALM)

	// Remove the money
	fm_set_user_money(id, fm_get_user_money(id)-get_pcvar_num(cvar_price))

	// Update money on HUD
	message_begin(MSG_ONE, g_msgMoney, _, id)
	write_long(fm_get_user_money(id)) // amount
	write_byte(1) // flash
	message_end()

	return PLUGIN_HANDLED;
}

// Napalm Grenade Explosion
napalm_explode(ent)
{
	// Get attacker and its team
	static attacker, attacker_team
	attacker = pev(ent, pev_owner)
	attacker_team = pev(ent, pev_team)

	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)

	// Custom explosion effect
	create_blast2(originF)

	// Napalm explosion sound
	engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, grenade_fire[random_num(0, sizeof grenade_fire - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)

	// Collisions
	static victim
	victim = -1

	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, get_pcvar_float(cvar_radius))) != 0)
	{
		// Only effect alive players
		if (!is_user_alive(victim))
			continue;

		// Check if myself is allowed
		if (victim == attacker && !get_pcvar_num(cvar_hitself))
			continue;

		// Check if friendly fire is allowed
		if (victim != attacker && !get_pcvar_num(cvar_ff) && attacker_team == fm_get_user_team(victim))
			continue;

		if (is_user_zombie(victim) && (get_class_id("Diablo") == get_user_class(victim) || get_class_id("FireLeaper") == get_user_class(victim) || get_class_id("Nurse") == get_user_class(victim) || g_havefire[victim]))
			continue;

		if (is_terminator(victim))
			return;

		// Heat icon
		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_BURN) // damage type
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()

		// Our task params
		static params[2]
		params[0] = get_pcvar_num(cvar_duration)*5 // duration
		params[1] = attacker // attacker

		// Set burning task on victim
		set_task(0.1, "burning_flame", victim+TASK_BURN, params, sizeof params)
	}
}

// Burning Task
public burning_flame(args[2], taskid)
{
	// Player died/disconnected
	if (!is_user_alive(ID_BURN))
		return;

	// Get player origin and flags
	static Float:originF[3], flags
	pev(ID_BURN, pev_origin, originF)
	flags = pev(ID_BURN, pev_flags)

	if (is_user_zombie(ID_BURN) && (get_class_id("Diablo") == get_user_class(ID_BURN) || get_class_id("FireLeaper") == get_user_class(ID_BURN) || get_class_id("Nurse") == get_user_class(ID_BURN) || g_havefire[ID_BURN]))
		return;

	if (is_terminator(ID_BURN))
		return;

	// In water or burning stopped
	if ((flags & FL_INWATER) || FLAME_DURATION < 1 || !is_user_zombie(ID_BURN) && !is_user_zombie(FLAME_ATTACKER) || get_user_godmode(ID_BURN))
	{
		// Smoke sprite
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()

		return;
	}

	// Get screams setting
	static screams
	screams = get_pcvar_num(cvar_screamrate)

	// Randomly play burning sounds
	if (screams > 0 && random_num(1, screams) == 1) {
		//if (is_user_zombie(ID_BURN)) engfunc(EngFunc_EmitSound, ID_BURN, CHAN_VOICE, grenade_fire_player_zm[random_num(0, sizeof grenade_fire_player_zm - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM);
		/*else*/ engfunc(EngFunc_EmitSound, ID_BURN, CHAN_VOICE, grenade_fire_player[random_num(0, sizeof grenade_fire_player - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
		//engfunc(EngFunc_EmitSound, ID_BURN, CHAN_VOICE, grenade_fire_player[random_num(0, sizeof grenade_fire_player - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)

	// Get fire slowdown setting
	static Float:slowdown
	slowdown = get_pcvar_float(cvar_slowdown)

	// Fire slow down
	if (slowdown > 0.0 && (flags & FL_ONGROUND))
	{
		static Float:velocity[3]
		pev(ID_BURN, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, slowdown, velocity)
		set_pev(ID_BURN, pev_velocity, velocity)
	}

	// Get health and fire damage setting
	static health, damage
	health = pev(ID_BURN, pev_health)
	damage = get_pcvar_num(cvar_damage)

	// Take damage from the fire
	if (health > damage)
		fm_set_user_health(ID_BURN, health - damage)
	else if (get_pcvar_num(cvar_cankill))
	{
		// Kill the victim
		//ExecuteHamB(Ham_Killed, ID_BURN, FLAME_ATTACKER, 0)
		set_msg(ID_BURN,FLAME_ATTACKER)

		// Smoke sprite
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()

		return;
	}

	// Flame sprite
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPRITE) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]+random_float(-5.0, 5.0)) // x
	engfunc(EngFunc_WriteCoord, originF[1]+random_float(-5.0, 5.0)) // y
	engfunc(EngFunc_WriteCoord, originF[2]+random_float(-10.0, 10.0)) // z
	write_short(g_flameSpr) // sprite
	write_byte(random_num(5, 10)) // scale
	write_byte(200) // brightness
	message_end()

	// Decrease task cycle count
	FLAME_DURATION -= 1;

	// Keep sending flame messages
	set_task(0.2, "burning_flame", taskid, args, sizeof args)
}

// Napalm Grenade: Fire Blast (originally made by Avalanche in Frostnades)
create_blast2(const Float:originF[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	#if defined USE_NAPALM_CUSTOM_MODELS
		write_byte(0) // red 200
		write_byte(100) // green 100
		write_byte(200) // blue
	#else
		write_byte(200) // red 200
		write_byte(100) // green 100
		write_byte(0) // blue
	#endif
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()

	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	#if defined USE_NAPALM_CUSTOM_MODELS
		write_byte(0) // red 200
		write_byte(50) // green
		write_byte(200) // blue
	#else
		write_byte(200) // red 200
		write_byte(50) // green
		write_byte(0) // blue
	#endif
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()

	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	#if defined USE_NAPALM_CUSTOM_MODELS
		write_byte(0) // red 200
		write_byte(0) // green
		write_byte(200) // blue
	#else
		write_byte(200) // red 200
		write_byte(0) // green
		write_byte(0) // blue
	#endif
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Register Ham Forwards for CZ bots
public register_ham_czbots(id)
{
	// Make sure it's a CZ bot and it's still connected
	if (g_hamczbots || !get_pcvar_num(cvar_botquota) || !is_user_connected(id) || !is_user_bot(id))
		return;

	RegisterHamFromEntity(Ham_Touch, id, "fw_TouchPlayer")

	// Ham forwards for CZ bots succesfully registered
	g_hamczbots = true;
}

// Set entity's rendering type (from fakemeta_util)
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)

	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}

// Set player's health (from fakemeta_util)
stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

// Give an item to a player (from fakemeta_util)
stock fm_give_item(id, const item[])
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	if (!pev_valid(ent)) return;

	static Float:originF[3]
	pev(id, pev_origin, originF);
	set_pev(ent, pev_origin, originF);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);

	static save
	save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, id);
	if (pev(ent, pev_solid) != save)
		return;

	engfunc(EngFunc_RemoveEntity, ent);
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) {}

	return entity;
}

// Finds napalm grenade weapon entity of a player
stock fm_get_napalm_entity(id, affect)
{
	return fm_find_ent_by_owner(-1, AFFECTED_CLASSNAMES[affect-1], id);
}

// Get User Money
stock fm_get_user_money(id)
{
	return cs_get_user_money_ul(id);
}

// Set User Money
stock fm_set_user_money(id, amount)
{
	cs_set_user_money_ul(id,amount);
}

// Get User Team
stock fm_get_user_team(id)
{
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX);
}

// Returns whether user is in a buyzone
stock fm_get_user_buyzone(id)
{
	if (get_pdata_int(id, OFFSET_MAPZONE) & PLAYER_IN_BUYZONE)
		return 1;

	return 0;
}


public setburn(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED_MAIN

	static ag[32]
	read_argv(1, ag, 31)
	static ag2[32],ag2p
	read_argv(2, ag2, 31)
	ag2p = cmd_target(id, ag2, (CMDTARGET_ALLOW_SELF))
	if (!ag2p)
		return PLUGIN_HANDLED_MAIN
	if(ag[0] == '@') {
		if(equali(ag[1],"ALL")) {
		for( new i = 1; i <= 33; i++ ) {
				if (is_user_connected(i) && is_user_alive(i)) {
					burning(i, ag2p)
				}
            }
		}
	} else {
	static target
	target = cmd_target(id, ag, (CMDTARGET_ALLOW_SELF))

	if(!is_user_connected(target) || !is_user_alive(target))
		return PLUGIN_HANDLED_MAIN;

	burning(target, ag2p);
	}
	return PLUGIN_HANDLED

}

public burning(victim,attacker) {
	// Only effect alive players
	if (!is_user_alive(victim))
		return PLUGIN_HANDLED;

	// Heat icon
	message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
	write_byte(0) // damage save
	write_byte(0) // damage take
	write_long(DMG_BURN) // damage type
	write_coord(0) // x
	write_coord(0) // y
	write_coord(0) // z
	message_end()

	// Our task params
	static params[2]
	params[0] = get_pcvar_num(cvar_duration)*5 // duration
	params[1] = attacker // attacker

	// Set burning task on victim
	set_task(0.1, "burning_flame2", victim+TASK_BURN, params, sizeof params)
	return PLUGIN_HANDLED

}

public burning_flame2(args[2], taskid)
{
	// Player died/disconnected
	if (!is_user_connected(ID_BURN) || !is_user_alive(ID_BURN))
		return PLUGIN_HANDLED;

	// Get player origin and flags
	static Float:originF[3], flags
	pev(ID_BURN, pev_origin, originF)
	flags = pev(ID_BURN, pev_flags)

	// In water or burning stopped
	if ((flags & FL_INWATER) || FLAME_DURATION < 1 || get_user_godmode(ID_BURN))
	{
		// Smoke sprite
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()

		return PLUGIN_HANDLED;
	}

	// Get screams setting
	static screams
	screams = get_pcvar_num(cvar_screamrate)

	// Randomly play burning sounds
	if (screams > 0 && random_num(1, screams) == 1) {
		//if (is_user_zombie(ID_BURN)) engfunc(EngFunc_EmitSound, ID_BURN, CHAN_VOICE, grenade_fire_player_zm[random_num(0, sizeof grenade_fire_player_zm - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM);
		/*else*/ engfunc(EngFunc_EmitSound, ID_BURN, CHAN_VOICE, grenade_fire_player[random_num(0, sizeof grenade_fire_player - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}

	// Get fire slowdown setting
	static Float:slowdown
	slowdown = get_pcvar_float(cvar_slowdown)

	// Fire slow down
	if (slowdown > 0.0 && (flags & FL_ONGROUND))
	{
		static Float:velocity[3]
		pev(ID_BURN, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, slowdown, velocity)
		set_pev(ID_BURN, pev_velocity, velocity)
	}

	// Get health and fire damage setting
	static health, damage
	health = pev(ID_BURN, pev_health)
	damage = get_pcvar_num(cvar_damage)

	// Take damage from the fire
	if (health > damage)
		fm_set_user_health(ID_BURN, health - damage)
	else if (get_pcvar_num(cvar_cankill))
	{
		// Kill the victim
		//ExecuteHamB(Ham_Killed, ID_BURN, FLAME_ATTACKER, 0)
		set_msg2(ID_BURN,FLAME_ATTACKER)

		// Smoke sprite
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()

		return PLUGIN_HANDLED;
	}

	// Flame sprite
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPRITE) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]+random_float(-5.0, 5.0)) // x
	engfunc(EngFunc_WriteCoord, originF[1]+random_float(-5.0, 5.0)) // y
	engfunc(EngFunc_WriteCoord, originF[2]+random_float(-10.0, 10.0)) // z
	write_short(g_flameSpr) // sprite
	write_byte(random_num(5, 10)) // scale
	write_byte(200) // brightness
	message_end()

	// Decrease task cycle count
	FLAME_DURATION -= 1;

	// Keep sending flame messages
	set_task(0.2, "burning_flame2", taskid, args, sizeof args)
	return PLUGIN_HANDLED
}

public set_msg(victim,attacker) {

	if(!is_user_connected(victim))
		return

	if(!is_user_connected(attacker))
		attacker = 0

	if (!is_user_zombie(victim) && !is_user_zombie(attacker))
		return

	message_begin(MSG_ALL, g_msgDeathMsg, {0, 0, 0} ,0)
	write_byte(attacker)
	write_byte(victim)
	write_byte(0)
	write_string("grenade")
	message_end()

	set_msg_block(g_msgDeathMsg, BLOCK_ONCE)
	set_user_health(victim, 0)
	if (attacker) {
		cs_set_user_money_ul(attacker,cs_get_user_money_ul(attacker)+1500)
		set_user_frags(attacker, get_user_frags(attacker) + 1)
		//if (!is_user_zombie(attacker) && !user_has_weapon(attacker,CSW_HEGRENADE))	give_item(attacker,"weapon_hegrenade")

		if (!is_user_zombie(attacker) && cs_get_user_bpammo(attacker, CSW_HEGRENADE)<3) {
			if (!user_has_weapon(attacker,CSW_HEGRENADE))
				give_item(attacker,"weapon_hegrenade")
			else {
				cs_set_user_bpammo( attacker, CSW_HEGRENADE, cs_get_user_bpammo(attacker, CSW_HEGRENADE)+1 )
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "AmmoPickup" ), _, attacker );
				write_byte( 12 );
				write_byte( 1 );
				message_end();
				emit_sound( attacker, CHAN_ITEM, G_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			}
		}

		updatescore(attacker)
	}

}

public set_msg2(victim,attacker) {

	if(!is_user_connected(victim))
		return

	if(!is_user_connected(attacker) || attacker == victim)
		attacker = 0

	message_begin(MSG_ALL, g_msgDeathMsg, {0, 0, 0} ,0)
	write_byte(attacker)
	write_byte(victim)
	write_byte(0)
	write_string("grenade")
	message_end()

	set_msg_block(g_msgDeathMsg, BLOCK_ONCE)
	set_user_health(victim, 0)
	if (attacker) {
		cs_set_user_money_ul(attacker,cs_get_user_money_ul(attacker)+1500)
		set_user_frags(attacker, get_user_frags(attacker) + 1)
		if (!is_user_zombie(attacker) && !user_has_weapon(attacker,CSW_HEGRENADE))	give_item(attacker,"weapon_hegrenade")
		updatescore(attacker)
	}

}

public updatescore(id)
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