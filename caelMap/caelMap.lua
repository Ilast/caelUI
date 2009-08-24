caelMap = CreateFrame("Frame")

local Player = WorldMapButton:CreateFontString(nil, "ARTWORK")
Player:SetPoint("TOPLEFT", WorldMapButton, 0, 40)
Player:SetFont([=[Interface\Addons\caelCooldowns\media\neuropol x cd rg.ttf]=], 11)
Player:SetTextColor(0.84, 0.75, 0.65)

local Cursor = WorldMapButton:CreateFontString(nil, "ARTWORK")
Cursor:SetPoint("TOPLEFT", WorldMapButton, 0, 20)
Cursor:SetFont([=[Interface\Addons\caelCooldowns\media\neuropol x cd rg.ttf]=], 11)
Cursor:SetTextColor(0.84, 0.75, 0.65)

WorldMapButton:HookScript("OnUpdate", function(self, u)
	local PlayerX, PlayerY = GetPlayerMapPosition("player")
	Player:SetFormattedText("Player X, Y • %.1f, %.1f", PlayerX * 100, PlayerY * 100)

	local CenterX, CenterY = WorldMapDetailFrame:GetCenter()
	local CursorX, CursorY = GetCursorPosition()
	CursorX = ((CursorX / WorldMapFrame:GetScale()) - (CenterX - (WorldMapDetailFrame:GetWidth() / 2))) / 10
	CursorY = (((CenterY + (WorldMapDetailFrame:GetHeight() / 2)) - (CursorY / WorldMapFrame:GetScale())) / WorldMapDetailFrame:GetHeight()) * 100
	
	if CursorX >= 100 or CursorY >= 100 or CursorX <= 0 or CursorY <= 0 then
		Cursor:SetText("Cursor X, Y • |cffAF5050Out of bounds.|r")
	else
		Cursor:SetFormattedText("Cursor X, Y • %.1f, %.1f", CursorX, CursorY)
	end
end)

UIPanelWindows["WorldMapFrame"] = {area = "center", pushable = 9}
hooksecurefunc(WorldMapFrame, "Show", function(self)
	self:SetScale(0.65)
	self:SetAlpha(0.75)
	self:EnableKeyboard(false)
	self:EnableMouse(false)
	BlackoutWorld:Hide()
end)

WorldMapZoneMinimapDropDown:Hide()
WorldMapZoomOutButton:Hide()

local OnUpdate = function(self)
	color = RAID_CLASS_COLORS[select(2, UnitClass(self.unit))]
	self.icon:SetVertexColor(color.r, color.g, color.b)
end

local OnEvent = function()
	for r = 1, 40 do
		if UnitInParty(_G["WorldMapRaid"..r].unit) then
			_G["WorldMapRaid"..r].icon:SetTexture([=[Interface\Addons\caelMap\media\partyIcon]=])
		else
			_G["WorldMapRaid"..r].icon:SetTexture([=[Interface\Addons\caelMap\media\raidIcon]=])
		end
		_G["WorldMapRaid"..r]:SetScript("OnUpdate", OnUpdate)
	end

	for p = 1, 4 do
		_G["WorldMapParty"..p].icon:SetTexture([=[Interface\Addons\caelMap\media\partyIcon]=])
		_G["WorldMapParty"..p]:SetScript("OnUpdate", OnUpdate)
	end
end

caelMap:SetScript("OnEvent", OnEvent)
caelMap:RegisterEvent("PARTY_MEMBERS_CHANGED")
caelMap:RegisterEvent("RAID_ROSTER_UPDATE")
caelMap:RegisterEvent("WORLD_MAP_UPDATE")