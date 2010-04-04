--[[	$Id: caelLib.lua 871 2010-04-02 16:34:14Z sdkyron@gmail.com $	]]

caelLib = {}

caelLib.dummy = function() end
caelLib.locale = GetLocale()

local realmName = GetRealmName()
local _, playerClass = UnitClass("player")

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

if charListA[realmName] and charListA[realmName][playerClass] and charListA[realmName][playerClass][UnitName("player")] then
	caelLib.isCharListA = true
end

if charListB[realmName] and charListB[realmName][playerClass] and charListB[realmName][playerClass][UnitName("player")] then
	caelLib.isCharListB = true
end

charListA = nil
charListB = nil
realmName = nil
playerClass = nil