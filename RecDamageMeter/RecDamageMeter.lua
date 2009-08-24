--$Revision: 324 $
--$Date: 2009-08-12 18:25:37 -0500 (Wed, 12 Aug 2009) $

-- Stuff you might be interested in changing:
local display_width = 161		-- Width of the main frame.
local display_height = 125		-- Height of the main frame.
local display_padding = 2		-- Padding between bar/button edge and frame edge.
local bar_height = 9.4			-- Height of each bar.
local bar_spacing = 1.5			-- Distance between each bar.
local font_face = [=[Interface\Addons\RecDamageMeter\media\neuropol x cd rg.ttf]=]	-- Font face.
local font_size = 9			-- Font size
local font_flags = nil			-- "OUTLINE" and such.
local background_alpha = 0		-- Alpha of the main frame's background.
local display_x_offset = -555	-- Relative to BOTTOM UIParent BOTTOM.
local display_y_offset = 5		-- Relative to BOTTOM UIParent BOTTOM.
	-- Texture of the bars:
local bar_texture = [=[Interface\Addons\RecDamageMeter\media\normTex]=]
local mode = "Fight"			-- Default display mode: "Total" or "Fight"

---------------------------------------------

local raid = {}
local display_frame = CreateFrame("Frame", "RecDamageMeter", UIParent)
local bit_band = bit.band
local table_sort = table.sort
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local math_floor = math.floor
local tonumber = tonumber
local UnitGUID = UnitGUID
local UnitName = UnitName
local GetNumRaidMembers = GetNumRaidMembers
local GetNumPartyMembers = GetNumPartyMembers
local need_reset = true

-- Functions which sort the damage table.
local function sort_total(a,b) return (a.total or 0) > (b.total or 0) end
local function sort_fight(a,b) return (a.fight or 0) > (b.fight or 0) end
local function SortDamage()
	if #raid and #raid > 0 then
		if mode == "Total" then
			table_sort(raid, sort_total)
		else
			table_sort(raid, sort_fight)
		end
	end
end

local function SetBarValues(index, value, left, right)
	-- Simply leave out value, left and/or right to reset the value(s) to a zeroed state.
	display_frame.bars[index]:SetValue(value or 0)
	display_frame.bars[index].lefttext:SetText(left or " ")
	display_frame.bars[index].righttext:SetText(right or " ")
end

local function UpdateDisplay()
	-- Sort members by damage
	SortDamage()

	-- If we have no data, then, zero out everything.
	if not #raid or #raid < 1 then
		for i=1,10 do
			display_frame.bars[i]:SetMinMaxValues(0, 1)
			SetBarValues(i)
		end
		return
	end

	-- Update our bars with damage done.
	for i=1,10 do
		if raid[1] then
			if mode == "Total" then
				display_frame.bars[i]:SetMinMaxValues(0, tonumber(raid[1].total) or 1)
			else
				display_frame.bars[i]:SetMinMaxValues(0, tonumber(raid[1].fight) or 1)
			end
		else
			display_frame.bars[i]:SetMinMaxValues(0, 1)
		end
		if raid[i] then
			if mode == "Total" and raid[i].total and raid[i].total > 0 then
				SetBarValues(i, tonumber(raid[i].total), raid[i].name, raid[i].total)
			elseif raid[i].fight and raid[i].fight > 0 then
				SetBarValues(i, tonumber(raid[i].fight), raid[i].name, raid[i].fight)
			else
				SetBarValues(i)
			end

			-- Color bar by class if we can obtain the info.
			local _, class = UnitClass(raid[i].name)
			if class then
				display_frame.bars[i]:SetStatusBarColor(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, 0.8) -- by class
			else
				display_frame.bars[i]:SetStatusBarColor(1, 1, 1, 0.8)
			end
		else
			SetBarValues(i)
		end
	end
end

local function TruncateBars(...)
	-- Truncate bars based on frame height.
	local bar_room = math_floor((RecDamageMeter:GetHeight()-30.5)/bar_height)
	for i=1,10 do
		RecDamageMeter.bars[i]:Hide()
	end
	if bar_room > 0 then
		for i=1,bar_room do
			RecDamageMeter.bars[i]:Show()
		end
	end
end

local function MakeDisplay()
	local f = display_frame
	f.bars = {}

	-- Creates a button
	local function MakeButton(caption, from_point, to_point, x_offset, y_offset)
		local b  = CreateFrame("Button", nil, display_frame)
		b:SetNormalFontObject(GameFontHighlightSmall)
		b:SetHeight(10)
		b:SetWidth(40)
		b:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight", "ADD")
		b:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
		b:SetBackdropColor(.3, .3, .3, .9)
		b:SetText(caption)
		b:SetPoint(from_point, display_frame, to_point, x_offset, y_offset)
		return b
	end

	-- Creates a left or right text for a bar index
	local function MakeText(index, direction)
		local t = f.bars[index]:CreateFontString(nil, "ARTWORK")
		t:SetFont(font_face, font_size, font_flags)
		t:SetPoint(direction, display_frame.bars[index], direction, 0, 2)
		return t
	end

	f:SetWidth(display_width)
	f:SetHeight(display_height)
	f:SetPoint("BOTTOM", UIParent, "BOTTOM", display_x_offset, display_y_offset)

	f.texture = f:CreateTexture()
	f.texture:SetAllPoints()
	f.texture:SetTexture(0,0,0,background_alpha)
	f.texture:SetDrawLayer("BACKGROUND")

	f.modetext = f:CreateFontString(nil, "ARTWORK")
	f.modetext:SetFont(font_face, font_size, font_flags)
	f.modetext:SetText(mode)
	f.modetext:SetPoint("TOP", f, "TOP", 0, 0)

	f.reset = MakeButton("Reset", "TOPLEFT", "TOPLEFT", display_padding, display_padding * -1)
	f.reset:SetScript("OnClick", function()
		raid = {}
		collectgarbage("collect")
		UpdateDisplay()
		print("RecDamageMeter reset.")
	end)

	f.mode = MakeButton("Mode", "TOPRIGHT", "TOPRIGHT", display_padding * -1, display_padding * -1)
	f.mode:SetScript("OnClick", function()
		mode = mode == "Total" and "Fight" or "Total"
		f.modetext:SetText(mode)
		UpdateDisplay()
	end)

	-- Add some bars!
	for i=1,10 do
		f.bars[i] = CreateFrame("StatusBar", nil, f)
		f.bars[i]:SetWidth(display_width - display_padding)
		f.bars[i]:SetHeight(bar_height)
		f.bars[i]:SetMinMaxValues(0, 1)
		f.bars[i]:SetOrientation("HORIZONTAL")
		f.bars[i]:SetStatusBarColor(1, 1, 1, 0.8)
		f.bars[i]:SetStatusBarTexture(bar_texture)
		f.bars[i]:SetPoint("TOPLEFT", i == 1 and f or f.bars[i-1], i == 1 and "TOPLEFT" or "BOTTOMLEFT", i == 1 and display_padding or 0, i == 1 and -15 or bar_spacing * -1)
		f.bars[i]:SetPoint("TOPRIGHT", i == 1 and f or f.bars[i-1], i == 1 and "TOPRIGHT" or "BOTTOMRIGHT", i == 1 and display_padding * -1 or 0, i == 1 and -15 or bar_spacing * -1)
		f.bars[i].lefttext = MakeText(i, "LEFT")
		f.bars[i].righttext = MakeText(i, "RIGHT")
		SetBarValues(i)
	end

	display_frame:HookScript("OnSizeChanged", TruncateBars)
end

-- Generate premade id tables for unitid lookups
local ids = { p = {}, r = {}, pp = {}, rp = {} }
for i = 1, 4 do ids.p[i] = string_format("party%d", i); ids.pp[i] = string_format("partypet%d", i) end
for i = 1, 40 do ids.r[i] = string_format("raid%d", i); ids.rp[i] = string_format("raidpet%d", i) end
local function GetUnitValidity(source_guid, source_flags)

	if bit_band(source_flags, COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0 then
		if bit_band(COMBATLOG_OBJECT_AFFILIATION_MINE)~=0 then
			if source_guid == UnitGUID("player") or source_guid == UnitGUID("pet") then
				return true, UnitName("player")
			end
		end
		if bit_band(source_flags, COMBATLOG_OBJECT_AFFILIATION_RAID)~=0 then
			local num = GetNumRaidMembers()
			if num > 0 then
				for i = 1, num do
					if source_guid == UnitGUID(ids.r[i]) or source_guid == UnitGUID(ids.rp[i]) then
						return true, UnitName(ids.r[i])
					end
				end
			end
		elseif bit_band(source_flags, COMBATLOG_OBJECT_AFFILIATION_PARTY)~=0 then
		local num = GetNumPartyMembers()
				if num > 0 then
				for i = 1, num do
					if source_guid == UnitGUID(ids.p[i]) or source_guid == UnitGUID(ids.pp[i]) then
						return true, UnitName(ids.p[i])
					end
				end
			end
		end
	end
	return false, nil
end

local function ParseDamage(...)
	local _, cleu_event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags = ...

	-- If player hurt themselves, then don't consider the data
	if source_guid == dest_guid then return end

	-- Make sure the player is yourself, a raid/party member, or a pet belonging to yourself or a raid/party member.
	local valid_player, owner_name = GetUnitValidity(source_guid, source_flags)
	if not valid_player then return end

	-- Merge pet with owner, if this is a pet
	if owner_name then
		source_name = owner_name
	end

	-- Remove pvp realm
	source_name = (string_find(source_name, "-", 1, true)) and string_gsub(source_name, "(.-)%-.*", "%1") or source_name

	-- Get the amount of damage done
	local amount, overkill = select(string_find(cleu_event, "SWING") and 9 or 12, ...)
	if overkill and amount then amount = amount - overkill end

	-- Return the name, and amount
	return source_name, amount
end

display_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
display_frame.PLAYER_REGEN_ENABLED = function(self)
	-- Combat ended, flag for fight to be reset
		--TODO: Fake combat end handling.
		--if UnitBuff("player", "Feign Death") or UnitBuff("player", "Vanish") or UnitBuff("player", "Invisibility") then
			--need_reset = false
		--else
			need_reset = true
		--end
		return
end

display_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
display_frame.PLAYER_REGEN_DISABLED = function(self)
	-- Combat begun, reset fight data
		if need_reset then
			for index,info in ipairs(raid) do
				info.fight = 0
			end
			need_reset = false
		end
		UpdateDisplay()
		return
end

display_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
display_frame.COMBAT_LOG_EVENT_UNFILTERED = function(self, event, ...)
	-- Do combat event
	local _, cleu_type = ...

	if string_find(cleu_type, "DAMAGE") and not string_find(cleu_type, "MISS") then

		-- Get sources and damage done
		local member_name, damage = ParseDamage(...)
		if not member_name or not damage then return end -- Sanity check

		-- Get a pointer to the member's raid table location
		local member_index
		for index, info in ipairs(raid) do
			if info.name == member_name then member_index = index end
		end

		-- Add member to raid table if needed
		if not member_index then
			member_index = (#raid or 0) + 1
			raid[member_index] = {}
			raid[member_index].name = member_name
		end

		-- Add in their new damage.
		raid[member_index].total = (raid[member_index].total or 0) + damage
		if not need_reset then -- Only add fight data if we are in combat.
			raid[member_index].fight = (raid[member_index].fight or 0) + damage
		end

		UpdateDisplay()
	end
end

MakeDisplay()
TruncateBars() -- In case the user changed the size of the main frame at the top of this file.

local ZoneChange = function(self, zone)
	local _, instanceType = IsInInstance()
	if instanceType == "party" or instanceType == "raid" then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:Show()
	else
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:Hide()
	end
end

display_frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
display_frame.ZONE_CHANGED_NEW_AREA = function(self)
	local zone = GetRealZoneText()
	return ZoneChange(self, zone)
end

display_frame:RegisterEvent("WORLD_MAP_UPDATE")
display_frame.WORLD_MAP_UPDATE = function(self)
	local zone = GetRealZoneText()
	if zone and zone ~= "" then
		self:UnregisterEvent("WORLD_MAP_UPDATE")
		return ZoneChange(self, zone)
	end
end

display_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
display_frame.PLAYER_ENTERING_WORLD = function(self)
	return ZoneChange(self, zone)
end

function OnEvent(self, event, ...)
	if type(self[event]) == 'function' then
		return self[event](self, event, ...)
	else
		print("Unhandled event: "..event)
	end
end

display_frame:SetScript("OnEvent", OnEvent)

--[[
local ZoneChange = function(self)
	local zone = GetRealZoneText()

	if zone and zone ~= "" then
		self:UnregisterEvent("WORLD_MAP_UPDATE")
	end

	local _, instanceType = IsInInstance()
	if instanceType == "party" or instanceType == "raid" then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:Show()
	else
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:Hide()
	end
end

display_frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
display_frame.ZONE_CHANGED_NEW_AREA = function(self) ZoneChange(self) end

display_frame:RegisterEvent("WORLD_MAP_UPDATE")
display_frame.WORLD_MAP_UPDATE = function(self) ZoneChange(self) end

display_frame:RegisterEvent("PLAYER_ENTRING_WORLD")
display_frame.PLAYER_ENTERING_WORLD = function(self) ZoneChange(self) end
--]]