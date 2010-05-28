--[[	$Id$	]]

-- Get namespace.
local _, caelDataFeeds = ...

-- Create Clock module.
caelDataFeeds.clock = caelDataFeeds.createModule("Clock")

-- Shorthand reference to make things easier to type.
local clock = caelDataFeeds.clock

-- Move text into position (frame is set to fontstring's position).
clock.text:SetPoint("RIGHT", caelPanel8, "RIGHT", caelLib.scale(-10), caelLib.scale(1))

-- Register necessary events.
clock:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")

-- Create an update script.
local delay = 0
clock:SetScript("OnUpdate", function(self, elapsed)
    delay = delay - elapsed
    if delay < 0 then
        -- Update the text.
        self.text:SetText(date("%H:%M:%S"))
        delay = 1
    end
end)

-- Handle registered events.
clock:SetScript("OnEvent", function(self, event)
    -- Color text based on calendar invite availability.
    if _G.CalendarGetNumPendingInvites() > 0 then
        self.text:SetTextColor(0.33, 0.59, 0.33)
    else
        self.text:SetTextColor(1, 1, 1)
    end
end)

-- Handle mouse clicks.
clock:SetScript("OnMouseDown", function(_, button)
    if (button == "LeftButton") then
        ToggleTimeManager()
    else
        GameTimeFrame:Click()
    end
end)

-- Tooltip on hover.
clock:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, caelLib.scale(4))
    GameTooltip:AddLine(date("%B, %A %d %Y"), 0.84, 0.75, 0.65)
    GameTooltip:Show()
end)