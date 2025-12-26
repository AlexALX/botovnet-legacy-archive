; <?php die("Access Denied."); ?>
; Biohazard class configuration file
; Default File location: cstrike/addons/amxmodx/configs/bh_zombieclass.ini
; To use with Biohazard plugin

; [class]     - Класс
; DESC        - Описание
; PMODEL      - Модель игрока (без пробелов)
; WMODEL      - Модель оружия (без пробелов)
; HEALTH      - Здоровье
; SPEED       - Скорость
; GRAVITY     - Гравитация
; ATTACK      - Сила атаки зомби (15 хп = 1.0)
; DEFENCE     - Сила повреждения зомби (15 хп с ножа = 1.0)
; HEDEFENCE   - Сила повреждения от гранаты (с напалмом не работает)
; HITSPEED    - скорость зомби когда по нему стреляют
; HITDELAY    - Количество сек после урона до возращения нормальной скорости
; REGENDLY    - Регенерация (каждые x сек по 1 хп, 0.1 = 10 хп/сек)
; HITREGENDLY - Количество сек после урона когда регенерация снова включиться
; KNOCKBACK   - "Отлетание" когда по зомби валят

; [New ZM Class by AlexALX]

;[Normal]
;DESC=Normal
;PMODEL=models/player/slum/slum.mdl
;HEALTH=200.0
;SPEED=270.0
;GRAVITY=1.0
;ATTACK=1.0
;DEFENCE=0.087
;HITSPEED=0.89
;HITDELAY=0.28
;REGENDLY=0.18
;HITREGENDLY=2.0
;KNOCKBACK=1.0

[Stalker]
DESC=Speed++ Strong+
PMODEL=models/player/bio_botovnetua/stalker.mdl
HEALTH=190.0
SPEED=310.0
GRAVITY=1.0
ATTACK=1.5
DEFENCE=0.07
HITSPEED=0.82
HITDELAY=0.3
REGENDLY=0.2
HITREGENDLY=2.0
KNOCKBACK=0.9

[FastStalker]
DESC=Speed+++ Strong-
PMODEL=models/player/bio_botovnetua/faststalker_fix.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie2.mdl
HEALTH=140.0
SPEED=360.0
GRAVITY=0.9
ATTACK=1.0
DEFENCE=0.068
HITSPEED=0.86
HITDELAY=0.25
REGENDLY=0.22
HITREGENDLY=2.5
KNOCKBACK=1.2

[RegenStalker]
DESC=Speed++ Regen+
PMODEL=models/player/bio_botovnetua/regenstalker_fix.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie17.mdl
HEALTH=145.0
SPEED=310.0
GRAVITY=1.0
ATTACK=1.5
DEFENCE=0.065
HITSPEED=0.82
HITDELAY=0.3
REGENDLY=0.13
HITREGENDLY=1.5
KNOCKBACK=1.1

[Hulk]
DESC=Strong+++ Speed-
PMODEL=models/player/bio_botovnetua/hulk.mdl
HEALTH=340.0
SPEED=235.0
GRAVITY=1.0
ATTACK=2.5
DEFENCE=0.09
HEDEFENCE=0.3
HITSPEED=0.62
HITDELAY=0.5
REGENDLY=0.2
HITREGENDLY=2.5
KNOCKBACK=0.3

[FastHulk]
DESC=Strong++
PMODEL=models/player/bio_botovnetua/fasthulk.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie14.mdl
HEALTH=260.0
SPEED=250.0
GRAVITY=1.0
ATTACK=2.0
DEFENCE=0.085
HITSPEED=0.73
HITDELAY=0.41
REGENDLY=0.2
HITREGENDLY=2.5
KNOCKBACK=0.5

[SlowHulk]
DESC=Strong+ Speed- Gravity-
PMODEL=models/player/bio_botovnetua/slowhulk.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie15.mdl
HEALTH=215.0
SPEED=230.0
GRAVITY=0.5
ATTACK=1.75
DEFENCE=0.087
HITSPEED=0.73
HITDELAY=0.45
REGENDLY=0.2
HITREGENDLY=2.5
KNOCKBACK=0.35

[GonomeHulk]
DESC=Strong+ Speed- Regen+
PMODEL=models/player/bio_botovnetua/gonomehulk.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie13.mdl
HEALTH=215.0
SPEED=230.0
GRAVITY=1.0
ATTACK=1.75
DEFENCE=0.087
HITSPEED=0.73
HITDELAY=0.45
REGENDLY=0.13
HITREGENDLY=1.5
KNOCKBACK=0.5

[Leaper]
DESC=Gravity-- Speed+
PMODEL=models/player/bio_botovnetua/fastleaper.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie3b.mdl
HEALTH=130.0
SPEED=280.0
GRAVITY=0.36
ATTACK=1.5
DEFENCE=0.055
HITSPEED=0.92
HITDELAY=0.32
REGENDLY=0.2
HITREGENDLY=2.5
KNOCKBACK=1.7

[StrongLeaper]
DESC=Gravity- Speed+ Strong+
PMODEL=models/player/bio_botovnetua/leaper.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie19.mdl
HEALTH=165.0
SPEED=290.0
GRAVITY=0.5
ATTACK=2.0
DEFENCE=0.067
HITSPEED=0.85
HITDELAY=0.35
REGENDLY=0.18
HITREGENDLY=2.0
KNOCKBACK=1.4

[FastLeaper]
DESC=Gravity-- Speed++ Strong-
PMODEL=models/player/bio_botovnetua/strongleaper_fix.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie12b.mdl
HEALTH=105.0
SPEED=310.0
GRAVITY=0.36
ATTACK=1.0
DEFENCE=0.05
HITSPEED=0.9
HITDELAY=0.35
REGENDLY=0.22
HITREGENDLY=2.5
KNOCKBACK=1.85

[FireLeaper]
DESC=Gravity-- Strong- NoBurn+
PMODEL=models/player/bio_botovnetua/fireleaper.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie20b.mdl
HEALTH=105.0
SPEED=250.0
GRAVITY=0.36
ATTACK=1.0
DEFENCE=0.065
HEDEFENCE=0.2
HITSPEED=0.88
HITDELAY=0.36
REGENDLY=0.22
HITREGENDLY=2.5
KNOCKBACK=1.85

[FlashLeaper]
DESC=Gravity- Speed+ NoFlash+
PMODEL=models/player/bio_botovnetua/flashleaper_fix2.mdl
TMODEL=models/player/bio_botovnetua/flashleaper_fix2T.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie21b.mdl
HEALTH=150.0
SPEED=290.0
GRAVITY=0.5
ATTACK=1.5
DEFENCE=0.065
HITSPEED=0.88
HITDELAY=0.36
REGENDLY=0.18
HITREGENDLY=2.0
KNOCKBACK=1.5

[Gonome]
DESC=Regen+ Speed+ Strong+
PMODEL=models/player/bio_botovnetua/gonome.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie9.mdl
HEALTH=175.0
SPEED=290.0
GRAVITY=1.0
ATTACK=2.0
DEFENCE=0.07
HITSPEED=0.86
HITDELAY=0.47
REGENDLY=0.13
HITREGENDLY=1.25
KNOCKBACK=1.0

[FastGonome]
DESC=Regen+++ Strong-
PMODEL=models/player/bio_botovnetua/fastgonome.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie4.mdl
HEALTH=125.0
SPEED=270.0
GRAVITY=1.0
ATTACK=1.0
DEFENCE=0.065
HITSPEED=0.89
HITDELAY=0.4
REGENDLY=0.09
HITREGENDLY=0.9
KNOCKBACK=1.3

[Alien]
DESC=Regen+ Speed+ Gravity-
PMODEL=models/player/bio_botovnetua/alien_new.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie16b.mdl
HEALTH=135.0
SPEED=290.0
GRAVITY=0.5
ATTACK=1.5
DEFENCE=0.06
HITSPEED=0.85
HITDELAY=0.37
REGENDLY=0.13
HITREGENDLY=1.0
KNOCKBACK=0.85

[Macara]
DESC=Regen+ Gravity- Strong+
PMODEL=models/player/bio_botovnetua/macara_fix.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie6.mdl
HEALTH=170.0
SPEED=260.0
GRAVITY=0.5
ATTACK=2.0
DEFENCE=0.078
HITSPEED=0.85
HITDELAY=0.42
REGENDLY=0.13
HITREGENDLY=1.5
KNOCKBACK=0.8

[Slum]
DESC=Regen++++ Gravity- Speed+++
PMODEL=models/player/bio_botovnetua/slum.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie8.mdl
HEALTH=95.0
SPEED=340.0
GRAVITY=0.5
ATTACK=1.0
DEFENCE=0.08
HITSPEED=0.85
HITDELAY=0.35
REGENDLY=0.08
HITREGENDLY=0.6
KNOCKBACK=1.5

[StrongPredator]
DESC=Gravity-- Strong++ Speed-
PMODEL=models/player/bio_botovnetua/predator.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie10.mdl
HEALTH=190.0
SPEED=235.0
GRAVITY=0.36
ATTACK=2.5
DEFENCE=0.075
HITSPEED=0.79
HITDELAY=0.4
REGENDLY=0.2
HITREGENDLY=2.5
KNOCKBACK=0.9

[RegenPredator]
DESC=Gravity-- Regen+
PMODEL=models/player/bio_botovnetua/predator2.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie11.mdl
HEALTH=135.0
SPEED=260.0
GRAVITY=0.36
ATTACK=1.5
DEFENCE=0.067
HITSPEED=0.86
HITDELAY=0.35
REGENDLY=0.13
HITREGENDLY=1.5
KNOCKBACK=1.3

[Predator]
DESC=Gravity-- Strong+
PMODEL=models/player/bio_botovnetua/predator3.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie18.mdl
HEALTH=170.0
SPEED=260.0
GRAVITY=0.36
ATTACK=2.0
DEFENCE=0.072
HITSPEED=0.83
HITDELAY=0.37
REGENDLY=0.18
HITREGENDLY=2.0
KNOCKBACK=1.1

[Hunter]
DESC=SpeedBullets+ Regen++
PMODEL=models/player/bio_botovnetua/hunter.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie7.mdl
HEALTH=125.0
SPEED=240.0
GRAVITY=1.0
ATTACK=1.5
DEFENCE=0.05
HITSPEED=650.0
HITDELAY=1.5
REGENDLY=0.1
HITREGENDLY=1.0
KNOCKBACK=1.0

[Diablo]
DESC=Speed+ Gravity- NoBurn+
PMODEL=models/player/bio_botovnetua/diablo_prefix3.mdl
TMODEL=models/player/bio_botovnetua/diablo_prefix3T.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie5.mdl
HEALTH=115.0
SPEED=285.0
GRAVITY=0.5
ATTACK=1.0
DEFENCE=0.048
HEDEFENCE=0.2
HITSPEED=0.86
HITDELAY=0.5
REGENDLY=0.18
HITREGENDLY=2.0
KNOCKBACK=1.5

[Nurse]
DESC=Gravity- NoFlash+ NoBurn+
PMODEL=models/player/bio_botovnetua/nurse_fix2.mdl
TMODEL=models/player/bio_botovnetua/nurse_fix2T.mdl
WMODEL=models/player/bio_botovnetua/knife/v_knife_zombie22.mdl
HEALTH=105.0
SPEED=260.0
GRAVITY=0.5
ATTACK=1.0
DEFENCE=0.045
HEDEFENCE=0.2
HITSPEED=0.89
HITDELAY=0.45
REGENDLY=0.18
HITREGENDLY=2.0
KNOCKBACK=1.5