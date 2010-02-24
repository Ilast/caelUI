-- $Id$
local _, recClassTimers = ...
local event_frame = CreateFrame("Frame")
local floor = math.floor
local mod = mod
local format = string.format
local pairs = pairs
local UnitBuff, UnitDebuff = UnitBuff, UnitDebuff

local bars = {}

local function pretty_time(seconds)
	local hours		= floor(seconds / 3600)
	hours = (hours > 0) and format("%d:", hours) or ""
	local minutes	= floor(mod(seconds / 60, 60))
	minutes = ((minutes > 0) and (hours ~= "")) and format("%02d:", minutes) or format("%d:", minutes) or ""
	seconds	= floor(mod(seconds / 1, 60))
	seconds = ((seconds > 0) and (minutes ~= "")) and format("%02d", seconds) or format("%d", seconds)
	return format("%s%s%s", hours, minutes, seconds)
end

local function on_update(self, elapsed)
	self.timer = self.timer - elapsed
	
	if self.timer > 0 then return end
	self.timer = 0.01
	
	if self.active then
		if self.expires >= GetTime() then
			self:SetValue(self.expires - GetTime())
			self:SetMinMaxValues(0, self.duration)
			self.lbl:SetText(format("%s%s - %s", self.spell_name, self.count > 1 and format("(%d)", self.count) or "", pretty_time(self.expires - GetTime())))
		else
			self.active = false
		end
	end
	
	if not self.active then
		self:Hide()
	end
end

recClassTimers.make_bar = function(self, spell_name, unit, buff_type, only_self, r, g, b, width, height, attach_point, parent_frame, relative_point, x_offset, y_offset)
	local new_id = (#bars or 0) + 1
	bars[new_id] = CreateFrame("StatusBar", format("recClassTimers_Bar_%d", new_id), parent_frame)
	bars[new_id]:SetHeight(height)
	bars[new_id]:SetWidth(width)
	bars[new_id].spell_name = spell_name
	bars[new_id].unit = unit
	bars[new_id].buff_type = buff_type
	bars[new_id].only_self = only_self
	bars[new_id].count = 0
	bars[new_id].active = false
	bars[new_id].timeless = timeless
	bars[new_id].expires = 0
	bars[new_id].duration = 0
	bars[new_id].timer = 0
	
	bars[new_id].tx = bars[new_id]:CreateTexture(nil, "ARTWORK")
	bars[new_id].tx:SetAllPoints()
	bars[new_id].tx:SetTexture([=[Interface\AddOns\caelMedia\StatusBars\normtexa.tga]=])
	bars[new_id].tx:SetVertexColor(r, g, b, 1)
	bars[new_id]:SetStatusBarTexture(bars[new_id].tx)

	bars[new_id].soft_edge = CreateFrame("Frame", nil, bars[new_id])
	bars[new_id].soft_edge:SetPoint("TOPLEFT", -4, 3.5)
	bars[new_id].soft_edge:SetPoint("BOTTOMRIGHT", 4, -4)
	bars[new_id].soft_edge:SetBackdrop({
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		edgeFile = [=[Interface\Addons\caelMedia\Miscellaneous\glowtex]=], edgeSize = 4,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	bars[new_id].soft_edge:SetFrameStrata("BACKGROUND")
	bars[new_id].soft_edge:SetBackdropColor(0.25, 0.25, 0.25, 1)
	bars[new_id].soft_edge:SetBackdropBorderColor(0, 0, 0)

	bars[new_id].bg = bars[new_id]:CreateTexture(nil, "BORDER")
	bars[new_id].bg:SetPoint("TOPLEFT")
	bars[new_id].bg:SetPoint("BOTTOMRIGHT")
	bars[new_id].bg:SetTexture([=[Interface\AddOns\caelMedia\StatusBars\normtexa.tga]=])
	bars[new_id].bg:SetVertexColor(0.25, 0.25, 0.25, 1)
--[[
	bars[new_id].border = bars[new_id]:CreateTexture(nil, "BACKGROUND")
	bars[new_id].border:SetPoint("TOPLEFT", -2.5, 2.5)
	bars[new_id].border:SetPoint("BOTTOMRIGHT", 2.5, -2.5)
	bars[new_id].border:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	bars[new_id].border:SetVertexColor(0.25, 0.25, 0.25, 1)
--]]
	bars[new_id].icon = bars[new_id]:CreateTexture(nil, "BORDER")
	bars[new_id].icon:SetHeight(height)
	bars[new_id].icon:SetWidth(height)
	bars[new_id].icon:SetPoint("TOPRIGHT", bars[new_id], "TOPLEFT", 0, 0)
	bars[new_id].icon:SetTexture(nil)
	
	bars[new_id].lbl = bars[new_id]:CreateFontString(format("recClassTimers_BarLabel_%d", new_id), "OVERLAY")
	bars[new_id].lbl:SetFontObject(neuropolrg9)
	bars[new_id].lbl:SetPoint("CENTER", bars[new_id], "CENTER", 0, 1)
	
	bars[new_id]:SetPoint(attach_point, parent_frame, relative_point, x_offset, y_offset)
	
	bars[new_id]:Hide()
end

local function check_buffs()
	for _, bar in pairs(bars) do
		local icon, count, duration, expiration, caster
		
		if bar.buff_type == "buff" then
			_, _, icon, count, _, duration, expiration, caster = UnitBuff(bar.unit, bar.spell_name)
		else
			_, _, icon, count, _, duration, expiration, caster = UnitDebuff(bar.unit, bar.spell_name)
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
	end
end)