/*

This plugin add clan Specializations with Skills + Bonuses
User on Botov-NET rust servers
Requires Clans.cs Plugin

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
using Oxide.Core.Plugins;
using Oxide.Core.Libraries;
using Oxide.Core;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Oxide.Core.Configuration;
using System;

using System.Text.RegularExpressions;

namespace Oxide.Plugins
{
    [Info("Clans Study", "AlexALX", "0.0.2")]
    public class ClansStudy : RustPlugin
    {
	
		private class ClanData {
			public int lvl { get; set; } = 0;
			public string type { get; set; } = "";
			public string tmptype { get; set; } = "";
			public bool spec { get; set; } = false;
			public Dictionary<string,int> res { get; set; } = new Dictionary<string,int>();
			public Dictionary<string,float> bonus { get; set; } = new Dictionary<string,float>();
		}	
		
		private class ClanReq {
			public int minplayers { get; set; } = 1;
			public Dictionary<string,int> res { get; set; }
			public Dictionary<string,float> bonus { get; set; }
		}
		
		private class ClanSpec {
			public string name { get; set; } = "";
			public Dictionary<string,int> res { get; set; }
			public Dictionary<string,float> bonus { get; set; }
			public List<string> weapons { get; set; }
		}

		private DynamicConfigFile StudyDataFile;
		string DataFileName = "StudyClans";
		private Oxide.Plugins.Timer SaveTimer;
		
		[PluginReference] Plugin Clans;
		
		bool DEBUG = false;
	
		private Dictionary<int,ClanReq> clanreq = new Dictionary<int,ClanReq>{
			[1] = new ClanReq(){
				res = new Dictionary<string,int>{
					["wolfmeat_cooked"] = 200,
					["bone_fragments"] = 3000,
				},
				minplayers = 2,
				bonus = new Dictionary<string,float>{
					["cond"] = 0.1f,
					["vinos"] = 0.05f,
				}
			},
			[2] = new ClanReq(){
				res = new Dictionary<string,int>{
					["blood"] = 30,
					["skull_human"] = 30,
					["skull_wolf"] = 10,
				},
				minplayers = 3,
				bonus = new Dictionary<string,float>{
					["gather"] = 0.1f,
					["vinos"] = 0.05f,
				}
			},
			[3] = new ClanReq(){
				res = new Dictionary<string,int>{
					["stones"] = 20000,
					["wood"] = 20000,
					["cloth"] = 10000,
				},
				minplayers = 5,
				bonus = new Dictionary<string,float>{
					["defence"] = 0.05f,
					["damage"] = 0.05f,
				}
			},
			[4] = new ClanReq(){
				res = new Dictionary<string,int>{
					["metal_fragments"] = 9000,
					["sulfur"] = 9000,
					["charcoal"] = 10000,
				},
				minplayers = 7,
				bonus = new Dictionary<string,float>{
					["kuznec"] = 0.05f,
					["kits"] = 0f,
					["spec"] = 0f,
 				}
			}
		};
		
		private Dictionary<string,ClanSpec> clanspec = new Dictionary<string,ClanSpec>{
			["aztec"] = new ClanSpec(){
				name = "Ацтеки",
				res = new Dictionary<string,int>{
					["wood"] = 40000,
					["charcoal"] = 20000,
					["sulfur"] = 10000,
					["wolfmeat_cooked"] = 1000,
					["metal_fragments"] = 10000,
				},
				bonus = new Dictionary<string,float>{
					["damage"] = 0.1f,
					["lovk"] = 0.1f,
					["cond"] = 0.05f,
					["weapons"] = 0.15f,
				},
				weapons = new List<string>{"bow_hunting", "spear_wooden", "spear_stone"}
			},
			["maya"] = new ClanSpec(){
				name = "Майя",
				res = new Dictionary<string,int>{
					["wood"] = 40000,
					["charcoal"] = 20000,
					["stones"] = 20000,
					["skull_human"] = 50,
					["skull_wolf"] = 40,
					["blood"] = 30,
				},
				bonus = new Dictionary<string,float>{
					["defence"] = 0.1f,
					["gather"] = 0.05f,
					["kuznec"] = 0.1f,
					["weapons"] = 0.2f,
				},
				weapons = new List<string>{"bow_hunting", "hatchet", "axe_salvaged", "stonehatchet"}
			},
			["inki"] = new ClanSpec(){
				name = "Инки",
				res = new Dictionary<string,int>{
					["wood"] = 40000,
					["charcoal"] = 20000,
					["stones"] = 10000,
					["skull_human"] = 50,
					["skull_wolf"] = 10,
					["blood"] = 60,
					["metal_fragments"] = 10000,
				},
				bonus = new Dictionary<string,float>{
					["master"] = 0.05f,
					["cond"] = 0.05f,
					["weapons"] = 0.25f,
				},
				weapons = new List<string>{"bow_hunting", "pickaxe", "stone_pickaxe", "icepick_salvaged"}
			},
			["colon"] = new ClanSpec(){
				name = "Колонизаторы",
				res = new Dictionary<string,int>{
					["wood"] = 40000,
					["charcoal"] = 20000,
					["metal_ore"] = 20000,
					["wolfmeat_cooked"] = 1000,
					["metal_fragments"] = 10000,
				},
				bonus = new Dictionary<string,float>{
					["kuznec"] = 0.06f,
					["defence"] = 0.12f,
					["gather"] = 0.07f,
					["weapons"] = 0.07f,
				},
				weapons = new List<string>{"smg_thompson", "rifle_bolt", "smg_2", "shotgun_waterpipe", "shotgun_pump"}
			},
			["pirat"] = new ClanSpec(){
				name = "Пираты",
				res = new Dictionary<string,int>{
					["wood"] = 50000,
					["charcoal"] = 20000,
					["skull_human"] = 50,
					["skull_wolf"] = 30,
					["blood"] = 40,
					["metal_fragments"] = 20000,
				},
				bonus = new Dictionary<string,float>{
					["stalker"] = 0.1f,
					["lovk"] = 0.05f,
					["vinos"] = 0.05f,
					["cond"] = 0.05f,
					["weapons"] = 0.07f,
				},
				weapons = new List<string>{"rifle_bolt", "shotgun_waterpipe", "shotgun_pump", "rifle_ak"}
			}
		};
		
		Dictionary<string,string> bdesc = new Dictionary<string,string>{
			["cond"]="Прочность всех предметов",
			["vinos"]="Выносливость",
			["gather"]="Добыча ресурсов",
			["defence"]="Защита",
			["damage"]="Сила",
			["kits"]="Доступ к клановому набору",
			["spec"]="Доступ к специализации клана",
			["kuznec"]="Кузнец",
			["lovk"]="Ловкость",
			["master"]="Мастер (бонус ко всему)",
			["stalker"]="Сталкер"
		};

		private Dictionary<string,ClanData> clandata = new Dictionary<string,ClanData>();
		
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
		
		protected override void LoadDefaultConfig() {
			Config["clanreq"] = new Dictionary<int,ClanReq>();
			Config["clanspec"] = new Dictionary<string,ClanSpec>();
		}
		
		private void SaveData() {
			if (clandata==null) return;
			StudyDataFile["Clans"] = clandata;
			Interface.GetMod().DataFileSystem.SaveDatafile(DataFileName);
		}
		
		private string GetPlayerClan(object player) {
			return (string)(Clans?.Call("GetClanOf",player)) ?? null;
		}
		
		private JObject ExtClanData(string tag) {
			return (JObject)(Clans?.Call("GetClan",tag)) ?? null;
		}
		
        void Loaded()
        {
            StudyDataFile = Interface.GetMod().DataFileSystem.GetDatafile(DataFileName);
			var tmp = ReadFromData<Dictionary<string, ClanData>>("Clans");
			if (tmp!=null) {
				clandata = new Dictionary<string, ClanData>(tmp);
				if (Clans!=null) {
					foreach(KeyValuePair<string,ClanData> kvp in tmp) {
						if (ExtClanData(kvp.Key)==null)	clandata.Remove(kvp.Key);
						else CalcClanBonus(kvp.Key, kvp.Value);
					}
				}
			}
			SaveTimer = timer.Repeat(900f, 0, () => SaveData());
			
			var save = false;
			LoadConfig();
			var tmp2 = ReadFromConfig<Dictionary<int,ClanReq>>("clanreq");
			if (!DEBUG && tmp2!=null&&tmp2.Count>0) clanreq = tmp2;
			else {
				Config["clanreq"] = clanreq;
				save = true;
			}
			var tmp3 = ReadFromConfig<Dictionary<string,ClanSpec>>("clanspec");
			if (!DEBUG && tmp3!=null&&tmp3.Count>0) clanspec = tmp3;
			else {
				Config["clanspec"] = clanspec;
				save = true;
			}			
			if (save) SaveConfig();
			
			//var chatmsg = new List<string>();			
			//Puts(ClearTags(string.Join("\n", chatmsg.ToArray())));
			
        }
		
		private string ClearTags(string txt) {
			txt = Regex.Replace(txt,@"<[^>]*>",String.Empty);
			//txt = Regex.Replace(txt,@"</color>",String.Empty);
			//txt = Regex.Replace(txt,@"<size=(.)>",String.Empty);
			//txt = Regex.Replace(txt,@"</size>",String.Empty);
			return txt;
		}
		
        [HookMethod("OnServerSave")]
        void OnServerSave()
        {
            SaveData();
        }
		/*
        [HookMethod("OnServerInitialized")]
        void OnServerInitialized()
        {

		}*/
		
        [HookMethod("Unload")]
        void Unload()
        {
			SaveTimer.Destroy();
            SaveData();
        }
		
		int GetClanLvl(string tag) {
			if (Clans==null) return 0;
			if (clandata.ContainsKey(tag)) return clandata[tag].lvl;
			return 0;
		}
		
		float GetClanBonus(string sid, string bonus) {
			if (Clans==null) return 0f;
			var clan = GetPlayerClan(sid);
			var cinfo = GetClanData(clan,true);
			if (cinfo==null || cinfo.bonus.Count==0) return 0f;
			if (cinfo.bonus.ContainsKey(bonus)) return cinfo.bonus[bonus];
			return 0f;
		}
		
		bool HasClanBonus(string sid, string bonus, bool isclan = false) {
			if (Clans==null) return false;
			var clan = sid;
			if (!isclan) clan = GetPlayerClan(sid);
			var cinfo = GetClanData(clan,true);
			if (cinfo==null || cinfo.bonus.Count==0) return false;
			if (cinfo.bonus.ContainsKey(bonus)) return true;
			return false;
		}
		
		float GetWeaponBonus(string sid, string weapon) {
			if (Clans==null || weapon=="") return 0f;
			var clan = GetPlayerClan(sid);
			var cinfo = GetClanData(clan,true);
			if (cinfo==null || cinfo.bonus.Count==0 || cinfo.type=="" || !cinfo.spec) return 0f;
			if (!cinfo.bonus.ContainsKey("weapons")) return 0f;
			if (!clanspec.ContainsKey(cinfo.type) || !clanspec[cinfo.type].weapons.Exists(e => e.EndsWith(weapon))) return 0f;
			return cinfo.bonus["weapons"];
		}
		
		string GetClanBonuses(string sid) {
			if (Clans==null) return "";
			var clan = GetPlayerClan(sid);
			var cinfo = GetClanData(clan,true);
			if (cinfo==null || cinfo.bonus.Count==0) return "";
			var chatmsg = new List<string>();
			chatmsg.Add("<color='#DD0000'>Бонусы от вашего клана:</color>");
			foreach(KeyValuePair<string,float> kvp in cinfo.bonus) {
				if (kvp.Key=="spec"||kvp.Key=="kits"||kvp.Key=="weapons") continue;
				chatmsg.Add("<color=#00DD00>"+CalcBonusTxt(kvp.Value)+"</color> "+(bdesc.ContainsKey(kvp.Key)?bdesc[kvp.Key]:kvp.Key));
			}
			chatmsg.Add("--------------");
			return string.Join("\n", chatmsg.ToArray());
		}
		
		private ClanData GetClanData(string tag, bool nocache = false) {
			if (tag==null || tag=="") return null;
			if (clandata.ContainsKey(tag)) return clandata[tag];
			if (nocache) return new ClanData();
			clandata.Add(tag, new ClanData());
			return clandata[tag];
		}
		
		private string CalcBonusTxt(float val) { 
			return "+"+(val*100).ToString()+"%";
		}
		
		private void CalcClanBonus(string clan, ClanData cdata) {
			var bonuses = new Dictionary<string,float>();
			for(var i = 1; i<=cdata.lvl; i++) {
				if (!clanreq.ContainsKey(i)) continue;
				foreach(KeyValuePair<string,float> kvp in clanreq[i].bonus) {
					if (!bonuses.ContainsKey(kvp.Key)) bonuses.Add(kvp.Key, kvp.Value);
					else bonuses[kvp.Key] += kvp.Value;
				}
			}
			if (cdata.type!="" && cdata.spec) {
				foreach(KeyValuePair<string,float> kvp in clanspec[cdata.type].bonus) {
					if (!bonuses.ContainsKey(kvp.Key)) bonuses.Add(kvp.Key, kvp.Value);
					else bonuses[kvp.Key] += kvp.Value;
				}
			}
			cdata.bonus = bonuses;
		}
		
		private string GetClanSpecTxt(ClanData cinfo) {
			var ret = (cinfo.type==""?"отсутствует":(clanspec.ContainsKey(cinfo.type)?clanspec[cinfo.type].name:cinfo.type));
			if (cinfo.type=="") return ret;
			return ret+" <color=#"+(cinfo.spec?"00DD00":"DD0000")+">("+(cinfo.spec?"активна":"не активна")+")</color>";
		}
		
		void OnClanRemoved(string tag) {
			if (clandata.ContainsKey(tag)) clandata.Remove(tag);
		}
		
        [ChatCommand("cskill")]
        void cmdClanSkill(BasePlayer player, string command, string[] args)
        {
			var chatmsg = new List<string>();
			var def = true;
			var clan = GetPlayerClan(player);
			var cinfo = GetClanData(clan,true);
			if (args.Length>0) {
				def = false;
				var ready = true;
				if (args[0].ToLower()!="about" && (clan==null || clan=="")) {
					SendReply(player, "<color='#ffb400'>Вы не состоите в клане! Напишите <color='#00DD00'>/clan</color> чтобы узнать подробности.</color>");
					return;
				}
				switch (args[0].ToLower())
				{
					case "res":
						if (cinfo.lvl==clanreq.Count && (cinfo.spec || cinfo.type=="")) {
							chatmsg.Add("<color='#00DD00'>Ваш клан достиг максимального уровня развития клана.</color>");
							chatmsg.Add("<color='#ffb400'>Владелец клана может выбрать или изменить специализацию клана используя команду <color='#00DD00'>/cskill spec</color>.</color>");
						} else {
							var cext = ExtClanData(clan);
							if (cext==null) return;
							if (!DEBUG && clanreq[(cinfo.lvl==clanreq.Count?cinfo.lvl:cinfo.lvl+1)].minplayers>((JArray)cext["members"]).Count) {
								SendReply(player, "<color='#DD0000'>Недостаточно игроков для повышения клана (минимум "+clanreq[(cinfo.lvl==clanreq.Count?cinfo.lvl:cinfo.lvl+1)].minplayers+").</color>");
								return;
							}
							Dictionary<string,int> need;
							if (cinfo.type!="" && !cinfo.spec) need = clanspec[cinfo.type].res;
							else need = clanreq[cinfo.lvl+1].res;
							if (args.Length>1 && args[1].ToLower()=="add") {
								var items = new List<Item>();
								var addres = new Dictionary<ItemDefinition,int>();
								foreach(KeyValuePair<string,int> kvp in need) {
									var item = ItemManager.FindItemDefinition(kvp.Key);
									if (item==null) continue;
									var amount = player.inventory.GetAmount(item.itemid);
									if (DEBUG) amount = 999999;
									var needres = kvp.Value;
									if (cinfo.res.ContainsKey(kvp.Key)) needres -= cinfo.res[kvp.Key];
									if (amount > needres) {
										amount = needres;
									}
									if (amount>0 && needres>0) {
										addres[item] = amount;
										player.inventory.Take(items,item.itemid, amount);
										player.Command(string.Concat(new object[] { "note.inv ", item.itemid, " ", amount * -1f }), new object[0]);
									}
								}
								if (addres.Count>0) {
									chatmsg.Add("<color='#00DD00'>Ресурсы успешно засчитаны:</color>");
									var added = new List<string>();
									var cdata = GetClanData(clan);
									foreach(KeyValuePair<ItemDefinition,int> kvp in addres) {
										added.Add("<color='#ffb400'>"+kvp.Key.displayName.translated+"</color> +"+kvp.Value);
										if (!cdata.res.ContainsKey(kvp.Key.shortname)) cdata.res.Add(kvp.Key.shortname,0);
										cdata.res[kvp.Key.shortname] += kvp.Value;
									}
									chatmsg.Add(string.Join(", ", added.ToArray()));
									var req = new List<string>();
									foreach(KeyValuePair<string,int> kvp in need) {
										var item = ItemManager.FindItemDefinition(kvp.Key);
										if (item==null) continue;
										var max = kvp.Value;
										var cur = (cdata.res.ContainsKey(kvp.Key)?cdata.res[kvp.Key]:0);
										if (cur<max) ready = false;
									}
									if (ready) {
										if (cinfo.type!="" && !cinfo.spec) {
											chatmsg.Add("\n<color='#DD0000'>Поздравляем!</color>\n<color='#ffb400'>Ваш клан собрал необходимое количество ресурсов, "
											+"лидер вашего клана должен написать <color='#00DD00'>/cskill up</color> чтобы активировать специализацию.</color>");	
										} else {
											chatmsg.Add("\n<color='#DD0000'>Поздравляем!</color>\n<color='#ffb400'>Ваш клан собрал необходимое количество ресурсов для повышения уровня, "
											+"лидер вашего клана должен написать <color='#00DD00'>/cskill up</color> чтобы повысить уровень.</color>");	
										}										
									}
								} else {
									chatmsg.Add("<color='#DD0000'>Нет подходящих ресурсов.</color>");
								}
							} else {
								if (cinfo.type!="" && !cinfo.spec) chatmsg.Add("<color='#00DD00'>Необходимые ресурсы для активации специализации:</color>");
								else chatmsg.Add("<color='#00DD00'>Необходимые ресурсы для повышения:</color>");
								var req = new List<string>();
								foreach(KeyValuePair<string,int> kvp in need) {
									var item = ItemManager.FindItemDefinition(kvp.Key);
									if (item==null) continue;
									var max = kvp.Value;
									var cur = (cinfo.res.ContainsKey(kvp.Key)?cinfo.res[kvp.Key]:0);
									var cres = "["+cur+"/"+max+"]";
									if (cur>=max) cres = "<color=#AADDAA>"+cres+"</color>";
									else ready = false;
									req.Add("<color='#ffb400'>"+item.displayName.translated+"</color> "+cres);
								}
								chatmsg.Add(string.Join("\n", req.ToArray()));
								if (ready) {
									if (cinfo.type!="" && !cinfo.spec) {
										chatmsg.Add("\n<color='#DD0000'>Поздравляем!</color>\n<color='#ffb400'>Ваш клан собрал необходимое количество ресурсов, "
										+"лидер вашего клана должен написать <color='#00DD00'>/cskill up</color> чтобы активировать специализацию.</color>");	
									} else {
										chatmsg.Add("\n<color='#DD0000'>Поздравляем!</color>\n<color='#ffb400'>Ваш клан собрал необходимое количество ресурсов для повышения уровня, "
										+"лидер вашего клана должен написать <color='#00DD00'>/cskill up</color> чтобы повысить уровень.</color>");	
									}			
								} else {
									chatmsg.Add("\n<color='#ffb400'>Чтобы зачислить ресурсы напишите <color='#00DD00'>/cskill res add</color>.");
									chatmsg.Add("Ресурсы будут изъяты из вашего инвентаря и добавлены на счёт вашего клана.");
									chatmsg.Add("Ресурсы можно начислять частями, нет необходимости иметь их все в инвентаре.</color>");
								}
							}
						}
					break;
					case "up":
						if (cinfo.lvl==clanreq.Count && (cinfo.spec || cinfo.type=="")) {
							chatmsg.Add("<color='#00DD00'>Ваш клан достиг максимального уровня развития клана.</color>");
							chatmsg.Add("<color='#ffb400'>Владелец клана может выбрать или изменить специализацию клана используя команду <color='#00DD00'>/cskill spec</color>.</color>");
						} else {
							var cext = ExtClanData(clan);
							if (cext==null) return;
							if (!DEBUG && clanreq[(cinfo.lvl==clanreq.Count?cinfo.lvl:cinfo.lvl+1)].minplayers>((JArray)cext["members"]).Count) {
								SendReply(player, "<color='#DD0000'>Недостаточно игроков для повышения клана (минимум "+clanreq[(cinfo.lvl==clanreq.Count?cinfo.lvl:cinfo.lvl+1)].minplayers+").</color>");
								return;
							}
							if ((string)cext["owner"]!=player.userID.ToString()) {
								SendReply(player, "<color='#DD0000'>Только владелец клана может повысить уровень!</color>");
								return;
							}
							Dictionary<string,int> need;
							var specup = (cinfo.type!="" && !cinfo.spec?true:false);
							if (specup) need = clanspec[cinfo.type].res;
							else need = clanreq[cinfo.lvl+1].res;
							foreach(KeyValuePair<string,int> kvp in need) {
								var item = ItemManager.FindItemDefinition(kvp.Key);
								if (item==null) continue;
								if (!cinfo.res.ContainsKey(kvp.Key) || cinfo.res[kvp.Key]<kvp.Value) { ready = false; break; }
							}
							if (ready) {
								var cdata = GetClanData(clan);
								cdata.res.Clear();
								if (specup) {
									cdata.spec = true;
									CalcClanBonus(clan,cinfo);
									foreach (var memberId in ((JArray)cext["members"])) {
										var p = BasePlayer.FindByID(Convert.ToUInt64(memberId));
										if (p != null) {
											var chatmsgp = new List<string>();
											chatmsgp.Add("<color='#00DD00'>Специализация клана активирована!</color>");
											chatmsgp.Add("<color='#ffb400'>Текущая специализация:</color> "+GetClanSpecTxt(cdata)+"\n<color='#ffb400'>");
											var bonus = "";
											foreach(KeyValuePair<string,float> kvb in clanspec[cinfo.type].bonus) {
												if (kvb.Key=="weapons") continue;
												if (bonus!="") bonus += ", ";
												bonus += (bdesc.ContainsKey(kvb.Key)?bdesc[kvb.Key]:kvb.Key)+(kvb.Value>0f?" <color=#00DD00>"+CalcBonusTxt(kvb.Value)+"</color>":"");
											}					
											chatmsgp.Add("<color='#00DD00'>Новые бонусы:</color> "+bonus);
											var weapons = "";
											foreach(string weapon in clanspec[cinfo.type].weapons) {
												var item = ItemManager.FindItemDefinition(weapon);
												if (item==null) continue;
												if (weapons!="") weapons += ", ";
												weapons += item.displayName.translated;
											}
											if (clanspec[cinfo.type].bonus.ContainsKey("weapons")) chatmsgp.Add("<color='#00DD00'>Бонусы к оружию:</color> "+weapons+" - <color='#00DD00'>"+CalcBonusTxt(clanspec[cinfo.type].bonus["weapons"])+"</color> урона");
											p.ChatMessage(string.Join("\n", chatmsgp.ToArray())+"</color>");
										}
									}
								} else {
									cdata.lvl += 1;
									CalcClanBonus(clan,cinfo);
									foreach (var memberId in ((JArray)cext["members"])) {
										var p = BasePlayer.FindByID(Convert.ToUInt64(memberId));
										if (p != null) {
											var chatmsgp = new List<string>();
											chatmsgp.Add("<color='#00DD00'>Уровень клана повышен!</color>");
											chatmsgp.Add("<color='#ffb400'>Текущий уровень: <color=#FFFFFF>"+cdata.lvl+"</color>");
											chatmsgp.Add("\n<color='#00DD00'>Новые бонусы:</color>");
											foreach(KeyValuePair<string,float> kvp in clanreq[cdata.lvl].bonus) {
												chatmsgp.Add("<color='#ffb400'>"+(bdesc.ContainsKey(kvp.Key)?bdesc[kvp.Key]:kvp.Key)+"</color>"+(kvp.Value>0f?" <color=#00DD00>"+CalcBonusTxt(kvp.Value)+"</color>":""));
											}
											p.ChatMessage(string.Join("\n", chatmsgp.ToArray())+"</color>");
										}
									}
								}
							} else {
								chatmsg.Add("<color='#DD0000'>Недостаточно ресурсов для повышения клана.</color>");
								chatmsg.Add("<color='#ffb400'>Используйте команду <color='#00DD00'>/cskill res</color> для начисления ресурсов.</color>");
							}
						}
					break;
					case "info":
						chatmsg.Add("<color='#00DD00'>Уровень вашего клана:</color> "+cinfo.lvl);
						var cextd = ExtClanData(clan);
						var members = "Ошибка";
						if (cextd!=null) members = ((JArray)cextd["members"]).Count.ToString();
						chatmsg.Add("<color='#00DD00'>Количество игроков:</color> "+members);
						chatmsg.Add("<color='#00DD00'>Специализация клана:</color> "+GetClanSpecTxt(cinfo));
						chatmsg.Add("\n<color='#00DD00'>Клановые бонусы</color>");
						if (cinfo.bonus.Count==0) {
							chatmsg.Add("<color='#ffb400'>На данный момент клан не имеет бонусов.</color>");
						} else {
							foreach(KeyValuePair<string,float> kvp in cinfo.bonus) {
								if (kvp.Key=="spec" || kvp.Key=="weapons") continue;
								chatmsg.Add("<color='#ffb400'>"+(bdesc.ContainsKey(kvp.Key)?bdesc[kvp.Key]:kvp.Key)+"</color>"+(kvp.Value>0f?" <color=#00DD00>"+CalcBonusTxt(kvp.Value)+"</color>":""));
							}
							if (cinfo.type!="" && cinfo.spec && clanspec[cinfo.type].bonus.ContainsKey("weapons")) {
								var weapons = "";
								foreach(string weapon in clanspec[cinfo.type].weapons) {
									var item = ItemManager.FindItemDefinition(weapon);
									if (item==null) continue;
									if (weapons!="") weapons += ", ";
									weapons += item.displayName.translated;
								}
								SendReply(player, string.Join("\n", chatmsg.ToArray()));							
								chatmsg.Clear();	
								chatmsg.Add("<color='#00DD00'>Бонусы к оружию:</color> <color='#ffb400'>"+weapons+" - <color='#00DD00'>"+CalcBonusTxt(clanspec[cinfo.type].bonus["weapons"])+"</color> урона</color>");
							}
						}
					break;
					case "spec":
						if (args.Length==1) {
							chatmsg.Add("<color='#00DD00'>Выбор специализации клана</color>");
							chatmsg.Add("<color='#ffb400'>Каждый клан может выбирать свою специализацию клана, а также изменять её в любой момент.");
							chatmsg.Add("Для того чтобы активировать выбранную специализацию необходимо собрать определнное количесво ресурсов.");
							chatmsg.Add("При смене специализации бонусы предыдущей специализации аннулируються и будет необходимо заново собирать требуемые ресурсы для новой специализации.</color>");
							chatmsg.Add("<color='#00DD00'>Текущая специализация клана:</color> "+GetClanSpecTxt(cinfo));
							SendReply(player, string.Join("\n", chatmsg.ToArray()));							
							chatmsg.Clear();	
							chatmsg.Add("<color='#DD0000'>Доступные команды:</color>");	
							chatmsg.Add("<color='#00DD00'>/cskill about spec</color> - информация о специализациях клана");
						}
						if (!HasClanBonus(clan,"spec",true)) {
							chatmsg.Add((args.Length==1?"\n":"")+"<color='#ffb400'>На данный момент клан не имеет доступа к специализациям. Необходим <color=#00DD00>"+clanreq.Count+" уровень</color> клана.</color>");
						} else {
							var cext = ExtClanData(clan);
							if (cext==null) return;
							if (!DEBUG && clanreq[cinfo.lvl].minplayers>((JArray)cext["members"]).Count) {
								chatmsg.Add("\n<color='#DD0000'>Недостаточно игроков для выбора специализации (минимум "+clanreq[cinfo.lvl].minplayers+").</color>");
							} else if ((string)cext["owner"]!=player.userID.ToString()) {
								chatmsg.Add("\n<color='#DD0000'>Только владелец клана может выбирать специализацию клана!</color>");
							} else {		
								if (args.Length>1) {
									var spec = args[1].ToLower();
									if (clanspec.ContainsKey(spec)) {
										chatmsg.Add("<color='#00DD00'>Выбранная специализация:</color> "+clanspec[spec].name+"<color='#ffb400'>");
										cinfo.tmptype = spec;
										var req = "";
										foreach(KeyValuePair<string,int> kvi in clanspec[spec].res) {
											var item = ItemManager.FindItemDefinition(kvi.Key);
											if (item==null) continue;
											if (req!="") req += ", ";
											req += kvi.Value+" "+item.displayName.translated;
										}
										chatmsg.Add("<color='#00DD00'>Необходимые ресурсы:</color> "+req);
										var bonus = "";
										foreach(KeyValuePair<string,float> kvb in clanspec[spec].bonus) {
											if (kvb.Key=="weapons") continue;
											if (bonus!="") bonus += ", ";
											bonus += (bdesc.ContainsKey(kvb.Key)?bdesc[kvb.Key]:kvb.Key)+(kvb.Value>0f?" <color=#00DD00>"+CalcBonusTxt(kvb.Value)+"</color>":"");
										}					
										chatmsg.Add("<color='#00DD00'>Бонусы:</color> "+bonus);
										var weapons = "";
										foreach(string weapon in clanspec[spec].weapons) {
											var item = ItemManager.FindItemDefinition(weapon);
											if (item==null) continue;
											if (weapons!="") weapons += ", ";
											weapons += item.displayName.translated;
										}
										if (clanspec[spec].bonus.ContainsKey("weapons")) chatmsg.Add("<color='#00DD00'>Бонусы к оружию:</color> "+weapons+" - <color='#00DD00'>"+CalcBonusTxt(clanspec[spec].bonus["weapons"])+"</color> урона");
										//SendReply(player, string.Join("\n", chatmsg.ToArray())+"</color>");							
										//chatmsg.Clear();
										chatmsg.Add("\nНапишите <color='#00DD00'>/cskill spec yes</color> чтобы подвердить выбор специализации.</color>");
									} else if (spec=="yes") {
										if (cinfo.type=="") {
											if (cinfo.tmptype!="" && clanspec.ContainsKey(cinfo.tmptype)) {
												chatmsg.Add("<color='#00DD00'>Специализация клана успешно выбрана.</color>");
												var req = "";
												foreach(KeyValuePair<string,int> kvi in clanspec[cinfo.tmptype].res) {
													var item = ItemManager.FindItemDefinition(kvi.Key);
													if (item==null) continue;
													if (req!="") req += "\n";
													//if (DEBUG) cinfo.res[kvi.Key] = kvi.Value;
													req += "<color='#ffb400'>"+item.displayName.translated+"</color> ["+kvi.Value+"]";
												}
												chatmsg.Add("\n<color='#00DD00'>Необходимые ресурсы для активации:</color>\n"+req);
												cinfo.type = cinfo.tmptype;
												cinfo.tmptype = "";
												cinfo.res.Clear();
											} else {
												chatmsg.Add("<color='#DD0000'>Вы не задали специализацию которую хотите выбрать.</color>");
											}
										} else {
											chatmsg.Add("<color='#00DD00'>Специализация клана успешно сброшена.</color>");
											cinfo.type = "";
											cinfo.tmptype = "";
											cinfo.spec = false;
											cinfo.res.Clear();
											CalcClanBonus(clan,cinfo);
										}
									} else if (spec=="reset") {
										if (cinfo.type=="") {
											chatmsg.Add("<color='#DD0000'>Невозможно сбросить специализацию - ваш клан не имеет специализации.</color>");
										} else {
											chatmsg.Add("<color='#00DD00'>Вы действительно хотите сбросить специализацию?</color>");
											chatmsg.Add("<color='#ffb400'>Все собраные ресурсы и бонусы текущей специализации будут аннулированы.");
											chatmsg.Add("Напишите <color='#00DD00'>/cskill spec yes</color> чтобы подвердить сброс.</color>");
										}
									} else {
										chatmsg.Add("<color='#DD0000'>Не верный параметр.</color>");
									}
								} else {		
									cinfo.tmptype = "";
									if (cinfo.type=="") {
										foreach(KeyValuePair<string,ClanSpec> kvp in clanspec) {
											chatmsg.Add("<color='#00DD00'>/cskill spec "+kvp.Key+"</color> - выбрать специализацию \""+kvp.Value.name+"\"");
										}
										chatmsg.Add("<color='#00DD00'>/cskill spec yes</color> - подтвердить выбор специализации");
									} else chatmsg.Add("<color='#00DD00'>/cskill spec reset</color> - сбросить специализацию");
								}
							}
						}						
					break;
					case "about":
						var def2 = true;
						if (args.Length>1) {
							def2 = false;
							switch (args[1].ToLower())
							{
								case "spec":
									chatmsg.Add("<color='#DD0000'>Описание специализаций</color>");
									chatmsg.Add("<color='#ffb400'>Специализации может выбрать или изменить владелец клана при достижении <color='#00DD00'>"+clanreq.Count+" уровня</color> клана.");
									chatmsg.Add("Специализации требуют ресурсы для активации и дают определённые бонусы.</color>");
									SendReply(player, string.Join("\n", chatmsg.ToArray()));							
									chatmsg.Clear();						
									foreach(KeyValuePair<string,ClanSpec> kvp in clanspec) {
										chatmsg.Add("<color='#00DD00'>"+kvp.Value.name+"</color><color='#ffb400'>");
										var req = "";
										foreach(KeyValuePair<string,int> kvi in kvp.Value.res) {
											var item = ItemManager.FindItemDefinition(kvi.Key);
											if (item==null) continue;
											if (req!="") req += ", ";
											req += kvi.Value+" "+item.displayName.translated;
										}
										chatmsg.Add("<color='#00DD00'>Необходимые ресурсы:</color> "+req);
										var bonus = "";
										foreach(KeyValuePair<string,float> kvb in kvp.Value.bonus) {
											if (kvb.Key=="weapons") continue;
											if (bonus!="") bonus += ", ";
											bonus += (bdesc.ContainsKey(kvb.Key)?bdesc[kvb.Key]:kvb.Key)+(kvb.Value>0f?" <color=#00DD00>"+CalcBonusTxt(kvb.Value)+"</color>":"");
										}					
										chatmsg.Add("<color='#00DD00'>Бонусы:</color> "+bonus);
										var weapons = "";
										foreach(string weapon in kvp.Value.weapons) {
											var item = ItemManager.FindItemDefinition(weapon);
											if (item==null) continue;
											if (weapons!="") weapons += ", ";
											weapons += item.displayName.translated;
										}
										if (kvp.Value.bonus.ContainsKey("weapons")) chatmsg.Add("<color='#00DD00'>Бонусы к оружию:</color> "+weapons+" - <color='#00DD00'>"+CalcBonusTxt(kvp.Value.bonus["weapons"])+"</color> урона");
										SendReply(player, string.Join("\n", chatmsg.ToArray())+"</color>");							
										chatmsg.Clear();
									}		
									chatmsg.Add("<color='#00DD00'>Причечание:</color> <color='#ffb400'>Используйте прокрутку чата чтобы прочитать всю информацию.</color>");
									//chatmsg.Add("<color='#DD0000'>Значения могут быть изменены до ввода функционала.</color>");
									//return;
								break;
								case "bonus":
									chatmsg.Add("<color='#DD0000'>Описание клановых бонусов</color>");
									chatmsg.Add("<color='#ffb400'>При достижении клана определёного уровня все игроки клана получают определённые бонусы.");
									chatmsg.Add("Бонусы сумируются, т.е. клановые игроки получают бонусы от всех уровней.</color>");
									SendReply(player, string.Join("\n", chatmsg.ToArray()));							
									chatmsg.Clear();	
									foreach(KeyValuePair<int,ClanReq> kvp in clanreq) {
										chatmsg.Add("<color='#DD0000'>"+kvp.Key+" Уровень клана</color><color='#ffb400'>");
										var req = "";
										foreach(KeyValuePair<string,int> kvi in kvp.Value.res) {
											var item = ItemManager.FindItemDefinition(kvi.Key);
											if (item==null) continue;
											if (req!="") req += ", ";
											req += kvi.Value+" "+item.displayName.translated;
										}
										chatmsg.Add("<color='#00DD00'>Необходимые ресурсы:</color> "+req);
										var bonus = "";
										foreach(KeyValuePair<string,float> kvb in kvp.Value.bonus) {
											if (kvb.Key=="weapons") continue;
											if (bonus!="") bonus += ", ";
											bonus += (bdesc.ContainsKey(kvb.Key)?bdesc[kvb.Key]:kvb.Key)+(kvb.Value>0f?" <color=#00DD00>"+CalcBonusTxt(kvb.Value)+"</color>":"");
										}					
										chatmsg.Add("<color='#00DD00'>Бонусы:</color> "+bonus);
										SendReply(player, string.Join("\n", chatmsg.ToArray())+"</color>");							
										chatmsg.Clear();
									}
									//return;
								break;
								default:
									def2 = true;
								break;
							}
						} 
						if (def2) {					
							chatmsg.Add("<color='#00DD00'>О кланововой системе прокачки</color>");		
							chatmsg.Add("<color='#ffb400'>Данная система разработана специально для проекта");
							chatmsg.Add("<color='#FF0000'>Botov.NET.UA</color> и на данный момент является <i>эксклюзивной</i>.</color>\n");
							chatmsg.Add("<color='#ffb400'>Прокачка клана осуществляется сбором определённых ресурсов и наличием нужного количества игроков в клане.</color>\n");
							chatmsg.Add("<color='#00DD00'>/cskill about bonus</color> - информация о клановых бонусах");
							chatmsg.Add("<color='#00DD00'>/cskill about spec</color> - информация о специализациях клана\n");
							chatmsg.Add("<color='#DD0000'>На данный момент система находиться в стадии разработки, подробное описание будет позже.</color>");
						}
					break;
					default:
						def = true;
					break;
				}
			}
			if (def) {
				chatmsg.Add("<color='#00DD00'>Клановая система прокачки от</color> <color='#FF0000'>Botov.NET.UA</color> v"+this.Version);
				chatmsg.Add("<color='#FF0000'><size=16>Данная система находится в стадии разработки.</size></color>\n");
				chatmsg.Add("<color='#ffb400'><color='#FF0000'>Список доступных команд:</color>");
				chatmsg.Add("<color='#00DD00'>/cskill about</color> - о системе прокачки кланов и её <color='#00DD00'>бонусах</color>");
				chatmsg.Add("<color='#00DD00'>/cskill info</color> - информация о бонусах вашего клана");
				chatmsg.Add("<color='#00DD00'>/cskill res</color> - зачисление ресурсов для повышения уровня клана");
				chatmsg.Add("<color='#00DD00'>/cskill up</color> - повышение уровня клана");
				chatmsg.Add("<color='#00DD00'>/cskill spec</color> - изменение специализации клана");
				chatmsg.Add("</color>");
			}
			
			SendReply(player, string.Join("\n", chatmsg.ToArray()));
		}
		
    }
   
}