--[[	$Id$	]]

local _, caelLib = ...
_G["caelLib"] = caelLib

local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", function(self, event, ...)
	if type(self[event]) == "function" then
		return self[event](self, event, ...)
	end
end)

caelLib.playerClass = select(2, UnitClass("player"))
caelLib.playerName = UnitName("player")
caelLib.playerRealm = GetRealmName()
caelLib.locale = GetLocale()

caelLib.utf8sub = function(string, i, dots)
	local bytes = string:len()
	if (bytes <= i) then
		return string
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = string:byte(pos)
			if (c > 0 and c <= 127) then
				pos = pos + 1
			elseif (c >= 192 and c <= 223) then
				pos = pos + 2
			elseif (c >= 224 and c <= 239) then
				pos = pos + 3
			elseif (c >= 240 and c <= 247) then
				pos = pos + 4
			end
			if (len == i) then break end
		end

		if (len == i and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and "..." or "")
		else
			return string
		end
	end
end

caelLib.screenWidth, caelLib.screenHeight = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)")

caelLib.scales = {
	["720"] = { ["576"] = 0.65},
	["800"] = { ["600"] = 0.7},
	["960"] = { ["600"] = 0.84},
	["1024"] = { ["600"] = 0.89, ["768"] = 0.7},
	["1152"] = { ["864"] = 0.7},
	["1176"] = { ["664"] = 0.93},
	["1280"] = { ["800"] = 0.84, ["720"] = 0.93, ["768"] = 0.87, ["960"] = 0.7, ["1024"] = 0.65},
	["1360"] = { ["768"] = 0.93},
	["1366"] = { ["768"] = 0.93},
	["1440"] = { ["900"] = 0.84},
	["1600"] = { ["1200"] = 0.7, ["1024"] = 0.82, ["900"] = 0.93},
	["1680"] = { ["1050"] = 0.84},
	["1768"] = { ["992"] = 0.93},
	["1920"] = { ["1440"] = 0.7, ["1200"] = 0.84, ["1080"] = 0.93},
	["2048"] = { ["1536"] = 0.7},
	["2560"] = { ["1600"] = 0.84},
}

local ScaleFix

caelLib.scale = function(value)
    return ScaleFix * math.floor(value / ScaleFix + 0.5)
end

EventFrame.ADDON_LOADED = function(self, event, addon)
	if addon ~= "caelLib" then
		return
	end
	
	if not caelDB then
		caelDB  = {}
	end
	
	local UIScale = caelDB.scale or caelLib.scales[screenWidth] and caelLib.scales[screenWidth][screenHeight] or 1
	ScaleFix = (768/tonumber(GetCVar("gxResolution"):match("%d+x(%d+)")))/UIScale
	
	self:UnregisterEvent(event)
end
EventFrame:RegisterEvent("ADDON_LOADED")

EventFrame.UPDATE_FLOATING_CHAT_WINDOWS = function(self, event)
	caelDB.scale = floor(GetCVar("uiScale") * 100 + 0.5)/100
end
EventFrame:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS")

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