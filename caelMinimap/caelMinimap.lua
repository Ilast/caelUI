--[[	$Id$	]]

local caelMinimap = CreateFrame("Frame", nil, Minimap)

local nextBattleTimer

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

	nextBattleTimer = caelPanel3:CreateFontString(nil, "OVERLAY")
	nextBattleTimer:SetPoint("BOTTOM", 0, 5)
	nextBattleTimer:SetFont(caelMedia.fonts.NORMAL, 10)

	DurabilityFrame:UnregisterAllEvents()
	MiniMapMailFrame:UnregisterAllEvents()
	MiniMapInstanceDifficulty:UnregisterAllEvents()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

local delay = 0
Minimap:SetScript("OnUpdate", function(self, elapsed)
	delay = delay - elapsed
	if delay < 0 then
		local nextBattleTime = GetWintergraspWaitTime()
		if not IsInInstance() then
			if nextBattleTime then
				local seconds = mod(nextBattleTime, 60)
				local minutes = mod(floor(nextBattleTime / 60), 60)
				local hours = floor(nextBattleTime / 3600)
				nextBattleTimer:SetFormattedText("WG in %sh %sm %ss", hours, minutes, seconds)
			else
				nextBattleTimer:SetText("WG in progress")
			end
		end
		delay = 1
	end
end)