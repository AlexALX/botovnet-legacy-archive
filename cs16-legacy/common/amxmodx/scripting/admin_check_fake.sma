/*  
 * This plugin was created for Botov-NET Project
 * Always shows like there is no admin online (for detect cheaters)
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

/*---------------EDIT ME------------------*/
static const COLOR[] = "^x04" //green
/*----------------------------------------*/

new gmsgSayText

public plugin_init() {
	register_plugin("Admin Check Fake", "1.0", "AlexALX")
	gmsgSayText = get_user_msgid("SayText")
	register_clcmd("say /admins", "fake_admin", -1, "")
	register_clcmd("say /admin", "fake_admin", -1, "")
	register_clcmd("say /who", "fake_admin", -1, "")
	register_clcmd("/admins", "fake_admin", -1, "")
	register_clcmd("/admin", "fake_admin", -1, "")
	register_clcmd("/who", "fake_admin", -1, "")
	register_clcmd("say admins", "fake_admin", -1, "")
	register_clcmd("say admin", "fake_admin", -1, "")
	register_clcmd("say who", "fake_admin", -1, "")
	register_clcmd("admins", "fake_admin", -1, "")
	register_clcmd("admin", "fake_admin", -1, "")
	register_clcmd("who", "fake_admin", -1, "")
}

public fake_admin(id) {

	new message[256],len

	len = format(message, 255, "%s ADMINS ONLINE: ^x01",COLOR)
	len += format(message[len], 255-len, "No admins online.")
	print_message(id, message)

	return PLUGIN_CONTINUE;
}

print_message(id, msg[]) {
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}
