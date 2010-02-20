local caelMinimap = CreateFrame("Frame", nil, Minimap)
local dummy = function() end

local onMouseWheel = function(self, direction)
	local zoom = Minimap:GetZoom()
	if not direction then return end
	if direction > 0 and zoom < 5 then
		Minimap:SetZoom(zoom + 1)
	elseif direction < 0 and zoom > 0 then
		Minimap:SetZoom(zoom - 1)
	end
end

local onEvent = function(self, event)
	self:SetAllPoints(Minimap)
	self:EnableMouse(false)
	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", onMouseWheel)

	local regions = {
		GameTimeFrame,
		MinimapBorder,
		MinimapZoomIn,
		MinimapZoomOut,
		MinimapNorthTag,
		MinimapBorderTop,
		MiniMapMailBorder,
		MinimapToggleButton,
--		MiniMapWorldMapButton,
--		MinimapZoneTextButton,
		MiniMapBattlefieldBorder,
		MiniMapTrackingBackground,
		MiniMapTrackingButtonBorder,
	}

	for _, frame in ipairs(regions) do
		frame:Hide()
		frame.Show = dummy
	end

	MiniMapTrackingButton:SetScript("OnEnter", function() MiniMapTracking:SetAlpha(1) end)
	MiniMapTrackingButton:SetScript("OnLeave", function() MiniMapTracking:SetAlpha(0) end)
end

	MiniMapWorldMapButton:Hide()
	MinimapZoneTextButton:Hide()
	
	MiniMapInstanceDifficulty:ClearAllPoints()
	MiniMapInstanceDifficulty:SetParent(Minimap)
	MiniMapInstanceDifficulty:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT")
	
	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetParent(Minimap)
	MiniMapLFGFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT")
	
MinimapCluster:EnableMouse(false)

Minimap:ClearAllPoints()
Minimap:SetScale(0.875)
Minimap:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 27.25)
Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
Minimap:SetBackdrop{
	bgFile = [=[Interface\Tooltips\UI-Tooltip-Background]=],
	insets = {left = -1, right = -0.5, top = -1.5, bottom = -0.5},
}
Minimap:SetBackdropColor(0, 0, 0, 1)
Minimap:SetBlipTexture([=[Interface\Addons\caelMedia\Miscellaneous\charmed.tga]=])

MiniMapTracking:SetParent(Minimap)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("TOPLEFT")
MiniMapTracking:SetAlpha(0)
MiniMapTrackingButton:SetHighlightTexture("")

MiniMapBattlefieldFrame:SetParent(Minimap)
MiniMapBattlefieldFrame:ClearAllPoints()
MiniMapBattlefieldFrame:SetPoint("TOPRIGHT", 1, -2)

MiniMapMailFrame:SetParent(Minimap)
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("TOP")
MiniMapMailFrame:EnableMouse(false)
MiniMapMailIcon:SetTexture([=[Interface\Addons\caelMedia\Miscellaneous\mail]=])
MiniMapMailIcon:Hide()

caelMinimap:SetScript("OnEvent", onEvent)
caelMinimap:RegisterEvent("PLAYER_ENTERING_WORLD")

function GetMinimapShape() return "SQUARE" end