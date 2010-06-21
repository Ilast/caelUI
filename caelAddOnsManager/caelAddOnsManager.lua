--[[	$Id$	]]

local addons = {
	--[[---------------------------------------------------------------------------
								   -=( Base Addons )=-
		---------------------------------------------------------------------------
		These addons will load for every user, always.								--]]
	["base"] = {"!recBug", "BadBoy",
		"caelActionBars", "caelAddOnsManager", "caelBags", "caelBuffet", "caelCCBreak", "caelChat", "caelCombatLog", "caelCore", "caelEmote", "caelFactions", "caelInterrupt",
		"caelMinimap", "caelNameplates", "caelCooldowns", "caelDataFeeds", "caelLib", "caelMap", "caelMedia", "caelPanels", "caelThreat", "caelTooltips",
		"gotChat", "gotMacros",
		"oUF", "oUF_Caellian", "oUF_CombatFeedback", "oUF_ReadyCheck", "oUF_SpellRange",
		"recReagents", "recScrollAreas", "recTimers", "Snoopy"
	},
	--[[---------------------------------------------------------------------------
							  -=( Class-Specific Addons )=-
		---------------------------------------------------------------------------
		These addons will load for the specified class, always.						--]]
	["DEATHKNIGHT"] = {"oUF_RuneBar"},
	["HUNTER"] = {"BadPet", "caelMisdirection", "caelSmartAmmo", "caelPetCare", "caelTracking"},
	["ROGUE"] = {"oUF_WeaponEnchant"},
	["SHAMAN"] = {"oUF_TotemBar", "oUF_WeaponEnchant"},

	--[[---------------------------------------------------------------------------
								-=( Task-Specific Addons )=-
		---------------------------------------------------------------------------
		These addons will load if you use their set name after the slash command.
		'/addonset raid' to load raid addons, for example.							--]]

	["raid"]	= {"BigWigs", "BigWigs_Citadel", "BigWigs_Coliseum", "BigWigs_Core", "BigWigs_Options", "BigWigs_Plugins", "BigWigs_Ulduar", "caelBossWhisperer", "caelDefile", "recDamageMeter", "recThreatMeter"},
	["party"] = {"recDamageMeter", "recThreatMeter"},
	["pvp"] = {},
	["dev"] = {},
}

local enableSet = function(set)
	if not addons[set] then return end		-- If the set does not exist, then bail.
	for k, v in pairs(addons[set]) do EnableAddOn(v) end		-- Load all addons in set
end

local handleSlash = function(set)
	for i = 1, GetNumAddOns() do DisableAddOn(i) end	-- Disable all addons (to ensure only what we want gets loaded)

	enableSet("base")							-- Enable base addons
	if set then enableSet(set) end				-- Enable requested set addons
	enableSet(select(2, UnitClass("player")))	-- Enable all class-related addons

	ReloadUI()			-- Reload the UI for changes to take effect
end

SLASH_CAELADDONSMANAGER1 = '/addonset'
SlashCmdList.CAELADDONSMANAGER = handleSlash