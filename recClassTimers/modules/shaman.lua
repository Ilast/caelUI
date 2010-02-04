-- $Id: shaman.lua 194 2010-02-03 16:24:23Z john.d.mann@gmail.com $
local _, recClassTimers = ...
if select(2, UnitClass("player")) ~= "SHAMAN" then return end

-- make_bar(spell_name, unit, buff_type, only_mine, r, g, b, width, height, attach_point, parent_frame, relative_point, x_offset, y_offset)
recClassTimers:make_bar("Tidal Waves", "player", "buff", true, 0, 0, 1, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
recClassTimers:make_bar("Water Shield", "player", "buff", true, 0, 0, 1, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 328)
recClassTimers:make_bar("Flame Shock", "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 296)