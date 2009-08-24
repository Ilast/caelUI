local CVarTweaks = CreateFrame("Frame", nil, UIParent)

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
		SetCVar("projectedTextures", 1)
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

CVarTweaks:RegisterEvent("ZONE_CHANGED_NEW_AREA")
CVarTweaks.ZONE_CHANGED_NEW_AREA = function(self)
	local zone = GetRealZoneText()
	return ZoneChange(zone)
end

CVarTweaks:RegisterEvent("WORLD_MAP_UPDATE")
CVarTweaks.WORLD_MAP_UPDATE = function(self)
	local zone = GetRealZoneText()
	if zone and zone ~= "" then
		self:UnregisterEvent("WORLD_MAP_UPDATE")
		return ZoneChange(zone)
	end
end

CVarTweaks:RegisterEvent("PLAYER_ENTERING_WORLD")
CVarTweaks.PLAYER_ENTERING_WORLD = function(self)
	return ZoneChange(zone)
end

Scales = {
	["800"] = { ["600"] = 0.69999998807907},
	["1024"] = { ["768"] = 0.69999998807907},
	["1152"] = { ["864"] = 0.69999998807907},
	["1280"] = { ["720"] = 0.93000000715256, ["960"] = 0.69999998807907, ["1024"] = 0.64999997615814},
	["1600"] = { ["900"] = 0.93000000715256, ["1200"] = 0.69999998807907},
	["1680"] = { ["1050"] = 0.83999997377396},
	["1768"] = { ["992"] = 0.93000000715256},
	["1920"] = { ["1200"] = 0.83999997377396, ["1080"] = 0.93000000715256},
}

--[[
	SetCVar("uiScale", 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
	SetCVar("uiScale", 768/tonumber(GetCVar("gxResolution"):match("%d+x(%d+)")))
--]]

CVarTweaks:RegisterEvent("PLAYER_LOGIN")
CVarTweaks.PLAYER_LOGIN = function(self)
	local width, height = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)")
	if Scales[width] and Scales[width][height] then
		SetCVar("useUiScale", 1)
		SetCVar("uiScale", Scales[width][height])
	else
		SetCVar("useUiScale", 0)
		print("Your resolution is not supported, UI Scale has been disabled.")
	end
end

WorldFrame:ClearAllPoints()
WorldFrame:SetUserPlaced()
WorldFrame:SetHeight(GetScreenHeight() * (GetCVar("UIScale")))
WorldFrame:SetWidth(GetScreenWidth() * (GetCVar("UIScale")))
WorldFrame:SetAllPoints(UIParent)

SetCVar("gxMultisample","1")
SetCVar("gxMultisampleQuality","0.000000")
SetCVar("gxVSync", "0")
SetCVar("gxTripleBuffer", "0")
SetCVar("gxFixLag", "0")
SetCVar("gxCursor", "1")
SetCVar("gxRefresh", "50")
SetCVar("Maxfps", "45")
SetCVar("maxfpsbk", "10")
SetCVar("ffx", "0")
SetCVar("spellEffectLevel", "9")
SetCVar("textureFilteringMode", "5")
SetCVar("baseMip", "0")
SetCVar("mapShadows", "0")
SetCVar("shadowLOD", "0")
SetCVar("farclip", 1277)
SetCVar("showfootprints", "0")
SetCVar("ffxDeath", "0")
SetCVar("ffxGlow", "0")
SetCVar("specular", "1")

SetCVar("shadowLevel", "0")
SetCVar("componentTextureLevel", "9")

SetCVar("Sound_AmbienceVolume", "0.10000000149012")
SetCVar("Sound_EnableErrorSpeech", "0")
SetCVar("Sound_EnableMusic", "0")
SetCVar("Sound_EnableSoundWhenGameIsInBG", "1")
SetCVar("Sound_MasterVolume", "0.20000000298023")
SetCVar("Sound_MusicVolume", "0")
SetCVar("Sound_OutputQuality", "0")
SetCVar("Sound_SFXVolume", "0.20000000298023")

SetCVar("extShadowQuality", 0)
SetCVar("cameraDistanceMax", 50)
SetCVar("cameraDistanceMaxFactor", 3.4)
SetCVar("cameraDistanceMoveSpeed", 50)
SetCVar("cameraViewBlendStyle", 2)

if (tonumber(GetCVar("ScreenshotQuality")) < 10) then SetCVar("ScreenshotQuality", 10) end

local cores = tonumber(GetCVar("coresDetected"))
if (cores > 1) then
	SetCVar("processAffinityMask", math.pow(cores, 2) - 1)
end

function OnEvent(self, event, ...)
	if type(self[event]) == 'function' then
		return self[event](self, event, ...)
	else
		print("Unhandled event: "..event)
	end
end

CVarTweaks:SetScript("OnEvent", OnEvent)