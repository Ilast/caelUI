--[[	$Id$	]]

local _, caelCore = ...

caelCore.dummy = function() end

caelCore.createModule = function(name)

    -- Create module frame.
    local module = CreateFrame("Frame", format("caelCoreModule%s", name), UIParent)
    
    return module
end

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
	isCharListA = true
end

if charListB[realmName] and charListB[realmName][playerClass] and charListB[realmName][playerClass][UnitName("player")] then
	isCharListB = true
end

charListA = nil
charListB = nil
realmName = nil
playerClass = nil