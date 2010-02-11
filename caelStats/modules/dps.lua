local level = UnitLevel("player")
if level ~= 80 then return end

local Holder = CreateFrame("Frame")

caelStats.dps = caelPanel10:CreateFontString(nil, "OVERLAY")
caelStats.dps:SetFont(font, fontSize, fontOutline)
caelStats.dps:SetPoint("CENTER", caelPanel10, "CENTER", 225, 0.5)
caelStats.dps:SetText("|cffD7BEA5DPS|r 0")

local playerName = UnitName("player")
local petName = UnitName("pet")
local combStart, combTime, dmgTotal
local prefix, suffix
local GetTime = GetTime

local FormatTime = function(s)
	local minute = 60

	if s >= minute then
		return format('%dm %02ds', floor(s/60), s % minute)
	else
		return format("%.1fs", s)
	end
end

local OnEnter = function(self)
	if not InCombatLockdown() then
		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 5)

		if (dmgTotal) then
			GameTooltip:AddDoubleLine("|cffD7BEA5Damage|r", dmgTotal)
			GameTooltip:AddDoubleLine("|cffD7BEA5Duration|r", FormatTime(combTime))
		end
		GameTooltip:Show()
	end
end

local UpdateDPS = function()
	if (combTime == 0) then
		caelStats.dps:SetText("|cffD7BEA5DPS|r 0")
	else
		caelStats.dps:SetFormattedText("|cffD7BEA5DPS|r %.1f", dmgTotal / combTime)
	end
end

Holder:RegisterEvent("PLAYER_REGEN_ENABLED")
Holder.PLAYER_REGEN_ENABLED = function(self)
	Holder:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	combTime = (GetTime() - combStart)
	UpdateDPS()
end

Holder:RegisterEvent("PLAYER_REGEN_DISABLED")
Holder.PLAYER_REGEN_DISABLED = function(self)
	combStart = GetTime()
	combTime = 0
	dmgTotal = 0
	Holder:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Holder:COMBAT_LOG_EVENT_UNFILTERED(_, _, type, _, sourceName, _, _, destName, _, ...)
	if (sourceName == playerName or sourceName == petName) and destName ~= playerName then
		prefix, suffix = type:match("(.-)_(.+)")
		if (suffix == "DAMAGE" or suffix == "PERIODIC_DAMAGE" or suffix == "SHIELD") then
			dmgTotal = (dmgTotal + select(prefix == "SWING" and 1 or 4,...))
			combTime = (GetTime() - combStart)
			UpdateDPS()
		end
	end
end

Holder:EnableMouse(true)
Holder:SetAllPoints(caelStats.dps)
Holder:SetScript("OnEnter", OnEnter)
Holder:SetScript("OnEvent", OnEvent)