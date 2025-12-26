<?php
/*-------------------------------------------------------+
| PHP-Fusion Content Management System
| Copyright (C) 2002 - 2011 Nick Jones
| http://www.php-fusion.co.uk/
+--------------------------------------------------------+
| This plugin is VIP system and Shop for RUST and GMOD servers
| Also includes some personal in-game stats
| Use together with VIP in-game plugin
| Was used on Botov-NET servers
| Copyright (c) 2015 by AlexALX
+--------------------------------------------------------+
| This program is released as free software under the
| Affero GPL license. You can redistribute it and/or
| modify it under the terms of this license which you
| can read by viewing the included agpl.txt or online
| at www.gnu.org/licenses/agpl.html. Removal of this
| copyright header is strictly prohibited without
| written permission from the original author(s).
+--------------------------------------------------------*/
require_once("core.php");

?><html>
<head>
<title>VIP Info</title>
<style type="text/css">
			pre
			{
				font-family:Verdana,Tahoma;
				color:#FFFFFF;
			}

			body
			{
				background:#000000;
				margin-left:8px;
				margin-top:0px;
			}
a	{
    	text-decoration:    underline;
	color:  #FFFFFF;
	}
</style>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body scroll="no">
<pre>
<?php

$prices = get_prices();
$servers = servers_arr();

if (isset($_GET['server'])&&isnum($_GET['server'])) { ?>
Все игроки на <span style='color:red'><b>Botov.NET.UA</b></span> могут купить VIP аккаунт на <b>наших серверах</b>:
<?php
$i = 0;
foreach ($servers as $serv) {
	if (isset($serv[2])) continue;
	if ($i!=0) echo ", ";
	echo $serv[0]; $i++;
}
echo ".\n\n";

 if ($_GET['server']=="1") { ?>
<span style='color:red'><b>VIP игрок на Garry's Mod Stargate сервере получает:</b></span>
* Возможность заходить на VIP слоты.
* Возможность использовать админский чат (по центру).
* Возможность создания голосований на смену карты/кик/бан и собственное.
* Возможность толкать (slap) других игроков.
* Возможность выдавать hp и броню другим игрокам.
* Возможность спавнить админские энтити/тулы CAP'а.
* Возможность воспроизводить видео в игре с помощью playx.
* Возможность садить игроков в тюрьму до 60 секунд.
<?php } ?>
<b>Примечание:</b> на каждом сервере возможности випов различаются!
<?php /*
<b><span style='color:red'>Внимание!</span> <span style='color:lightgreen'>Новогодняя акция 2015!</span></b>
С <u>25 декабря</u> по <u>18 января</u> есть <b>25% скидка</b> на покупку и продления VIP аккаунта.

Также добавлено <u>специальное предложение</u> - вип аккаунт на <b>пол года</b> (180 дней) за <b>70/125 грн</b> (один/все сервера).

А также всем кто купит новый VIP в данный период получат <b>+2 недели VIP'а бесплатно</b>.
Данный бонус действует <u>только один раз</u>, при повторной покупке вы уже не получите его.

<span style='color:green'><b>Стоимость услуги:</b></span>
Скидка <span style='color:red'><b>-25%</b></span> до <b>18 января</b>
*/ ?>

<span style='color:green'><b>Стоимость услуги:</b></span>

<b>На 1 Сервер:</b>
3 Дня - <?php echo $prices[0][1][0]; ?> гривен (<?php echo $prices[1][1][0]; ?> рублей).
2 Недели - <?php echo $prices[0][1][1]; ?> гривен (<?php echo $prices[1][1][1]; ?> рублей).
1 Месяц - <?php echo $prices[0][1][2]; ?> гривен (<?php echo $prices[1][1][2]; ?> рублей).
3 Месяца - <?php echo $prices[0][1][3]; ?> гривен (<?php echo $prices[1][1][3]; ?> рублей).
<b>На все сервера:</b>
3 Дня - <?php echo $prices[0][0][0]; ?> гривен (<?php echo $prices[1][0][0]; ?> рублей).
2 Недели - <?php echo $prices[0][0][1]; ?> гривен (<?php echo $prices[1][0][1]; ?> рублей).
1 Месяц - <?php echo $prices[0][0][2]; ?> гривен (<?php echo $prices[1][0][2]; ?> рублей).
3 Месяца - <?php echo $prices[0][0][3]; ?> гривен (<?php echo $prices[1][0][3]; ?> рублей).

<?php if ($_GET['server']=="1") { ?>
<b>Доступные команды:</b> !vip, !vips, !vipinfo, !vipcommands, !menu.

<b>Подробнее</b>: <a href='http://botov.net.ua/vip'>http://botov.net.ua/vip</a>
<?php } else { ?>
<b>Доступные команды:</b> /vip, /vips, /vipinfo, /vipmenu, /vipcommands.

<b>Подробнее</b>: <u>http://botov.net.ua/vip</u>
<?php } ?>
<?php } else if (isset($_GET['commands'])&&isnum($_GET['commands'])) {
if ($_GET['commands']=="1") { ?>
<h1>Команды для випов</h1>
<b>Примечание:</b> кавычки (&quot;) не во всех случаях являются обязательными.
ulx csay &quot;message&quot; Сообщение для всех по центру
ulx tsay &quot;message&quot; Сообщение для всех слева
В чате: &quot;@[@|@]text&quot; HUD Сообщение в выбранном формате
<b>Примеры:</b>
@тест - сообщение &quot;тест&quot; для админов
@@тест - сообщение &quot;тест&quot; слева
@@@тест - сообщение &quot;тест&quot; по центру
ulx menu или !menu в чате - VIP Меню
ulx vote &quot;вопрос&quot; &quot;ответ1&quot; &quot;ответ2&quot; (до 10 ответов) Любое голосование
ulx voteban &quot;name or #userid&quot; [время] [причина] Голосование за бан игрока
ulx votekick &quot;name or #userid&quot; [время] [причина] Голосование за кик игрока
ulx votemap2 &quot;карта&quot; (до 10 карт) Голосование за следующую карту
ulx slap &quot;name or #userid&quot; Толкнуть игрока
ulx hp &quot;name or #userid&quot; [здоровье] Задать здоровье игроку
ulx armor &quot;name or #userid&quot; [броня] Задать броню игроку

Также данные команды доступны в чате через приставку <b>!ulx</b>
Например: !ulx hp nick 100

<b>Другие комманды (чат):</b>
!vip, !vips, !vipinfo - команды для випов, информация.
!playx http://youtube.com/...... - воспроизвести видео с помощью playx.

<b>Заходите на сайт и форум сервера! <a href='http://botov.net.ua/' style="color: red">http://botov.net.ua/</a></b>
<?php } } ?>
</pre>
</body>
</html>