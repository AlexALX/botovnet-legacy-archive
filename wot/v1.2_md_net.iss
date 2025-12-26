; Custom mod installer for World of Tanks (2014)
; Author: AlexALX
; License: MIT License
; -----------------------------------------------------------------------------
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this script and associated files, to deal in the script without restriction,
; including without limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the script, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the script.
;
; THE SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
; INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
; PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
; SCRIPT OR THE USE OR OTHER DEALINGS IN THE SCRIPT.
; -----------------------------------------------------------------------------

#include "SHFileOperation.iss"  

#define MyAppVer "1.6.23"
#define WotVer "0.9.7"
#define XVM "6.1.0-dev"

#define ZonsVer "73"

#pragma include __INCLUDE__ + ";" + ReadReg(HKLM, "Software\Mitrich Software\Inno Download Plugin", "InstallDir")

#define records

//#define SecondProgressBar

//#define IsSkin
//#define SkinBackground

//#define ALPHA "true"
#define BETA "true"


[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{DECE0B8C-F719-4B2F-80EF-20E0B393CB3A}
AppName=Моды для World of Tanks v{#WotVer}
AppVersion={#MyAppVer}
;AppVerName=Counter-Strike 1.6 1.0
AppPublisher=AlexALX
AppPublisherURL=http://yoursite.local/
AppSupportURL=http://yoursite.local/
AppUpdatesURL=http://yoursite.local/
DefaultDirName={pf}\World_of_Tanks
AppendDefaultDirName=no 
AppendDefaultGroupName=no
AllowNoIcons=yes
SourceDir=O:\Downloads\Games\WoT\mods_install
OutputDir=O:\Downloads\Games\WoT\mods_install\out
OutputBaseFilename=[-KIEB]_WOT_{#WotVer}_v{#MyAppVer}
;Compression=lzma2/normal
Compression=lzma2/ultra64
InternalCompressLevel=ultra64
;Compression=none
SolidCompression=yes
;DiskSpanning=yes          
SetupIconFile=O:\Downloads\Games\WoT\mods_install\KUEB.ico
UninstallDisplayIcon=O:\Downloads\Games\WoT\mods_install\KUEB.ico
VersionInfoVersion={#MyAppVer}.48
;Uninstallable=no
DirExistsWarning=no
AllowCancelDuringInstall=no 
DisableProgramGroupPage=yes
WizardImageFile=01.bmp
;WizModernImage-Wot.bmp
;01.bmp
WizardSmallImageFile=02.bmp
RestartApplications=false

#include <idp.iss>
#include <idplang\russian.iss>
#ifdef SkinBackground
#include "include\PicEX.iss"
#endif

[Languages]
;#ifdef BETA
;Name: russian; MessagesFile: "compiler:Languages\Russian.isl"; LicenseFile: "lic-ru.rtf"; InfoBeforeFile: "before-ru_beta.rtf"; InfoAfterFile: "after-ru.rtf";
;#else
Name: russian; MessagesFile: "compiler:Languages\Russian.isl"; LicenseFile: "lic-ru.rtf"; InfoBeforeFile: "before-ru.rtf"; InfoAfterFile: "after-ru.rtf";
;#endif
         
[Messages]   
russian.BeveledLabel=© 2013-2015 by http://yoursite.local/

[CustomMessages]
russian.ExtractedFile=Извлекается файл:
russian.Extracted=Распаковка архивов...
russian.CancelButton=Отменить распаковку
russian.Error=Ошибка распаковки!
russian.ElapsedTime=Прошло:
russian.RemainingTime=Осталось времени:
russian.EstimatedTime=Всего:
russian.AllElapsedTime=Время установки:
russian.Backup=Создание резервной копии

[Tasks]
Name: src; Description: "Создать резервную копию оригинальных файлов (модов)"; Flags: unchecked
Name: del; Description: "Очистить директорию с модами";
;Name: none; Description: "Ничего не делать"; Flags: unchecked exclusive 
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";
;Name: dokan_rm; Description: "Удалить Dokan (больше не требуется для XVM-Stat)"; Flags: checkedonce;

[Types]
Name: "default"; Description: "Стандартная установка";
;Name: "recommend"; Description: "Вариант от AlexALX"
Name: "custom"; Description: "Выборочная установка"; Flags: iscustom

[Components]
Name: "xvm"; Description: "XVM v{#XVM}"; Types: default; Flags: checkablealone;
Name: "xvm\lamp"; Description: "Заменить лампочку на знак восклицания с надписью ""Танк Обнаружен"" (шестое чувство)"; Types: default 
Name: "xvm\lamp_audio"; Description: "Воспроизводить гудок при засвете (шестое чувство)"; Types: default
Name: "xvm\stat"; Description: "Включить статистику игроков в бою (необходима активация на modxvm.com)"; Flags: disablenouninstallwarning checkablealone; Types: default
Name: "xvm\stat\panel"; Description: "Включить отображение статистики в ушах"; Flags: disablenouninstallwarning dontinheritcheck;
;Name: "xvm\markeru"; Description: "Показывать щит и маркер фокуса если осталось менее 30% здоровья"; Flags: disablenouninstallwarning; Types: default custom
;Name: "xvm\stat\always"; Description: "Всегда показывать процент побед у игрока (без нажатия на alt)"; Types: default
Name: "xvm\map"; Description: "Миникарта с названием техники и радиусом обзора"; Types: default; Flags: checkablealone;
;Name: "xvm\map\def"; Description: "Стандартный вариант"; Flags: exclusive; Types: default
;Name: "xvm\map\line"; Description: "Показывать линии до конца карты"; Flags: exclusive; Types: default
Name: "xvm\map\cube"; Description: "Показывать квадрат максимальной отрисовки техники"; Flags: disablenouninstallwarning; Types: default
Name: "xvm\map\size"; Description: "Увеличивать мини-карту через crtl на весь экран"; Flags: disablenouninstallwarning dontinheritcheck;
Name: "xvm\load"; Description: "Отключить вступительный ролик World Of Tanks при загрузке"; Flags: disablenouninstallwarning; Types: default
Name: "xvm\save"; Description: "Сохранять последний сервер при заходе в игру"; Types: default
Name: "xvm\clock"; Description: "Часы в ангаре"; Flags: disablenouninstallwarning; Types: default
Name: "xvm\login"; Description: "Автоматический вход в игру (если сохранён пароль)"; Flags: disablenouninstallwarning;
Name: "xvm\angar"; Description: "Несколько рядов танков в ангаре"; Flags: disablenouninstallwarning;
Name: "xvm\angar\two"; Description: "в 2 ряда"; Flags: exclusive disablenouninstallwarning;
Name: "xvm\angar\three"; Description: "в 3 ряда"; Flags: exclusive disablenouninstallwarning;
Name: "xvm\totalhp"; Description: "Панель с общим здоровьем команд в бою";
Name: "xvm\hp"; Description: "Показывать здоровье танков команды в ушах (может снизить fps)"; Flags: disablenouninstallwarning;
Name: "xvm\hp\v2"; Description: "пропорциональные"; Flags: exclusive disablenouninstallwarning;
Name: "xvm\hp\v1"; Description: "однородные"; Flags: exclusive disablenouninstallwarning;
;Name: "cross"; Description: "Прицелы"; Types: default
;Name: "cross\def"; Description: "Стандартные прицелы с временем перезарядки/полёта снаряда (для арт-сау)"; Flags: exclusive; Types: default 
;Name: "cross"; Description: "Minimalistic Sights - прицел включает время полёта снарядов арт-сау и толщину брони в прицеле"; Types: default
Name: "ugn"; Description: "Углы горизонтальной наводки для пт и арт-сау"; Types: default
;Name: "damage\default"; Description: "Стандартная"; Flags: exclusive;
;Name: "damage\jove"; Description: "Улучшеная от Jove (визуально)"; Flags: exclusive; Types: default
Name: "damage"; Description: "Дамаг панель с индикацией полученого урона/временем починки модулей"; Types: default; Flags: checkablealone;
Name: "damage\sound"; Description: "Включить звуковое оповещение о пожаре и повреждении боеукладки"; Types: default
Name: "dmdind"; Description: "Дамаг индикатор с направлением выстрела"; Types: default
Name: "stat"; Description: "Суммарная статистика за день + результат боя в чат"; Types: default; Flags: checkablealone;
Name: "stat\kom"; Description: "Не учитывать укреп/командные бои"; Flags: dontinheritcheck;
;Name: "dead_w"; Description: "Белые трупы танков"; Types: default
Name: "zons"; Description: "Цветные шкурки с зонами пробития"; Types: default
;Name: "zons\white"; Description: "Белые иконочные (контурные)"; Flags: exclusive;
;Name: "zons\color"; Description: "Цветные (штриховка)"; Flags: exclusive; Types: default
;Name: "autofire"; Description: "Авто-стрельба c зажатой кнопкой мышки"; Types: default 
Name: "texts"; Description: "Расширенные подсказки с навыками и умениями"; Types: default 
Name: "tuman"; Description: "Увеличение дальности видимости на всех картах"; Types: default                                             
Name: "safe"; Description: "Блокировка выстрела по союзникам и трупам сразу после уничтожения"; Types: default; Flags: checkablealone;
;Name: "safe\dead"; Description: "Блокировка выстрела только по трупам (для режима Зимняя битва)"; Flags: disablenouninstallwarning;
Name: "zasvet"; Description: "Уведомление союзников о засвете"; Types: default
;Name: "angar"; Description: "Несколько рядов танков в ангаре с настройками прямо в игре";
Name: "color_pr"; Description: "Цветные места пробитий";
Name: "vagonu"; Description: "Отдельный вид для каждого типа вагонов";
Name: "art_camera"; Description: "Улучшенный вид камеры в арт прицеле (нажмите G в арт прицеле)"; Types: default
;Name: "reload"; Description: "Оставшееся время перезарядки в чат"; Types: default 
Name: "pmod"; Description: "PMod - пакет с пряниками"; Types: default
Name: "pmod\replay"; Description: "Свободная камера в реплеях (нажать F3)"; Types: default
Name: "pmod\spawn"; Description: "Показывать позицию респавна во время загрузки боя вместо подсказки"; Types: default
Name: "pmod\rm_black"; Description: "Отключить затемнение в снайперском прицеле"; Types: default
Name: "pmod\zoom"; Description: "Максимальное отдаление камеры (zoom-мод)"; Types: default;
Name: "pmod\nd"; Description: "Отключить дрожание динамической камеры"; Flags: disablenouninstallwarning; Types: default
Name: "pmod\ns"; Description: "Отключить смену режима прицела колесиком мышки";
Name: "pmod\zoomx"; Description: "Увеличить приближение в снайперском прицеле"; Types: default;
Name: "pmod\zoomx\16"; Description: "4-позиционный, добавлено x16 приближение"; Flags: exclusive disablenouninstallwarning;
Name: "pmod\zoomx\30"; Description: "5-позиционный, добавлено x16 и x30 приближение"; Flags: exclusive disablenouninstallwarning; Types: default
Name: "pmod\lamp_timer"; Description: "10 секундная задержка отображения лампочки";

[InstallDelete]
;Type: filesandordirs; Name: "{app}\res_mods\{#WotVer}\*"; Tasks: del;
;Type: filesandordirs; Name: "{app}\res_mods\xvm\*"; Tasks: del;
Type: filesandordirs; Name: "{app}\xvm-stat.exe";
Type: filesandordirs; Name: "{app}\xvm-stat.exe.config";
Type: filesandordirs; Name: "{app}\World of Tanks (stat).lnk"
Type: filesandordirs; Name: "{commondesktop}\World of Tanks (stat).lnk"
;Type: filesandordirs; Name: "{app}\res_mods\{#WotVer}\scripts\client\gui\Scaleform\daapi\view\meta"; Components: angar;

[UninstallDelete]
Type: files; Name: "{app}\wot_[-KIEB]_log.txt"
Type: files; Name: "{app}\wot_[-KIEB]_ver.txt"
Type: files; Name: "{app}\tokens.xdb.tmp"
Type: filesandordirs; Name: "{app}\res_mods\{#WotVer}\vehicles"; Components: zons;

[Files]
Source: "{app}\res_mods\{#WotVer}\*"; DestDir: "{app}\backup_mods\last\res_mods\{#WotVer}"; Tasks: del and src; Flags: external ignoreversion skipifsourcedoesntexist createallsubdirs recursesubdirs uninsneveruninstall; AfterInstall: CleanupDirectory('{app}\res_mods\{#WotVer}\*')
Source: "{app}\res_mods\configs\xvm\*"; DestDir: "{app}\backup_mods\last\res_mods\configs\xvm"; Tasks: del and src; Flags: external ignoreversion skipifsourcedoesntexist createallsubdirs recursesubdirs uninsneveruninstall; AfterInstall: CleanupDirectory('{app}\res_mods\configs\xvm\*')
Source: "{app}\res_mods\mods\*"; DestDir: "{app}\backup_mods\last\res_mods\mods"; Tasks: del and src; Flags: external ignoreversion skipifsourcedoesntexist createallsubdirs recursesubdirs uninsneveruninstall; AfterInstall: CleanupDirectory('{app}\res_mods\mods\*')

Source: "{app}\res\text\LC_MESSAGES\*"; DestDir: "{app}\res_mods\{#WotVer}\text\LC_MESSAGES"; Components: texts; Flags: external ignoreversion skipifsourcedoesntexist onlyifdoesntexist;
Source: "{app}\res\audio\*"; DestDir: "{app}\res_mods\{#WotVer}\audio"; Components: xvm\lamp_audio damage\sound; Flags: external ignoreversion skipifsourcedoesntexist onlyifdoesntexist;

Source: "O:\Downloads\Games\WoT\mods_install\files\xvm\*"; Components: xvm; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\xvm-lamp\*"; Components: xvm\lamp; DestDir: "{app}\res_mods\mods\shared_resources\xvm\res\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\lamp-audio\*"; Components: xvm\lamp_audio; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\xvm-stat\*"; Components: xvm\stat; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\minimap\*"; Components: xvm\map; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\xvm-alw\*"; Components: xvm\stat\always; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\cross\*"; Components: cross\def; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\cross_ms\*"; Components: cross; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\ugn\*"; Components: ugn; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\damage\*"; Components: damage; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\damage-sound\*"; Components: damage\sound; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\dmg_ind\*"; Components: dmdind; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\damage_jove\*"; Components: damage\jove; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\stat\*"; Components: stat; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\rm_black\*"; Components: rm_black; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\clock\*"; Components: clock; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly;
;Source: "O:\Downloads\Games\WoT\mods_install\files\dead_w\*"; Components: dead_w; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly;
;Source: "O:\Downloads\Games\WoT\mods_install\files\zoom\*"; Components: zoom; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\zoom_nd\*"; Components: zoom\nd; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\zoom_ns\*"; Components: zoom\ns; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\zoom_x\*"; Components: zoomx; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\zons_white\*"; Components: zons\white; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\zons_color\*"; Components: zons; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\DokanInstall_0.6.0.exe"; Tasks: dokan; DestDir: "{app}"; Flags: deleteafterinstall ignoreversion overwritereadonly;
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
;Source: "century-gothic-bold.ttf"; DestDir: "{fonts}"; Components: clock; FontInstall: "Century Gothic Bold"; Flags: onlyifdoesntexist uninsneveruninstall;
Source: "O:\Downloads\Games\WoT\mods_install\files\base_scripts\*"; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\texts\*"; Components: texts; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\tuman\*"; Components: tuman; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\safeshot\*"; Components: safe; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\save\*"; Components: save; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\reload\*"; Components: reload; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\angar\*"; Components: angar; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\angar_set\MultilinedTankCarousel.cfg"; Components: angar; DestDir: "{app}\res_mods\ModSettings\"; Flags: ignoreversion onlyifdoesntexist overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\zasvet\*"; Components: zasvet; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\markeru\*"; Components: xvm; DestDir: "{app}\res_mods\{#WotVer}\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\color_pr\*"; Components: color_pr; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\vagonu\*"; Components: vagonu; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
;Source: "O:\Downloads\Games\WoT\mods_install\files\lamp_timer\*"; Components: lamp_timer; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\pmod\*"; Components: pmod; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\totalhp\*"; Components: xvm\totalhp; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;
Source: "O:\Downloads\Games\WoT\mods_install\files\art_camera\*"; Components: art_camera; DestDir: "{app}\res_mods\"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; BeforeInstall: CreateBackup;

Source: "{tmp}\zons.7z";  DestDir: "{app}"; Flags: external; ExternalSize: 445002704; Components: zons

;Source: "O:\Downloads\Games\WoT\mods_install\files\zons_color\zons.7z";  DestDir: "{app}"; Components: zons

Source: "O:\Downloads\Games\WoT\mods_install\imgs\cut\*.bmp"; Flags: dontcopy nocompression;
Source: include\psvince.dll; Flags: dontcopy

Source: include\russian.ini; DestDir: {tmp}; Flags: dontcopy
Source: include\ISDone.dll; DestDir: {tmp}; Flags: dontcopy
Source: include\7z.dll; DestDir: {tmp}; Flags: dontcopy
Source: include\packZIP.exe; DestDir: {tmp}; Flags: dontcopy
#ifdef records
Source: records.inf; DestDir: {tmp}; Flags: dontcopy
#endif

#ifdef IsSkin
Source: Skin\ISSkinExU.dll; Flags: dontcopy
Source: Skin\Skin.cjstyles; Flags: dontcopy
#endif

[Icons]
Name: "{commondesktop}\World of Tanks"; Filename: "{app}\WOTLauncher.exe"; Tasks: desktopicon;

[Run]
Filename: "{app}\WOTLauncher.exe"; Description: "{cm:LaunchProgram,World of Tanks}"; Flags: shellexec postinstall skipifsilent unchecked;
;Filename: "{pf32}\Dokan\DokanLibrary\DokanUninstall.exe"; StatusMsg: "Удаление Dokan..."; Parameters: "/S"; Flags: skipifdoesntexist hidewizard; Tasks: dokan_rm;
    
;[UninstallRun]
;Filename: "{pf32}\Dokan\DokanLibrary\DokanUninstall.exe"; Parameters: "/S"; StatusMsg: "Удаление Dokan..."; Tasks: dokan; Flags: postinstall

[Code]
var
  str: string;

const
   nc = 50;


// -----------------------------------

#ifdef IsSkin

#ifdef UNICODE
  #define A "W"
  #define S "U"
#else
  #define A "A"
  #define S "A"
#endif

// Importing LoadSkin API from ISSkin.DLL
procedure LoadSkin(lpszPath: String; lpszIniFileName: String);
external 'LoadSkin@files:ISSkinExU.dll stdcall';

// Importing UnloadSkin API from ISSkin.DLL
procedure UnloadSkin();
external 'UnloadSkin@files:ISSkinExU.dll stdcall';

// Importing ShowWindow Windows API from User32.DLL
function ShowWindow(hWnd: Integer; uType: Integer): Integer;
external 'ShowWindow@user32.dll stdcall';

function InitializeSetup(): Boolean;
begin
  ExtractTemporaryFile('Skin.cjstyles');
  LoadSkin(ExpandConstant('{tmp}\Skin.cjstyles'), '');
  Result := True;
end;

procedure DeinitializeSetup();
begin
  // Hide Window before unloading skin so user does not get
  // a glimpse of an unskinned window before it is closed.
  ShowWindow(StrToInt(ExpandConstant('{wizardhwnd}')), 0);
  UnloadSkin();
end;
#endif

function MoveFile(const srcFile, destFile: PChar): Integer;
  external 'MoveFileA@kernel32.dll stdcall';

function IsModuleLoaded(modulename: AnsiString ): Boolean;
external 'IsModuleLoaded@files:psvince.dll stdcall';

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if (CurUninstallStep = usPostUninstall) then
  begin
    if DirExists(ExpandConstant('{app}\backup_mods\last')) then
    begin
      MoveDir(ExpandConstant('{app}\backup_mods\last\res_mods\'), ExpandConstant('{app}\res_mods\'));
      //RemoveDir(ExpandConstant('{app}\backup_mods\last\res_mods\'));
      //RemoveDir(ExpandConstant('{app}\backup_mods\last\'));
      DelTree(ExpandConstant('{app}\backup_mods\last\'), True, True, True);
    end;
  end;
end; 

procedure CreateBackup;
var
  srcFile, destFile: string;
  basePath, shortPath: string;
begin
  if IsTaskSelected('src') and not IsTaskSelected('del') then
  begin
    basePath := ExpandConstant('{app}');
    srcFile := ExpandConstant(CurrentFileName);
    shortPath := srcFile;
    StringChangeEx(shortPath, basePath, '', True);
    destFile := ExpandConstant('{app}\backup_mods\last') + shortPath;
    if not FileExists(destFile) then
    begin
      ForceDirectories(ExtractFilePath(destFile));
      MoveFile(PChar(srcFile), PChar(destFile));
    end;
  end;
end; 

function FileReplaceString(const FileName, SearchString, ReplaceString: string):boolean;
var
  MyFile : TStrings;
  MyText : string;
begin
  MyFile := TStringList.Create;

  try
    result := true;

    try
      MyFile.LoadFromFile(FileName);
      MyText := MyFile.Text;

      if StringChangeEx(MyText, SearchString, ReplaceString, True) > 0 then //Only save if text has been changed.
      begin;
        MyFile.Text := MyText;
        MyFile.SaveToFile(FileName);
      end;
    except
      result := false;
    end;
  finally
    MyFile.Free;
  end;
end;

function LoadValueFromXML(const AFileName, APath: string): string;
var
  XMLNode: Variant;
  XMLDocument: Variant;
begin
  Result := '';
  XMLDocument := CreateOleObject('Msxml2.DOMDocument.6.0');
  try
    XMLDocument.async := False;
    XMLDocument.load(AFileName);
    if (XMLDocument.parseError.errorCode <> 0) then
      //MsgBox('The XML file could not be parsed. ' +
       // XMLDocument.parseError.reason, mbError, MB_OK)
    else
    begin
      XMLDocument.setProperty('SelectionLanguage', 'XPath');
      XMLNode := XMLDocument.selectSingleNode(APath);
      Result := XMLNode.text;
    end;
  except
    //MsgBox('An error occured!' + #13#10 + GetExceptionMessage, mbError, MB_OK);
  end;
end;

function NextButtonClick(CurPage: Integer): Boolean;
var
  s: string;
begin
  str := GetDateTimeString('ss', #0, #0);
  Result := True;
  if CurPage = 6 then
  begin
    //if (FileSearch('WorldOfTanks.exe', ExpandConstant('{app}')) = '') or (FileSearch('version.xml', ExpandConstant('{app}')) = '')
    if not FileExists(ExpandConstant('{app}/WorldOfTanks.exe')) or not FileExists(ExpandConstant('{app}/version.xml')) or not DirExists(ExpandConstant('{app}/res/audio'))
      then
    begin
      s := ExpandConstant('World of Tanks не найдены в данной директории!') + #13#13 + ExpandConstant('Пожалуйста, укажите папку с игрой.');
      MsgBox(s, mbError, mb_Ok);
      Result := False;
    end else if(IsModuleLoaded('WorldOfTanks.exe') or IsModuleLoaded('WOTLauncher.exe')) // or IsModuleLoaded('xvm-stat.exe'))
      then
    begin
      s := ExpandConstant('Пожалуйста закройте World of Tanks перед установкой!');
      MsgBox(s, mbError, mb_Ok);
      Result := False  
    end else begin
      s := LoadValueFromXML(ExpandConstant('{app}\version.xml'),'//version.xml/version');
      if Pos(ExpandConstant('{#WotVer}'),s) = 0 then begin
        s := ExpandConstant('Данная сборка предназначена только для World of Tanks v{#WotVer}!');
        MsgBox(s, mbError, mb_Ok);
        Result := False
      end
    end;
  end;
end;

procedure CleanupDirectory(const Path: string);
begin
  if IsTaskSelected('del') then begin
    DelTree(ExpandConstant(Path), False, True, True);
  end;
end;

const
  PCFonFLY=true;
  notPCFonFLY=false;
var
  LabelPct1,LabelCurrFileName,LabelTime1,LabelTime2,LabelTime3: TLabel;
  ISDoneProgressBar1: TNewProgressBar;
#ifdef SecondProgressBar
  LabelPct2: TLabel;
  ISDoneProgressBar2:TNewProgressBar;
#endif
  MyCancelButton: TButton;
  ISDoneCancel:integer;
  ISDoneError:boolean;
  PCFVer:double;

type
  TCallback = function (OveralPct,CurrentPct: integer;CurrentFile,TimeStr1,TimeStr2,TimeStr3:PAnsiChar): longword;

function WrapCallback(callback:TCallback; paramcount:integer):longword;external 'wrapcallback@files:ISDone.dll stdcall delayload';

function IS7ZipExtract(CurComponent:Cardinal; PctOfTotal:double; InName, OutPath: AnsiString; DeleteInFile:boolean; Password: AnsiString):boolean; external 'IS7zipExtract@files:ISDone.dll stdcall delayload';

function Exec2 (FileName, Param: PAnsiChar;Show:boolean):boolean; external 'Exec2@files:ISDone.dll stdcall delayload';
function ISFindFiles(CurComponent:Cardinal; FileMask:AnsiString; var ColFiles:integer):integer; external 'ISFindFiles@files:ISDone.dll stdcall delayload';
function ISPickFilename(FindHandle:integer; OutPath:AnsiString; var CurIndex:integer; DeleteInFile:boolean):boolean; external 'ISPickFilename@files:ISDone.dll stdcall delayload';
function ISGetName(TypeStr:integer):PAnsichar; external 'ISGetName@files:ISDone.dll stdcall delayload';
function ISFindFree(FindHandle:integer):boolean; external 'ISFindFree@files:ISDone.dll stdcall delayload';
function ISExec(CurComponent:Cardinal; PctOfTotal,SpecifiedProcessTime:double; ExeName,Parameters,TargetDir,OutputStr:AnsiString;Show:boolean):boolean; external 'ISExec@files:ISDone.dll stdcall delayload';

function SrepInit(TmpPath:PAnsiChar;VirtMem,MaxSave:Cardinal):boolean; external 'SrepInit@files:ISDone.dll stdcall delayload';
function PrecompInit(TmpPath:PAnsiChar;VirtMem:cardinal;PrecompVers:single):boolean; external 'PrecompInit@files:ISDone.dll stdcall delayload';
function FileSearchInit(RecursiveSubDir:boolean):boolean; external 'FileSearchInit@files:ISDone.dll stdcall delayload';
function ISDoneInit(RecordFileName:AnsiString; TimeType,Comp1,Comp2,Comp3:Cardinal; WinHandle, NeededMem:longint; callback:TCallback):boolean; external 'ISDoneInit@files:ISDone.dll stdcall';
function ISDoneStop:boolean; external 'ISDoneStop@files:ISDone.dll stdcall';
function ChangeLanguage(Language:AnsiString):boolean; external 'ChangeLanguage@files:ISDone.dll stdcall delayload';
function SuspendProc:boolean; external 'SuspendProc@files:ISDone.dll stdcall';
function ResumeProc:boolean; external 'ResumeProc@files:ISDone.dll stdcall';

function ProgressCallback(OveralPct,CurrentPct: integer;CurrentFile,TimeStr1,TimeStr2,TimeStr3:PAnsiChar): longword;
var
  srcFile, destFile: string;
  basePath, shortPath: string;
begin
  if OveralPct<=1000 then ISDoneProgressBar1.Position := OveralPct;
  LabelPct1.Caption := IntToStr(OveralPct div 10)+'.'+chr(48 + OveralPct mod 10)+'%';
#ifdef SecondProgressBar
  if CurrentPct<=1000 then ISDoneProgressBar2.Position := CurrentPct;
  LabelPct2.Caption := IntToStr(CurrentPct div 10)+'.'+chr(48 + CurrentPct mod 10)+'%';
#endif
  LabelCurrFileName.Caption:=ExpandConstant('{cm:ExtractedFile} ')+MinimizePathName(CurrentFile, LabelCurrFileName.Font, LabelCurrFileName.Width-ScaleX(100));
  LabelTime1.Caption:=ExpandConstant('{cm:ElapsedTime} ')+TimeStr2;
  LabelTime2.Caption:=ExpandConstant('{cm:RemainingTime} ')+TimeStr1;
  LabelTime3.Caption:=ExpandConstant('{cm:AllElapsedTime}')+TimeStr3;

  //if IsTaskSelected('src') and not IsTaskSelected('del') then
  //begin
    //basePath := ExpandConstant('{app}');
    //srcFile := ExpandConstant('{app}\'+CurrentFile);
    //shortPath := srcFile;
    //StringChangeEx(shortPath, basePath, '', True);
    //destFile := ExpandConstant('{app}\backup_mods\last') + shortPath;
    //if not FileExists(destFile) then
    //begin
    //  ForceDirectories(ExtractFilePath(destFile));
    //  MoveFile(PChar(srcFile), PChar(destFile));
    //end;
  //end;

  Result := ISDoneCancel;
end;

procedure HideControls;
begin
  WizardForm.FileNamelabel.Hide;
  ISDoneProgressBar1.Hide;
  LabelPct1.Hide;
  LabelCurrFileName.Hide;
  LabelTime1.Hide;
  LabelTime2.Hide;
  MyCancelButton.Hide;
#ifdef SecondProgressBar
  ISDoneProgressBar2.Hide;
  LabelPct2.Hide;
#endif
end;

procedure CreateControls;
var PBTop:integer;
begin
  PBTop:=ScaleY(50);
  ISDoneProgressBar1 := TNewProgressBar.Create(WizardForm);
  with ISDoneProgressBar1 do begin
    Parent   := WizardForm.InstallingPage;
    Height   := WizardForm.ProgressGauge.Height;
    Left     := ScaleX(0);
    Top      := PBTop;
    Width    := ScaleX(365);
    Max      := 1000;
  end;
  LabelPct1 := TLabel.Create(WizardForm);
  with LabelPct1 do begin
    Parent    := WizardForm.InstallingPage;
    AutoSize  := False;
    Left      := ISDoneProgressBar1.Width+ScaleX(5);
    Top       := ISDoneProgressBar1.Top + ScaleY(2);
    Width     := ScaleX(80);
  end;
  LabelCurrFileName := TLabel.Create(WizardForm);
  with LabelCurrFileName do begin
    Parent   := WizardForm.InstallingPage;
    AutoSize := False;
    Width    := ISDoneProgressBar1.Width+ScaleX(30);
    Left     := ScaleX(0);
    Top      := ScaleY(30);
  end;
#ifdef SecondProgressBar
  PBTop:=PBTop+ScaleY(25);
  ISDoneProgressBar2 := TNewProgressBar.Create(WizardForm);
  with ISDoneProgressBar2 do begin
    Parent   := WizardForm.InstallingPage;
    Left     := ScaleX(0);
    Top      := PBTop+ScaleY(8);
    Width    := ISDoneProgressBar1.Width;
    Max      := 1000;
    Height   := WizardForm.ProgressGauge.Height;
  end;
  LabelPct2 := TLabel.Create(WizardForm);
  with LabelPct2 do begin
    Parent    := WizardForm.InstallingPage;
    AutoSize  := False;
    Left      := ISDoneProgressBar2.Width+ScaleX(5);
    Top       := ISDoneProgressBar2.Top + ScaleY(2);
    Width     := ScaleX(80);
  end;
#endif
  LabelTime1 := TLabel.Create(WizardForm);
  with LabelTime1 do begin
    Parent   := WizardForm.InstallingPage;
    AutoSize := False;
    Width    := ISDoneProgressBar1.Width div 2;
    Left     := ScaleX(0);
    Top      := PBTop + ScaleY(35);
  end;
  LabelTime2 := TLabel.Create(WizardForm);
  with LabelTime2 do begin
    Parent   := WizardForm.InstallingPage;
    AutoSize := False;
    Width    := LabelTime1.Width+ScaleX(40);
    Left     := ISDoneProgressBar1.Width div 2;
    Top      := LabelTime1.Top;
  end;
  LabelTime3 := TLabel.Create(WizardForm);
  with LabelTime3 do begin
    Parent   := WizardForm.FinishedPage;
    AutoSize := False;
    Width    := 300;
    Left     := 180;
    Top      := 200;
  end;
  MyCancelButton:=TButton.Create(WizardForm);
  with MyCancelButton do begin
    Parent:=WizardForm;
    Width:=ScaleX(135);
    Caption:=ExpandConstant('{cm:CancelButton}');
    Left:=ScaleX(360);
    Top:=WizardForm.cancelbutton.top;
    Enabled:=False;
    //OnClick:=@CancelButtonOnClick;
  end;
end;

function CheckError:boolean;
begin
  result:= not ISDoneError;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  arr: array[1..nc] of AnsiString;
  url: AnsiString;
  tmp: string;
  count: integer;
  c: integer;
  Comps1,Comps2,Comps3, TmpValue:cardinal;
begin
  if CurStep = ssPostInstall then
  begin
    #ifdef ALPHA
      SaveStringToFile(ExpandConstant('{app}\wot_[-KIEB]_ver.txt'), ExpandConstant('{#MyAppVer}a'), False);
    #else
    #ifdef BETA
      SaveStringToFile(ExpandConstant('{app}\wot_[-KIEB]_ver.txt'), ExpandConstant('{#MyAppVer}b'), False);
    #else
      SaveStringToFile(ExpandConstant('{app}\wot_[-KIEB]_ver.txt'), ExpandConstant('{#MyAppVer}'), False);
    #endif
    #endif

    c := 1;

    arr[c] := 'xvm'; c := c+1;
    arr[c] := 'xvm\lamp'; c := c+1;
    arr[c] := 'xvm\lamp_audio'; c := c+1;
    arr[c] := 'xvm\stat'; c := c+1;
    arr[c] := 'xvm\stat\panel'; c := c+1;
    //arr[c] := 'xvm\markeru'; c := c+1;
    arr[c] := 'xvm\map'; c := c+1;
    arr[c] := 'xvm\map\cube'; c := c+1;
    arr[c] := 'xvm\map\size'; c := c+1;
    arr[c] := 'xvm\load'; c := c+1;
    arr[c] := 'xvm\save'; c := c+1;
    arr[c] := 'xvm\clock'; c := c+1;
    arr[c] := 'xvm\login'; c := c+1;
    arr[c] := 'xvm\angar'; c := c+1;
    arr[c] := 'xvm\angar\two'; c := c+1;
    arr[c] := 'xvm\angar\three'; c := c+1;
    arr[c] := 'xvm\totalhp'; c := c+1;
    arr[c] := 'xvm\hp'; c := c+1;
    arr[c] := 'xvm\hp\v2'; c := c+1;
    arr[c] := 'xvm\hp\v1'; c := c+1;
    arr[c] := 'cross'; c := c+1;
    arr[c] := 'ugn'; c := c+1;
    arr[c] := 'damage'; c := c+1;
    arr[c] := 'damage\sound'; c := c+1;
    arr[c] := 'dmdind'; c := c+1;
    arr[c] := 'stat'; c := c+1;
    arr[c] := 'stat\kom'; c := c+1;
    arr[c] := 'zons'; c := c+1;
    arr[c] := 'texts'; c := c+1;
    arr[c] := 'tuman'; c := c+1;
    arr[c] := 'safe'; c := c+1;
    //arr[c] := 'safe\dead'; c := c+1;
    arr[c] := 'zasvet'; c := c+1;
    arr[c] := 'color_pr'; c := c+1;
    arr[c] := 'vagonu'; c := c+1;
    if (IsComponentSelected('pmod')) then begin
      arr[c] := 'pmod'; c := c+1;
      arr[c] := 'pmod\replay'; c := c+1;
      arr[c] := 'pmod\spawn'; c := c+1;
      arr[c] := 'pmod\rm_black'; c := c+1;
      arr[c] := 'pmod\zoom'; c := c+1;
      arr[c] := 'pmod\nd'; c := c+1;
      arr[c] := 'pmod\ns'; c := c+1;
      arr[c] := 'pmod\zoomx'; c := c+1;
      arr[c] := 'pmod\zoomx\16'; c := c+1;
      arr[c] := 'pmod\zoomx\30'; c := c+1;
      arr[c] := 'pmod\lamp_timer'; c := c+1;
    end;
    arr[c] := 'art_camera'; c := c+1;

    c := c-1;

    for count := 1 to c do begin
      tmp := arr[count];
      if (IsComponentSelected(tmp)) then begin
        StringChange(tmp,'\','-');
        if (count=1) then begin
          tmp := tmp + '=' + ExpandConstant('{#XVM}') + '&';
          url := url + tmp;
        end else begin
          url := url + tmp + '=&';
        end;
      end;
    end;

    SaveStringToFile(ExpandConstant('{app}\wot_[-KIEB]_log.txt'), url, False);

    if (not IsComponentSelected('xvm\stat')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\xvm\configs\AlexALX\rating.xc'), '"showPlayersStatistics": true,', '"showPlayersStatistics": false,');
    end;
    if (not IsComponentSelected('xvm\map')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\xvm\configs\AlexALX\minimap.xc'), '"enabled": true, //1', '"enabled": false, //1');
    end;
    if (not IsComponentSelected('xvm\map\cube')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\xvm\configs\AlexALX\minimap.xc'), '"enabled": true, //2', '"enabled": false, //2');
    end;
    if (not IsComponentSelected('xvm\load')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\login.xc'), '"skipIntro": true,', '"skipIntro": false,');
    end;
    if (IsComponentSelected('xvm\map\size')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\hotkeys.xc'), '"minimapZoom":         { "enabled": false, "keyCode": 29, "onHold": true },', '"minimapZoom":         { "enabled": true, "keyCode": 29, "onHold": true },');
    end;
    //if (IsComponentSelected('zoomx\16')) then begin
    //  FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\gui\ZoomX.xml'), '<zooms>2 4 8 16 30</zooms>', '<zooms>2 4 8 16</zooms>');
    //end;
    //if (not IsComponentSelected('xvm\markeru')) then begin
    //  FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\markersAliveNormal.xc'), '"visible": true, //MARK', '"visible": false, //MARK');
    //end;
    if (not IsComponentSelected('xvm\save')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\login.xc'), '"saveLastServer": true,', '"saveLastServer": false,');
    end;
    if (not IsComponentSelected('xvm\clock')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\clock.xc'), '"enabled": true, //1', '"enabled": false, //1');
    end;
    if (IsComponentSelected('xvm\stat\panel')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"formatLeft": "{{nick}}", //1', '"formatLeft": "<font color=''{{c:eff}}'' alpha=''{{alive?#FF|#80}}''>{{nick}}</font>", //1');
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"formatRight": "{{nick}}", //1', '"formatRight": "<font color=''{{c:eff}}'' alpha=''{{alive?#FF|#80}}''>{{nick}}</font>", //1');
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"formatLeft": "{{vehicle}}", //2', '"formatLeft": "<font color=''{{c:eff}}'' alpha=''{{alive?#FF|#80}}''>{{vehicle}}</font>", //2');
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"formatRight": "{{vehicle}}", //2', '"formatRight": "<font color=''{{c:eff}}'' alpha=''{{alive?#FF|#80}}''>{{vehicle}}</font>", //2');
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"nickFormatLeft": "{{nick}}", //3', '"nickFormatLeft": "<font color=''{{c:eff}}'' alpha=''{{alive?#FF|#80}}''>{{eff}}</font> {{nick}}", //3');
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"nickFormatRight": "{{nick}}", //3', '"nickFormatRight": "{{nick}} <font color=''{{c:eff}}'' alpha=''{{alive?#FF|#80}}''>{{eff}}</font>", //3');
    end;
    if (IsComponentSelected('xvm\login')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\login.xc'), '"autologin": false,', '"autologin": true,');
    end;
    if (IsComponentSelected('xvm\angar')) then begin
      //FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\carousel.xc'), '"enabled": false,', '"enabled": true,');
      if (IsComponentSelected('xvm\angar\two')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\carousel.xc'), '"zoom": 1,', '"zoom": 0.9,');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\carousel.xc'), '"rows": 1,', '"rows": 2,');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\carousel.xc'), '"x": 0, "y": 83,', '"x": 0, "y": 72,');
      end;
      if (IsComponentSelected('xvm\angar\three')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\carousel.xc'), '"zoom": 1,', '"zoom": 0.87,');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\carousel.xc'), '"rows": 1,', '"rows": 3,');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\carousel.xc'), '"x": 0, "y": 83,', '"x": 0, "y": 70,');
      end;
    end;
    if (IsComponentSelected('stat\kom')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\scripts\client\mods\stat_config.json'), '"ignoreBattleType": [2, 4, 7, 8],', '"ignoreBattleType": [2, 3, 4, 5, 7, 8, 9],');
    end;
    if (IsComponentSelected('xvm\totalhp')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\battle.xc'), '"hideTeamTextFields": true', '"hideTeamTextFields": false');
    end;
    if (IsComponentSelected('xvm\hp')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"width": 46,', '"width": 170,');
      FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\battle.xc'), '"allowHpInPanelsAndMinimap": false,', '"allowHpInPanelsAndMinimap": true,');
      if (IsComponentSelected('xvm\hp\v1')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"extraFieldsLeft": [], //h1', '"extraFieldsLeft": [ {"x": 0, "y": 2, "bgColor": "0x00FF00", "h": 22, "w": "{{hp-ratio:106}}", "alpha": "{{alive?20|0}}"} ], //h1');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '//h1r', ', {"x": 0, "y": 2, "bgColor": "0xFF0000", "h": 22, "w": "{{hp-ratio:106}}", "alpha": "{{alive?30|0}}"} //h1r');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"extraFieldsLeft": [], //h2', '"extraFieldsLeft": [ {"x": 0, "y": 0, "bgColor": "0x00FF00", "h": 24, "w": "{{hp-ratio:191}}", "alpha": "{{alive?20|0}}"} ], //h2');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '//h2r', ', {"x": 0, "y": 0, "bgColor": "0xFF0000", "h": 24, "w": "{{hp-ratio:191}}", "alpha": "{{alive?30|0}}"} //h2r');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"extraFieldsLeft": [], //h3', '"extraFieldsLeft": [ {"x": 0, "y": 0, "bgColor": "0x00FF00", "h": 24, "w": "{{hp-ratio:95}}", "alpha": "{{alive?20|0}}"} ], //h3');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '//h3r', ', {"x": 0, "y": 0, "bgColor": "0xFF0000", "h": 24, "w": "{{hp-ratio:95}}", "alpha": "{{alive?30|0}}"} //h3r');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"extraFieldsLeft": [], //h4', '"extraFieldsLeft": [ {"x": 0, "y": 0, "bgColor": "0x00FF00", "h": 24, "w": "{{hp-ratio:283}}", "alpha": "{{alive?20|0}}"} ], //h4');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '//h4r', ', {"x": 0, "y": 0, "bgColor": "0xFF0000", "h": 24, "w": "{{hp-ratio:283}}", "alpha": "{{alive?30|0}}"} //h4r');
      end else if (IsComponentSelected('xvm\hp\v2')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"extraFieldsLeft": [], //h1', '"extraFieldsLeft": [ {"x": 0, "y": 2, "bgColor": "0x00FF00", "h": 22, "w": "{{hp:106}}", "alpha": "{{alive?20|0}}"}, {"x": 0, "y": 2, "bgColor": "0xFFFFFF", "h": 22, "w": "{{hp-max:106}}", "alpha": "{{alive?20|0}}"} ], //h1');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '//h1r', ', {"x": 0, "y": 2, "bgColor": "0xFF0000", "h": 22, "w": "{{hp:106}}", "alpha": "{{alive?30|0}}"}, {"x": 0, "y": 2, "bgColor": "0xFFFFFF", "h": 22, "w": "{{hp-max:106}}", "alpha": "{{alive?20|0}}"} //h1r');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"extraFieldsLeft": [], //h2', '"extraFieldsLeft": [ {"x": 0, "y": 0, "bgColor": "0x00FF00", "h": 24, "w": "{{hp:191}}", "alpha": "{{alive?20|0}}"}, {"x": 0, "y": 0, "bgColor": "0xFFFFFF", "h": 24, "w": "{{hp-max:191}}", "alpha": "{{alive?20|0}}"} ], //h2');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '//h2r', ', {"x": 0, "y": 0, "bgColor": "0xFF0000", "h": 24, "w": "{{hp:191}}", "alpha": "{{alive?30|0}}"}, {"x": 0, "y": 0, "bgColor": "0xFFFFFF", "h": 24, "w": "{{hp-max:191}}", "alpha": "{{alive?20|0}}"} //h2r');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"extraFieldsLeft": [], //h3', '"extraFieldsLeft": [ {"x": 0, "y": 0, "bgColor": "0x00FF00", "h": 24, "w": "{{hp:95}}", "alpha": "{{alive?20|0}}"}, {"x": 0, "y": 0, "bgColor": "0xFFFFFF", "h": 24, "w": "{{hp-max:95}}", "alpha": "{{alive?20|0}}"} ], //h3');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '//h3r', ', {"x": 0, "y": 0, "bgColor": "0xFF0000", "h": 24, "w": "{{hp:95}}", "alpha": "{{alive?30|0}}"}, {"x": 0, "y": 0, "bgColor": "0xFFFFFF", "h": 24, "w": "{{hp-max:95}}", "alpha": "{{alive?20|0}}"} //h3r');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"extraFieldsLeft": [], //h4', '"extraFieldsLeft": [ {"x": 0, "y": 0, "bgColor": "0x00FF00", "h": 24, "w": "{{hp:283}}", "alpha": "{{alive?20|0}}"}, {"x": 0, "y": 0, "bgColor": "0xFFFFFF", "h": 24, "w": "{{hp-max:283}}", "alpha": "{{alive?20|0}}"} ], //h4');
        FileReplaceString(ExpandConstant('{app}\res_mods\configs\xvm\AlexALX\playersPanel.xc'), '"//h4r', ', {"x": 0, "y": 0, "bgColor": "0xFF0000", "h": 24, "w": "{{hp:283}}", "alpha": "{{alive?30|0}}"}, {"x": 0, "y": 0, "bgColor": "0xFFFFFF", "h": 24, "w": "{{hp-max:283}}", "alpha": "{{alive?20|0}}"} //h4r');
      end;
    end;
    if (IsComponentSelected('pmod')) then begin
      if (IsComponentSelected('pmod\lamp_timer')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\scripts\client\mods\PMOD.json'), '"enable": false, //m_bg', '"enable": true, //m_bg');
      end;
      if (IsComponentSelected('pmod\spawn')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\scripts\client\mods\PMOD.json'), '"enable": false, //m_bl', '"enable": true, //m_bl');
      end;
      if (IsComponentSelected('pmod\rm_black')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\scripts\client\mods\PMOD.json'), '"enable": false //m_nb', '"enable": true //m_nb');
      end;
      if (IsComponentSelected('pmod\nd')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\scripts\client\mods\PMOD.json'), '"enable": false, //m_nd', '"enable": true, //m_nd');
      end;
      if (IsComponentSelected('pmod\ns')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\scripts\client\mods\PMOD.json'), '"enable": false //m_ns', '"enable": true //m_ns');
      end;
      if (IsComponentSelected('pmod\replay')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\scripts\client\mods\PMOD.json'), '"enable": false, //m_vm', '"enable": true, //m_vm');
      end;
      if (IsComponentSelected('pmod\zoom')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\scripts\client\mods\PMOD.json'), '"enable": false, //m_zd', '"enable": true, //m_zd');
      end;
      if (IsComponentSelected('pmod\zoomx')) then begin
        FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\scripts\client\mods\PMOD.json'), '"enable": false, //m_zx', '"enable": true, //m_zx');
        if (IsComponentSelected('pmod\zoomx\16')) then begin
          FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\scripts\client\mods\PMOD.json'), '"zoomXSteps": [2, 4, 8, 16, 30]', '"zoomXSteps": [2, 4, 8, 16]');
        end;
      end;
    end;
    (*if (IsComponentSelected('safe\dead')) then begin
      FileReplaceString(ExpandConstant('{app}\res_mods\{#WotVer}\scripts\client\mods\SafeShot.xml'), '<teamShot>true</teamShot>', '<teamShot>false</teamShot>');
    end;
    (*if IsTaskSelected('del') and IsComponentSelected('xvm\stat') then
    begin
      if FileExists(ExpandConstant('{app}\tokens.xdb.tmp')) then
      begin
        CreateDir(ExpandConstant('{app}\res_mods\xvm\db\'));
        if not RenameFile(ExpandConstant('{app}\tokens.xdb.tmp'),ExpandConstant('{app}\res_mods\xvm\db\tokens.xdb')) then
        begin
          DeleteFile(ExpandConstant('{app}\tokens.xdb.tmp'));
        end;
      end;
    end; *)

    if IsComponentSelected('zons') then begin

      WizardForm.ProgressGauge.Hide;

      if IsTaskSelected('src') and not IsTaskSelected('del') then begin
        WizardForm.StatusLabel.Caption:=ExpandConstant('{cm:Backup}');
        CopyDir(ExpandConstant('{app}\res_mods\{#WotVer}\vehicles\'), ExpandConstant('{app}\backup_mods\last\res_mods\{#WotVer}\vehicles\'));
      end;

      WizardForm.CancelButton.Hide;
      CreateControls;
      WizardForm.StatusLabel.Caption:=ExpandConstant('{cm:Extracted}');
      ISDoneCancel:=0;

      ExtractTemporaryFile('7z.dll');
      ExtractTemporaryFile('PackZIP.exe');
      ExtractTemporaryFile('russian.ini');
      #ifdef records
        ExtractTemporaryFile('records.inf');
        tmp := ExpandConstant('{tmp}\records.inf');
      #else
        tmp := ExpandConstant('{src}\records.inf');
      #endif

      Comps1:=0; Comps2:=0; Comps3:=0;

      PCFVer:=0;

      ISDoneError:=true;

      if ISDoneInit(tmp, $F777, Comps1,Comps2,Comps3, MainForm.Handle, 256, @ProgressCallback) then begin
        repeat
          //if not SrepInit('',512,0) then break;
          //if not PrecompInit('',128,PCFVer) then break;
          if not FileSearchInit(true) then break;

          if not IS7ZipExtract   ( 0, 0, ExpandConstant('{app}\zons.7z'), ExpandConstant('{app}\res_mods\{#WotVer}\'), false, '') then break;

          ISDoneError:=false;
        until true;
        ISDoneStop;
      HideControls;
      WizardForm.CancelButton.Visible:=true;
      WizardForm.CancelButton.Enabled:=false;
      //WizardForm.ProgressGauge.Show;
      //WizardForm.FileNamelabel.Show;

      end;

      DeleteFile(ExpandConstant('{app}\zons.7z'));

    end;

  end else if CurStep = ssInstall then
  begin
    if (IsTaskSelected('src') and DirExists(ExpandConstant('{app}\backup_mods\last'))) then
    begin
      MoveDir(ExpandConstant('{app}\backup_mods\last\'), ExpandConstant('{app}\backup_mods\old_' + GetDateTimeString('dd/mm/yyyy_(hh:nn:ss)', '-', '-')));
    end;
    (*if IsTaskSelected('del') and IsComponentSelected('xvm\stat') then
    begin
      if FileExists(ExpandConstant('{app}\res_mods\xvm\db\tokens.xdb')) then
      begin
        DeleteFile(ExpandConstant('{app}\tokens.xdb.tmp'));
        //if IsTaskSelected('src') then
        //begin
          RenameFile(ExpandConstant('{app}\res_mods\xvm\db\tokens.xdb'),ExpandConstant('{app}\tokens.xdb.tmp'));
        //end;
      end;
    end;*)
    if not IsTaskSelected('src') and IsTaskSelected('del') then
    begin
      CleanupDirectory('{app}\res_mods\{#WotVer}\*');
      CleanupDirectory('{app}\res_mods\configs\xvm\*');
      CleanupDirectory('{app}\res_mods\mods\*');
      //ForceDirectories(ExtractFilePath(ExpandConstant('{app}\backup_mods\last\res_mods\xvm\')));
      //ForceDirectories(ExtractFilePath(ExpandConstant('{app}\backup_mods\last\res_mods\{#WotVer}\')));
      //RenameFile(ExpandConstant('{app}\res_mods\xvm\'), ExpandConstant('{app}\backup_mods\last\res_mods\xvm\'));
      //RenameFile(ExpandConstant('{app}\res_mods\{#WotVer}\'), ExpandConstant('{app}\backup_mods\last\res_mods\{#WotVer}\'));
      //MoveDir(ExpandConstant('{app}\res_mods\xvm\'), ExpandConstant('{app}\backup_mods\last\res_mods\xvm\'));
      //MoveDir(ExpandConstant('{app}\res_mods\{#WotVer}\'), ExpandConstant('{app}\backup_mods\last\res_mods\{#WotVer}\'));
      //MsgBox('SSSSSSSSs', mbError, mb_Ok);
    end;
  end;
end;            

procedure CurPageChanged(CurPageID: Integer);
begin
    if CurPageID = wpReady then
    begin
        // User can navigate to 'Ready to install' page several times, so we
        // need to clear file list to ensure that only needed files are added.
        idpClearFiles;

        if IsComponentSelected('zons') then
            idpAddFile(ExpandConstant('http://yoursite.local/patch/zons_{#ZonsVer}.7z'), ExpandConstant('{tmp}\zons.7z'));
  end else if (CurPageID = wpFinished) and ISDoneError then
  begin
    LabelTime3.Hide;
    WizardForm.Caption:= ExpandConstant('{cm:Error}');
    WizardForm.FinishedLabel.Font.Color:= clRed;
    WizardForm.FinishedLabel.Caption:= SetupMessage(msgSetupAborted) ;
  end else if CurPageId = wpSelectComponents then begin
      WizardForm.ActiveControl:=WizardForm.ComponentsList;
  end; (* else if CurPageId = wpPreparing then begin
    if (IsTaskSelected('src') and DirExists(ExpandConstant('{app}\backup_mods\last'))) then
    begin
      MoveDir(ExpandConstant('{app}\backup_mods\last\'), ExpandConstant('{app}\backup_mods\old_' + GetDateTimeString('dd/mm/yyyy_(hh:nn:ss)', '-', '-')));
    end;

    if not IsTaskSelected('src') and IsTaskSelected('del') then
    begin
      CleanupDirectory('{app}\res_mods\{#WotVer}\*');
      CleanupDirectory('{app}\res_mods\xvm\*');
    end;

    if IsComponentSelected('zons') then begin
     DeleteFile(ExpandConstant('{app}\zons.7z'));
    end;
  end;  *)
end;

// msg := WizardForm.StatusLabel.Caption;
// WizardForm.StatusLabel.Caption := ExpandConstant('{cm:pointMsg}');
// WizardForm.Repaint;
// WizardForm.StatusLabel.Caption := msg;

#ifdef UNICODE
    #define A "W"
#else
    #define A "A"
#endif

const
    UNDEF_INDEX = -777;
    ALPHA_BLEND_LEVEL = 255; // max=Byte=255

    WS_EX_LAYERED = $80000;
    WS_EX_TRANSPARENT = $20;
    LWA_COLORKEY = 1;
    LWA_ALPHA = 2;
    GWL_EXSTYLE = (-20);


var
    InfoPic: TBitmapImage;
    LastIndex: Integer;
    TempPath: String;
    PicForm: TForm;

type
    COLORREF = DWORD;


function GetCursorPos(var lpPoint: TPoint): BOOL; external 'GetCursorPos@user32.dll stdcall';
function SetLayeredWindowAttributes(Hwnd: THandle; crKey: COLORREF; bAlpha: Byte; dwFlags: DWORD): Boolean; external 'SetLayeredWindowAttributes@user32.dll stdcall';
function GetWindowLong(hWnd: HWND; nIndex: Integer): Longint; external 'GetWindowLong{#A}@user32.dll stdcall';
function SetWindowLong(hWnd: HWND; nIndex: Integer; dwNewLong: Longint): Longint; external 'SetWindowLong{#A}@user32.dll stdcall';
function SetFocus(hWnd: HWND): HWND; external 'SetFocus@user32.dll stdcall';


procedure ShowPicHint(const PicFilePath: String);
var
    pt: TPoint;
begin
    if not GetCursorPos(pt) then Exit;
    InfoPic.Bitmap.LoadFromFile(PicFilePath);
    try
        with PicForm do
        begin
            SetBounds(ScaleX(pt.x + 16), ScaleY(pt.y + 27), InfoPic.Width, InfoPic.Height);
            Show;
        end;
    finally
        SetFocus(WizardForm.Handle);
    end;
end;

procedure CompOnItemMouseMove(Sender: TObject; X, Y: Integer; Index: Integer; Area: TItemArea);
var
    UndefPic: String;
begin
    if Index = -1 then Exit;
    if Index = LastIndex then Exit;              
    try
        case TNewCheckListBox(Sender).ItemCaption[Index] of
            'XVM v{#XVM}': UndefPic := 'xvm.bmp';
            'Включить статистику игроков в бою (необходима активация на modxvm.com)': UndefPic := 'xvm_stat.bmp';
            'Часы в ангаре': UndefPic := 'clock.bmp';
            'Суммарная статистика за день + результат боя в чат': UndefPic := 'stat.bmp';
            'Заменить лампочку на знак восклицания с надписью "Танк Обнаружен" (шестое чувство)': UndefPic := 'lamp.bmp';
            'Отключить затемнение в снайперском прицеле': UndefPic := 'rm_black.bmp';
            'Увеличение дальности видимости на всех картах': UndefPic := 'tuman.bmp';
            'Дамаг панель с индикацией полученого урона/временем починки модулей': UndefPic := 'dmg.bmp';
            'Миникарта с названием техники и радиусом обзора': UndefPic := 'map.bmp';
            'Показывать квадрат максимальной отрисовки техники': UndefPic := 'map_cube.bmp';
            '4-позиционный, добавлено x16 приближение': UndefPic := 'zoom16.bmp';
            '5-позиционный, добавлено x16 и x30 приближение': UndefPic := 'zoom30.bmp';
            'Блокировка выстрела по союзникам и трупам сразу после уничтожения': UndefPic := 'safe.bmp';
            'Сохранять последний сервер при заходе в игру': UndefPic := 'save.bmp';
            'Максимальное отдаление камеры (zoom-мод)': UndefPic := 'zoom.bmp';
            'Цветные шкурки с зонами пробития': UndefPic := 'zons.bmp';
            'Расширенные подсказки с навыками и умениями': UndefPic := 'texts.bmp';
            'Уведомление союзников о засвете': UndefPic := 'zasvet.bmp';
            'Несколько рядов танков в ангаре': UndefPic := 'angar_two.bmp';
            'в 2 ряда': UndefPic := 'angar_two.bmp';
            'в 3 ряда': UndefPic := 'angar_three.bmp';
            'Углы горизонтальной наводки для пт и арт-сау': UndefPic := 'ugn.bmp';
            'Minimalistic Sights - прицел включает время полёта снарядов арт-сау и толщину брони в прицеле': UndefPic := 'cross_ms.bmp';
            'Дамаг индикатор с направлением выстрела': UndefPic := 'dmg_ind.bmp';
            'Отключить вступительный ролик World Of Tanks при загрузке': UndefPic := 'load.bmp';
            'Увеличивать мини-карту через crtl на весь экран': UndefPic := 'crtl.bmp';
            'Показывать щит и маркер фокуса если осталось менее 30% здоровья': UndefPic := 'markeru.bmp';
            'Цветные места пробитий': UndefPic := 'color_pr.bmp';
            'Отдельный вид для каждого типа вагонов': UndefPic := 'vagonu.bmp';
            'Включить отображение статистики в ушах': UndefPic := 'panel.bmp';
            'Показывать позицию респавна во время загрузки боя вместо подсказки': UndefPic := 'spawn.bmp';
            'Панель с общим здоровьем команд в бою': UndefPic := 'totalhp.bmp';
            'Показывать здоровье танков команды в ушах (может снизить fps)': UndefPic := 'hp_v2.bmp';
            'однородные': UndefPic := 'hp_v1.bmp';
            'пропорциональные': UndefPic := 'hp_v2.bmp';
            'Улучшенный вид камеры в арт прицеле (нажмите G в арт прицеле)': UndefPic := 'art_camera.bmp';
        else
            begin
                LastIndex := UNDEF_INDEX;
                PicForm.Hide;
                Exit;
            end;
        end;
        if not FileExists(TempPath + UndefPic) then ExtractTemporaryFile(UndefPic);
        ShowPicHint(TempPath + UndefPic);
    finally
        LastIndex := Index;
    end;
end;


procedure CompOnMouseLeave(Sender: TObject);
begin
    PicForm.Hide;
    LastIndex := -1;
end;


procedure InitInfo();
begin
    WizardForm.ComponentsList.OnItemMouseMove := @CompOnItemMouseMove;
    WizardForm.ComponentsList.OnMouseLeave := @CompOnMouseLeave;
    TempPath := AddBackslash(ExpandConstant('{tmp}'));
    LastIndex := UNDEF_INDEX;
    PicForm := TForm.Create(WizardForm)
    with PicForm do
    begin
        BorderStyle := bsNone;
        FormStyle := fsStayOnTop;
        InfoPic := TBitmapImage.Create(PicForm)
        with InfoPic do
        begin
            Parent := PicForm;
            AutoSize := True;
        end;
    end;
    SetWindowLong(PicForm.Handle, GWL_EXSTYLE, GetWindowLong(PicForm.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
    SetLayeredWindowAttributes(PicForm.Handle, 0, ALPHA_BLEND_LEVEL, LWA_ALPHA);
end;
procedure InitializeWizard();
begin
    InitInfo();
    idpDownloadAfter(wpReady);
    //InitializeImage;

  //with WizardForm do begin
   //BorderStyle:=bsNone;
    //ClientWidth:=ScaleX(702);
    //ClientHeight:=ScaleY(436);
  //end;

end;

end.
end;