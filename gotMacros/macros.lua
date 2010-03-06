--[[	$Id$	]]

--[==[ 0.89 with 2.30 base speed
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

gM_Macros = {
-------------------
--[[	GENERAL	]]--
-------------------
	["T2"] = {
		char = "Bonewraith, Dens, Cowdiak, Pimiko",
		icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
		body = [=[/cleartarget [exists]
			/targetenemy]=],
	},
	["CDs2"] = {
		char = "Cowdiak, Bonewraith",
		icon = [=[Interface\Icons\Spell_Shadow_LastingAfflictions]=],
		body = [=[/use Battlemaster's Determination
			/use Bloodlust Brooch]=],
		nosound = true,
	},
-------------------
--[[	HUNTER	]]--
-------------------
	["TGT"] = {
		char = "Caellian, Callysto, Dynames",
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
		char = "Caellian, Callysto, Dynames",
		icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
		body = [=[/cleartarget [exists]
			/assist [target=pet, exists]Pet
			/stopmacro [target=pettarget, exists]
			/targetenemy [target=pet, dead][target=pet, noexists]]=],
	},
	["CDs1"] = {
		char = "Caellian, Callysto, Dynames",
		icon = [=[Interface\Icons\Spell_Shadow_LastingAfflictions]=],
		body = [=[/cast [target=pettarget, exists] Kill Command
			/cast [target=pettarget, exists] Bestial Wrath
			/cast Blood Fury
			/cast Berserking]=],
		nosound = true,
	},
	["Foc"] = {
		char = "Caellian, Callysto, Dynames",
		icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
		body = [=[/castsequence [harm] reset=0 Hunter's Mark, null
			/focus [help, nodead]]=],
		blizzmacro = true,
	},
	["SvR"] = {
		char = "Caellian, Callysto, Dynames",
		show = "Auto Shot",
		body = [=[/click [noexists][noharm][dead] gotMacros_T1
			/click [combat, harm, nodead] gotMacros_CDs1
			/click [modifier, combat, harm, nodead] gotMacros_RfRd
			/click [harm, nodead] gotMacros_RotA]=],
		blizzmacro = true,
		perChar = true,
	},
	["MmR"] = {
		char = "Caellian, Callysto, Dynames",
		show = "Auto Shot",
		body = [=[/click [noexists][noharm][dead] gotMacros_T1
			/click [combat, harm, nodead] gotMacros_CDs1
			/click [modifier, combat, harm, nodead] gotMacros_RfRd
			/click [harm, nodead] gotMacros_RotB]=],
		blizzmacro = true,
		perChar = true,
	},
	["BmR"] = {
		char = "Caellian, Callysto, Dynames",
		show = "Auto Shot",
		body = [=[/click [noexists][noharm][dead] gotMacros_T1
			/click [combat, harm, nodead] gotMacros_CDs1
			/click [modifier, combat, harm, nodead] gotMacros_RfRd
			/click [harm, nodead] gotMacros_RotC]=],
		blizzmacro = true,
		perChar = true,
	},
	["RotA"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/cast !Auto Shot
			/click gotMacros_ExpS
			/click gotMacros_BlkA
			/click gotMacros_SrSa
			/click gotMacros_AimS
			/click gotMacros_StdS]=],
	},
	["RotB"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/cast !Auto Shot
			/click gotMacros_SrSb
			/click gotMacros_Mark
			/click gotMacros_AimS
			/cast Silencing Shot
			/click gotMacros_StdS]=],
	},
	["RotC"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/cast !Auto Shot
			/click gotMacros_SrSa
			/click gotMacros_MulS
			/click gotMacros_ArcS
			/click gotMacros_StdS]=],
	},
	["BlkA"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/castsequence reset=23.3 Black Arrow, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
	},
	["SrSa"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/castsequence reset=20.4/target Serpent Sting, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
	},
	["SrSb"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/castsequence reset=target Serpent Sting, Null]=],
	},
	["ExpS"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/castsequence reset=5.6 Explosive Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
	},
	["Mark"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/castsequence reset=9.3 Chimera Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
	},
	["AimS"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/castsequence reset=9.7 Aimed Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
	},
	["MulS"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/castsequence reset=9.7 Multi-Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
	},
	["ArcS"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/castsequence reset=5.8 Arcane Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
	},
	["StdS"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/cast Steady Shot]=],
	},
	["LnL"] = {
		char = "Caellian, Callysto, Dynames",
		show = "Explosive Shot",
		body = [=[/click [noexists][noharm][dead] gotMacros_T1
			/click [combat, harm, nodead] gotMacros_CDs1
			/castsequence reset=3 Explosive Shot, Steady Shot, Explosive Shot, Steady Shot]=],
		nosound = true,
		blizzmacro = true,
		perChar = true,
	},
	["MisD"] = {
		char = "Caellian, Callysto, Dynames",
		show = "Misdirection",
		body = [=[/cast [help][target=focus, help][target=pet, exists, nodead] Misdirection]=],
		blizzmacro = true,
		perChar = true,
	},
	["RfRd"] = {
		char = "Caellian, Callysto, Dynames",
		body = [=[/castsequence reset=3 Rapid Fire, Readiness, null]=],
	},
-------------------
--[[	ROGUE	]]--
-------------------
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
	},
-------------------
--[[	DRUID	]]--
-------------------
	["Bear"] = {
		char = "Cowdiak",
		show = "Mangle (Bear)(Rank 3)",
		body = [=[/click [noexists][noharm][dead] gotMacros_T2
			/click [combat, harm, nodead] gotMacros_CDs2
			/click [harm, nodead] gotMacros_RotD]=],
		blizzmacro = true,
		perChar = true,
	},
	["RotD"] = {
		char = "Cowdiak",
		show = "Mangle (Bear)(Rank 3)",
		body = [=[/startattack
			/click gotMacros_MgB
			/click gotMacros_Maul]=],
	},
	["MgB"] = {
		char = "Cowdiak",
		show = "Mangle (Bear)(Rank 3)",
		body = [=[/castsequence reset=target Mangle (Bear)(Rank 3), Mangle (Bear)(Rank 3), Lacerate]=],
		nosound = true,
	},
	["Maul"] = {
		char = "Cowdiak",
		show = "Maul",
		body = [=[/cast !Maul]=],
		nosound = true,
	},
-------------------
--[[	DEATH KNIGHT	]]--
-------------------
	["DPS"] = {
		char = "Dens",
		show = "Attaque Auto",
		body = [=[/click [noexists][noharm][dead] gotMacros_T2
			/castsequence [harm, nodead] reset=target/combat Toucher de glace, Frappe de peste, Frappe de sang, Frappe de sang, Frappe du fléau, Voile mortel]=],
		blizzmacro = true,
		perChar = true,
	},
	["BUFF"] = {
		char = "Dens",
		body = [=[/castsequence Cor de l'hiver, Bouclier d'os]=],
		blizzmacro = true,
		perChar = true,
	},
}