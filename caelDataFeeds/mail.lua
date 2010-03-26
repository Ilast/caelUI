--[[	$Id: mail.lua 678 2010-03-19 07:33:13Z sdkyron@gmail.com $	]]

local _, caelDataFeeds = ...

caelDataFeeds.mail = caelPanel8:CreateFontString(nil, "OVERLAY")
caelDataFeeds.mail:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 10)
caelDataFeeds.mail:SetPoint("CENTER", caelPanel8, "CENTER", 0, 1)

caelDataFeeds.mailFrame = CreateFrame("Frame", nil, UIParent)
caelDataFeeds.mailFrame:SetAllPoints(caelDataFeeds.mail)
caelDataFeeds.mailFrame:EnableMouse(true)
caelDataFeeds.mailFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelDataFeeds.mailFrame:RegisterEvent("UPDATE_PENDING_MAIL")
caelDataFeeds.mailFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

caelDataFeeds.mailFrame:SetScript("OnEvent", function(self, event)
	if event == "UPDATE_PENDING_MAIL" then
		if HasNewMail() then
			caelDataFeeds.mail:SetText("New mail", 1, 1, 1)
		else
			caelDataFeeds.mail:SetText("")
		end
	end
end)

caelDataFeeds.mailFrame:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	local sender1, sender2, sender3 = GetLatestThreeSenders()
	if sender1 then GameTooltip:AddLine("|cffD7BEA51. |r"..sender1) end
	if sender2 then GameTooltip:AddLine("|cffD7BEA52. |r"..sender2) end
	if sender3 then GameTooltip:AddLine("|cffD7BEA53. |r"..sender3) end	
	GameTooltip:Show()
end)