local caelMisdirection = CreateFrame("Frame")

local print = function(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffD7BEA5cael|rMisdirection: "..tostring(text))
end

if select(2, UnitClass("player")) ~= "HUNTER" then
	print("You are not a Hunter, caelMisdirection will be disabled on next UI reload.")
	return DisableAddOn("caelMisdirection")
end

local textColor = {r = 0.84, g = 0.75, b = 0.65}
function caelMisdirection_OnEvent(_, _, _, subEvent, _, sourceName, _, _, destName, _, _, spellName, ...)
	if subEvent == "SPELL_CAST_SUCCESS" then
		if  spellName == "Misdirection" then
			if sourceName and UnitIsPlayer(destName) then
				if UnitIsUnit(sourceName, "Caellian") and not UnitIsUnit(destName, "pet") then
					local index = GetChannelName("RaidHunter")
					if (index ~= nil) then 
						SendChatMessage(("misdirected ".. destName) , "CHANNEL", nil, index)
						SendChatMessage(("Misdirected"), "WHISPER", GetDefaultLanguage("player"), destName)
--						RaidNotice_AddMessage(RaidWarningFrame, "|cffD7BEA5Misdirection on "..destName.."|r")
						RaidNotice_AddMessage(RaidWarningFrame, "Misdirection on "..destName, textColor)
					end
				end
			end
		end
	end
end

caelMisdirection:SetScript("OnEvent", caelMisdirection_OnEvent)
caelMisdirection:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")