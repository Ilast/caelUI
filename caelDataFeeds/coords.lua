--[[	$Id$	]]

local _, caelDataFeeds = ...

caelDataFeeds.coords = caelPanel8:CreateFontString(nil, "OVERLAY")
caelDataFeeds.coords:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 10)
caelDataFeeds.coords:SetPoint("CENTER", caelPanel8, "CENTER", 425, 1) 

caelDataFeeds.coordsFrame = CreateFrame("Frame", nil, UIParent)
caelDataFeeds.coordsFrame:SetAllPoints(caelDataFeeds.coords)
caelDataFeeds.coordsFrame:EnableMouse(true)
caelDataFeeds.coordsFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelDataFeeds.coordsFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

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

caelDataFeeds.coordsFrame:SetScript("OnEvent", function(self, event)
	SetMapToCurrentZone()
end)

local delay = 0
caelDataFeeds.coordsFrame:SetScript("OnUpdate", function(self, elapsed)
	delay = delay - elapsed
	if delay <= 0 then
	local x, y = GetPlayerMapPosition("player")
		if x == 0 and y == 0 then
			caelDataFeeds.coords:SetText("")
		else
--			caelDataFeeds.coords:SetFormattedText("|cffD7BEA5Loc|r %.0f, %.0f", x * 100, y * 100)
			caelDataFeeds.coords:SetFormattedText("|cffD7BEA5x|r %0.1f |cffD7BEA5y|r %0.1f", x * 100, y * 100)
		end
	delay = 0.2
	end
end)

local zoneName, zoneColor, subzoneName
caelDataFeeds.coordsFrame:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	zoneName = GetZoneText()
	subzoneName = GetSubZoneText()
	zoneColor = ColorizePVPType(GetZonePVPInfo())

	if subzoneName == zoneName then
		subzoneName = ""
	end

	GameTooltip:AddDoubleLine(zoneName, subzoneName, zoneColor.r, zoneColor.g, zoneColor.b, 0.84, 0.75, 0.65)
	GameTooltip:Show()
end)

caelDataFeeds.coordsFrame:SetScript("OnMouseDown", function(self, button)
	if not InCombatLockdown() then
		if (button == "LeftButton") then
			ToggleFrame(WorldMapFrame)
		elseif(button == "RightButton") then
			ToggleBattlefieldMinimap()
		end
	end
end)