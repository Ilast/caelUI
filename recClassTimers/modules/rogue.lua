-- $Id: rogue.lua 194 2010-02-03 16:24:23Z john.d.mann@gmail.com $
local _, recClassTimers = ...
if select(2, UnitClass("player")) ~= "ROGUE" then return end

-- make_bar(spell_name, unit, buff_type, only_mine, r, g, b, width, height, attach_point, parent_frame, relative_point, x_offset, y_offset)
recClassTimers:make_bar("Deadly Poison", "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
recClassTimers:make_bar("Rupture", "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)