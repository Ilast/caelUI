--[[	$Id$	]]

local dummy = caelLib.dummy

WatchFrame:ClearAllPoints()
WatchFrame:SetHeight(caelLib.scale(600))
WatchFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", caelLib.scale(-15), caelLib.scale(-15))
WatchFrameCollapseExpandButton:Hide()

WatchFrame.ClearAllPoints = dummy
WatchFrame.SetPoint = dummy
WatchFrameCollapseExpandButton.Show = dummy

local ZoneChange = function(zone)
	local _, instanceType = IsInInstance()
	if instanceType == "arena" then
		WatchFrame:Hide()
	else
		WatchFrame:Show()
	end
end

WatchFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
WatchFrame:RegisterEvent("WORLD_MAP_UPDATE")
WatchFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
WatchFrame:HookScript("OnEvent", function(self, event)
	if event == "ZONE_CHANGED_NEW_AREA" or event == "WORLD_MAP_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
		local zone = GetRealZoneText()
		if zone and zone ~= "" then
			return ZoneChange(zone)
		end
	end
end)