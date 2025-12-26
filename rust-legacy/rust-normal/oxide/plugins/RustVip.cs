/*

This plugin used with VIP system based on php-fusion custom plugin
Allowed to buy VIP account on website and get bonuses 
Also had free vip (promo) activated for limited time, can have less features
Used on Botov-NET rust servers

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

// Reference: Oxide.Ext.Rust
// Reference: Newtonsoft.Json
using System.Collections.Generic;
using System.Linq;
using Oxide.Core;
using Oxide.Ext.MySql;
using Oxide.Ext.MySql.Libraries;
using Oxide.Core.Libraries;
using Oxide.Core.Plugins;
using Oxide.Core.Configuration;
using Oxide.Plugins;
using UnityEngine;
using System;
using Newtonsoft.Json;
using System.Text.RegularExpressions;

/*
Rust VIP System
By AlexALX (c) 2015
*/

namespace Oxide.Plugins
{
    [Info("VIP System", "AlexALX", "0.0.1")]
    public class RustVip : RustPlugin
    {
	
		[PluginReference] Plugin ZoneManager;
	
		private const string DataFileName = "VipData";
		private DynamicConfigFile VipDataFile;
		
		private const string DB_VIPS = "fusion_game_vip";
		private const string DB_SETTINGS = "fusion_game_vip_set";
		private Connection db;
		private Ext.MySql.Libraries.MySql mysql = Interface.Oxide.GetLibrary<Ext.MySql.Libraries.MySql>("MySql");
		private WebRequests webrequests = Interface.Oxide.GetLibrary<WebRequests>("WebRequests");
	
		private bool vip_enabled = false;
		private bool amx_free_vip = false;
		private int amx_free_vipt = 0;
		private const float DELAY_CHECK_VIP = 300f;
		private int server = 0;
		
		private Dictionary<string, PlayerVIP> PlayerConfig = new Dictionary<string, PlayerVIP>();
		private Dictionary<string, VIPInfo> VipConfig = new Dictionary<string, VIPInfo>();
		private DateTime epoch = new System.DateTime(1970, 1, 1);
		
		private Dictionary<string, Oxide.Plugins.Timer> CheckTimer = new Dictionary<string, Oxide.Plugins.Timer>();
		
		private const string URL_PREFIX = "http://botov.net.ua/";
		private Dictionary<string, Dictionary<string, string>> MESSAGES = new Dictionary<string, Dictionary<string, string>>(){
			["ru"] = new Dictionary<string, string>(){
				["YOU_VIP"] = "Ваш VIP активен до:",
				["YOU_VIPFREE"] = "Вы имеете бесплатный VIP аккаунт до:",
				["YOU_VIP2"] = "Напишите <color=#00DD00>/viphelp</color> чтобы узнать команды для випов.",
				["YOU_NVIP"] = "Вы не VIP!",
				["YOU_NVIP2"] = "Напишите <color=#00DD00>/vipinfo</color> для более подробной информации.",
				["YOU_BVIP"] = "Ваш VIP аккаунт заблокирован!",
				["YOU_FVIP"] = "Ваш VIP аккаунт заморожен!",
				["YOU_EVIP"] = "Вы уже не VIP! Дата окончания VIP'а:",
				["YOU_DVIP"] = "VIP система отключена!",
				["VIP_UNL"] = "неограничено",
				["VIPS"] = "VIP'ы онлайн",
				["VIPS_NO"] = "Нет онлайн VIP'ов.",
				["ERROR"] = "Системная ошибка, попробуйте позже."
			},
			["en"] = new Dictionary<string, string>(){
				["YOU_VIP"] = "You VIP are active to:",
				["YOU_VIPFREE"] = "You FREE VIP are active to:",
				["YOU_NVIP"] = "You are not VIP!",
				["YOU_NVIP2"] = "Type <color=#00DD00>!vipinfo</color> for view more information. (only for russian!)",
				["YOU_BVIP"] = "Your VIP account is blocked!",
				["YOU_FVIP"] = "Your VIP account is unactive!",
				["YOU_EVIP"] = "You are not VIP! End Date:",
				["VIP_UNL"] = "unlimined",
				["VIPS"] = "VIPs online",
				["VIPS_NO"] = "No vips online."
			}
		};
		private const string lang = "ru";
		
		private Dictionary<string,List<List<RndItem>>> RandomKit = new Dictionary<string,List<List<RndItem>>>(){
			["weapon"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="rifle_ak",container="belt",cond=true},new RndItem(){name="ammo_rifle",amount=64}},
				new List<RndItem>(){new RndItem(){name="rifle_bolt",container="belt",cond=true},new RndItem(){name="ammo_rifle",amount=40}},
				new List<RndItem>(){new RndItem(){name="smg_thompson",container="belt",cond=true},new RndItem(){name="ammo_pistol",amount=64}},
				new List<RndItem>(){new RndItem(){name="shotgun_pump",container="belt",cond=true},new RndItem(){name="ammo_shotgun",amount=36}},
			},
			["weapon_misc"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="pistol_revolver",container="belt",cond=true},new RndItem(){name="ammo_pistol",amount=18}},
				new List<RndItem>(){new RndItem(){name="smg_2",container="belt",cond=true},new RndItem(){name="ammo_pistol",amount=48}},
				new List<RndItem>(){new RndItem(){name="grenade.f1",container="belt",amount=1,max=3}},
				new List<RndItem>(){new RndItem(){name="grenade.beancan",container="belt",amount=1,max=5}}
			},
			["tool"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="axe_salvaged",container="belt"}},
				new List<RndItem>(){new RndItem(){name="hatchet",container="belt"}},
				new List<RndItem>(){new RndItem(){name="spear_stone",container="belt"}},
			},
			["tool2"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="icepick_salvaged",container="belt"}},
				new List<RndItem>(){new RndItem(){name="pickaxe",container="belt"}}
			},
			/*["wear"] = new List<List<RndItem>>{
				new List<RndItem>(){
					new RndItem(){name="urban_pants",container="wear"},new RndItem(){name="urban_boots",container="wear"},
					new RndItem(){name="longsleeve_tshirt_blue",container="wear"},new RndItem(){name="burlap_gloves",container="wear"}
				},
				new List<RndItem>(){
					new RndItem(){name="urban_pants",container="wear"},new RndItem(){name="urban_boots",container="wear"},
					new RndItem(){name="urban_shirt",container="wear"},new RndItem(){name="vagabond_jacket",container="wear"}
				},
				new List<RndItem>(){
					new RndItem(){name="urban_pants",container="wear"},new RndItem(){name="urban_boots",container="wear"},
					new RndItem(){name="jacket_snow2",container="wear"},new RndItem(){name="metal_facemask",container="wear"}
				},
				new List<RndItem>(){
					new RndItem(){name="urban_pants",container="wear"},new RndItem(){name="urban_boots",container="wear"},
					new RndItem(){name="urban_jacket",container="wear"},new RndItem(){name="coffeecan_helmet",container="wear"}
				},
				new List<RndItem>(){
					new RndItem(){name="urban_pants",container="wear"},new RndItem(){name="urban_boots",container="wear"},
					new RndItem(){name="burlap_shirt",container="wear"},new RndItem(){name="burlap_gloves",container="wear"},new RndItem(){name="burlap_headwrap",container="wear"}
				}
			},	*/
			["wear_top"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="metal_facemask",container="wear",amount=0,max=1}},
				new List<RndItem>(){new RndItem(){name="bucket_helmet",container="wear",amount=0,max=1}},
				new List<RndItem>(){new RndItem(){name="coffeecan_helmet",container="wear",amount=0,max=1}},
				new List<RndItem>(){new RndItem(){name="burlap_headwrap",container="wear",amount=0,max=1}},
				new List<RndItem>(){new RndItem(){name="hat.candle",container="wear",amount=0,max=1}}
			},
			["wear_main"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="urban_shirt",container="wear"},new RndItem(){name="vagabond_jacket",container="wear",amount=0,max=1}},
				new List<RndItem>(){new RndItem(){name="urban_jacket",container="wear"},new RndItem(){name="vagabond_jacket",container="wear",amount=0,max=1}},
				new List<RndItem>(){new RndItem(){name="jacket_snow",container="wear"}},
				new List<RndItem>(){new RndItem(){name="jacket_snow2",container="wear"}},
				new List<RndItem>(){new RndItem(){name="jacket_snow3",container="wear"}},
				new List<RndItem>(){new RndItem(){name="longsleeve_tshirt_blue",container="wear"},new RndItem(){name="vagabond_jacket",container="wear",amount=0,max=1}}
			},
			["wear_under"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="urban_pants",container="wear"},new RndItem(){name="urban_boots",container="wear"}},
				//new List<RndItem>(){new RndItem(){name="hazmat_pants",container="wear"},new RndItem(){name="hazmat_boots",container="wear"}}
			},
			["wear_misc"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="burlap_gloves",container="wear",amount=0,max=1}}
			},
			["food"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="wolfmeat_cooked",amount=10,max=20}},
				new List<RndItem>(){new RndItem(){name="humanmeat_cooked",amount=10,max=20}},
				new List<RndItem>(){new RndItem(){name="chicken_cooked",amount=10,max=20}}
			},	
			["food2"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="apple",amount=10,max=20}},
				new List<RndItem>(){new RndItem(){name="blueberries",amount=10,max=20}},
				new List<RndItem>(){new RndItem(){name="black raspberries",amount=10,max=20}}
			},	
			["medic"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="bandage",amount=1,max=2}},
				new List<RndItem>(){new RndItem(){name="syringe_medical",amount=1,max=2}}
			},	
			["medic2"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="largemedkit",amount=1,max=2}},
				new List<RndItem>(){new RndItem(){name="antiradpills",amount=0,max=5}}
			},	
			["res"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="metal_ore",amount=1000,max=3000}},
				new List<RndItem>(){new RndItem(){name="sulfur_ore",amount=1000,max=3000}},
				new List<RndItem>(){new RndItem(){name="wood",amount=1500,max=4000}},
				new List<RndItem>(){new RndItem(){name="stones",amount=1500,max=3000}}
			},
			["resc"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="metal_fragments",amount=300,max=1200}},
				new List<RndItem>(){new RndItem(){name="sulfur",amount=200,max=1200}},
				new List<RndItem>(){new RndItem(){name="gunpowder",amount=100,max=500}}
			},
			["air"] = new List<List<RndItem>>{
				new List<RndItem>(){new RndItem(){name="supply_signal",container="belt"}}
			}
		};
		private int MaxSlots = 0;
		private List<RndItem> VipSpawn = new List<RndItem>(){
			new RndItem(){name="attire.hide.pants",container="wear"},
			new RndItem(){name="attire.hide.vest",container="wear"},
			//new RndItem(){name="attire.hide.boots",container="wear"},
			//new RndItem(){name="attire.hide.poncho",container="wear"}
		};
		private static float CondMin = 0.6f;
		private static float CondMax = 1f;
		
		private bool DEBUG = false;
		
		public RustVip() {
			//HasConfig = true;
		}
		
		public bool IsInArena(BasePlayer player) {
			return (bool)(ZoneManager?.Call("isPlayerInZone", "Deathmatch", player) ?? false);
		}
		
		private List<Dictionary<string, object>> Query(string sqlquery) {
			Sql sql = mysql.NewSql();
			sql.Append(sqlquery);
			var query = mysql.Query(sql,db);
			Dictionary<string, object> entry;
			List<Dictionary<string, object>> result = new List<Dictionary<string, object>>();
			foreach (Dictionary<string, object> obj in query)
            {
                List<string> tableKeys = obj.Select(x => x.Key).ToList<string>();
                List<object> tableVals = obj.Select(x => x.Value).ToList<object>();
 
                entry = new Dictionary<string, object>();
 
                foreach (string key in tableKeys)
                    entry.Add(key, tableVals[tableKeys.IndexOf(key)]);
 
                result.Add(entry);
            }
			return result;
		}
		
        protected override void LoadDefaultConfig()
        {
            DefaultConfig();
        }

		private void DefaultConfig() {
			Config["server"] = 0; 
			Config["items"] = RandomKit;
			Config["spawn"] = VipSpawn;
			SaveConfig();
		}
	
        public T ReadFromConfig<T>(string configKey)
        {
            string serializeObject = JsonConvert.SerializeObject(Config[configKey]);
            return JsonConvert.DeserializeObject<T>(serializeObject);
        }
		
        public T ReadFromData<T>(string dataKey)
        {
            string serializeObject = JsonConvert.SerializeObject(VipDataFile[dataKey]);
            return JsonConvert.DeserializeObject<T>(serializeObject);
        }
		
	    [HookMethod("Init")]
        void Init() {
			VipLoad();
		}
		
        private void VipLoad() {
			var serverCFG = ReadFromConfig<int>("server");
			if (serverCFG!=null&&serverCFG>0) server = serverCFG;
			var cfg = ReadFromConfig<Dictionary<string,List<List<RndItem>>>>("items");
			if (!DEBUG && cfg!=null) RandomKit = cfg;
			var cfgs = ReadFromConfig<List<RndItem>>("spawn");
			if (!DEBUG && cfgs!=null) VipSpawn = cfgs;
			
			var count =0;			
			foreach(KeyValuePair<string,List<List<RndItem>>> kvp in RandomKit) {
				var tcount = 0;
				foreach(List<RndItem> kvi in kvp.Value) {
					if (kvi.Count>tcount) tcount = kvi.Count;
				}
				if (tcount>0) count += tcount;
			}
			if (count>0) MaxSlots = count;
			
			db = mysql.OpenDb("localhost", 3306, "dbname", "dbuser", "dbpass");
			SQL_Settings();
			VipDataFile = Interface.GetMod().DataFileSystem.GetDatafile(DataFileName);
			//VipDataFile["Vips"] = new Dictionary<string, VIPInfo>();
			var Vips = ReadFromData<Dictionary<string, VIPInfo>>("Vips");
			if (Vips!=null) VipConfig = Vips;
        }
		
		private void SaveData() {
			VipDataFile["Vips"] = VipConfig;
			Interface.GetMod().DataFileSystem.SaveDatafile(DataFileName);
		}
		
		private void SQL_Settings() {
			var settings = Query("SELECT * FROM "+DB_SETTINGS).First();
			if (settings==null||settings.Count==0) return;
			var enabled = Convert.ToInt32(settings["enabled"]);
			var servers = (string)settings["servers"];
			var free_vip = Convert.ToInt32(settings["free_vip"]);
			var free_vipt = Convert.ToInt32(settings["free_vipt"]);

			if (enabled==0 || server==0) {
				vip_enabled = false;
			} else {
				vip_enabled = true;
				if (free_vip==1 && free_vipt>0 && servers.Contains("."+server+".")) {
					amx_free_vip = true;
					amx_free_vipt = free_vipt;
				}
			}
			
			var itPlayerList = BasePlayer.activePlayerList.GetEnumerator();

			while (itPlayerList.MoveNext()) {
				check_ini(itPlayerList.Current);
			}
		}
		
        private string SteamId(BasePlayer player)
        {
            return player.userID.ToString();
        }
		
        private PlayerVIP PlayerVIPInfo(BasePlayer player, bool reset = false)
        {
			string steamId = SteamId(player);
            if (!reset && PlayerConfig.ContainsKey(steamId)) return PlayerConfig[steamId];
            PlayerConfig[steamId] = new PlayerVIP();
            return PlayerConfig[steamId];
        }
		
        private VIPInfo PlayerVIPData(BasePlayer player)
        {
			string steamId = SteamId(player);
            if (VipConfig.ContainsKey(steamId)) return VipConfig[steamId];
            VipConfig[steamId] = new VIPInfo();
            return VipConfig[steamId];
        }
		
        private int CurrentTime()
        {
            return (int)Math.Ceiling(System.DateTime.UtcNow.Subtract(epoch).TotalSeconds);
        }
		
		private static DateTime UnixTimeStampToDateTime( int unixTimeStamp )
		{
			System.DateTime dtDateTime = new DateTime(1970,1,1,0,0,0,0,System.DateTimeKind.Utc);
			dtDateTime = dtDateTime.AddSeconds( unixTimeStamp ).ToLocalTime();
			return dtDateTime;
		}
		
		private void check_inis(BasePlayer ply) {
			check_ini(ply,true);
		}
		
		private void check_inif(PlayerVIP playerInfo) {
			if (CurrentTime() <= amx_free_vipt) {
				playerInfo.p_VIP = true;
				playerInfo.t_VIP = amx_free_vipt;
				playerInfo.f_VIP = "ctu";
				playerInfo.o_VIP = "z";
				playerInfo.s_VIP = 1;
			}
		}
		
		private void check_ini(BasePlayer ply, bool nomsg = false) {
			if (vip_enabled!=true) return;
			
			if (ply.net.connection==null) return;
		
			var playerInfo = PlayerVIPInfo(ply,true);
			var steamid = SteamId(ply);
			
			var result = Query("SELECT vid,sid,time,flags,options,status FROM "+DB_VIPS+" WHERE (server='0' OR server='"+server+"') AND sid='"+SteamId(ply)+"'");
			
			if (result.Count==1) {
				var data = result.First();
			
				var name = ply.displayName;
				var ip = ply.net.connection.ipaddress;
			
				var status = Convert.ToInt32(data["status"]);
				var time = Convert.ToInt32(data["time"]);
			
				if (status==1) {
					if (time==0 || CurrentTime() <= time) {
						playerInfo.p_VIP = true;
						playerInfo.t_VIP = time;
						playerInfo.f_VIP = (string)data["flags"];
						playerInfo.o_VIP = (string)data["options"];
						playerInfo.s_VIP = status;
						if (!nomsg) {
							Puts("Login: \""+name+"<"+steamid+"><"+status.ToString()+">\" vip (flags \""+playerInfo.f_VIP+"\") (address \""+ip+"\")");
							ply.ConsoleMessage("* VIP Autorized");
						}
					} else {
						playerInfo.p_VIP = false;
						playerInfo.t_VIP = time;
						playerInfo.f_VIP = "z";
						playerInfo.o_VIP = "z";
						playerInfo.s_VIP = status;
						if (!nomsg) {
							Puts("Unactive login: \""+name+"<"+steamid+"><"+status.ToString()+">\" vip (flags \""+playerInfo.f_VIP+"\") (address \""+ip+"\")");
							ply.ConsoleMessage("* Warning: VIP Expired");
						}
					}
				} else {
					playerInfo.p_VIP = false;
					playerInfo.t_VIP = time;
					playerInfo.f_VIP = "z";
					playerInfo.o_VIP = "z";
					playerInfo.s_VIP = status;
					if (!nomsg) Puts("Unactive login: \""+name+"<"+steamid+"><"+status.ToString()+">\" vip (flags \""+playerInfo.f_VIP+"\") (address \""+ip+"\")");
				}
			}
		
			if (amx_free_vip==true && CurrentTime() <= amx_free_vipt && !playerInfo.p_VIP) check_inif(playerInfo);
			if (CheckTimer.ContainsKey(steamid)) {
				CheckTimer[steamid].Destroy();
				CheckTimer.Remove(steamid);
			}
			CheckTimer[steamid] = timer.Once(DELAY_CHECK_VIP,() => check_inis(ply));
		}

        [ConsoleCommand("rust_reloadvips")]
        void cmdReloadVips(ConsoleSystem.Arg arg) {
			if (!arg.CheckPermissions()) return;
			SQL_Settings();
			Puts("[C#] Reload vips comleted.");
		}
		
        [HookMethod("OnPlayerInit")]
        void OnPlayerInit(BasePlayer player)
        {
            check_ini(player);
        }
		
        [HookMethod("OnPlayerRespawned")]
        void OnPlayerRespawned(BasePlayer player)
        {
            if (IsVIP(player)) {
				if (IsInArena(player)) return;
				foreach(RndItem item in VipSpawn) {
					var inv = player.inventory.containerMain;
					if (item.container=="wear") inv = player.inventory.containerWear;
					else if (item.container=="belt") inv = player.inventory.containerBelt;
					GiveItem(player, item.name, item.amount, inv);
				}
			}
        }
		
        [HookMethod("OnPlayerDisconnected")]
        void OnPlayerDisconnected(BasePlayer player)
        {
			var steamid = SteamId(player);
			if (CheckTimer.ContainsKey(steamid)) {
				CheckTimer[steamid].Destroy();
				CheckTimer.Remove(steamid);
			}
        }
		
        [HookMethod("Unload")]
        void Unload()
        {
			foreach (KeyValuePair<string,Oxide.Plugins.Timer> kvp in CheckTimer) {
				kvp.Value.Destroy();
			}
			SaveData();
        }
		
        [HookMethod("OnServerSave")]
        void OnServerSave()
        {
            SaveData();
        }
		
		bool IsVIP(BasePlayer ply) {
			if (ply==null) return false;
			var playerInfo = PlayerVIPInfo(ply);
			if (playerInfo.p_VIP == true && !playerInfo.f_VIP.Contains("z")) return true;
			return false;
		}
		
		bool VIPHasFlag(BasePlayer ply, string flag, bool ignore = false) {
			if (ply==null) return false;
			var playerInfo = PlayerVIPInfo(ply);
			if ((IsVIP(ply) || ignore) && playerInfo.f_VIP.Contains(flag)) return true;
			return false;
		}
		
		bool VIPHasOption(BasePlayer ply, string opt) {
			if (ply==null) return false;
			var playerInfo = PlayerVIPInfo(ply);
			if (IsVIP(ply) && playerInfo.o_VIP.Contains(opt)) return true;
			return false;
		}
		
		object VIPGetData(BasePlayer ply, string type, bool ignore = false) {
			if (ply==null) return null;
			var playerInfo = PlayerVIPInfo(ply);
			if (IsVIP(ply)) {
				var data = PlayerVIPData(ply);
				var free = VIPHasFlag(ply,"u");
				if (type=="chat") {
					if (free) return false;
 					return data.Chat; 
				} else if (type=="color") {
					if (free) return "off";
					if (!ignore && !data.Chat) return "off";
					return data.Color; 
				} else if (type=="textcolor") {
					if (free) return "";
					if (!ignore && !data.Chat) return "";
					return data.TextColor; 
				} else if (type=="wear") {
					if (free) return true;
					return data.Wear; 
				}
			}
			return null;
		}

		void VIPSetData(BasePlayer ply, string type, object arg) {
			if (ply==null) return;
			var playerInfo = PlayerVIPInfo(ply);
			if (IsVIP(ply)) {
				var data = PlayerVIPData(ply);
				if (type=="color") {
					data.Color = (string)arg; 
				} else if (type=="textcolor") {
					data.TextColor = (string)arg; 
				} else if (type=="chat") {
					data.Chat = (bool)arg; 
				} else if (type=="wear") {
					data.Wear = (bool)arg; 
				}
			}
		}
		
		bool GiveVipKit(BasePlayer player) {
			if (!IsVIP(player)) return false;
			
			//player.inventory.Strip();
			//player.containerMain.Clear();
			
			//Puts(player.inventory.containerMain.itemList.Count.ToString());
			//Puts(player.inventory.containerMain.capacity.ToString());
			var cur = player.inventory.containerMain.itemList.Count+player.inventory.containerBelt.itemList.Count;
			var total = player.inventory.containerMain.capacity+player.inventory.containerBelt.capacity;
			
			if (cur+MaxSlots>total) return false;
			
			foreach(KeyValuePair<string,List<List<RndItem>>> kvp in RandomKit) {
				var rnd = (int)Math.Round(UnityEngine.Random.Range(0f,kvp.Value.Count-1f));
				var items = kvp.Value[rnd];
				foreach(RndItem item in items) {
					var inv = player.inventory.containerMain;
					if (item.container=="wear" && (bool)VIPGetData(player,"wear")) inv = player.inventory.containerWear;
					else if (item.container=="belt") inv = player.inventory.containerBelt;
					float amount = item.amount;
					var cond = 1f;
					if (item.max>0) amount = UnityEngine.Random.Range(amount,(float)item.max);
					if (item.cond) cond = UnityEngine.Random.Range(item.condmin,item.condmax);
					//Puts(amount.ToString()+" | "+item.name);
					if (amount>0.5f) GiveItem(player, item.name, (int)Math.Round(amount), inv, false, cond);
				}
			}
			return true;
		}
		
        private void ChatMessage(BasePlayer player, string message)
        {
            player.ChatMessage(message);
        }
		
        [ChatCommand("vip")]
        void cmdVip(BasePlayer player, string command, string[] args) {
			if (!vip_enabled) {
				ChatMessage(player,"<color=#DD0000>"+MESSAGES[lang]["YOU_DVIP"]+"</color>"); return;
			}
			
			var vip = IsVIP(player);
			var free = VIPHasFlag(player,"u");
			
			if (args.Length>0) {
				if (args[0]=="info") {
					cmdVipInfo(player,command,args);
				} else if (args[0]=="buy") {
					cmdVipInfo(player,command,new string[]{"cost"});
				} else if (args[0]=="help") {
					cmdVipHelp(player,command,args);
				} else if (args[0]=="color" && vip) {
					if (free) { ChatMessage(player,"<color=#DD0000>Бесплатный vip не имеет доступа к данной команде.</color>"); return; }
					if (args.Length==1) { ChatMessage(player,"<color=#DD0000>Вы не указали цвет.</color>"); return; }
					var color = Regex.Replace(args[1],"[^A-Za-z0-9#]","");
					if (color=="normal") color = "";
					else if (color=="off") color = "off";
					VIPSetData(player,"color",color);
					if (color=="") color = "lime";
					else if (color=="off") color = "#5af";
					ChatMessage(player,"<color="+color+">Цвет ника установлен.</color>");
				} else if (args[0]=="textcolor" && vip) {
					if (free) { ChatMessage(player,"<color=#DD0000>Бесплатный vip не имеет доступа к данной команде.</color>"); return; }
					if (args.Length==1) { ChatMessage(player,"<color=#DD0000>Вы не указали цвет.</color>"); return; }
					var color = Regex.Replace(args[1],"[^A-Za-z0-9#]","");
					if (color=="normal") color = "";
					VIPSetData(player,"textcolor",color);
					ChatMessage(player,"<color="+color+">Цвет сообщений установлен.</color>");
				} else if (args[0]=="chat" && vip) {
					if (free) { ChatMessage(player,"<color=#DD0000>Бесплатный vip не имеет доступа к данной команде.</color>"); return; }
					if (args.Length==1) { ChatMessage(player,"<color=#DD0000>Вы не указали действие.</color>"); return; }
					if (args[1]=="off") {
						VIPSetData(player,"chat",false);
						ChatMessage(player,"<color=#ffb400>Цветной чат <color=#DD0000>выключен</color>.</color>");
					} else if (args[1]=="on") {
						VIPSetData(player,"chat",true);
						ChatMessage(player,"<color=#ffb400>Цветной чат <color=#00DD00>включён</color>.</color>");
					} else {
						ChatMessage(player,"<color=#DD0000>Не верное действие.</color>");
					}
				} else if (args[0]=="wear" && vip) {
					if (free) { ChatMessage(player,"<color=#DD0000>Бесплатный vip не имеет доступа к данной команде.</color>"); return; }
					if (args.Length==1) { ChatMessage(player,"<color=#DD0000>Вы не указали действие.</color>"); return; }
					if (args[1]=="off") {
						VIPSetData(player,"wear",false);
						ChatMessage(player,"<color=#ffb400>Теперь одежда из набора будет выдаваться в <color=#DD0000>инвентарь</color>.</color>");
					} else if (args[1]=="on") {
						VIPSetData(player,"wear",true);
						ChatMessage(player,"<color=#ffb400>Теперь одежда из набора будет <color=#00DD00>надеваться</color> на игрока.</color>");
					} else {
						ChatMessage(player,"<color=#DD0000>Не верное действие.</color>");
					}
				} else {
					ChatMessage(player,"<color=#DD0000>Не верный параметр.</color>");
				}
				return;
			}
			
			var playerInfo = PlayerVIPInfo(player);
			var time = playerInfo.t_VIP;
			var status = playerInfo.s_VIP;

			var msg = "";
			if (vip) {
				msg = MESSAGES[lang]["YOU_VIP"];
				if (free) msg = MESSAGES[lang]["YOU_VIPFREE"];
				var date = UnixTimeStampToDateTime(time).ToString("d/MM/yyyy HH:mm:ss"); //os.date("%d/%m/%Y %H:%M:%S",time)
				if (time==0) date = MESSAGES[lang]["VIP_UNL"];
				msg = "<color=#00DD00>"+msg+"</color> "+date+"\n";
				var chat = (bool)VIPGetData(player,"chat");
				msg += "<color=#ffb400>Цветной чат:</color> "+(free?"<color=#CCC>недоступен</color>":(chat?"<color=#00DD00>включён</color>":"<color=#DD0000>выключен</color>"))+"\n";
				var wear = (bool)VIPGetData(player,"wear");
				msg += "<color=#ffb400>Режим выдачи одежды:</color> "+(wear?"<color=#00DD00>надеваеться</color>":"<color=#DD0000>в инвентарь</color>")+"\n";
				var color = (string)VIPGetData(player,"color",true);
				if (color=="") color = "<color=lime>lime (стандарт)</color>";
				else if (color=="off") color = "<color=#5af>синий (выключено)</color>";
				else color = "<color="+color+">"+color+"</color>";
				msg += "<color=#ffb400>Цвет вашего ника:</color> "+color+"\n";
				color = (string)VIPGetData(player,"textcolor",true);
				if (color=="") color = "белый (стандарт)";
				else color = "<color="+color+">"+color+"</color>";
				msg += "<color=#ffb400>Цвет вашего сообщения:</color> "+color;
			} else {
				if (status==1 && time!=0 && time!=-1) {
					var date = UnixTimeStampToDateTime(time).ToString("d/MM/yyyy HH:mm:ss"); //os.date("%d/%m/%Y %H:%M:%S",time)
					if (time==0) date = MESSAGES[lang]["VIP_UNL"];
					msg = "<color=#DD0000>"+MESSAGES[lang]["YOU_EVIP"]+"</color> "+date;
				} else if (status==0) {
					msg = "<color=#00DDDD>"+MESSAGES[lang]["YOU_FVIP"]+"</color>";
				} else if (status==2) {
					msg = "<color=#DD0000>"+MESSAGES[lang]["YOU_BVIP"]+"</color>";
				} else {
					msg = "<color=#DD0000>"+MESSAGES[lang]["YOU_NVIP"]+"</color>";
				}
			}
			
			msg += "\n\n<color=#DD0000>Доступные команды:</color>\n";
			msg += "<color=#00DD00>/vip info</color> - информация о вип аккаунтах\n";
			msg += "<color=#00DD00>/vip buy</color> - стоимость вип аккаунта\n";
			msg += "<color=#00DD00>/vip help</color> - команды для випов\n";
			msg += "<color=#00DD00>/vips</color> - список вип игроков";
			
			if (msg!="") ChatMessage(player,msg);
		}
		
        [ChatCommand("vips")]
        void cmdVips(BasePlayer player, string command, string[] args) {
			if (!vip_enabled) {
				ChatMessage(player,"<color=#DD0000>"+MESSAGES[lang]["YOU_DVIP"]+"</color>"); return;
			}
			
			var itPlayerList = BasePlayer.activePlayerList.GetEnumerator();

			var vips = "<color=#00DD00>"+MESSAGES[lang]["VIPS"]+"</color>\n";
			var i = 0;
			
			while (itPlayerList.MoveNext()) {
				var ply = itPlayerList.Current;
				if (IsVIP(ply)) {
					if (i!=0) vips += ", ";
					vips += ply.displayName;
					i += 1;
				}
			}
			
			if (i>0) ChatMessage(player,vips);
			else ChatMessage(player,vips+MESSAGES[lang]["VIPS_NO"]);
		}
		
        private void cmdVipInfo(BasePlayer player, string command, string[] args) {
			if (!vip_enabled) {
				ChatMessage(player,"<color=#DD0000>"+MESSAGES[lang]["YOU_DVIP"]+"</color>"); return;
			}
			
			var cost = "";
			if (args.Length>0&&args[0]=="cost") cost = "&cost";
			
			webrequests.EnqueueGet("http://localhost/infusions/personal/rust.php?server="+server.ToString()+cost, 
				(code, response) => ChatMessage(player, (code==200?response:"<color=#DD0000>"+MESSAGES[lang]["ERROR"]+"</color>")
			), this);
		}
		
        private void cmdVipHelp(BasePlayer player, string command, string[] args) {
			if (!vip_enabled) {
				ChatMessage(player,"<color=#DD0000>"+MESSAGES[lang]["YOU_DVIP"]+"</color>"); return;
			}
			
			webrequests.EnqueueGet("http://localhost/infusions/personal/rust.php?commands="+server.ToString(), 
				(code, response) => ChatMessage(player, (code==200?response:"<color=#DD0000>"+MESSAGES[lang]["ERROR"]+"</color>")
			), this);
		}
		
        private void GiveItem(BasePlayer player, string itemname, int amount, ItemContainer pref, bool isBP = false, float cond = 1f)
        {
            itemname = itemname.ToLower();
            if (amount < 1) amount = 1;
            var definition = ItemManager.FindItemDefinition(itemname);
			//Puts(definition.ToString());
            if (definition == null) return;
			var item = ItemManager.CreateByItemID((int)definition.itemid, amount, isBP);
			if (cond<1f) {
				item.condition *= cond;
			}
			player.inventory.GiveItem(item, pref);
        }
	
		
		private class PlayerVIP {
			public bool p_VIP { get; set; } = false;
			public int t_VIP { get; set; } = 0;
			public string f_VIP { get; set; } = "z";
			public string o_VIP { get; set; } = "z";
			public int s_VIP { get; set; } = -1;
		}
		
		private class VIPInfo {
			public string Color { get; set; } = "";
			public string TextColor { get; set; } = "";
			public bool Chat { get; set; } = true;
			public bool Wear { get; set; } = true;
		}
		
		private class RndItem {
			public string name { get; set; } = "";
			public int amount { get; set; } = 1;
			public int max { get; set; } = 0;
			public string container { get; set; } = "main";
			public bool cond { get; set; } = false;
			public float condmax { get; set; } = CondMax;
			public float condmin { get; set; } = CondMin;
		}		
		
	}
	
}