--[[	$Id$	]]

local _, caelStats = ...

caelStats.coords = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.coords:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 10)
caelStats.coords:SetPoint("CENTER", caelPanel8, "CENTER", 425, 1) 

caelStats.coordsFrame = CreateFrame("Frame", nil, UIParent)
caelStats.coordsFrame:SetAllPoints(caelStats.coords)
caelStats.coordsFrame:EnableMouse(true)
caelStats.coordsFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelStats.coordsFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

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

caelStats.coordsFrame:SetScript("OnEvent", function(self, event)
	if event == "ZONE_CHANGED_NEW_AREA" then
		SetMapToCurrentZone()
	end
end)

local delay = 0
caelStats.coordsFrame:SetScript("OnUpdate", function(self, elapsed)
	delay = delay - elapsed
	if delay <= 0 then
	local x, y = GetPlayerMapPosition("player")
		if x == 0 and y == 0 then
			caelStats.coords:SetText("")
		else
--			caelStats.coords:SetFormattedText("|cffD7BEA5Loc|r %.0f, %.0f", x * 100, y * 100)
			caelStats.coords:SetFormattedText("|cffD7BEA5x|r %0.1f |cffD7BEA5y|r %0.1f", x * 100, y * 100)
		end
	delay = 0.2
	end
end)

local zoneName, zoneColor, subzoneName
caelStats.coordsFrame:SetScript("OnEnter", function(self)
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

caelStats.coordsFrame:SetScript("OnMouseDown", function(self, button)
	if not InCombatLockdown() then
		if (button == "LeftButton") then
			ToggleFrame(WorldMapFrame)
		elseif(button == "RightButton") then
			ToggleBattlefieldMinimap()
		end
	end
end)