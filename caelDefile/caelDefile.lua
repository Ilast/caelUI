--[[	$Id$	]]

local _, caelDefile = ...

caelDefile.eventFrame = CreateFrame("Frame", nil, UIParent)

local defile = caelDefile.eventFrame

defile:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
defile:SetScript("OnEvent", function(self, event, timestamp, subEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if subEvent == "SPELL_CAST_START" then
			spellId, spellName, spellSchool, auraType, amount = ...

			if sourceName == "The Lich King" then
				if spellName == "Defile" then
					if UnitIsUnit("focus".."target", "player") then
						RaidNotice_AddMessage(RaidWarningFrame, "DEFILE ON ME")
					end
				end
			end
		end
	end
end)