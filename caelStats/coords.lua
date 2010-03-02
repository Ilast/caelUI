local _, caelStats = ...

local Holder = CreateFrame("Frame")

caelStats.coords = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.coords:SetFontObject(neuropolrg10)
caelStats.coords:SetPoint("CENTER", caelPanel8, "CENTER", 425, 0.5) 

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

Holder:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Holder:SetScript("OnEvent", function()
	SetMapToCurrentZone()
end)

local delay = 0
local OnUpdate = function(self, elapsed)
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
end

local zoneName, zoneColor, subzoneName
local OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	zoneName = GetZoneText()
	subzoneName = GetSubZoneText()
	zoneColor = ColorizePVPType(GetZonePVPInfo())

	if subzoneName == zoneName then
		subzoneName = ""
	end

	GameTooltip:AddLine(zoneName, zoneColor.r, zoneColor.g, zoneColor.b)
	GameTooltip:AddLine(subzoneName, 0.84, 0.75, 0.65)
	GameTooltip:Show()
end

local OnClick = function(self, button)
	if not InCombatLockdown() then
		if (button == "LeftButton") then
			ToggleFrame(WorldMapFrame)
		elseif(button == "RightButton") then
			ToggleBattlefieldMinimap()
		end
	end
end

Holder:EnableMouse(true)
Holder:SetAllPoints(caelStats.coords)
Holder:SetScript("OnEnter", OnEnter)
Holder:SetScript("OnLeave", function() GameTooltip:Hide() end)
Holder:SetScript("OnMouseDown", OnClick)
Holder:SetScript("OnUpdate", OnUpdate)