--[[	$Id$	]]

local opt = recDamageMeterOptions
local raid = {}
local display_frame = CreateFrame("Frame", "recDamageMeter", UIParent)
local bit_band = bit.band
local table_sort = table.sort
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_sub = string.gsub
local tonumber = tonumber
local tostring = tostring
local UnitGUID = UnitGUID
local UnitName = UnitName
local GetNumRaidMembers = GetNumRaidMembers
local GetNumPartyMembers = GetNumPartyMembers
local need_reset = true
local player_name = caelLib.playerName
local whisper_name = player_name

local recycle_bin = {}
local function Recycler(trash_table)
	if trash_table then
		-- Recycle trash_table
		for k,v in pairs(trash_table) do
			if type(v) == "table" then
				Recycler(v)
			end
			trash_table[k] = nil
		end
		recycle_bin[(#recycle_bin or 0) + 1] = trash_table
	else
		-- Return recycled table, or new table if there are no used ones to give.
		if #recycle_bin and #recycle_bin > 0 then
			return table.remove(recycle_bin, 1)
		else
			return {}
		end
	end
end

-- Functions which sort the damage table.
local function sort_total(a,b) return (a.total or 0) > (b.total or 0) end
local function sort_fight(a,b) return (a.fight or 0) > (b.fight or 0) end
local function sort_dps(a,b) return (a.dps or 0) > (b.dps or 0) end
local function SortDamage()
	if #raid and #raid > 0 then
		if opt.mode == "Total" then
			table_sort(raid, sort_total)
		elseif opt.mode == "Fight" then
			table_sort(raid, sort_fight)
		elseif opt.mode == "DPS" then
			table_sort(raid, sort_dps)
		end
	end
end

local function PrettyNumber(number)
	-- If we have nothing to do, just return the number
	if number < 1000 then return number end
	output = string.gsub(number, "(%d)(%d%d%d)$", "%1,%2", 1)
	while true do
		output, found = string.gsub(output, "(%d)(%d%d%d)$", "%1,%2", 1)
		if found == 0 then
			break
		end
	end
	return output
end

-- Sets values on display bars.
local smooth_bars = Recycler()
local smooth_update = CreateFrame("Frame")
local function SmoothUpdate()
        local rate = GetFramerate()
        local limit = 30/rate
        for index, data in pairs(smooth_bars) do
                local cur = display_frame.bars[index]:GetValue()
                local new = cur + min((data.value-cur)/3, max(data.value-cur, limit))
                if new ~= new then
                        -- Mad hax to prevent QNAN.
                        new = data.value
                end
                display_frame.bars[index]:SetValue(new)
				display_frame.bars[index].lefttext:SetText(data.left or " ")
				local right
				if data.right and data.right ~= " " then right = PrettyNumber(data.right) else right = " " end
				display_frame.bars[index].righttext:SetText(right or " ")
                if cur == data.value or abs(new - data.value) < 2 then
                        display_frame.bars[index]:SetValue(data.value)
						display_frame.bars[index].lefttext:SetText(data.left or " ")
						display_frame.bars[index].righttext:SetText(right or " ")
						local temp = smooth_bars[index]
						smooth_bars[index] = nil
						Recycler(temp)
                end
        end
		if not smooth_bars or #smooth_bars == 0 then
			smooth_update:SetScript('OnUpdate', nil)
		end
end
local function SetBarValues(index, value, left, right)
	if value ~= display_frame.bars[index]:GetValue() or value == 0 then
		smooth_bars[index] = smooth_bars[index] or Recycler()
		smooth_bars[index].value = value or 0
		smooth_bars[index].left = left or " "
		smooth_bars[index].right = right or " "
		smooth_update:SetScript('OnUpdate', SmoothUpdate)
	else
        local temp = smooth_bars[index]
		smooth_bars[index] = nil
		Recycler(temp)
	end
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
			if opt.mode == "Total" then
				display_frame.bars[i]:SetMinMaxValues(0, tonumber(raid[1].total) or 1)
			elseif opt.mode == "Fight" then
				display_frame.bars[i]:SetMinMaxValues(0, tonumber(raid[1].fight) or 1)
			elseif opt.mode == "DPS" then
				display_frame.bars[i]:SetMinMaxValues(0, tonumber(raid[1].dps) or 1)
			end
		else
			display_frame.bars[i]:SetMinMaxValues(0, 1)
		end
		if raid[i] then
			if opt.mode == "Total" and raid[i].total and raid[i].total > 0 then
				SetBarValues(i, tonumber(raid[i].total), raid[i].name, raid[i].total)
			elseif opt.mode == "Fight" and raid[i].fight and raid[i].fight > 0 then
				SetBarValues(i, tonumber(raid[i].fight), raid[i].name, raid[i].fight)
			elseif opt.mode == "DPS" and raid[i].dps and raid[i].dps > 0 then
				SetBarValues(i, tonumber(raid[i].dps), raid[i].name, floor(tonumber(raid[i].dps)))
			else
				SetBarValues(i)
			end

			-- Color bar by class if we can obtain the info.
			local _, class = UnitClass(raid[i].name)
			if opt.bar_color_by_class and class then
				display_frame.bars[i]:SetStatusBarColor(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, opt.bar_color_a) -- by class
			else
				display_frame.bars[i]:SetStatusBarColor(opt.bar_color_r, opt.bar_color_g, opt.bar_color_b, opt.bar_color_a)
			end
		else
			SetBarValues(i)
		end
	end
end

local function TruncateBars(...)
	-- Truncate bars based on frame height.
	local bar_room = opt.display_height - (opt.button_height + (opt.display_padding * 2) + opt.bar_spacing)
	local room_needed = opt.bar_height + opt.bar_spacing

	for i=1,10 do
		if tonumber(tostring(bar_room)) >= tonumber(tostring(room_needed)) then
			recDamageMeter.bars[i]:Show()
			bar_room = bar_room - room_needed
		else
			recDamageMeter.bars[i]:Hide()
		end
	end
end

local button_font = CreateFont("RDM_ButtonFont")
button_font:SetFont(opt.button_font_face, opt.button_font_size, opt.button_font_flags)
button_font:SetTextColor(opt.button_font_color_r, opt.button_font_color_g, opt.button_font_color_b, opt.button_font_color_a)

local function MakeDisplay()
	local f = display_frame
	f.bars = Recycler()

	-- Creates a button
	local function MakeButton(caption, from_point, to_point, x_offset, y_offset)
		local b  = CreateFrame("Button", nil, display_frame)
		b:SetNormalFontObject(RDM_ButtonFont)
		b:SetHeight(opt.button_height)
		b:SetWidth(opt.button_width)
		b:SetHighlightTexture(opt.button_highlight_texture, opt.button_highlight_blend_mode)
		b:SetBackdrop({
			bgFile = opt.button_bg_texture,
			edgeFile = opt.button_edge_texture,
			edgeSize = opt.button_edge_size,
			insets = { left = opt.button_bg_inset, right = opt.button_bg_inset, top = opt.button_bg_inset, bottom = opt.button_bg_inset }
		})
		b:SetBackdropColor(opt.button_bg_color_r, opt.button_bg_color_g, opt.button_bg_color_b, opt.button_bg_color_a)
		b:SetText(caption)
		b:SetPoint(from_point, display_frame, to_point, x_offset, y_offset)
		return b
	end

	-- Creates a left or right text for a bar index
	local function MakeText(index, direction)
		local t = f.bars[index]:CreateFontString(nil, "ARTWORK")
		t:SetFont(opt.bar_font_face, opt.bar_font_size, opt.bar_font_flags)
		t:SetTextColor(opt.bar_font_color_r, opt.bar_font_color_g, opt.bar_font_color_b, opt.bar_font_color_a)
		t:SetPoint(direction, display_frame.bars[index], direction, opt.bar_font_x_offset, opt.bar_font_y_offset)
		return t
	end

	f:SetWidth(opt.display_width)
	f:SetHeight(opt.display_height)
	f:SetPoint("BOTTOM", UIParent, "BOTTOM", opt.display_x_offset, opt.display_y_offset)

	f.texture = f:CreateTexture()
	f.texture:SetAllPoints()
	f.texture:SetTexture(opt.display_bg_color_r, opt.display_bg_color_g, opt.display_bg_color_b, opt.display_bg_color_a)
	f.texture:SetDrawLayer("BACKGROUND")

	f.modetext = CreateFrame("Button", nil, display_frame)
	f.modetext:SetNormalFontObject(RDM_ButtonFont)
	f.modetext:SetHeight(opt.button_height)
	f.modetext:SetWidth(opt.mode_button_width)
	f.modetext:SetText(opt.mode)
	f.modetext:SetPoint("TOP", f, "TOP", opt.mode_button_x_offset, opt.mode_button_y_offset)
	f.modetext:SetScript("OnClick", function()
		opt.mode = opt.mode == "Total" and "Fight" or opt.mode == "Fight" and "DPS" or "Total"
		f.modetext:SetText(opt.mode)
		UpdateDisplay()
	end)

	f.reset = MakeButton("R", "TOPLEFT", "TOPLEFT", opt.display_padding, opt.display_padding * -1)
	f.reset:SetScript("OnClick", function()
		Recycler(raid)
		raid = Recycler()
		collectgarbage("collect")
		UpdateDisplay()
		print("recDamageMeter reset.")
	end)

	f.report = MakeButton("<", "TOPRIGHT", "TOPRIGHT", opt.display_padding * -1, opt.display_padding * -1)
	f.report:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	f.report:SetScript("OnClick", function(self, button)
		-- cCL style.
		local chatType = ChatFrameEditBox:GetAttribute("chatType")
		local tellTarget = ChatFrameEditBox:GetAttribute("tellTarget")
		local channelTarget = ChatFrameEditBox:GetAttribute("channelTarget")
		for i=1,10 do
			if not raid[i] then
				if i == 1 then
					SendChatMessage("No Data", chatType, GetDefaultLanguage("player"), tellTarget or channelTarget)
				end
				return
			end
					
			SendChatMessage(string.format(opt.report_format, i, raid[i].name, raid[i].total), chatType, GetDefaultLanguage("player"), tellTarget or channelTarget)
		end
	end)

	-- Add some bars!
	for i=1,10 do
		f.bars[i] = CreateFrame("StatusBar", nil, f)
		f.bars[i]:SetWidth(opt.display_width - (opt.display_padding * 2))
		f.bars[i]:SetHeight(opt.bar_height)
		f.bars[i]:SetMinMaxValues(0, 1)
		f.bars[i]:SetOrientation("HORIZONTAL")
		f.bars[i]:SetStatusBarColor(opt.bar_color_r, opt.bar_color_g, opt.bar_color_b, opt.bar_color_a)
		f.bars[i]:SetStatusBarTexture(opt.bar_texture)
		f.bars[i]:SetPoint("TOPLEFT", i == 1 and f or f.bars[i-1], i == 1 and "TOPLEFT" or "BOTTOMLEFT", i == 1 and opt.display_padding or 0, i == 1 and ((10 + opt.display_padding + opt.bar_spacing) * -1) or opt.bar_spacing * -1)
		f.bars[i]:SetPoint("TOPRIGHT", i == 1 and f or f.bars[i-1], i == 1 and "TOPRIGHT" or "BOTTOMRIGHT", i == 1 and opt.display_padding * -1 or 0, i == 1 and ((10 + opt.display_padding + opt.bar_spacing) * -1) or opt.bar_spacing * -1)
		f.bars[i].lefttext = MakeText(i, "LEFT")
		f.bars[i].righttext = MakeText(i, "RIGHT")
		SetBarValues(i)
	end

end

-- Thank you for all the help with this caching concept, Gotai!
local p, r, pp, rp = "party%d", "raid%d", "partypet%d", "raidpet%d"
local guid_cache = Recycler()
local function GetOwnerName(source_guid, pet_format, owner_format)

	if bit_band(source_guid:sub(1,5), 0x007) == 4 then
		source_guid = string_sub(source_guid, 6, 12)
	end

	local owner_name = guid_cache[source_guid]

	if not(owner_name) then

		local max_id = pet_format:find("raid") and GetNumRaidMembers() or GetNumPartyMembers()
		local unit

		for id=1, max_id do

			unit = pet_format:format(id)
			pet_guid = UnitGUID(unit)

			if pet_guid then

				pet_guid = string_sub(pet_guid, 6, 12)

				if not guid_cache[pet_guid] then

					owner = owner_format:format(id)
					guid_cache[pet_guid] = UnitName(owner)
					if source_guid == pet_guid then owner_name = guid_cache[pet_guid] end

				end
			end
		end
	end

	return owner_name
end

local function GetValidSourceName(source_guid, source_flags, source_name)

	if bit_band(source_flags, COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0 then
		if bit_band(source_flags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 then
			return player_name

		elseif bit_band(source_flags, COMBATLOG_OBJECT_AFFILIATION_RAID)~=0 then
			if bit_band(source_flags, COMBATLOG_OBJECT_TYPE_PET) ~= 0 then
				return GetOwnerName(source_guid, rp, r)
			else
				return source_name
			end

		elseif bit_band(source_flags, COMBATLOG_OBJECT_AFFILIATION_PARTY)~=0 then
			if bit_band(source_flags, COMBATLOG_OBJECT_TYPE_PET) ~= 0 then
				return GetOwnerName(source_guid, pp, p)
			else
				return source_name
			end
		end

	end
	return nil
end

local function ParseDamage(...)
	local _, cleu_event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags = ...

	-- Player hurt themselves, then don't consider the data
	if source_guid == dest_guid then return end

	-- Make sure the player is yourself, a raid/party member, or a pet belonging to yourself or a raid/party member.
	local source_name = GetValidSourceName(source_guid, source_flags, source_name)
	if not source_name then return end

	-- Remove pvp realm
	source_name = (string_find(source_name, "-", 1, true)) and string_gsub(source_name, "(.-)%-.*", "%1") or source_name

	-- Get the amount of damage done
	local amount, overkill = select(string_find(cleu_event, "SWING") and 9 or 12, ...)
	if overkill and amount then amount = amount - overkill end

	-- Return the name, and amount
	return source_name, amount
end

local function OnUpdate(self, elapsed)
	for k,v in pairs(raid) do
		v.dps_time = (v.dps_time or 0) + elapsed
		v.dps = v.fight / v.dps_time
	end
end

local function ZoneChange()
	local _, instanceType = IsInInstance()
	if instanceType == "party" or instanceType == "raid" then
		display_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		display_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
		display_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
		display_frame:Show()
	else
		display_frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		display_frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		display_frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
		display_frame:Hide()
	end
end

-- Wait a user-defined period before flagging as combat having ended.
-- This helps to compensate for feign death/vanish type abilities resetting fight data.
local ooc_timer_frame = CreateFrame("Frame")
local ooc_time = 0
local function OOCTimer(s,e)
	ooc_time = ooc_time + e
	if ooc_time >= opt.ooc_timeout then
		ooc_timer_frame:SetScript("OnUpdate", nil)
		display_frame:SetScript("OnUpdate", nil)
		ooc_time = 0
		need_reset = true
	end
end

local function OnEvent(s,e,...)

	-- These three events check if the user in in an instance/raid.  They are only registered if opt.dungeon_only == true
	if e == "PLAYER_ENTERING_WORLD" then
		ZoneChange()

	elseif e == "ZONE_CHANGED_NEW_AREA" or e == "WORLD_MAP_UPDATE" then
		local zone = GetRealZoneText()
		if e == "WORLD_MAP_UPDATE" and zone and zone ~= "" then
			display_frame:UnregisterEvent("WORLD_MAP_UPDATE")
		end
		ZoneChange()

	-- Combat ended, wait for ooc_timeout
	elseif e == "PLAYER_REGEN_ENABLED" then
		ooc_timer_frame:SetScript("OnUpdate", OOCTimer)

	-- Combat begun, reset fight data
	elseif e == "PLAYER_REGEN_DISABLED" then
		ooc_timer_frame:SetScript("OnUpdate", nil)
		if need_reset then
			for index,info in ipairs(raid) do
				info.fight = 0
				info.dps = 0
				info.dps_time = 0
			end
			need_reset = false
		end
		display_frame:SetScript("OnUpdate", OnUpdate)
		UpdateDisplay()

	elseif e == "RAID_ROSTER_UPDATE" then
		if not(UnitInRaid("player")) then
			Recycler(guid_cache)
			guid_cache = Recycler()
		end

	else

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
				raid[member_index] = Recycler()
				raid[member_index].name = member_name
			end

			-- Add in their new damage.
			raid[member_index].total = (raid[member_index].total or 0) + damage
			if not need_reset then -- Only add fight/dps data if we are in combat.
				raid[member_index].fight = (raid[member_index].fight or 0) + damage
			end

			UpdateDisplay()
		end
	end
end

MakeDisplay()
TruncateBars() -- In case the user changed the size of the main frame in the options.

display_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
display_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
display_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
display_frame:RegisterEvent("RAID_ROSTER_UPDATE")
if opt.dungeon_only then
	display_frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	display_frame:RegisterEvent("WORLD_MAP_UPDATE")
	display_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
end
display_frame:SetScript("OnEvent", OnEvent)

SLASH_RECDAMAGEMETERTARGET1 = '/rdmtarget'
SlashCmdList.RECDAMAGEMETERTARGET = function(name)
	if not name then return end
	whisper_name = name
end