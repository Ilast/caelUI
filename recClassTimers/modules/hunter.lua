-- $Id: hunter.lua 194 2010-02-03 16:24:23Z john.d.mann@gmail.com $
local _, recClassTimers = ...
if select(2, UnitClass("player")) ~= "HUNTER" then return end

-- make_bar(spell_name, unit, buff_type, only_mine, r, g, b, width, height, attach_point, parent_frame, relative_point, x_offset, y_offset)
recClassTimers:make_bar("Hunter's Mark", "target", "debuff", false, 0.31, 0.45, 0.63, 200, 12, "BOTTOM", UIParent, "BOTTOM", 0, 312) -- Magic
recClassTimers:make_bar("Serpent Sting", "target", "debuff", true, 0.33, 0.59, 0.33, 200, 12, "BOTTOM", UIParent, "BOTTOM", 0, 328) -- Poison
recClassTimers:make_bar("Black Arrow", "target", "debuff", true, 0.31, 0.45, 0.63, 200, 12, "BOTTOM", UIParent, "BOTTOM", 0, 344) -- Magic

recClassTimers:make_bar("Aimed Shot", "target", "debuff", true, 0.69, 0.31, 0.31, 200, 12, "BOTTOM", UIParent, "BOTTOM", 0, 360) -- Red

recClassTimers:make_bar("Explosive Shot", "target", "debuff", true, 0.69, 0.31, 0.31, 200, 12, "BOTTOM", UIParent, "BOTTOM", 0, 376) -- Red
recClassTimers:make_bar("Silencing Shot", "target", "debuff", true, 0.31, 0.45, 0.63, 200, 12, "BOTTOM", UIParent, "BOTTOM", 0, 376) -- Magic

recClassTimers:make_bar("Piercing Shots", "target", "debuff", true, 0.69, 0.31, 0.31, 200, 12, "BOTTOM", UIParent, "BOTTOM", 0, 394) -- Red
