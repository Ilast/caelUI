--[[	$Id: oUF_cTags.lua 1407 2010-07-08 16:08:53Z sdkyron@gmail.com $	]]

local _, oUF_Caellian = ...

oUF.TagEvents["caellian:diffcolor"] = "UNIT_LEVEL"
if (not oUF.Tags["caellian:diffcolor"]) then
	oUF.Tags["caellian:diffcolor"]  = function(unit)
		local r, g, b
		local level = UnitLevel(unit)
		if (level < 1) then
			r, g, b = 0.69, 0.31, 0.31
		else
			local DiffColor = UnitLevel("target") - UnitLevel("player")
			if (DiffColor >= 5) then
				r, g, b = 0.69, 0.31, 0.31
			elseif (DiffColor >= 3) then
				r, g, b = 0.71, 0.43, 0.27
			elseif (DiffColor >= -2) then
				r, g, b = 0.84, 0.75, 0.65
			elseif (-DiffColor <= GetQuestGreenRange()) then
				r, g, b = 0.33, 0.59, 0.33
			else
				r, g, b = 0.55, 0.57, 0.61
			end
		end
		return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	end
end

local colors = setmetatable({
	happiness = setmetatable({
		[1] = {.69,.31,.31},
		[2] = {.65,.63,.35},
		[3] = {.33,.59,.33},
	}, {__index = oUF.colors.happiness}),
}, {__index = oUF.colors})

oUF.TagEvents["caellian:getnamecolor"] = "UNIT_HAPPINESS"
if (not oUF.Tags["caellian:getnamecolor"]) then
	oUF.Tags["caellian:getnamecolor"] = function(unit)
		local reaction = UnitReaction(unit, "player")
		if unit == "pet" and GetPetHappiness() then
			local c = colors.happiness[GetPetHappiness()]
			return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
		elseif UnitIsPlayer(unit) then
			return oUF.Tags["raidcolor"](unit)
		elseif reaction then
			local c =  colors.reaction[reaction]
			return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
		else
			r, g, b = .84,.75,.65
			return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
		end
	end
end

--[[
-- Workaround for names starting with weird letters, german for example (only works with capital letters sadly)
local newName = (string.len(oldName) > 10) and string.gsub(oldName, "%s?([\128-\196].)%S+%s", "%1. ") or oldName
newName = (string.len(newName) > 10) and string.gsub(newName, "(%s?)([^\128-\196])%S+%s", "%1%2. ") or newName
--]]

oUF.TagEvents["caellian:nameshort"] = "UNIT_NAME_UPDATE"
if (not oUF.Tags["caellian:nameshort"]) then
	oUF.Tags["caellian:nameshort"] = function(unit)
		local oldName = UnitName(unit)
		local newName = (string.len(oldName) > 8) and string.gsub(oldName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or oldName -- "%s?(.)%S+%s"
		return caelLib.utf8sub(newName, 8, false)
	end
end

oUF.TagEvents["caellian:namemedium"] = "UNIT_NAME_UPDATE"
if (not oUF.Tags["caellian:namemedium"]) then
	oUF.Tags["caellian:namemedium"] = function(unit)
		local oldName = UnitName(unit)
		local newName = (string.len(oldName) > 12) and string.gsub(oldName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or oldName
		if (unit == "pet" and name == "Unknown") then
			return "Pet"
		elseif (unit == PetFrame.unit and oldName == UnitName("player")) then
			return
		else
			return caelLib.utf8sub(newName, 12, true)
		end
	end
end

oUF.TagEvents["caellian:namelong"] = "UNIT_NAME_UPDATE"
if (not oUF.Tags["caellian:namelong"]) then
	oUF.Tags["caellian:namelong"] = function(unit)
		local oldName = UnitName(unit)
		local newName = (string.len(oldName) > 18) and string.gsub(oldName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or oldName
		return caelLib.utf8sub(newName, 18, true)
	end
end