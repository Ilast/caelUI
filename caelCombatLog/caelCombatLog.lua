local cCL, frames = cCLFrame, cCLFrame.frames
cCLFrame = nil

local player, damage, duration, tooltipMsg
local deathChar = "††"

local red = "|cffAF5050"
local green = "|cff559655"
local lightgreen = "|cff7DCD6E"
local beige = "|cffD7BEA5" -- 215, 190, 165

local schoolColors = {}

local link = "|HClog:%s|h"

local format = string.format

local missTypes = {
	ABSORB = "Absorb",
	BLOCK = "Block",
	DEFLECT = "Deflect",
	DODGE = "Dodge",
	EVADE = "Evade",
	IMMUNE = "Immune",
	MISS = "Miss",
	PARRY = "Parry",
	REFLECT = "Reflect",
	RESIST = "Resist",
}

local powerColors = {
	[0]	= "|cff5073A0",	-- Mana -- |cff0000FF -- 80, 115, 160
	[1]	= "|cffAF5050",	-- Rage -- |cffFF0000 -- 175, 80, 80
	[2]	= "|cffB46E46",	-- Focus -- |cff643219 -- 180, 110, 70
	[3]	= "|cffA5A05A",	-- Energy -- |cffFFFF00 -- 165, 160, 90
	[4]	= "|cff329696",	-- Happiness -- cff00FFFF -- 50, 150, 150
	[5]	= "|cff8C919B",	-- Runes -- |cff323232 -- 140, 145, 155
	[6]	= "|cff005264",	-- Runic Power
}

setmetatable(powerColors, {__index = function(t, k) return "|cffD7BEA5" end})

local powerStrings = {
  [SPELL_POWER_MANA] = MANA, -- 0
  [SPELL_POWER_RAGE] = RAGE, -- 1
  [SPELL_POWER_FOCUS] = FOCUS, -- 2
  [SPELL_POWER_ENERGY] = ENERGY, -- 3
  [SPELL_POWER_HAPPINESS] = HAPPINESS, -- 4
  [SPELL_POWER_RUNES] = RUNES, -- 5
  [SPELL_POWER_RUNIC_POWER] = RUNIC_POWER, -- 6
}

local eventTable = {
  ["SWING_DAMAGE"] = "damage",
  ["RANGE_DAMAGE"] = "damage",
  ["SPELL_DAMAGE"] = "damage",
  ["SPELL_PERIODIC_DAMAGE"] = "damage",
  ["ENVIRONMENTAL_DAMAGE"] = "damage",
  ["SPELL_HEAL"] = "healing",
  ["SPELL_PERIODIC_HEAL"] = "healing",
}

local data = {damageOut = 0, damageIn = 0, healingOut = 0, healingIn = 0}

local function clearSummary()
	data.damageIn = 0
	data.damageOut = 0
	data.healingIn = 0
	data.healingOut = 0
end

local throttledEvents = {
	["SPELL_ENERGIZE"] = {amount = 0, count = 0, formatString = "%s %s energize %s for %d %s. (%d hits)"},
	["SPELL_PERIODIC_ENERGIZE"] = {amount = 0, count = 0, formatString = "%s %s energize %s for %d %s. (%d hits)"},
	["SPELL_PERIODIC_HEAL"] = {amount = 0, count = 0, formatString = "%s %s heal %s for %d%7$s. (%6$d hits)"},
}

local Output = function(frame, color, text, critical, pet, prefix, tooltipMsg)
local msg = format("%s%s%s%s%s%s%s|h", link:format(tooltipMsg or ""), (frame ~= 1 and prefix and prefix ~= "" and "|cffD7BEA5"..prefix.."|r" or ""), (color or ""), (pet and "·" or ""), text, (pet and "·" or ""), (frame == 1 and prefix and prefix ~= "" and "|cffD7BEA5"..prefix.."|r" or ""))
local rsamsg = format("%s%s%s%s%s%s|h", (frame ~= 1 and prefix and prefix ~= "" and "|cffD7BEA5"..prefix.."|r" or ""), (color or ""), (pet and "·" or ""), text, (pet and "·" or ""), (frame == 1 and prefix and prefix ~= "" and "|cffD7BEA5"..prefix.."|r" or ""))

	for i, v in pairs(frames) do
		v:AddMessage(i == frame and msg or " ")
	end

	if RecScrollAreas then
		RecScrollAreas:AddText(rsamsg, critical, frame == 1 and "NotificationDOWN" or frame == 3 and "NotificationUP" or "Notification")
	end
end

cCL:RegisterEvent("PLAYER_LOGIN")
function cCL:PLAYER_LOGIN()
	player = UnitGUID("player")
	for i, v in pairs(COMBATLOG_DEFAULT_COLORS.schoolColoring) do
		schoolColors[i] = format("|cff%02x%02x%02x", v.r * 255, v.g * 255, v.b * 255)
	end
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

local FormatMissType = function(event, missType, amountMissed)
	local resultStr
	if (missType == "RESIST" or missType == "BLOCK" or missType == "ABSORB") then
		if amountMissed == 0 then
			resultStr = ""
		else
			resultStr = format(_G["TEXT_MODE_A_STRING_RESULT_"..missType], amountMissed)
		end
	else
		resultStr = _G["ACTION_SWING_MISSED_"..missType]
	end
	return resultStr
end

cCL:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
function cCL:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, subEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	local pet = UnitGUID("pet")
	if not (sourceGUID == player or destGUID == player or sourceGUID == pet or destGUID == pet) then return end
	
	local meSource, meTarget = sourceGUID == player, destGUID == player
	local modString
	local color, crit, prefix, scrollFrame, text
	local absorbed, amount, blocked, critical, crushing, enviromentalType, extraAmount, glancing, missAmount, missType, overheal, overkill, powerType, resisted, school, spellId, spellName, spellSchool
	local ispet = sourceGUID == pet or destGUID == pet
	scrollFrame = (sourceGUID == player or sourceGUID == pet) and 3 or 1
	
	if subEvent == "SWING_DAMAGE" then

		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		text, crit, color = amount - overkill, critical, schoolColors[school <= 1 and 0 or school]
		
		modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
		tooltipMsg = format("%s melee swing hit %s for %d. %s", (meSource and "Your" or sourceName.."'s"), (meTarget and "you" or destName), amount, modString)

	elseif subEvent == "SPELL_DAMAGE" then

		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		text, crit, color = amount - overkill, critical, schoolColors[spellSchool]

		modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
		tooltipMsg = format("%s %s hit %s for %d. %s", (meSource and "Your" or sourceName and sourceName.."'s" or ""), (spellName), (meTarget and "you" or destName), amount, modString)

	elseif subEvent == "SPELL_PERIODIC_DAMAGE" or subEvent == "DAMAGE_SHIELD" or subEvent == "DAMAGE_SPLIT" then

		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		text, crit, color = amount - overkill, critical, schoolColors[spellSchool]

		modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
		tooltipMsg = format("%s %s damaged %s for %d. %s", (meSource and "Your" or sourceName and sourceName.."'s" or ""), (spellName), (meTarget and "you" or destName), amount, modString)

	elseif subEvent == "RANGE_DAMAGE" then

		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		spellSchool = school
		text, crit, color = amount - overkill, critical, schoolColors[school <= 1 and 0 or school]

		modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
		tooltipMsg = format("%s %s hit %s for %d. %s", (meSource and "Your" or sourceName.."'s"), (spellName), (meTarget and "you" or destName), amount, modString)

	elseif subEvent == "ENVIRONMENTAL_DAMAGE" then

		enviromentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		text, color = amount, schoolColors[school <= 1 and 0 or school]

		tooltipMsg = format("%s suffer %d from %s.", (meTarget and "You" or destName), amount, _G["ACTION_ENVIRONMENTAL_DAMAGE_"..enviromentalType])

 	elseif subEvent == "SPELL_HEAL" or subEvent == "SPELL_PERIODIC_HEAL" then

		spellId, spellName, spellSchool, amount, overheal, absorbed, critical = ...
		if overheal < amount then
			text, crit, prefix = amount - overheal, critical, sourceGUID == player and destGUID ~= player and "» " or "« "
		end

		color = subEvent == "SPELL_PERIODIC_HEAL" and lightgreen or green
		scrollFrame = 2

		modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
		tooltipMsg = format("%s %s heal %s for %d. %s", (meSource and "Your" or sourceName.."'s"), (spellName), (meTarget and "you" or destName), amount, modString)

	elseif subEvent == "SPELL_ENERGIZE" or subEvent == "SPELL_PERIODIC_ENERGIZE" then

		spellId, spellName, spellSchool, amount, powerType = ...

		if amount == 0 then return end

		color = powerColors[powerType]
--		text, crit, color = amount, critical, powerColors[powerType]
--		scrollFrame = 2

--		tooltipMsg = format("%s %s energize %s for %d %s.", (meSource and "Your" or sourceName.."'s"), (spellName), (meTarget and "you" or destName), amount, powerStrings[powerType])

	elseif subEvent == "SPELL_DRAIN" or subEvent == "SPELL_PERIODIC_DRAIN" then

		spellId, spellName, spellSchool, amount, powerType, extraAmount = ...
		text, crit, color = extraAmount, critical, powerColors[powerType]
		scrollFrame = 2

		tooltipMsg = format("%s %s drain %s for %d %s. %s", (meSource and "Your" or sourceName.."'s"), (spellName), (meTarget and "you" or destName), amount, powerStrings[powerType], extraAmount and "("..extraAmount.." gained)" or "")

	elseif subEvent == "SPELL_LEECH" or subEvent == "SPELL_PERIODIC_LEECH" then

		spellId, spellName, spellSchool, amount, powerType, extraAmount = ...
		text, crit, color = extraAmount, critical, powerColors[powerType]
		scrollFrame = 2

		tooltipMsg = format("%s %s leech %s for %d %s. (%s gained)", (meSource and "Your" or sourceName.."'s"), (spellName), (meTarget and "you" or destName), amount, powerStrings[powerType], extraAmount)

	elseif subEvent == "SWING_MISSED" then

		missType, missAmount = ...
		text = missTypes[missType] or missType

		tooltipMsg = format("%s melee swing miss %s. %s", (meSource and "You" or sourceName.."'s"), (meTarget and "you" or destName), FormatMissType(subEvent, missType, missAmount))

	elseif subEvent == "RANGE_MISSED" or subEvent == "SPELL_MISSED" or subEvent == "SPELL_PERIODIC_MISSED" or subEvent == "DAMAGE_SHIELD_MISSED" then

		spellId, spellName, spellSchool, missType, missAmount = ...
		text, color = missTypes[missType] or missType, schoolColors[spellSchool]

		tooltipMsg = format("%s %s miss %s. %s", (meSource and "Your" or sourceName and sourceName.."'s" or ""), (spellName), (meTarget and "you" or destName), FormatMissType(subEvent, missType, missAmount))

	elseif subEvent == "PARTY_KILL" or subEvent == "UNIT_DIED" or subEvent == "UNIT_DESTROYED" or subEvent == "UNIT_DISSIPATES" then

		text, color, scrollFrame = deathChar.." "..destName.." "..deathChar, beige, 2

	end

	prefix = prefix or ""
	if overkill and overkill > 0 then prefix = scrollFrame ~= 1 and prefix.."k " or prefix.." k" end
	if overheal and overheal > 0 then prefix = scrollFrame ~= 1 and prefix.."h " or prefix.." h" end
	if absorbed and absorbed > 0 then prefix = scrollFrame ~= 1 and prefix.."a " or prefix.." a" end
	if critical then prefix = scrollFrame ~= 1 and prefix.."• " or prefix.." •" end
	if blocked then prefix = scrollFrame ~= 1 and prefix.."b " or prefix.." b" end
	if resisted then prefix = scrollFrame ~= 1 and prefix.."r " or prefix.." r" end
	if glancing then prefix = scrollFrame ~= 1 and  prefix.."g " or prefix.." g" end
	if crushing then prefix = scrollFrame ~= 1 and  prefix.."c " or prefix.." c" end

	local valueType = eventTable[subEvent]
	local direction = (sourceGUID == player or sourceGUID == pet) and "Out" or "In"

	if valueType then
		data[valueType..direction] = data[valueType..direction] + amount
	end

	if text then
		Output(scrollFrame, color, text, crit, ispet, prefix, tooltipMsg)
	end

	local throttle = throttledEvents[subEvent]
	if throttle then
		throttle.amount = throttle.amount + amount
		throttle.count = throttle.count + 1
		if throttle.count >= 3 then
			tooltipMsg = format(throttle.formatString, (meSource and "Your" or sourceName.."'s"), (spellName), (meTarget and "you" or destName), throttle.amount, powerStrings[powerType], throttle.count, (modString and modString ~= "" and " "..modString or ""))
			Output(2, color, format("%s", throttle.amount), crit, ispet, prefix, tooltipMsg)
			throttle.amount = 0
			throttle.count = 0
		end
	end
end

cCL:RegisterEvent("PLAYER_REGEN_DISABLED")
function cCL:PLAYER_REGEN_DISABLED()
	Output(2, red, "++ Combat ++")

	duration = GetTime()
	clearSummary()
end

local ShortValue = function(value)
	if value >= 1e6 then
		return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return value
	end
end

cCL:RegisterEvent("PLAYER_REGEN_ENABLED")
function cCL:PLAYER_REGEN_ENABLED()
	duration = GetTime() - duration

	local t = {}
	t[#t+1] = (data.damageOut) > 0 and red..ShortValue(data.damageOut).."|r"  or nil
	t[#t+1] = (data.damageIn) > 0 and red..ShortValue(data.damageIn).."|r" or nil
	t[#t+1] = (data.healingOut) > 0 and green..ShortValue(data.healingOut).."|r" or nil
	t[#t+1] = (data.healingIn) > 0 and green..ShortValue(data.healingIn).."|r" or nil

	Output(2, green, "-- Combat --")
--	Output(2, beige, ((floor(duration / 60) > 0) and (floor(duration / 60).."m "..(floor(duration) % 60).."s") or (floor(duration).."s")).." in combat", true)

	if #t > 0 then
		tooltipMsg = format("%s%s%s%s%s", (floor(duration / 60) > 0) and (floor(duration / 60).."m "..(floor(duration) % 60).."s") or (floor(duration).."s").." in combat\n", data.damageOut > 0 and "Damage done: "..(data.damageOut).."\n" or "", data.damageIn > 0 and "Damage recieved: "..(data.damageIn).."\n" or "", data.healingOut > 0 and "Healing done: "..data.healingOut.."\n" or "", data.healingIn > 0 and "Healing recieved: "..data.healingIn.."\n" or "")
		Output(2, nil, table.concat(t, beige.." ¦ "), true, nil, nil, tooltipMsg)
	end
end

--	/run for i=1,1000 do local id,n=GetAchievementInfo(i) if n and n:find("[dD]amage") then print(id, n) end end