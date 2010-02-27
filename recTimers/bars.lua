-- $Id: bars.lua 497 2010-02-25 06:31:32Z john.d.mann@gmail.com $
local _, t = ...
local _, class = UnitClass("player")
local level = UnitLevel("player")

-- Bar creation reference.
--
-- t.make_bar = function(self, spell_name, unit, buff_type, only_self, r, g, b, width, height, attach_point1, parent_frame1, relative_point1, x_offset1, y_offset1, attach_point2, parent_frame2, relative_point2, x_offset2, y_offset2, hide_name)
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
if level == 80 then
	--t:make_bar("Well Fed",		"player", "buff",	false, .4, .4, .4,	200, 10, "CENTER", UIParent, "CENTER", 0, 0)
end

-- DEATHKNIGHT
if class == "DEATHKNIGHT" then
	t:make_bar("Frost Fever", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 286)
	t:make_bar("Ebon Plague", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)
	t:make_bar("Blood Plague", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)
	t:make_bar("Horn of Winter", "player", "buff", false, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 241)
	t:make_bar("Bone Shield", "player", "buff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 226)
end

-- DRUID
if class == "DRUID" then
	t:make_bar("Entangling Roots",    "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Moonfire",            "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Faerie Fire",         "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Faerie Fire (Feral)", "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Rake",                "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Rip",                 "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Mangle (Cat)",        "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Lacerate",            "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Demoralizing Roar",   "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Mangle (Bear)",       "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Gift of the Wild",    "player", "buff",   false, .5, 0, .5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Mark of the Wild",    "player", "buff",   false, .5, 0, .5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Thorns",              "player", "buff",   false, .3, .2, .1, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 329)
end

-- HUNTER
--	make_bar(name, unit, de/buff, onlyMine, r, g, b, w, h, anchorPoint1, anchorParent1, relativePoint1, x1, y1, anchorPoint2, anchorParent2, relativePoint2, x2, y2, hideSpellName)
if class == "HUNTER" then
	t:make_bar("Aimed Shot", "target", "debuff", false, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 286)

	t:make_bar("Silencing Shot", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)
	t:make_bar("Piercing Shots", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)

	t:make_bar("Explosive Shot", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)
	t:make_bar("Black Arrow", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)

	t:make_bar("Serpent Sting", "target", "debuff", true, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 241)
	t:make_bar("Hunter's Mark", "target", "debuff", false, nil, nil, nil, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 226)
end

-- MAGE
if class == "MAGE" then
	t:make_bar("Scorch",				"target", "debuff",	false, 1.0, 0.0, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Ice Barrier",			"player", "buff",	false, 0.0, 0.5, 0.5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 329)
	t:make_bar("Missile Barrage",		"player", "buff",	false, 1.0, 0.0, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 346)
	t:make_bar("Dalaran Intellect",		"player", "buff",	false, 0.0, 0.0, 0.5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 363)
	t:make_bar("Dalaran Brilliance",	"player", "buff",	false, 0.0, 0.0, 0.5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 363)
	t:make_bar("Arcane Intellect",		"player", "buff",	false, 0.0, 0.0, 0.5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 363)
	t:make_bar("Arcane Brilliance",		"player", "buff",	false, 0.0, 0.0, 0.5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 363)
	t:make_bar("Molten Armor",			"player", "buff",	false, 0.5, 0.2, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 380)
end

-- PALADIN
if class == "PALADIN" then
	t:make_bar("Judgement of Wisdom",	"target", "debuff",	false,	0.0, 0.42, 0.53, 230,  10, "BOTTOM", UIParent, "BOTTOM", 278, 370)
	t:make_bar("Judgement of Light",	"target", "debuff",	false,	0.6, 0.60, 0.00, 230,  10, "BOTTOM", UIParent, "BOTTOM", 278, 387)
	t:make_bar("Judgement of Justice",	"target", "debuff",	false,	0.5, 0.30, 0.09, 230,  10, "BOTTOM", UIParent, "BOTTOM", 278, 404)
	t:make_bar("Blessing of Sanctuary",	"player", "buff",	false,	0.0, 0.00, 0.50, 57.5, 10, "BOTTOM", UIParent, "BOTTOM", -192, 404, true)
	t:make_bar("Blessing of Wisdom",	"player", "buff",	false,	0.0, 0.50, 0.50, 57.5, 10, "BOTTOM", UIParent, "BOTTOM", -192 - 57.5, 404, true)
	t:make_bar("Blessing of Might",		"player", "buff",	false,	0.4, 0.00, 0.00, 57.5, 10, "BOTTOM", UIParent, "BOTTOM", -192 - 115, 404, true)
	t:make_bar("Blessing of Kings",		"player", "buff",	false,	0.6, 0.60, 0.00, 57.5, 10, "BOTTOM", UIParent, "BOTTOM", -192 - 172, 404, true)
	t:make_bar("Seal of Righteousness",	"player", "buff",	true,	0.6, 0.60, 0.00, 230,  10, "BOTTOM", UIParent, "BOTTOM", -278, 387)
	t:make_bar("Seal of Wisdom",		"player", "buff",	true,	1.0, 0.00, 0.00, 230,  10, "BOTTOM", UIParent, "BOTTOM", -278, 387)
	t:make_bar("Seal of Justice",		"player", "buff",	true,	0.5, 0.30, 0.09, 230,  10, "BOTTOM", UIParent, "BOTTOM", -278, 387)
	t:make_bar("Seal of Light",			"player", "buff",	true,	0.6, 0.60, 0.00, 230,  10, "BOTTOM", UIParent, "BOTTOM", -278, 387)
	t:make_bar("Righteous Fury",		"player", "buff",	true,	0.5, 0.30, 0.09, 230,  10, "BOTTOM", UIParent, "BOTTOM", -278, 370)
end

-- PRIEST
if class == "PRIEST" then
	t:make_bar("Shadow Word: Pain",		"target", "debuff", true, 0.4, 0.0, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", 263, 416)
	t:make_bar("Shadow Word: Death",	"target", "debuff", true, 0.4, 0.0, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", 263, 399)
	t:make_bar("Weakened Soul",			"target", "debuff", true, 0.5, 0.1, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 263, 382)
	t:make_bar("Renew",					"target", "buff",	true, 0.0, 0.6, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 263, 365)
	t:make_bar("Weakened Soul",			"player", "debuff", true, 0.5, 0.1, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 433)
	t:make_bar("Inner Fire",			"player", "buff",	true, 0.6, 0.6, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 416)
	t:make_bar("Power Word: Fortitude",	"player", "buff",	true, 0.5, 0.6, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 399)
	t:make_bar("Prayer of Fortitude",	"player", "buff",	true, 0.5, 0.6, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 399)
	t:make_bar("Divine Spirit",			"player", "buff",	true, 0.6, 0.6, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 382)
	t:make_bar("Prayer of Spirit",		"player", "buff",	true, 0.6, 0.6, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 382)
	t:make_bar("Fade",					"player", "buff",	true, 0.0, 0.5, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 365)
	t:make_bar("Power Word: Fortitude",	"party1", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	t:make_bar("Prayer of Fortitude",	"party1", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	t:make_bar("Divine Spirit",			"party1", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	t:make_bar("Prayer of Spirit",		"party1", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	t:make_bar("Power Word: Fortitude",	"party2", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	t:make_bar("Prayer of Fortitude",	"party2", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	t:make_bar("Divine Spirit",			"party2", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	t:make_bar("Prayer of Spirit",		"party2", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	t:make_bar("Power Word: Fortitude",	"party3", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	t:make_bar("Prayer of Fortitude",	"party3", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	t:make_bar("Divine Spirit",			"party3", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	t:make_bar("Prayer of Spirit",		"party3", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	t:make_bar("Power Word: Fortitude",	"party4", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	t:make_bar("Prayer of Fortitude",	"party4", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	t:make_bar("Divine Spirit",			"party4", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	t:make_bar("Prayer of Spirit",		"party4", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
end

-- ROGUE
if class == "ROGUE" then
	t:make_bar("Deadly Poison",  "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Slice and Dice", "player", "buff",   true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Rupture",        "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Sap",            "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Sap",            "focus",  "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Garrote",        "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Cheap Shot",     "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Kidney Shot",    "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Blind",          "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Gouge",          "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Evasion",        "player", "buff",   true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
end

-- SHAMAN
if class == "SHAMAN" then
	t:make_bar("Tidal Waves",	"player",	"buff",		true, 0.0, 0.0, 1.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 277)
	t:make_bar("Water Shield",	"player",	"buff",		true, 0.3, 0.3, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 293)
	t:make_bar("Earth Shield",	"focus",	"buff",		true, 0.6, 0.6, 0.3, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 305)
	t:make_bar("Flame Shock",	"target",	"debuff",	true, 1.0, 0.0, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 261)
end

-- WARLOCK
if class == "WARLOCK" then
	t:make_bar("Immolate",               "target", "debuff", true, .65, .20,   0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	t:make_bar("Seed of Corruption",     "target", "debuff", true,   0, .38, .03, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 329)
	t:make_bar("Curse of Agony",         "target", "debuff", true, .43,   0, .40, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 346)
	t:make_bar("Demonic Circle: Summon", "player", "buff",   true,   0, .38, .03, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 363)
	t:make_bar("Fel Armor",              "player", "buff",   true,   0, .38, .03, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 380)
	t:make_bar("Life Tap",               "player", "buff",   true, .43,   0, .40, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 397)
end

-- WARRIOR
if class == "WARRIOR" then
	t:make_bar("Battle Shout",       "player", "buff",   false,	0.59, 0.00, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 377)
	t:make_bar("Bloodrage",          "player", "buff",   true,	0.59, 0.00, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 394)
	t:make_bar("Shield Block",       "player", "buff",   true,	0.60, 0.60, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 411)
	t:make_bar("Shield Wall",        "player", "buff",   true,	0.60, 0.60, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 428)
	t:make_bar("Last Stand",         "player", "buff",   true,	0.60, 0.60, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 445)
	t:make_bar("Berserker Rage",     "player", "buff",   true,	0.50, 0.20, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 462)
	t:make_bar("Retaliation",        "player", "buff",   true,	0.50, 0.20, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 479)
	t:make_bar("Sunder Armor",       "target", "debuff", true,	0.50, 0.20, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", 225, 377)
	t:make_bar("Rend",               "target", "debuff", true,	0.59, 0.00, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", 225, 394)
	t:make_bar("Thunder Clap",       "target", "debuff", false,	0.60, 0.60, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", 225, 411)
	t:make_bar("Demoralizing Shout", "target", "debuff", false,	0.00, 0.50, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", 225, 428)
	t:make_bar("Hamstring",          "target", "debuff", false,	0.50, 0.20, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", 225, 445)
end