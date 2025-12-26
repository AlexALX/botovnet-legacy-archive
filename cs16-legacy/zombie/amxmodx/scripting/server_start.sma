/*  
 * This plugin was created for Botov-NET Project
 * It allow to change map into random map
 * Console command - "amx_randommap"
 * Also could be used in server.cfg on server start
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

static const PLUGIN_NAME[] = "Random Map Loader"
static const PLUGIN_AUTHOR[] = "AlexALX"
static const PLUGIN_VERSION[] = "1.0"

new Array:g_mapName;
new g_mapNums
new maps_ini_file[64];

//#define _random(%1) random_num(0, %1 - 1)

public plugin_init()
{

	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_concmd("amx_randommap", "cmd_map", ADMIN_LEVEL_A, "<nick or #userid>")

	g_mapName=ArrayCreate(32);

	get_configsdir(maps_ini_file, 63);
	format(maps_ini_file, 63, "%s/maps.ini", maps_ini_file);

	if (!file_exists(maps_ini_file))
		get_cvar_string("mapcyclefile", maps_ini_file, sizeof(maps_ini_file) - 1);

	if (!file_exists(maps_ini_file))
		format(maps_ini_file, 63, "mapcycle.txt")

	//load_settings(maps_ini_file)
	register_dictionary("randommap.txt");

}

public cmd_map(id, level, cid) {

	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED_MAIN

	load_settings(maps_ini_file,id)

	return true;

}

stock bool:ValidMap(mapname[])
{
	if ( is_map_valid(mapname) )
	{
		return true;
	}
	// If the is_map_valid check failed, check the end of the string
	new len = strlen(mapname) - 4;

	// The mapname was too short to possibly house the .bsp extension
	if (len < 0)
	{
		return false;
	}
	if ( equali(mapname[len], ".bsp") )
	{
		// If the ending was .bsp, then cut it off.
		// the string is byref'ed, so this copies back to the loaded text.
		mapname[len] = '^0';

		// recheck
		if ( is_map_valid(mapname) )
		{
			return true;
		}
	}

	return false;
}

load_settings(filename[],id)
{
	new fp = fopen(filename, "r");

	if (!fp)
	{
		return 0;
	}


	new text[256];
	new tempMap[32];

	while (!feof(fp))
	{
		fgets(fp, text, charsmax(text));

		if (text[0] == ';')
		{
			continue;
		}
		if (parse(text, tempMap, charsmax(tempMap)) < 1)
		{
			continue;
		}
		if (!ValidMap(tempMap))
		{
			continue;
		}

		ArrayPushString(g_mapName, tempMap);
		//g_mapName[g_mapNums] = tempMap
		g_mapNums++;
	}

	//new tempMap[32];
	ArrayGetString(g_mapName, random_num(0,g_mapNums), tempMap, charsmax(tempMap));

	if (id!=0) {
		new authid[32], name[32]
		get_user_authid(id, authid, 31)
		get_user_name(id, name, 31)
		log_amx("^"%s<%d><%s><>^" load random map", name, get_user_userid(id), authid)
		show_activity_key("RAND_1", "RAND_2", name)
	} else {
		log_amx("Server: load random map")
	}

	new configsDir[64]
	get_configsdir(configsDir, 63)
	server_cmd("exec %s/amxx.cfg", configsDir)
	if (id!=0) {
		new _modName[10]
		get_modname(_modName, 9)
		if (!equal(_modName, "zp"))
		{
			message_begin(MSG_ALL, SVC_INTERMISSION)
			message_end()
		}
		set_task(2.0, "delayedChange", 0, tempMap, strlen(tempMap) + 1)
	} else
		server_cmd("changelevel %s", tempMap)

	return 1;
}

public delayedChange(mapname[])
	server_cmd("changelevel %s", mapname)