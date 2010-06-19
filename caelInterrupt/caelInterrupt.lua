--[[	$Id$	]]

local _, caelInterrupt = ...

caelInterrupt.eventFrame = CreateFrame("Frame", nil, UIParent)

local playerGuid = nil
local msg = "%s: %s (%s)"
--local emo = "interrupted %s. (%s)"
local emo = "a interrompu %s. (%s)"
local grouped = nil
local lastTimestamp = nil
local lastInterrupted = nil

caelInterrupt.eventFrame:RegisterEvent("PLAYER_LOGIN")
caelInterrupt.eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
caelInterrupt.eventFrame:SetScript("OnEvent", function(self, event, timestamp, subEvent, sourceGUID, _, _, _, destName, _, _, spellName, _, _, extraSkillName)

	if tostring(GetZoneText() == "Wintergrasp") or MiniMapBattlefieldFrame.status == "active" then return end

	if event == "PARTY_MEMBERS_CHANGED" then
		local n = GetNumPartyMembers()
		if not grouped and n > 0 then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			grouped = true
		elseif grouped and n == 0 then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			grouped = nil
		end
	elseif event == "PLAYER_LOGIN" then
		playerGuid = UnitGUID("player")
	else
		if subEvent == "SPELL_INTERRUPT" and sourceGUID == playerGuid then
			if timestamp ~= lastTimestamp or extraSkillName ~= lastInterrupted then
				lastTimestamp = timestamp
				lastInterrupted = extraSkillName
--				local text = msg:format(spellName, extraSkillName, destName)
				local emote = emo:format(extraSkillName, destName)
--				SendChatMessage(text, "SAY")
				SendChatMessage(emote, "EMOTE")
			end
		end
	end
end)