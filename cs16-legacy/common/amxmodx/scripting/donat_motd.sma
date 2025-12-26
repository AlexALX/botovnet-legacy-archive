/*  
 * This plugin was created for Botov-NET Project
 * Just add chat commands to show MOTH with donation page
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

static const PLUGIN_NAME[] = "Сбор средств"
static const PLUGIN_AUTHOR[] = "AlexALX"
static const PLUGIN_VERSION[] = "1.1"

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_clcmd("say /donation", "cmd_donationmotd")
	register_clcmd("say donation", "cmd_donationmotd")
	register_clcmd("say /donat", "cmd_donationmotd")
	register_clcmd("say donat", "cmd_donationmotd")
	register_clcmd("/donation", "cmd_donationmotd")
	register_clcmd("donation", "cmd_donationmotd")
	register_clcmd("/donat", "cmd_donationmotd")
	register_clcmd("donat", "cmd_donationmotd")
	register_clcmd("say /поддержка", "cmd_donationmotd")
	//register_dictionary("donat.txt")

	set_task(0.8, "checktime", 6642458, "", 0, "b")

	return PLUGIN_CONTINUE

}

public cmd_donationmotd(id)
{
	static motd[2048]
	formatex(motd, 2047, "<html> \
	<head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'> \
	<META HTTP-EQUIV='refresh' CONTENT='0; URL=http://botov.net.ua/motd-ingame.php'> \
		<style type='text/css'> \
			pre \
			{ \
				font-family:Verdana,Tahoma; \
				color:#FFF; \
			} \
			body \
			{ \
				background:#000; \
				margin-left:8px; \
				margin-top:0px; \
			} \
		</style> \
	</head> \
	<body> \
	</body> \
</html>")

	show_motd(id, motd, "Server information")

	return PLUGIN_CONTINUE
}

const m_flNextAttack = 83

public cmd_donationmotd_all()
{
	new players[32], pnum

	get_players(players, pnum, "ch");

	for (new i = 0; i < pnum; i++)
	{
		if (is_user_connected(players[i])) {
			cmd_donationmotd(players[i]);

			if (is_user_alive(players[i])) {
				set_pev( players[i] , pev_velocity , { 0.0 , 0.0 , 0.0 } );
				set_pev( players[i] , pev_flags , pev( players[i] , pev_flags ) | FL_FROZEN );
				set_pdata_float( players[i], m_flNextAttack, 9999.0 );
			}

		}
	}
}

public checktime()
{
	new timeleft = get_timeleft()

	if (timeleft<=0) {

		remove_task(6642458);

	} else if (timeleft<9) {

		cmd_donationmotd_all();

	}
}