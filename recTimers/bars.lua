--[[	$Id$	]]

local _, t = ...
local _, playerClass = UnitClass("player")
local playerLevel = UnitLevel("player")

-- Bar creation reference.
--
-- t.make_bar = function(self, spell_name, unit, buff_type, only_self, r, g, b, width, height, attach_point1, parent_frame1, relative_point1, x_offset1, y_offset1, attach_point2, parent_frame2, relative_point2, x_offset2, y_offset2, hide_name)
-- t.make_bar(name, unit, de/buff, onlyMine, r, g, b, w, h, anchorPoint1, anchorParent1, relativePoint1, x1, y1, anchorPoint2, anchorParent2, relativePoint2, x2, y2, hideSpellName)
--
-- spell_name:    Name of the buff/debuff.
-- unit:          Unit to monitor (player, target, focus, party1, etc)
-- buff_type:     Buff or debuff.
-- only_self:     If set to false, timer will always show if buff/debuff is present.  If set to true, timer will only show if you were the player who cast the buff/debuff.
-- r, g, b:       Color of the timer bar.  If nil, they will automatically color to aura type. (poison, curse, etc)
-- width, height: Width and height of the timer bar.
--
-- The first set of points positions the bar for your primary talent spec.
-- attach_point1:        Which point on the timer to use when positioning the bar.
-- parent_frame1:        Which frame to use when positioning the bar.  Normally UIParent.
-- relative_point1:      Which point of the parent_frame to use when positioning the bar.
-- x_offset1, y_offset1: X/Y offset values from the attach point.
-- attach_point2, parent_frame2, relative_point2, x_offset2, y_offset2: Secondary talent spec values.  You may enter 'nil' to use the same values as primary spec.
-- 
-- hide_name:   This will hide the name of the buff/debuff if set to true.  You may need to set this if your bar is too short to contain the name.

-- EVERYONE
	--t:make_bar("Well Fed",		"player", "buff",	false, .4, .4, .4,	200, 10, "CENTER", UIParent, "CENTER", 0, 0)
	--t:make_bar("Toasty Fire",	"player", "buff",	false, .4, .4, .4,	200, 10, "CENTER", UIParent, "CENTER", 0, 0)
	
-- LEVELBASED
if playerLevel == 80 then
	--t:make_bar("Well Fed",		"player", "buff",	false, .4, .4, .4,	200, 10, "CENTER", UIParent, "CENTER", 0, 0)
end

-- HUNTER
if playerClass == "HUNTER" then
	t:make_bar("Aimed Shot", "target", "debuff", false, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 286)

	t:make_bar("Silencing Shot", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)
	t:make_bar("Piercing Shots", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)

	t:make_bar("Explosive Shot", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)
	t:make_bar("Black Arrow", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)

	t:make_bar("Serpent Sting", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 241)
	t:make_bar("Hunter's Mark", "target", "debuff", false, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 226)
end