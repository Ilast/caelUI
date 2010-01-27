local caelMinimap = CreateFrame("Frame", nil, Minimap)
local dummy = function() end
--[[
local font, fontSize, fontOutline = [=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 11, "OUTLINE"

local AddonsMemoryCompare = function(a, b)
	return a.memory > b.memory
end

local FormatMemoryNumber = function(number)
	if number > 1000 then
		return string.format("%.2f mb", number / 1000)
	else
		return string.format("%.1f kb", number)
	end
end

local ColorizeLatency = function(number)
	if number <= 100 then
		return {r = 0, g = 1, b = 0}
	elseif number <= 200 then
		return {r = 1, g = 1, b = 0}
	else
		return {r = 1, g = 0, b = 0}
	end
end

local ColorizePVPType = function(pvpType)
	if pvpType == "sanctuary" then
		return {r = 0.41, g = 0.8, b = 0.94}
	elseif pvpType == "friendly" then
		return {r = 0.1, g = 1.0, b = 0.1}
	elseif pvpType == "arena" or pvpType == "hostile" then
		return {r = 1.0, g = 0.1, b = 0.1}
	elseif pvpType == "contested" then
		return {r = 1.0, g = 0.7, b = 0.0}
	else
		return NORMAL_FONT_COLOR
	end
end

local onClickClock = function(self, button)
	if (button == "RightButton") then
		local collected = collectgarbage("count")
		collectgarbage("collect")
		GameTooltip:AddLine("---------- ---------- ---------- ---------- ----------")
		GameTooltip:AddDoubleLine("Garbage Collected:", FormatMemoryNumber(collected - collectgarbage("count")))
		GameTooltip:Show()
	else
		ToggleCalendar()
	end
end

local zoneName, zoneColor, subzoneName
local memoryFormat = "%.2f %s"
local latency, latencyColor, Addons, totalMemory
local memory, addon, i
local onEnter = function(self)
	GameTooltip:SetOwner(TimeManagerClockButton, "ANCHOR_BOTTOMLEFT")
	
	zoneName = GetZoneText()
	subzoneName = GetSubZoneText()
	zoneColor = ColorizePVPType(GetZonePVPInfo())

	if subzoneName == zoneName then
		subzoneName = ""
	end

	GameTooltip:AddLine(zoneName, zoneColor.r, zoneColor.g, zoneColor.b)
	GameTooltip:AddLine(subzoneName, 0.84, 0.75, 0.65)
	GameTooltip:AddLine("---------- ---------- ---------- ---------- ----------")
	
	latency = select(3, GetNetStats())
	latencyColor = ColorizeLatency(latency)
	
	GameTooltip:AddLine(string.format("Latency: %d ms", latency), latencyColor.r, latencyColor.g, latencyColor.b)
	GameTooltip:AddLine(string.format("Framerate: %.1f", GetFramerate()), 0.65, 0.63, 0.35)
	GameTooltip:AddLine("---------- ---------- ---------- ---------- ----------")

	Addons = {}
	totalMemory = 0

	UpdateAddOnMemoryUsage()

	for i = 1, GetNumAddOns(), 1 do
		if(IsAddOnLoaded(i)) then
			memory = GetAddOnMemoryUsage(i)
			addon = {name = GetAddOnInfo(i), memory = memory}
			table.insert(Addons, addon)
			totalMemory = totalMemory + memory
		end
	end

	table.sort(Addons, AddonsMemoryCompare)

	i = 0
	for _, addon in ipairs(Addons) do
		GameTooltip:AddDoubleLine(addon.name, FormatMemoryNumber(addon.memory), 0.84, 0.75, 0.65, 0.65, 0.63, 0.35)

		i = i + 1
		
		if i >= 50 then
			break
		end
	end

	GameTooltip:AddLine("---------- ---------- ---------- ---------- ----------")
	GameTooltip:AddDoubleLine("Addon Memory Usage", FormatMemoryNumber(totalMemory), 0.84, 0.75, 0.65, 0.65, 0.63, 0.35)

	GameTooltip:SetBackdrop{
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		edgeFile = [=[Interface\Tooltips\UI-Tooltip-Border]=], edgeSize = 2,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	GameTooltip:SetBackdropColor(0, 0, 0, 0.5)
	GameTooltip:SetBackdropBorderColor(0, 0, 0)

	GameTooltip:Show()
end
]]
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

--	TimeManagerClockButton:SetScript("OnEnter", onEnter)
--	TimeManagerClockButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
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

--[[
TimeManager_LoadUI()
TimeManagerClockButton:ClearAllPoints()
TimeManagerClockButton:SetPoint("BOTTOMLEFT", -12, -6)
TimeManagerClockButton:GetRegions():Hide()
TimeManagerClockButton:SetScript("OnClick", onClickClock)

TimeManagerClockTicker:SetPoint("CENTER", TimeManagerClockButton)
TimeManagerClockTicker:SetFont(font, 11, "OUTLINE")
TimeManagerClockTicker:SetTextColor(0.84, 0.75, 0.65)

local CoordString = Minimap:CreateFontString("CoordString", "OVERLAY")
CoordString:SetPoint("BOTTOMRIGHT", 0, 2)
CoordString:SetFont(font, fontSize, fontOutline)
CoordString:SetTextColor(0.84, 0.75, 0.65)

local CoordFrame = CreateFrame("Frame")
CoordFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
CoordFrame:SetScript("OnEvent", function()
	SetMapToCurrentZone()
end)

local interval = 0
CoordFrame:SetScript("OnUpdate", function(self, elapsed)
	interval = interval - elapsed
	if (interval <= 0) then
	local x,y = GetPlayerMapPosition("player")
		if (x == 0 and y == 0) then
			CoordString:SetText("")
		else
			CoordString:SetFormattedText("%.0f, %.0f", x * 100, y * 100)
		end
	interval = 1
	end
end)]]

caelMinimap:SetScript("OnEvent", onEvent)
caelMinimap:RegisterEvent("PLAYER_ENTERING_WORLD")

function GetMinimapShape() return "SQUARE" end