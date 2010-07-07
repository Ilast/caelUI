--[[	$Id$	]]

if caelLib.playerClass ~= "HUNTER" then return end

local _, oUF_Caellian = ...

oUF_Caellian.eventFrame = CreateFrame("Frame", nil, UIParent)

local viperAspectName = GetSpellInfo(34074)

oUF_Caellian.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
oUF_Caellian.eventFrame:SetScript("OnEvent", function(self, event, arg1, ...)
	if event == "LEARNED_SPELL_IN_TAB" then
		AotV = GetSpellInfo(viperAspectName)
		if AotV then
			self:UnregisterEvent("LEARNED_SPELL_IN_TAB")
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		if UnitLevel("player") < 20 then
			self:RegisterEvent("PLAYER_LEVEL_UP")
			return
		end
		AotV = GetSpellInfo(viperAspectName)
		if not AotV then
			self:RegisterEvent("LEARNED_SPELL_IN_TAB")
		end
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	elseif event == "PLAYER_LEVEL_UP" and arg1 == 20 then
		self:UnregisterEvent("PLAYER_LEVEL_UP")
		self:RegisterEvent("LEARNED_SPELL_IN_TAB")
	end
end)