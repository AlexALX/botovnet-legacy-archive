Плагин исправления энтити game_team_master и game_team_set для CS 1.6 (fix)

Описание:
Этот плагин фиксит энтитю game_team_master и game_team_set для CS 1.6.
Без данного плагина эти энтити всегда активируются, вне зависимости от команды игрока.

Информация о энтити:
http://cs-mapper.by.ru/entities/game_team_master.shtml
http://cs-mapper.by.ru/entities/game_team_set.shtml

Используемые модули:
Сstrike
Fakemeta
Hamsandwich

Как использовать:
Для game_team_master используйте поле Team Index для указания команды:
* -1 - каждый может активировать
* 1 - только Террористы могут активировать
* 2 - только КТ могут активировать
Для game_team_set теперь можно указывать какую команду задавать для game_team_master:
* -1 - сменить команду на всех
* 0 - сменить команду на команду активирующего объект (по-умолчанию)
* 1 - сменить команду на Террористов
* 2 - сменить команду на КТ
Для указания команды вы должны выключить SmartEdit в Valve Hammer Editor и добавить новое поле:
Key: team, Value: 2 (или другое значение).
(смотрите изображение)
Важно! Не исправляйте ошибку в Valve Hammer Editor (alt+p):
Entity (game_team_set) has unused keyvalues.
Смотрите карту-пример, где показано как работает плагин. Надеюсь всё всем ясно.

Копирайты и спасибо:
Created by AlexALX (c) 2010 http://alex-php.net/
Created special for map deathrun_skills_edited
Big thank Arkshine (http://forums.alliedmods.net/member.php?u=7779)
For help in creating plugin.

Создано специально для карты deathrun_skills_edited.

Список изменений:
[15.09.10 - v0.3]
* Полностью изменён код (спасибо Arkshine), теперь функции работают как в HL SDK (за исключение добавленной новой опции "team" для энтити game_team_set).
[28.08.10 - v0.2]
* Обновлена тестовая карта-пример (с учетом новых изменений).
* Теперь для указания команды энтини game_team_set вы должны выключить SmartEdit в Valve Hammer Editor и добавить новое поле: Key: team, Value: 2 (или другое значение).
* Теперь Team Index работает, вам не нужно использовать поле Yaw.
* Теперь вы должны указывать команду в team index (для game_team_master) или team (для game_team_set). Поле Yaw больше не имеет никакого эффекта.
[27.08.10 - v0.1]
* Первая версия.