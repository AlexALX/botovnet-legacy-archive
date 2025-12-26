# -*- coding: utf8 -*-
# File created by AlexALX (c) 2014 http://alex-php.net/

# WotKIEB.py
# Source code of modpack update checker for World of Tanks (2014)
# Author: AlexALX
# License: For reference / educational purposes only
# This script will not work with current game versions

# World of Tanks mods are subject to Wargaming’s End User License Agreement (EULA).  
# Only mods that do not provide unfair advantages or are expressly permitted by Wargaming (e.g., via the official Mod Hub) are considered safe to use.  
# These files are historical references and may not comply with current policies; use at your own risk.

import BigWorld
from gui import SystemMessages
from Account import Account

import re
import urllib
import os

xvm_exists = True

try:
    from xpm import log
except ImportError, e:
    xvm_exists = False

def CheckVersion(version1, version2):
    def normalize(v):
        return [int(x) for x in re.sub(r'(\.0+)*$','', v).split(".")]
    return cmp(normalize(version1), normalize(version2))

link = Account.onBecomePlayer

def _onBecomePlayer(self):
    link(self)
    type = SystemMessages.SM_TYPE.GameGreeting

    cur_ver = '0'
    cur_ver_txt = '0'
    ver_txt = "ERROR"
    try:
        fver = open('wot_[-KIEB]_ver.txt','r')
        try:
            cur_ver_txt = fver.read()
            ver_txt = cur_ver_txt.replace("b"," <font color='#FF0000'>BETA</font>")
            cur_ver = re.sub('[^0-9.]+', '', cur_ver_txt)
            if (cur_ver=='' or len(cur_ver)>15):
                cur_ver = '0'
                ver_txt = "ERROR"
                cur_ver_txt = '0'
        except:
            cur_ver = '0'
            cur_ver_txt = '0'
            ver_txt = "ERROR"
        finally:
            fver.close()
    except:
        pass
    # GameGreeting Information Error Warning  
    msg = ""
    col = "#FFC000"
    if (ver_txt=="ERROR"):
        type = SystemMessages.SM_TYPE.Warning
        msg += "<font color='#FF0000'>Ошибка определения версии сборки.</font><br>"
        col = "#FF0000"

    update = False
    last_ver = '0'
    last_txt = ""

    req = "http://yoursite.local/patch/ver.txt"
    try:
        resp = urllib.urlopen(req)
    except:
        type = SystemMessages.SM_TYPE.Warning
        msg += "<font color='#FF0000'>Ошибка определения последней версии.</font><br><br>"
    else:
        last_ver = resp.read()
        last_txt = last_ver.replace("b"," <font color='#FF0000'>BETA</font>")
        last_ver = re.sub('[^0-9.]+', '', last_ver)
        if (last_ver=='' or len(last_ver)>15):
            last_ver = '0'
            last_txt = ""
            type = SystemMessages.SM_TYPE.Warning
            msg += "<font color='#FF0000'>Ошибка определения последней версии.</font><br><br>"

    if (last_ver!='0' and CheckVersion(last_ver,cur_ver)>0):
        update = True

    if (msg!=""):
        msg += "<br>"

    if (update==True and cur_ver!='0'):
        type = SystemMessages.SM_TYPE.Warning
        col = "#FF0000"

    if (update==True):
        if (cur_ver=='0'):
            msg += "Последняя версия: <font color='#00FF00'><b>v" + last_txt + "</b></font>"
        else:
            msg += "<font color='#FF0000' size='16'>Ваша версия сборки устарела!</font><br><br>"
            msg += "Доступна новая версия: <font color='#00FF00'><b>v" + last_txt + "</b></font>"
    else:
        if (last_ver!='0'):
            msg += "<font color='#00FF00' size='16'>У вас последняя версия сборки.</font>"
        
    msg += "<br><br><img src='img://gui/flash/icons/-KIEB_16.png' vspace='-3'> <b>[-KIEB]</b> Сборка модов <font color='" + col + "'><b>v" + ver_txt + "</b></font>"

    if (xvm_exists==True):
        if (update==True):
            msg += "<br><br><a href='event:http://yoursite.local/'>Перейти на форум</a>"
        else:
            msg += "<br><br><a href='event:http://yoursite.local/'>Посетить наш форум</a>"
    
    SystemMessages.pushMessage(msg, type)

    if (os.path.isfile('wot_[-KIEB]_log.txt')):
        fsend = open('wot_[-KIEB]_log.txt','r')
        rem = False
        try:
            send = fsend.read()
            req = "http://yoursite.local/patch/check.php"
            try:
                resp = urllib.urlopen(req, "ver=" + cur_ver_txt + "&name=" + BigWorld.player().name + "&" + send)
            except:
                pass
            else:
                if (resp.read()=="OK"):
                    rem = True
        except:
            pass
        finally:
            fsend.close()
            if (rem==True):
                os.remove('wot_[-KIEB]_log.txt')
    
    Account.onBecomePlayer = link

Account.onBecomePlayer = _onBecomePlayer
