--[[	$Id$	]]

local _, caelStats = ...

caelStats.dps = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.dps:SetFontObject(neuropolrg10)
caelStats.dps:SetPoint("CENTER", caelPanel8, "CENTER", 125, 1)
caelStats.dps:SetText("|cffD7BEA5DPS|r 0")

caelStats.eventFrame = CreateFrame("Frame", nil, UIParent)
caelStats.eventFrame:SetAllPoints(caelStats.dps)
caelStats.eventFrame:EnableMouse(true)
caelStats.eventFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelStats.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
caelStats.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

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
		caelStats.dps:SetText("|cffD7BEA5DPS|r 0")
	else
		caelStats.dps:SetFormattedText("|cffD7BEA5DPS|r %.1f", dmgTotal / combTime)
	end
end

caelStats.eventFrame:HookScript("OnEvent", function(self, event, _, type, _, sourceName, _, _, destName, _, ...)
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

caelStats.eventFrame:HookScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	if dmgTotal then
		GameTooltip:AddDoubleLine("|cffD7BEA5Damage|r", dmgTotal)
		GameTooltip:AddDoubleLine("|cffD7BEA5Duration|r", formatTime(combTime))
	end
		GameTooltip:Show()
end)