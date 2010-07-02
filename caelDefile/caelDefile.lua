--[[	$Id$	]]

local _, caelDefile = ...

caelDefile.eventFrame = CreateFrame("Frame", nil, UIParent)

local defile = caelDefile.eventFrame

local output = {}
defile:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
defile:SetScript("OnEvent", function(self, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local event, timestamp, subEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...
		if subEvent == "SPELL_CAST_START" or subEvent == "SPELL_DAMAGE" then
			spellId, spellName, spellSchool, auraType, amount = select(10, ...)

			if sourceName == "The Lich King" then
				if spellName == "Defile" then
					output[#output + 1] = string.format("[%d] - %s (%s)", GetTime(), tostring(subEvent), tostring(destName))
				end
			end
		end
	elseif event == "UNIT_TARGET" then
		local unit = ...
		
		if unit == "focus" and UnitName("focus") == "The Lich King" then
			output[#output + 1] = string.format("[%d] - %s (%s)", GetTime(), event, tostring(UnitName("focustarget")))
		end
	end
end)

caelDefileOutput = output