--[[	$Id$	]]

local _, caelStats = ...

caelStats.mail = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.mail:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 10)
caelStats.mail:SetPoint("CENTER", caelPanel8, "CENTER", 0, 1)

caelStats.mailFrame = CreateFrame("Frame", nil, UIParent)
caelStats.mailFrame:SetAllPoints(caelStats.mail)
caelStats.mailFrame:EnableMouse(true)
caelStats.mailFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelStats.mailFrame:RegisterEvent("UPDATE_PENDING_MAIL")
caelStats.mailFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

caelStats.mailFrame:HookScript("OnEvent", function(self, event)
	if event == "UPDATE_PENDING_MAIL" then
		if HasNewMail() then
			caelStats.mail:SetText("New mail", 1, 1, 1)
		else
			caelStats.mail:SetText("")
		end
	end
end)

caelStats.mailFrame:HookScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	local sender1, sender2, sender3 = GetLatestThreeSenders()
	if sender1 then GameTooltip:AddLine("|cffD7BEA51. |r"..sender1) end
	if sender2 then GameTooltip:AddLine("|cffD7BEA52. |r"..sender2) end
	if sender3 then GameTooltip:AddLine("|cffD7BEA53. |r"..sender3) end	
	GameTooltip:Show()
end)