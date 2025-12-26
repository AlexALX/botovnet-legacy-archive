/*

This plugin are helper to ArenaDeathmatch.cs plugin, addign arena_dm admin chat command
But i don't remember what its doing already, probably related to spawn points or building

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

// Reference: Newtonsoft.Json
using System.Collections.Generic;
using System.Linq;
using Oxide.Core;
using Oxide.Core.Plugins;
using Oxide.Core.Configuration;
using Oxide.Plugins;
using UnityEngine;
using System;
using Newtonsoft.Json;
using System.Reflection;

namespace Oxide.Plugins
{
    [Info("Arena Help", "AlexALX", "0.0.1")]
    public class ArenaHelp : RustPlugin
    {
		private List<object> rawDeployables;
        private Vector3 transformedPos;
        private float newX;
        private float newZ;
        private FieldInfo serverinput = typeof(BasePlayer).GetField("serverInput", BindingFlags.NonPublic | BindingFlags.Instance);
        private Quaternion currentRot;
        private object closestEnt;
        private Vector3 closestHitpoint;
		private int layerMasks = LayerMask.GetMask("Construction", "Construction Trigger", "Trigger", "Deployed", "Tree", "AI");
        private Dictionary<string, object> rotCleanData;
        private Dictionary<string, object> posCleanData;
        private Vector3 normedPos;
        private float normedYRot;
		
		private Oxide.Plugins.Timer RunTimer;
		
        void Loaded() 
        {
			//RunTimer = timer.Repeat(1800f, 0, () => RunArena());
        }
		
        void Unload()
        {
			RunTimer.Destroy();
		}
		
		void RunArena() {
			ConsoleSystem.Run.Server.Normal("event.game", new string[]{"Deathmatch"});
			//ConsoleSystem.Run.Server.Normal("event.spawnfile", new string[]{"DeathmatchSpawnfile"});
			ConsoleSystem.Run.Server.Normal("event.open");
			ConsoleSystem.Run.Server.Normal("event.start");
		}
		
        bool hasAccess(BasePlayer player)
        {
            if (player.net.connection.authLevel < 1)
            {
                SendReply(player, "You are not allowed to use this command");
                return false;
            }
            return true;
        }
		
        bool TryGetClosestRayPoint(Vector3 sourcePos, Quaternion sourceDir, out object closestEnt, out Vector3 closestHitpoint)
        {
            Vector3 sourceEye = sourcePos + new Vector3(0f, 1.5f, 0f);
            Ray ray = new Ray(sourceEye, sourceDir * Vector3.forward);

            var hits = Physics.RaycastAll(ray);
            float closestdist = 999999f;
            closestHitpoint = sourcePos;
            closestEnt = false;
            foreach (var hit in hits)
            {
                if (hit.collider.isTrigger)
                    continue;
                if (hit.distance < closestdist)
                {
                    closestdist = hit.distance;
                    closestEnt = hit.collider;
                    closestHitpoint = hit.point;
                }
            }
            if (closestEnt is bool)
                return false;
            return true;
        }
		
        bool GetStructureClean(BuildingBlock initialBlock, float playerRot, BuildingBlock currentBlock, out Dictionary<string, object> data)
        {
            data = new Dictionary<string, object>();
            posCleanData = new Dictionary<string, object>();
            rotCleanData = new Dictionary<string, object>();

            normedPos = GenerateGoodPos(initialBlock.transform.position, currentBlock.transform.position, playerRot);
            normedYRot = currentBlock.transform.rotation.ToEulerAngles().y - playerRot;

            data.Add("prefabname", currentBlock.blockDefinition.fullName);
            data.Add("grade", currentBlock.grade);

            posCleanData.Add("x", normedPos.x);
            posCleanData.Add("y", normedPos.y);
            posCleanData.Add("z", normedPos.z);
            data.Add("pos", posCleanData);

            rotCleanData.Add("x", currentBlock.transform.rotation.ToEulerAngles().x);
            rotCleanData.Add("y", normedYRot);
            rotCleanData.Add("z", currentBlock.transform.rotation.ToEulerAngles().z);
            data.Add("rot", rotCleanData);
            return true;
        }
		
        bool GetDeployableClean(BuildingBlock initialBlock, float playerRot, Deployable currentBlock, out Dictionary<string, object> data)
        {
            data = new Dictionary<string, object>();
            posCleanData = new Dictionary<string, object>();
            rotCleanData = new Dictionary<string, object>();

            normedPos = GenerateGoodPos(initialBlock.transform.position, currentBlock.transform.position, playerRot);
            normedYRot = currentBlock.transform.rotation.ToEulerAngles().y - playerRot;
            data.Add("prefabname", StringPool.Get(currentBlock.prefabID).ToString());

            posCleanData.Add("x", normedPos.x);
            posCleanData.Add("y", normedPos.y);
            posCleanData.Add("z", normedPos.z);
            data.Add("pos", posCleanData);

            rotCleanData.Add("x", currentBlock.transform.rotation.ToEulerAngles().x);
            rotCleanData.Add("y", normedYRot);
            rotCleanData.Add("z", currentBlock.transform.rotation.ToEulerAngles().z);
            data.Add("rot", rotCleanData);
            return true;
        }
		
        bool TryGetPlayerView(BasePlayer player, out Quaternion viewAngle)
        {
            viewAngle = new Quaternion(0f, 0f, 0f, 0f);
            var input = serverinput.GetValue(player) as InputState;
            if (input == null || input.current == null || input.current.aimAngles == Vector3.zero)
                return false;

            viewAngle = Quaternion.Euler(input.current.aimAngles);
            return true;
        }

        Vector3 GenerateGoodPos(Vector3 InitialPos, Vector3 CurrentPos, float diffRot)
        {
            transformedPos = CurrentPos - InitialPos;
            newX = (transformedPos.x * (float)Math.Cos(-diffRot)) + (transformedPos.z * (float)Math.Sin(-diffRot));
            newZ = (transformedPos.z * (float)Math.Cos(-diffRot)) - (transformedPos.x * (float)Math.Sin(-diffRot));
            transformedPos.x = newX;
            transformedPos.z = newZ;
            return transformedPos;
        }
		
        object CopyBuilding(Vector3 playerPos, float playerRot, BuildingBlock initialBlock, out List<object> rawDeployables)
        {
            rawDeployables = new List<object>();
            List<object> houseList = new List<object>();
            List<Vector3> checkFrom = new List<Vector3>();
            BuildingBlock fbuildingblock;
            Deployable fdeployable;
            Spawnable fspawnable;

            houseList.Add(initialBlock);
            checkFrom.Add(initialBlock.transform.position);

            Dictionary<string, object> housedata;
            if (!GetStructureClean(initialBlock, playerRot, initialBlock, out housedata))
            {
                return "Couldn\'t get a clean initial block";
            }
            //if (initialBlock.HasSlot(BaseEntity.Slot.Lock)) // initial block could be a door.
            //    TryCopyLock(initialBlock, housedata);
            //rawStructure.Add(housedata);

            int current = 0;
            while (true)
            {
                current++;
                if (current > checkFrom.Count)
                    break;
                var hits = Physics.OverlapSphere(checkFrom[current - 1], 3f, layerMasks);
                foreach (var hit in hits)
                {
                    if (hit.isTrigger)
                        continue;
                    if (hit.GetComponentInParent<BuildingBlock>() != null)
                    {
                        fbuildingblock = hit.GetComponentInParent<BuildingBlock>();
                        if (!(houseList.Contains(fbuildingblock)))
                        {
                            houseList.Add(fbuildingblock);
                            checkFrom.Add(fbuildingblock.transform.position);
                            /*if (GetStructureClean(initialBlock, playerRot, fbuildingblock, out housedata))
                            {

                                if (fbuildingblock.HasSlot(BaseEntity.Slot.Lock))
                                    TryCopyLock(fbuildingblock, housedata);
                                rawStructure.Add(housedata);
                            }*/
                        }
                    }
					else if (hit.GetComponentInParent<Deployable>() != null)
                    {
                        fdeployable = hit.GetComponentInParent<Deployable>();
                        if (!(houseList.Contains(fdeployable)))
                        {
                            houseList.Add(fdeployable);
                            checkFrom.Add(fdeployable.transform.position);
                            if (GetDeployableClean(initialBlock, playerRot, fdeployable, out housedata))
                            {
                                if (fdeployable.GetComponent<StorageContainer>())
                                {
                                    var box = fdeployable.GetComponent<StorageContainer>();
                                    var itemlist = new List<object>();
                                    foreach (Item item in box.inventory.itemList)
                                    {
                                        var newitem = new Dictionary<string, object>();
                                        newitem.Add("blueprint", item.isBlueprint.ToString());
                                        newitem.Add("id", item.info.itemid.ToString());
                                        newitem.Add("amount", item.amount.ToString());
                                        itemlist.Add(newitem);
                                    }
                                    housedata.Add("items", itemlist);

                                    //if (box.HasSlot(BaseEntity.Slot.Lock))
                                    //    TryCopyLock(box, housedata);
                                }
                                else if (fdeployable.GetComponent<Signage>())
                                {
                                    var signage = fdeployable.GetComponent<Signage>();
                                    var sign = new Dictionary<string, object>();
                                    if (signage.textureID > 0 && FileStorage.server.Exists(signage.textureID, FileStorage.Type.png))
                                        sign.Add("texture", Convert.ToBase64String(FileStorage.server.Get(signage.textureID, FileStorage.Type.png)));
                                    sign.Add("locked", signage.IsLocked());
                                    housedata.Add("sign", sign);
                                }
                                //rawDeployables.Add(housedata);
								if (StringPool.Get(fdeployable.prefabID).ToString()=="items/woodbox_deployed") {
									/*rawDeployables.Add(new List<object>{
										/*((Dictionary<string, object>)housedata["pos"])["x"],
										((Dictionary<string, object>)housedata["pos"])["y"],
										((Dictionary<string, object>)housedata["pos"])["z"]*
										fdeployable.transform.position.x,fdeployable.transform.position.y,fdeployable.transform.position.z
									});*/
									rawDeployables.Add(fdeployable.transform.position);
									if (hit.GetComponentInParent<BaseEntity>() != null) hit.GetComponentInParent<BaseEntity>().Kill(BaseNetworkable.DestroyMode.Gib);
								}
                            }
                        }
                    }
                }
            }
            return true;
        }
		
		/*
			event.spawnfile DeathmatchSpawnfile
			event.zone 45
		*/
		
        [ChatCommand("arena_dm")]
        void cmdChatCopy(BasePlayer player, string command, string[] args)
        {
            if (!hasAccess(player)) return;

            // Get player camera view directly from the player
            if (!TryGetPlayerView(player, out currentRot))
            {
                SendReply(player, "Couldn\'t find your eyes");
                return;
            }

            // Get what the player is looking at
            if (!TryGetClosestRayPoint(player.transform.position, currentRot, out closestEnt, out closestHitpoint))
            {
                SendReply(player, "Couldn\'t find any Entity");
                return;
            }

            // Check if what the player is looking at is a collider
            var baseentity = closestEnt as Collider;
            if (baseentity == null)
            {
                SendReply(player, "You are not looking at a Structure, or something is blocking the view.");
                return;
            }

            // Check if what the player is looking at is a BuildingBlock (like a wall or something like that)
            var buildingblock = baseentity.GetComponentInParent<BuildingBlock>();
            if (buildingblock == null)
            {
                SendReply(player, "You are not looking at a Structure, or something is blocking the view.");
                return;
            }

            var returncopy = CopyBuilding(player.transform.position, currentRot.ToEulerAngles().y, buildingblock, out rawDeployables);
            if (returncopy is string)
            {
                SendReply(player, (string)returncopy);
                return;
            }

            if (rawDeployables.Count == 0)
            {
                SendReply(player, "Something went wrong, house is empty?");
                return;
            }

            Dictionary<string, object> defaultValues = new Dictionary<string, object>();
			/*
            Dictionary<string, object> defaultPos = new Dictionary<string, object>();
            defaultPos.Add("x", buildingblock.transform.position.x);
            defaultPos.Add("y", buildingblock.transform.position.y);
            defaultPos.Add("z", buildingblock.transform.position.z);
            defaultValues.Add("position", defaultPos);
            defaultValues.Add("yrotation", buildingblock.transform.rotation.ToEulerAngles().y);*/

            //Interface.GetMod().DataFileSystem.SaveDatafile(filename);
            var NewSpawnFile = Interface.GetMod().DataFileSystem.GetDatafile("DeathmatchSpawnfile");
            NewSpawnFile.Clear();
			var i = 1;
			foreach (object item in rawDeployables)
			{
				var spawnpoint = (Vector3)item;//new Vector3(Convert.ToSingle(()item[0]), Convert.ToSingle(item[1]), Convert.ToSingle(item[2]));
				var spawnpointadd = new Dictionary<string, object>();
				spawnpointadd.Add("x", Math.Round(spawnpoint.x * 100) / 100);
				spawnpointadd.Add("y", Math.Round(spawnpoint.y * 100) / 100);
				spawnpointadd.Add("z", Math.Round(spawnpoint.z * 100) / 100);
				NewSpawnFile[i.ToString()] = spawnpointadd;
				i++;
			}
			Interface.GetMod().DataFileSystem.SaveDatafile("DeathmatchSpawnfile");
			
			ConsoleSystem.Run.Server.Normal("oxide.reload", new string[]{"Spawns"});			

            SendReply(player, string.Format("{0} spawns created", rawDeployables.Count.ToString()));
        }
		
	}
	
}