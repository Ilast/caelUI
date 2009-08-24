local TEXT_FONT = [=[Interface\Addons\caelCooldowns\media\neuropol x cd rg.ttf]=]
local FONT_SIZE = 14
local MIN_SCALE = 0.5
local MIN_DURATION = 1.5
local R, G, B = 0.84, 0.75, 0.65

local format = string.format
local floor = math.floor
local min = math.min

local function GetFormattedTime(s)
	local day, hour, minute = 86400, 3600, 60

	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		if s <= minute * 5 then
			return format('%d:%02d', floor(s/60), s % minute), s - floor(s)
--			return format("%d.%d", mm, ss), s - floor(s)
		end
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
--		return floor(s + 0.5), s - floor(s)
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
--	return floor(s*10)/10, 0.02 -- s-floor(s*10)/20
end

local function Timer_OnUpdate(self, elapsed)
	if self.text:IsShown() then
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - elapsed
		else
			if (self:GetEffectiveScale()/UIParent:GetEffectiveScale()) < MIN_SCALE then
				self.text:SetText('')
				self.nextUpdate = 1
			else
				local remain = self.duration - (GetTime() - self.start)
				if floor(remain + 0.5) > 0 then
					local time, nextUpdate = GetFormattedTime(remain)
					self.text:SetText(time)
					self.nextUpdate = nextUpdate
				else
					self.text:Hide()
				end
			end
		end
	end
end

local function Timer_Create(self)
	local scale = min(self:GetParent():GetWidth() / 32, 1)
	if scale < MIN_SCALE then
		self.noOCC = true
	else
		local text = self:GetParent():CreateFontString(nil, "OVERLAY")
		text:SetPoint('CENTER', 0, 1)
		text:SetFont(TEXT_FONT, FONT_SIZE * scale, "OUTLINE")
		text:SetTextColor(R, G, B)
		
		self.text = text
		self:HookScript("OnHide", function(self) self.text:Hide() end)
		self:SetScript('OnUpdate', Timer_OnUpdate)
		return text
	end
end

local function Timer_Start(self, start, duration)
	self.start = start
	self.duration = duration
	self.nextUpdate = 0

	local text = self.text or (not self.noOCC and Timer_Create(self))
	if text then
		text:Show()
	end
end

local methods = getmetatable(ActionButton1Cooldown).__index
hooksecurefunc(methods, 'SetCooldown', function(self, start, duration)
	if self.ocd then return end
	if start > 0 and duration > MIN_DURATION then
		Timer_Start(self, start, duration)
	else
		local text = self.text
		if text then
			text:Hide()
		end
	end
end)

hooksecurefunc("CooldownFrame_SetTimer", function(frame, start, duration, enable)
      if (enable > 0 and duration <= 1.5) then
         frame:SetAlpha(0)
      else
         frame:SetAlpha(1)
      end
      
end)