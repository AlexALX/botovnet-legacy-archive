/*

This plugin making !stopsounds chat command for player
Stop all sounds on player if any stuck in loop
Uses ULX permission system
Used on Botov-NET gmod server

-----------

MIT License

Copyright (c) 2015 by AlexALX

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND...
*/

function ulx.stopsounds( calling_ply )
    calling_ply:SendLua("LocalPlayer():ConCommand('stopsounds')")
    ULib.tsayColor( calling_ply, false, Color( 255, 0, 0 ), "Stopped all sounds." )
end
local stopsounds = ulx.command( CATEGORY_NAME, "ulx stopsounds", ulx.stopsounds, "!stopsounds", true )
stopsounds:defaultAccess( ULib.ACCESS_ALL )
stopsounds:help( "Stops all sounds." )