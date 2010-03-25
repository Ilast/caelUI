--[[	$Id: oUF_ThreatFeedback.lua 540 2010-03-06 17:48:05Z sdkyron@gmail.com $	]]

local _, caelThreat = ...

local lastWarning
local abs = math.abs

local mediaPath = [=[Interface\Addons\oUF_ThreatFeedback\media\]=]
local glowTex = mediaPath..[=[textures\glowtex]=]

caelThreat.eventFrame = CreateFrame("Frame", nil, self)
caelThreat.eventFrame:SetPoint("CENTER", UIParent)
caelThreat.eventFrame:SetSize(80, 80)
caelThreat.eventFrame:SetFrameStrata("BACKGROUND")
caelThreat.eventFrame:SetBackdrop({
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = glowTex, edgeSize = 5,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
})
caelThreat.eventFrame:SetBackdropColor(0, 0, 0, 0)
caelThreat.eventFrame:SetBackdropBorderColor(0, 0, 0)
caelThreat.eventFrame:Hide()

local warningSounds = true -- false to disable audio warnings

caelThreat.eventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
caelThreat.eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
caelThreat.eventFrame:SetScript("OnEvent", function(self, event, unit)
	if unit ~= "player" then return end

	local status = UnitThreatSituation("player")
	if (status and status > 0) then
		r, g, b = GetThreatStatusColor(status)
		self:SetBackdropBorderColor(r, g, b)
		self:Show()
	else
		self:SetBackdropBorderColor(0, 0, 0)
		self:Hide()
	end

--	if (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) then
		local _,status,threatpct,_, threatvalue = UnitDetailedThreatSituation("player", "target")
		if (status) then
			threatpct = floor(threatpct + 0.5)
		end

		if (status and status < 1)	then
			if (abs(threatpct - 20) <= 5) then
				if (lastWarning ~= 20) then
					RaidNotice_AddMessage(RaidWarningFrame, "|cff559655".."~20% THREAT|r", ChatTypeInfo["RAID_WARNING"]) -- Green
					lastWarning = 20
				end
			elseif (abs(threatpct - 40) <= 5) then
				if (lastWarning ~= 40) then
					RaidNotice_AddMessage(RaidWarningFrame, "|cff559655".."~40% THREAT|r", ChatTypeInfo["RAID_WARNING"]) -- Green
					lastWarning = 40
				end
			elseif (abs(threatpct - 60) <= 5) then
				if (lastWarning ~= 60) then
					RaidNotice_AddMessage(RaidWarningFrame, "|cffA5A05A".."~60% THREAT|r", ChatTypeInfo["RAID_WARNING"]) -- Yellow
					lastWarning = 60
				end
			end
		elseif (status and status > 0 and status < 3 and unit == "player") then
			if (abs(threatpct - 80) <= 5) then
				if (lastWarning ~= 85) then
					if warningSounds then
						PlaySoundFile(mediaPath..[=[sounds\warning.mp3]=])
					end
					RaidNotice_AddMessage(RaidWarningFrame, "|cffB46E46".."WARNING THREAT: "..tostring(threatpct).."%|r", ChatTypeInfo["RAID_WARNING"]) -- Orange
					UIFrameFlash(LowHealthFrame, 0.2, 0.2, 0.4, false)
					lastWarning = 85
				end
			end
		elseif (status and status > 2 and unit == "player") then
			if warningSounds then
				PlaySoundFile(mediaPath..[=[sounds\aggro.mp3]=])
			end
			RaidNotice_AddMessage(RaidWarningFrame, "|cffAF5050AGGRO|r", ChatTypeInfo["RAID_WARNING"]) -- Red
			UIFrameFlash(LowHealthFrame, 0.2, 0.2, 0.8, false)
		end
--	end
end)