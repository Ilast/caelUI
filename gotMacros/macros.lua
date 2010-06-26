--[[	$Id$	]]

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

local multiClasses
local playerClass = caelLib.playerClass

if playerClass == "HUNTER" then
	gM_Macros = {
		["TGT"] = {
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
			icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
			body = [=[/cleartarget [exists]
				/assist [target=pet, exists]Pet
				/stopmacro [target=pettarget, exists]
				/targetenemy [target=pet, dead][target=pet, noexists]]=],
		},
		["CDsHunter"] = {
			body = [=[/cast [target=pettarget, exists] Kill Command
				/cast [target=pettarget, exists] Bestial Wrath]=],
			nosound = true,
		},
		["Foc"] = {
			icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
			body = [=[/castsequence [harm] reset=0 Hunter's Mark, null
				/focus [help, nodead]]=],
			blizzmacro = true,
			perChar = true,
		},
		["SvR"] = {
			show = "Auto Shot",
			body = [=[/click [noexists][noharm][dead] gotMacros_T1
				/click [combat, harm, nodead] gotMacros_CDsAll
				/click [combat, harm, nodead] gotMacros_CDsHunter
				/click [modifier, combat, harm, nodead] gotMacros_RfRd
				/click [harm, nodead] gotMacros_RotA]=],
			blizzmacro = true,
			perChar = true,
		},
		["MmR"] = {
			show = "Auto Shot",
			body = [=[/click [noexists][noharm][dead] gotMacros_T1
				/click [combat, harm, nodead] gotMacros_CDsAll
				/click [combat, harm, nodead] gotMacros_CDsHunter
				/click [modifier, combat, harm, nodead] gotMacros_RfRd
				/click [harm, nodead] gotMacros_RotB]=],
			blizzmacro = true,
			perChar = true,
		},
		["BmR"] = {
			show = "Auto Shot",
			body = [=[/click [noexists][noharm][dead] gotMacros_T1
				/click [combat, harm, nodead] gotMacros_CDsAll
				/click [combat, harm, nodead] gotMacros_CDsHunter
				/click [modifier, combat, harm, nodead] gotMacros_RfRd
				/click [harm, nodead] gotMacros_RotC]=],
			blizzmacro = true,
			perChar = true,
		},
		["RotA"] = {
			body = [=[/cast !Auto Shot
				/click gotMacros_ExpS
				/click gotMacros_BlkA
				/click gotMacros_SrSa
				/click gotMacros_AimS
				/click gotMacros_StdS]=],
		},
		["RotB"] = {
			body = [=[/cast !Auto Shot
				/click gotMacros_SrSb
				/click gotMacros_Mark
				/click gotMacros_AimS
				/cast Silencing Shot
				/click gotMacros_StdS]=],
		},
		["RotC"] = {
			body = [=[/cast !Auto Shot
				/click gotMacros_SrSa
				/click gotMacros_AimS
				/click gotMacros_ArcS
				/click gotMacros_StdS]=],
		},
		["BlkA"] = {
			body = [=[/castsequence reset=29.3 Black Arrow, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		},
		["SrSa"] = {
			body = [=[/castsequence reset=20.4/target Serpent Sting, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		},
		["SrSb"] = {
			body = [=[/castsequence reset=target Serpent Sting, null]=],
		},
		["ExpS"] = {
			body = [=[/castsequence reset=5.6 Explosive Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		},
		["Mark"] = {
			body = [=[/castsequence reset=9.3 Chimera Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		},
		["AimS"] = {
			body = [=[/castsequence reset=9.7 Aimed Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		},
		["MulS"] = {
			body = [=[/castsequence reset=9.7 Multi-Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		},
		["ArcS"] = {
			body = [=[/castsequence reset=5.8 Arcane Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		},
		["StdS"] = {
			body = [=[/cast Steady Shot]=],
		},
		["LnL"] = {
			show = "Explosive Shot",
			body = [=[/click [noexists][noharm][dead] gotMacros_T1
				/click [combat, harm, nodead] gotMacros_CDsAll
				/click [combat, harm, nodead] gotMacros_CDsHunter
				/castsequence reset=3 Steady Shot, Explosive Shot, Steady Shot, Explosive Shot]=],
			nosound = true,
			blizzmacro = true,
			perChar = true,
		},
		["MisD"] = {
			show = "Misdirection",
			body = [=[/cast [help][target=focus, help][target=pet, exists, nodead] Misdirection]=],
			blizzmacro = true,
			perChar = true,
		},
		["RfRd"] = {
			body = [=[/castsequence reset=3 Rapid Fire, Readiness, null]=],
		},
		["KillS"] = {
			show = "Kill Shot",
			body = [=[/Stopattack
				/Stopcasting
				/cast Kill Shot]=],
			blizzmacro = true,
			perChar = true,
		},
		["Tranq"] = {
			show = "Tranquilizing shot",
			body = [=[/cast [target=mouseover, exists] Tranquilizing Shot]=],
			blizzmacro = true,
			perChar = true,
		},
	}
elseif playerClass == "DRUID" then
	gM_Macros = {
		["CatF"] = {
			show = "[stealth]Pounce; [nostealth]Mangle (Cat)(Rank 5)",
			body = [=[/click [noexists][noharm][dead] gotMacros_T2
				/click [modifier, combat, harm, nodead] gotMacros_CDsDruid
				/click [harm, nodead, stealth] gotMacros_DpsFs; [harm, nodead, nostealth] gotMacros_DpsFns]=],
			blizzmacro = true,
			perChar = true,
		},
		["DpsFs"] = {
			body = [=[/cast Pounce]=],
		},
		["DpsFns"] = {
			body = [=[/castsequence reset=combat/target/1 Rake, Mangle (Cat)(Rank 5), Mangle (Cat)(Rank 5), Mangle (Cat)(Rank 5), Mangle (Cat)(Rank 5)]=],
		},
		["CatB"] = {
			show = "[stealth]Ravage; [nostealth]Shred",
			body = [=[/click [noexists][noharm][dead] gotMacros_T2
				/click [modifier, combat, harm, nodead] gotMacros_CDsDruid
				/click [harm, nodead, stealth] gotMacros_DpsBs; [harm, nodead, nostealth] gotMacros_DpsBns]=],
			blizzmacro = true,
			perChar = true,
		},
		["DpsBs"] = {
			body = [=[/cast Ravage]=],
		},
		["DpsBns"] = {
			body = [=[/cast Shred]=],
		},
		["Bear"] = {
			show = "Mangle (Bear)(Rank 5)",
			body = [=[/click [noexists][noharm][dead] gotMacros_T2
				/click [harm, nodead] gotMacros_Tank]=],
			blizzmacro = true,
			perChar = true,
		},
		["Tank"] = {
			show = "Mangle (Bear)(Rank 5)",
			body = [=[/startattack
				/click gotMacros_MgB
				/click gotMacros_Maul]=],
		},
		["MgB"] = {
			body = [=[/castsequence reset=target Mangle (Bear)(Rank 5), Lacerate]=],
		},
		["Swipe"] = {
			show = "Swipe (Bear)",
			body = [=[/cast Swipe (Bear)
				/click gotMacros_Maul]=],
			blizzmacro = true,
			perChar = true,
		},
		["Maul"] = {
			body = [=[/cast !Maul]=],
		},
		["CDsDruid"] = {
			body = [=[/cast Berserk
					/cast Tiger's Fury]=],
			nosound = true,
		}
	}
elseif playerClass == "ROGUE" then
	gM_Macros = {
		["SinS"] = {
			show = "Sinister Strike",
			body = [=[/click [noexists][noharm][dead] gotMacros_T2
				/click [combat, harm, nodead] gotMacros_CDsAll
				/script if strfind(GetInventoryItemLink("player",16)or"", "Assassin's Blade") then EquipItemByName("Wingblade", 16) end
				/startattack
				/castsequence reset=target Sinister Strike, Sinister Strike, Sinister Strike, Eviscerate]=],
			blizzmacro = true,
			perChar = true,
		},
		["BacS"] = {
			show = "Backstab",
			body = [=[/click [noexists][noharm][dead] gotMacros_T2
				/click [combat, harm, nodead] gotMacros_CDsAll
				/script if strfind(GetInventoryItemLink("player",16)or"", "Wingblade") then EquipItemByName("Assassin's Blade", 16) end
				/startattack
				/castsequence reset=target Backstab, Backstab, Backstab, Eviscerate]=],
			blizzmacro = true,
			perChar = true,
		},
		["Amb"] = {
			show = "Ambush",
			body = [=[/click [noexists][noharm][dead] gotMacros_T2
				/script if strfind(GetInventoryItemLink("player",16)or"", "Wingblade") then EquipItemByName("Assassin's Blade", 16) end
				/cast [harm, nodead] Ambush]=],
			blizzmacro = true,
			perChar = true,
		},
		["Gar"] = {
			show = "Garrote",
			body = [=[/click [noexists][noharm][dead] gotMacros_T2
				/cast [harm, nodead] Garrote]=],
			blizzmacro = true,
			perChar = true,
		},
		["Sap"] = {
			show = "Sap",
			body = [=[/click [noexists][noharm][dead] gotMacros_T2
				/cast [harm, nodead] Sap]=],
			blizzmacro = true,
			perChar = true,
		}
	}
elseif playerClass == "PALADIN" then
	gM_Macros = {
		["DPS"] = {
			show = "Auto Attack",
			body = [=[/click [noexists][noharm][dead] gotMacros_T2
				/click [combat, harm, nodead] gotMacros_CDsAll
				/click [combat, harm, nodead] gotMacros_CDsPaladin
				/click gotMacros_RetR]=],
			blizzmacro = true,
			perChar = true,
		},
		["TANK"] = {
			show = "Auto Attack",
			body = [=[/click [noexists][noharm][dead] gotMacros_T2
				/click [combat, harm, nodead] gotMacros_CDsAll
				/click [combat, harm, nodead] gotMacros_CDsPaladin
				/click gotMacros_ProtR]=],
			blizzmacro = true,
			perChar = true,
		},
		["RetR"] = {
			body = [=[/startattack [harm, nodead]
				/cast [harm, nodead] Crusader Strike]=],
		},
		["ProtR"] = {
			body = [=[/startattack [harm, nodead]
				/castsequence [harm, nodead] reset=combat Holy Shield, Hammer of the Righteous, Judgement of Wisdom]=],
		},
		["CDsPaladin"] = {
			body = [=[/cast Avenging Wrath]=],
			nosound = true,
		}
	}
end

multiClasses = {
	["WDI"] = {
		body = [=[/2 [[ - >> We Did It << - ]] Recrute
			/2 Avancée: ICC10-HM:11/12, ICC25-HM:7/12
			/2 4 soirs de présence requis par semaine
			/2 Prio: War Def(1), Pal Heal(1), Cham Heal(1)
			/2 Toute autre candidature sera aussi étudiée
			/2 Visitez: http://www.guilde-wedidit.fr]=],
		blizzmacro = true,
	},
	["T2"] = {
		body = [=[/cleartarget [exists]
			/targetenemy]=],
	},
	["CDsAll"] = {
		body = [=[/cast Blood Fury
				/cast Berserking
				/use 10
				/use 13
				/use 14]=],
		nosound = true,
	}
}

if multiClasses then
	if not gM_Macros then
		gM_Macros = {}
	end

	for k, v in pairs(multiClasses) do
		gM_Macros[k] = v
	end

	multiClasses = nil
end