/*  
 * This plugin was created for Botov-NET Project
 * This uses custom VIP system, and making VIPS to have smoke grenade for gungame server
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
#include <fun>
#include <vip>

public plugin_init() {
    register_plugin("VIP GunGame", "1.0", "AlexALX")

    RegisterHam( Ham_Spawn, "player", "bacon_Spawned", 1 );
}

public bacon_Spawned( id )
{
    if( get_vip_flags(id) & VIP_FLAG_C)
    {
        give_item(id, "weapon_smokegrenade")
    }
}