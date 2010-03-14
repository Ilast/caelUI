--[[	$Id$	]]

if UnitLevel("player") == 80 then return end

local _, caelStats = ...

caelStats.experience = caelPanel3:CreateFontString(nil, "OVERLAY")
caelStats.experience:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 10)
caelStats.experience:SetPoint("BOTTOM", caelPanel3, "BOTTOM", 0, 5)

caelStats.eventFrame = CreateFrame("Frame", nil, UIParent)
caelStats.eventFrame:SetAllPoints(caelStats.experience)
caelStats.eventFrame:EnableMouse(true)
caelStats.eventFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelStats.eventFrame:RegisterEvent("UNIT_PET")
caelStats.eventFrame:RegisterEvent("UNIT_LEVEL")
caelStats.eventFrame:RegisterEvent("UNIT_EXPERIENCE")
caelStats.eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
caelStats.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelStats.eventFrame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")

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
		xpString = string.format("|cffD7BEA5XP|r %.1f%%", ((xp/maxXp)*100))
	else
		xpString = string.format("|cffD7BEA5XP|r %.1f%% |cffD7BEA5Pet|r %.0f%%", ((xp/maxXp)*100), ((petXp/petMaxXp)*100))
	end

	caelStats.experience:SetText(xpString)

	if retval then
		return string.format("|cffD7BEA5Player|r %s / %s", xp, maxXp), (petMaxXp and petMaxXp > 0) and string.format("|cffD7BEA5Pet|r %s / %s", petXp, petMaxXp) or nil
	end
end

caelStats.eventFrame:HookScript("OnEvent", function(...) OnEvent(false, ...) end)

caelStats.eventFrame:HookScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)
	local playerXp, petXp = OnEvent(true)
	GameTooltip:AddLine(playerXp)
	if petXp then
		GameTooltip:AddLine(petXp)
	end
	GameTooltip:Show()
end)