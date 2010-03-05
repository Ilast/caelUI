local _, caelStats = ...

local Holder = CreateFrame("Frame")

caelStats.clock = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.clock:SetFontObject(neuropolrg10)
caelStats.clock:SetPoint("RIGHT", caelPanel8, "RIGHT", -10, 1) 

local delay = 0
local OnUpdate = function(self, elapsed)
	delay = delay - elapsed
	if delay < 0 then
		caelStats.clock:SetText(date("%H:%M:%S"))
--[[
		Hr, Min = GetGameTime()
		if Hr == 0 then Hr = 12 end
		if Min < 10 then Min = "0"..Min end
		if Hr > 12 then
			Hr = Hr - 12
			caelStats.clock:SetText(Hr..":"..Min)
		else
			caelStats.clock:SetText(Hr..":"..Min.." |cffD7BEA5AM|r")
		end]]
		delay = 1
	end
end

local OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)
	GameTooltip:AddLine(date("%B, %A %d %Y"))
	GameTooltip:Show()
end

local OnEvent = function(self)
	if _G.CalendarGetNumPendingInvites() > 0 then
		caelStats.clock:SetTextColor(0.33, 0.59, 0.33)
	else
		caelStats.clock:SetTextColor(1, 1, 1)
	end
end

local OnClick = function(self, button)
	if (button == "LeftButton") then
		ToggleTimeManager()
	else
		GameTimeFrame:Click()
	end
end

Holder:EnableMouse(true)
Holder:SetAllPoints(caelStats.clock)
Holder:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
Holder:SetScript("OnEvent", OnEvent)
Holder:SetScript("OnUpdate", OnUpdate)
Holder:SetScript("OnEnter", OnEnter)
Holder:SetScript("OnLeave", function() GameTooltip:Hide() end)
Holder:SetScript("OnMouseDown", OnClick)