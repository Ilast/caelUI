local cCL, frames = cCLFrame, cCLFrame.frames
cCLFrame = nil

local holdTime = 5
local player, damage, duration, tooltipMsg
local deathChar = "††"

local red = "|cffAF5050"
local green = "|cff559655"
local lightgreen = "|cff7DCD6E"
local beige = "|cffD7BEA5" -- 215, 190, 165

local schoolColors = {}

local link = "|HClog:%s|h"

local find = string.find
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

local formatStrings = {
	["SPELL_ENERGIZE"] = "%s + %d%s", -- "%s energize for %d. %s"
	["SPELL_PERIODIC_ENERGIZE"] = "%s + %d%s", -- "%s energize for %d. %s"
	["SPELL_PERIODIC_HEAL"] = "%s + %d%s", -- "%s heal for %d. %s"
	["SPELL_PERIODIC_DAMAGE"] = "%s + %d%s", -- "%s damage for %d. %s"
	["Volley"] = "%s + %d%s", -- "%s damage for %d. %s"
}	

local excludedSpells = {}
local throttledEvents = {
	["SPELL_ENERGIZE"] = {petIn = {}, playerIn = {}},
	["SPELL_PERIODIC_ENERGIZE"] = {petIn = {}, playerIn = {}},
	["SPELL_PERIODIC_HEAL"] = {petIn = {}, playerIn = {}},
	["SPELL_PERIODIC_DAMAGE"] = {petIn = {}, petOut = {}, playerIn = {}, petOut = {}},
}

local throttledSpells = {
	["Volley"] = {
		playerIn = {amount = 0, isHit = 0, isCrit = 0, reportOnFade = true, format = formatStrings["Volley"]},
		playerOut = {amount = 0, isHit = 0, isCrit = 0, reportOnFade = true, format = formatStrings["Volley"]},
		petIn = {amount = 0, isHit = 0, isCrit = 0, reportOnFade = true, format = formatStrings["Volley"]},
	},
}

local tooltipStrings = {
	[1] = "%s %s %s %s for %d. %s",
	[2] = "%s suffer %d from %s.",
	[3] = "%s %s leech %s for %d %s. (%s gained)",
	[4] = "%s %s miss %s. %s",
}

for event, entry in pairs(throttledEvents) do
	local mt = {__index = function(t, k)
		local newTable = {amount = 0, isHit = 0, isCrit = 0, format = formatStrings[event]}
		t[k] = newTable
		return newTable
	end}
	
	for unit, entry in pairs(entry) do
		setmetatable(entry, mt)
	end
end

local Output = function(frame, color, text, rsatext, critical, pet, prefix, suffix, tooltipMsg, throttle, noccl)
	local msg = format("%s%s%s%s%s|h", link:format(tooltipMsg or ""), ((frame == 2 or frame == 3) and prefix and prefix ~= "" and "|cffD7BEA5"..prefix.."|r" or ""), (color or ""), text, ((frame == 1 or frame == 2) and suffix and suffix ~= "" and "|cffD7BEA5"..suffix.."|r" or ""))

	if not(noccl) then
		for i, v in pairs(frames) do
			v:AddMessage(i == frame and msg or " ")
		end
	end

	if RecScrollAreas and not(throttle) or (throttle and noccl) then
		local rsamsg = format("%s%s%s%s|h", ((frame == 2 or frame == 3) and prefix and prefix ~= "" and "|cffD7BEA5"..prefix.."|r" or ""), (color or ""), rsatext or text, ((frame == 1 or frame == 2) and suffix and suffix ~= "" and "|cffD7BEA5"..suffix.."|r" or ""))
		RecScrollAreas:AddText(rsamsg, critical, frame == 1 and "Incoming" or frame == 3 and "Outgoing" or "Information")
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

local ShortName = function(spellName)
	if find(spellName, "[%s%-]") then
		spellName = string.gsub(spellName, "(%a)[%l]*[%s%-]*", "%1") -- "(%a)[%l%p]*[%s%-]*"
	else
		spellName = string.sub(spellName, 1, 3)
	end
	return spellName
end

cCL:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
function cCL:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, subEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	local pet = UnitGUID("pet")
	if not (sourceGUID == player or destGUID == player or sourceGUID == pet or destGUID == pet) then return end
	
	local meSource, meTarget = sourceGUID == player, destGUID == player
	local modString
	local color, crit, prefix, suffix, scrollFrame, text, rsatext, noccl
	local absorbed, amount, blocked, critical, crushing, enviromentalType, extraAmount, glancing, missAmount, missType, overheal, overkill, powerType, resisted, school, spellId, spellName, spellSchool
	local ispet = sourceGUID == pet or destGUID == pet
	scrollFrame = (sourceGUID == player or sourceGUID == pet) and 3 or 1

	local direction = (destGUID == player or destGUID == pet) and "In" or "Out"
	local unitDirection = (ispet and "pet" or "player")..direction
	
	if subEvent == "SWING_DAMAGE" then

		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		text, rsatext, crit, color = amount - overkill, amount, critical, schoolColors[school <= 1 and 0 or school]
		
		modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
		tooltipMsg = format(tooltipStrings[1], (meSource and "Your" or sourceName.."'s"), "melee swing", "hit", (meTarget and "you" or destName), amount, modString)

	elseif subEvent == "RANGE_DAMAGE" then

		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		spellSchool = school
		text, rsatext, crit, color = amount - overkill, format("%s %s", ShortName(spellName), amount), critical, schoolColors[school <= 1 and 0 or school]

		modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
		tooltipMsg = format(tooltipStrings[1], (meSource and "Your" or sourceName.."'s"), (spellName), "hit", (meTarget and "you" or destName), amount, modString)

	elseif subEvent == "SPELL_DAMAGE" then

		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		text, rsatext, crit, color = amount - overkill, format("%s %s", ShortName(spellName), amount), critical, schoolColors[spellSchool]

		modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
		tooltipMsg = format(tooltipStrings[1], (meSource and "Your" or sourceName and sourceName.."'s" or ""), (spellName), "hit", (meTarget and "you" or destName), amount, modString)

	elseif subEvent == "SPELL_PERIODIC_DAMAGE" or subEvent == "DAMAGE_SHIELD" or subEvent == "DAMAGE_SPLIT" then

		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		text, rsatext, crit, color = amount - overkill, format("%s %s", ShortName(spellName), amount), critical, schoolColors[spellSchool]

		modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
		tooltipMsg = format(tooltipStrings[1], (meSource and "Your" or sourceName and sourceName.."'s" or ""), (spellName), "damaged", (meTarget and "you" or destName), amount, modString)

	elseif subEvent == "ENVIRONMENTAL_DAMAGE" then

		enviromentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		text, rsatext, color = amount, format("%s %s", _G["ACTION_ENVIRONMENTAL_DAMAGE_"..enviromentalType], amount), schoolColors[school <= 1 and 0 or school]

		tooltipMsg = format(tooltipStrings[2], (meTarget and "You" or destName), amount, _G["ACTION_ENVIRONMENTAL_DAMAGE_"..enviromentalType])

 	elseif subEvent == "SPELL_HEAL" or subEvent == "SPELL_PERIODIC_HEAL" then

		spellId, spellName, spellSchool, amount, overheal, absorbed, critical = ...
		if overheal < amount then
			text, rsatext, crit, prefix = amount - overheal, format("%s %s", ShortName(spellName), amount), critical, sourceGUID == player and destGUID ~= player and "» " or "« "
		end

		color = subEvent == "SPELL_PERIODIC_HEAL" and lightgreen or green
		scrollFrame = 2

		modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
		tooltipMsg = format(tooltipStrings[1], (meSource and "Your" or sourceName.."'s"), (spellName), "heal", (meTarget and "you" or destName), amount, modString)

	elseif subEvent == "SPELL_ENERGIZE" or subEvent == "SPELL_PERIODIC_ENERGIZE" then

		spellId, spellName, spellSchool, amount, powerType = ...

		if amount == 0 then return end

		text, rsatext, crit, color = amount, format("%s %s", ShortName(spellName), amount), critical, powerColors[powerType]
		scrollFrame = 2

		tooltipMsg = format(tooltipStrings[1], (meSource and "Your" or sourceName.."'s"), (spellName), "energize", (meTarget and "you" or destName), amount, powerStrings[powerType])

	elseif subEvent == "SPELL_DRAIN" or subEvent == "SPELL_PERIODIC_DRAIN" then

		spellId, spellName, spellSchool, amount, powerType, extraAmount = ...
		text, rsatext, crit, color = extraAmount, format("%s %s", ShortName(spellName), extraAmount), critical, powerColors[powerType]
		scrollFrame = 2

		tooltipMsg = format(tooltipStrings[1], (meSource and "Your" or sourceName.."'s"), (spellName), "drain", (meTarget and "you" or destName), amount, powerStrings[powerType], extraAmount and "("..extraAmount.." gained)" or "")

	elseif subEvent == "SPELL_LEECH" or subEvent == "SPELL_PERIODIC_LEECH" then

		spellId, spellName, spellSchool, amount, powerType, extraAmount = ...
		text, rsatext, crit, color = extraAmount, format("%s %s", ShortName(spellName), extraAmount), critical, powerColors[powerType]
		scrollFrame = 2

		tooltipMsg = format(tooltipStrings[3], (meSource and "Your" or sourceName.."'s"), (spellName), (meTarget and "you" or destName), amount, powerStrings[powerType], extraAmount)

	elseif subEvent == "SWING_MISSED" then

		missType, missAmount = ...
		text = missTypes[missType] or missType

		tooltipMsg = format(tooltipStrings[4], (meSource and "You" or sourceName.."'s"), "melee swing", (meTarget and "you" or destName), FormatMissType(subEvent, missType, missAmount))

	elseif subEvent == "RANGE_MISSED" or subEvent == "SPELL_MISSED" or subEvent == "SPELL_PERIODIC_MISSED" or subEvent == "DAMAGE_SHIELD_MISSED" then

		spellId, spellName, spellSchool, missType, missAmount = ...
		text, rsatext = missTypes[missType] or missType, format("%s %s", ShortName(spellName), missTypes[missType] or missType), schoolColors[spellSchool]

		tooltipMsg = format(tooltipStrings[4], (meSource and "Your" or sourceName and sourceName.."'s" or ""), (spellName), (meTarget and "you" or destName), FormatMissType(subEvent, missType, missAmount))

	elseif subEvent == "PARTY_KILL" or subEvent == "UNIT_DIED" or subEvent == "UNIT_DESTROYED" or subEvent == "UNIT_DISSIPATES" then

		text, color, scrollFrame = deathChar.." "..destName.." "..deathChar, beige, 2

	elseif subEvent:find("AURA_APPLIED") or subEvent:find("AURA_REMOVED") then

		spellId, spellName, spellSchool, auraType, amount = ...

		if spellName == "Trueshot Aura" and not meSource then return end

		color, noccl = schoolColors[spellSchool], true

		if auraType == "DEBUFF" and meTarget then
			scrollFrame = 1
		elseif auraType == "DEBUFF" and meSource then
			scrollFrame = 3
		elseif auraType == "BUFF" and meSource and meTarget then
			scrollFrame = 2
			crit = true
		else
			return
		end

		if not (throttledSpells[spellName] and throttledSpells[spellName][unitDirection]) then
			text = format("%s%s", scrollFrame == 2 and spellName or ShortName(spellName), amount and format(" (%d)", amount) or "")
		end

		if throttledSpells[spellName] and throttledSpells[spellName][unitDirection] and throttledSpells[spellName][unitDirection].reportOnFade then
			throttledSpells[spellName][unitDirection].elapsed = holdTime
		end
	end

	prefix = prefix or ""
	suffix = suffix or ""

	if ispet then
		prefix = (scrollFrame == 2 or scrollFrame == 3) and prefix.."· " or prefix
		suffix = (scrollFrame == 1 or scrollFrame == 2) and suffix.." ·" or prefix
	end

	if critical then
		prefix = (scrollFrame == 2 or scrollFrame == 3) and prefix.."• " or prefix
		suffix = (scrollFrame == 1 or scrollFrame == 2) and suffix.." •" or prefix
	end

	if blocked then prefix = scrollFrame ~= 1 and prefix.."b " or prefix.." b" end
	if crushing then prefix = scrollFrame ~= 1 and  prefix.."c " or prefix.." c" end
	if glancing then prefix = scrollFrame ~= 1 and  prefix.."g " or prefix.." g" end
	if resisted then prefix = scrollFrame ~= 1 and prefix.."r " or prefix.." r" end

	if absorbed and absorbed > 0 then prefix = scrollFrame ~= 1 and prefix.."a " or prefix.." a" end
	if overheal and overheal > 0 then prefix = scrollFrame ~= 1 and prefix.."h " or prefix.." h" end
	if overkill and overkill > 0 then prefix = scrollFrame ~= 1 and prefix.."k " or prefix.." k" end

	if subEvent:find("AURA_APPLIED") then
		prefix = (scrollFrame == 2 or scrollFrame == 3) and not throttledSpells[spellName] and prefix.."++ "
		suffix = (scrollFrame == 1 or scrollFrame == 2) and not throttledSpells[spellName] and suffix.." ++"
	elseif subEvent:find("AURA_REMOVED") then
		prefix = (scrollFrame == 2 or scrollFrame == 3) and not throttledSpells[spellName] and prefix.."-- "
		suffix = (scrollFrame == 1 or scrollFrame == 2) and not throttledSpells[spellName] and suffix.." --"
	end

	local valueType = eventTable[subEvent]

	if valueType then
		data[valueType..direction] = data[valueType..direction] + amount
	end

	local throttle
	if (throttledEvents[subEvent] and throttledEvents[subEvent][unitDirection] or throttledSpells[spellName] and throttledSpells[spellName][unitDirection]) and not excludedSpells[spellName] then 
		if throttledSpells[spellName] then
			throttle = throttledSpells[spellName][unitDirection]
		else
			throttle = throttledEvents[subEvent][unitDirection][spellName]  
		end
		throttle.amount = throttle.amount + (amount or 0) - (overheal or overkill or 0)
		if not throttle.elapsed and not throttle.reportOnFade then
			throttle.elapsed = 0
		end
		
		throttle.color = color

		if not throttle.scrollFrame then
			throttle.scrollFrame = scrollFrame
		end

		if critical then
			throttle.isCrit = throttle.isCrit + 1
		else
			throttle.isHit = throttle.isHit + 1
		end
	end

	if text then
		Output(scrollFrame, color, text, rsatext, crit, ispet, prefix, suffix, tooltipMsg, throttle, noccl)
	end
end

local UpdateThrottle = function(v, unit, spellName, elapsed)
	if v.elapsed then
		v.elapsed = v.elapsed + elapsed
		if v.elapsed >= holdTime then

			local isPet = unit:find("pet")
			local hitString
			if v.isCrit  > 0 then
				hitString = format(" (%d |4hit:hits;, %d |4crit:crits;)", v.isHit, v.isCrit)
			elseif v.isHit  > 1 then
				hitString = format(" (%d hits)", v.isHit)
			else
				hitString = ""
			end
			if v.amount > 0 then
				Output(v.scrollFrame, v.color, format(v.format, ShortName(spellName), v.amount, hitString), rsatext, nil, isPet, nil, nil, nil, true, true)
			end
			v.amount = 0
			v.isHit = 0
			v.isCrit = 0
			v.elapsed = nil
		end
	end
end

local OnUpdate = function(self, elapsed)
	for event, t in pairs(throttledEvents) do
		for unit, throttledEvents in pairs(t) do
			for spellName, v in pairs(throttledEvents) do
				UpdateThrottle(v, unit, spellName, elapsed)
			end
		end
	end

	for spellName, units in pairs(throttledSpells) do
		for unit, data in pairs(units) do
			UpdateThrottle(data, unit, spellName, elapsed)
		end
	end
end
cCL:SetScript("OnUpdate", OnUpdate)

cCL:RegisterEvent("PLAYER_REGEN_DISABLED")
function cCL:PLAYER_REGEN_DISABLED()
	Output(2, red, "++ Combat ++", nil, true)
	PlaySoundFile([=[Interface\Addons\caelCombatLog\media\combat+.mp3]=])

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

local t = {}
cCL:RegisterEvent("PLAYER_REGEN_ENABLED")
function cCL:PLAYER_REGEN_ENABLED()
	duration = GetTime() - duration

	for k,_ in pairs(t) do t[k] = nil end

	t[#t+1] = (data.damageOut) > 0 and red..ShortValue(data.damageOut).."|r"  or nil
	t[#t+1] = (data.damageIn) > 0 and red..ShortValue(data.damageIn).."|r" or nil
	t[#t+1] = (data.healingOut) > 0 and green..ShortValue(data.healingOut).."|r" or nil
	t[#t+1] = (data.healingIn) > 0 and green..ShortValue(data.healingIn).."|r" or nil

	Output(2, green, "-- Combat --", nil, true)
	PlaySoundFile([=[Interface\Addons\caelCombatLog\media\combat-.mp3]=])

	if #t > 0 then
		tooltipMsg = format("%s%s%s%s%s", (floor(duration / 60) > 0) and (floor(duration / 60).."m "..(floor(duration) % 60).."s") or (floor(duration).."s").." in combat\n", data.damageOut > 0 and "Damage done: "..(data.damageOut).."\n" or "", data.damageIn > 0 and "Damage recieved: "..(data.damageIn).."\n" or "", data.healingOut > 0 and "Healing done: "..data.healingOut.."\n" or "", data.healingIn > 0 and "Healing recieved: "..data.healingIn.."\n" or "")
		Output(2, nil, table.concat(t, beige.." ¦ "), nil, true, nil, nil, nil, tooltipMsg)
	end
end