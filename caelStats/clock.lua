--[[	$Id$	]]

local _, caelStats = ...

caelStats.clock = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.clock:SetFontObject(neuropolrg10)
caelStats.clock:SetPoint("RIGHT", caelPanel8, "RIGHT", -10, 1) 

caelStats.eventFrame = CreateFrame("Frame", nil, UIParent)
caelStats.eventFrame:SetAllPoints(caelStats.clock)
caelStats.eventFrame:EnableMouse(true)
caelStats.eventFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelStats.eventFrame:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")

local delay = 0
caelStats.eventFrame:HookScript("OnUpdate", function(self, elapsed)
	delay = delay - elapsed
	if delay < 0 then
		caelStats.clock:SetText(date("%H:%M:%S"))
		delay = 1
	end
end)

caelStats.eventFrame:HookScript("OnEvent", function(self, event)
	if event == "CALENDAR_UPDATE_PENDING_INVITES" then
		if _G.CalendarGetNumPendingInvites() > 0 then
			caelStats.clock:SetTextColor(0.33, 0.59, 0.33)
		else
			caelStats.clock:SetTextColor(1, 1, 1)
		end
	end
end)

caelStats.eventFrame:HookScript("OnMouseDown", function(self, button)
	if (button == "LeftButton") then
		ToggleTimeManager()
	else
		GameTimeFrame:Click()
	end
end)

caelStats.eventFrame:HookScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)
	GameTooltip:AddLine(date("%B, %A %d %Y"), 0.84, 0.75, 0.65)
	GameTooltip:Show()
end)