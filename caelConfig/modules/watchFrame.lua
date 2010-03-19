--[[	$Id: watchFrame.lua 515 2010-03-06 16:33:44Z sdkyron@gmail.com $	]]

local dummy = function() end

WatchFrame:ClearAllPoints()
WatchFrame:SetHeight(600)
WatchFrame:SetScale(0.85)
WatchFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -15,-15)
WatchFrameCollapseExpandButton:Hide()

WatchFrame.ClearAllPoints = dummy
WatchFrame.SetPoint = dummy
WatchFrameCollapseExpandButton.Show = dummy