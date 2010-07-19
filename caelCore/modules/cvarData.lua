--[[	$Id$	]]

local _, caelCore = ...

caelCore.cvardata = caelCore.createModule("cvarData")

local cvardata = caelCore.cvardata

local ZoneChange = function(zone)
	local _, instanceType = IsInInstance()
	if zone == "Dalaran" then
		if caelLib.playerClass == "HUNTER" then SetTracking(nil) end
		SetCVar("useWeatherShaders", "0")
		SetCVar("weatherDensity", 0)
		SetCVar("environmentDetail", 0.5)
		SetCVar("groundEffectDensity", 16)
		SetCVar("groundEffectDist", 0)
		SetCVar("particleDensity", 0.11)
		SetCVar("projectedTextures", 0)
		SetCVar("chatBubbles", 0)
	elseif instanceType == "raid" then
		SetCVar("useWeatherShaders", "0")
		SetCVar("weatherDensity", 0)
		SetCVar("environmentDetail", 1.5)
		SetCVar("groundEffectDensity", 256)
		SetCVar("groundEffectDist", 45)
		SetCVar("particleDensity", 1)
		SetCVar("projectedTextures", 1)
		SetCVar("chatBubbles", 1)
	else
		SetCVar("useWeatherShaders", "1")
		SetCVar("weatherDensity", 3)
		SetCVar("environmentDetail", 1.5)
		SetCVar("groundEffectDensity", 128)
		SetCVar("groundEffectDist", 45)
		SetCVar("particleDensity", 1)
		SetCVar("projectedTextures", 1)
		SetCVar("chatBubbles", 0)
	end
end

cvardata:RegisterEvent("ZONE_CHANGED_NEW_AREA")
cvardata:RegisterEvent("WORLD_MAP_UPDATE")
cvardata:RegisterEvent("PLAYER_ENTERING_WORLD")
cvardata:SetScript("OnEvent", function(self, event)
	if event == "ZONE_CHANGED_NEW_AREA" or event == "WORLD_MAP_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
		local zone = GetRealZoneText()
		if zone and zone ~= "" then
			return ZoneChange(zone)
		end
	end
end)

--[[
Scales = {
	["800"] = { ["600"] = 0.69999998807907},
	["1024"] = { ["768"] = 0.69999998807907},
	["1152"] = { ["864"] = 0.69999998807907},
	["1280"] = { ["720"] = 0.93000000715256, ["768"] = 0.87000000476837, ["960"] = 0.69999998807907, ["1024"] = 0.64999997615814},
	["1366"] = { ["768"] = 0.93000000715256},
	["1600"] = { ["900"] = 0.93000000715256, ["1200"] = 0.69999998807907},
	["1680"] = { ["1050"] = 0.83999997377396},
	["1768"] = { ["992"] = 0.93000000715256},
	["1920"] = { ["1200"] = 0.83999997377396, ["1080"] = 0.93000000715256},
}
--]]

cvardata:RegisterEvent("PLAYER_ENTERING_WORLD")
cvardata:HookScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		local screenWidth, screenHeight = caelLib.screenWidth, caelLib.screenHeight
		if caelLib.scales[screenWidth] and caelLib.scales[screenWidth][screenHeight] then
			SetCVar("useUiScale", 1)
			SetCVar("uiScale", caelLib.scales[screenWidth][screenHeight])

			WorldFrame:SetUserPlaced(false)
			WorldFrame:ClearAllPoints()
			WorldFrame:SetHeight(GetScreenHeight() * caelLib.scales[screenWidth][screenHeight])
			WorldFrame:SetWidth(GetScreenWidth() * caelLib.scales[screenWidth][screenHeight])
			WorldFrame:SetPoint("BOTTOM", UIParent)
		else
			SetCVar("useUiScale", 0)
			print("Your resolution is not supported, UI Scale has been disabled.")
		end

		ConsoleExec("pitchlimit 449") -- 89, 449. 449 allows doing flips, 89 will not
		ConsoleExec("characterAmbient -0.1") -- -0.1-1 use ambient lighting for character. <0 == off

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
			"synchronizeConfig 0",
			"synchronizeBindings 0",
			"synchronizeMacros 0",
			"alwaysCompareItems 1",
			"autoDismountFlying 1",
			"autoClearAFK 1",
			"lootUnderMouse 0",
			"autoLootDefault 1",
			"autoRangedCombat 1", -- Automatically switch between auto attack & auto shot
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
			"chatBubblesParty 0",
			"spamFilter 0",
			"guildMemberNotify 1",
			"chatMouseScroll 1",
			"chatStyle classic",
			"conversationMode inline",
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
			caelLib.isCharListA and "autointeract 1" or "autointeract 0",
			"previewTalents 1",
			"showTutorials 0",
			"UberTooltips 1",
			"showNewbieTips 0",
			"scriptErrors 1",

			"showToastOnline 0",
			"showToastOffline 0",
			"showToastBroadcast 0",
			"showToastFriendRequest 0",
			"showToastConversation 0",
			"showToastWindow 0",
			"toastDuration 0",

			"M2Faster 3", -- Adds additional threads used in rendering models on screen (0 = no additional threads, 1 - 3 = adds additional threads to the WoW Client)
			"gxTextureCacheSize 512",
			"gxMultisample 8",
			"gxMultisampleQuality 0.000000",
			"gxVSync 0",
			"gxTripleBuffer 0",
			"gxFixLag 0",
			"gxCursor 1",
			"Maxfps 50",
			"maxfpsbk 10",
			"ffx 0",
			"textureFilteringMode 5",
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
			"componentThread 3",
			"componentTextureLevel 9", -- min 8
			"violencelevel 5", -- 0-5 Level of violence, 0 == none, 1 == green blood 2-5 == red blood

			"Sound_EnableHardware 1",
			"Sound_NumChannels 128", -- 12, 32, 64, 128
			"Sound_OutputQuality 2", -- 0-2
			"Sound_EnableSoftwareHRTF 1", -- Enables headphone designed sound subsystem
			"Sound_AmbienceVolume 0.10000000149012",
			"Sound_EnableErrorSpeech 0",
			"Sound_EnableMusic 0",
			"Sound_EnableSoundWhenGameIsInBG 1",
			"Sound_MasterVolume 0.10000000149012",
			"Sound_MusicVolume 0",
			"Sound_SFXVolume 0.20000000298023",

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