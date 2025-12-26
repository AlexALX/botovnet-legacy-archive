/***
 *
 * Original autor - xPaw
 *
 * This plugin was edited for Botov-NET Project
 * Copyring by AlexALX (c) 2015
 *
 * ------------------------  
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
#include <engine>
#include <fakemeta>

#define m_flWait 44
#define m_flDelay 34

public plugin_init( ) {
	register_plugin( "Deathrun Maps Fixer", "1.8.1", "xPaw / AlexALX" );

	register_cvar( "deathrun_mapsfixer", "1.8.1", FCVAR_SERVER | FCVAR_SPONLY );

	new szMapname[ 32 ];
	get_mapname( szMapname, charsmax( szMapname ) );

	if( equali( szMapname, "deathrun_nightmare_beta2" ) )
		remove_entity( find_ent_by_model( -1, "func_wall", "*95" ) );
	else if( equali( szMapname, "deathrun_impossible_last" ) )
		remove_entity( find_ent_by_model( -1, "func_wall", "*112" ) );
	else if( equali( szMapname, "deathrun_impossible" ) )
		remove_entity( find_ent_by_model( -1, "func_wall", "*119" ) );
	else if( equali( szMapname, "deathrun_insane" ) )
		FixMap_Insane( );
	else if( equali( szMapname, "deathrun_caves" ) )
		CreateTriggerHurt( Float:{ 1420.0, 629.0, 279.0 }, Float:{ 1555.0, 1101.0, 309.0 } );
	else if( equali( szMapname, "deathrun_bkm" ) )
		FixMap_Bkm( );
	else if( equali( szMapname, "deathrun_piirates" ) )
		FixMap_Piirates( );
	else if( equali( szMapname, "deathrun_pirates_final" ) )
		FixMap_Pirates( );
	else if( equali( szMapname, "deathrun_fatality_beta5" ) )
		FixMap_Fatality( 0 );
	else if( equali( szMapname, "deathrun_fatality_beta6" ) )
		FixMap_Fatality( 1 );
	else if( equali( szMapname, "deathrun_meadsy_final" ) )
		FixMap_Meadsy( );
	else if( equali( szMapname, "deathrun_aztecrun" ) )
		FixMap_AztecRun( );
	else if( equali( szMapname, "deathrun_pyramid" ) )
		FixMap_Pyramid( );
	else if( equali( szMapname, "deathrun_cxx-inc" ) )
		FixMap_CxxInc( );
	else if( equali( szMapname, "deathrun_mordownia" ) )
		FixMap_Mordownia( );
	else if( equali( szMapname, "deathrun_W0RMS" ) )
		FixMap_Worms( );
	else if( equali( szMapname, "deathrun_hotel_b6" ) )
		FixMap_Hotel( );
	else if( equali( szMapname, "deathrun_fs-facility" ) )
		FixMap_FsFacility( );
	else if( equali( szMapname, "deathrun_proz_final" ) )
		remove_entity( find_ent_by_model( -1, "func_door", "*80" ) );
	else if( equali( szMapname, "deathrun_simpsons" ) )
		FixMap_Simpsons( );
	else if( equali( szMapname, "deathrun_junkie" ) )
		FixMap_Junkie( );
	else if( equali( szMapname, "deathrun_hills" ) )
		FixMap_Hills( );
}

FixMap_Insane( ) {
	remove_entity( find_ent_by_model( -1, "func_wall", "*144" ) );

	// Anti stuck bug in trap
	DispatchKeyValue( find_ent_by_model( -1, "func_door_rotating", "*71" ), "dmg", "1000" );
	DispatchKeyValue( find_ent_by_model( -1, "func_door_rotating", "*72" ), "dmg", "1000" );

	// Hurt higher damage
	DispatchKeyValue( find_ent_by_model( -1, "trigger_hurt", "*135" ), "dmg", "300" );

	// Push replace to hurt
	new Float:vMins[ 3 ], Float:vMaxs[ 3 ];
	new iEntity = find_ent_by_model( -1, "trigger_push", "*140" );
	entity_get_vector( iEntity, EV_VEC_mins, vMins );
	entity_get_vector( iEntity, EV_VEC_maxs, vMaxs );
	remove_entity( iEntity );
	CreateTriggerHurt( vMins, vMaxs );

	// Button replace to door
	new Float:vOrigin[ 3 ];
	iEntity = find_ent_by_model( -1, "func_button", "*4" );
	entity_get_vector( iEntity, EV_VEC_origin, vOrigin );
	remove_entity( iEntity );

	iEntity = create_entity( "func_door" );

	if( is_valid_ent( iEntity ) ) {
		entity_set_vector( iEntity, EV_VEC_origin, vOrigin );
		entity_set_float( iEntity, EV_FL_speed, 700.0 );
		entity_set_string( iEntity, EV_SZ_targetname, "startpush" );
		entity_set_string( iEntity, EV_SZ_model, "*4" );

		DispatchKeyValue( iEntity, "angles", "0 270 0" );
		DispatchSpawn( iEntity );

		set_pdata_float( iEntity, m_flWait, 4.0, 4 );
	}
}

FixMap_Piirates( ) {
	new const Traps[ ][ ] = {
		"*19",
		"*44",
		"*49",
		"*82",
		"*95",
		"*117"
	};

	new const Angles[ ][ ] = { // <3 master4life
		"0 270 0",
		"-90 0 0",
		"0 180 0",
		"0 0 0",
		"0 90 0",
		"90 0 0"
	};

	new iEntity, Float:vOrigin[ 3 ], Float:flWait, Float:flDmg, Float:flSpeed, szTargetName[ 10 ];
	for( new i = 0; i < sizeof Traps; i++ ) {
		iEntity = find_ent_by_model( -1, "func_button", Traps[ i ] );

		if( iEntity > 0 ) {
			flWait = get_pdata_float( iEntity, m_flWait, 4 );
			flDmg = entity_get_float( iEntity, EV_FL_dmg );
			flSpeed = entity_get_float( iEntity, EV_FL_speed );
			entity_get_vector( iEntity, EV_VEC_origin, vOrigin );
			entity_get_string( iEntity, EV_SZ_targetname, szTargetName, charsmax( szTargetName ) );

			remove_entity( iEntity );

			iEntity = create_entity( "func_door" );
			if( is_valid_ent( iEntity ) ) {
				entity_set_vector( iEntity, EV_VEC_origin, vOrigin );
				entity_set_float( iEntity, EV_FL_dmg, flDmg );
				entity_set_float( iEntity, EV_FL_speed, flSpeed );
				entity_set_string( iEntity, EV_SZ_targetname, szTargetName );
				entity_set_string( iEntity, EV_SZ_model, Traps[ i ] );

				DispatchKeyValue( iEntity, "angles", Angles[ i ] );
				DispatchSpawn( iEntity );

				set_pdata_float( iEntity, m_flWait, flWait, 4 );
			}
		}
	}
}

FixMap_Pirates( ) {
	new const Traps[ ][ ] = {
		"*21",
		"*46",
		"*51",
		"*98"
	};

	new const Angles[ ][ ] = { // <3 master4life
		"0 270 0",
		"-90 0 0",
		"0 180 0",
		"0 90 0"
	};

	new iEntity, Float:vOrigin[ 3 ], Float:flWait, Float:flDmg, Float:flSpeed, szTargetName[ 10 ];
	for( new i = 0; i < sizeof Traps; i++ ) {
		iEntity = find_ent_by_model( -1, "func_button", Traps[ i ] );

		if( iEntity > 0 ) {
			flWait = get_pdata_float( iEntity, m_flWait, 4 );
			flDmg = entity_get_float( iEntity, EV_FL_dmg );
			flSpeed = entity_get_float( iEntity, EV_FL_speed );
			entity_get_vector( iEntity, EV_VEC_origin, vOrigin );
			entity_get_string( iEntity, EV_SZ_targetname, szTargetName, charsmax( szTargetName ) );

			remove_entity( iEntity );

			iEntity = create_entity( "func_door" );
			if( is_valid_ent( iEntity ) ) {
				entity_set_vector( iEntity, EV_VEC_origin, vOrigin );
				entity_set_float( iEntity, EV_FL_dmg, flDmg );
				entity_set_float( iEntity, EV_FL_speed, flSpeed );
				entity_set_string( iEntity, EV_SZ_targetname, szTargetName );
				entity_set_string( iEntity, EV_SZ_model, Traps[ i ] );

				DispatchKeyValue( iEntity, "angles", Angles[ i ] );
				DispatchSpawn( iEntity );

				set_pdata_float( iEntity, m_flWait, flWait, 4 );
			}
		}
	}
}

FixMap_Hotel( ) {
	// Make those doors to be silent, because it makes too much noise
	new iEntity;
	while( ( iEntity = find_ent_by_tname( iEntity, "z52" ) ) > 0 )
		entity_set_string( iEntity, EV_SZ_noise1, "common/null.wav" );
}

FixMap_Worms( ) {
	new const Breaks[ ][ ] = {
		"*1",
		"*2",
		"*5",
		"*15",
		"*16",
		"*17",
		"*18",
		"*19",
		"*20",
		"*33",
		"*34",
		"*35",
		"*36",
		"*153",
		"*156",
		"*158",
		"*159"
	};

	// Trigger only flag on breakables
	new iEntity;
	for( new i = 0; i < sizeof Breaks; i++ ) {
		iEntity = find_ent_by_model( -1, "func_breakable", Breaks[ i ] );

		entity_set_int( iEntity, EV_INT_spawnflags, SF_BREAK_TRIGGER_ONLY );
	}
}

FixMap_Mordownia( ) {
	new const Pushes[ ][ ] = {
		"*52",
		"*58"
	};

	new const Breaks[ ][ ] = {
		"*1",
		"*11",
		"*26",
		"*70"
	};

	// Replace pushes to hurt
	new iEntity, Float:flMins[ 3 ], Float:flMaxs[ 3 ];
	for( new i = 0; i < sizeof Pushes; i++ ) {
		iEntity = find_ent_by_model( -1, "trigger_push", Pushes[ i ] );

		entity_get_vector( iEntity, EV_VEC_mins, flMins );
		entity_get_vector( iEntity, EV_VEC_maxs, flMaxs );
		remove_entity( iEntity );

		CreateTriggerHurt( flMins, flMaxs );
	}

	// Trigger only flag on breakables
	for( new i = 0; i < sizeof Breaks; i++ ) {
		iEntity = find_ent_by_model( -1, "func_breakable", Breaks[ i ] );

		entity_set_int( iEntity, EV_INT_spawnflags, SF_BREAK_TRIGGER_ONLY );
	}
}

FixMap_Bkm( ) {
	new iEntity = find_ent_by_model( -1, "func_door_rotating", "*7" );
	remove_entity( iEntity );

	iEntity = find_ent_by_model( -1, "func_breakable", "*44" );

	// Trigger only flag on breakable
	entity_set_int( iEntity, EV_INT_spawnflags, SF_BREAK_TRIGGER_ONLY );
	entity_set_string( iEntity, EV_SZ_target, "" ); // clear it, bugfix

	iEntity = find_ent_by_model( -1, "func_breakable", "*43" );

	// Trigger only flag on breakable
	entity_set_int( iEntity, EV_INT_spawnflags, SF_BREAK_TRIGGER_ONLY );
	entity_set_string( iEntity, EV_SZ_target, "" ); // clear it, bugfix

	iEntity = find_ent_by_model( -1, "func_button", "*37" );
	set_pdata_float( iEntity, m_flWait, 4.0, 4 );
	iEntity = find_ent_by_model( -1, "func_button", "*30" );
	set_pdata_float( iEntity, m_flWait, 7.0, 4 );
	iEntity = find_ent_by_model( -1, "func_door_rotating", "*17" );
	set_pdata_float( iEntity, m_flWait, 1.0, 4 );

	// Create trigger_hurt, mapper forget 1 xD
	CreateTriggerHurt( Float:{ -608.0, -480.0, -608.0 }, Float:{ 1152.0, 1376.0, -588.0 } );
}

FixMap_Fatality( IsBeta6 ) {
	new Fatality_Glass[ 7 ][ 4 ], iGlassNum;

	if( !IsBeta6 ) {
		new const Beta6[ ][ ] = {
			"*40",
			"*91",
			"*92",
			"*54",
			"*75",
			"*52"
		};

		for( iGlassNum = 0; iGlassNum < sizeof Beta6; iGlassNum++ )
			copy( Fatality_Glass[ iGlassNum ], 3, Beta6[ iGlassNum ] );
	} else {
		new const Beta5[ ][ ] = {
			"*39",
			"*52",
			"*87",
			"*88"
		};

		for( iGlassNum = 0; iGlassNum < sizeof Beta5; iGlassNum++ )
			copy( Fatality_Glass[ iGlassNum ], 3, Beta5[ iGlassNum ] );
	}

	// Replaces breakables to walls (glass)
	new iEntity, Float:vOrigin[ 3 ];
	for( new i = 0; i < iGlassNum; i++ ) {
		iEntity = find_ent_by_model( -1, "func_breakable", Fatality_Glass[ i ] );

		if( iEntity > 0 ) {
			entity_get_vector( iEntity, EV_VEC_origin, vOrigin );
			remove_entity( iEntity );

			iEntity = create_entity( "func_wall" );
			entity_set_vector( iEntity, EV_VEC_origin, vOrigin );
			entity_set_string( iEntity, EV_SZ_model, Fatality_Glass[ i ] );
			DispatchSpawn( iEntity );

			entity_set_int( iEntity, EV_INT_rendermode, kRenderTransTexture );
			entity_set_vector( iEntity, EV_VEC_rendercolor, Float:{ 0.0, 0.0, 0.0 } );
			entity_set_float( iEntity, EV_FL_renderamt, 100.0 );
		}
	}

	// Remove hurt in fire
	if( IsBeta6 )
		iEntity = find_ent_by_model( -1, "trigger_hurt", "*96" );
	else
		iEntity = find_ent_by_model( -1, "trigger_hurt", "*100" );

	remove_entity( iEntity );
}

FixMap_Meadsy( ) {
	new const Meadsy_Doors[ ][ ] = {
		"*2",
		"*3",
		"*4",
		"*70",
		"*78",
		"*79",
		"*87",
		"*88",
		"*89",
		"*90",
		"*91",
		"*92",
		"*32",
		"*33",
		"*34",
		"*37",
		"*38",
		"*39",
		"*109",
		"*110",
		"*111",
		"*112"
	};

	new const Meadsy_DoorsRot[ ][ ] = {
		"*35",
		"*36",
		"*73",
		"*99",
		"*101"
	};

	new iEntity = find_ent_by_model( -1, "func_door", "*106" );
	remove_entity( iEntity );

	iEntity = find_ent_by_model( -1, "func_button", "*104" );
	remove_entity( iEntity );

	new i;
	for( i = 0; i < sizeof Meadsy_Doors; i++ ) {
		iEntity = find_ent_by_model( -1, "func_door", Meadsy_Doors[ i ] );

		if( iEntity > 0 )
			entity_set_int( iEntity, EV_INT_spawnflags, 0 );
	}

	for( i = 0; i < sizeof Meadsy_DoorsRot; i++ ) {
		iEntity = find_ent_by_model( -1, "func_door_rotating", Meadsy_DoorsRot[ i ] );

		if( iEntity > 0 )
			entity_set_int( iEntity, EV_INT_spawnflags, 0 );
	}

	CreateTriggerHurt( Float:{ -824.0, 989.0, 164.0 }, Float:{ -674.0, 1348.0, 252.0 } );
}

FixMap_AztecRun( ) {
	new const AztecRun_Doors[ ][ ] = {
		"*11",
		"*14",
		"*15",
		"*23",
		"*78",
		"*79",
		"*80",
		"*81",
		"*82",
		"*83"
	};

	// Remove flags on doors (anti +use bug)
	new iEntity;
	for( new i = 0; i < sizeof AztecRun_Doors; i++ ) {
		iEntity = find_ent_by_model( -1, "func_door", AztecRun_Doors[ i ] );

		if( iEntity > 0 )
			entity_set_int( iEntity, EV_INT_spawnflags, 0 );
	}

	// Remove not working shit
	remove_entity( find_ent_by_model( -1, "func_button", "*67" ) );
	remove_entity( find_ent_by_model( -1, "button_target", "*68" ) );
}

FixMap_Pyramid( ) {
	new const Pyramid_Doors[ ][ ] = {
		"*12",
		"*13",
		"*14",
		"*15"
	};

	// Remove flags on doors (anti +use bug)
	new iEntity;
	for( new i = 0; i < sizeof Pyramid_Doors; i++ ) {
		iEntity = find_ent_by_model( -1, "func_door", Pyramid_Doors[ i ] );

		if( iEntity > 0 )
			entity_set_int( iEntity, EV_INT_spawnflags, 0 );
	}

	// Remove not working shit
	remove_entity( find_ent_by_model( -1, "func_button", "*36" ) );
	remove_entity( find_ent_by_model( -1, "func_button", "*37" ) );
}

FixMap_CxxInc( ) {
	new const CxxInc_Breakables[ ][ ] = {
		"*149",
		"*150",
		"*151",
		"*152",
		"*153",
		"*154",
		"*155",
		"*156",
		"*157",
		"*158",
		"*159",
		"*160",
		"*161",
		"*162",
		"*163",
		"*164",
		"*165",
		"*166"
	};

	// Remove breakables
	new iEntity;
	for( new i = 0; i < sizeof CxxInc_Breakables; i++ ) {
		iEntity = find_ent_by_model( -1, "func_breakable", CxxInc_Breakables[ i ] );

		remove_entity( iEntity );
	}

	// Create trigger hurt in black room (anti stuck + semiclip bugg)
	CreateTriggerHurt( Float:{ -1200.0, -168.0, -1436.0 }, Float:{ 1220.0, 176.0, -1127.0 } );
}

FixMap_FsFacility( ) {
	new iEntity;
	iEntity = find_ent_by_model( -1, "func_button", "*16" );
	if (pev_valid(iEntity)) {
		entity_set_int( iEntity, EV_INT_spawnflags, SF_BUTTON_DONTMOVE);
		set_pdata_float( iEntity, m_flWait, 10.0, 4 );
	}

}

FixMap_Simpsons( ) {
	new const Simpsons_Breakables[ ][ ] = {
		"*1",
		"*2",
		"*4"
	};

	new iEntity;
	for( new i = 0; i < sizeof Simpsons_Breakables; i++ ) {
		iEntity = find_ent_by_model( -1, "func_breakable", Simpsons_Breakables[ i ] );
		if (pev_valid(iEntity))
			entity_set_int( iEntity, EV_INT_spawnflags, SF_BREAK_TRIGGER_ONLY );
	}
}

CreateTriggerHurt( const Float:flMins[ 3 ], const Float:flMaxs[ 3 ] ) {
	new iEntity = create_entity( "trigger_hurt" );

	if( !is_valid_ent( iEntity ) )
		return 0;

	DispatchKeyValue( iEntity, "classname", "trigger_hurt" );
	DispatchKeyValue( iEntity, "damagetype", "1024" );
	DispatchKeyValue( iEntity, "dmg", "1000" );
	DispatchKeyValue( iEntity, "origin", "0 0 0" );

	DispatchSpawn( iEntity );

	entity_set_size( iEntity, flMins, flMaxs );
	entity_set_int( iEntity, EV_INT_solid, SOLID_TRIGGER );

	return iEntity;
}

FixMap_Junkie( ) {

	new iEntity
	iEntity = find_ent_by_model( -1, "func_button", "*23" );
	remove_entity( iEntity );

	new const Breakables[ ][ ] = {
		"*6",
		"*7"
	};

	for( new i = 0; i < sizeof Breakables; i++ ) {
		iEntity = find_ent_by_model( -1, "func_breakable", Breakables[ i ] );
		if (pev_valid(iEntity))
			entity_set_int( iEntity, EV_INT_spawnflags, SF_BREAK_TRIGGER_ONLY );
	}
}

FixMap_Hills () {
	new iEntity
	iEntity = find_ent_by_model( -1, "func_door", "*2" );
	DispatchKeyValue( iEntity, "dmg", "1000" );
	iEntity = find_ent_by_model( -1, "func_button", "*17" );
	set_pdata_float( iEntity, m_flWait, 5.0, 4 );
	iEntity = find_ent_by_model( -1, "func_door_rotating", "*11" );
	DispatchKeyValue( iEntity, "dmg", "1000" );

}