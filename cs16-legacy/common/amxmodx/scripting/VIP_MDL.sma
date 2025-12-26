/*  
 * This plugin was created for Botov-NET Project
 * This uses custom VIP system, and making VIPS to have different player model
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
#include <hamsandwich>
#include <cstrike>
#include <vip>

new bool:MDLS[33];

public plugin_init() {
    register_plugin("VIP Model Classic", "1.1", "AlexALX")

    new szMapName[ 30 ];
    get_mapname( szMapName, charsmax( szMapName ) );

    if( containi( szMapName, "as_" )==-1)
    {
        RegisterHam( Ham_Spawn, "player", "bacon_Spawned", 1 );
    }
}

public plugin_precache()
{
	precache_model("models/player/vip_bn/vip_bn.mdl")
	precache_model("models/player/vip_bn/vip_bnT.mdl")
}

public bacon_Spawned( id )
{
    if( is_user_alive( id ))
    {
        if( cs_get_user_team( id ) == CS_TEAM_CT && get_vip_options(id) & VIP_FLAG_M) {
            cs_set_user_model( id, "vip_bn" );
            MDLS[id] = true;
        } else if( cs_get_user_team( id ) == CS_TEAM_T && get_vip_options(id) & VIP_FLAG_M) {
            cs_set_user_model( id, "vip" );
            MDLS[id] = true;
        } else if(MDLS[id]) {
        	cs_reset_user_model(id);
        	MDLS[id] = false;
        }
    }
}

public client_connect(id) {
	MDLS[id] = false;
}

public client_disconnect(id) {
	MDLS[id] = false;
}