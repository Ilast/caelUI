--[[	$Id: watchFrame.lua 686 2010-03-19 09:47:09Z sdkyron@gmail.com $	]]

local dummy = function() end

WatchFrame:ClearAllPoints()
WatchFrame:SetHeight(600)
WatchFrame:SetScale(0.85)
WatchFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -15,-15)
WatchFrameCollapseExpandButton:Hide()

WatchFrame.ClearAllPoints = dummy
WatchFrame.SetPoint = dummy
WatchFrameCollapseExpandButton.Show = dummy