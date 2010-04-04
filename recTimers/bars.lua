--[[	$Id$	]]

local _, recTimers = ...

local _, playerClass = UnitClass("player")
local playerLevel = UnitLevel("player")
--[[
Bar creation reference.

recTimers.make_bar = function(self, spell_name, unit, buff_type, only_self, r, g, b, width, height, attach_point1, parent_frame1, relative_point1, x_offset1, y_offset1, attach_point2, parent_frame2, relative_point2, x_offset2, y_offset2, hide_name)
recTimers.make_bar(name, unit, de/buff, onlyMine, r, g, b, w, h, anchorPoint1, anchorParent1, relativePoint1, x1, y1, anchorPoint2, anchorParent2, relativePoint2, x2, y2, hideSpellName)

spell_name:    Name of the buff/debuff.
unit:          Unit to monitor (player, target, focus, party1, etc)
buff_type:     Buff or debuff.
only_self:     If set to false, timer will always show if buff/debuff is present.  If set to true, timer will only show if you were the player who cast the buff/debuff.
r, g, b:       Color of the timer bar.  If nil, they will automatically color to aura type. (poison, curse, etc)
width, height: Width and height of the timer bar.

The first set of points positions the bar for your primary talent spec.
attach_point1:        Which point on the timer to use when positioning the bar.
parent_frame1:        Which frame to use when positioning the bar.  Normally UIParent.
relative_point1:      Which point of the parent_frame to use when positioning the bar.
x_offset1, y_offset1: X/Y offset values from the attach point.
attach_point2, parent_frame2, relative_point2, x_offset2, y_offset2: Secondary talent spec values.  You may enter 'nil' to use the same values as primary spec.

hide_name:   This will hide the name of the buff/debuff if set to true.  You may need to set this if your bar is too short to contain the name.

EVERYONE
	--recTimers:make_bar("Well Fed", "player", "buff",	false, .4, .4, .4,	200, 10, "CENTER", UIParent, "CENTER", 0, 0)
	--recTimers:make_bar("Toasty Fire",	"player", "buff",	false, .4, .4, .4,	200, 10, "CENTER", UIParent, "CENTER", 0, 0)
	
LEVELBASED
if playerLevel == 80 then
	--recTimers:make_bar("Well Fed", "player", "buff",	false, .4, .4, .4,	200, 10, "CENTER", UIParent, "CENTER", 0, 0)
end
--]]

if caelLib.locale == "enUS" then
	if playerClass == "HUNTER" then
		recTimers:make_bar("Aimed Shot", "target", "debuff", false, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 286)

		recTimers:make_bar("Silencing Shot", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)
		recTimers:make_bar("Piercing Shots", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)

		recTimers:make_bar("Explosive Shot", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)
		recTimers:make_bar("Black Arrow", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)

		recTimers:make_bar("Serpent Sting", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 241)
		recTimers:make_bar("Hunter's Mark", "target", "debuff", false, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 226)
	end
elseif caelLib.locale == "frFR" then
	if playerClass == "DEATHKNIGHT" then
		t:make_bar("Fièvre de givre", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 286)
		t:make_bar("Peste d'ébène", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)
		t:make_bar("Peste de sang", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)
		t:make_bar("Cor de l'hiver", "player", "buff", false, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 241)
		t:make_bar("Bouclier d'os", "player", "buff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 226)
	elseif playerClass == "HUNTER" then
		t:make_bar("Visée",	"target", "debuff", false, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 286)
		t:make_bar("Flèche-bâillon","target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)
		t:make_bar("Tirs perforants", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)
		t:make_bar("Tir explosif", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)
		t:make_bar("Flèche noire", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)
		t:make_bar("Morsure de serpent", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 241)
		t:make_bar("Marque du chasseur", "target", "debuff", false, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 226)
	elseif playerClass == "MAGE" then
		t:make_bar("Brûlure", "target", "debuff", false, 1.0, 0.0, 0.0, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 301)
		t:make_bar("barrieres de glace", "player", "buff", false, 0.0, 0.5, 0.5, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 286)
		
		t:make_bar("Barrage de projectiles", "player", "buff",	false, 1.0, 0.0, 0.0, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)
		t:make_bar("Atténuation de la magie", "player", "buff",	false, 1.0, 0.0, 0.0, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)
		
		t:make_bar("Intelligence de Dalaran", "player", "buff",	false, 0.0, 0.0, 0.5, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 241)
		t:make_bar("Lumiere de Dalaran", "player", "buff",	false, 0.0, 0.0, 0.5, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 241)
		t:make_bar("Intelligence des arcanes", "player", "buff", false, 0.0, 0.0, 0.5, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 241)
		t:make_bar("Lumiere des arcanes", "player", "buff",	false, 0.0, 0.0, 0.5, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 241)
		
		t:make_bar("Armure de givre", "player", "buff",	false, 0.5, 0.2, 0.0, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 226)
		t:make_bar("Armure de la fournaise", "player", "buff",	false, 0.5, 0.2, 0.0, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 226)
	end
end