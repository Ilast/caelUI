--[[	$Id$	]]

local _, caelDataFeeds = ...

caelDataFeeds.clock = caelPanel8:CreateFontString(nil, "OVERLAY")
caelDataFeeds.clock:SetFont(caelMedia.files.fontRg, 10)
caelDataFeeds.clock:SetPoint("RIGHT", caelPanel8, "RIGHT", -10, 1) 

caelDataFeeds.clockFrame = CreateFrame("Frame", nil, UIParent)
caelDataFeeds.clockFrame:SetAllPoints(caelDataFeeds.clock)
caelDataFeeds.clockFrame:EnableMouse(true)
caelDataFeeds.clockFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelDataFeeds.clockFrame:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")

local delay = 0
caelDataFeeds.clockFrame:SetScript("OnUpdate", function(self, elapsed)
	delay = delay - elapsed
	if delay < 0 then
		caelDataFeeds.clock:SetText(date("%H:%M:%S"))
		delay = 1
	end
end)

caelDataFeeds.clockFrame:SetScript("OnEvent", function(self, event)
	if _G.CalendarGetNumPendingInvites() > 0 then
		caelDataFeeds.clock:SetTextColor(0.33, 0.59, 0.33)
	else
		caelDataFeeds.clock:SetTextColor(1, 1, 1)
	end
end)

caelDataFeeds.clockFrame:SetScript("OnMouseDown", function(self, button)
	if (button == "LeftButton") then
		ToggleTimeManager()
	else
		GameTimeFrame:Click()
	end
end)

caelDataFeeds.clockFrame:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)
	GameTooltip:AddLine(date("%B, %A %d %Y"), 0.84, 0.75, 0.65)
	GameTooltip:Show()
end)