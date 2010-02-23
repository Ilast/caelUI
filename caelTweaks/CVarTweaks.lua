local _, caelTweaks = ...

local ZoneChange = function(zone)
	local _, instanceType = IsInInstance()
	if zone == "Dalaran" then
		if select(2, UnitClass("player")) == "HUNTER" then SetTracking(nil) end
		SetCVar("useWeatherShaders", "0")
		SetCVar("weatherDensity", 0)
		SetCVar("environmentDetail", 0.5)
		SetCVar("groundEffectDensity", 16)
		SetCVar("groundEffectDist", 0)
		SetCVar("particleDensity", 0.11)
		SetCVar("projectedTextures", 0)
	elseif instanceType == "raid" then
		SetCVar("useWeatherShaders", "0")
		SetCVar("weatherDensity", 0)
		SetCVar("environmentDetail", 1.5)
		SetCVar("groundEffectDensity", 256)
		SetCVar("groundEffectDist", 45)
		SetCVar("particleDensity", 1)
		SetCVar("projectedTextures", 0)
	else
		SetCVar("useWeatherShaders", "1")
		SetCVar("weatherDensity", 3)
		SetCVar("environmentDetail", 1.5)
		SetCVar("groundEffectDensity", 128)
		SetCVar("groundEffectDist", 45)
		SetCVar("particleDensity", 1)
		SetCVar("projectedTextures", 1)
	end
end

caelTweaks.events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
caelTweaks.events:HookScript("OnEvent", function(self, event)
	if event == "ZONE_CHANGED_NEW_AREA" then
		return ZoneChange(GetRealZoneText())
	end
end)

caelTweaks.events:RegisterEvent("WORLD_MAP_UPDATE")
local mapUpdate = function(self, event)
	if event == "WORLD_MAP_UPDATE" then
		local zone = GetRealZoneText()
		if zone and zone ~= "" then
			mapUpdate = function() end
			return ZoneChange(zone)
		end
	end
end
caelTweaks.events:HookScript("OnEvent", mapUpdate)

caelTweaks.events:RegisterEvent("PLAYER_ENTERING_WORLD")
caelTweaks.events:HookScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		return ZoneChange(GetRealZoneText())
	end
end)

--[[
Scales = {
	["800"] = { ["600"] = 0.69999998807907},
	["1024"] = { ["768"] = 0.69999998807907},
	["1152"] = { ["864"] = 0.69999998807907},
	["1280"] = { ["720"] = 0.93000000715256, ["960"] = 0.69999998807907, ["1024"] = 0.64999997615814},
	["1366"] = { ["768"] = 0.93000000715256},
	["1600"] = { ["900"] = 0.93000000715256, ["1200"] = 0.69999998807907},
	["1680"] = { ["1050"] = 0.83999997377396},
	["1768"] = { ["992"] = 0.93000000715256},
	["1920"] = { ["1200"] = 0.83999997377396, ["1080"] = 0.93000000715256},
}
--]]

local Scales = {
	["800"] = { ["600"] = 0.7},
	["1024"] = { ["768"] = 0.7},
	["1152"] = { ["864"] = 0.7},
	["1280"] = { ["720"] = 0.93, ["960"] = 0.7, ["1024"] = 0.65},
	["1366"] = { ["768"] = 0.93},
	["1600"] = { ["900"] = 0.93, ["1200"] = 0.7},
	["1680"] = { ["1050"] = 0.84},
	["1768"] = { ["992"] = 0.93},
	["1920"] = { ["1200"] = 0.84, ["1080"] = 0.93},
}

caelTweaks.events:RegisterEvent("PLAYER_ENTERING_WORLD")
caelTweaks.events:HookScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		local width, height = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)")
		if Scales[width] and Scales[width][height] then
			SetCVar("useUiScale", 1)
			SetCVar("uiScale", Scales[width][height])

			WorldFrame:SetUserPlaced(false)
			WorldFrame:ClearAllPoints()
			WorldFrame:SetHeight(GetScreenHeight() * Scales[width][height])
			WorldFrame:SetWidth(GetScreenWidth() * Scales[width][height])
			WorldFrame:SetPoint("BOTTOM", UIParent, "BOTTOM")
		else
			SetCVar("useUiScale", 0)
			print("Your resolution is not supported, UI Scale has been disabled.")
		end

		for _, cvarData in pairs {

	--[[
		http://forums.worldofwarcraft.com/thread.html?topicId=1778017311&sid=1&pageNo=5#96
			╔════════╤════════╤════════╤════════╤════════╤════════╤════════╤════════╗
			║ Core 8 │ Core 7 │ Core 6 │ Core 5 │ Core 4 │ Core 3 │ Core 2 │ Core 1 ║
			╠════════╪════════╪════════╪════════╪════════╪════════╪════════╪════════╣
			║  +128  │  +64   │  +32   │  +16   │   +8   │   +4   │   +2   │   +1   ║
			╚════════╧════════╧════════╧════════╧════════╧════════╧════════╧════════╝
	--]]

			"processAffinityMask 255",
			"scriptProfile 0", -- Disables CPU profiling
			"showToolsUI 0", -- Disables the Launcher
			"synchronizeSettings 0", -- Don't synchronize settings with the server
			"autoDismountFlying 1",
			"autoClearAFK 0",
			"lootUnderMouse 0",
			"autoLootDefault 1",
			"autoRangedCombat 0",
			"stopAutoAttackOnTargetChange 1",
			"autoSelfCast 1",
			"rotateMinimap 0",
			"showLootSpam 1",
			"showClock 0",
			"threatShowNumeric 0",
			"threatPlaySounds 0",
			"questFadingDisable 1",
			"autoQuestWatch 1",
			"autoQuestProgress 1",
			"mapQuestDifficulty 1",
			"profanityFilter 0",
			"chatBubbles 0",
			"chatBubblesParty 0",
			"spamFilter 0",
			"guildMemberNotify 0",
			"lockActionBars 1",
			"alwaysShowActionBars 1",
			"secureAbilityToggle 1",
			"UnitNameOwn 0",
			"UnitNameNPC 1",
			"UnitNameNonCombatCreatureName 0",
			"UnitNamePlayerGuild 0",
			"UnitNamePlayerPVPTitle 0",
			"UnitNameFriendlyPlayerName 1",
			"UnitNameFriendlyPetName 0",
			"UnitNameFriendlyGuardianName 0",
			"UnitNameFriendlyTotemName 0",
			"UnitNameEnemyPlayerName 1",
			"UnitNameEnemyPetName 1",
			"UnitNameEnemyGuardianName 1",
			"UnitNameEnemyTotemName 1",
			"CombatDamage 0",
			"CombatHealing 0",
			"fctSpellMechanics 0",
			"enableCombatText 0",
			"hidePartyInRaid 1",
			"showArenaEnemyFrames 0",
			"autointeract 1",
			"previewTalents 1",
			"showTutorials 0",
			"UberTooltips 1",
			"showNewbieTips 0",
			"scriptErrors 1",

	--		"gxcolorbits","16"
	--		"gxdepthbits","16"
			"gxTextureCacheSize 512",
			"M2Faster 1", -- Adds additional threads used in rendering models on screen (0 = no additional threads, 1 - 3 = adds additional threads to the WoW Client)

			"gxMultisample 1",
			"gxMultisampleQuality 0.000000",
			"gxVSync 0",
			"gxTripleBuffer 0",
			"gxFixLag 0",
			"gxCursor 1",
	--		"gxRefresh 50"
	--		"Maxfps 45"
	--		"maxfpsbk 10"
			"ffx 0",
			"textureFilteringMode 0",
			"baseMip 0", -- 0 for max
			"mapShadows 0",
			"shadowLOD 0",
			"farclip 1277",
			"showfootprints 0",
			"ffxDeath 0",
			"ffxGlow 0",
			"specular 1",

			"shadowLevel 0",
			"componentCompress 0",
			"componentThread 1",
			"componentTextureLevel 9", -- min 8

			"Sound_AmbienceVolume 0.10000000149012",
			"Sound_EnableErrorSpeech 0",
			"Sound_EnableMusic 0",
			"Sound_EnableSoundWhenGameIsInBG 1",
			"Sound_MasterVolume 0.20000000298023",
			"Sound_MusicVolume 0",
			"Sound_OutputQuality 0",
			"Sound_SFXVolume 0.20000000298023",
			"Sound_EnableSoftwareHRTF 1",

			"extShadowQuality 0",
			"cameraDistanceMax 50",
			"cameraDistanceMaxFactor 3.4",
			"cameraDistanceMoveSpeed 50",
			"cameraViewBlendStyle 2",

			"nameplateAllowOverlap 0",

			"nameplateShowFriends 0",
			"nameplateShowFriendlyPets 0",
			"nameplateShowFriendlyGuardians 0",
			"nameplateShowFriendlyTotems 0",

			"nameplateShowEnemies 0",
			"nameplateShowEnemyPets 0",
			"nameplateShowEnemyGuardians 0",
			"nameplateShowEnemyTotems 0",
		} do
			SetCVar(string.split(" ", cvarData))
		end
	end
end)

if (tonumber(GetCVar("ScreenshotQuality")) < 10) then SetCVar("ScreenshotQuality", 10) end