local level = UnitLevel("player")
if level == 80 then return end

local Holder = CreateFrame("Frame")

caelStats.experience = caelPanel10:CreateFontString(nil, "OVERLAY")
caelStats.experience:SetFont(font, fontSize, fontOutline)
caelStats.experience:SetPoint("CENTER", caelPanel10, "CENTER", 225, 0.5)

local find, tonumber = string.find, tonumber

local lastXP, a, b = 0
local OnEvent = function(retval, self, event, ...)
	if event == "CHAT_MSG_COMBAT_XP_GAIN" then
		_, _, lastXP = find(select(1, ...), ".*gain (.*) experience.*")
		lastXP = tonumber(lastXP)
		return
	end
	
	local petXp, petMaxXp

	local xp = UnitXP("player")
	local maxXp = UnitXPMax("player")
	if UnitGUID("pet") then
		petXp, petMaxXp = GetPetExperience()
	end

	local xpString
	if not petMaxXp or petMaxXp == 0 then
		xpString = string.format("P:%.1f%%", ((xp/maxXp)*100))
	else
		xpString = string.format("P:%.1f%% p:%.0f%%", ((xp/maxXp)*100), ((petXp/petMaxXp)*100))
	end

	caelStats.experience:SetText(xpString)

	if retval then
		return string.format("Player: %s/%s (%.1f%%)", xp, maxXp, ((xp/maxXp)*100)), (petMaxXp and petMaxXp > 0) and string.format("Pet: %s/%s (%.0f%%)", petXp, petMaxXp, ((petXp/petMaxXp)*100)) or nil
	end
end

local OnEnter = function(self, ...)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	local playerXp, petXp = OnEvent(true)
	GameTooltip:AddLine(playerXp)
	if petXp then
		GameTooltip:AddLine(petXp)
	end
	GameTooltip:Show()
end

Holder:EnableMouse(true)
Holder:SetAllPoints(caelStats.experience)
Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
Holder:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
Holder:RegisterEvent("PLAYER_XP_UPDATE")
Holder:RegisterEvent("UNIT_PET")
Holder:RegisterEvent("UNIT_EXPERIENCE")
Holder:RegisterEvent("UNIT_LEVEL")
Holder:SetScript("OnEvent", function(s,e,...) OnEvent(false, s,e,...) end)
Holder:SetScript("OnEnter", OnEnter)
Holder:SetScript("OnLeave", function(...) GameTooltip:Hide() end)