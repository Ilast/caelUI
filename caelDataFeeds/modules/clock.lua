--[[	$Id$	]]

local _, caelDataFeeds = ...

caelDataFeeds.clock = caelDataFeeds.createModule("Clock")

local clock = caelDataFeeds.clock

clock.text:SetPoint("RIGHT", caelPanel8, "RIGHT", caelLib.scale(-10), caelLib.scale(1))

clock:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
clock:RegisterEvent("PLAYER_ENTERING_WORLD")

local delay = 0
clock:SetScript("OnUpdate", function(self, elapsed)
	delay = delay - elapsed
	if delay < 0 then
		self.text:SetText(date("%H:%M:%S"))
		delay = 1
	end
end)

clock:SetScript("OnEvent", function(self, event)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		-- Hides the stupid clock because Blizzard was cool enough to remove the showClock CVAR! GO BLIZZARD YOU ROCK!!
		TimeManagerClockButton:Hide()
	elseif ( event == "CALENDAR_UPDATE_PENDING_INVITES" ) then
		if _G.CalendarGetNumPendingInvites() > 0 then
			self.text:SetTextColor(0.33, 0.59, 0.33)
		else
			self.text:SetTextColor(1, 1, 1)
		end
	end
end)

clock:SetScript("OnMouseDown", function(_, button)
	if (button == "LeftButton") then
		ToggleTimeManager()
	else
		GameTimeFrame:Click()
	end
end)

clock:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, caelLib.scale(4))
	GameTooltip:AddLine(date("%B, %A %d %Y"), 0.84, 0.75, 0.65)
	GameTooltip:Show()
end)
