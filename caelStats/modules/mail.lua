local Holder = CreateFrame("Frame")

caelStats.mail = caelPanel10:CreateFontString(nil, "OVERLAY")
caelStats.mail:SetFont(font, fontSize, fontOutline)
caelStats.mail:SetPoint("CENTER", caelPanel10, "CENTER", 0, 0.5)

local function OnEvent(self)
	if HasNewMail() then
		caelStats.mail:SetText("New Mail!", 1, 1, 1)
	else
		caelStats.mail:SetText("No Mail", 1, 1, 1)
	end
end

local OnEnter = function(self)
	if not InCombatLockdown() then
		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 5)
	
		local sender1, sender2, sender3 = GetLatestThreeSenders()
		if sender1 then GameTooltip:AddLine("|cffD7BEA51. |r"..sender1) end
		if sender2 then GameTooltip:AddLine("|cffD7BEA52. |r"..sender2) end
		if sender3 then GameTooltip:AddLine("|cffD7BEA53. |r"..sender3) end	
		GameTooltip:Show()
	end
end

Holder:EnableMouse(true)
Holder:SetAllPoints(caelStats.mail)
Holder:RegisterEvent("UPDATE_PENDING_MAIL")
Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
Holder:SetScript("OnEvent", OnEvent)
Holder:SetScript("OnEnter", OnEnter)
Holder:SetScript("OnLeave", function() GameTooltip:Hide() end)