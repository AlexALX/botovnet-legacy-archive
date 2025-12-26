/*

This plugin add unique skills tree for users.
User on Botov-NET rust servers.

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
using Rust;

using StudyCore;

public static class StudyGlobals {
    public const string Version = "0.0.6";
	public const string DataFileName = "StudyData";
}

namespace Oxide.Plugins
{
    [Info("Self Study", "AlexALX", StudyGlobals.Version)]
    public class SelfStudy : RustPlugin
    {
		private readonly Study StudyInstance;
		private DynamicConfigFile StudyDataFile;
		private Oxide.Plugins.Timer SaveTimer;
		
		[PluginReference] Plugin RustVip;
		[PluginReference] Plugin ClansStudy;
		[PluginReference] Plugin ZoneManager;
		
		public bool IsVIP(BasePlayer player) {
			return (bool)(RustVip?.Call("IsVIP",player) ?? false);
		}
		
		public float GetClanBonus(string player, string bonus) {
			return (float)(ClansStudy?.Call("GetClanBonus", player, bonus) ?? 0f);
		}		
	
		public string GetClanBonuses(BasePlayer player) {
			return (string)(ClansStudy?.Call("GetClanBonuses", player.userID.ToString()) ?? "");
		}
		
		public float GetWeaponBonus(string sid, string weapon) {
			return (float)(ClansStudy?.Call("GetWeaponBonus", sid, weapon) ?? 0f);
		}
		
		public bool IsInArena(BasePlayer player) {
			return (bool)(ZoneManager?.Call("isPlayerInZone", "Deathmatch", player) ?? false);
		}
	
        public SelfStudy()
        {
            //HasConfig = true;
            StudyInstance = new Study(this);
            /*if (StudyInstance == null) {
				return;
			}*/
        }

        public void Print(string msg)
        {
            Puts("{0}", msg);
        }
		
	    [HookMethod("Init")]
        void Init()
        {
			Puts(StudyInstance == null ? "Problem initializating Self-Study Instance!" : "Self-Study initialized!");
			LoadStudy();	
			SaveTimer = timer.Repeat(900f, 0, () => StudyInstance.Save());
        }
		
        [HookMethod("OnServerInitialized")]
        void OnServerInitialized()
        {
			//Init();
			StudyInstance.GenerateItemTable();
            StudyInstance.FurnacesCheck((Dictionary<string, string>)StudyDataFile["Furnace"]);
        }
		
        [HookMethod("OnServerSave")]
        void OnServerSave()
        {
            StudyInstance.Save();
        }
		
        [HookMethod("Unload")]
        void Unload()
        {
			SaveTimer.Destroy();
            StudyInstance.Save(true);
			StudyInstance.FixItemTable();
        }
		
        protected override void LoadDefaultConfig()
        {
            DefaultConfig();
        }
		
        private void DefaultConfig() {
			StudyDataFile = Interface.GetMod().DataFileSystem.GetDatafile(StudyGlobals.DataFileName);
			StudyDataFile["Profile"] = new Dictionary<string, PlayerInfo>();
			StudyDataFile["Furnace"] = new Dictionary<string, string>();
			Interface.GetMod().DataFileSystem.SaveDatafile(StudyGlobals.DataFileName);
			//var ret = StudyInstance.DefaultConfig();
			//Config["settings"] = ret["settings"];
			//Config["skills"] = ret["skills"];
			Config["settings"] = new Dictionary<string,object>();
			Config["skills"] = new Dictionary<string,StudySkill>();
			Config["profs"] = new Dictionary<string,StudyProf>();
			SaveConfig();
		}
		
		public void SaveStudy(Dictionary<string, PlayerInfo> playerConfig, Dictionary<string, string> furnaceConfig) {
			if (playerConfig==null||furnaceConfig==null) return;
			StudyDataFile["Profile"] = playerConfig;
			StudyDataFile["Furnace"] = furnaceConfig;
			Interface.GetMod().DataFileSystem.SaveDatafile(StudyGlobals.DataFileName);
		}
		
		public void SaveStudyConfig(Dictionary<string, object> settings, Dictionary<string, StudySkill> skills, Dictionary<string, StudyProf> profs) {
			Config["settings"] = settings;
			Config["skills"] = skills;
			Config["profs"] = profs;
			SaveConfig();
		}
		
		private void LoadStudy() {
			LoadConfig();
			StudyInstance.LoadConfig(ReadFromConfig<Dictionary<string,object>>("settings"),ReadFromConfig<Dictionary<string,StudySkill>>("skills"),ReadFromConfig<Dictionary<string,StudyProf>>("profs"));
			StudyDataFile = Interface.GetMod().DataFileSystem.GetDatafile(StudyGlobals.DataFileName);
			StudyDataFile["Profile"] = ReadFromData<Dictionary<string, PlayerInfo>>("Profile");
			StudyDataFile["Furnace"] = ReadFromData<Dictionary<string, string>>("Furnace");
			StudyInstance.Load((Dictionary<string, PlayerInfo>)StudyDataFile["Profile"],(Dictionary<string, string>)StudyDataFile["Furnace"]);
		}
		
        public T ReadFromConfig<T>(string configKey)
        {
            string serializeObject = JsonConvert.SerializeObject(Config[configKey]);
            return JsonConvert.DeserializeObject<T>(serializeObject);
        }
		
        public T ReadFromData<T>(string dataKey)
        {
            string serializeObject = JsonConvert.SerializeObject(StudyDataFile[dataKey]);
            return JsonConvert.DeserializeObject<T>(serializeObject);
        }
		
        [ChatCommand("fc")]
        void cmdChatFix(BasePlayer player, string command, string[] args)
        {
			var i = 20;
			timer.Repeat(0.1f,i,() => SendReply(player, "FIX CHAT #"+(i--)));
		}
		
        [ConsoleCommand("study.recalc_manual")]
        void cmdReCalc(ConsoleSystem.Arg arg)
        {
			if (!arg.CheckPermissions()) return;
			Print(StudyInstance.ReCalcSkills(false,true));
		}	
		
        [ConsoleCommand("study.recalc_auto")]
        void cmdReCalcAuto(ConsoleSystem.Arg arg)
        {
			if (!arg.CheckPermissions()) return;
			Print(StudyInstance.ReCalcSkills(true,true));
		}	
		
        [ChatCommand("hunt")]
        void cmdChatHunt(BasePlayer player, string command, string[] args)
        {
			SendReply(player, "Данная команда не используется, напишите <color='#00DD00'>/skill</color>.");
		}
	
        [ChatCommand("skill")]
        void cmdChatSkill(BasePlayer player, string command, string[] args)
        {
			SendReply(player, StudyInstance.ChatSkill(player, command, args));
		}
		
        [ChatCommand("me")]
        void cmdChatMe(BasePlayer player, string command, string[] args)
        {
			SendReply(player, StudyInstance.ChatMe(player, command, args));
		}	
		
        [ChatCommand("up")]
        void cmdChatUp(BasePlayer player, string command, string[] args)
        {
			SendReply(player, StudyInstance.ChatUp(player, command, args));
		}	
		
        [HookMethod("OnPlayerInit")]
        void OnPlayerInit(BasePlayer player)
        {
            StudyInstance.PlayerInit(player);
        }
		
        [HookMethod("OnPlayerRespawned")]
        void OnPlayerRespawned(BasePlayer player)
        {
            StudyInstance.PlayerRespawned(player);
        }
		
        [HookMethod("OnPlayerDisconnected")]
        void OnPlayerDisconnected(BasePlayer player)
        {
            StudyInstance.PlayerDisconnected(player);
        }
		
        [HookMethod("OnItemCraft")]
        void OnItemCraft(ItemCraftTask craft)
        {
			StudyInstance.OnItemCraft(craft);
		}
		
        [HookMethod("OnLoseCondition")]
        void OnLoseCondition(Item item, ref float amount)
        {
			if (item.hasCondition) amount = StudyInstance.LoseCondition(item,amount);
        }
		
        [HookMethod("OnGather")]
        void OnGather(ResourceDispenser dispenser, BaseEntity entity, Item item)
        {
			StudyInstance.OnGather(dispenser, entity, item);
		}
		
        [HookMethod("OnPlayerAttack")]
        void OnPlayerAttack(BasePlayer entity, HitInfo hitInfo)
        {
			StudyInstance.OnPlayerAttack(entity, hitInfo);
		}
		
        [HookMethod("OnEntityTakeDamage")]
        void OnEntityAttacked(BaseCombatEntity entity, HitInfo hitInfo)
        {
			//Print(StringPool.Get(hitInfo.HitBone));
			StudyInstance.OnEntityAttacked(entity, hitInfo);
		}
		
        [HookMethod("OnEntityDeath")]
        void OnEntityDeath(BaseCombatEntity entity, HitInfo hitInfo)
        {
			StudyInstance.OnEntityDeath(entity, hitInfo);
		}
		
        [HookMethod("OnEntityBuilt")]
        void OnEntityBuilt(Planner planner, UnityEngine.GameObject gameObject)
        {
			StudyInstance.OnEntityBuilt(planner, gameObject);
		}
		
        [HookMethod("OnBuildingBlockUpgrade")]
        void OnBuildingBlockUpgrade(BuildingBlock block, BasePlayer player, BuildingGrade.Enum grade)
        {
			StudyInstance.OnBuildingBlockUpgrade(block, player, grade);
		}
		
        [HookMethod("OnItemDeployed")]
        void OnItemDeployed(Deployer deployer, BaseEntity baseEntity)
        {
			StudyInstance.DeployItem(deployer, baseEntity);
		}
		
        [HookMethod("OnConsumeFuel")]
        void OnConsumeFuel(BaseOven oven, Item fuel, ItemModBurnable burnable)
        {
			StudyInstance.ConsumeFuel(oven, fuel, burnable);
		}
		
		int GetPlayerLvl(string sid) {
			return StudyInstance.GetPlayerLvl(sid);
		}
		
	}
	
}
	
namespace StudyCore
{
    class Study
    {
		private Dictionary<string, PlayerInfo> PlayerConfig;
		private Dictionary<string, string> FurnaceConfig;
		private Dictionary<int, int> SkillLvlTable;
		private Dictionary<int, int> RockLvlTable;
		private Dictionary<int, int> WeaponLvlTable;
		private Dictionary<int, int> PlayerLvlTable;
		private readonly SelfStudy PluginInstance;
		private Dictionary<string, List<string>> CorrectResources;
		private Dictionary<string, PlayerTmp> PlayerTmpInfo;
		private Dictionary<string, StudyProf> StudyProfs;
		private Dictionary<string, StudySkill> StudySkills;
		private Dictionary<string, Dictionary<string,StudySkill>> StudySTypes;
		//private float TotalGatherX;
		private float TotalGatherC;
		private float StartGatherX;
		private float WeaponCondX;
		private float XPMul;
		private Dictionary<string, ItemInfo> ItemTable;
		private Dictionary<string, Dictionary<int,string>> StudyEvents;
		public static DateTime epoch = new System.DateTime(1970, 1, 1);
	
        public Study(SelfStudy pluginInstance)
        {
            PluginInstance = pluginInstance;
			PlayerConfig = new Dictionary<string, PlayerInfo>();
			FurnaceConfig = new Dictionary<string, string>();
			SkillLvlTable = GenerateLvlTable(50000,50,0.0784f);
			RockLvlTable = GenerateLvlTable(1000,10,2,1);
			WeaponLvlTable = GenerateLvlTable(8000,30,0.2146f);
			PlayerLvlTable = GenerateLvlTable(2225,99,0.01608f,0.2f);
			CorrectResources = new Dictionary<string, List<string>>(){
				{ "Tree", new List<string>(new string[] {"rock","stonehatchet","hatchet","axe_salvaged"} ) },
				{ "Ore", new List<string>(new string[] {"rock","stone_pickaxe","pickaxe","icepick_salvaged","hammer_salvaged"} ) }
			};
			PlayerTmpInfo = new Dictionary<string, PlayerTmp>();
			
			ItemTable = new Dictionary<string, ItemInfo>();
			//ItemTable = GenerateItemTable();
			
			StartGatherX = 1f;
			//TotalGatherX = 2f;
			//TotalGatherC = 0.5f;
			WeaponCondX = 0.5f;
			XPMul = 1f;
			
			StudyProfs = new Dictionary<string, StudyProf>();
			StudyProfs["Tree"] = new StudyProf(new string[] {"лесоруба","Лесоруб"},"Tree",12f,new Dictionary<string, StudySkillOpts>{
				{"Tree",new StudySkillOpts("добыча дерева",5f,"x")}
				//{"прочность",new object[]{1.25f,"+"}}
			});
			StudyProfs["Ore"] = new StudyProf(new string[] {"каменоломщика","Каменоломщик"},"Ore",22f,new Dictionary<string, StudySkillOpts>{
				{"Ore",new StudySkillOpts("добыча камня",5f,"x")}
				//{"прочность",new object[]{0.7f,"+"}}
			});
			StudyProfs["Flesh"] = new StudyProf(new string[] {"охотника","Охотник"},"Flesh",3f,new Dictionary<string, StudySkillOpts>{
				{"Flesh",new StudySkillOpts("добыча животных",5f,"x")}
				//{"прочность",new object[]{0.7f,"+"}}
			});
			StudyProfs["Kill"] = new StudyProf(new string[] {"убийцы","Убийца"},"Kill",3f,new Dictionary<string, StudySkillOpts>{
				{"Kill",new StudySkillOpts("урон игрокам",1.25f,"+")}
			});
			StudyProfs["Build"] = new StudyProf(new string[] {"строителя","Строитель"},"Build",3f,new Dictionary<string, StudySkillOpts>{
				{"Build",new StudySkillOpts("стоимость постройки",0.75f,"-")}
			});
			
			StudySkills = new Dictionary<string, StudySkill>();
			StudySkills["power"] = new StudySkill("Сила",90,new Dictionary<string, StudySkillOpts>(){
				{"damage",new StudySkillOpts("урон",1.25f,"+")}
			},6);
			StudySkills["defence"] = new StudySkill("Защита",90,new Dictionary<string, StudySkillOpts>(){
				{"defence",new StudySkillOpts("оборона",1.25f,"+")}
			},5);			
			StudySkills["lovk"] = new StudySkill("Ловкость",80,new Dictionary<string, StudySkillOpts>(){
				{"lovk",new StudySkillOpts("шанс уклонения",1.1f,"")}
			},4);	
			StudySkills["int"] = new StudySkill("Интелект",80,new Dictionary<string, StudySkillOpts>(){
				{"craft",new StudySkillOpts("крафт",0.85f,"-")},
				{"kuznec",new StudySkillOpts("кузнец",1.5f,"+")}
			},4);
			StudySkills["master"] = new StudySkill("Мастер",80,new Dictionary<string, StudySkillOpts>(){
				{"total",new StudySkillOpts("бонус ко всему",1.05f,"+")}
			},5);
			StudySkills["craft"] = new StudySkill("Инженер",80,new Dictionary<string, StudySkillOpts>(){
				{"craft",new StudySkillOpts("крафт",0.65f,"-")}
			},6,15);
			StudySkills["vinos"] = new StudySkill("Выносливость",60,new Dictionary<string, StudySkillOpts>(){
				{"vinos",new StudySkillOpts("",1.5f,"+")}
			},1);	
			StudySkills["stalker"] = new StudySkill("Сталкер",50,new Dictionary<string, StudySkillOpts>(){
				{"rad",new StudySkillOpts("устойчивость к радиации",1.5f,"+")}
			},4,30);/*
			StudySkills["speed"] = new StudySkill("Атлет",20,new Dictionary<string, object[]>(){
				{"speed",new object[]{"скорость бега",1.05f,"+"}}
			},6,60);*/
			
			StudyEvents = new Dictionary<string, Dictionary<int,string>>();
			StudyEvents["Build"] = new Dictionary<int,string>(){
				{20,"Вы получили доступ к команде <color='#00DD00'>/up</color>! Теперь вы можете автоматически обновлять постройки до дерева."},
				{35,"Вы получили доступ к команде <color='#00DD00'>/up stone</color>! Теперь вы можете автоматически обновлять постройки до камня."}
			};
			StudyEvents["playerlvl"] = new Dictionary<int,string>(){
				{50,"Вы получили доступ к команде <color='#00DD00'>/me reset</color>! Теперь вы можете сбрасывать ваши навыки <color='#DD0000'>раз в неделю</color>."}
			};
			
        }
		
		private void PostInit() {
			StudySTypes = new Dictionary<string, Dictionary<string,StudySkill>>();
			foreach(KeyValuePair<string,StudySkill> kvp in StudySkills) {
				foreach(KeyValuePair<string,StudySkillOpts> kvs in kvp.Value.Skills) {
					if (!StudySTypes.ContainsKey(kvs.Key)) StudySTypes[kvs.Key] = new Dictionary<string,StudySkill>();
					StudySTypes[kvs.Key][kvp.Key] = kvp.Value;
				}
			}
			
			/*foreach( KeyValuePair<string, Dictionary<string,StudySkill>> kvp in StudySTypes )
			{
				Print("Key = " + kvp.Key.ToString() + ", Values = " + string.Join(", ", kvp.Value.Select(f => f.ToString()).ToArray()).ToString());
			}*/
		}
		
		/*
		public Dictionary<string,object> DefaultConfig() {
			var config = new Dictionary<string,object>();
			config["settings"] = new Dictionary<string,object>();
			((Dictionary<string,object>)config["settings"]).Add("StartGatherX",StartGatherX);
			((Dictionary<string,object>)config["settings"]).Add("WeaponCondX",WeaponCondX);
			config["skills"] = new Dictionary<string,StudySkill>();
			foreach(KeyValuePair<string,StudySkill> kvp in StudySkills) {
				((Dictionary<string,StudySkill>)config["skills"]).Add(kvp.Key,kvp.Value);
			}
			return config;
		}*/
		
		public void LoadConfig(Dictionary<string,object> settings, Dictionary<string,StudySkill> skills, Dictionary<string,StudyProf> profs) {
			var save = false;
			var nsettings = new Dictionary<string,object>();
			var nskills = new Dictionary<string,StudySkill>();
			var nprofs = new Dictionary<string,StudyProf>();
			if (settings==null||settings.Count==0||skills==null||skills.Count==0||profs==null||profs.Count==0) save = true;	
			StartGatherX = (float)(settings!=null&&settings.ContainsKey("StartGatherX")?Convert.ToSingle(settings["StartGatherX"]):StartGatherX);
			nsettings.Add("StartGatherX",StartGatherX);
			WeaponCondX = (float)(settings!=null&&settings.ContainsKey("WeaponCondX")?Convert.ToSingle(settings["WeaponCondX"]):WeaponCondX);
			nsettings.Add("WeaponCondX",WeaponCondX);
			XPMul = (float)(settings!=null&&settings.ContainsKey("XPMul")?Convert.ToSingle(settings["XPMul"]):XPMul);
			nsettings.Add("XPMul",XPMul);
			StudySkills = (skills!=null&&skills.Count>0?skills:StudySkills);
			/*foreach(KeyValuePair<string,StudySkill> kvp in StudySkills) {
				foreach(KeyValuePair<string,object[]> kvs in kvp.Value.Skills) {
					kvs.Value[1] = (float)Convert.ToSingle(kvs.Value[1]);
				}
			}*/
			nskills = StudySkills;
			StudyProfs = (profs!=null&&profs.Count>0?profs:StudyProfs);
			/*foreach(KeyValuePair<string,StudyProf> kvp in StudyProfs) {
				foreach(KeyValuePair<string,object[]> kvs in kvp.Value.Skills) {
					kvs.Value[1] = (float)Convert.ToSingle(kvs.Value[1]);
				}
			}*/
			nprofs = StudyProfs;
			//Print(StudySkills["power"].Skills["damage"].Mul.GetType().ToString());
			if (save) PluginInstance.SaveStudyConfig(nsettings,nskills,nprofs);
			PostInit();
		}
		
        public Dictionary<string, ItemInfo> GenerateItemTable()
        {	
            var itemDict = new Dictionary<string, ItemInfo>();
            var itemsDefinition = ItemManager.GetItemDefinitions();
            foreach (var itemDefinition in itemsDefinition)
            {
                var newInfo = new ItemInfo {Shortname = itemDefinition.shortname, ItemId = itemDefinition.itemid, ItemCategory = itemDefinition.category.ToString()};
                var blueprint = ItemManager.FindBlueprint(itemDefinition);
                if (blueprint != null) newInfo.BlueprintTime = blueprint.time;
                if (!itemDict.ContainsKey(itemDefinition.displayName.translated.ToLower())) itemDict.Add(itemDefinition.displayName.translated.ToLower(), newInfo);
            }
			ItemTable = itemDict;
            //var blueprintDefinitions = Resources.LoadAll<ItemBlueprint>("items/").ToList();
			/*var itemDefinitions = Resources.LoadAll<ItemDefinition>("items/").ToList();
            foreach (ItemDefinition itemDefinition in itemDefinitions) {
				var newInfo = new ItemInfo {Shortname = itemDefinition.shortname, ItemId = itemDefinition.itemid, ItemCategory = itemDefinition.category.ToString()};
                var blueprint = ItemManager.FindBlueprint(itemDefinition);
                if (blueprint != null) newInfo.BlueprintTime = blueprint.time;
                itemDict.Add(itemDefinition.displayName.english, newInfo);
				Print(itemDefinition.displayName.english);
			}*/
			/*Print(blueprintDefinitions.Count.ToString());
            foreach (ItemBlueprint bp in blueprintDefinitions) {
				//var newInfo = new ItemInfo {Shortname = itemDefinition.shortname, ItemId = itemDefinition.itemid, ItemCategory = itemDefinition.category.ToString()};
                //itemDict.Add(bp.targetItem.displayName.translated.ToLower(), newInfo);
				Print(bp.time.ToString());
			}*//*
			foreach(KeyValuePair<string,ItemInfo> kvp in itemDict) {
				Print(kvp.Value.BlueprintTime.ToString());
			}*/
            return itemDict;
        }
		
        public void FixItemTable()
        {
            var itemsDefinition = ItemManager.GetItemDefinitions();
            foreach (var itemDefinition in itemsDefinition)
            {
                var blueprint = ItemManager.FindBlueprint(itemDefinition);
                if (blueprint != null && ItemTable.ContainsKey(itemDefinition.displayName.translated.ToLower()))
                    blueprint.time = ItemTable[itemDefinition.displayName.translated.ToLower()].BlueprintTime;
            }
        }
		
		public int GetPlayerLvl(string sid) {
			var info = PlayerInfo(null,sid);
			if (info==null) return 0;
			return info.Info.Level;
		}
		
        private PlayerInfo PlayerInfo(BasePlayer player, string sid = "")
        {
			string steamId = "";
			if (sid!="") steamId = sid;
			else steamId = SteamId(player);
            if (PlayerConfig.ContainsKey(steamId)) return PlayerConfig[steamId];
			if (sid!="") return null;
            PlayerConfig[steamId] = new PlayerInfo(player.displayName);
            //PluginInstance.SaveRPG(PlayerConfig, PlayersFurnaces);
            return PlayerConfig[steamId];
        }
		
        private PlayerTmp PlayerTmp(BasePlayer player)
        {
            string steamId = SteamId(player);
            if (PlayerTmpInfo.ContainsKey(steamId)) return PlayerTmpInfo[steamId];
            PlayerTmpInfo[steamId] = new PlayerTmp();
            //PluginInstance.SaveRPG(PlayerConfig, PlayersFurnaces);
            return PlayerTmpInfo[steamId];
        }
	
        private string SteamId(BasePlayer player)
        {
            return player.userID.ToString();
        }
		
        private void ChatMessage(BasePlayer player, string message)
        {
            player.ChatMessage(string.Format("{0}", message));
        }
		
        private void Print(string msg)
        {
            PluginInstance.Print(msg);
        }
		
		private float StudyGetType(PlayerInfo playerInfo,string type, float def = 0f, BasePlayer player = null) {
			float ret = 0f;
			foreach(KeyValuePair<string,StudySkill> kvp in StudySTypes[type]) {
				var mul = (float)kvp.Value.Skills[type].Mul;
				if (mul>1) mul -= 1;
				else mul = 1-mul;
				if (playerInfo.PlayerOptions.ContainsKey(kvp.Key)) {
					mul = playerInfo.PlayerOptions[kvp.Key].Points*(mul/kvp.Value.Points);
					ret += mul;
				}
			}
			if (ret==0f) ret = def;
			if (type=="total") {
				var clanbonus = PluginInstance.GetClanBonus(SteamId(player),"master");
				if (clanbonus>0f) ret += clanbonus;
			}
			return ret;
		}
		
		private float StudyProfType(PlayerInfo playerInfo,string type) {
			if (!playerInfo.PlayerSkills.ContainsKey(type)) return 0f;
			var mul = (float)StudyProfs[type].Skills[type].Mul;
			if (mul>1) mul -= 1;
			else mul = 1-mul;
			mul = playerInfo.PlayerSkills[type].Info.Level*(mul/SkillLvlTable.Count);
			return mul;
		}
		
		private Dictionary<int, int> GenerateLvlTable(int total, int lvl, float mul, float min = 0, bool print = false)
		{
			Dictionary<int, int> GeneratedTbl = new Dictionary<int, int>();
			for (int i = 1; i <= lvl; i++)
			{
				if (min==0) {
					GeneratedTbl[i] = (int)Math.Ceiling((decimal)(total/100*(mul*i)));
				} else {
					if (i==1) {
						GeneratedTbl[i] = (int)Math.Ceiling((decimal)(total/100*min));
					} else {
						GeneratedTbl[i] = (int)Math.Ceiling((decimal)(total/100*(min+mul*(i-1))));
					}
				}
			}			
			
			if (print) {
				var count = 0;
				foreach( KeyValuePair<int, int> kvp in GeneratedTbl )
				{
					Print("Level = " + kvp.Key.ToString() + ", Value = " + kvp.Value.ToString());
					count += kvp.Value;
				}
				Print("Total value: " + count.ToString());
			}
			
			return GeneratedTbl;
		}
		
		public void Save(bool unload = false) {
			if (unload) {
				FurnacesCheck(FurnaceConfig);
				PlayersCheck(PlayerConfig);
			}
			PluginInstance.SaveStudy(PlayerConfig,FurnaceConfig);
		}
		
		public void Load(Dictionary<string, PlayerInfo> playerConfig, Dictionary<string, string> furnaceConfig) {
			if (playerConfig!=null) PlayerConfig = playerConfig;
			if (furnaceConfig!=null) FurnaceConfig = furnaceConfig;
		}
		
		public void FurnacesCheck(Dictionary<string, string> furnaceConfig) {
			var furnaces = new Dictionary<string, string>();
			if (furnaceConfig!=null&&furnaceConfig.Count>0) {
				BaseOven[] finds = UnityEngine.Object.FindObjectsOfType(typeof(BaseOven)) as BaseOven[];
				foreach (BaseOven find in finds) {
					if (find.ToString().Contains("furnace_deployed")) {
						var instanceId = OvenId(find);
						if (furnaceConfig.ContainsKey(instanceId)) furnaces[instanceId] = furnaceConfig[instanceId];
					}
				}
			}
			FurnaceConfig = furnaces;
		}
		
		private bool CheckTime(double last, int level) {
			var time = CurrentTime();
			if (level<=3) { if (last+60*60*24*3<time) return false; }
			else if (level<=10) { if (last+60*60*24*14<time) return false; }
			else if (level<=30) { if (last+60*60*24*30<time) return false; }
			else if (level<=60) { if (last+60*60*24*90<time) return false; }
			else if (last+60*60*24*180<time) return false;
			return true;
		}
		
		public void PlayersCheck(Dictionary<string, PlayerInfo> playerConfig) {
			var players = new Dictionary<string, PlayerInfo>();
			if (playerConfig!=null&&playerConfig.Count>0) {
				foreach (KeyValuePair<string, PlayerInfo> kvp in playerConfig) {
					if ((kvp.Value.Info.Level>1 || kvp.Value.Info.XP>0 || kvp.Value.PlayerSkills.Count>0 || kvp.Value.WeaponSkills.Count>0) && CheckTime(kvp.Value.LastVisit, kvp.Value.Info.Level))
						players[kvp.Key] = kvp.Value;
				}
			}
			PlayerConfig = players;
		}
		
        public void PlayerInit(BasePlayer player)
        {
            var steamId = SteamId(player);
			if (PlayerConfig.ContainsKey(steamId)) {
				var playerInfo = PlayerInfo(player);
				playerInfo.SteamName = player.displayName;
				playerInfo.LastVisit = CurrentTime();
			}
        }
		
		public void PlayerRespawned(BasePlayer player) {
			if (PluginInstance.IsInArena(player)) return;
			var playerInfo = PlayerInfo(player);
			if (playerInfo.Info.Level>0) {
				var add = 0.5f/PlayerLvlTable.Count*playerInfo.Info.Level;
				player.health = player.health+(player.health*add);
				player.metabolism.calories.Add(player.metabolism.calories.@value*add);
				player.metabolism.hydration.Add(player.metabolism.hydration.@value*add);
			}
		}
		
        public void PlayerDisconnected(BasePlayer player)
        {
            string steamId = SteamId(player);
            if (PlayerTmpInfo.ContainsKey(steamId)) {
				PlayerTmpInfo.Remove(steamId);
			}
        }
		
		public void OnItemCraft(ItemCraftTask craft) {
            var itemName = craft.blueprint.targetItem.displayName.translated.ToLower();
            if (!ItemTable.ContainsKey(itemName)||!StudySTypes.ContainsKey("craft")) return;
            var blueprintTime = ItemTable[itemName].BlueprintTime;

			craft.blueprint.time = blueprintTime-blueprintTime*StudyGetType(PlayerInfo(craft.owner),"craft")*(1-StudyGetType(PlayerInfo(craft.owner),"total",0f,craft.owner));
			//Print(craft.blueprint.time.ToString());
		}
		
        public float LoseCondition(Item item, float amount)
        {
			var player = item.GetOwnerPlayer();
			if (player==null) return amount;
			if (PluginInstance.IsInArena(player)) return amount;
			/*var playerTmp = PlayerTmp(player);
			if (playerTmp.Cache.ContainsKey("condition") && ((Dictionary<string,float>)playerTmp.Cache["condition"]).ContainsKey(item.info.shortname)) {
				var mul = ((Dictionary<string,float>)playerTmp.Cache["condition"])[item.info.shortname];
				if (mul<1) amount *= mul;
				return amount;
			}*/
			var playerInfo = PlayerInfo(player);
			var mul = 1f;
			if (playerInfo.WeaponSkills.ContainsKey(item.info.shortname)) {
				var total = WeaponLvlTable.Count; 
				if (item.info.shortname=="rock") total = RockLvlTable.Count;
				mul = 1-(WeaponCondX/total*playerInfo.WeaponSkills[item.info.shortname].Info.Level);
			}
			var clancond = PluginInstance.GetClanBonus(SteamId(player),"cond");
			if (clancond>0f) mul -= clancond;
			if (mul<1f) amount *= mul;
			return amount;
        }

		private bool IsHuman(object ent, bool player = false) {
			//Print(ent.ToString());
			if (ent!=null && (ent.ToString().Contains("player") || ent.ToString().Contains("animals") && !player) && !ent.ToString().Contains("corpse")) return true;
			return false;
		}
		
		public void OnPlayerAttack(BasePlayer attacker, HitInfo hitInfo) {
			var ent = hitInfo.HitEntity;
			if (ent!=null && ent.GetComponent<ResourceDispenser>()!=null||IsNPC(attacker)) return;
			
			var player = attacker; //hitInfo.Initiator as BasePlayer;
			if (PluginInstance.IsInArena(player)) return;
			
			var playerInfo = PlayerInfo(player);

			Item weaponObj = (hitInfo.Weapon as HeldEntity).GetItem();
			if (weaponObj==null) return;
			string weapon = weaponObj.info.shortname;

			if (weapon=="syringe_medical"||weapon=="torch") return;

			//var meleeItem = player.svActiveItem.GetHeldEntity() as BaseMelee;
			//var cond = 1f; //meleeItem.GetGatherInfoFromIndex(dispenser.gatherType);
			
			var addxp = 0.25f;
			if (IsHuman(ent)) addxp = 1f;
			var ret = CalcAction(player,"Attack",new Dictionary<string, object>(){
				{"Type","Flesh"},
				{"AddXP",addxp},
				{"Weapon",weapon},
				{"WeaponObj",weaponObj},
				//{"ConditionLost",cond}
			});
			
			if (ret==null||ent==null||ent.GetComponent<BasePlayer>()==null&&ent.GetComponent<BaseNPC>()==null) return;
			
			float skillmul = StudyGetType(playerInfo,"damage");
			float profmul = StudyProfType(playerInfo,"Kill");
			
			float mul = skillmul+profmul+(1-StudyGetType(PlayerInfo(player),"total",1f,player));
			var clanbonus = PluginInstance.GetClanBonus(SteamId(player),"damage");
			if (clanbonus>0f) mul += clanbonus;
			clanbonus = PluginInstance.GetWeaponBonus(SteamId(player),weapon);
			if (clanbonus>0f) mul += clanbonus;
			
			if (mul>0f) {
				for (int i = 0; i < hitInfo.damageTypes.types.Length; i++) {
					if (hitInfo.damageTypes.types[i]>0f) hitInfo.damageTypes.types[i] += hitInfo.damageTypes.types[i]*mul;
				}
			}
		}
		
		private bool IsNPC(BasePlayer player) {
			if (player.userID < 76560000000000000L) return true;
			return false;
		}
		
        public void DeployItem(Deployer deployer, BaseEntity baseEntity)
        {
            var player = deployer.ownerPlayer;
            var item = deployer.GetItem();
            var itemDef = item.info;
            var type = baseEntity.GetType();
            if (type != typeof (BaseOven) || !itemDef.displayName.translated.ToLower().Equals("furnace")) return;
            var baseOven = (BaseOven)baseEntity;
            var instanceId = OvenId(baseOven);
            if (FurnaceConfig.ContainsKey(instanceId))
            {
                ChatMessage(player, "Ошибка привязки печки к игроку, сообщите владельцу сервера: "+instanceId);
                return;
            }
            FurnaceConfig.Add(instanceId, SteamId(player));
        }

        private string OvenId(BaseOven oven)
        {
            var position = oven.transform.position;
            return String.Format("X{0} Y{1} Z{2}", position.x, position.y, position.z);
        }
		
        public void ConsumeFuel(BaseOven oven, Item fuel, ItemModBurnable burnable)
        {
            var instanceId = OvenId(oven);
            if (!FurnaceConfig.ContainsKey(instanceId))
                return;
            //var player = BasePlayer.FindByID(Convert.ToUInt64(FurnaceConfig[instanceId]));
            var playerInfo = PlayerInfo(null,FurnaceConfig[instanceId]);
			var clanbonus = PluginInstance.GetClanBonus(FurnaceConfig[instanceId],"kuznec");
			var type = StudySTypes.ContainsKey("int")?"int":"kuznec";
            if (clanbonus==0f && (playerInfo==null || !playerInfo.PlayerOptions.ContainsKey(type) || playerInfo.PlayerOptions[type].Points==0)) return;
			var mul = (playerInfo!=null?StudyGetType(playerInfo,"kuznec"):0f);
			if (clanbonus>0f) mul += clanbonus;
			if (mul==0f) return;
            var chs = mul*0.5f;
            var rand = UnityEngine.Random.Range(0f,1f);
            if (rand<=chs) {
				var amountToGive = 1;
				var itemList = oven.inventory.itemList;
				var itensCanMelt = (from item in itemList let itemModCookable = item.info.GetComponent<ItemModCookable>() where itemModCookable != null select item).ToList();
				foreach (var item in itensCanMelt)
				{
					var itemModCookable = item.info.GetComponent<ItemModCookable>();
					oven.inventory.Take(null, item.info.itemid, amountToGive);
					var itemToGive = ItemManager.Create(itemModCookable.becomeOnCooked, amountToGive, false);
					//Print(itemToGive.info.shortname);
					if (!itemToGive.MoveToContainer(oven.inventory, -1, true))
						itemToGive.Drop(oven.inventory.dropPosition, oven.inventory.dropVelocity);
				}
			}
        }
		
		public void OnEntityAttacked(BaseCombatEntity entity, HitInfo hitInfo) {
			if (hitInfo.Initiator!=null && IsHuman(hitInfo.Initiator) && entity.ToPlayer()) {
				var player = entity as BasePlayer;
				if (!IsNPC(player)) {
					if (PluginInstance.IsInArena(player)) return;
					BasePlayer attacker = null;
					bool selfdmg = false;
					if (IsHuman(hitInfo.Initiator,true)) {
						attacker = hitInfo.Initiator as BasePlayer;
						if (attacker.userID==player.userID) selfdmg = true;					
					}					
					
					var playerInfo = PlayerInfo(player);
					if (!selfdmg) {
						var chs = StudyGetType(playerInfo,"lovk")*(1+StudyGetType(playerInfo,"total",0f,player))*100;
						var rand = UnityEngine.Random.Range(0f,100f);
						if (rand<=chs) {
							ChatMessage(player,"<color='#00DD00'>Вы уклонились от атаки!</color>");
							if (attacker!=null) ChatMessage(attacker,"<color='#DD0000'>Игрок " + player.displayName + " уклонился от атаки!</color>");
							while (hitInfo.damageTypes.Total() > 0) {
								hitInfo.damageTypes.Set( hitInfo.damageTypes.GetMajorityDamageType(), 0 );
							}
							hitInfo.HitMaterial = 0;
							return;
						}
					
						float mul = StudyGetType(playerInfo,"defence")+StudyGetType(playerInfo,"total",0f,player);
						var clanbonus = PluginInstance.GetClanBonus(SteamId(player),"defence");
						if (clanbonus>0f) mul += clanbonus;
						if (mul>0f) {
							for (int i = 0; i < hitInfo.damageTypes.types.Length; i++) {
								if (hitInfo.damageTypes.types[i]>0f) hitInfo.damageTypes.types[i] -= hitInfo.damageTypes.types[i]*mul;
							}
						}
					} else {
						float mul = 0f;
						var raddmg = hitInfo.damageTypes.Get(Rust.DamageType.Radiation);
						float clanbonus = 0f;
						if (raddmg>0f) {
							mul = StudyGetType(playerInfo,"rad")+StudyGetType(playerInfo,"total",0f,player);
							clanbonus = PluginInstance.GetClanBonus(SteamId(player),"stalker");
							if (clanbonus>0f) mul += clanbonus;
							hitInfo.damageTypes.Set(Rust.DamageType.Radiation,raddmg-raddmg*mul);
						}
						mul = StudyGetType(playerInfo,"vinos")+StudyGetType(playerInfo,"total",0f,player);
						clanbonus = PluginInstance.GetClanBonus(SteamId(player),"vinos");
						if (clanbonus>0f) mul += clanbonus;
						if (mul>0f) {
							int[] arr = {(int)Rust.DamageType.Cold,(int)Rust.DamageType.Drowned,(int)Rust.DamageType.Heat,(int)Rust.DamageType.Hunger};
							for (int i = 0; i < hitInfo.damageTypes.types.Length; i++) {
								if (Array.Exists(arr, e => e == i) && hitInfo.damageTypes.types[i]>0f) hitInfo.damageTypes.types[i] -= hitInfo.damageTypes.types[i]*mul; 
							}
						}
					}
				}
			}
		}
		
		public void OnEntityDeath(BaseCombatEntity entity, HitInfo hitInfo) {
			
			if (hitInfo.Initiator!=null && IsHuman(entity) && hitInfo.Initiator.ToPlayer() && !IsNPC(hitInfo.Initiator as BasePlayer)) {
				var player = hitInfo.Initiator as BasePlayer;
				if (PluginInstance.IsInArena(player)) return;
				var type = "Flesh";
				if (IsHuman(entity,true)) type = "Kill";
				//if (player.svActiveItem==null) return;
				//var playerInfo = PlayerInfo(player);
				if (hitInfo.Weapon==null) return;
				Item weaponObj = (hitInfo.Weapon as HeldEntity).GetItem();
				string weapon = weaponObj.info.shortname;

				//var meleeItem = player.svActiveItem.GetHeldEntity() as BaseMelee;
				//var cond = 1f; //meleeItem.GetGatherInfoFromIndex(dispenser.gatherType);
				
				var ret = CalcAction(player,"Kill",new Dictionary<string, object>(){
					{"Type",type},
					{"ItemAmount",350},
					{"Weapon",weapon},
					{"WeaponObj",weaponObj},
					{"PlayerProf",true},
					//{"ConditionLost",cond}
				});
				
				if (ret==null) return;
				
				/*
				if (player.svActiveItem.condition>0f && (float)ret["totalamount"]>0) {
					player.svActiveItem.condition += cond.conditionLost*(float)ret["totalamount"];
				}*/				
			} else if (entity.GetComponentInParent<BaseOven>() != null) {
				var deploy = entity.GetComponentInParent<Deployable>();
				var name = StringPool.Get(deploy.prefabID).ToString();
				if (name=="items/furnace_deployed") {
					var instanceId = OvenId(entity.GetComponentInParent<BaseOven>());
					if (FurnaceConfig.ContainsKey(instanceId)) {
						FurnaceConfig.Remove(instanceId);
					}
				}
			}
		}
		
		public void OnGather(ResourceDispenser dispenser, BaseEntity entity, Item item)
		{	
			BasePlayer player = entity.ToPlayer();
			var type = dispenser.gatherType.ToString();
			string weapon = player.svActiveItem.info.shortname;
			
			if (type!="Flesh") {
				if(!CorrectResources.ContainsKey(type)) {
					return;
				}
				if(!CorrectResources[type].Exists(e => e.EndsWith(weapon))) {
					if (ShowMessage(player,weapon,true)) ChatMessage(player, "<color='#00DD00'>Прогресс обучения:</color>\n<color='#FF0000'>Обучение невозможно - не верный ресурс!</color>");
					return;
				}
			}
			
			var skull = false;
			if (item.info.shortname=="skull_human" || item.info.shortname=="skull_wolf") skull = true;

			var meleeItem = player.svActiveItem.GetHeldEntity() as BaseMelee;
			var cond = meleeItem.GetGatherInfoFromIndex(dispenser.gatherType);
			if (weapon=="knife_bone"&&type=="Flesh"&&!skull) {
				cond.conditionLost = 0.33f;
				item.amount *= 2;
				//player.svActiveItem.condition -= 0.33f;
			}
			
			var ret = CalcAction(player,"Gather",new Dictionary<string, object>(){
				{"Type",type},
				{"ItemAmount",item.amount},
				{"Weapon",weapon},
				{"WeaponObj",player.svActiveItem},
				{"PlayerProf",true},
				//{"ConditionLost",cond.conditionLost}
			});
			
			if (ret==null) return;
			//item.amount += (int)Math.Round(item.amount*(1+(AmMul*WeaponSkill.Level))-item.amount*2);
			//Print(item.info.shortname.ToString());
			if (((float)ret["totalamount"]>0||StartGatherX!=1f) && !skull) {
				item.amount = (int)Math.Round(item.amount*(1+StudyGetType(PlayerInfo(player),"total",0f,player))*(1+(float)ret["totalamount"])*StartGatherX);
			}
			var clangather = PluginInstance.GetClanBonus(SteamId(player),"gather");
			var isvip = PluginInstance.IsVIP(player);
			if (!skull && (isvip || clangather>0f)) {
				var mul = (isvip?1.25f:1f);
				if (clangather>0f) mul += clangather;
				item.amount = (int)Math.Round(mul*item.amount);
			}
			/*if (player.svActiveItem.condition>0f && (float)ret["totalamount"]>0) {
				player.svActiveItem.condition += cond.conditionLost*(float)ret["totalamount"];
			}*/
			
		}
		
		private bool CanAffordUpgrade(int grade, BuildingBlock buildingBlock, BasePlayer player, float amount)
		{
			bool flag = true;
			List<ItemAmount>.Enumerator enumerator = buildingBlock.blockDefinition.grades[(int)buildingBlock.grade].costToBuild.GetEnumerator(); //this[iGrade].costToBuild.GetEnumerator();
			/*try
			{*/
			Dictionary<int,float> costs = new Dictionary<int,float>();
			while (enumerator.MoveNext())
			{
				ItemAmount current = enumerator.Current;
				var calc = (int)Math.Ceiling(current.amount*amount);
				costs[current.itemid] = current.amount-calc;
			}
			
			enumerator = buildingBlock.blockDefinition.grades[grade].costToBuild.GetEnumerator();
			
			while (enumerator.MoveNext())
			{
				ItemAmount current = enumerator.Current;
				var calc = (int)Math.Ceiling(current.amount*amount);
				var cost = 0f;
				if (costs.ContainsKey(current.itemid)) {
					cost = costs[current.itemid];
					costs.Remove(current.itemid);
				}
				if (player.inventory.GetAmount(current.itemid) >= current.amount-calc+cost)
				{
					continue;
				}
				flag = false;
				return flag;
			}
			
			if (costs.Count>0) {
				foreach(KeyValuePair<int,float> kvp in costs) {
					if (player.inventory.GetAmount(kvp.Key) >= kvp.Value) {
						continue;
					}
					flag = false;
					return flag;
				}
			}
			//return true;
			/*}
			finally
			{
				((IDisposable)(object)enumerator).Dispose();
			}*/
			return flag;
		}
		
        public void OnEntityBuilt(Planner planner, UnityEngine.GameObject gameObject)
        {	
			var addxp = 5;
			
			BuildingBlock buildingBlock = gameObject.GetComponent<BuildingBlock>();
			if (buildingBlock==null) return; 
			var items = buildingBlock.blockDefinition.grades[(int)buildingBlock.grade].costToBuild;
			int amount = 0;
			var player = planner.ownerPlayer;
			var playerInfo = PlayerInfo(player);
			if (playerInfo.PlayerSkills.ContainsKey("Build")) {
				//List<Item> items2 = new List<Item>();
				var level = playerInfo.PlayerSkills["Build"].Info.Level;
				if (level>0) {
					var calc = (1-(float)(StudyProfs["Build"].Skills["Build"].Mul))/SkillLvlTable.Count*level*(1+StudyGetType(playerInfo,"total",0f,player));
					var grade = PlayerTmp(player).BuildGrade;
					if (grade>0&&grade>(int)buildingBlock.grade&&buildingBlock.blockDefinition.grades[grade]) {
						if (!CanAffordUpgrade(grade,buildingBlock,player,calc)) {
							foreach (ItemAmount itemAmount in items)
							{
								player.inventory.GiveItem(itemAmount.itemid,(int)itemAmount.amount);
							}
							gameObject.GetComponent<BaseEntity>().KillMessage();
							ChatMessage(player,"Недостаточно ресурсов для постройки.");
							return;
						} else {
							var grd = (BuildingGrade.Enum) grade;
							buildingBlock.SetGrade(grd);
							buildingBlock.SetHealthToMax();
							addxp = grade*30+5;
							var items2 = buildingBlock.blockDefinition.grades[grade].costToBuild;
							List<Item> items3 = new List<Item>();
							foreach (ItemAmount itemAmount in items2)
							{
								amount = (int)Math.Ceiling(itemAmount.amount-(int)Math.Ceiling(itemAmount.amount*calc));
								player.inventory.Take(items3, itemAmount.itemid, amount);
								player.Command(string.Concat(new object[] { "note.inv ", itemAmount.itemid, " ", amount * -1f }), new object[0]);
							}
						}
					}			
					foreach (ItemAmount itemAmount in items)
					{
						amount = (int)Math.Ceiling(itemAmount.amount*calc);
						//planner.ownerPlayer.inventory.Take(items2, itemAmount.itemid, amount);
						//planner.ownerPlayer.Command(string.Concat(new object[] { "note.inv ", itemAmount.itemid, " ", amount * -1f }), new object[0]);
						player.inventory.GiveItem(itemAmount.itemid,amount);
					}	
				}
			}
			
			var ret = CalcAction(player,"Build",new Dictionary<string, object>(){
				{"Type","Build"},
				{"ItemAmount",addxp},
				{"PlayerProf",true},
				//{"ConditionLost",1f}
			});		
		}
		
        public void OnBuildingBlockUpgrade(BuildingBlock buildingBlock, BasePlayer player, BuildingGrade.Enum grade)
        {
			var ret = CalcAction(player,"Upgrade",new Dictionary<string, object>(){
				{"Type","Build"},
				{"ItemAmount",(int)grade*30},
				{"PlayerProf",true},
				//{"ConditionLost",1f}
			});
			
			var items = buildingBlock.blockDefinition.grades[(int)grade].costToBuild;
			int amount = 0;
			//List<Item> items2 = new List<Item>();
			var level = PlayerInfo(player).PlayerSkills["Build"].Info.Level;
			if (level>0) {
				foreach (ItemAmount itemAmount in items)
				{
					amount = (int)Math.Ceiling(itemAmount.amount*(1-(float)(StudyProfs["Build"].Skills["Build"].Mul))/SkillLvlTable.Count*level*(1+StudyGetType(PlayerInfo(player),"total",0f,player)));
					//planner.ownerPlayer.inventory.Take(items2, itemAmount.itemid, amount);
					//planner.ownerPlayer.Command(string.Concat(new object[] { "note.inv ", itemAmount.itemid, " ", amount * -1f }), new object[0]);
					player.inventory.GiveItem(itemAmount.itemid,amount);
				}	
			}
		}
		
		private Dictionary<string, object> CalcAction(BasePlayer player, string action, Dictionary<string, object> args) {
			var playerInfo = PlayerInfo(player);
			//string steamId = SteamId(player);
			var type = (string)args["Type"];
			
			var weapon = "null";
			Item weaponObj = null;
			if (args.ContainsKey("Weapon")) weapon = (string)args["Weapon"];
			if (args.ContainsKey("WeaponObj")) weaponObj = (Item)args["WeaponObj"];
			var IsUp = false;
			var IsMax = false;
			
			var ret = new Dictionary<string, object>();
			
			var chatmsg = "";
			var chatmsgevent = "";
			ret["totalamount"] = 0f;
			//ret["totalcond"] = 0f;
			
			var AddXP = 0f;
			
			if (args.ContainsKey("PlayerProf")) {
				if(StudyProfs.ContainsKey(type)) {
					var skill = StudyProfs[type];
					AddXP = 0.5f;
					if (args.ContainsKey("AddProfXP")) {
						AddXP = (float)args["AddProfXP"];
					} else if (weapon!="rock") {
						AddXP = (int)args["ItemAmount"]/skill.Div;
					}					
					var playerProf = CalcLvl(player,playerInfo,action,"Prof",AddXP,type,skill.Name[0],skill);
					
					if (playerProf.chatmsg!="") chatmsg += playerProf.chatmsg + "\n";
					//ret["SkillXPPerc"] = playerSkill.XPPerc;
					if (playerProf.IsUp) IsUp = true;
					if (IsMax) IsMax = true;
					ret["totalamount"] = (float)ret["totalamount"]+playerProf.amount;
					//ret["totalcond"] = (float)ret["totalcond"]+playerProf.cond;
					
					ret["PlayerProf"] = playerProf;
					if (playerProf.IsUp && StudyEvents.ContainsKey(type) && StudyEvents[type].ContainsKey(playerInfo.PlayerSkills[type].Info.Level)) {
						if (chatmsgevent!="") chatmsgevent += "\n";
						chatmsgevent += StudyEvents[type][playerInfo.PlayerSkills[type].Info.Level];
					}
				}
			}
			
			if (weapon!="null") {
				AddXP = 1f;
				if (args.ContainsKey("AddXP")) {
					AddXP = (float)args["AddXP"];
				} else if (type=="Flesh"&&weapon!="rock") {
					AddXP = 5f;
				}

				var weaponSkill = CalcLvl(player,playerInfo,action,"Weapon",AddXP,weapon,weaponObj.info.displayName.translated);
				
				chatmsg += weaponSkill.chatmsg;
				if (weaponSkill.IsUp) IsUp = true;
				if (weaponSkill.IsMax && (!ret.ContainsKey("PlayerProf") || ((CalcLvlRet)ret["PlayerProf"]).IsMax)) IsMax = true;
				//ret["totalamount"] = (float)ret["totalamount"]+weaponSkill.amount;
				//ret["totalcond"] = (float)ret["totalcond"]+weaponSkill.cond;
				ret["WeaponSkill"] = weaponSkill;
			}
			
			if (IsUp) {
				AddXP = 0f;
				if (ret.ContainsKey("WeaponSkill")?((CalcLvlRet)ret["WeaponSkill"]).IsUp:false) AddXP += 5f;
				if (ret.ContainsKey("PlayerProf")?((CalcLvlRet)ret["PlayerProf"]).IsUp:false) AddXP += 5f;
				var playerLvl = CalcLvl(player,playerInfo,action,"Player",AddXP); 
				chatmsg = playerLvl.chatmsg + chatmsg;
				if (playerLvl.IsUp && StudyEvents["playerlvl"].ContainsKey(playerInfo.Info.Level)) {
					if (chatmsgevent!="") chatmsgevent += "\n";
					chatmsgevent += StudyEvents["playerlvl"][playerInfo.Info.Level];
				}
			}
			
			if (chatmsgevent!="") {
				chatmsg += "\n<color='#DD0000'>Достижения:</color>\n"+chatmsgevent;
			}
			
			var showmsg = true;
			if (playerInfo.MsgMode==2) showmsg = false;
			else if (playerInfo.MsgMode==1 && !IsUp) showmsg = false;
			
			if (chatmsg!="" && showmsg && ShowMessage(player,weapon,false,(ret.ContainsKey("WeaponSkill")?((CalcLvlRet)ret["WeaponSkill"]).XPPerc:0),(ret.ContainsKey("PlayerProf")?((CalcLvlRet)ret["PlayerProf"]).XPPerc:0),IsUp,IsMax)) {
				/*var meleeItem = player.svActiveItem.GetHeldEntity() as BaseMelee;
				float cond = 0f;
				if (action=="Gather") cond = (float)args["ConditionLost"];
				var xcond = (float)ret["totalcond"];
				if (float.IsNaN(xcond)) xcond = 1;
				
				decimal TotalX = 0;
				if (action=="Gather") TotalX = (decimal)Math.Round((1+(((float)ret["totalamount"])*StartGatherX)/(int)args["ItemAmount"])*StartGatherX,2);
				//decimal TotalC = (decimal)Math.Round(xcond*100,2);
				
				if (IsUp || IsMax) {
					if (action=="Gather") {
						chatmsg += "\n\n<color='#00DD00'>Сумарные бонусы:</color> добыча <color='#00DD00'>x" + TotalX.ToString() + "</color>.";					
					} else {
						chatmsg += "\n\n<color='#00DD00'>Сумарные бонусы:</color> прочность <color='#00DD00'>+" + TotalC.ToString() + "%</color>.";
					}
				}*/ //#AAFFAA
				ChatMessage(player,"<color='#00DD00'>Прогресс обучения:</color>\n" + chatmsg);
			}
			
			return ret;
		}
		
		private CalcLvlRet CalcLvl(BasePlayer player, PlayerInfo playerInfo, string maction, string action, float AddXP, string type = "", string skillName = "", object skill = null) 
		{
			int NeedXP = 0;
			int MaxLvl = 0;		
			LvlInfo playerTbl = playerInfo.Info;
			if (action=="Player") {
				playerTbl = playerInfo.Info;
				MaxLvl = PlayerLvlTable.Count+1;
				NeedXP = PlayerLvlTable[(playerTbl.Level>=MaxLvl?MaxLvl-1:playerTbl.Level)];
			} else if (action=="Prof") {
				if(!playerInfo.PlayerSkills.ContainsKey(type)) playerInfo.PlayerSkills[type] = new PlayerSkill(skillName);		
				playerTbl = playerInfo.PlayerSkills[type].Info;
				MaxLvl = SkillLvlTable.Count;
				NeedXP = SkillLvlTable[(playerTbl.Level>=MaxLvl?MaxLvl:playerTbl.Level+1)];
			} else if (action=="Weapon") {
				if(!playerInfo.WeaponSkills.ContainsKey(type)) playerInfo.WeaponSkills[type] = new PlayerSkill(skillName);
				playerTbl = playerInfo.WeaponSkills[type].Info;				
				if (type=="rock") {
					MaxLvl = RockLvlTable.Count;
					NeedXP = RockLvlTable[(playerTbl.Level>=MaxLvl?MaxLvl:playerTbl.Level+1)];
				} else {
					MaxLvl = WeaponLvlTable.Count;
					NeedXP = WeaponLvlTable[(playerTbl.Level>=MaxLvl?MaxLvl:playerTbl.Level+1)];
				}
			}
			
			if (playerTbl.Level>MaxLvl) {
				playerTbl.Level=MaxLvl;
			}		
			
			if (action!="Player") {
				if (XPMul!=1f) {
					AddXP *= XPMul;
				}
				if (PluginInstance.IsVIP(player)) {
					AddXP *= 1.5f;
				}
			}
			
			var chatmsg = "";
			if (action=="Player") {
				chatmsg = "<color='#ffb400'>Уровень игрока</color> ";
			} else if (action=="Prof") {
				chatmsg = "<color='#ffb400'>Мастерство " + skillName + "</color> ";
			} else if (action=="Weapon") {
				chatmsg = "<color='#ffb400'>Владение " + skillName + "</color> ";
			}
			
			var IsMax = false;
			var IsUp = false;
			
			var chatmsgo = "";
			
			if (playerTbl.Level==MaxLvl) {
				IsMax = true;
			} else {
				playerTbl.XP += AddXP;
				if (playerTbl.XP >= NeedXP) {
					if (playerTbl.XP-NeedXP>0) playerTbl.XP = playerTbl.XP-NeedXP;
					else playerTbl.XP = 0;
					playerTbl.Level += 1;
					IsUp = true;
					if (action=="Player") {
						chatmsg = "\n" + chatmsg;
						chatmsgo = CalcPlayerLvlOptions(player,playerInfo);
					}
					if (playerTbl.Level==MaxLvl) {
						IsMax = true;
					}
				}		
			}
			
			float AmMul = 0f; 
			float CondMul = 0f;
			float LvlX = 0f;
			float CondP = 0f;
			var XPPerc = (decimal)Math.Round((decimal)playerTbl.XP/(decimal)NeedXP*100,2);
			if (action=="Prof") {
				AmMul = ((float)((StudyProf)skill).Skills[type].Mul-1)/MaxLvl;
				//CondMul = TotalGatherC*0.7f/MaxLvl;	
			} else if (action=="Weapon") {
				//AmMul = (WeaponGatherX-1)/MaxLvl;
				CondMul = WeaponCondX/MaxLvl;		
			}
			if (action!="Player") {
				LvlX = (float)Math.Round(AmMul*playerTbl.Level,2); //*StartGatherX
				CondP = (float)Math.Round(CondMul*playerTbl.Level*100,2);
			}

			chatmsg += "[" + playerTbl.Level.ToString() + " лвл]: ";
			
			var showchat = true;
			var playerTmp = PlayerTmp(player);
			
			if (IsMax) {
				if (IsUp) {
					chatmsg += "<color='#00AA00'>Поздравляем! Вы достигли максимального уровня!</color>";	
					if (chatmsgo!="") chatmsg += chatmsgo;
				} else {
					chatmsg += "<color='#00AA00'>Вы уже достигли максимальный уровень!</color>";
					//if (maction=="Gather") chatmsg += " (<color='#00DD00'>x" + LvlX.ToString() + "</color>, <color='#00DD00'>+" + CondP.ToString() + "%</color>)";
					if (action=="Player"||action=="Prof"&&playerTmp.ProfTmp.ContainsKey(type)||action=="Weapon"&&playerTmp.WeapTmp.ContainsKey(type)) showchat = false;
					else if (action=="Prof"&&!playerTmp.ProfTmp.ContainsKey(type)) playerTmp.ProfTmp[type] = true;
					else if (action=="Weapon"&&!playerTmp.WeapTmp.ContainsKey(type)) playerTmp.WeapTmp[type] = true;
				}
			} else if (IsUp) {
				chatmsg += " <color='#DD0000'>Новый уровень!</color>";
				if (chatmsgo!="") chatmsg += chatmsgo;
				if (action!="Player"&&playerTbl.Level>0) {
					//if (maction=="Gather") chatmsg += " (<color='#00DD00'>x" + LvlX.ToString() + "</color>, <color='#00DD00'>+" + CondP.ToString() + "%</color>)";
					//else chatmsg += " (<color='#00DD00'>+" + CondP.ToString() + "%</color>)";
					if (action=="Weapon") {
						chatmsg += " (<color='#00DD00'>+" + CondP.ToString() + "%</color> прочности)";
					} else {
						var act = "";
						var skl = StudyProfs[type].Skills[type];
						var level = playerTbl.Level;
						var clangather = PluginInstance.GetClanBonus(SteamId(player),"gather");
						if (skl.MulTxt=="x") {
							//act = "x"+((float)Math.Round(StartGatherX*(StartGatherX+((float)skl.Mul-1)/SkillLvlTable.Count*level-1),2)).ToString();
							var vip = (PluginInstance.IsVIP(player)?1.25f:1f);
							if (clangather>0f) vip += clangather;
							act = "x"+((float)Math.Round((StartGatherX+((StartGatherX*skl.Mul-StartGatherX)/SkillLvlTable.Count*level))*vip,2)).ToString();
						} else if (skl.MulTxt=="+") {
							act = skl.MulTxt+((float)Math.Round(((float)skl.Mul-1)/SkillLvlTable.Count*level*100,2)).ToString()+"%";
						} else {
							act = ((float)Math.Round(((float)skl.Mul-1)/SkillLvlTable.Count*level*100,2)).ToString()+"%";
						}
					
						chatmsg += " (<color='#00DD00'>" + act + "</color>)";
					}
				}
			} else {
				chatmsg += XPPerc.ToString() + "%";
			}
			
			//if (IsUp || IsMax) {
			//	chatmsg += "\n<color='#00DD00'>Бонусы:</color> добыча <color='#00DD00'>x" + LvlX.ToString() + "</color>, прочность <color='#00DD00'>+" + CondP.ToString() + "%</color>.";
			//}
			
			float cond = CondMul*playerTbl.Level;					
			float amount = AmMul*playerTbl.Level;
			
			if (action=="Player") chatmsg += "\n";
			if (!showchat) chatmsg = "";
			
			return new CalcLvlRet(chatmsg, amount, cond, XPPerc, IsUp, IsMax);		
		}
		
		private string CalcPlayerLvlOptions(BasePlayer player, PlayerInfo playerInfo) 
		{
			var skills = StudySkills.Count;
			var chatmsg = "";
			if (skills>0) {
				var add = 4; //skills*50/100;
				
				var playerOptions = playerInfo.PlayerOptions;
				
				if (playerInfo.Info.Level<=2&&playerOptions.Count==0) {
					foreach(KeyValuePair<string,StudySkill> kvp in StudySkills ) {
						if(!playerOptions.ContainsKey(kvp.Key)) playerOptions[kvp.Key] = new PlayerOptions(kvp.Value.Name);
					}
				}
				
				if (playerInfo.Reset) {
					chatmsg += "свободные очки <color='#00DD00'>+" + add.ToString() + "</color>"; 
					playerInfo.Points += add;
				} else {
					chatmsg += CalcPlayerLvlOptionsRnd(playerInfo,add);
				}
			}			
			if (chatmsg!="") chatmsg = "\n<color='#00DD00'>Навыки:</color> " + chatmsg + "\n";
			return chatmsg;
		}
		
		private string CalcPlayerLvlOptionsRnd(PlayerInfo playerInfo, int add, int maxc = 20, bool ignore = false, bool test = false) {
			var playerOptions = playerInfo.PlayerOptions;
			var chatmsg = "";
		
			var rand = new System.Random();
			Dictionary<string,StudySkill> studyskills = StudySkills.OrderBy(x => rand.Next()).ToDictionary(item => item.Key, item => item.Value);
			
			List<string> used = new List<string>();
			Dictionary<string, int> points = new Dictionary<string, int>();
			int rnd;
			int max = 0;
			int maxadd = 0;
			int optc = 0;
			foreach(KeyValuePair<string,StudySkill> kvp in studyskills) { 
				if (!playerOptions.ContainsKey(kvp.Key)) playerOptions[kvp.Key] = new PlayerOptions(kvp.Value.Name);
				if (playerInfo.Info.Level<kvp.Value.MinLvl||playerOptions[kvp.Key].Points>=kvp.Value.Points) continue; 
				optc += 1;
			}
			if (optc<4) ignore = true;
			while(add>0) {
				if (max>=maxc) break;
				foreach(KeyValuePair<string,StudySkill> kvp in studyskills) { 
					if (!playerOptions.ContainsKey(kvp.Key)) playerOptions[kvp.Key] = new PlayerOptions(kvp.Value.Name);
					if (!ignore&&used.Exists(e => e.EndsWith(kvp.Key))||playerInfo.Info.Level<kvp.Value.MinLvl||playerOptions[kvp.Key].Points>=kvp.Value.Points) continue; 
					rnd = (int)Math.Round(UnityEngine.Random.Range(0f, (float)(add>3?3:add)));
					if (playerOptions[kvp.Key].Points+rnd>kvp.Value.Points) rnd = kvp.Value.Points-playerOptions[kvp.Key].Points;
					if (rnd>0) {
						//chatmsg += kvp.Value.Name + " <color='#00DD00'>+" + rnd.ToString() + "</color> ";
						points[kvp.Value.Name] = (points.ContainsKey(kvp.Value.Name)?points[kvp.Value.Name]+rnd:rnd);
						used.Add(kvp.Key);
						if (!test) playerOptions[kvp.Key].Points += rnd;
						add -= rnd;
					}
					if (add<=0) break;
				}
				max += 1;
			}
			foreach (KeyValuePair<string, int> kvp in points) {
				chatmsg += kvp.Key + " <color='#00DD00'>+" + kvp.Value.ToString() + "</color> ";
			}
			return chatmsg;
		}
		
		private bool ShowMessage(BasePlayer player, string weapon, bool OnlyLast = false, decimal XPPerc = 0, decimal SkillXPPerc = 0, bool IsUp = false, bool IsMax = false) 
		{
	
			var SendMessage = true;
	
			var playerTmp = PlayerTmp(player);
			if(!playerTmp.WeaponTmp.ContainsKey(weapon))
			{
				playerTmp.WeaponTmp[weapon] = new WeaponTmp();
			}
			
			var weaponTmp = playerTmp.WeaponTmp[weapon];
			var time = UnityEngine.Time.time;
			
			if (OnlyLast) {
				if (time < weaponTmp.LastGTime) {
					SendMessage = false;
				}
				
				if (time >= weaponTmp.LastGTime) {
					weaponTmp.LastGTime = time+30;
				}
			} else {
				if (IsMax) {
					if (weaponTmp.LastLvl) {
						return false;
					} else {
						weaponTmp.LastLvl = true;
					}
				}
			
				//if (!IsUp && ( time < weaponTmp.Last && (XPPerc < weaponTmp.LastPerc && !IsMax) )) {
				if (!IsUp && ( time < weaponTmp.Last && (time < weaponTmp.LastWTime && !IsMax)) ) {
					SendMessage = false;
				} 
				
				if (!IsUp && !IsMax && time < weaponTmp.Last && time >= weaponTmp.LastWTime && weaponTmp.LastPerc > XPPerc && weaponTmp.LastSkillPerc > SkillXPPerc) {
					SendMessage = false;
					weaponTmp.LastWTime = time+8;
				}
				
				//if (time >= weaponTmp.Last || XPPerc >= weaponTmp.LastPerc && !IsMax || IsUp) {
				if (time >= weaponTmp.Last || time >= weaponTmp.LastWTime && !IsMax || IsUp) {
					weaponTmp.LastPerc = XPPerc+1; //XPPerc+(decimal)Math.Round((decimal)MaxLvl/(WeaponSkill.Level==MaxLvl?MaxLvl:WeaponSkill.Level+1),2);
					weaponTmp.LastSkillPerc = SkillXPPerc+1;
					weaponTmp.Last = time+60;
					weaponTmp.LastWTime = time+8;
				}
			}
			
			return SendMessage;
		}
		
		public string ReCalcSkills(bool auto = false, bool cmd = false) {
			if (auto) {
				foreach(KeyValuePair<string,PlayerInfo> kvp in PlayerConfig) {
					var points = kvp.Value.Info.Level*4-4;
					foreach(KeyValuePair<string,PlayerOptions> kvs in kvp.Value.PlayerOptions) {
						points -= kvs.Value.Points;
					}
					var add = points;
					if (add>0) {						
						CalcPlayerLvlOptionsRnd(kvp.Value,add,1000,true);
					}							
				}			
				if (cmd) return "Player skills auto-recalc complete.";
				return "Навыки игроков перераспределены.";
			} else {
				foreach(KeyValuePair<string,PlayerInfo> kvp in PlayerConfig) {
					kvp.Value.Reset = true;
					kvp.Value.ResetLast = 0;
					kvp.Value.Points = kvp.Value.Info.Level*4;
				}
				if (cmd) return "Player skills reset complete.";
				return "Навыки игроков сброшены.";
			}
			return "";
		}
		
		public string ChatSkill(BasePlayer player, string command, string[] args) {
			var chatmsg = new List<string>();
			var def = true;
			if (args.Length>0) {
				def = false;
				switch (args[0].ToLower())
				{
					case "reset_yes":
					if (player.net.connection.authLevel==2) {
						chatmsg.Add(ReCalcSkills());
					} else def = true;
					break;
					case "reset_auto":
					if (player.net.connection.authLevel==2) {
						chatmsg.Add(ReCalcSkills(true));
					} else def = true;
					break;
					case "about":
					chatmsg.Add("<color='#00DD00'>О системе прокачки</color>");
					chatmsg.Add("<color='#ffb400'>Данная система разработана специально для проекта");
					chatmsg.Add("<color='#FF0000'>Botov.NET.UA</color> и на данный момент является <i>эксклюзивной</i>.</color>\n");
					chatmsg.Add("<color='#00DD00'>Система включает в себя 3 разных типа навыков:</color>");
					chatmsg.Add("--------------");	
					ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
					chatmsg.Clear();
					chatmsg.Add("<color='#00DD00'>Навыки игрока</color><color='#ffb400'>");
					chatmsg.Add("Эти навыки дают определённые бонусы игроку, начислаются случайным образом.");	
					chatmsg.Add("Уровень повышается при получении новых уровней мастерства или владения предметами.");
					chatmsg.Add("При достижении <color='#FF0000'>50+ уровня игрока</color> возможно перераспределение навыков <color='#FF0000'>раз в неделю</color>.");								
					chatmsg.Add("Узнать подробнее - напишите <color='#00DD00'>/skill player</color></color>");	
					chatmsg.Add("--------------");
					ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
					chatmsg.Clear();
					chatmsg.Add("<color='#00DD00'>Навыки игрока</color><color='#ffb400'>");
					chatmsg.Add("Этот тип навыка даёт бонус к соотвствующим ему действиям.");
					chatmsg.Add("Уровень повышается автоматически (например во время охоты).");				
					chatmsg.Add("Узнать подробнее - напишите <color='#00DD00'>/skill master</color></color>");		
					chatmsg.Add("--------------");
					ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
					chatmsg.Clear();
					chatmsg.Add("<color='#00DD00'>Владение предметами</color><color='#ffb400'>");
					chatmsg.Add("Владения предметами добавляет прочность к используемому предмету.");
					chatmsg.Add("При попадании в игроков или их убийства скорость прокачки увеличивается.");
					chatmsg.Add("Уровень повышается автоматически.</color>");									
					break;
					case "player":
					chatmsg.Add("<color='#FF0000'>Список навыков игрока:</color>");
					var desc = new Dictionary<string,string>(){
						{"power","Увеличивает ваш урон против игроков и животных."},
						{"defence","Увеличивает вашу защиту от урона игроков и животных."},
						{"lovk","Увеличивает шанс уклониться от атаки."},
						{"int","Уменьшает время создания предметов, а также увеличивает производство ресурсов в печках (даже когда оффлайн)."},
						{"kuznec","Увеличивает производство ресурсов в печках (даже когда оффлайн)."},
						{"master","Добавляет бонус ко всем навыкам, мастерствам и владения оружия."},
						{"craft","Уменьшает время создания предметов."},
						{"vinos","Уменьшает урон от холода/жары, а также когда тоните."},
						{"stalker","Уменьшает воздействие радиации."}
						//{"speed","Увеличивает скорость бега."}
					}; int i = 1; var i2 = 0;
					foreach(KeyValuePair<string,StudySkill> kvp in StudySkills) {
						if (desc.ContainsKey(kvp.Key)) {
							var add = desc[kvp.Key];
							add += " Макс. очков: <color='#00FF00'>"+kvp.Value.Points+"</color>";
							add += ", макс. эффект: "; var first = true;
							foreach(KeyValuePair<string,StudySkillOpts> kvs in kvp.Value.Skills) {
								if (!first) add += ", ";
								var calc = (float)Math.Round(((float)kvs.Value.Mul-1)*100,2);
								if (calc<0&&kvs.Value.MulTxt=="-") calc *= -1;
								add += (string)kvs.Value.Desc+" <color='#00FF00'>"+kvs.Value.MulTxt+calc.ToString()+"%</color>";
								first = false;
							}
							if (kvp.Value.MinLvl>0) add += ", мин. уровень: <color='#00FF00'>"+kvp.Value.MinLvl+"</color>";
							add += ".";
							chatmsg.Add(i+". <color='#ffb400'><color='#00DD00'>"+kvp.Value.Name+"</color> - "+add+"</color>");
							i++;
							i2++;
							if (i2>2) {
								ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
								chatmsg.Clear();
								i2 = 0;
							}
						}
					}
					ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
					chatmsg.Clear();
					chatmsg.Add("<color='#FF0000'>Некоторые навыки доступны только при достижении определённого уровня игрока.</color>\n");	
					chatmsg.Add("<color='#00DD00'>Дополнительная информация:</color>");
					chatmsg.Add("<color='#ffb400'>Также каждый новый уровень игрока увеличивает стартовое здоровье, добавляет каллории и уменьшает жажду.</color>");
					//chatmsg.Add("Всего на данный момент <color='#FF0000'>"+StudySkills.Count+"</color> навыков игрока.");						
					break;
					case "master":
					chatmsg.Add("<color='#FF0000'>Список мастерств:</color>");
					desc = new Dictionary<string,string>(){
						{"Tree","Увеличивает добычу дерева."},
						{"Ore","Увеличивает добычу камня."},
						{"Flesh","Увеличивает добычу ткань/мяса/жира/костей с животных."},
						{"Kill","Увеличивает урон против игроков."},
						{"Build","Уменьшает стоимость постройки и обновления, a также при достижении <color='#FF0000'>20 уровня</color> разблокируеться доступ к команде:\n"+
						"<color='#00DD00'>/up</color> - автоматическое обновление конструкции до дерева во время строительства.\n"+
						"При достижении <color='#FF0000'>35 уровня</color> - автоматическое обновление констуркции до камня."}
					}; i = 1; i2 = 0;
					foreach(KeyValuePair<string,StudyProf> kvp in StudyProfs) {
						if (desc.ContainsKey(kvp.Key)) {
							var add = desc[kvp.Key];
							add += " Макс. эффект: "; var first = true;
							foreach(KeyValuePair<string,StudySkillOpts> kvs in kvp.Value.Skills) {
								if (!first) add += ", ";
								var act = "";
								if (kvs.Value.MulTxt=="x") {
									act = "x"+((float)Math.Round(StartGatherX*((float)kvs.Value.Mul),2)).ToString();
								} else if (kvs.Value.MulTxt=="+") {
									act = kvs.Value.MulTxt+((float)Math.Round(((float)kvs.Value.Mul-1)*100,2)).ToString()+"%";
								} else {
									act = ((float)Math.Round(((float)kvs.Value.Mul-1)*100,2)).ToString()+"%";
								}
								add += (string)kvs.Value.Desc+" <color='#00FF00'>"+act+"</color>";
								first = false;
							}
							add += ".";
							chatmsg.Add(i+". <color='#ffb400'><color='#00DD00'>"+kvp.Value.Name[1]+"</color> - "+add+"</color>");
							i++;
							i2++;
							if (i2>2) {
								ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
								chatmsg.Clear();
								i2 = 0;
							}
						}
					}		
					ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
					chatmsg.Clear();
					chatmsg.Add("<color='#00DD00'>Дополнительная информация:</color>");
					//chatmsg.Add("<color='#ffb400'>Всего на данный момент <color='#FF0000'>"+StudyProfs.Count+"</color> мастерств.");		
					chatmsg.Add("<color='#ffb400'>Некоторые мастерства дают новые возможности при повышении уровня.</color>");					
					break;
					/*case "items":
					chatmsg.Add("О владении предметами");
					chatmsg.Add("Бла бла бла");							
					break;*/
					default:
					def = true;
					break;
				}
			} 
			if (def) {
				chatmsg.Add("<color='#00DD00'>Система прокачки от</color> <color='#FF0000'>Botov.NET.UA</color> v"+StudyGlobals.Version);
				chatmsg.Add("<color='#FF0000'><size=16>Данная система находится в стадии разработки.</size></color>\n");
				chatmsg.Add("<color='#ffb400'><color='#FF0000'>Список доступных команд:</color>");
				chatmsg.Add("<color='#00DD00'>/skill about</color> - о системе прокачки");
				chatmsg.Add("<color='#00DD00'>/me</color> - узнать вашу основную информацию (уровень, навыки)");		
				chatmsg.Add("<color='#00DD00'>/me items</color> - узнать информацию о владении предметами");
				var playerInfo = PlayerInfo(player);
				if (playerInfo.Info.Level>=50) chatmsg.Add("<color='#00DD00'>/me reset</color> - сбросить ваши навыки");
				if (playerInfo.PlayerSkills.ContainsKey("Build")&&playerInfo.PlayerSkills["Build"].Info.Level>20)
				chatmsg.Add("<color='#00DD00'>/up</color> - автоматическое обновление постройки до дерева/камня");
				chatmsg.Add("</color>");
			}
			return string.Join("\n", chatmsg.ToArray());
		}
		
        public static double CurrentTime()
        {
            return System.DateTime.UtcNow.Subtract(epoch).TotalSeconds;
        }
		
		private string CalcTime(double time) {
			var str = "";
			if (time/60/60/24>1) {
				str = Math.Ceiling(time/60/60/24).ToString()+" дней";
			} else if (time/60/60>1) {
				str = Math.Ceiling(time/60/60).ToString()+" часов";
			} else if (time/60>1) {
				str = Math.Ceiling(time/60).ToString()+" минут";
			} else {
				str = Math.Ceiling(time).ToString()+" секунд";
			}
			return str;
		}
		
		public string ChatMe(BasePlayer player, string command, string[] args) {
			var playerInfo = PlayerInfo(player);
			var chatmsg = new List<string>();
			var def = true;
			var bonus = false;
			
			/*if (1==1) {
				return CalcPlayerLvlOptionsRnd(playerInfo, 4, 20, false, true);
			}*/
			
			if (args.Length>0) {
				def = false;
				switch (args[0].ToLower())
				{
					case "menu": {
						var RndName = ((int)Math.Round(UnityEngine.Random.Range(0f, 10000000f))).ToString();
						
						var x_add = 0.04;

						string json = @"[  
									{
										""name"": ""Test{RND}"",
										""parent"": ""Overlay"",
										""components"":
										[
											{
												 ""type"":""UnityEngine.UI.Image"",
												 ""color"":""0.3 0.3 0.3 0.7"",
											},
											{
												""type"":""RectTransform"",
												""anchormin"": ""0 0"",
												""anchormax"": ""1 1""
											},
											{
												""type"":""NeedsCursor""
											}
										]
									},
									{
										""name"": ""TitlePanelBase{RND}"",
										""parent"": ""Test{RND}"",
										""components"":
										[
											{
												""type"":""UnityEngine.UI.Image"",
												""color"": ""0.3 0.3 0.3 1.0"",
											},
											{
												""type"":""RectTransform"",
												""anchormin"": ""0.1 0.1"",
												""anchormax"": ""0.9 0.9""
											},
										]
									},
									{
										""name"": ""TitlePanelBut{RND}"",
										""parent"": ""TitlePanelBase{RND}"",
										""components"":
										[
											{
												""type"":""UnityEngine.UI.Button"",
												""close"":""Test{RND}"",
												""color"": ""0.6 0.3 0.3 1.0"",
											},
											{
												""type"":""RectTransform"",
												""anchormin"": ""0.9 0.9"",
												""anchormax"": ""1 1""
											},
										]
									},
									{
										""parent"": ""TitlePanelBut{RND}"",
										""components"":
										[
											{
												""type"":""UnityEngine.UI.Text"",
												""text"":""X"",
												""fontSize"":20,
												""align"": ""MiddleCenter"",
											},
										]
									},
									{
										""parent"": ""TitlePanelBase{RND}"",
										""components"":
										[
											{
												""type"":""UnityEngine.UI.Text"",
												""text"":""Ваш ник: {NICK}"",
												""fontSize"":20,
												""align"": ""UpperLeft"",
											},
											{
												""type"":""RectTransform"",
												""anchormin"": ""0.02 0.02"",
												""anchormax"": ""0.98 0.98""
											},
										]
									},
									{
										""parent"": ""TitlePanelBase{RND}"",
										""components"":
										[
											{
												""type"":""UnityEngine.UI.Text"",
												""text"":""Ваш уровень: {LVL}"",
												""fontSize"":20,
												""align"": ""UpperLeft"",
											},
											{
												""type"":""RectTransform"",
												""anchormin"": ""0.02 "+(0.02+x_add)+@""",
												""anchormax"": ""0.98 "+(0.98-x_add)+@"""
											},
										]
									},
									{
										""parent"": ""TitlePanelBase{RND}"",
										""components"":
										[
											{
												""type"":""UnityEngine.UI.Text"",
												""text"":""Ваши навыки:"",
												""fontSize"":20,
												""align"": ""UpperLeft"",
												""color"": ""0.8 0.3 0.3 1""
											},
											{
												""type"":""RectTransform"",
												""anchormin"": ""0.02 "+(0.02+x_add*2)+@""",
												""anchormax"": ""0.98 "+(0.98-x_add*2)+@"""
											},
										]
									},
									{
										""parent"": ""TitlePanelBase{RND}"",
										""components"":
										[
											{
												""type"":""UnityEngine.UI.Text"",
												""text"":""Данное меню в стадии разработки"",
												""fontSize"":20,
												""align"": ""UpperLeft"",
												""color"": ""0.8 0.3 0.3 1"",
											},
											{
												""type"":""RectTransform"",
												""anchormin"": ""0.37 0.0"",
												""anchormax"": ""1 0.05""
											},
										]
									},
									{NAVIKI}
								]
								";
							
							var lvl = playerInfo.Info.Level;
							var perc = -1m;
							if (lvl<=PlayerLvlTable.Count) perc = (decimal)Math.Round((decimal)playerInfo.Info.XP/(decimal)PlayerLvlTable[lvl]*100,2);
							if (perc>99.99m) { perc = 99.99m; }
										
							json = json.Replace("{NICK}",player.displayName);
							json = json.Replace("{LVL}","<color=#00DD00>"+playerInfo.Info.Level.ToString()+"</color>"+(perc>=0m? " ("+perc+"%)" : ""));
							
							if (playerInfo.PlayerOptions.Count>0) {
								var jreplace = ""; 
								var i = 0;
								foreach(KeyValuePair<string,StudySkill> kvp in StudySkills) {
									if (playerInfo.PlayerOptions.ContainsKey(kvp.Key)&&playerInfo.PlayerOptions[kvp.Key].Points>0) {
									
										var bonuses = new List<string>();
										//var perc = (float)kvp.Value.Points/playerInfo.PlayerOptions[kvp.Key].Points;
										
										foreach(KeyValuePair<string,StudySkillOpts> kvs in kvp.Value.Skills) {
											var points = playerInfo.PlayerOptions[kvp.Key].Points;
											var calc = 0f;
											if (kvp.Value.Points>1f) calc = (float)Math.Round(points*(((float)kvs.Value.Mul-1)/kvp.Value.Points)*100,2);
											else calc = (float)Math.Round(points*((float)kvs.Value.Mul/kvp.Value.Points)*100,2);
											if (calc<0f) calc *= -1;
										
											bonuses.Add(((string)kvs.Value.Desc!=""?(string)kvs.Value.Desc + " ":"") + "<color=#00DD00>" + (string)kvs.Value.MulTxt + calc.ToString() + "%</color>");
										}
										
										var bonustr =  string.Join(", ", bonuses.ToArray());		
									
										jreplace += @"                        
										{
											""parent"": ""TitlePanelBase{RND}"",
											""components"":
											[
												{
													""type"":""UnityEngine.UI.Text"",
													""text"":"""+kvp.Value.Name+@""",
													""color"": ""0.9 0.7 0.3 1"",
													""fontSize"":20,
													""align"": ""UpperLeft"",
												},
												{
													""type"":""RectTransform"",
													""anchormin"": ""0.02 "+((0.02+x_add*3)+0.04*i)+@""",
													""anchormax"": ""0.98 "+((0.98-x_add*3)-0.04*i)+@"""
												},
											]
										},
										{
											""parent"": ""TitlePanelBase{RND}"",
											""components"":
											[
												{
													""type"":""UnityEngine.UI.Text"",
													""text"":"""+playerInfo.PlayerOptions[kvp.Key].Points.ToString() + "/" + kvp.Value.Points.ToString()+@""",
													""color"": ""0.3 0.8 0.3 1"",
													""fontSize"":20,
													""align"": ""UpperLeft"",
												},
												{
													""type"":""RectTransform"",
													""anchormin"": ""0.16 "+((0.02+x_add*3)+0.04*i)+@""",
													""anchormax"": ""0.74 "+((0.98-x_add*3)-0.04*i)+@"""
												},
											]
										},
										{
											""parent"": ""TitlePanelBase{RND}"",
											""components"":
											[
												{
													""type"":""UnityEngine.UI.Text"",
													""text"":"""+bonustr+@""",
													""fontSize"":20,
													""align"": ""UpperLeft"",
												},
												{
													""type"":""RectTransform"",
													""anchormin"": ""0.23 "+((0.02+x_add*3)+0.04*i)+@""",
													""anchormax"": ""0.77 "+((0.98-x_add*3)-0.04*i)+@"""
												},
											]
										},
										";	
										i++;
									}
								}	
								
								x_add += x_add*3+x_add*i;
									
								json = json.Replace("{NAVIKI}",jreplace);
							} else {
								json = json.Replace("{NAVIKI}",@"                        
									{
										""parent"": ""TitlePanelBase{RND}"",
										""components"":
										[
											{
												""type"":""UnityEngine.UI.Text"",
												""text"":""У вас ещё не изучены навыки."",
												""fontSize"":20,
												""align"": ""UpperLeft"",
											},
											{
												""type"":""RectTransform"",
												""anchormin"": ""0.02 "+(0.02+x_add*3)+@""",
												""anchormax"": ""0.98 "+(0.98-x_add*3)+@"""
											},
										]
									},
									");
									x_add += x_add*3;
							}
							
							json = json.Replace("{RND}",RndName);
							
							//Print(json);
							//CommunityEntity.ServerInstance.ClientRPCEx(new Network.SendInfo() { connection = player.net.connection }, null, "DestroyUI","Test"+RndName);
							CommunityEntity.ServerInstance.ClientRPCEx(new Network.SendInfo() { connection = player.net.connection }, null, "AddUI", json);
							return "";
						break;
					} case "items":
					chatmsg.Add("<color='#DD0000'>Владения предметами</color>");
					chatmsg.Add("<color='#ffb400'>Владения предметами даёт бонус к их прочности.</color>");
					chatmsg.Add("--------------");	
					if (playerInfo.WeaponSkills.Count>0) {
						var i = 0;
						foreach(KeyValuePair<string,PlayerSkill> kvp in playerInfo.WeaponSkills) {
							var needtbl = (kvp.Key=="rock"?RockLvlTable:WeaponLvlTable);
							var maxlvl = needtbl.Count;
							var add = "";
							decimal perc = 0;
							var condx = 0f;
							if (kvp.Value.Info.Level<maxlvl) perc = (decimal)Math.Round((decimal)kvp.Value.Info.XP/(decimal)needtbl[kvp.Value.Info.Level+1]*100,2);
							if (kvp.Value.Info.Level>0) condx = (float)Math.Round(WeaponCondX/maxlvl*kvp.Value.Info.Level*100,2);
							if (perc>0) add = perc.ToString() + "%";
							if (condx>0f) add += (add!=""?", ":"")+"<color='#00DD00'>+"+condx.ToString()+"%</color>";
							if (add!="") add = " ("+add+")";
							chatmsg.Add("<color='#ffb400'>" + kvp.Value.Name + ":</color> <color='#00DD00'>" + kvp.Value.Info.Level.ToString() + "/" + maxlvl + "</color>" + add);
							i++;
							if (i>5) {
								ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
								chatmsg.Clear();
								i = 0;
							}
						}				
					} else {
						chatmsg.Add("У вас ещё нет навыка владения предметами.");
					}	
					break;
					case "bonus":
					bonus = true;
					def = true;
					break;
					case "finish":
					if (playerInfo.Reset) {
						if (playerInfo.Points>0) {
							chatmsg.Add("Невозможно сохранить навыки, у вас есть ещё <color='#00DD00'>"+playerInfo.Points+"</color> свободных очков. Пожалуйста распределите их.");
						} else {
							foreach(KeyValuePair<string,PlayerOptions> kvp in playerInfo.PlayerOptionsTmp) {
								playerInfo.PlayerOptions[kvp.Key].Points = kvp.Value.Points;
							}
							playerInfo.PlayerOptionsTmp = new Dictionary<string,PlayerOptions>();
							playerInfo.Reset = false;
							playerInfo.ResetLast = CurrentTime();
							chatmsg.Add("<color='#00DD00'>Навыки успешно сохранены.</color>");
							chatmsg.Add("Следующий сброс будет доступен <color='#DD0000'>через неделю</color>.");
						}
					} else chatmsg.Add("<color='#DD0000'>Данная команда доступна только во время перенастройки навыков.</color>");
					break;
					case "set":
					if (playerInfo.Reset) {
						if (args.Length>1) {
							if (args.Length<3) {
								chatmsg.Add("Вы не задали количество очков!");
							} else {
								int addp = 0;
								var arg = args[1].ToLower();
								if (StudySkills.ContainsKey(arg)) {
									try {
									  addp = Convert.ToInt32(args[2]);
									}
									finally {}    
									if (playerInfo.Points<=0&&addp>0) {
										chatmsg.Add("У вас уже нет свободных очков!");
									} else {
										if (!playerInfo.PlayerOptionsTmp.ContainsKey(arg)) playerInfo.PlayerOptionsTmp[arg] = new PlayerOptions(StudySkills[arg].Name);
										var playerOption = playerInfo.PlayerOptionsTmp[arg];
										var calc = playerOption.Points+addp;
										if (addp>0) {
											if (addp>playerInfo.Points) { addp = playerInfo.Points; calc = playerOption.Points; }
											if (calc>StudySkills[arg].Points) addp = StudySkills[arg].Points-playerOption.Points;
											playerOption.Points += addp;
											chatmsg.Add("Вы успешно добавили <color='#00DD00'>+"+addp.ToString()+"</color> очков к навыку <color='#ffb400'>"+StudySkills[arg].Name+"</color>.");
											playerInfo.Points -= addp;
										} else if (addp<0) {
											if (calc<0) addp = 0-playerOption.Points;
											playerOption.Points += addp;	
											chatmsg.Add("Вы успешно отняли <color='#DD0000'>"+addp.ToString()+"</color> очков от навыка <color='#ffb400'>"+StudySkills[arg].Name+"</color>.");	
											playerInfo.Points += addp*(-1);
										} else {
											chatmsg.Add("Вы ввели неверное число!");
										}
									}
								} else {
									chatmsg.Add("Вы задали неверный навык!");
								}
							}
						} else {
							chatmsg.Add("<color='#DD0000'>Перенастройка навыков игрока</color>");
							chatmsg.Add("<color='#ffb400'>Данная команда позволяет настроить ваши навыки игрока. "+
							"Вы должны распределить все ваши доступные очки на навыки и сохранить настройки.</color>");
							chatmsg.Add("--------------");	
							chatmsg.Add("Свободные очки: <color='#00DD00'>"+playerInfo.Points+"</color>");
							chatmsg.Add("Используйте команды ниже чтобы добавить очки к нужным навыкам. Возможно использовать минус для того чтобы отнять очки от навыка.");
							chatmsg.Add("--------------");	
							//chatmsg.Add("<color='#DD0000'>Доступные навыки</color>");
							foreach(KeyValuePair<string,StudySkill> kvp in StudySkills) {
								chatmsg.Add("<color='#00DD00'>/me set "+kvp.Key+" число</color> - "+kvp.Value.Name+"\nОчков: <color='#00DD00'>"+
								(playerInfo.PlayerOptionsTmp.ContainsKey(kvp.Key)?playerInfo.PlayerOptionsTmp[kvp.Key].Points:0).ToString()+"</color>, макс очков: <color='#DD0000'>"+kvp.Value.Points+"</color>");
								var bonuses = new List<string>();
								//var perc = (float)kvp.Value.Points/playerInfo.PlayerOptions[kvp.Key].Points;
								
								foreach(KeyValuePair<string,StudySkillOpts> kvs in kvp.Value.Skills) {
									if (!playerInfo.PlayerOptionsTmp.ContainsKey(kvp.Key)) continue;
									var points = playerInfo.PlayerOptionsTmp[kvp.Key].Points;
									if (points>0) {
										var calc = 0f;
										if (kvp.Value.Points>1f) calc = (float)Math.Round(points*(((float)kvs.Value.Mul-1)/kvp.Value.Points)*100,2);
										else calc = (float)Math.Round(points*((float)kvs.Value.Mul/kvp.Value.Points)*100,2);
										if (calc<0f) calc *= -1;
									
										bonuses.Add(((string)kvs.Value.Desc!=""?(string)kvs.Value.Desc + " ":"") + "<color='#00DD00'>" + (string)kvs.Value.MulTxt + calc.ToString() + "%</color>");
									}
								}
								
								if (bonuses.Count>0) chatmsg.Add("<color='#ffb400'>Бонусы:</color> " + string.Join(", ", bonuses.ToArray()));	
							}
							chatmsg.Add("--------------");	
							chatmsg.Add("<color='#00DD00'>/me reset</color> - заново сбросить навыки.");
							chatmsg.Add("<color='#00DD00'>/me finish</color> - закончить режим настройки и сохранить навыки.");
						}
					} else chatmsg.Add("<color='#DD0000'>Данная команда доступна только во время перенастройки навыков.</color>");
					break;
					case "reset":
					var reset = false;
					if (playerInfo.Reset) {
						reset = true;
					} else if (playerInfo.Info.Level>=50&&playerInfo.ResetLast+604800<CurrentTime()) {
						if (args.Length>1) {
							var arg = args[1].ToLower();
							if (arg=="yes") {
								reset = true;
							} else {
								chatmsg.Add("Неверный параметр.");
							}
						} else {
							chatmsg.Add("<color='#DD0000'>Подверждение сброса навыков</color>");
							chatmsg.Add("<color='#ffb400'>Данное действие сбросит все ваши навыки игрока, и вы сможете перенастроить их как вы пожелаете."+
							" Данное действие возможно использовать только <color='#DD0000'>раз в неделю</color> и невозможно отменить.</color>");
							chatmsg.Add("<color='#ffb400'>Напишите <color='#00DD00'>/me reset yes</color> для подверждения.</color>");
						}		
					} else if (playerInfo.Info.Level<50) {
						chatmsg.Add("Вы ещё не достигли <color='#DD0000'>50 уровня</color> игрока для доступа к данной команде.");			
					} else {
						chatmsg.Add("На данный момент вы не можете сбросить навыки.\nСледующис сброс будет доступен через <color='#DD0000'>"+CalcTime(playerInfo.ResetLast+604800-CurrentTime())+"</color>.");						
					}
					if (reset) {
						//playerInfo.ResetLast = CurrentTime();
						//playerInfo.Points = 0;
						var tbl = playerInfo.PlayerOptions;
						if (playerInfo.Reset) tbl = playerInfo.PlayerOptionsTmp;
						foreach(KeyValuePair<string,PlayerOptions> kvp in tbl) {
							playerInfo.Points += kvp.Value.Points;
							kvp.Value.Points = 0;
							//playerTmp.PlayerOptions[kvp.Key] = new PlayerOptions(kvp.Value.Name);
						}
						playerInfo.Reset = true;
						chatmsg.Add("<color='#00DD00'>Навыки успешно сброшены.</color>");
						chatmsg.Add("Используйте команду <color='#00DD00'>/me set</color> для их настройки.");
					}
					break;
					case "msg":
					
						if (args.Length>1) {
							//var arg = args[1].ToLower();
							switch (args[1].ToLower())
							{
								case "all":
									chatmsg.Add("<color='#ffb400'>Все сообщения успешно <color='#00DD00'>включены</color>.</color>");
									playerInfo.MsgMode = 0;
								break;
								case "new":
									chatmsg.Add("<color='#ffb400'>Сообщения о прогрессе теперь будут отображаться только при получении <color='#00DD00'>нового уровня</color>.</color>");
									playerInfo.MsgMode = 1;
								break;
								case "off":
									chatmsg.Add("<color='#ffb400'>Сообщения о прогрессе полностью <color='#00DD00'>отключены</color>.</color>");
									playerInfo.MsgMode = 2;
								break;
								default:
									chatmsg.Add("Неверный параметр.");
								break;
							}
						} else {
							chatmsg.Add("<color='#DD0000'>Описание команды</color>");
							chatmsg.Add("<color='#ffb400'>Данная команда позволяет настроить отображения сообщений о прогрессе обучения.</color>");
							var mode = "Все сообщения";
							if (playerInfo.MsgMode==1) mode = "Только новый уровень";
							else if (playerInfo.MsgMode==2) mode = "Выключено";
							chatmsg.Add("<color='#ffb400'>Текущий режим:</color> <color=#00DD00>"+mode+"</color>"); 
							chatmsg.Add("--------------");
							chatmsg.Add("<color='#DD0000'>Доступные команды</color>");
							chatmsg.Add("<color='#00DD00'>/me msg all</color> - включить все сообщения");
							chatmsg.Add("<color='#00DD00'>/me msg new</color> - только при получении нового уровня");
							chatmsg.Add("<color='#00DD00'>/me msg off</color> - полностью выключить");
						}
					break;
					default:
					def = true;
					break;
				}
			} 
			if (def) {
			
				var isvip = PluginInstance.IsVIP(player);
			
				chatmsg.Add("--------------");	
				chatmsg.Add(player.displayName);	
				var lvl = playerInfo.Info.Level;
				var perc = -1m;
				if (lvl<=PlayerLvlTable.Count) perc = (decimal)Math.Round((decimal)playerInfo.Info.XP/(decimal)PlayerLvlTable[lvl]*100,2);
				if (perc>99.99m) { perc = 99.99m; }
				chatmsg.Add("Уровень: " + lvl + (!bonus&&perc>=0m? " ("+perc+"%)" : ""));
				chatmsg.Add("--------------");
				
				if (bonus) {
					if (isvip) {
						chatmsg.Add("<color='#DD0000'>Бонусы от VIP аккаунта:</color>");
						chatmsg.Add("<color='#00DD00'>+50%</color> к скорости прокачки");
						chatmsg.Add("<color='#00DD00'>+25%</color> к добыче ресурсов");
						chatmsg.Add("--------------");
					}
					var clanbonus = PluginInstance.GetClanBonuses(player);
					if (clanbonus!="") {
						if (isvip) {
							ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
							chatmsg.Clear();
						}
						chatmsg.Add(clanbonus);
						ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
						chatmsg.Clear();
					}
				}
				chatmsg.Add("<color='#DD0000'>Ваши навыки</color>"+(!bonus?" [ очки ]":""));
				if (playerInfo.Reset) {
					chatmsg.Add("<color='#ffb400'>Включён режим перенастройки навыков.</color>");
					chatmsg.Add("<color='#ffb400'>Используйте команду <color='#00DD00'>/me set</color> для их настройки.</color>");
					chatmsg.Add("<color='#ffb400'>Сейчас навыки <color='#DD0000'>не действуют</color>.</color>");
				} else if (playerInfo.PlayerOptions.Count>0) {
					foreach(KeyValuePair<string,StudySkill> kvp in StudySkills) {
						/*playerInfo.PlayerOptions[kvp.Key] = new PlayerOptions(kvp.Value.Name);
						playerInfo.PlayerOptions[kvp.Key].Points = kvp.Value.Points;*/
						if (playerInfo.PlayerOptions.ContainsKey(kvp.Key)&&playerInfo.PlayerOptions[kvp.Key].Points>0) {
							if (bonus) {
								var bonuses = new List<string>();
								//var perc = (float)kvp.Value.Points/playerInfo.PlayerOptions[kvp.Key].Points;
								
								foreach(KeyValuePair<string,StudySkillOpts> kvs in kvp.Value.Skills) {
									var points = playerInfo.PlayerOptions[kvp.Key].Points;
									var calc = 0f;
									if (kvp.Value.Points>1f) calc = (float)Math.Round(points*(((float)kvs.Value.Mul-1)/kvp.Value.Points)*100,2);
									else calc = (float)Math.Round(points*((float)kvs.Value.Mul/kvp.Value.Points)*100,2);
									if (calc<0f) calc *= -1;
								
									bonuses.Add(((string)kvs.Value.Desc!=""?(string)kvs.Value.Desc + " ":"") + "<color='#00DD00'>" + (string)kvs.Value.MulTxt + calc.ToString() + "%</color>");
								}
								
								chatmsg.Add("<color='#ffb400'>" + kvp.Value.Name + ":</color> " + string.Join(", ", bonuses.ToArray()));								
							} else {
								var spaces = kvp.Value.Spaces; // new String('\t', spaces) +
								chatmsg.Add("<color='#ffb400'>" + kvp.Value.Name + ":</color> <color='#00DD00'>" + playerInfo.PlayerOptions[kvp.Key].Points.ToString() + "/" + kvp.Value.Points.ToString() + "</color>");
							}							
						}
					}				
				} else {
					chatmsg.Add("У вас ещё не изучены навыки.");
				}
				chatmsg.Add("--------------");
				ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
				chatmsg.Clear();
				chatmsg.Add("<color='#DD0000'>Ваши мастерства</color>"+(!bonus?" [ уровень ]":""));
				if (bonus&&StartGatherX>1f) chatmsg.Add("Начальная скорость добычи на сервере: <color='#DD0000'>x"+StartGatherX+"</color>");
				chatmsg.Add("--------------");
				if (playerInfo.PlayerSkills.Count>0) {
					//var count = StudyProfs.Count.ToString();
					foreach(KeyValuePair<string,StudyProf> kvp in StudyProfs) {	
						/*playerInfo.PlayerSkills[kvp.Key] = new PlayerSkill(kvp.Value.Name[0]);
						playerInfo.PlayerSkills[kvp.Key].Info.Level = 50;*/
						if (playerInfo.PlayerSkills.ContainsKey(kvp.Key)) { //&&playerInfo.PlayerSkills[kvp.Key].Info.Level>0) 
							var playerSkill = playerInfo.PlayerSkills[kvp.Key];
							if (bonus) {
								var bonuses = new List<string>();
								var level = playerInfo.PlayerSkills[kvp.Key].Info.Level;
								var clangather = PluginInstance.GetClanBonus(SteamId(player),"gather");

								foreach(KeyValuePair<string,StudySkillOpts> kvs in kvp.Value.Skills) {
									var act = "";
									if (kvs.Value.MulTxt=="x") {
										var vip = (isvip?1.25f:1f);
										if (clangather>0f) vip += clangather;
										act = "x"+((float)Math.Round((StartGatherX+((StartGatherX*kvs.Value.Mul-StartGatherX)/SkillLvlTable.Count*level))*vip,2)).ToString();
										//act = "+"+((float)Math.Round((kvp.Value.Mul*100f-100)/SkillLvlTable.Count*level,2)).ToString()+"%";
									} else if (kvs.Value.MulTxt=="+") {
										act = kvs.Value.MulTxt+((float)Math.Round(((float)kvs.Value.Mul-1)/SkillLvlTable.Count*level*100,2)).ToString()+"%";
									} else {
										act = ((float)Math.Round(((float)kvs.Value.Mul-1)/SkillLvlTable.Count*level*100,2)).ToString()+"%";
									}
								
									bonuses.Add((string)kvs.Value.Desc + " <color='#00DD00'>" + act + "</color>");
								}
								
								//bonuses.Add((string)kvp.Value.Skills[2] + " <color='#00DD00'>+" + ((float)Math.Round(kvp.Value.Mul*perc,2)).ToString() + "%</color>");
								
								chatmsg.Add("<color='#ffb400'>" + kvp.Value.Name[1] + ":</color> " + string.Join(", ", bonuses.ToArray()));	
							} else {
								var add = "";
								if (playerSkill.Info.Level<SkillLvlTable.Count) {
									var calc = (decimal)Math.Round((decimal)playerSkill.Info.XP/(decimal)SkillLvlTable[playerSkill.Info.Level+1]*100,2);
									if (calc>99.99m) { calc = 99.99m; }
									add = " (" + calc.ToString() + "%)";
								}
								chatmsg.Add("<color='#ffb400'>" + kvp.Value.Name[1] + ":</color> <color='#00DD00'>" + playerInfo.PlayerSkills[kvp.Key].Info.Level.ToString() + "/" + SkillLvlTable.Count.ToString() + "</color>" + add);
							}
						}
					}				
				} else {
					chatmsg.Add("У вас ещё не изучены мастерства.");
				}
				chatmsg.Add("--------------");
				ChatMessage(player,string.Join("\n", chatmsg.ToArray()));
				chatmsg.Clear();
				chatmsg.Add("<color='#DD0000'>Дополнительные команды:</color>");
				if (bonus) chatmsg.Add("<color='#00DD00'>/me</color> - уровень навыков и мастерства");
				chatmsg.Add("<color='#00DD00'>/me items</color> - уровень владения предметами");
				if (!bonus) chatmsg.Add("<color='#00DD00'>/me bonus</color> - бонусы которые дают навыки/мастерства");
				if (playerInfo.Info.Level>=50) chatmsg.Add("<color='#00DD00'>/me reset</color> - сбросить ваши навыки");
				chatmsg.Add("<color='#00DD00'>/me msg</color> - вкл/выкл сообщений о прогрессе обучения");
				chatmsg.Add("<color='#00DD00'>/me menu</color> - <color=#DD0000>тестовое</color> меню с информацией о игроке");
				chatmsg.Add("<color='#00DD00'>/skill about</color> - узнать подробнее о навыках и мастерствах");
				if (playerInfo.PlayerSkills.ContainsKey("Build")&&playerInfo.PlayerSkills["Build"].Info.Level>20)
				chatmsg.Add("<color='#00DD00'>/up</color> - автоматическое обновление постройки до дерева/камня");
			}
			
			return string.Join("\n", chatmsg.ToArray());
		}
	
		public string ChatUp(BasePlayer player, string command, string[] args) {
			var chatmsg = new List<string>();
			var def = true;
			var playerInfo = PlayerInfo(player);
			var playerTmp = PlayerTmp(player);
			var buildlvl = 0;
			if (playerInfo.PlayerSkills.ContainsKey("Build")) {
				buildlvl = playerInfo.PlayerSkills["Build"].Info.Level;
			}
			if (buildlvl<20) {
				chatmsg.Add("Извините, на данный момент вы не можете использовать данную команду. Необходим <color='#FF0000'>20 уровень</color> мастерства строителя. Текущий уровень: <color='#00DD00'>"+buildlvl+"</color>");
			} else {
				if (args.Length>0) {
					def = false;
					var arg = args[0].ToLower();
					if (arg=="1"||arg=="wood") {
						chatmsg.Add("<color='#00DD00'>Автоматическое обновление до дерева успешно включено.</color>");
						playerTmp.BuildGrade = 1;
					} else if (arg=="2"||arg=="stone") {
						if (buildlvl>=35) {
							chatmsg.Add("<color='#00DD00'>Автоматическое обновление до камня успешно включено.</color>");
							playerTmp.BuildGrade = 2;
						} else chatmsg.Add("Извините, но вы ещё не достигли <color='#FF0000'>35 уровня</color> мастерства строителя для доступа к данной команде.");
					} else if (arg=="0"||arg=="off") {
						chatmsg.Add("<color='#00DD00'>Автоматическое обновление успешно выключено.</color>");
						playerTmp.BuildGrade = 0;
					} else {
						def = true;
					}
				}
				if (def) {
					chatmsg.Add("<color='#DD0000'>Описание команды:</color>");
					chatmsg.Add("<color='#ffb400'>С помощью данной команды вы можете автоматически обновлять конструкцию до дерева или камня во время строительства.");
					if (buildlvl<35) chatmsg.Add("Для обновления до камня необходим <color='#FF0000'>35 уровень</color> мастерства строителя. Текущий уровень: <color='#00DD00'>"+buildlvl+"</color>");
					chatmsg.Add("</color>--------------");
					chatmsg.Add("<color='#DD0000'>Доступные команды:</color>");
					chatmsg.Add("<color='#00DD00'>/up wood</color> или <color='#00DD00'>/up 1</color> - авто обновление до дерева");
					if (buildlvl>=35) chatmsg.Add("<color='#00DD00'>/up stone</color> или <color='#00DD00'>/up 2</color> - авто обновление до камня");
					chatmsg.Add("<color='#00DD00'>/up off</color> или <color='#00DD00'>/up 0</color> - выключить авто обновление");
					chatmsg.Add("--------------");
					var cur = "выключено";
					if (playerTmp.BuildGrade==1) cur = "авто, дерево";
					else if (playerTmp.BuildGrade==2) cur = "авто, камень";
					chatmsg.Add("<color='#DD0000'>Текущий режим:</color> "+cur);
				}
			}
			return string.Join("\n", chatmsg.ToArray());
		}
	
	}	
	
	public class CalcLvlRet
	{
		public string chatmsg { get; set; }
		public float amount { get; set; }
		public float cond { get; set; }
		public decimal XPPerc { get; set; }
		public bool IsUp { get; set; }
		public bool IsMax { get; set; }
		
		public CalcLvlRet(string ChatMSG, float Amount, float Cond, decimal xpperc, bool isup, bool ismax)
		{
			chatmsg = ChatMSG;
			amount = Amount;
			cond = Cond;
			XPPerc = xpperc;
			IsUp = isup;
			IsMax = ismax;
		}
	}
	
	public class StudyProf
	{
		public string[] Name { get; set; }
		public string ResourceName { get; set; }
		//public float Mul { get; set; }
		public float Div { get; set; }
		public Dictionary<string, StudySkillOpts> Skills { get; set; }
		
		public StudyProf(string[] name, string resourceName, float div, Dictionary<string, StudySkillOpts> skills)
		{
			Name = name;
			ResourceName = resourceName;
			//Mul = mul;
			Div = div;
			Skills = skills;
		}
	}
	
	public class StudySkill
	{
		public string Name { get; set; }
		public int Points { get; set; }
		public Dictionary<string, StudySkillOpts> Skills { get; set; }
		public int MinLvl { get; set; }
		public int Spaces { get; set; }
		
		public StudySkill(string name, int points, Dictionary<string, StudySkillOpts> skills, int spaces, int minLvl = 0)
		{
			Name = name;
			Points = points;
			Skills = skills;
			MinLvl = minLvl;
			Spaces = spaces;
		}
	}
	
	public class StudySkillOpts
	{
		public string Desc { get; set; }
		public float Mul { get; set; }
		public string MulTxt { get; set; }
		
		public StudySkillOpts(string desc, float mul, string multxt)
		{
			Desc = desc;
			Mul = mul;
			MulTxt = multxt;
		}
	}
	
	public class LvlInfo {
		public int Level { get; set; }
		public float XP { get; set; }
		
		public LvlInfo(int level, float xp) {
			Level = level;
			XP = xp;
		}
	}
	
	public class PlayerInfo
	{
		public string SteamName { get; set; }
		public LvlInfo Info { get; set; }
		public Dictionary<string,PlayerOptions> PlayerOptions { get; set; }
		public Dictionary<string,PlayerSkill> WeaponSkills { get; set; }
		public Dictionary<string,PlayerSkill> PlayerSkills { get; set; }
		public int Points { get; set; }
		public bool Reset { get; set; }
		public double ResetLast { get; set; }
		public Dictionary<string,PlayerOptions> PlayerOptionsTmp { get; set; }
		public int MsgMode { get; set; }
		public double LastVisit { get; set; }
	
		public PlayerInfo(string steamName)
		{
			SteamName = steamName;
			Info = new LvlInfo(1,0f);
			Points = 0;
			Reset = false;
			ResetLast = 0;
			PlayerOptions = new Dictionary<string, PlayerOptions>();
			WeaponSkills = new Dictionary<string, PlayerSkill>();
			PlayerSkills = new Dictionary<string, PlayerSkill>();
			PlayerOptionsTmp = new Dictionary<string, PlayerOptions>();
			MsgMode = 0;
			LastVisit = Study.CurrentTime();
		}
	}
	
	public class PlayerOptions
	{
		public string Name { get; set; }
		public int Points { get; set; }
		
		public PlayerOptions(string name)
		{
			Name = name;
			Points = 0;
		}
	}
	
	public class PlayerSkill
	{
		public string Name { get; set; }
		public LvlInfo Info { get; set; }
		
		public PlayerSkill(string name)
		{
			Name = name;
			Info = new LvlInfo(0,0f);
		}
	}
	
	public class PlayerTmp
	{
		public float Last { get; set; }
		public decimal LastPerc { get; set; }
		public float LastWTime { get; set; }
		public int BuildGrade { get; set; }
		public Dictionary<string,WeaponTmp> WeaponTmp { get; set; }
		public Dictionary<string,bool> ProfTmp { get; set; }
		public Dictionary<string,bool> WeapTmp { get; set; }
		//public Dictionary<string,object> Cache { get; set; }
	
		public PlayerTmp()
		{
			Last = 0f;
			LastPerc = 0;
			BuildGrade = 0;
			ProfTmp = new Dictionary<string, bool>();
			WeaponTmp = new Dictionary<string, WeaponTmp>();
			WeapTmp = new Dictionary<string, bool>();
			//Cache = new Dictionary<string, object>();
		}
	}
	
	public class WeaponTmp
	{
		public float Last { get; set; }
		public decimal LastPerc { get; set; }
		public decimal LastSkillPerc { get; set; }
		public float LastWTime { get; set; }
		public float LastGTime { get; set; }
		public bool LastLvl { get; set; }
		
		public WeaponTmp()
		{
			Last = 0f;
			LastPerc = 0;
			LastSkillPerc = 0;
			LastWTime = 0f;
			LastGTime = 0f;
			LastLvl = false;
		}
	}
	
    public class ItemInfo
    {
        public int ItemId { get; set; }
        public string Shortname { get; set; }
        public float BlueprintTime { get; set; }
        //public bool CanResearch { get; set; }
        public string ItemCategory { get; set; }
    }
	
}
