﻿--[==[ 0.94
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

[14:56] <Gotai> ./spew GetMouseFocus()
[14:56] <Gotai> Then look at the GetRegions() result and look for a texture field, probably something called SomethingSomethingIcon.
[14:56] <Gotai> Then /spew SomethingSomethingIcon:GetTexture()

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
		char = "ßone, Bonewraith, Cowdiak, Grimløck, Pimiko, Pimikow",
		icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
		body = [=[/cleartarget [exists]
			/targetenemy]=],
	},
-------------------
--[[	HUNTER	]]--
-------------------
	["TGT"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Hunter's Mark",
		body = [=[/targetenemy [noexists][noharm][dead]
			/cast [nopet]Call Pet
			/castsequence [harm]reset=target Hunter's Mark, null
			/petpassive [target=pettarget,exists] 
			/stopmacro [target=pettarget,exists] 
			/petdefensive
			/petattack]=],
		nosound = true,
		blizzmacro = true,
		perChar = true,
	},
	["T1"] = {
		char = "Caellian, Caellianaia, Dynames",
		icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
		body = [=[/cleartarget [exists]
			/assist [target=pet, exists]Pet
			/stopmacro [target=pettarget, exists]
			/targetenemy [target=pet, dead][target=pet, noexists]]=],
	},
	["CDs"] = {
		char = "Caellian, Caellianaia, Dynames",
		icon = [=[Interface\Icons\Spell_Shadow_LastingAfflictions]=],
		body = [=[/cast [target=pettarget, exists] Kill Command]=],
		nosound = true,
	},
	["Foc"] = {
		char = "Caellian, Caellianaia, Dynames",
		icon = [=[Interface\Icons\Ability_Hunter_MasterMarksman]=],
		body = [=[/castsequence [harm] reset=0 Hunter's Mark, null
			/focus [help, nodead]]=],
		blizzmacro = true,
	},
	["SvR"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Auto Shot",
		body = [=[/click [noexists][noharm][dead] gotMacros_T1
			/click [combat, harm, nodead] gotMacros_CDs
			/click [modifier, combat, harm, nodead] gotMacros_RfRd
			/click [harm, nodead] gotMacros_RotA]=],
		blizzmacro = true,
		perChar = true,
	},
	["MmR"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Auto Shot",
		body = [=[/click [noexists][noharm][dead] gotMacros_T1
			/click [combat, harm, nodead] gotMacros_CDs
			/click [modifier, combat, harm, nodead] gotMacros_RfRd
			/click [harm, nodead] gotMacros_RotB]=],
		blizzmacro = true,
		perChar = true,
	},
	["BmR"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Auto Shot",
		body = [=[/click [noexists][noharm][dead] gotMacros_T1
			/click [combat, harm, nodead] gotMacros_CDs
			/click [modifier, combat, harm, nodead] gotMacros_RfRd
			/click [harm, nodead] gotMacros_RotC]=],
		blizzmacro = true,
		perChar = true,
	},
	["RotA"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Steady Shot",
		body = [=[/cast !Auto Shot
			/click gotMacros_ExpS
			/click gotMacros_BlkA
			/click gotMacros_SerS
			/click gotMacros_AimS
			/click gotMacros_StdS]=],
		nosound = true,
		perChar = true,
	},
	["RotB"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Steady Shot",
		body = [=[/cast !Auto Shot
			/castsequence reset=target Serpent Sting, Null
			/click gotMacros_Mark
			/click gotMacros_AimS
			/cast Silencing Shot
			/click gotMacros_StdS]=],
		nosound = true,
		perChar = true,
	},
	["RotC"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Steady Shot",
		body = [=[/cast !Auto Shot
			/click gotMacros_SerS
			/click gotMacros_MulS
			/click gotMacros_ArcS
			/click gotMacros_StdS]=],
		nosound = true,
		perChar = true,
	},
	["BlkA"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Black Arrow",
		body = [=[/castsequence reset=23.3 Black Arrow, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		nosound = true,
		perChar = true,
	},
	["SerS"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Serpent Sting",
		body = [=[/castsequence reset=20.4/target Serpent Sting, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		nosound = true,
		perChar = true,
	},
	["ExpS"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Explosive Shot",
		body = [=[/castsequence reset=5.6 Explosive Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		nosound = true,
		perChar = true,
	},
	["Mark"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Chimera Shot",
		body = [=[/castsequence reset=9.3 Chimera Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		nosound = true,
		perChar = true,
	},
	["AimS"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Aimed Shot",
		body = [=[/castsequence reset=9.7 Aimed Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		nosound = true,
		perChar = true,
	},
	["MulS"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Multi-Shot",
		body = [=[/castsequence reset=9.7 Multi-Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		nosound = true,
		perChar = true,
	},
	["ArcS"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Arcane Shot",
		body = [=[/castsequence reset=5.8 Arcane Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot, !Auto Shot]=],
		nosound = true,
		perChar = true,
	},
	["StdS"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Steady Shot",
		body = [=[/cast Steady Shot]=],
		nosound = true,
		perChar = true,
	},
	["LnL"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Explosive Shot",
		body = [=[/click [noexists][noharm][dead] gotMacros_T1
			/click [combat, harm, nodead] gotMacros_CDs
			/castsequence reset=3 Explosive Shot, Steady Shot, Explosive Shot, Steady Shot]=],
		nosound = true,
		blizzmacro = true,
		perChar = true,
	},
	["MisD"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Misdirection",
		body = [=[/cast [help][target=focus, help][target=pet, exists, nodead] Misdirection]=],
		nosound = true,
		blizzmacro = true,
		perChar = true,
	},
	["RfRd"] = {
		char = "Caellian, Caellianaia, Dynames",
		show = "Rapid Fire",
		body = [=[/castsequence reset=3 Rapid Fire, Readiness, null]=],
		nosound = true,
		perChar = true,
	},
-------------------
--[[	ROGUE	]]--
-------------------
	["SinS"] = {
		char = "ßone, Bonewraith",
		show = "Sinister Strike",
		body = [=[/click [noexists][noharm][dead] gotMacros_T2
			/click [combat, harm, nodead] gotMacros_CDs
			/script if strfind(GetInventoryItemLink("player",16)or"", "Assassin's Blade") then EquipItemByName("Wingblade", 16) end
			/startattack
			/castsequence reset=target Sinister Strike, Sinister Strike, Sinister Strike, Eviscerate]=],
		nosound = true,
		blizzmacro = true,
		perChar = true,
	},
	["BacS"] = {
		char = "ßone, Bonewraith",
		show = "Backstab",
		body = [=[/click [noexists][noharm][dead] gotMacros_T2
			/click [combat, harm, nodead] gotMacros_CDs
			/script if strfind(GetInventoryItemLink("player",16)or"", "Wingblade") then EquipItemByName("Assassin's Blade", 16) end
			/startattack
			/castsequence reset=target Backstab, Backstab, Backstab, Eviscerate]=],
		nosound = true,
		blizzmacro = true,
		perChar = true,
	},
	["Amb"] = {
		char = "ßone, Bonewraith",
		show = "Ambush",
		body = [=[/click [noexists][noharm][dead] gotMacros_T2
			/script if strfind(GetInventoryItemLink("player",16)or"", "Wingblade") then EquipItemByName("Assassin's Blade", 16) end
			/cast [harm, nodead]Ambush]=],
		nosound = true,
		blizzmacro = true,
		perChar = true,
	},
	["Gar"] = {
		char = "ßone, Bonewraith",
		show = "Garrote",
		body = [=[/click [noexists][noharm][dead] gotMacros_T2
			/cast [harm, nodead]Garrote]=],
		nosound = true,
		blizzmacro = true,
		perChar = true,
	},
	["Sap"] = {
		char = "ßone, Bonewraith",
		show = "Sap",
		body = [=[/click [noexists][noharm][dead] gotMacros_T2
			/cast [harm, nodead]Sap]=],
		nosound = true,
		blizzmacro = true,
		perChar = true,
	},
}