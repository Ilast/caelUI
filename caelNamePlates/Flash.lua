local _, addon = ...
addon.flash = {}

local min, max = min, max
local fader = CreateFrame"Frame"

fader.interval = 1/24
fader.frames = {}
fader:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > self.interval then
		for i=#self.frames, 1, -1 do
			local frame = self.frames[i]
			local info = frame.FlashData
			info.elapsed = info.elapsed and (info.elapsed + self.elapsed) or 0
			
			
			if info.elapsed < info.duration then
				-- Transition phase
				local fract = info.dir > 0 and 1-(info.elapsed/info.duration) or (info.elapsed/info.duration)
				local new = info.high - fract * info.delta
				frame:SetAlpha(new)
			else
				-- Finalize transition phase and switch direction.
				frame:SetAlpha(info.high + info.dir * info.delta)
				
				if info.stop and info.dir == 1 then
					info.elapsed = 0
					table.remove(self.frames, i)
				else
					info.elapsed = 0
					info.dir = info.dir * -1
				end
			end
			
			local cur = info.cur
			
		end
		self.elapsed = 0
	end
end)

function addon.flash.Start(frame, duration, low, high)
	if not tContains(fader.frames, frame) then
		local t = frame.FlashData or {}
		t.duration = duration
		t.low = low
		t.high = high or self:GetAlpha()
		t.delta = high - low
		t.dir = -1
		t.stop = false
		
		frame.FlashData = t
		fader.frames[#fader.frames + 1] = frame
	end
end

function addon.flash.Stop(frame)
	if frame.FlashData then
		frame.FlashData.stop = true
	end
end