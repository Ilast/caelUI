-- $Id: deathknight.lua 194 2010-02-03 16:24:23Z john.d.mann@gmail.com $
local _, recClassTimers = ...
if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

-- make_bar(spell_name, unit, buff_type, r, g, b, width, height, attach_point, parent_frame, relative_point, x_offset, y_offset)
recClassTimers:make_bar("Blood Plague", "target", "debuff", true, 0, .5, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
recClassTimers:make_bar("Frost Fever", "target", "debuff", true, 0, 1, 1, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 328)
recClassTimers:make_bar("Horn of Winter", "player", "buff", false, 1, 1, 1, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 344)