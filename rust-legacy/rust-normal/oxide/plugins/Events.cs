/*

This plugin add unique events for any playes, completing those will give rewards.
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
using Oxide.Core.Plugins;
using System;
using Oxide.Game.Rust;

using Newtonsoft.Json;
using System.Linq;

namespace Oxide.Plugins
{
    [Info("Events Botov-NET", "AlexALX", "0.0.1")]
    public class Events : RustPlugin
    {
		private class Event {
			public string name { get; set; } = "";
			public string ename { get; set; } = "";
			public int minplayers { get; set; } = 4;
			public float time { get; set; } = 1800f;
			public List<string> weapons { get; set; } = new List<string>();
			public int type { get; set; } = 0;
			public List<string> classes { get; set; } = new List<string>();
			public bool animals { get; set; } = false;
			public bool nosleep { get; set; } = false;
			public int mincount { get; set; } = 1;
			public Dictionary<int,Dictionary<string,List<List<RndItem>>>> prises { get; set; }
			public Dictionary<string,List<List<RndItem>>> prisesjoin { get; set; } = new Dictionary<string,List<List<RndItem>>>();
			public float msgtime { get; set; } = 300f;
			public int msgcount { get; set; } = 5;
			public Dictionary<string,string> messages { get; set; }
			//public int last { get; set; } = 0;
			public bool air { get; set; } = false;
			public Dictionary<string,string> rndanimal = new Dictionary<string,string>();
			public bool one { get; set; } = false;
			public int ID { get; set; } = 0;
		}
		
		private class RndItem {
			public string name { get; set; } = "";
			public int amount { get; set; } = 1;
			public int max { get; set; } = 0;
			public string container { get; set; } = "main";
			public float cond { get; set; } = 0f;
			public bool mul { get; set; } = false;
		}	
		
		private class DataItem {
			public int count { get; set; } = 0;
			public double last { get; set; } = 0;
		}
		
		private const string airmsg = "\nДополнительно за первое место прилетит <color=#DD0000>аирдроп</color>.";
		
		private List<Event> events = new List<Event>(){
			new Event(){
				name = "Лисица",
				ename = "Lisica",
				weapons = new List<string>{"bow_hunting"},
				classes = new List<string>{"chicken"},
				time = 3600f,
				msgcount = 11,
				messages = new Dictionary<string,string>{
					["start"] = "убить как можно больше куриц.",
					["need"] = "убить с лука.",
					["prises"] = "топ-3 игроков получат призы."+airmsg,
					["timed"] = "Топ-3 игроков",
					["end"] = "Топ-3 победителей",
					["desc"] = "куриц",
					["descn"] = "недостаточно куриц"
				},
				prisesjoin = new Dictionary<string,List<List<RndItem>>>{
					["weapon"] = new List<List<RndItem>>{
						new List<RndItem>{new RndItem(){name="arrow_wooden",amount=12},new RndItem(){name="bandage",container="belt"}},
					}
				},
				prises = new Dictionary<int,Dictionary<string,List<List<RndItem>>>>(){
					[1] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{new RndItem(){name="rifle_ak",container="belt"},new RndItem(){name="ammo_rifle",amount=60},new RndItem(){name="ammo_rifle",amount=4,mul=true}},
							new List<RndItem>{new RndItem(){name="rifle_bolt",container="belt"},new RndItem(){name="ammo_rifle",amount=60},new RndItem(){name="ammo_rifle",amount=4,mul=true}}
						},
						["ammo"] = new List<List<RndItem>>{
							new List<RndItem>{
								new RndItem(){name="explosive.timed",container="belt"},new RndItem(){name="metal_plate_torso",container="wear"},
								new RndItem(){name="metal_facemask",container="wear"}
							}
						}
					},
					[2] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{new RndItem(){name="smg_thompson",container="belt"},new RndItem(){name="ammo_pistol",amount=60},new RndItem(){name="ammo_pistol",amount=4,mul=true}},
							new List<RndItem>{new RndItem(){name="smg_2",container="belt"},new RndItem(){name="ammo_pistol",amount=60},new RndItem(){name="ammo_pistol",amount=4,mul=true}}
						},
						["ammo"] = new List<List<RndItem>>{
							new List<RndItem>{new RndItem(){name="metal_plate_torso",container="wear"},new RndItem(){name="grenade.f1",container="belt",amount=5}}
						}
					},
					[3] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{new RndItem(){name="shotgun_waterpipe",container="belt"},new RndItem(){name="ammo_handmade_shell",amount=24},new RndItem(){name="ammo_handmade_shell",amount=4,mul=true}}
						},
						["ammo"] = new List<List<RndItem>>{
							new List<RndItem>{new RndItem(){name="grenade.beancan",container="belt",amount=5}}
						}
					}
				},
				air = true
			},
			new Event(){
				name = "Браконьер",
				ename = "Brakonyer",
				mincount = 3,
				rndanimal = new Dictionary<string,string>{
					["horse"] = "лошадей",
					["boar"] = "кабанов",
					["bear"] = "медведей",
					["stag"] = "оленей",
					["wolf"] = "волков",
				},
				messages = new Dictionary<string,string>{
					["startr"] = "убить как можно больше {replace}.",
					["need"] = "убить не менее 3х животных.",
					["prises"] = "топ-3 игроков получат призы."+airmsg,
					["timed"] = "Топ-3 игроков",
					["end"] = "Топ-3 победителей",
					["desc"] = "животных",
					["descn"] = "недостаточно животных"
				},
				prisesjoin = new Dictionary<string,List<List<RndItem>>>{
					["weapon"] = new List<List<RndItem>>{
						new List<RndItem>{new RndItem(){name="bandage",container="belt"},new RndItem(){name="syringe_medical",container="belt"}},
					}
				},
				prises = new Dictionary<int,Dictionary<string,List<List<RndItem>>>>(){
					[1] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{new RndItem(){name="rifle_ak",container="belt"},new RndItem(){name="ammo_rifle",amount=60},new RndItem(){name="ammo_rifle",amount=4,mul=true}},
							new List<RndItem>{new RndItem(){name="rifle_bolt",container="belt"},new RndItem(){name="ammo_rifle",amount=60},new RndItem(){name="ammo_rifle",amount=4,mul=true}}
						},
						["ammo"] = new List<List<RndItem>>{
							new List<RndItem>{
								new RndItem(){name="gunpowder",amount=1500},new RndItem(){name="wolfmeat_cooked",amount=10},new RndItem(){name="chicken_cooked",amount=3,mul=true},
								new RndItem(){name="grenade.f1",container="belt"}
							}
						}
					},
					[2] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{new RndItem(){name="smg_thompson",container="belt"},new RndItem(){name="ammo_pistol",amount=60},new RndItem(){name="ammo_pistol",amount=4,mul=true}},
							new List<RndItem>{new RndItem(){name="smg_2",container="belt"},new RndItem(){name="ammo_pistol",amount=60},new RndItem(){name="ammo_pistol",amount=4,mul=true}}
						},
						["ammo"] = new List<List<RndItem>>{
							new List<RndItem>{new RndItem(){name="gunpowder",amount=500},new RndItem(){name="grenade.beancan",container="belt"}}
						}
					},
					[3] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{new RndItem(){name="shotgun_waterpipe",container="belt"},new RndItem(){name="ammo_handmade_shell",amount=24},new RndItem(){name="ammo_handmade_shell",amount=4,mul=true}}
						},
						["ammo"] = new List<List<RndItem>>{
							new List<RndItem>{new RndItem(){name="syringe_medical",container="belt",amount=2}}
						}
					}
				},
				air = true
			},
			new Event(){
				name = "Королевская охота",
				ename = "Korolevskaya oxota",
				weapons = new List<string>{"bow_hunting"},
				animals = true,
				time = 2700f,
				mincount = 8,
				messages = new Dictionary<string,string>{
					["start"] = "убить как можно больше животных.",
					["need"] = "убить с лука, но не менее 8ми.",
					["prises"] = "топ-3 игроков получат призы."+airmsg,
					["timed"] = "Топ-3 игроков",
					["end"] = "Топ-3 победителей",
					["desc"] = "животных",
					["descn"] = "недостаточно животных"
				},
				prisesjoin = new Dictionary<string,List<List<RndItem>>>{
					["weapon"] = new List<List<RndItem>>{
						new List<RndItem>{new RndItem(){name="arrow_wooden",amount=24},new RndItem(){name="bandage",container="belt"},new RndItem(){name="syringe_medical",container="belt"}},
					}
				},
				prises = new Dictionary<int,Dictionary<string,List<List<RndItem>>>>(){
					[1] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{
								new RndItem(){name="grenade.f1",container="belt",amount=5},new RndItem(){name="shotgun_pump",container="belt"},
								new RndItem(){name="ammo_shotgun",amount=30},new RndItem(){name="ammo_shotgun",amount=2,mul=true},
								new RndItem(){name="trap_bear",amount=3},new RndItem(){name="ammo_rocket_basic",amount=2}
							}
						}
					},
					[2] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{
								new RndItem(){name="grenade.beancan",container="belt",amount=5},new RndItem(){name="smg_thompson",container="belt"},
								new RndItem(){name="ammo_pistol",amount=60},new RndItem(){name="ammo_pistol",amount=4,mul=true},
								new RndItem(){name="trap_bear",amount=1},new RndItem(){name="gunpowder",amount=1500}
							}
						}
					},
					[3] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{
								new RndItem(){name="largemedkit",container="belt",amount=3},new RndItem(){name="syringe_medical",container="belt",amount=3},
								new RndItem(){name="wolfmeat_cooked",amount=10},new RndItem(){name="chicken_cooked",amount=3,mul=true},
								new RndItem(){name="gunpowder",amount=500}
							}
						}
					}
				},
				air = true
			},
			new Event(){
				name = "Резня",
				ename = "Rezna",
				weapons = new List<string>{
					"knife_bone","spear_stone","spear_wooden","hatchet","stonehatchet","pickaxe","bone_club",
					"axe_salvaged","hammer_salvaged","stone_pickaxe","icepick_salvaged","rock","machete","salvaged_sword"
				},
				nosleep = true,
				mincount = 5,
				time = 3600f,
				msgcount = 11,
				type = 1,
				minplayers = 10,
				messages = new Dictionary<string,string>{
					["start"] = "убить как можно больше онлайн игроков.",
					["need"] = "убить холодным оружием, но не менее 5ти.",
					["prises"] = "топ-3 игроков получат призы."+airmsg,
					["timed"] = "Топ-3 игроков",
					["end"] = "Топ-3 победителей",
					["desc"] = "игроков",
					["descn"] = "недостаточно игроков"
				},
				prisesjoin = new Dictionary<string,List<List<RndItem>>>{
					["weapon"] = new List<List<RndItem>>{
						new List<RndItem>{new RndItem(){name="hatchet",container="belt"},new RndItem(){name="syringe_medical",container="belt",amount=2}},
					}
				},
				prises = new Dictionary<int,Dictionary<string,List<List<RndItem>>>>(){
					[1] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{
								new RndItem(){name="explosive.timed",container="belt",amount=2},new RndItem(){name="grenade.f1",container="belt",amount=5},new RndItem(){name="rifle_ak",container="belt"},
								new RndItem(){name="ammo_rifle",amount=60},new RndItem(){name="ammo_rifle",amount=4,mul=true}
							}
						}
					},
					[2] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{
								new RndItem(){name="grenade.beancan",container="belt",amount=10},new RndItem(){name="smg_2",container="belt"},
								new RndItem(){name="ammo_pistol",amount=60},new RndItem(){name="ammo_pistol",amount=4,mul=true}
							}
						}
					},
					[3] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{
								new RndItem(){name="grenade.beancan",container="belt",amount=5},new RndItem(){name="bandage",container="belt",amount=4},
								new RndItem(){name="humanmeat_cooked",amount=4,mul=true}
							}
						}
					}
				},
				air = true
			},
			new Event(){
				name = "Охотник",
				ename = "Oxotnuk",
				time = 900f,
				mincount = 1,
				one = true,
				rndanimal = new Dictionary<string,string>{
					["horse"] = "лошадь",
					["boar"] = "кабана",
					["bear"] = "медведя",
					["stag"] = "оленя",
					["wolf"] = "волка",
				},
				msgcount = 2,
				messages = new Dictionary<string,string>{
					["startr"] = "убить {replace}.",
					["need"] = "убить первым.",
					["prises"] = "К победителю прилетит <color=#DD0000>аирдроп</color>."
				},
				air = true
			},
			new Event(){
				name = "Найди бочки",
				ename = "Naydu bo4ki",
				weapons = new List<string>{
					"knife_bone","spear_stone","spear_wooden","hatchet","stonehatchet","pickaxe","bone_club",
					"axe_salvaged","hammer_salvaged","stone_pickaxe","icepick_salvaged","rock","machete","salvaged_sword"
				},
				time = 600f,
				mincount = 3,
				one = true,
				msgcount = 1,
				type = 2,
				messages = new Dictionary<string,string>{
					["start"] = "разбить 3 бочки.",
					["need"] = "разбить первым c холодного оружия.",
					["prises"] = "К победителю прилетит <color=#DD0000>аирдроп</color>.",
					["desc"] = "Разбито бочек:"
				},
				air = true
			},
			new Event(){
				name = "Сталкер",
				ename = "Stalker",
				mincount = 8,
				time = 1800f,
				msgcount = 5,
				type = 2,
				minplayers = 10,
				messages = new Dictionary<string,string>{
					["start"] = "разбить как можно больше бочек.",
					["need"] = "разбить не менее 8ти бочек.",
					["prises"] = "топ-3 игроков получат призы."+airmsg,
					["timed"] = "Топ-3 игроков",
					["end"] = "Топ-3 победителей",
					["desc"] = "бочек",
					["descn"] = "недостаточно бочек"
				},
				prisesjoin = new Dictionary<string,List<List<RndItem>>>{
					["weapon"] = new List<List<RndItem>>{
						new List<RndItem>{new RndItem(){name="hatchet",container="belt"},new RndItem(){name="metal_fragments",amount=200}},
					}
				},
				prises = new Dictionary<int,Dictionary<string,List<List<RndItem>>>>(){
					[1] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{
								new RndItem(){name="grenade.f1",container="belt",amount=5},new RndItem(){name="rifle_bolt",container="belt"},
								new RndItem(){name="ammo_rifle",amount=24},new RndItem(){name="ammo_rifle",amount=3,mul=true},
								new RndItem(){name="syringe_medical",amount=2},new RndItem(){name="metal_fragments",amount=1200},
								new RndItem(){name="gunpowder",amount=500}
							}
						}
					},
					[2] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{
								new RndItem(){name="grenade.beancan",container="belt",amount=5},new RndItem(){name="smg_2",container="belt"},
								new RndItem(){name="ammo_pistol",amount=48},new RndItem(){name="ammo_pistol",amount=4,mul=true},
								new RndItem(){name="syringe_medical",amount=2},new RndItem(){name="metal_fragments",amount=500}
							}
						}
					},
					[3] = new Dictionary<string,List<List<RndItem>>>{
						["weapon"] = new List<List<RndItem>>{
							new List<RndItem>{
								new RndItem(){name="grenade.beancan",container="belt",amount=2},new RndItem(){name="antiradpills",container="belt",amount=5},
								new RndItem(){name="wolfmeat_cooked",amount=3,mul=true},new RndItem(){name="largemedkit",container="belt"},new RndItem(){name="metal_fragments",amount=200}
							}
						}
					}
				},
				air = true
			}
		};
		/*
		private const string DataFileName = "EventsData";
		private DynamicConfigFile EventDataFile;
		*/
        public T ReadFromConfig<T>(string configKey)
        {
            string serializeObject = JsonConvert.SerializeObject(Config[configKey]);
            return JsonConvert.DeserializeObject<T>(serializeObject);
        }
		/*
        public T ReadFromData<T>(string dataKey)
        {
            string serializeObject = JsonConvert.SerializeObject(EventDataFile[dataKey]);
            return JsonConvert.DeserializeObject<T>(serializeObject);
        }
		
		private void SaveData() {
			EventDataFile["nextevent"] = nextevent-CurrentTime();
			EventDataFile["activeEvent"] = activeEvent;
			Interface.GetMod().DataFileSystem.SaveDatafile(DataFileName);
		}*/
		
		private DateTime epoch = new System.DateTime(1970, 1, 1);
		
        private double CurrentTime()
        {
            return System.DateTime.UtcNow.Subtract(epoch).TotalSeconds;
        }
		
		private string CalcTime(double time, bool cmd = false) {
			var str = "";
			if (time/60/60/24>1) {
				str = Math.Ceiling(time/60/60/24).ToString()+(cmd?" day":" дней");
			} else if (time/60/60>1) {
				str = Math.Ceiling(time/60/60).ToString()+(cmd?" hour":" часов");
			} else if (time/60>1) {
				str = Math.Ceiling(time/60).ToString()+(cmd?" min":" минут");
			} else {
				str = Math.Ceiling(time).ToString()+(cmd?" sec":" секунд");
			}
			return str;
		}
		
		private Dictionary<BasePlayer,DataItem> eventdata = new Dictionary<BasePlayer,DataItem>();
		private Dictionary<string,DataItem> tmpdata = new Dictionary<string,DataItem>();
		private Event lastevent = null;
		private Event activeEvent = null;
		private double nextevent = 0;
		private float startevent = 300f;
		private float eventpause = 900f;

		private bool DEBUG = false;
		
		private Dictionary<string, Oxide.Plugins.Timer> EventTimer = new Dictionary<string, Oxide.Plugins.Timer>();
		
        private string SteamId(BasePlayer player)
        {
            return player.userID.ToString();
        }
	
        protected override void LoadDefaultConfig()
        {
            DefaultConfig();
        }

		private void DefaultConfig() {
			Config["lastevent"] = -1;
			SaveConfig();
		}
	
        void Loaded()
        {
            Puts("Events Botov-NET initialized.");
			if (DEBUG) {
				//startevent = 1f;
				foreach(Event ev in events) {
					ev.minplayers = 1;
					ev.time = 120f;
					ev.mincount = 1;
					ev.msgcount = 3;
					ev.msgtime = 20f;
				}
			}
			
			var i = 0;
			foreach(Event ev in events) {
				ev.ID = i;
				i++;
			}
			
			var lastCFG = ReadFromConfig<int>("lastevent");
			if (lastCFG!=null) {
				if(events.ElementAtOrDefault(lastCFG) != null) {
					lastevent = events[lastCFG];
				}
			}
			
			//EventDataFile = Interface.GetMod().DataFileSystem.GetDatafile(DataFileName);
			
			nextevent = CurrentTime()+startevent;
			EventTimer["event"] = timer.Once(startevent, () => RandomEvent());
        }
		
        [HookMethod("Unload")]
        void Unload()
        {
			if (EventTimer.Count>0) {
				foreach(KeyValuePair<string,Oxide.Plugins.Timer> kvp in EventTimer) {
					kvp.Value.Destroy();
				}
			}
			if (activeEvent!=null) {
				PrintToChat("<color=#dd0000>Ивент \""+activeEvent.name+"\" прерван из-за перезагрузки плагина.</color>");
				//FinishEvent();
			}
			if (lastevent!=null) {
				Config["lastevent"] = lastevent.ID;
				SaveConfig();
			}
        }
		
        [HookMethod("OnPlayerInit")]
        void OnPlayerInit(BasePlayer player)
        {
			var sid = SteamId(player);
			if (tmpdata.ContainsKey(sid)) {	
				eventdata[player] = tmpdata[sid];
				tmpdata.Remove(sid);
			}	
		}
		
        [HookMethod("OnPlayerDisconnected")]
        void OnPlayerDisconnected(BasePlayer player)
        {
			if (eventdata.ContainsKey(player)) {
				tmpdata[SteamId(player)] = eventdata[player];
				eventdata.Remove(player);
			}
		}
		
		private int GetPlayerCount() {
			return BasePlayer.activePlayerList.Count;
		}
		
		private void RandomEvent() {
			var eventstmp = new List<Event>();
			foreach(Event ev in events) {
				if (lastevent==ev && events.Count>1 || ev.minplayers>GetPlayerCount()) continue;
				eventstmp.Add(ev);
			}
			if (eventstmp.Count>0) { 
				var rnd = (int)Math.Round(UnityEngine.Random.Range(0f,eventstmp.Count-1f));
				StartEvent(eventstmp[rnd]);
			} else {
				nextevent = CurrentTime()+eventpause;
				EventTimer["event"] = timer.Once(eventpause, () => RandomEvent());
			}
		}
		
		private void StartEvent(Event Event) {
			activeEvent = Event;
			lastevent = activeEvent;
			var msgs = new List<string>();		
			msgs.Add("<size=35><color=#DD0000>⋙ ВНИМАНИЕ! ⋘</color></size>\n----------------\n<color=#00DD00><size=20>Ивент <color=#DD0000>\""+activeEvent.name+"\"</color> начался!</size></color>");
			Puts("Event "+activeEvent.ename+" started!");
			if (activeEvent.rndanimal.Count>0) {
				var rnda = (int)Math.Round(UnityEngine.Random.Range(0f,activeEvent.rndanimal.Count-1f));
				var keys = Enumerable.ToList(activeEvent.rndanimal.Keys);
				activeEvent.messages["start"] = activeEvent.messages["startr"].Replace("{replace}",activeEvent.rndanimal[keys[rnda]]);
				activeEvent.classes.Clear();
				activeEvent.classes.Add(keys[rnda]);
				Puts("Kill: "+keys[rnda]);
			}
			msgs.Add("<color=#ffb400><color=#00DD00>Задание:</color> "+activeEvent.messages["start"]);
			msgs.Add("<color=#00DD00>Условие:</color> "+activeEvent.messages["need"]);
			msgs.Add("<color=#00DD00>Время на выполнение ивента:</color> "+CalcTime(activeEvent.time)+".");//+activeEvent.messages["time"]);
			msgs.Add("<color=#00DD00>Награды:</color> "+activeEvent.messages["prises"]);
			msgs.Add("</color>----------------\n<color=#ffb400><color=#00DD00>Напишите <color=#DD0000>/event</color> чтобы узнать подробности.</color></color>");
			PrintToChat(string.Join("\n", msgs.ToArray()));
			nextevent = CurrentTime()+activeEvent.time;
			if (activeEvent.msgcount>0) EventTimer["msg"] = timer.Repeat(activeEvent.msgtime, activeEvent.msgcount, () => MsgEvent());
			EventTimer["event"] = timer.Once(activeEvent.time, () => FinishEvent());
		}
		
		private void MsgEvent() {
			if (activeEvent==null) return;
			var msgs = new List<string>();
			msgs.Add("<color=#00DD00><size=20>Ивент <color=#DD0000>\""+activeEvent.name+"\"</color>:</size></color>");
			msgs.Add("<color=#ffb400><color=#00DD00>Осталось времени:</color> "+CalcTime(nextevent-CurrentTime()));
			msgs.Add("<color=#00DD00>Задание:</color> "+activeEvent.messages["start"]);
			msgs.Add("<color=#00DD00>Условие:</color> "+activeEvent.messages["need"]);
			if (!activeEvent.one) {
				msgs.Add("\n<color=#00DD00>"+activeEvent.messages["timed"]+":</color>");
				var players = (from pair in eventdata orderby pair.Value.count descending, pair.Value.last ascending where pair.Value.count >= activeEvent.mincount select pair).Take(activeEvent.prises.Count).ToDictionary(pair => pair.Key, pair => pair.Value);
				var i = 1;
				var playerlist = new Dictionary<string,DataItem>();
				if (players.Count>0) {
					i = 1;
					foreach(KeyValuePair<BasePlayer,DataItem> kvp in players) {
						msgs.Add(i+". "+kvp.Key.displayName+" - "+kvp.Value.count+" "+activeEvent.messages["desc"]);
						i++;
					}
				} else {
					msgs.Add("На данный момент нет активных учасников.");
				}
			}
			msgs.Add("\n<color=#00DD00>Напишите <color=#DD0000>/event</color> чтобы узнать подробности.</color></color>");
			PrintToChat(string.Join("\n", msgs.ToArray()));
		}
		
		private void FinishEvent(bool cmd = false) {
			if (activeEvent==null) return;
			var msgs = new List<string>();
			msgs.Add("<color=#00DD00><size=20>Ивент <color=#DD0000>\""+activeEvent.name+"\"</color>"+(cmd?" преждевременно":"")+" завершён!</size></color>");
			Puts("Event "+activeEvent.ename+" finish!");
			if (activeEvent.one) {
				BasePlayer winner = null;
				var players = (from pair in eventdata orderby pair.Value.count descending, pair.Value.last ascending where pair.Value.count >= activeEvent.mincount select pair).Take(1).ToDictionary(pair => pair.Key, pair => pair.Value);
				if (players.Count>0) {
					winner = players.Keys.First();
					Puts("Winner: "+winner.displayName);
					msgs.Add("<color=#00DD00>Победитель: <color=#ffb400>"+winner.displayName+"</color>"+(activeEvent.air?" <color=#dd0000>[ Аирдроп ]</color>":""));
				} else {
					msgs.Add("<color=#ffb400>В ивенте никто не принял участие.");
				}
				PrintToChat(string.Join("\n", msgs.ToArray())+"</color>");
				if (winner!=null) {
					msgs.Clear();
					msgs.Add("<color=#00DD00>Позравляем! Вы стали победителем ивента <color=#DD0000>\""+activeEvent.name+"\"</color>.</color>");
					if (activeEvent.air) {
						msgs.Add("<color=#ffb400>На ваши координаты выслан <color=#DD0000>аирдроп</color>.</color>");
						var position = winner.transform.position;
						var dropPos = position.x.ToString() + " " + (position.y+700).ToString() + " " + position.z.ToString();
						ConsoleSystem.Run.Server.Normal("airdrop.topos " + dropPos);
					}
					winner.ChatMessage(string.Join("\n", msgs.ToArray()));
				}
			} else {
				msgs.Add("<color=#ffb400><color=#00DD00>"+activeEvent.messages["end"]+":</color>");
				var players = (from pair in eventdata orderby pair.Value.count descending, pair.Value.last ascending where pair.Value.count >= activeEvent.mincount select pair).Take(activeEvent.prises.Count).ToDictionary(pair => pair.Key, pair => pair.Value);
				//var playerlist = new Dictionary<string,int>();
				var i = 1;
				if (players.Count>0) {
					foreach(KeyValuePair<BasePlayer,DataItem> kvp in players) {
						msgs.Add(i+". "+kvp.Key.displayName+" - "+kvp.Value.count+" "+activeEvent.messages["desc"]+(activeEvent.air && i==1?" <color=#dd0000>[ Аирдроп ]</color>":""));
						Puts("#"+i+": "+kvp.Key.displayName+" - "+kvp.Value.count);
						i++;
					}
				} else {
					msgs.Add("В ивенте никто не принял участие.");
				}
				PrintToChat(string.Join("\n", msgs.ToArray())+"</color>");
				i = 1;
				foreach(KeyValuePair<BasePlayer,DataItem> kvp in players) {
					if (!activeEvent.prises.ContainsKey(i)) break;
					if (kvp.Value.count<activeEvent.mincount) continue;
					var player = kvp.Key;
					msgs.Clear();
					if (i==1) {
						msgs.Add("<color=#00DD00>Позравляем! Вы стали победителем ивента <color=#DD0000>\""+activeEvent.name+"\"</color>.</color>");
						msgs.Add("<color=#ffb400>Ваша награда уже начислена в инвентарь.</color>");
					} else {
						msgs.Add("<color=#00DD00>Позравляем! Вы заняли "+i.ToString()+" место в ивенте <color=#DD0000>\""+activeEvent.name+"\"</color>.</color>");
						msgs.Add("<color=#ffb400>Ваша награда уже начислена в инвентарь.</color>");				
					}
					if (activeEvent.air && i==1) {
						var position = player.transform.position;
						var dropPos = position.x.ToString() + " " + (position.y+700).ToString() + " " + position.z.ToString();
						ConsoleSystem.Run.Server.Normal("airdrop.topos " + dropPos);
						msgs.Add("<color=#ffb400>Также на ваши координаты выслан <color=#DD0000>аирдроп</color>.</color>");
					}
					player.ChatMessage(string.Join("\n", msgs.ToArray()));
					foreach(List<List<RndItem>> list in activeEvent.prises[i].Values) {
						var rnd = (int)Math.Round(UnityEngine.Random.Range(0f,list.Count-1f));
						foreach(RndItem item in list[rnd]) {
							var inv = player.inventory.containerMain;
							if (item.container=="wear") inv = player.inventory.containerWear;
							else if (item.container=="belt") inv = player.inventory.containerBelt;
							float amount = item.amount;
							if (item.mul) amount *= kvp.Value.count;
							var cond = 1f;
							//if (item.max>0) amount = UnityEngine.Random.Range(amount,(float)item.max);
							//if (item.cond) cond = UnityEngine.Random.Range(item.condmin,item.condmax);
							//Puts(amount.ToString()+" | "+item.name);
							if (amount>0f) GiveItem(player, item.name, (int)Math.Round(amount), inv, false, cond);
						}
					}
					i++;
				}
			}
			StopEvent();
		}
		
		private void StopEvent() {
			if (EventTimer.ContainsKey("msg")) { EventTimer["msg"].Destroy(); EventTimer.Remove("msg"); }
			if (EventTimer.ContainsKey("event")) { EventTimer["event"].Destroy(); }
			activeEvent = null;
			eventdata.Clear();
			tmpdata.Clear();
			//lastevent.last = CurrentTime();
			nextevent = CurrentTime()+eventpause;
			//lasteventtime = CurrentTime()+nextevent;
			EventTimer["event"] = timer.Once(eventpause, () => RandomEvent());
		}
		
		[ChatCommand("event")]
		void chatEvent(BasePlayer player, string command, string[] args) {
			var msgs = new List<string>();
			if (activeEvent==null) {
				msgs.Add("<color=#ffb400>На данный момент нет активных ивентов.\n<color=#00DD00>Следующий ивент через:</color> "+CalcTime(nextevent-CurrentTime())+".");
			} else {
				msgs.Add("<color=#00DD00><size=20>Ивент <color=#DD0000>\""+activeEvent.name+"\"</color>:</size></color>");
				msgs.Add("<color=#ffb400><color=#00DD00>Осталось времени:</color> "+CalcTime(nextevent-CurrentTime()));
				msgs.Add("<color=#00DD00>Задание:</color> "+activeEvent.messages["start"]);
				msgs.Add("<color=#00DD00>Условие:</color> "+activeEvent.messages["need"]);
				msgs.Add("<color=#00DD00>Награды:</color> "+activeEvent.messages["prises"]);
				if (!activeEvent.one) {
					player.ChatMessage(string.Join("\n", msgs.ToArray())+"</color>");
					msgs.Clear();
					msgs.Add("<color=#ffb400><color=#00DD00>"+activeEvent.messages["timed"]+":</color>");
					var players = (from pair in eventdata orderby pair.Value.count descending, pair.Value.last ascending where pair.Value.count >= activeEvent.mincount select pair).ToDictionary(pair => pair.Key, pair => pair.Value);//.Take(activeEvent.prises.Count).ToDictionary(pair => pair.Key, pair => pair.Value);
					var i = 1;
					var playerlist = new Dictionary<BasePlayer,int>();
					if (players.Count>0) {
						i = 1;
						foreach(KeyValuePair<BasePlayer,DataItem> kvp in players) {
							if (activeEvent.prises.ContainsKey(i)) {
								msgs.Add(i+". "+kvp.Key.displayName+" - "+kvp.Value.count+" "+activeEvent.messages["desc"]);
							}
							playerlist[kvp.Key] = i;
							i++;
						}
					} else {
						msgs.Add("На данный момент нет активных учасников.");
					}
					var plydata = (from pair in eventdata orderby pair.Value.count descending, pair.Value.last ascending where pair.Key == player select pair).ToDictionary(pair => pair.Key, pair => pair.Value);
					if (plydata.Count>0) msgs.Add("\n<color=#00DD00>Ваша позиция:</color> "+(playerlist.ContainsKey(player)?playerlist[player].ToString():activeEvent.messages["descn"])+" ("+plydata.First().Value.count+" "+activeEvent.messages["desc"]+").");
					else msgs.Add("\n<color=#00DD00>Ваша позиция:</color> вы не являетесь учасником ивента.");
				} else if (activeEvent.mincount>1) {
					msgs.Add("\n<color=#00DD00>"+activeEvent.messages["desc"]+"</color> "+(eventdata.ContainsKey(player)?eventdata[player].count:0));
				}
			}
			player.ChatMessage(string.Join("\n", msgs.ToArray())+"</color>");
		}
		
		private bool IsHumanOrAnimal(object ent, bool player = false, bool animal = false) {
			//Print(ent.ToString());
			if (ent!=null && (ent.ToString().Contains("player") && !animal || ent.ToString().Contains("animals") && !player) && !ent.ToString().Contains("corpse")) return true;
			return false;
		}
		
		private string get_animal(string entity) {
			var animal = entity.Split('/');
			return animal[animal.Length-1];
		}
		
		private void JoinEvent(BasePlayer player) {
			var msgs = new List<string>();
			msgs.Add("<color=#00DD00>Игрок <color=#ffb400>"+player.displayName+"</color> стал участиником ивента <color=#DD0000>\""+activeEvent.name+"\"</color>.</color>");
			PrintToChat(string.Join("\n", msgs.ToArray()));	
			msgs.Clear();
			msgs.Add("<color=#00DD00>Вы стали учасником ивента <color=#DD0000>\""+activeEvent.name+"\"</color>.</color>");
			msgs.Add("<color=#ffb400>Так как выполнили минимальные требования.</color>");
			if (activeEvent.prisesjoin.Count>0) {
				foreach(List<List<RndItem>> list in activeEvent.prisesjoin.Values) {
					var rnd = (int)Math.Round(UnityEngine.Random.Range(0f,list.Count-1f));
					foreach(RndItem item in list[rnd]) {
						var inv = player.inventory.containerMain;
						if (item.container=="wear") inv = player.inventory.containerWear;
						else if (item.container=="belt") inv = player.inventory.containerBelt;
						float amount = item.amount;
						var cond = 1f;
						//if (item.max>0) amount = UnityEngine.Random.Range(amount,(float)item.max);
						//if (item.cond) cond = UnityEngine.Random.Range(item.condmin,item.condmax);
						//Puts(amount.ToString()+" | "+item.name);
						if (amount>0f) GiveItem(player, item.name, (int)Math.Round(amount), inv, false, cond);
					}
				}
				msgs.Add("<color=#ffb400>Вам начислен небольшой бонус за участие.</color>");
			}
			msgs.Add("<color=#00DD00>Напишите <color=#DD0000>/event</color> чтобы узнать подробности.</color>");
			player.ChatMessage(string.Join("\n", msgs.ToArray()));					
		}
		
        [HookMethod("OnEntityDeath")]
        void OnEntityDeath(BaseCombatEntity entity, HitInfo hitInfo)
        {	
			if (activeEvent==null) return;
			if ((IsHumanOrAnimal(entity) || entity.ToString().Contains("barrel")) && IsHumanOrAnimal(hitInfo.Initiator,true)) {
				var sid = hitInfo.Initiator as BasePlayer; //SteamId(hitInfo.Initiator as BasePlayer);
				if (activeEvent.weapons.Count>0 && (hitInfo.Weapon==null || !activeEvent.weapons.Exists(e => e.EndsWith((hitInfo.Weapon as HeldEntity).GetItem().info.shortname)))) return;
				if (activeEvent.type==1 && entity.ToPlayer() && (!activeEvent.nosleep || !(entity as BasePlayer).IsSleeping())) {
					var count = (eventdata.ContainsKey(sid)?eventdata[sid].count+1:1);
					if (!eventdata.ContainsKey(sid)) eventdata[sid] = new DataItem();
					eventdata[sid].count = count;
					eventdata[sid].last = CurrentTime();
					if (!activeEvent.one && count==activeEvent.mincount) JoinEvent(sid);
					if (activeEvent.one) FinishEvent();
				} else if (activeEvent.type==0 && !entity.ToPlayer()) {
					if (activeEvent.animals || activeEvent.classes.Exists(e => e.EndsWith(get_animal(entity.LookupPrefabName().ToString())))) {
						var count = (eventdata.ContainsKey(sid)?eventdata[sid].count+1:1);
						if (!eventdata.ContainsKey(sid)) eventdata[sid] = new DataItem();
						eventdata[sid].count = count;
						eventdata[sid].last = CurrentTime();
						if (!activeEvent.one && count==activeEvent.mincount) JoinEvent(sid);
						if (activeEvent.one) FinishEvent();
					}
				} else if (activeEvent.type==2 && entity.ToString().Contains("barrel")) {
					var count = (eventdata.ContainsKey(sid)?eventdata[sid].count+1:1);
					if (!eventdata.ContainsKey(sid)) eventdata[sid] = new DataItem();
					eventdata[sid].count = count;
					eventdata[sid].last = CurrentTime();
					if (!activeEvent.one && count==activeEvent.mincount) JoinEvent(sid);
					if (activeEvent.one && count==activeEvent.mincount) FinishEvent();
				}
			}
		}
		
        [ConsoleCommand("event.status")]
        void cmdEventStatus(ConsoleSystem.Arg arg) {
			if (!arg.CheckPermissions()) return;
			if (activeEvent==null) { 
				Puts("No active event."); 
				Puts("Time to next: "+CalcTime(nextevent-CurrentTime(),true)); 
				return; 
			}
			var players = (from pair in eventdata orderby pair.Value.count descending, pair.Value.last ascending select pair).ToDictionary(pair => pair.Key, pair => pair.Value);
			var i = 1;
			Puts("Active event: "+activeEvent.ename);
			Puts("Time to end: "+CalcTime(nextevent-CurrentTime(),true));
			if (activeEvent.one) {
				Puts("Kill: "+activeEvent.classes.First());
			} else {
				if (activeEvent.rndanimal.Count>0) Puts("Kill: "+activeEvent.classes.First());
				Puts("Min value: "+activeEvent.mincount);
				if (players.Count==0) { Puts("No active players."); return; }
				foreach(KeyValuePair<BasePlayer,DataItem> kvp in players) {
					Puts("#"+i+" "+kvp.Key.displayName+" - "+kvp.Value.count);
					i++;
				}
			}
		}
		
        [ConsoleCommand("event.stop")]
        void cmdEventStop(ConsoleSystem.Arg arg) {
			if (!arg.CheckPermissions()) return;
			if (activeEvent==null) { Puts("No active event."); return; }
			PrintToChat("<color=#dd0000>Ивент \""+activeEvent.name+"\" прерван администрацией.</color>");
			Puts("Event "+activeEvent.ename+" stopped.");
			StopEvent();
		}
		
        [ConsoleCommand("event.finish")]
        void cmdEventFinish(ConsoleSystem.Arg arg) {
			if (!arg.CheckPermissions()) return;
			if (activeEvent==null) { Puts("No active event."); return; }
			FinishEvent(true);
		}
		
        [ConsoleCommand("event.on")]
        void cmdEventStart(ConsoleSystem.Arg arg) {
			if (!arg.CheckPermissions()) return;
			if (activeEvent!=null) { Puts("Already active event: "+activeEvent.ename); return; }
			Event Event = null;
			if (arg.Args != null && arg.Args.Length > 0) {
				var id = Convert.ToInt32(arg.Args[0]);
				if(events.ElementAtOrDefault(id) != null) {
					Event = events[id];
				} else { 
					Puts("Event ID #"+id+" is invalid!"); return; 
				}
			}
			if (Event==null) Event = events[(int)Math.Round(UnityEngine.Random.Range(0f,events.Count-1f))];
			if (Event!=null) {
				if (EventTimer.ContainsKey("event")) { EventTimer["event"].Destroy(); EventTimer.Remove("event"); }
				StartEvent(Event);
				//Puts("Event "+Event.ename+" started!");
			} else Puts("Error start event!");
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
		
    }
   
}