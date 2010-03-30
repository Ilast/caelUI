--[[	$Id$	]]

local _, caelDataFeeds = ...

caelDataFeeds.dps = caelDataFeeds.createModule("DPS")

local dps = caelDataFeeds.dps

dps.text:SetPoint("CENTER", caelPanel8, "CENTER", 125, 1)
dps.text:SetText("|cffD7BEA5DPS|r 0")

dps:RegisterEvent("PLAYER_REGEN_ENABLED")
dps:RegisterEvent("PLAYER_REGEN_DISABLED")

local playerName, petName = UnitName("player"), UnitName("pet")
local combStart, combTime, dmgTotal, prefix, suffix

local formatTime = function(s)
	local minute = 60

	if s >= minute then
		return format('%dm %02ds', floor(s/60), s % minute)
	else
		return format("%.1fs", s)
	end
end

local updateDps = function()
	if combTime == 0 then
		self.text:SetText("|cffD7BEA5DPS|r 0")
	else
		self.text:SetFormattedText("|cffD7BEA5DPS|r %.1f", dmgTotal / combTime)
	end
end

dps:SetScript("OnEvent", function(self, event, _, type, _, sourceName, _, _, destName, _, ...)
	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		combTime = (GetTime() - combStart)
		updateDps()
	elseif event == "PLAYER_REGEN_DISABLED" then
		combStart = GetTime()
		combTime = 0
		dmgTotal = 0
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if (sourceName == playerName or sourceName == petName) and destName ~= playerName then
			prefix, suffix = type:match("(.-)_(.+)")
			if (suffix == "DAMAGE" or suffix == "PERIODIC_DAMAGE" or suffix == "SHIELD") then
				dmgTotal = (dmgTotal + select(prefix == "SWING" and 1 or 4, ...))
				combTime = (GetTime() - combStart)
				updateDps()
			end
		end
	end
end)

dps:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	if dmgTotal then
		GameTooltip:AddDoubleLine("|cffD7BEA5Damage|r", dmgTotal)
		GameTooltip:AddDoubleLine("|cffD7BEA5Duration|r", formatTime(combTime))
	end
		GameTooltip:Show()
end)