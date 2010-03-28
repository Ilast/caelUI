--[[	$Id$	]]

local _, t = ...
local event_frame = CreateFrame("Frame")
local floor = math.floor
local mod = mod
local format = string.format
local pairs = pairs
local UnitBuff, UnitDebuff = UnitBuff, UnitDebuff
local font_face    = [=[Interface\AddOns\caelMedia\fonts\neuropol x cd rg.ttf]=]
local font_size    = 8
local font_outline = ""
local texture      = [=[Interface\AddOns\caelMedia\statusbars\normtexa.tga]=]
local edge_file    = [=[Interface\AddOns\caelMedia\borders\glowtex.tga]=]
local bg_file      = [=[Interface\ChatFrame\ChatFrameBackground]=]
--[[
local aura_colors  = {
	["Magic"]   = {r = 0.00, g = 0.25, b = 0.45}, 
	["Disease"] = {r = 0.40, g = 0.30, b = 0.10}, 
	["Poison"]  = {r = 0.00, g = 0.40, b = 0.10}, 
	["Curse"]   = {r = 0.40, g = 0.00, b = 0.40},
	["None"]    = {r = 0.69, g = 0.31, b = 0.31}
}
--]]
local bars = {}

local function pretty_time(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		if s <= minute * 5 then
			return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
		end
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
end

local function on_update(self, elapsed)
	self.timer = self.timer - elapsed
	
	if self.timer > 0 then return end
	self.timer = 0.1
	
	if self.active then
		if self.expires >= GetTime() then
			self:SetValue(self.expires - GetTime())
			self:SetMinMaxValues(0, self.duration)
			if not self.hide_name then
				self.lbl:SetText(format("%s%s - %s", self.spell_name, self.count > 1 and format(" x%d", self.count) or "", pretty_time(self.expires - GetTime())))
			else
				self.lbl:SetText(format("%s", pretty_time(self.expires - GetTime())))
			end
		else
			self.active = false
		end
	end
	
	if not self.active then
		self:Hide()
	end
end

-- Function to position bar based on talent spec.
local function position_bar(bar)
	local spec = GetActiveTalentGroup()
	bar:ClearAllPoints()
	bar:SetPoint(bar.position[spec].attach_point, bar.position[spec].parent_frame, bar.position[spec].relative_point, bar.position[spec].x_offset, bar.position[spec].y_offset)
end

t.make_bar = function(self, spell_name, unit, buff_type, only_self, r, g, b, width, height, attach_point1, parent_frame1, relative_point1, x_offset1, y_offset1, attach_point2, parent_frame2, relative_point2, x_offset2, y_offset2, hide_name)
	local new_id = (#bars or 0) + 1
	bars[new_id] = CreateFrame("StatusBar", format("recTimers_Bar_%d", new_id), parent_frame)
	t.SmoothBar(bars[new_id])
	bars[new_id]:SetHeight(height)
	bars[new_id]:SetWidth(width)
	bars[new_id].spell_name = spell_name
	bars[new_id].unit = unit
	bars[new_id].buff_type = buff_type
	bars[new_id].only_self = only_self
	bars[new_id].hide_name = hide_name
	bars[new_id].count     = 0
	bars[new_id].active    = false
	bars[new_id].expires   = 0
	bars[new_id].duration  = 0
	bars[new_id].timer     = 0
	
	-- Store values for each talent spec position.
	bars[new_id].position = {
		-- Talent spec 1 references
		[1] = {
			attach_point   = attach_point1,
			parent_frame   = parent_frame1,
			relative_point = relative_point1,
			x_offset       = x_offset1,
			y_offset       = y_offset1
		},
		-- Talent spec 2 references - default to spec 1 values if user did not provide them.
		[2] = {
			attach_point   = attach_point2   or attach_point1,
			parent_frame   = parent_frame2   or parent_frame1,
			relative_point = relative_point2 or relative_point1,
			x_offset       = x_offset2       or x_offset1,
			y_offset       = y_offset2       or y_offset1
		}
	}
	
	bars[new_id].tx = bars[new_id]:CreateTexture(nil, "ARTWORK")
	bars[new_id].tx:SetAllPoints()
	bars[new_id].tx:SetTexture(texture)
	-- Color bar with user values unless they enter nil values.  If so, then we color bar based on aura type
	if r and g and b then
		bars[new_id].tx:SetVertexColor(r, g, b, 1)
	else
		bars[new_id].auto_color = true
	end
	bars[new_id]:SetStatusBarTexture(bars[new_id].tx)

	bars[new_id].soft_edge = CreateFrame("Frame", nil, bars[new_id])
	bars[new_id].soft_edge:SetPoint("TOPLEFT", -3.5, 3.5)
	bars[new_id].soft_edge:SetPoint("BOTTOMRIGHT", 3.5, -3.5)
	bars[new_id].soft_edge:SetBackdrop({
		bgFile = bg_file,
		edgeFile = edge_file, edgeSize = 3,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	bars[new_id].soft_edge:SetFrameStrata("BACKGROUND")
	bars[new_id].soft_edge:SetBackdropColor(0.25, 0.25, 0.25)
	bars[new_id].soft_edge:SetBackdropBorderColor(0, 0, 0)

	bars[new_id].bg = bars[new_id]:CreateTexture(nil, "BORDER")
	bars[new_id].bg:SetPoint("TOPLEFT")
	bars[new_id].bg:SetPoint("BOTTOMRIGHT")
	bars[new_id].bg:SetTexture(texture)
	bars[new_id].bg:SetVertexColor(0.25, 0.25, 0.25, 1)

	bars[new_id].icon = bars[new_id]:CreateTexture(nil, "BORDER")
	bars[new_id].icon:SetHeight(height)
	bars[new_id].icon:SetWidth(height)
	bars[new_id].icon:SetPoint("TOPRIGHT", bars[new_id], "TOPLEFT", 0, 0)
	bars[new_id].icon:SetTexture(nil)
	
	bars[new_id].lbl = bars[new_id]:CreateFontString(format("recTimers_BarLabel_%d", new_id), "OVERLAY")
	bars[new_id].lbl:SetFont(font_face, font_size, font_outline)
	bars[new_id].lbl:SetPoint("CENTER", bars[new_id], "CENTER", 0, 1)
	
	position_bar(bars[new_id])
	
	bars[new_id]:Hide()
end

local function check_buffs()
	for _, bar in pairs(bars) do
		local icon, count, duration, expiration, caster
		
		if bar.buff_type == "buff" then
			_, _, icon, count, aura_type, duration, expiration, caster = UnitBuff(bar.unit, bar.spell_name)
		else
			_, _, icon, count, aura_type, duration, expiration, caster = UnitDebuff(bar.unit, bar.spell_name)
		end
		
		if icon and (not(bar.only_self) or (bar.only_self and (caster == "player"))) then
			--bar.icon:SetTexture(icon)
			bar.count = count
			bar.active = true
			bar.expires = expiration
			bar.duration = duration
			
			if duration and duration > 0 then
				bar:SetScript("OnUpdate", on_update)
			else
				bar:SetScript("OnUpdate", nil)
				bar.lbl:SetText(format("%s%s", bar.spell_name, bar.count > 1 and format("(%d)", bar.count) or ""))
			end
			
			-- If we need to color the bar automatically, do so.
			if bar.auto_color then
--				bar.tx:SetVertexColor(aura_colors[aura_type or "None"].r, aura_colors[aura_type or "None"].g, aura_colors[aura_type or "None"].b, 1)
				bar.tx:SetVertexColor(DebuffTypeColor[aura_type or "none"].r, DebuffTypeColor[aura_type or "none"].g, DebuffTypeColor[aura_type or "none"].b, 1)
			end
			
			bar:Show()
		end
	end
end

local function on_cleu(...)
	local _, event, source_guid, _, _, dest_guid, _, _, spell_id, spell_name, _, _ = ...
	if spell_name then
	
			if event == "SPELL_AURA_REMOVED" then
				for _, bar in pairs(bars) do
					if dest_guid == UnitGUID(bar.unit) and spell_name == bar.spell_name then
						if not(bar.only_self) or (bar.only_self and (source_guid == UnitGUID("player"))) then
							bar.count = 0
							bar.active = false
							bar.expires = 0
							bar:Hide()
						end
					end
				end
			end
		
		return check_buffs()
	end
end

event_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
event_frame:RegisterEvent("PLAYER_TALENT_UPDATE")
event_frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		for _, bar in pairs(bars) do
			if bar.unit == "target" then
				bar:Hide()
			end
		end
		check_buffs()
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		on_cleu(...)
	elseif event == "PLAYER_ENTERING_WORLD" then
		check_buffs()
	elseif event == "PLAYER_TALENT_UPDATE" then
		for index, _ in pairs(bars) do
			position_bar(bars[index])
		end
	end
end)