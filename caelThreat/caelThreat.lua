--[[	$Id$	]]

local _, caelThreat = ...

local lastWarning
local abs = math.abs
local class = caelLib.playerClass

caelThreat.eventFrame = CreateFrame("Frame", nil, self)

local warningSounds = true

local isTankClassSpec = {
	["PALADIN"] = {
		GetSpellInfo(25780), -- Righteous Fury
		(GetSpellInfo(465)), -- Devotion Aura
	},
	["WARRIOR"] = GetSpellInfo(71), -- Defensive Stance
	["DRUID"] = {
		GetSpellInfo(5487), -- Bear Form
		(GetSpellInfo(9634)), -- Dire Bear Form
	},
}

local function IsTankCheck(unit, spells)
	local status = false
	if type(spells) == "table" then
		status = true
		for i = 1, #spells do
			if not UnitAura(unit, spells[i]) then
				status = false
			end
		end
	elseif spells then
		if UnitAura(unit, spells) then
			status = true
		end
	end
	
	return status
end

local aggroColors = {
	[true] = {
		[1] = {1, 0.6, 0},
		[2] = {1, 1, 0.47},
		[3] = {0.33, 0.59, 0.33},
	},
	[false] = {
		[1] = {1, 1, 0.47},
		[2] = {1, 0.6, 0},
		[3] = {0.69, 0.31, 0.31},
	}
}

caelThreat.eventFrame:RegisterEvent("UNIT_AURA")
caelThreat.eventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
caelThreat.eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
caelThreat.eventFrame:SetScript("OnEvent", function(self, event, unit)
	if unit ~= "player" then return end

	local isTank = IsTankCheck("player", isTankClassSpec[class])

	if event ~= "UNIT_AURA" then

		local _, status, threatPercent = UnitDetailedThreatSituation("player", "target")

		if not isTank then

			if status then
				threatPercent = floor(threatPercent + 0.5)
			end

			if (status and status < 1)	then
				if (abs(threatPercent - 20) <= 5) then
					if (lastWarning ~= 20) then
						RaidNotice_AddMessage(RaidWarningFrame, "|cff559655".."~20% THREAT|r", ChatTypeInfo["RAID_WARNING"])
						lastWarning = 20
					end
				elseif (abs(threatPercent - 40) <= 5) then
					if (lastWarning ~= 40) then
						RaidNotice_AddMessage(RaidWarningFrame, "|cff559655".."~40% THREAT|r", ChatTypeInfo["RAID_WARNING"])
						lastWarning = 40
					end
				elseif (abs(threatPercent - 60) <= 5) then
					if (lastWarning ~= 60) then
						RaidNotice_AddMessage(RaidWarningFrame, "|cffFFFF78".."~60% THREAT|r", ChatTypeInfo["RAID_WARNING"]) -- Yellow |cffA5A05A
						lastWarning = 60
					end
				end
			elseif (status and status > 0 and status < 3 and unit == "player") then
				if (abs(threatPercent - 80) <= 5) then
					if (lastWarning ~= 85) then
						if warningSounds then
							PlaySoundFile(caelMedia.files.soundWarning)
						end
						RaidNotice_AddMessage(RaidWarningFrame, "|cffFF9900".."WARNING THREAT: "..tostring(threatPercent).."%|r", ChatTypeInfo["RAID_WARNING"]) -- Orange |cffB46E46
						UIFrameFlash(LowHealthFrame, 0.2, 0.2, 0.4, false)
						lastWarning = 85
					end
				end
			elseif (status and status > 2 and unit == "player") then
				if warningSounds then
					PlaySoundFile(caelMedia.files.soundAggro)
				end
				RaidNotice_AddMessage(RaidWarningFrame, "|cffAF5050AGGRO|r", ChatTypeInfo["RAID_WARNING"]) -- Red
				UIFrameFlash(LowHealthFrame, 0.2, 0.2, 0.8, false)
			end
		end
	end

	for _, panel in pairs(caelPanels) do
		local status = UnitThreatSituation("player")
		if (status and status > 0) then
			local r, g, b = unpack(aggroColors[isTank][status])
			panel:SetBackdropBorderColor(r, g, b)
		else
			panel:SetBackdropBorderColor(0, 0, 0)
		end
	end
end)