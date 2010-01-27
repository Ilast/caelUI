caelMap = CreateFrame("Frame")

local dummy = function() end
local Kill = function(object)
	object.Show = dummy
	object:Hide()
end

local Player = WorldMapButton:CreateFontString(nil, "ARTWORK")
Player:SetPoint("TOPLEFT", WorldMapButton, 0, 40)
Player:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 11)
Player:SetTextColor(0.84, 0.75, 0.65)

local Cursor = WorldMapButton:CreateFontString(nil, "ARTWORK")
Cursor:SetPoint("TOPLEFT", WorldMapButton, 0, 20)
Cursor:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 11)
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

local OnUpdate = function(self)
	color = RAID_CLASS_COLORS[select(2, UnitClass(self.unit))]
	self.icon:SetVertexColor(color.r, color.g, color.b)
end

local OnEvent = function()
	for r = 1, 40 do
		if UnitInParty(_G["WorldMapRaid"..r].unit) then
			_G["WorldMapRaid"..r].icon:SetTexture([=[Interface\Addons\caelMedia\Miscellaneous\partyicon]=])
		else
			_G["WorldMapRaid"..r].icon:SetTexture([=[Interface\Addons\caelMedia\Miscellaneous\raidicon]=])
		end
		_G["WorldMapRaid"..r]:SetScript("OnUpdate", OnUpdate)
	end

	for p = 1, 4 do
		_G["WorldMapParty"..p].icon:SetTexture([=[Interface\Addons\caelMedia\Miscellaneous\partyicon]=])
		_G["WorldMapParty"..p]:SetScript("OnUpdate", OnUpdate)
	end

	if event == "PLAYER_ENTERING_WORLD" then
		Kill(BlackoutWorld)
		Kill(WorldMapQuestDetailScrollFrame)
		Kill(WorldMapQuestRewardScrollFrame)
		Kill(WorldMapQuestScrollFrame)
		Kill(WorldMapBlobFrame)
		Kill(WorldMapQuestShowObjectives)
		Kill(WorldMapFrameSizeDownButton)
		Kill(WorldMapZoneMinimapDropDown)
		Kill(WorldMapZoomOutButton)
		Kill(WorldMapLevelUpButton)
		Kill(WorldMapLevelDownButton)

		SetCVar("questPOI", 1)

		UIPanelWindows["WorldMapFrame"] = {area = "center", pushable = 9}
		WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)

		WorldMapPositioningGuide:ClearAllPoints()
		WorldMapPositioningGuide:SetPoint("CENTER")
		WorldMapPositioningGuide.SetPoint = dummy

		WorldMapDetailFrame:SetScale(1)
		WorldMapDetailFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOP", -502, -69)

		WorldMapButton:SetScale(1)
		WorldMapButton.SetScale = dummy
		WorldMapButton.GetCenter = function() return 0, 0 end

		WorldMapPOIFrame:SetScale(1)
		WorldMapPOIFrame.ratio = 1
		WorldMapPOIFrame.SetScale = dummy
		WorldMapFrame_SetPOIMaxBounds()

		WorldMapQuestPOI_OnLeave = function()
			WorldMapTooltip:Hide()
		end

		WorldMapFrame.scale = 1
		WorldMapFrame:SetScale(0.65)
		WorldMapFrame.SetScale = dummy
		WorldMapFrame:SetAlpha(0.75)
		WorldMapFrame.SetAlpha = dummy
		
		WorldMapFrame:EnableKeyboard(false)
		WorldMapFrame.EnableKeyboard = dummy
		WorldMapFrame:EnableMouse(false)
		WorldMapFrame.EnableMouse = dummy
		
		WorldMapFrame.sizedDown = true

		WorldMapFrame:HookScript("OnShow", function()
			WorldMap_LoadTextures()
		end)

		WorldMapFrame_AdjustMapAndQuestList = dummy
		
	elseif event == "WORLD_MAP_UPDATE" then
		WatchFrame_GetCurrentMapQuests()
		WatchFrame_Update()
		WorldMapFrame_UpdateQuests()
	end
end

caelMap:SetScript("OnEvent", OnEvent)
caelMap:RegisterEvent("PLAYER_ENTERING_WORLD")
caelMap:RegisterEvent("PARTY_MEMBERS_CHANGED")
caelMap:RegisterEvent("RAID_ROSTER_UPDATE")
caelMap:RegisterEvent("WORLD_MAP_UPDATE")