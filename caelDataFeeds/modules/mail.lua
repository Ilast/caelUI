--[[	$Id: mail.lua 818 2010-03-29 06:52:53Z sdkyron@gmail.com $	]]

local _, caelDataFeeds = ...

caelDataFeeds.mail, caelDataFeeds.mailFrame = Create()

caelDataFeeds.mail:SetPoint("CENTER", caelPanel8, "CENTER", 0, 1)

caelDataFeeds.mailFrame:RegisterEvent("UPDATE_PENDING_MAIL")
caelDataFeeds.mailFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

caelDataFeeds.mailFrame:SetScript("OnEvent", function(self, event)
	if HasNewMail() then
		caelDataFeeds.mail:SetText("New mail", 1, 1, 1)
	else
		caelDataFeeds.mail:SetText("")
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