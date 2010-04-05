﻿--[[	$Id$	]]

local _, caelMap = ...

caelMap.eventFrame = CreateFrame("Frame")

local Player = WorldMapButton:CreateFontString(nil, "ARTWORK")
Player:SetPoint("TOPLEFT", WorldMapButton, 0, 40)
Player:SetFont(caelMedia.files.fontRg, 12)
Player:SetTextColor(0.84, 0.75, 0.65)

local Cursor = WorldMapButton:CreateFontString(nil, "ARTWORK")
Cursor:SetPoint("TOPLEFT", WorldMapButton, 0, 20)
Cursor:SetFont(caelMedia.files.fontRg, 12)
Cursor:SetTextColor(0.84, 0.75, 0.65)

local caelMap_OnUpdate = function(self)
	color = RAID_CLASS_COLORS[select(2, UnitClass(self.unit))]
	self.icon:SetVertexColor(color.r, color.g, color.b)
end

local function setupMap(self)
	WORLDMAP_QUESTLIST_SIZE = 0.7

	if WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
		ToggleFrame(WorldMapFrame)
		WorldMapFrame_ToggleWindowSize()
		ToggleFrame(WorldMapFrame)
	end

	WorldMap_ToggleSizeDown = caelLib.dummy
	WorldMap_ToggleSizeUp = caelLib.dummy

	WorldMapFrame.oArrow = PositionWorldMapArrowFrame
	PositionWorldMapArrowFrame = function(point, frame, anchor, x, y)
		local playerX, playerY = GetPlayerMapPosition("player")
		playerX = playerX * WorldMapDetailFrame:GetWidth()
		playerY = -playerY * WorldMapDetailFrame:GetHeight()
		WorldMapFrame.oArrow(point, frame, anchor, playerX * WORLDMAP_QUESTLIST_SIZE, playerY * WORLDMAP_QUESTLIST_SIZE)
	end

	SetCVar("questPOI", 1)
	WatchFrame.showObjectives = true
	QuestLogFrameShowMapButton:Show()
	WorldMapQuestShowObjectives:SetChecked(1)

	WORLDMAP_SETTINGS.size = WORLDMAP_QUESTLIST_SIZE

	UIPanelWindows["WorldMapFrame"] = { area = "center", pushable = 9, whileDead = 1 };

	caelLib.kill(BlackoutWorld)
	caelLib.kill(WorldMapQuestDetailScrollFrame)
	caelLib.kill(WorldMapQuestRewardScrollFrame)
	caelLib.kill(WorldMapQuestScrollFrame)
	caelLib.kill(WorldMapBlobFrame)
	caelLib.kill(WorldMapQuestShowObjectives)
	caelLib.kill(WorldMapFrameSizeDownButton)
	caelLib.kill(WorldMapFrameSizeUpButton)
	caelLib.kill(WorldMapFrameCloseButton)
	caelLib.kill(WorldMapZoneMinimapDropDown)
	caelLib.kill(WorldMapZoomOutButton)
	caelLib.kill(WorldMapLevelDropDown)
	caelLib.kill(WorldMapFrameTitle)
	caelLib.kill(WorldMapContinentDropDown)
	caelLib.kill(WorldMapZoneDropDown)
	caelLib.kill(WorldMapLevelUpButton)
	caelLib.kill(WorldMapLevelDownButton)
	caelLib.kill(WorldMapTrackQuest)

	WorldMapFrame:EnableKeyboard(false)
	WorldMapFrame:EnableMouse(false)
	WorldMapFrame.EnableKeyboard = caelLib.dummy
	WorldMapFrame.EnableMouse = caelLib.dummy

	WorldMap_LoadTextures = caelLib.dummy

	WorldMapPositioningGuide:ClearAllPoints()
	WorldMapPositioningGuide:SetPoint("CENTER")
	WorldMapPositioningGuide.ClearAllPoints = caelLib.dummy
	WorldMapPositioningGuide.SetPoint = caelLib.dummy

	WorldMapDetailFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOP", -502, -69)

	local function StopMessingWithMyShitBlizzard(frame)
		frame:SetScale(WORLDMAP_QUESTLIST_SIZE)
		frame.ClearAllPoints = caelLib.dummy
		frame.SetPoint = caelLib.dummy
		frame.SetScale = caelLib.dummy
		frame.SetWidth = caelLib.dummy
		frame.SetHeight = caelLib.dummy
		frame.SetSize = caelLib.dummy
	end

	StopMessingWithMyShitBlizzard(WorldMapPositioningGuide)
	StopMessingWithMyShitBlizzard(WorldMapDetailFrame)
	StopMessingWithMyShitBlizzard(WorldMapFrame)
	StopMessingWithMyShitBlizzard(WorldMapButton)
	StopMessingWithMyShitBlizzard(WorldMapBlobFrame)
	StopMessingWithMyShitBlizzard(WorldMapFrameAreaFrame)

	WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)

	WorldMapDetailFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOP", -502, -69)

	WorldMapFrame_SetPOIMaxBounds()

	WorldMapQuestPOI_OnLeave = function()
		WorldMapTooltip:Hide()
	end

	WorldMapFrame:SetAlpha(0.75)
	WorldMapFrame.SetAlpha = caelLib.dummy

	WorldMapDetailFrame.bg = CreateFrame("Frame", nil, WorldMapDetailFrame)
	WorldMapDetailFrame.bg:SetPoint("TOPLEFT", -10, 50)
	WorldMapDetailFrame.bg:SetPoint("BOTTOMRIGHT", 10, -10)
	WorldMapDetailFrame.bg:SetBackdrop({
		bgFile = caelMedia.files.bgFile,
		edgeFile = caelMedia.files.edgeFile, edgeSize = 4,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	WorldMapDetailFrame.bg:SetFrameStrata("BACKGROUND")
	WorldMapDetailFrame.bg:SetBackdropColor(0.15, 0.15, 0.15, 1)
	WorldMapDetailFrame.bg:SetBackdropBorderColor(0, 0, 0)

	WorldMapButton.cursor_coordinates = WorldMapButton:CreateFontString(nil, "ARTWORK")
	WorldMapButton.cursor_coordinates:SetPoint("BOTTOMLEFT", WorldMapButton, "BOTTOMLEFT", 5, 5)
	WorldMapButton.cursor_coordinates:SetFont(caelMedia.files.fontRg, 12)
	WorldMapButton.cursor_coordinates:SetTextColor(0.84, 0.75, 0.65)
	WorldMapButton.timer = 0.1

	WorldMapButton:HookScript("OnUpdate", function(self, elapsed)
		self.timer = self.timer - elapsed
		if self.timer > 0 then return end
		self.timer = 0.1

		local PlayerX, PlayerY = GetPlayerMapPosition("player")
		Player:SetFormattedText("Player X, Y • %.1f, %.1f", PlayerX * 100, PlayerY * 100)

		local CenterX, CenterY = WorldMapDetailFrame:GetCenter()
		local CursorX, CursorY = GetCursorPosition()
		CursorX = ((CursorX / WORLDMAP_QUESTLIST_SIZE) - (CenterX - (WorldMapDetailFrame:GetWidth() / 2))) / 10
		CursorY = (((CenterY + (WorldMapDetailFrame:GetHeight() / 2)) - (CursorY / WORLDMAP_QUESTLIST_SIZE)) / WorldMapDetailFrame:GetHeight()) * 100

		if CursorX >= 100 or CursorY >= 100 or CursorX <= 0 or CursorY <= 0 then
			Cursor:SetText("Cursor X, Y • |cffAF5050Out of bounds.|r")
		else
			Cursor:SetFormattedText("Cursor X, Y • %.1f, %.1f", CursorX, CursorY)
		end
	end)

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

caelMap.eventFrame:RegisterEvent("WORLD_MAP_UPDATE")
caelMap.eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
caelMap.eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
caelMap.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelMap.eventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
		for r = 1, 40 do
			if UnitInParty(_G["WorldMapRaid"..r].unit) then
				_G["WorldMapRaid"..r].icon:SetTexture([=[Interface\Addons\caelMedia\miscellaneous\partyicon]=])
			else
				_G["WorldMapRaid"..r].icon:SetTexture([=[Interface\Addons\caelMedia\miscellaneous\raidicon]=])
			end
			_G["WorldMapRaid"..r]:SetScript("OnUpdate", caelMap_OnUpdate)
		end

		for p = 1, 4 do
			_G["WorldMapParty"..p].icon:SetTexture([=[Interface\Addons\caelMedia\miscellaneous\partyicon]=])
			_G["WorldMapParty"..p]:SetScript("OnUpdate", caelMap_OnUpdate)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		setupMap(self)
		setupMap = nil
	end
end)