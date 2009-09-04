local addons = {
	--[[---------------------------------------------------------------------------
								   -=( Base Addons )=-
		---------------------------------------------------------------------------
		These addons will load for every user, always.								--]]
	["base"] = {"!DamnBlizzardErrorFrame", "BadBoy", "BadBoy_CCleaner", "BadBoy_Levels", "Buffet-Lite", "Butsu",
		"caelAddOnsManager", "caelCCBreak", "caelCombatLog", "caelEmote", "caelFactions", "caelFonts", "caelInterrupt",
		"caelMinimap", "caelNamePlates", "caelCooldowns", "caelMap", "caelMedia", "caelPanels", "caelStats", "caelTooltips", "caelTweaks",
		"GetReagents-Lite", "gotChat", "gotMacros", "gotQuests",
		"oUF", "oUF_Caellian", "oUF_CombatFeedback", "oUF_DebuffHighlight", "oUF_Experience", "oUF_ReadyCheck", "oUF_Reputation", "oUF_SpellRange", "oUF_ThreatFeedback",
		"rActionBarStyler", "rActionButtonStyler", "RecBags", "RecDamageMeter", "RecScrollAreas", "Snoopy", "tekKompare"
	},
	--[[---------------------------------------------------------------------------
							  -=( Class-Specific Addons )=-
		---------------------------------------------------------------------------
		These addons will load for the specified class, always.						--]]
	["DEATHKNIGHT"] = {"oUF_RuneBar"},
	["HUNTER"] = {"BadPet", "caelMisdirection", "caelSmartAmmo", "caelTracking", "CreatureComforts"},
	["ROGUE"] = {"oUF_WeaponEnchant"},
	["SHAMAN"] = {"oUF_TotemBar", "oUF_WeaponEnchant"},

	--[[---------------------------------------------------------------------------
								-=( Task-Specific Addons )=-
		---------------------------------------------------------------------------
		These addons will load if you use their set name after the slash command.
		'/addonset raid' to load raid addons, for example.							--]]

	["raid"]	= {"DBM-Coliseum", "DBM-Core", "DBM-GUI", "DBM-Ulduar", "SimpleBossWhisperer"},
	["party"] = {},
	["pvp"] = {},
	["dev"] = {"Spew"},
}

local function EnableSet(set)
	if not addons[set] then return end		-- If the set does not exist, then bail.
	for k, v in pairs(addons[set]) do EnableAddOn(v) end		-- Load all addons in set
end

local function HandleSlash(set)
	for i = 1, GetNumAddOns() do DisableAddOn(i) end	-- Disable all addons (to ensure only what we want gets loaded)

	EnableSet("base")							-- Enable base addons
	if set then EnableSet(set) end				-- Enable requested set addons
	EnableSet(select(2, UnitClass("player")))	-- Enable all class-related addons

	ReloadUI()			-- Reload the UI for changes to take effect
end

SLASH_CAELADDONSMANAGER1 = '/addonset'
SlashCmdList.CAELADDONSMANAGER = HandleSlash