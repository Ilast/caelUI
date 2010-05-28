--[[	$Id$	]]

local dummy = caelLib.dummy

WatchFrame:ClearAllPoints()
WatchFrame:SetHeight(caelLib.scale(600))
WatchFrame:SetScale(0.85)
WatchFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", caelLib.scale(-15), caelLib.scale(-15))
WatchFrameCollapseExpandButton:Hide()

WatchFrame.ClearAllPoints = dummy
WatchFrame.SetPoint = dummy
WatchFrameCollapseExpandButton.Show = dummy