/*  
 * This plugin was created for Botov-NET Project
 * In past allowed to navigate between servers by simple chat command
 * With never updates of steam this will probably NEVER work again
 * But published for archive
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

#define PLUGIN "Simple server command"
#define VERSION "1.1"
#define AUTHOR "AlexALX"

const KEYS_M = MENU_KEY_0 | MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9;
new RedirectServer[33][128], RedirectName[33][128];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /server","menu_server")
	register_clcmd("say_team /server","menu_server")
	register_clcmd("say server","menu_server")
	register_clcmd("say_team server","menu_server")
	register_clcmd("/server","menu_server")
	register_clcmd("server","menu_server")
	register_menucmd( register_menuid( "Servers Menu" ), KEYS_M, "menu_server" );
	register_dictionary( "server.txt" );
}

public menu_server( id )
{

	new szText[ 768 char ];
	formatex( szText, charsmax( szText ), "\r%L", id, "SERVER_CMD_TITLE" );
	new menu = menu_create( szText, "server_menu" );

	new Port[6];
	get_cvar_string("port", Port, 5);

	if (equal(Port,"27015")) {
		formatex( szText, charsmax( szText ), "Classic - \ybotov.net.ua:27015 \d- \r%L",id,"SERVER_CMD_CURRENT");
		menu_additem( menu, szText, "1", ADMIN_ADMIN );
	} else {
		formatex( szText, charsmax( szText ), "Classic - \ybotov.net.ua:27015");
		menu_additem( menu, szText, "1", 0 );
	}

	if (equal(Port,"27020")) {
		formatex( szText, charsmax( szText ), "Biohazard - \ybotov.net.ua:27020 \d- \r%L",id,"SERVER_CMD_CURRENT");
		menu_additem( menu, szText, "2", ADMIN_ADMIN );
	} else {
		formatex( szText, charsmax( szText ), "Biohazard - \ybotov.net.ua:27020");
		menu_additem( menu, szText, "2", 0 );
	}

	if (equal(Port,"27016")) {
		formatex( szText, charsmax( szText ), "DeathRun - \ybotov.net.ua:27016 \d- \r%L",id,"SERVER_CMD_CURRENT");
		menu_additem( menu, szText, "3", ADMIN_ADMIN );
	} else {
		formatex( szText, charsmax( szText ), "DeathRun - \ybotov.net.ua:27016");
		menu_additem( menu, szText, "3", 0 );
	}

	if (equal(Port,"27017")) {
		formatex( szText, charsmax( szText ), "War3FT - \ybotov.net.ua:27017 \d- \r%L",id,"SERVER_CMD_CURRENT");
		menu_additem( menu, szText, "4", ADMIN_ADMIN );
	} else {
		formatex( szText, charsmax( szText ), "War3FT - \ybotov.net.ua:27017");
		menu_additem( menu, szText, "4", 0 );
	}

	if (equal(Port,"27018")) {
		formatex( szText, charsmax( szText ), "GunGame - \ybotov.net.ua:27018 \d- \r%L",id,"SERVER_CMD_CURRENT");
		menu_additem( menu, szText, "5", ADMIN_ADMIN );
	} else {
		formatex( szText, charsmax( szText ), "GunGame - \ybotov.net.ua:27018");
		menu_additem( menu, szText, "5", 0 );
	}

	if (equal(Port,"27019")) {
		formatex( szText, charsmax( szText ), "Surf - \ybotov.net.ua:27019 \d- \r%L",id,"SERVER_CMD_CURRENT");
		menu_additem( menu, szText, "6", ADMIN_ADMIN );
	} else {
		formatex( szText, charsmax( szText ), "Surf - \ybotov.net.ua:27019");
		menu_additem( menu, szText, "6", 0 );
	}

	if (equal(Port,"27021")) {
		formatex( szText, charsmax( szText ), "DM-FFA - \ybotov.net.ua:27021 \d- \r%L",id,"SERVER_CMD_CURRENT");
		menu_additem( menu, szText, "7", ADMIN_ADMIN );
	} else {
		formatex( szText, charsmax( szText ), "DM-FFA - \ybotov.net.ua:27021");
		menu_additem( menu, szText, "7", 0 );
	}

	menu_addblank(menu,0);

	formatex( szText, charsmax( szText ), "\wGarry's mod - \ybotov.net.ua:28015");
	menu_addtext(menu,szText,1);

	menu_addblank(menu,1);

	formatex( szText, charsmax( szText ), "\w%L",id,"SERVER_CMD_INFO");
	menu_addtext(menu,szText,0);

	menu_addblank(menu,0);

	formatex( szText, charsmax( szText ), "%L", id, "SERVER_CMD_EXIT");
	menu_additem( menu, szText, "0", 0 );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL); //, MEXIT_ALL
	new string[100];
	formatex( string, sizeof string - 1, "%L", id, "SERVER_CMD_EXIT" );
	menu_setprop( menu, MPROP_EXITNAME, string );

	new num = 0;
	menu_setprop( menu, MPROP_PERPAGE, num);

	menu_display( id, menu, 0 );

	if (equal(Port,"27015")) {
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_HANDLED;
}

stock return_ip(server[]) {
	new servername[128];
	if (equal(server,"Classic")) {
		servername = "botov.net.ua:27015";
	} else if (equal(server,"Biohazard")) {
		servername = "botov.net.ua:27020";
	} else if (equal(server,"Deathrun")) {
		servername = "botov.net.ua:27016";
	} else if (equal(server,"War3FT")) {
		servername = "botov.net.ua:27017";
	} else if (equal(server,"GunGame")) {
		servername = "botov.net.ua:27018";
	} else if (equal(server,"Surf")) {
		servername = "botov.net.ua:27019";
	} else if (equal(server,"DM-FFA")) {
		servername = "botov.net.ua:27021";
	}
	return servername;
}

public server_menu( id, menu, item )
{

	/*RedirectServer[id] = "";
	RedirectName[id] = "";*/

	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}

	new data[ 6 ], iName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

	new key = str_to_num( data );

	new Name[ 32 ];
	get_user_name( id, Name, 31 );
	RedirectName[id] = Name;

	switch( key )
	{
		case 1:
		{
			RedirectServer[id] = "Classic";
			client_cmd(id, "Connect botov.net.ua:27015");
			set_task(0.1,"check_redirect",id);
			menu_destroy( menu );
		}
		case 2:
		{
			RedirectServer[id] = "Biohazard";
			client_cmd(id, "Connect botov.net.ua:27020");
			set_task(0.1,"check_redirect",id);
			menu_destroy( menu );
		}
		case 3:
		{
			RedirectServer[id] = "DeathRun";
			client_cmd(id, "Connect botov.net.ua:27016");
			set_task(0.1,"check_redirect",id);
			menu_destroy( menu );
		}
		case 4:
		{
			RedirectServer[id] = "War3FT";
			client_cmd(id, "Connect botov.net.ua:27017");
			set_task(0.1,"check_redirect",id);
			menu_destroy( menu );
		}
		case 5:
		{
			RedirectServer[id] = "GunGame";
			client_cmd(id, "Connect botov.net.ua:27018");
			set_task(0.1,"check_redirect",id);
			menu_destroy( menu );
		}
		case 6:
		{
			RedirectServer[id] = "Surf";
			client_cmd(id, "Connect botov.net.ua:27019");
			set_task(0.1,"check_redirect",id);
			menu_destroy( menu );
		}
		case 7:
		{
			RedirectServer[id] = "DM-FFA";
			client_cmd(id, "Connect botov.net.ua:27021");
			set_task(0.1,"check_redirect",id);
			menu_destroy( menu );
		}
		case 0:
		{
			menu_destroy( menu );
		}
	}
	return PLUGIN_HANDLED;
}

public check_redirect(id) {
	if (is_user_connected(id)) {
		client_print(0,print_chat,"%L",LANG_PLAYER,"SERVER_CMD_PLAYERN",RedirectName[id],RedirectServer[id],return_ip(RedirectServer[id]));
		client_print(id,print_chat,"%L",LANG_PLAYER,"SERVER_CMD_MANUAL",RedirectServer[id],return_ip(RedirectServer[id]));
	} else {
		client_print(0,print_chat,"%L",LANG_PLAYER,"SERVER_CMD_PLAYER",RedirectName[id],RedirectServer[id],return_ip(RedirectServer[id]));
	}
	RedirectServer[id] = "";
	RedirectName[id] = "";
	return PLUGIN_CONTINUE;
}