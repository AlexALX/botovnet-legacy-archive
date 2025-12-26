/*

This plugin adding workshop addons based on maps
Purpose is to NOT download all maps, and only load those if current map match asset
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

maplist = {}

maplist["gm_construct_flatgrass_v6-2"] = "104468359"
maplist["sg1_the_fifth_race"] = "104753884"
maplist["gm_bigcity"] = "105982362"
maplist["rp_stargate_v5"] = "133391119"
maplist["sb_forlorn_sb3_r3"] = "131473300"
maplist["sb_genesis_omega"] = "129076641"
maplist["sb_gooniverse"] = "104542705"
maplist["sb_new_worlds_2"] = "104585425"
maplist["sb_omen_v2"] = "175520745"
maplist["sb_twinsuns"] = "104580685"
maplist["sg_quadrants"] = "142217689"
maplist["sb_wuwgalaxy_fix"] = "118110850"
maplist["rp_stargateworldsv3"] = "193805691"
maplist["gm_wireconstruct_bna"] = "105382455"
maplist["gm_galactic_rc1"] = "120433773"
maplist["gm_area51_rc1"] = "194709790"
maplist["gm_excess_construct_13"] = "174651081"
maplist["gm_mobenix_v3_final"] = "140618773"
maplist["gm_trainset"] = "248213731"
--maplist["gm_rockside_rails_beta"] = "230721135"
maplist["sm_trains"] = "112928935"
maplist["gm_sgc_to_atlantis"] = "308453527"
maplist["gm_botmap_v3"] = "217886361"

local map = game.GetMap():lower()
local workshopid = maplist[map]

if( workshopid != nil )then
	print( "Setting up map - " ..map.. ", workshop ID: " ..workshopid )
	resource.AddWorkshop( workshopid )
end