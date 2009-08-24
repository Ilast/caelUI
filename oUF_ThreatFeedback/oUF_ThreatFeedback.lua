--[[
	Threat Background

	Elements handled: .ThreatBackground

	Functions that can be overridden from within a layout:
	- :PreUpdateThreat(event, unit)
	- :OverrideUpdateThreat(event, unit, status)
	- :PostUpdateThreat(event, unit, status)
--]]
local parent = debugstack():match[[\AddOns\(.-)\]]
local global = GetAddOnMetadata(parent, "X-oUF")
local oUF = _G[global] or oUF
assert(oUF, "oUF not loaded")

local lastWarning
local abs = math.abs

local warningSounds = true -- false to disable audio warnings

local mediaPath = [=[Interface\Addons\oUF_ThreatFeedback\media\]=]
local glowTex = mediaPath..[=[textures\glowTex]=]

local Update = function(self, event, unit)
	if (self.unit ~= unit) then return end
	if(self.PreUpdateThreat) then self:PreUpdateThreat(event, unit) end

	local status = UnitThreatSituation(unit)
	if (status and status > 0) then
		r, g, b = GetThreatStatusColor(status)
		self.ThreatFeedbackFrame:SetBackdropBorderColor(r, g, b)
		self.ThreatFeedbackFrame:Show()
	else
		self.ThreatFeedbackFrame:SetBackdropBorderColor(0, 0, 0)
		self.ThreatFeedbackFrame:Hide()
	end

	if (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) then
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
	end
	if(self.PostUpdateThreat) then self:PostUpdateThreat(event, unit, status) end
end

local Enable = function(self)
	if (not self.ThreatFeedbackFrame) then
		local ThreatFeedbackFrame = CreateFrame("Frame", nil, self)
		ThreatFeedbackFrame:SetPoint("TOPLEFT", self, "TOPLEFT", -4.5, 4)
		ThreatFeedbackFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4.5, -4.5)
		ThreatFeedbackFrame:SetFrameStrata("BACKGROUND")
		ThreatFeedbackFrame:SetBackdrop({
			edgeFile = glowTex, edgeSize = 5,
			insets = {left = 3, right = 3, top = 3, bottom = 3}
		})
		ThreatFeedbackFrame:SetBackdropColor(0, 0, 0, 0)
		ThreatFeedbackFrame:SetBackdropBorderColor(0, 0, 0)
		ThreatFeedbackFrame:Hide()
		self.ThreatFeedbackFrame = ThreatFeedbackFrame
	end
	table.insert(self.__elements, Update)
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", Update)
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)

	if (self.Threat) then
		self:DisableElement("Threat")
		self.Threat = nil
		self.PreUpdateThreat = nil
		self.OverrideUpdateThreat = nil
		self.PostUpdateThreat = nil
	end
end

local Disable = function(self)
	if (self.ThreatFeedbackFrame) then
		self:UnregisterEvent("UNIT_THREAT_LIST_UPDATE", Update)
		self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)
	end
end

oUF:AddElement("ThreatFeedback", Update, Enable, Disable)