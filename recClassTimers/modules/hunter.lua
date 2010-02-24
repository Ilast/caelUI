-- $Id: hunter.lua 194 2010-02-03 16:24:23Z john.d.mann@gmail.com $
local _, recClassTimers = ...
if select(2, UnitClass("player")) ~= "HUNTER" then return end

-- make_bar(spell_name, unit, buff_type, only_mine, r, g, b, width, height, attach_point, parent_frame, relative_point, x_offset, y_offset)
recClassTimers:make_bar("Serpent Sting", "target", "debuff", true, 0.33, 0.59, 0.33, 200, 12, "BOTTOM", UIParent, "BOTTOM", 0, 328)
recClassTimers:make_bar("Hunter's Mark", "target", "debuff", false, 0.69, 0.31, 0.31, 200, 12, "BOTTOM", UIParent, "BOTTOM", 0, 312)