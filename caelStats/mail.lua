--[[	$Id$	]]

local _, caelStats = ...

caelStats.mail = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.mail:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 10)
caelStats.mail:SetPoint("CENTER", caelPanel8, "CENTER", 0, 1)

caelStats.eventFrame = CreateFrame("Frame", nil, UIParent)
caelStats.eventFrame:SetAllPoints(caelStats.mail)
caelStats.eventFrame:EnableMouse(true)
caelStats.eventFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelStats.eventFrame:RegisterEvent("UPDATE_PENDING_MAIL")
caelStats.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

caelStats.eventFrame:HookScript("OnEvent", function(self, event)
	if event == "UPDATE_PENDING_MAIL" then
		if HasNewMail() then
			caelStats.mail:SetText("New mail", 1, 1, 1)
		else
			caelStats.mail:SetText("")
		end
	end
end)

caelStats.eventFrame:HookScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	local sender1, sender2, sender3 = GetLatestThreeSenders()
	if sender1 then GameTooltip:AddLine("|cffD7BEA51. |r"..sender1) end
	if sender2 then GameTooltip:AddLine("|cffD7BEA52. |r"..sender2) end
	if sender3 then GameTooltip:AddLine("|cffD7BEA53. |r"..sender3) end	
	GameTooltip:Show()
end)