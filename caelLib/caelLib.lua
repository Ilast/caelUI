--[[	$Id$	]]

_, caelLib = ...

caelLib.playerClass = select(2, UnitClass("player"))
caelLib.playerName = UnitName("player")
caelLib.playerRealm = GetRealmName()
caelLib.locale = GetLocale()

screenWidth, screenHeight = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)")

caelLib.scales = {
	["720"] = { ["576"] = 0.65},
	["800"] = { ["600"] = 0.7},
	["1024"] = { ["600"] = 0.89, ["768"] = 0.7},
	["1152"] = { ["864"] = 0.7},
	["1280"] = { ["800"] = 0.84, ["720"] = 0.93, ["768"] = 0.87, ["960"] = 0.7, ["1024"] = 0.65},
	["1360"] = { ["768"] = 0.93},
	["1366"] = { ["768"] = 0.93},
	["1600"] = { ["1200"] = 0.7, ["1024"] = 0.82, ["900"] = 0.93},
	["1680"] = { ["1050"] = 0.84},
	["1768"] = { ["992"] = 0.93},
	["1920"] = { ["1200"] = 0.84, ["1080"] = 0.93},
}

local UIScale = caelLib.scales[screenWidth] and caelLib.scales[screenWidth][screenHeight] or 1
local ScaleFix = (768/tonumber(GetCVar("gxResolution"):match("%d+x(%d+)")))/UIScale

caelLib.scale = function(value)
    return ScaleFix * math.floor(value / ScaleFix + 0.5)
end

caelLib.dummy = function() end

caelLib.kill = function(object)
    local objectReference = object
    if type(object) == "string" then
        objectReference = _G[object]
    else
        objectReference = object
    end
    if not objectReference then return end
    if type(objectReference) == "frame" then
        objectReference:UnregisterAllEvents()
    end
    objectReference.Show = caelLib.dummy
    objectReference:Hide()
end

local charListA = {
	["Illidan"] = { 
		["HUNTER"] = {
			["Caellian"] = true,
			["Callysto"] = true
		},
		["DRUID"] = {
			["Cowdiak"] = true
		},
		["PALADIN"] = {
			["Calyr"] = true
		},
		["PRIEST"] = {
			["Nïmue"] = true
		}
	}
}

local charListB = {
	["Illidan"] = { 
		["HUNTER"] = {
			["Caellian"] = true,
			["Callysto"] = true,
			["Eling"] = true
		},
		["DRUID"] = {
			["Cowdiak"] = true,
			["Xelem"] = true
		},
		["PALADIN"] = {
			["Calyr"] = true
		},
		["PRIEST"] = {
			["Nïmue"] = true
		},
		["DEATHKNIGHT"] = {
			["Dkdens"] = true
		}
	}
}

if charListA[caelLib.playerRealm] and charListA[caelLib.playerRealm][caelLib.playerClass] and charListA[caelLib.playerRealm][caelLib.playerClass][UnitName("player")] then
	caelLib.isCharListA = true
end

if charListB[caelLib.playerRealm] and charListB[caelLib.playerRealm][caelLib.playerClass] and charListB[caelLib.playerRealm][caelLib.playerClass][UnitName("player")] then
	caelLib.isCharListB = true
end

charListA = nil
charListB = nil
--caelLib.playerRealm = nil
--caelLib.playerClass = nil