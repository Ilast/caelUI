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
	self:SetParent(caelPanel3)
	self:SetFrameLevel(caelPanel3:GetFrameLevel() - 1)
	self:SetScale(0.88)
	self:SetPoint("BOTTOM", caelPanel3, 0, caelLib.scale(4))

	self:SetMaskTexture(caelMedia.files.bgFile)
	self:SetBlipTexture([=[Interface\Addons\caelMedia\miscellaneous\charmed.tga]=])

	MinimapCluster:EnableMouse(false)

	MiniMapBattlefieldFrame:SetParent(self)
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("TOPRIGHT")

	MiniMapTracking:SetParent(self)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("TOPLEFT")
	MiniMapTracking:SetAlpha(0)

	MiniMapTrackingButton:SetHighlightTexture(nil)
	MiniMapTrackingButton:SetScript("OnEnter", function() MiniMapTracking:SetAlpha(1) end)
	MiniMapTrackingButton:SetScript("OnLeave", function() MiniMapTracking:SetAlpha(0) end)

	DurabilityFrame:UnregisterAllEvents()
	MiniMapMailFrame:UnregisterAllEvents()
--	MiniMapInstanceDifficulty:UnregisterAllEvents()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)