--[[	$Id$	]]

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

	if(self.PostUpdateThreat) then self:PostUpdateThreat(event, unit, status) end
end

local Enable = function(self)
	if (not self.ThreatFeedbackFrame) then
		local ThreatFeedbackFrame = CreateFrame("Frame", nil, self)
		ThreatFeedbackFrame:SetPoint("TOPLEFT", self, "TOPLEFT", -4.5, 4)
		ThreatFeedbackFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4.5, -4.5)
		ThreatFeedbackFrame:SetFrameStrata("BACKGROUND")
		ThreatFeedbackFrame:SetBackdrop({
			edgeFile = [=[Interface\Addons\oUF_ThreatFeedback\media\glowtex]=],
			edgeSize = 5,
			insets = {left = 3, right = 3, top = 3, bottom = 3}
		})
		ThreatFeedbackFrame:SetBackdropColor(0, 0, 0, 0)
		ThreatFeedbackFrame:SetBackdropBorderColor(0, 0, 0)
		ThreatFeedbackFrame:Hide()
		self.ThreatFeedbackFrame = ThreatFeedbackFrame
	end
	table.insert(self.__elements, Update)
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
		self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)
	end
end

oUF:AddElement("ThreatFeedback", Update, Enable, Disable)