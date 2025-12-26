/*

This plugin used with website online shop based on php-fusion custom plugin
Allowed to buy items and pay on website then receive in-game
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

// Reference: Newtonsoft.Json
using System.Collections.Generic;
using System.Linq;
using Oxide.Core;
using Oxide.Core.Plugins;
using Oxide.Core.Configuration;
using Oxide.Ext.MySql;
using Oxide.Ext.MySql.Libraries;
using Oxide.Plugins;
using UnityEngine;
using System;
using Newtonsoft.Json;

namespace Oxide.Plugins
{
    [Info("Online Shop System", "AlexALX", "0.0.1")]
    public class RustOnlineShop : RustPlugin
    {
	
		private const string DB_SHOP = "fusion_game_shop_pays";
		private const string DB_SETTINGS = "fusion_game_vip_set";
		private Connection db;
		private Ext.MySql.Libraries.MySql mysql = Interface.Oxide.GetLibrary<Ext.MySql.Libraries.MySql>("MySql");
		
		private bool shop_enabled = false;
		private int server = 0;
		
		private List<string> ignorestack = new List<string>(){"wood","stones","sulfur","metal_fragments","cloth","fat_animal","bone_fragments"};
		
		private Dictionary<string,string> classnames = new Dictionary<string,string>();
		
        void Loaded() 
        {
			var serverCFG = ReadFromConfig<int>("server");
			if (serverCFG!=null&&serverCFG>0) server = serverCFG;
			
			db = mysql.OpenDb("localhost", 3306, "dbname", "dbuser", "dbpass"); 
			SQL_Settings();
        }
		
		void OnServerInitialized() {
			InitializeTable();
		}
		
        private void InitializeTable()
        {
            classnames.Clear();
            List<ItemDefinition> ItemsDefinition = ItemManager.GetItemDefinitions() as List<ItemDefinition>;
            foreach(ItemDefinition itemdef in ItemsDefinition)
            {
                classnames.Add(itemdef.shortname.ToString(), itemdef.displayName.english.ToString());
            }
        }
		
        protected override void LoadDefaultConfig()
        {
            Config["server"] = 0; 
			SaveConfig();
        }
		
        public T ReadFromConfig<T>(string configKey)
        {
            string serializeObject = JsonConvert.SerializeObject(Config[configKey]);
            return JsonConvert.DeserializeObject<T>(serializeObject);
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
		
		private void NonQuery(string sqlquery) {
			Sql sql = mysql.NewSql();
			sql.Append(sqlquery);
			mysql.ExecuteNonQuery(sql,db);
		}
		
		private void SQL_Settings() {
			var settings = Query("SELECT * FROM "+DB_SETTINGS).First();
			if (settings==null||settings.Count==0) return;
			var enabled = Convert.ToInt32(settings["enabled"]);
			if (enabled>0) enabled = Convert.ToInt32(settings["shop_enabled"]);

			if (enabled==0 || server==0) {
				shop_enabled = false;
			} else {
				shop_enabled = true;
			}
		}
		
        private string SteamId(BasePlayer player)
        {
            return player.userID.ToString();
        }
		
        private void ChatMessage(BasePlayer player, string message)
        {
            player.ChatMessage(message);
        }
		
		[ChatCommand("bshop")]
		void cmdChatShop(BasePlayer player, string command, string[] args) {
			if (!shop_enabled) {
				ChatMessage(player,"<color=#DD0000>Система онлайн магазина временно отключена.</color>"); return;
			}
			var chatmsg = new List<string>();
			var result = Query("SELECT * FROM "+DB_SHOP+" WHERE server='"+server+"' AND sid='"+SteamId(player)+"'");
			
			if (result.Count>0) {
				var addmsg = "";
				if (args.Length>0) {
					if (args[0]=="get") {
						var cur = player.inventory.containerMain.itemList.Count+player.inventory.containerBelt.itemList.Count;
						var total = player.inventory.containerMain.capacity+player.inventory.containerBelt.capacity;
						if (cur>=total) { ChatMessage(player,"<color=#DD0000>Невозможно выдать предметы - ваш инвентарь полностью занят.</color>"); return; }
						chatmsg.Add("Следующие предметы были зачислены:");
						var inv = player.inventory.containerMain;
						var added = new Dictionary<string, Dictionary<string,object>>();
						var breaked = false;
						foreach(Dictionary<string, object> list in result) {
							var isBP = Convert.ToInt32(list["bp"]);
							var amount = Convert.ToInt32(list["amount"]);
							var res = (string)list["res"];
							var gived = GiveItem(player, res, amount, inv, (isBP==1?true:false));
							if (gived==0) { breaked = true; break; }
							else if (gived==-1) { ChatMessage(player,"<color=#DD0000>Ошибка выдачи предмета: "+res+"</color>\nОбратитесь к администратору за помощью на сайте."); Puts("Error, item not found: "+res); continue; }
							if (addmsg!="") addmsg += ", ";
							var restxt = res;
							if (classnames.ContainsKey(restxt)) restxt = classnames[restxt];
							addmsg += restxt+(isBP==1?" BP":"")+" - "+gived;
							/*added[res] = new Dictionary<string,object>{
								["amount"] = amount,
								["gived"] = gived,
								["hash"] = (string)list["hash"],
							};*/
							if (amount!=gived) {
								breaked = true; 
								NonQuery("UPDATE "+DB_SHOP+" SET amount=amount-"+gived+" WHERE hash='"+list["hash"]+"'");
							} else {
								NonQuery("DELETE FROM "+DB_SHOP+" WHERE hash='"+list["hash"]+"'");
							}
						}
						/*foreach(KeyValuePair<string, Dictionary<string,object>> kvp in added) {
							var amount = (int)kvp.Value["amount"];
							var gived = (int)kvp.Value["gived"];
							var hash = (string)kvp.Value["hash"];
							if (amount==gived) {
								// remove
							} else {
								var calc = amount-gived;
								// update
							}
						}*/
						chatmsg.Add(addmsg);
						if (breaked) {
							chatmsg.Add("\nНекоторые ресурсы не были выданы, недостаточно места в инвентаре! Вы можете забрать их позже повторно использовав данную команду.");
						}
						Puts(SteamId(player)+" "+player.displayName+" bshop get:");
						if (addmsg!="") {
							Puts("Gived: "+addmsg);
							ChatMessage(player, string.Join("\n", chatmsg.ToArray()));
						}
					} else {
						ChatMessage(player,"<color=#DD0000>Не верный параметр.</color>");
					}
					return;
				}		
			
				chatmsg.Add("Предметы которые вы можете получить:");
				foreach(Dictionary<string, object> list in result) {
					if (addmsg!="") addmsg += ", ";
					var res = list["res"] as string;
					if (classnames.ContainsKey(res)) res = classnames[res];
					else res = "<color=#DD0000>"+res+"</color>";
					addmsg += res+" - "+list["amount"];
				}
				chatmsg.Add(addmsg);
				chatmsg.Add("\nИспользуйте команду <color=#00DD00>/bshop get</color> для получения предметов.");
				chatmsg.Add("При использовании данной команды купленые предметы будут начислены в ваш инвентарь.");
				chatmsg.Add("Если места в инвентаре недостаточно - выдаст лишь часть предметов, остальное вы сможете забрать позже.");
			} else {
				chatmsg.Add("У вас нет купленых предметов для получения.");
				chatmsg.Add("\nДля покупки предметов необходимо:");
				chatmsg.Add("1. Зарегестрироваться на сайте <color=#DD0000>botov.net.ua</color>.");
				chatmsg.Add("2. Зайти в личный кабинет, выбрать раздел <color=#ffb400>Онлайн магазин</color>.");
				chatmsg.Add("3. Выбрать сервер и предмет, нажать кнопку <color=#ffb400>Купить</color>.");
				chatmsg.Add("4. Оплатить заказ (через webmoney).");
				chatmsg.Add("5. После устешной оплаты прописать <color=#00DD00>/bshop get</color> для получения предметов.");
				chatmsg.Add("\nВозможна покупка сразу несколько (по очереди) предметов, позже их можно забрать используя команду выше.");
			}
			
			ChatMessage(player, string.Join("\n", chatmsg.ToArray()));
		}

		[ConsoleCommand("bshop_update")]
		void cmdList(ConsoleSystem.Arg arg) {
			if (!arg.CheckPermissions()) return;
			
            Puts("Hello");
		}
		
        public int GiveItem(BasePlayer player, string itemname, int amount, ItemContainer pref, bool isBP = false)
        {
            itemname = itemname.ToLower();
            if (amount < 1) amount = 1;
            var definition = ItemManager.FindItemDefinition(itemname);
            if (definition == null)
                return -1; //string.Format("{0} {1}","not found",itemname);
            int giveamount = 0;
            int stack = (int)definition.stackable;
			var Stackable = ignorestack.Exists(e => e.EndsWith(itemname));
            if (stack < 1) stack = 1;
            if (isBP)
            {
                stack = 1;
            }
            if (Stackable && !isBP)
            {
				var cur = player.inventory.containerMain.itemList.Count+player.inventory.containerBelt.itemList.Count;
				var total = player.inventory.containerMain.capacity+player.inventory.containerBelt.capacity;
				
				if (cur>=total) return 0;
				
                player.inventory.GiveItem(ItemManager.CreateByItemID((int)definition.itemid, amount, isBP), pref);
				return amount;
                //SendReply(player, string.Format("You've received {0} x {1}", description, amount.ToString()));
            }
            else
            {
				var cur = player.inventory.containerMain.itemList.Count+player.inventory.containerBelt.itemList.Count;
				var total = player.inventory.containerMain.capacity+player.inventory.containerBelt.capacity;
				var gived = 0;
				
				if (cur>=total) return 0;
			
                for (var i = amount; i > 0; i = i - stack)
                {
                    if (i >= stack)
                        giveamount = stack;
                    else
                        giveamount = i;
                    if (giveamount < 1) return amount;
					if (cur>=total) return gived;
                    player.inventory.GiveItem(ItemManager.CreateByItemID((int)definition.itemid, giveamount, isBP), pref);
					gived += giveamount;
					cur++;
                    //SendReply(player, string.Format("You've received {0} x {1}", description, giveamount.ToString()));
                }
				return gived;
            }
            return 0;
        }
	
	}
	
}