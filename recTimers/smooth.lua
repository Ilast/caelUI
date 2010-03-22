local _, recTimers = ...

-- Stores bars which are being smoothed.
local smoothBars = {}

local function Smooth(self, value)
	if value ~= self:GetValue() or value == 0 then
		smoothBars[self] = value
	else
		smoothBars[self] = nil
	end
end

-- Smoothes on update.
local min, max = math.min, math.max
local smoothFrame = CreateFrame("Frame")
smoothFrame:SetScript("OnUpdate", function()
	local rate = GetFramerate()
	local limit = 30/rate
	for bar, value in pairs(smoothBars) do
		local cur = bar:GetValue()
		local new = cur + min((value-cur)/3, max(value-cur, limit))
		if new ~= new then
			-- Mad hax to prevent QNAN.
			new = value
		end
		bar:SetValue_(new)
		if cur == value or abs(new - value) < 2 then
			bar:SetValue_(value)
			smoothBars[bar] = nil
		end
	end
end)

-- Insert bar into here to enable smoothing.
recTimers.SmoothBar = function(bar)
	bar.SetValue_ = bar.SetValue
	bar.SetValue = Smooth
end