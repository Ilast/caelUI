﻿--[[	$Id$	]]

caelLib = {}

caelLib.playerClass = select(2, UnitClass("player"))
caelLib.playerName = UnitName("player")
caelLib.playerRealm = GetRealmName()
caelLib.locale = GetLocale()

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
	["Temple noir"] = { 
		["HUNTER"] = {
			["Caellian"] = true,
			["Callysto"] = true
		},
		["DRUID"] = {
			["Cowdiak"] = true
		}
	}
}

local charListB = {
	["Temple noir"] = { 
		["HUNTER"] = {
			["Caellian"] = true,
			["Callysto"] = true,
			["Eling"] = true
		},
		["DRUID"] = {
			["Cowdiak"] = true
		},
		["DEATHKNIGHT"] = {
			["Dens"] = true
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