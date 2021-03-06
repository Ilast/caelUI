﻿--[[	$Id: macros.lua 1225 2010-06-11 21:35:23Z sdkyron@gmail.com $	]]

--[==[ 0.89 with 2.30 base speed, 1.16 with 2.57 base speed (has to be verified)
	gM_Macros = {
		name = {		Macroname, these need to be unique
			body,		Macrobody, 1023 chars max. Use either linebreaks in long comments [=[ ]=] or \n.
			blizzmacro,	1/nil - Specifies whether or not you want to create a /click macro for it.
			perChar,	1/nil - Specifies whether you want the macro to be char specific.
					If char specific macros are full, it will be created as general by default.
			show,		When set uses #showtooltip in combination with the value of this field.
					You should NOT include #showtooltip, just the condition.
			char,		List the playernames (case-sensitive) of the characters for whom this macro
					should be used. Defaults to all chars when not set.
			icon,		Texture path or macro icon index. Defaults to 1 (question mark) when not set or invalid.
		},
	}

	example:
	
	gM_Macros = {
		["test"] = {
			body = [=[/run print("Hi!")
				/run print("Apples!")]=],
			blizzmacro = true,
		},
		["someothertest"] = {
			body = "/run print('apples')\n/run print('oranges')",
			blizzmacro = true,
			perChar = true,
		},
	}
]==]--

local multiLocales
local locale = caelLib.locale
local playerClass = caelLib.playerClass

if locale == "enUS" then
	if playerClass == "HUNTER" then
		gM_Macros = {
			["WDI"] = {
				char = "Cowdiak, Callysto",
				body = [=[/2 [[ -- >> We Did It << -- ]]
					/2 Ouvre ses portes aux recrutements.
					/2 Avancée PVE : ICC10-HM: 11/12, ICC25-HM: 5/12
					/2 4 soirs de présence requis par semaine.
					/2 Toutes les candidatures seront étudiées.
					/2 Rendez-vous sur: http://www.guilde-wedidit.fr
					/2 ou contactez nous directement. Bonne journée !]=],
				blizzmacro = true,
			},
			["TGT"] = {
				char = "Caellian, Callysto",
				show = "Hunter's Mark",
				body = [=[/targetenemy [noexists][noharm][dead]
					/cast [nopet]Call Pet
					/castsequence [harm]reset=target Hunter's Mark, null
					/petpassive [target=pettarget,exists]
					/stopmacro [target=pettarget,exists]
					/petdefensive
					/petattack]=],
				blizzmacro = true,
				perChar = true,
			},
			["T1"] = {
				char = "Caellian, Callysto",
				icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
				body = [=[/cleartarget [exists]
					/assist [target=pet, exists]Pet
					/stopmacro [target=pettarget, exists]
					/targetenemy [target=pet, dead][target=pet, noexists]]=],
			},
			["CDs1"] = {
				char = "Caellian, Callysto",
				icon = [=[Interface\Icons\Spell_Shadow_LastingAfflictions]=],
				body = [=[/cast [target=pettarget, exists] Kill Command
					/cast [target=pettarget, exists] Bestial Wrath
					/cast Blood Fury
					/cast Berserking
					/use 10]=],
				nosound = true,
			},
			["Foc"] = {
				char = "Caellian, Callysto",
				icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
				body = [=[/castsequence [harm] reset=0 Hunter's Mark, null
					/focus [help, nodead]]=],
				blizzmacro = true,
			},
			["SvR"] = {
				char = "Caellian, Callysto",
				show = "Auto Shot",
				body = [=[/click [noexists][noharm][dead] gotMacros_T1
					/click [combat, harm, nodead] gotMacros_CDs1
					/click [modifier, combat, harm, nodead] gotMacros_RfRd
					/click [harm, nodead] gotMacros_RotA]=],
				blizzmacro = true,
				perChar = true,
			},
			["MmR"] = {
				char = "Caellian, Callysto",
				show = "Auto Shot",
				body = [=[/click [noexists][noharm][dead] gotMacros_T1
					/click [combat, harm, nodead] gotMacros_CDs1
					/click [modifier, combat, harm, nodead] gotMacros_RfRd
					/click [harm, nodead] gotMacros_RotB]=],
				blizzmacro = true,
				perChar = true,
			},
			["BmR"] = {
				char = "Caellian, Callysto",
				show = "Auto Shot",
				body = [=[/click [noexists][noharm][dead] gotMacros_T1
					/click [combat, harm, nodead] gotMacros_CDs1
					/click [modifier, combat, harm, nodead] gotMacros_RfRd
					/click [harm, nodead] gotMacros_RotC]=],
				blizzmacro = true,
				perChar = true,
			},
			["RotA"] = {
				char = "Caellian, Callysto",
				body = [=[/cast !Auto Shot
					/click gotMacros_ExpS
					/click gotMacros_BlkA
					/click gotMacros_SrSa
					/click gotMacros_AimS
					/click gotMacros_StdS]=],
			},
			["RotB"] = {
				char = "Caellian, Callysto",
				body = [=[/cast !Auto Shot
					/click gotMacros_SrSb
					/click gotMacros_Mark
					/click gotMacros_AimS
					/cast Silencing Shot
					/click gotMacros_StdS]=],
			},
			["RotC"] = {
				char = "Caellian, Callysto",
				body = [=[/cast !Auto Shot
					/click gotMacros_SrSa
					/click gotMacros_AimS
					/click gotMacros_ArcS
					/click gotMacros_StdS]=],
			},
			["BlkA"] = {
				char = "Caellian, Callysto",
				body = [=[/castsequence reset=29.3 Black Arrow, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
			},
			["SrSa"] = {
				char = "Caellian, Callysto",
				body = [=[/castsequence reset=20.4/target Serpent Sting, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
			},
			["SrSb"] = {
				char = "Caellian, Callysto",
				body = [=[/castsequence reset=target Serpent Sting, null]=],
			},
			["ExpS"] = {
				char = "Caellian, Callysto",
				body = [=[/castsequence reset=5.6 Explosive Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
			},
			["Mark"] = {
				char = "Caellian, Callysto",
				body = [=[/castsequence reset=9.3 Chimera Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
			},
			["AimS"] = {
				char = "Caellian, Callysto",
				body = [=[/castsequence reset=9.7 Aimed Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
			},
			["MulS"] = {
				char = "Caellian, Callysto",
				body = [=[/castsequence reset=9.7 Multi-Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
			},
			["ArcS"] = {
				char = "Caellian, Callysto",
				body = [=[/castsequence reset=5.8 Arcane Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
			},
			["StdS"] = {
				char = "Caellian, Callysto",
				body = [=[/cast Steady Shot]=],
			},
			["LnL"] = {
				char = "Caellian, Callysto",
				show = "Explosive Shot",
				body = [=[/click [noexists][noharm][dead] gotMacros_T1
					/click [combat, harm, nodead] gotMacros_CDs1
					/castsequence reset=3 Steady Shot, Explosive Shot, Steady Shot, Explosive Shot]=],
				nosound = true,
				blizzmacro = true,
				perChar = true,
			},
			["MisD"] = {
				char = "Caellian, Callysto",
				show = "Misdirection",
				body = [=[/cast [help][target=focus, help][target=pet, exists, nodead] Misdirection]=],
				blizzmacro = true,
				perChar = true,
			},
			["RfRd"] = {
				char = "Caellian, Callysto",
				body = [=[/castsequence reset=3 Rapid Fire, Readiness, null]=],
			},
			["KillS"] = {
				char = "Caellian, Callysto",
				show = "Kill Shot",
				body = [=[/Stopattack
					/Stopcasting
					/cast Kill Shot]=],
				blizzmacro = true,
				perChar = true,
			},
			["Tranq"] = {
				char = "Caellian, Callysto",
				show = "Tranquilizing shot",
				body = [=[/cast [target=mouseover, exists] Tranquilizing Shot]=],
				blizzmacro = true,
				perChar = true,
			},
		}
	elseif playerClass == "DRUID" then
		gM_Macros = {
			["CatF"] = {
				char = "Cowdiak",
				show = "[stealth]Pounce; [nostealth]Mangle (Cat)(Rank 5)",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/click [modifier, combat, harm, nodead] gotMacros_DruidCD
					/click [harm, nodead, stealth] gotMacros_DpsFs; [harm, nodead, nostealth] gotMacros_DpsFns]=],
				nosound = true,
				blizzmacro = true,
				perChar = true,
			},
			["DpsFs"] = {
				char = "Cowdiak",
				body = [=[/cast Pounce]=],
			},
			["DpsFns"] = {
				char = "Cowdiak",
				body = [=[/castsequence reset=combat/target/1 Rake, Mangle (Cat)(Rank 5), Mangle (Cat)(Rank 5), Mangle (Cat)(Rank 5), Mangle (Cat)(Rank 5)]=],
			},
			["CatB"] = {
				char = "Cowdiak",
				show = "[stealth]Ravage; [nostealth]Shred",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/click [modifier, combat, harm, nodead] gotMacros_DruidCD
					/click [harm, nodead, stealth] gotMacros_DpsBs; [harm, nodead, nostealth] gotMacros_DpsBns]=],
				nosound = true,
				blizzmacro = true,
				perChar = true,
			},
			["DpsBs"] = {
				char = "Cowdiak",
				body = [=[/cast Ravage]=],
			},
			["DpsBns"] = {
				char = "Cowdiak",
				body = [=[/cast Shred]=],
			},
			["Bear"] = {
				char = "Cowdiak",
				show = "Mangle (Bear)(Rank 5)",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/click [harm, nodead] gotMacros_Tank]=],
				blizzmacro = true,
				perChar = true,
			},
			["Tank"] = {
				char = "Cowdiak",
				show = "Mangle (Bear)(Rank 5)",
				body = [=[/startattack
					/click gotMacros_MgB
					/click gotMacros_Maul]=],
			},
			["MgB"] = {
				char = "Cowdiak",
				body = [=[/castsequence reset=target Mangle (Bear)(Rank 5), Lacerate]=],
			},
			["Swipe"] = {
				char = "Cowdiak",
				show = "Swipe (Bear)",
				body = [=[/cast Swipe (Bear)
					/click gotMacros_Maul]=],
				blizzmacro = true,
				perChar = true,
			},
			["Maul"] = {
				char = "Cowdiak",
				body = [=[/cast !Maul]=],
			},
			["DruidCD"] = {
				char = "Cowdiak",
				show = "",
				body = [=[/cast Berserk
						/cast Tiger's Fury]=],
				nosound = true,
				perChar = true,
			}
		}
	elseif playerClass == "ROGUE" then
		gM_Macros = {
			["SinS"] = {
				char = "Bonewraith",
				show = "Sinister Strike",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/click [combat, harm, nodead] gotMacros_CDs2
					/script if strfind(GetInventoryItemLink("player",16)or"", "Assassin's Blade") then EquipItemByName("Wingblade", 16) end
					/startattack
					/castsequence reset=target Sinister Strike, Sinister Strike, Sinister Strike, Eviscerate]=],
				nosound = true,
				blizzmacro = true,
				perChar = true,
			},
			["BacS"] = {
				char = "Bonewraith",
				show = "Backstab",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/click [combat, harm, nodead] gotMacros_CDs2
					/script if strfind(GetInventoryItemLink("player",16)or"", "Wingblade") then EquipItemByName("Assassin's Blade", 16) end
					/startattack
					/castsequence reset=target Backstab, Backstab, Backstab, Eviscerate]=],
				nosound = true,
				blizzmacro = true,
				perChar = true,
			},
			["Amb"] = {
				char = "Bonewraith",
				show = "Ambush",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/script if strfind(GetInventoryItemLink("player",16)or"", "Wingblade") then EquipItemByName("Assassin's Blade", 16) end
					/cast [harm, nodead] Ambush]=],
				nosound = true,
				blizzmacro = true,
				perChar = true,
			},
			["Gar"] = {
				char = "Bonewraith",
				show = "Garrote",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/cast [harm, nodead] Garrote]=],
				nosound = true,
				blizzmacro = true,
				perChar = true,
			},
			["Sap"] = {
				char = "Bonewraith",
				show = "Sap",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/cast [harm, nodead] Sap]=],
				nosound = true,
				blizzmacro = true,
				perChar = true,
			}
		}
	elseif playerClass == "PALADIN" then
		gM_Macros = {
			["DPS"] = {
				char = "Calyr",
				show = "Auto Attack",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/click [combat, harm, nodead] gotMacros_CDs2
					/click gotMacros_RetR]=],
				blizzmacro = true,
				perChar = true,
			},
			["TANK"] = {
				char = "Calyr",
				show = "Auto Attack",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/click [combat, harm, nodead] gotMacros_CDs2
					/click gotMacros_ProtR]=],
				blizzmacro = true,
				perChar = true,
			},
			["RetR"] = {
				char = "Calyr",
				body = [=[/startattack [harm, nodead]
					/cast [harm, nodead] Crusader Strike]=],
			},
			["ProtR"] = {
				char = "Calyr",
				body = [=[/startattack [harm, nodead]
					/castsequence [harm, nodead] reset=combat Holy Shield, Hammer of the Righteous, Judgement of Wisdom]=],
			}
		}
	elseif playerClass == "DEATHKNIGHT" then
		gM_Macros = {
			["DPS"] = {
				char = "Dkdens",
				show = "Attaque Auto",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/click [combat, harm, nodead] gotMacros_CDs2
					/castsequence [harm, nodead] reset=target/combat Plague Strike, Ice Touch, Blood Strike, Scourge Strike, Blood Strike, Scourge Strike, Blood Strike, Scourge Strike, Blood Strike]=],
				blizzmacro = true,
				perChar = true,
			},
			["BUFF"] = {
				char = "Dkdens",
				show = "Peste de sang",
				body = [=[/castsequence Horn of Winter, Bone Shield]=],
				blizzmacro = true,
				perChar = true,
			}
		}	
	end
elseif locale == "frFR" then
	if playerClass == "DEATHKNIGHT" then
		gM_Macros = {
			["DPS"] = {
				char = "Dkdens",
				show = "Attaque Auto",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/click [combat, harm, nodead] gotMacros_CDs2
					/castsequence [harm, nodead] reset=target/combat Frappe de peste, Toucher de glace, Frappe de sang,  Frappe de sang, Frappe du fléau, Frappe du fléau, Frappe de sang, Frappe de sang]=],
				blizzmacro = true,
				perChar = true,
			},
			["TANK"] = {
				char = "Dkdens",
				show = "Attaque Auto",
				body = [=[/click [noexists][noharm][dead] gotMacros_T2
					/click [combat, harm, nodead] gotMacros_CDs2
					/castsequence [harm, nodead] reset=target/combat Toucher de glace, Frappe de peste, Frappe au coeur, Frappe au coeur, Frappe de mort, Voile mortel]=],
				blizzmacro = true,
				perChar = true,
			},
			["BUFF"] = {
				char = "Dkdens",
				show = "Peste de sang",
				body = [=[/castsequence Cor de l'hiver, Bouclier d'os]=],
				blizzmacro = true,
				perChar = true,
			}
		}
	elseif playerClass == "HUNTER" then
		gM_Macros = {
			["TGT"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Marque du chasseur",
				body = [=[/targetenemy [noexists][noharm][dead]
					/cast [nopet]Appel du familier
					/castsequence [harm]reset=target Marque du chasseur, null
					/petpassive [target=pettarget,exists] 
					/stopmacro [target=pettarget,exists] 
					/petdefensive
					/petattack]=],
				nosound = true,
				blizzmacro = true,
				perChar = true,
			},
			["T1"] = {
				char = "Caellian, Callysto, Eling, Heria",
				icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
				body = [=[/cleartarget [exists]
					/assist [target=pet, exists]Pet
					/stopmacro [target=pettarget, exists]
					/targetenemy [target=pet, dead][target=pet, noexists]]=],
			},
			["CDs1"] = {
				char = "Caellian, Callysto, Eling, Heria",
				icon = [=[Interface\Icons\Spell_Shadow_LastingAfflictions]=],
				body = [=[/cast [target=pettarget, exists] Kill Command
					/cast Berserker]=],
				nosound = true,
			},
			["Foc"] = {
				char = "Caellian, Callysto, Eling, Heria",
				icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
				body = [=[/castsequence [harm] reset=0 Hunter's Mark, null
					/focus [help, nodead]]=],
				blizzmacro = true,
			},
			["SvR"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Auto Shot",
				body = [=[/click [noexists][noharm][dead] gotMacros_T1
					/click [combat, harm, nodead] gotMacros_CDs1
					/click [modifier, combat, harm, nodead] gotMacros_RfRd
					/click [harm, nodead] gotMacros_RotA]=],
				blizzmacro = true,
				perChar = true,
			},
			["MmR"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Auto Shot",
				body = [=[/click [noexists][noharm][dead] gotMacros_T1
					/click [combat, harm, nodead] gotMacros_CDs1
					/click [modifier, combat, harm, nodead] gotMacros_RfRd
					/click [harm, nodead] gotMacros_RotB]=],
				blizzmacro = true,
				perChar = true,
			},
			["BmR"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Tir Automatique",
				body = [=[/click [noexists][noharm][dead] gotMacros_T1
					/click [combat, harm, nodead] gotMacros_CDs1
					/click [modifier, combat, harm, nodead] gotMacros_RfRd
					/click [harm, nodead] gotMacros_RotC]=],
				blizzmacro = true,
				perChar = true,
			},
			["RotA"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Tir assuré",
				body = [=[/cast !Tir automatique
					/click gotMacros_ExpS
					/click gotMacros_BlkA
					/click gotMacros_SrSa
					/click gotMacros_AimS
					/click gotMacros_StdS]=],
				nosound = true,
				perChar = true,
			},
			["RotB"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Tir assuré",
				body = [=[/cast !Tir automatique
					/click gotMacros_SrSb
					/click gotMacros_Mark
					/click gotMacros_AimS
					/cast Silencing Shot
					/click gotMacros_StdS]=],
				nosound = true,
				perChar = true,
			},
			["RotC"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Tir assuré",
				body = [=[/cast !Tir automatique
					/click gotMacros_SrSa
					/click gotMacros_AimS
					/click gotMacros_ArcS
					/click gotMacros_StdS]=],
				nosound = true,
				perChar = true,
			},
			["BlkA"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Flèche noir",
				body = [=[/castsequence reset=23.3 Black Arrow, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique]=],
				nosound = true,
				perChar = true,
			},
			["SrSa"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Morsure de serpent",
				body = [=[/castsequence reset=20.4/target Morsure de serpent, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique]=],
				nosound = true,
				perChar = true,
			},
			["SrSb"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Morsure de serpent",
				body = [=[/castsequence reset=target Morsure de serpent, Null]=],
				nosound = true,
				perChar = true,
			},
			["ExpS"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Tir explosif",
				body = [=[/castsequence reset=5.6 Tir explosif, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique]=],
				nosound = true,
				perChar = true,
			},
			["Mark"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Tir de la chimère",
				body = [=[/castsequence reset=9.3 Tir de la chimère, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique]=],
				nosound = true,
				perChar = true,
			},
			["AimS"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Visée",
				body = [=[/castsequence reset=9.7 Visée, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique]=],
				nosound = true,
				perChar = true,
			},
			["MulS"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Flèches multiples",
				body = [=[/castsequence reset=9.7 Flèches multiples, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique]=],
				nosound = true,
				perChar = true,
			},
			["ArcS"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Tir des arcanes",
				body = [=[/castsequence reset=5.8 Tir des arcanes, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique, !Tir automatique]=],
				nosound = true,
				perChar = true,
			},
			["StdS"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Tir assuré",
				body = [=[/cast Tir assuré]=],
				nosound = true,
				perChar = true,
			},
			["LnL"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Tir explosif",
				body = [=[/click [noexists][noharm][dead] gotMacros_T1
					/click [combat, harm, nodead] gotMacros_CDs1
					/castsequence reset=3 Explosive Shot, Tir assuré, Explosive Shot, Tir assuré]=],
				nosound = true,
				blizzmacro = true,
				perChar = true,
			},
			["MisD"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Détournement",
				body = [=[/cast [help][target=focus, help][target=pet, exists, nodead] Détournement]=],
				nosound = true,
				blizzmacro = true,
				perChar = true,
			},
			["RfRd"] = {
				char = "Caellian, Callysto, Eling, Heria",
				show = "Tir rapide",
				body = [=[/castsequence reset=3 Tir rapide, Promptitude, null]=],
				nosound = true,
				perChar = true,
			}
		}
	end
end

if locale == "enUS" then
	multiLocales = {
		["WDI"] = {
			char = "Cowdiak, Callysto",
			body = [=[/2 [[ -- >> We Did It << -- ]]
				/2 Ouvre ses portes aux recrutements.
				/2 Avancée PVE : ICC10-HM: 11/12, ICC25-HM: 5/12
				/2 4 soirs de présence requis par semaine.
				/2 Toutes les candidatures seront étudiées.
				/2 Rendez-vous sur: http://www.guilde-wedidit.fr
				/2 ou contactez nous directement. Bonne journée !]=],
			blizzmacro = true,
		},
		["T2"] = {
			char = "Bonewraith, Calyr, Dkdens, Cowdiak, Pimiko",
			icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
			body = [=[/cleartarget [exists]
				/targetenemy]=],
		},
		["CDs2"] = {
			char = "Cowdiak, Bonewraith, Calyr, Dkdens",
			icon = [=[Interface\Icons\Spell_Shadow_LastingAfflictions]=],
			body = [=[/cast Avenging Wrath
				/use 13
				/use 14]=],
			nosound = true,
		}
	}
elseif locale == "frFR" then
	multiLocales = {
		["T2"] = {
			char = "Bonewraith, Calyr, Dkdens, Cowdiak, Pimiko",
			icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
			body = [=[/cleartarget [exists]
				/targetenemy]=],
		},
		["CDs2"] = {
			char = "Cowdiak, Bonewraith, Calyr, Dkdens",
			icon = [=[Interface\Icons\Spell_Shadow_LastingAfflictions]=],
			body = [=[/cast Fureur sanguinaire
				/use 13
				/use 14]=],
			nosound = true,
		}
	}
end

if playerClass ~= "HUNTER" then
	if not gM_Macros then
		gM_Macros = {}
	end

	for k, v in pairs(multiLocales) do
		gM_Macros[k] = v
	end
end
multiLocales = nil