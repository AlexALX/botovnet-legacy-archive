/*  
 * This plugin was created for Botov-NET Project
 * It adds invisible/god/noclip chat command for admins
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
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <cstrike>
//#include <zmnofs>
//#include <santahat>
//#include <biohazard>

#define PLUGIN "Invis"
#define VERSION "1.0"
#define AUTHOR "AlexALX"

#define G_PICKUP_SND	"items/9mmclip1.wav"

enum
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T,
	CS_TEAM_CT,
	CS_TEAM_SPECTATOR
}

public plugin_init()
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_forward( FM_PlayerPreThink, "forward_player_prethink" );
	register_event( "DeathMsg", "Hook_Deathmessage", "a" );

	register_clcmd( "amx_invis", "cmd_invis", ADMIN_RCON, "<nick or #userid>");
	register_clcmd( "amx_god", "cmd_god", ADMIN_RCON, "<nick or #userid>");
	register_clcmd( "amx_noclip", "cmd_noclip", ADMIN_RCON, "<nick or #userid>");
	register_clcmd( "amx_gren", "cmd_gren", ADMIN_BAN, "<nick or #userid>");

}

public plugin_precache()
{
	precache_sound( G_PICKUP_SND );
}


stock is_user_zombie(index)
	return false

stock user_footsteps( index, set = 1 )
{
	if( set )
	{
		set_pev( index, pev_flTimeStepSound, 999 );
	}
	else
	{
		set_pev( index, pev_flTimeStepSound, 400 );
	}
	return 1;
}

public Hook_Deathmessage()
{
	new id = read_data( 2 );

		//fm_set_rendering( id );
	user_footsteps(id,0);

	return PLUGIN_CONTINUE;
}

public cmd_invis(id, level, cid) {

	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	new arg[32],arg2[32];

	read_argv(1, arg, 31);
	read_argv(2, arg2, 31);
	new invis = str_to_num(arg2);
	if(arg[0] == '@') {
		if(equali(arg[1],"ALL")) {
			for(new i = 1; i < 33; i++) {
				if (is_user_connected(i) && is_user_alive(i)) {
					if (invis == 1) {
						fm_set_rendering( i, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );
						if (!is_user_zombie(i)) user_footsteps(i,1);
					} else {
						fm_set_rendering( i, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );
						user_footsteps(i,1);
					}
				}
			}
		}
	} else {
		new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE);

		if (!player)
			return PLUGIN_HANDLED;

		if (invis == 1) {
			fm_set_rendering( player, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );
			if (!is_user_zombie(player)) user_footsteps(player,1);
		} else {
   		 	fm_set_rendering( player, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );
			user_footsteps(player,1);
		}
	}
	return PLUGIN_HANDLED;

}

public cmd_gren(id, level, cid) {

	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	new arg[32],arg2[32],arg3[32];

	read_argv(1, arg, 31);
	read_argv(2, arg2, 31);
	read_argv(3, arg3, 31);
	new invis = str_to_num(arg2);
	if(arg[0] == '@') {
		if(equali(arg[1],"ALL")) {
			for(new player = 1; player < 33; player++) {
				if (is_user_connected(player) && is_user_alive(player)) {
					if (invis == 1) {
						if (!user_has_weapon(player,CSW_HEGRENADE)) give_item(player,"weapon_hegrenade");
						cs_set_user_bpammo( player, CSW_HEGRENADE, str_to_num( arg3 ) )
						message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "AmmoPickup" ), _, player );
						write_byte( 12 );
						write_byte( str_to_num( arg3 ) );
						message_end();
						emit_sound( player, CHAN_ITEM, G_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
					} else if (invis == 2) {
						if (!user_has_weapon(player,CSW_FLASHBANG)) give_item(player,"weapon_flashbang");
						cs_set_user_bpammo( player, CSW_FLASHBANG, str_to_num( arg3 ) )
						message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "AmmoPickup" ), _, player );
						write_byte( 11 );
						write_byte( str_to_num( arg3 ) );
						message_end();
						emit_sound( player, CHAN_ITEM, G_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
					} else if (invis == 3) {
						if (!user_has_weapon(player,CSW_SMOKEGRENADE)) give_item(player,"weapon_smokegrenade");
						cs_set_user_bpammo( player, CSW_SMOKEGRENADE, str_to_num( arg3 ) )
						message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "AmmoPickup" ), _, player );
						write_byte( 13 );
						write_byte( str_to_num( arg3 ) );
						message_end();
						emit_sound( player, CHAN_ITEM, G_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
					}
				}
			}
		}
	} else {
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE);

	if (!player)
		return PLUGIN_HANDLED;

	if (invis == 1) {
		if (!user_has_weapon(player,CSW_HEGRENADE)) give_item(player,"weapon_hegrenade");
		cs_set_user_bpammo( player, CSW_HEGRENADE, str_to_num( arg3 ) )
		message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "AmmoPickup" ), _, player );
		write_byte( 12 );
		write_byte( str_to_num( arg3 ) );
		message_end();
		emit_sound( player, CHAN_ITEM, G_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
	} else if (invis == 2) {
		if (!user_has_weapon(player,CSW_FLASHBANG)) give_item(player,"weapon_flashbang");
		cs_set_user_bpammo( player, CSW_FLASHBANG, str_to_num( arg3 ) )
		message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "AmmoPickup" ), _, player );
		write_byte( 11 );
		write_byte( str_to_num( arg3 ) );
		message_end();
		emit_sound( player, CHAN_ITEM, G_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
	} else if (invis == 3) {
		if (!user_has_weapon(player,CSW_SMOKEGRENADE)) give_item(player,"weapon_smokegrenade");
		cs_set_user_bpammo( player, CSW_SMOKEGRENADE, str_to_num( arg3 ) )
		message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "AmmoPickup" ), _, player );
		write_byte( 13 );
		write_byte( str_to_num( arg3 ) );
		message_end();
		emit_sound( player, CHAN_ITEM, G_PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
	}
	}
	return PLUGIN_HANDLED;

}

public cmd_god(id, level, cid) {

	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	new arg[32],arg2[32];

	read_argv(1, arg, 31);
	read_argv(2, arg2, 31);
	new invis = str_to_num(arg2);
	if(arg[0] == '@') {
		if(equali(arg[1],"ALL")) {		for(new i = 1; i < 33; i++) {
	if (is_user_connected(i) && is_user_alive(i)) {
	if (!invis) {
	set_user_godmode(i,0);
	//set_user_rendering(i);
	} else {
	set_user_godmode(i,1);
	//set_user_rendering(i, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25);
	}
	}
	}
		}
	} else {
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE);

	if (!player)
		return PLUGIN_HANDLED;

	if (!invis) {
	set_user_godmode(player,0);
	//set_user_rendering(player);
	} else {
	set_user_godmode(player,1);
	//set_user_rendering(player, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25);
	}
	}
	return PLUGIN_HANDLED;

}

public cmd_noclip(id, level, cid) {

	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	new arg[32],arg2[32];

	read_argv(1, arg, 31);
	read_argv(2, arg2, 31);
	new invis = str_to_num(arg2);
	if(arg[0] == '@') {
		if(equali(arg[1],"ALL")) {		for(new i = 1; i < 33; i++) {
	if (is_user_connected(i) && is_user_alive(i)) {
	if (!invis) {
	set_user_noclip(i,0);
	} else {
	set_user_noclip(i,1);
	}
	}
	}
		}
	} else {
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE);

	if (!player)
		return PLUGIN_HANDLED;

	if (!invis) {
	set_user_noclip(player,0);
	} else {
	set_user_noclip(player,1);
	}
	}
	return PLUGIN_HANDLED;

}
/*
stock reset_user_model(index)
{
	set_pev(index, pev_rendermode, kRenderNormal)
	set_pev(index, pev_renderamt, 0.0)

	//if(pev_valid(g_modelent[index]))
		fm_set_entity_visibility(g_modelent[index], 0)
}

stock remove_user_model(ent)
{
	static id
	id = pev(ent, pev_owner)

	if(pev_valid(ent))
		engfunc(EngFunc_RemoveEntity, ent)

	//g_modelent[id] = 0
}

stock fm_set_entity_visibility(index, visible = 1)
	set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW)
	*/