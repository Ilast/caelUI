--[[	$Id$	]]

if select(2, UnitClass("player")) ~= "HUNTER" then
	print("|cffD7BEA5cael|rMisdirection: You are not a Hunter, caelMisdirection will be disabled on next UI reload.")
	return DisableAddOn("caelMisdirection")
end

local _, caelMisdirection = ...

caelMisdirection.eventFrame = CreateFrame("Frame", nil, UIParent)

local textColor = {r = 0.84, g = 0.75, b = 0.65}

caelMisdirection.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
caelMisdirection.eventFrame:SetScript("OnEvent", function(_, _, _, subEvent, _, sourceName, _, _, destName, _, _, spellName, ...)
	if subEvent == "SPELL_CAST_SUCCESS" then
		if  spellName == "Misdirection" then
			if sourceName and UnitIsPlayer(destName) then
				if sourceName == caelLib.playerName and not UnitIsUnit(destName, "pet") then
					if caelLib.locale = "frFR" then
						SendChatMessage(("Détourné"), "WHISPER", GetDefaultLanguage("player"), destName)
					else
						SendChatMessage(("Misdirected"), "WHISPER", GetDefaultLanguage("player"), destName)
					end

					RaidNotice_AddMessage(RaidWarningFrame, "Misdirection on "..destName, textColor)

					local index = GetChannelName("WeDidHunter")
					if (index ~= nil) then 
						SendChatMessage(("misdirected ".. destName) , "CHANNEL", nil, index)
					end
				end
			end
		end
	end
end)