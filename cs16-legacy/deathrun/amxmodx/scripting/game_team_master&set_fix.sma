/*
game_team_master & game_team_set fix for CS 1.6
Created by AlexALX (c) 2010 http://alex-php.net/
=========
Created special for map deathrun_skills_edited
Big thanks Arkshine (http://forums.alliedmods.net/member.php?u=7779)
For help in creating plugin.
=========
For game_team_master specify team in team index:
-1 - anyone can activate
1 - only Terrorist can activate
2 - only CT can activate
=========
For game_team_set is now possible to specify a team to change for game_team_master:
-1 - changes team to all
0 - changes team to activator team (default)
1 - changes team to Terrorist
2 - changes team to CT
For specify team you must disable SmartEdit in Valve Hammer Editor and add manualy this:
Key: team, Value: 2 (or other)
Attention! Do not fix error in Valve Hammer Editor (alt+p):
Entity (game_team_set) has unused keyvalues.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/
#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>

enum USE_TYPE { USE_OFF = 0, USE_ON = 1, USE_SET = 2, USE_TOGGLE = 3 };

const m_iszMaster = 34;
const m_teamIndex = 35;
const triggerType = 36;

#define RemoveOnFire(%0) ( pev( %0, pev_spawnflags ) & SF_TEAMMASTER_FIREONCE )
#define ShouldClearTeam(%0)  ( pev( %0, pev_spawnflags ) & SF_TEAMSET_CLEARTEAM   )
#define AnyTeam(%0)  ( pev( %0, pev_spawnflags ) & SF_TEAMMASTER_ANYTEAM  )

public plugin_init()
{
	register_plugin( "game_team_master & game_team_set Fix", "0.3", "AlexALX / Arkshine" );
	RegisterHam( Ham_Use, "game_team_master", "CGameTeamMaster_Use" );
	RegisterHam( Ham_Use, "game_team_set"   , "CGameTeamSet_Use");
}

public CGameTeamMaster_Use( const gameTeamMaster, const activator, const caller, const USE_TYPE:useType, const Float:value )
{
	if ( !CanFireForActivator( gameTeamMaster, activator ) ) return HAM_IGNORED;

	if ( CGameTeamMaster_TeamMatch( gameTeamMaster, activator ) )
	{
		SUB_UseTargets( gameTeamMaster, activator, USE_TYPE:get_pdata_int( gameTeamMaster, triggerType, 4 ), value );
		if ( RemoveOnFire( gameTeamMaster ) ) UTIL_Remove( gameTeamMaster );
	}
	return HAM_SUPERCEDE;
}

public CGameTeamSet_Use( const gameTeamSet, const activator, const caller, const USE_TYPE:useType, const Float:value )
{
	if ( !CanFireForActivator( gameTeamSet, activator ) ) return HAM_IGNORED;

	new team = pev( gameTeamSet, pev_team );
	new target[ 32 ];
	pev( gameTeamSet, pev_target, target, charsmax( target ) );
	new master = engfunc( EngFunc_FindEntityByString, FM_NULLENT, "targetname", target );
	new value = team;

	if ( team < 0 || ShouldClearTeam( gameTeamSet ) ) value = -1;
	else if ( !team ) value = _:cs_get_user_team( activator );

	set_pdata_int( master, m_teamIndex, value );
	if ( RemoveOnFire( gameTeamSet ) ) UTIL_Remove( gameTeamSet );

	return HAM_SUPERCEDE;
}

bool:CGameTeamMaster_TeamMatch( const entity, const activator )
{
	new teamIndex = get_pdata_int( entity, m_teamIndex, 4 );
	if ( teamIndex < 0 || AnyTeam( entity ) ) return true;
	if ( !activator ) return false;
	return cs_get_user_team( activator ) == CsTeams:teamIndex;
}

bool:CanFireForActivator( const entity, const activator )
{
	new master = get_pdata_int( entity, m_iszMaster, 4 );
	if ( master ) return UTIL_IsMasterTriggered( master, activator );
	return true;
}

bool:UTIL_IsMasterTriggered( const master, const activator )
{
	if ( master )
	{
		new stringMaster[ 32 ];
		engfunc( EngFunc_SzFromIndex, stringMaster, charsmax( stringMaster ) );
		new target = engfunc( EngFunc_FindEntityByString, FM_NULLENT, "targetname", stringMaster );
		if ( target && ( ExecuteHam( Ham_ObjectCaps, target ) & FCAP_MASTER ) )
			return CGameTeamMaster_TeamMatch( target, activator );
	}
	return true;
}

SUB_UseTargets( const entity, const activator, USE_TYPE:useType, Float:value )
{
	new target[ 32 ];
	pev( entity, pev_target, target, charsmax( target ) );
	if ( target[ 0 ] ) FireTargets( target, activator, entity, useType, value );
}

FireTargets( const targetName[], const activator, const caller, USE_TYPE:useType, Float:value )
{
	if ( !targetName[ 0 ] )	return;
	new target = FM_NULLENT;
	while ( ( target = engfunc( EngFunc_FindEntityByString, target, "targetname", targetName ) ) )
		if ( target && ~pev( target, pev_flags ) & FL_KILLME )
			ExecuteHam( Ham_Use, target, activator, caller, useType, value );
}

UTIL_Remove( const entity )
{
	if ( entity )
	{
		set_pev( entity, pev_flags, pev( entity, pev_flags ) | FL_KILLME );
		set_pev( entity, pev_targetname, 0 );
	}
}