--[[	$Id$	]]

local _, caelEmote = ...

caelEmote.eventFrame = CreateFrame("Frame", nil, UIParent)

local playerFaction, oldState
local targets = {}

caelEmote.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelEmote.eventFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		playerFaction = UnitFactionGroup("player")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end)

caelEmote.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
caelEmote.eventFrame:HookScript("OnEvent", function(self, event, timestamp, subevent, sourceGUID, sourceName, sourceFlags, destGUID, destName)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if subevent == "PARTY_KILL" then
			local dashPos = destName:find("-")
			if dashPos then
				destName = destName:sub(0, dashPos - 1)
			end
			if targets[destName] then
				if sourceName == caelLib.playerName then
					DoEmote("GLOAT", destName)
					PlaySoundFile(caelMedia.files.soundGodlike)
				end
				targets[destName] = nil
			end
		end
	end
end)

caelEmote.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
caelEmote.eventFrame:HookScript("OnEvent", function(self, event)
	if event == "PLAYER_TARGET_CHANGED" then
		if UnitExists("target") and UnitIsPlayer("target") and UnitIsEnemy("player", "target") and UnitFactionGroup("target") ~= playerFaction then
			targets[UnitName("target")] = true
		end
	end
end)

caelEmote.eventFrame:RegisterEvent("UNIT_AURA")
caelEmote.eventFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "UNIT_AURA" then
		arg1, arg2 = ...
		if  arg1 == "player" then
			local newState = UnitBuff("player", "Strength of the Taunka") or UnitBuff("player", "Speed of the Vrykul") or UnitBuff("player", "Agility of the Vrykul")
			if newState and not oldState then
				DoEmote("GRIN", arg2)
			end
			oldState = newState
		end
	end
end)