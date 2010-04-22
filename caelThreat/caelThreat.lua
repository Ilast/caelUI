--[[	$Id$	]]

local _, caelThreat = ...

local lastWarning
local abs = math.abs

caelThreat.eventFrame = CreateFrame("Frame", nil, self)

local warningSounds = true

caelThreat.eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
caelThreat.eventFrame:SetScript("OnEvent", function(self, event, unit)
	if unit ~= "player" then return end

	local isTanking, status, threatPercent = UnitDetailedThreatSituation("player", "target")

	if not isTanking then

		if status then
			threatPercent = floor(threatPercent + 0.5)
		end

		if (status and status < 1)	then
			if (abs(threatPercent - 20) <= 5) then
				if (lastWarning ~= 20) then
					RaidNotice_AddMessage(RaidWarningFrame, "|cffB0B0B0".."~20% THREAT|r", ChatTypeInfo["RAID_WARNING"]) -- Green |cff559655
					lastWarning = 20
				end
			elseif (abs(threatPercent - 40) <= 5) then
				if (lastWarning ~= 40) then
					RaidNotice_AddMessage(RaidWarningFrame, "|cffB0B0B0".."~40% THREAT|r", ChatTypeInfo["RAID_WARNING"]) -- Green |cff559655
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

		for _, panel in pairs(caelPanels) do
			local status = UnitThreatSituation("player")
			if (status and status > 0) then
				local r, g, b = GetThreatStatusColor(status)
				panel:SetBackdropBorderColor(r, g, b)
			else
				panel:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end
end)