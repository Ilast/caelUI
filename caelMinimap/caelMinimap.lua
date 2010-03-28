--[[	$Id$	]]

local caelMinimap = CreateFrame("Frame", nil, Minimap)

for _, object in pairs({
		GameTimeFrame,
		MinimapBorder,
		MinimapZoomIn,
		MinimapZoomOut,
		MinimapNorthTag,
		MinimapBorderTop,
		MinimapToggleButton,
		MiniMapWorldMapButton,
		MinimapZoneTextButton,
		MiniMapBattlefieldBorder,
		MiniMapTrackingBackground,
		MiniMapTrackingIconOverlay,
		MiniMapTrackingButtonBorder,
}) do
	if object:GetObjectType() == "Texture" then
		object:SetTexture(nil)
	else
		object:Hide()
	end
end

Minimap:RegisterEvent("PLAYER_ENTERING_WORLD")
Minimap:SetScript("OnEvent", function(self, event, ...)
	self:EnableMouse(true)
	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", function(frame, direction)
		if direction > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)

	self:ClearAllPoints()
	self:SetParent(UIParent)
	self:SetScale(0.875)
	self:SetPoint("BOTTOM", UIParent, 0, 27.25)
	self:SetBackdrop{
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {left = -1, right = -0.5, top = -1.5, bottom = -0.5},
}
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	self:SetBlipTexture([=[Interface\Addons\caelMedia\miscellaneous\charmed.tga]=])

	MinimapCluster:EnableMouse(false)

	MiniMapBattlefieldFrame:SetParent(self)
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("TOPRIGHT", 1, -2)

	MiniMapTracking:SetParent(self)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("TOPLEFT")
	MiniMapTracking:SetAlpha(0)

	MiniMapTrackingButton:SetHighlightTexture(nil)
	MiniMapTrackingButton:SetScript("OnEnter", function() MiniMapTracking:SetAlpha(1) end)
	MiniMapTrackingButton:SetScript("OnLeave", function() MiniMapTracking:SetAlpha(0) end)

	DurabilityFrame:UnregisterAllEvents()
	MiniMapMailFrame:UnregisterAllEvents()
	MiniMapInstanceDifficulty:UnregisterAllEvents()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)