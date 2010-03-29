--[[	$Id$	]]

if UnitLevel("player") == 80 then return end

local _, caelDataFeeds = ...

caelDataFeeds.experience, expFrame = createModule()

caelDataFeeds.experience:SetPoint("BOTTOM", caelPanel3, "BOTTOM", 0, 5)

caelDataFeeds.expFrame:RegisterEvent("UNIT_PET")
caelDataFeeds.expFrame:RegisterEvent("UNIT_LEVEL")
caelDataFeeds.expFrame:RegisterEvent("UNIT_EXPERIENCE")
caelDataFeeds.expFrame:RegisterEvent("PLAYER_XP_UPDATE")
caelDataFeeds.expFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelDataFeeds.expFrame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")

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

	caelDataFeeds.experience:SetText(xpString)

	if retval then
		return string.format("|cffD7BEA5Player|r %s / %s", xp, maxXp), (petMaxXp and petMaxXp > 0) and string.format("|cffD7BEA5Pet|r %s / %s", petXp, petMaxXp) or nil
	end
end

caelDataFeeds.expFrame:SetScript("OnEvent", function(...) OnEvent(false, ...) end)

caelDataFeeds.expFrame:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)
	local playerXp, petXp = OnEvent(true)
	GameTooltip:AddLine(playerXp)
	if petXp then
		GameTooltip:AddLine(petXp)
	end
	GameTooltip:Show()
end)