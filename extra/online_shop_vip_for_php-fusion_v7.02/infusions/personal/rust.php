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
header('Content-Type: text/plain; charset=utf-8');

require_once("core.php");

$prices = get_prices();
$servers = servers_arr();

if (isset($_GET['server'])&&isnum($_GET['server'])) {   /*
$i = 0;
foreach ($servers as $serv) {
	if (isset($serv[2])) continue;
	if ($i!=0) echo ", ";
	echo $serv[0]; $i++;
}
echo ".\n\n"; */

if (isset($_GET['cost'])) { ?>
<color=#00DD00>Стоимость услуги:</color>
<color=#DDDD00>На 1 Сервер:</color>
3 Дня - <?php echo $prices[0][1][0]; ?> гривен (<?php echo $prices[1][1][0]; ?> рублей).
2 Недели - <?php echo $prices[0][1][1]; ?> гривен (<?php echo $prices[1][1][1]; ?> рублей).
1 Месяц - <?php echo $prices[0][1][2]; ?> гривен (<?php echo $prices[1][1][2]; ?> рублей).
3 Месяца - <?php echo $prices[0][1][3]; ?> гривен (<?php echo $prices[1][1][3]; ?> рублей).
<color=#DDDD00>На все сервера:</color>
3 Дня - <?php echo $prices[0][0][0]; ?> гривен (<?php echo $prices[1][0][0]; ?> рублей).
2 Недели - <?php echo $prices[0][0][1]; ?> гривен (<?php echo $prices[1][0][1]; ?> рублей).
1 Месяц - <?php echo $prices[0][0][2]; ?> гривен (<?php echo $prices[1][0][2]; ?> рублей).
3 Месяца - <?php echo $prices[0][0][3]; ?> гривен (<?php echo $prices[1][0][3]; ?> рублей).
<?php
} else { ?>
Все игроки проекта <color=#DD0000>Botov.NET.UA</color> могут купить VIP аккаунт на наших серверах.

<?php if ($_GET['server']=="2") { ?>
<color=#DD0000>VIP на сервере Rust - Фан Сервере получает:</color>
* <color=#00DD00>+50%</color> к скорости прокачки.
* <color=#00DD00>+25%</color> к добыче ресурсов.
* При спавне вы сразу в <color=#00DD00>костюме охотника</color>.
* Доступ к вип набору с <color=#00DD00>случайным лутом</color> (раз в сутки).
* Набор содержит <color=#00DD00>сигнальную гранату</color> для вызова <color=#DD0000>аирдропа</color>.
* Доступ к <color=#00DD00>цветному чату</color>.

<?php } else if ($_GET['server']=="3") { ?>
<color=#DD0000>VIP на сервере Rust - Выживании получает:</color>
* <color=#00DD00>+50%</color> к скорости прокачки.
* <color=#00DD00>+25%</color> к добыче ресурсов.
* При спавне вы сразу в <color=#00DD00>шортах</color> и <color=#00DD00>футболке</color>.
* Доступ к вип набору с <color=#00DD00>случайным лутом</color> (раз в сутки).
* Набор содержит <color=#00DD00>сигнальную гранату</color> для вызова <color=#DD0000>аирдропа</color>.
* Доступ к <color=#00DD00>цветному чату</color>.

<?php } else if ($_GET['server']=="4") { ?>
<color=#DD0000>VIP на сервере Rust - Остров Смерти получает:</color>
* <color=#00DD00>+50%</color> к скорости прокачки.
* <color=#00DD00>+25%</color> к добыче ресурсов.
* При спавне вы сразу в <color=#00DD00>костюме охотника</color>.
* Доступ к вип набору с <color=#00DD00>случайным лутом</color> (раз в сутки).
* Набор содержит <color=#00DD00>сигнальную гранату</color> для вызова <color=#DD0000>аирдропа</color>.
* Доступ к <color=#00DD00>цветному чату</color>.

<?php } ?>
Примечание: на каждом сервере возможности випов различаются!
<?php /*
<b><span style='color:red'>Внимание!</span> <span style='color:lightgreen'>Новогодняя акция 2015!</span></b>
С <u>25 декабря</u> по <u>18 января</u> есть <b>25% скидка</b> на покупку и продления VIP аккаунта.

Также добавлено <u>специальное предложение</u> - вип аккаунт на <b>пол года</b> (180 дней) за <b>70/125 грн</b> (один/все сервера).

А также всем кто купит новый VIP в данный период получат <b>+2 недели VIP'а бесплатно</b>.
Данный бонус действует <u>только один раз</u>, при повторной покупке вы уже не получите его.

<span style='color:green'><b>Стоимость услуги:</b></span>
Скидка <span style='color:red'><b>-25%</b></span> до <b>18 января</b>
*/ ?>

<color=#DD0000>Доступные команды:</color>
<color=#00DD00>/vip buy</color> - стоимость вип аккаунта
<color=#00DD00>/vip help</color> - команды для випов
<color=#00DD00>/vip</color> - узнать информацию о вашем вип аккаунте
<color=#00DD00>/vips</color> - список вип игроков
<?php }
echo "\nПодробнее: <color=#DD0000>http://botov.net.ua/vip</color>";
} else if (isset($_GET['commands'])&&isnum($_GET['commands'])) {

	if ($_GET['commands']!="0") { ?>
<color=#DD0000>Команды для випов</color>
<?php /*amx_csay &quot;color&quot; &quot;message&quot; Сообщение для всех по центру
amx_say &quot;message&quot; Послать сообщение всем игрокам
amx_tsay &quot;color&quot; &quot;message&quot; Сообщение для всех слева
В чате: &quot;@[@|@][w|r|g|b|y|m|c]text&quot; HUD Сообщение в выбранном формате
<b>Примеры:</b>
@тест - сообщение &quot;тест&quot; слева
@@тест - сообщение &quot;тест&quot; сверху
@@@тест - сообщение &quot;тест&quot; снизу
Также можно указать цвет сразу после &quot;@&quot;:
w - белый, r - красный, g - зелёный, b - синий, y - жёлтый, m - фиолетовый, c - голубой.
<b>Например:</b> @@y тест - жёлтое сообщение &quot;тест&quot; сверху     */
?><color=#00DD00>/vip chat</color> <color=#ffb400>on/off</color> - вкл/выкл цветной чат випа
<color=#00DD00>/vip wear</color> <color=#ffb400>on/off</color> - вкл/выкл авто-надевание одежды из набора
<color=#00DD00>/vip color</color> <color=#ffb400>цвет</color> - задать цвет ника
<color=#00DD00>/vip color</color> <color=#ffb400>normal</color> - вернуть стандартный цвет
<color=#00DD00>/vip color</color> <color=#ffb400>off</color> - отключить цветной ник
<color=#00DD00>/vip textcolor</color> <color=#ffb400>цвет</color> - задать цвет сообщения
<color=#00DD00>/vip textcolor</color> <color=#ffb400>normal</color> - вернуть стандартный цвет сообщения
<color=#00DD00>/kit vip</color> - использовать набор випа (раз в сутки)

<color=#DD0000>Доступные стандартные цвета:</color>
<?php
	$colors = array("aqua","black","blue","brown","darkblue","green","grey","lightblue","lime","magenta","maroon","navy","olive","orange","purple","red","silver","teal","white","yellow");
	$i = 0;
	foreach($colors as $col) {
		if ($i!=0) echo " ";
		echo "<color=$col>$col</color>";
		$i++;
	}
?>


Также возможно задавать цвет используя html код цвета (например #00FF00). Подобрать цвет можно на нашем сайте в личном кабинете, раздел VIP аккаунт.

Заходите на сайт и форум сервера! <color=#DD0000>http://botov.net.ua/</color>
<?php } ?>
<?php } ?>