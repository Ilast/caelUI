--[[	$Id$	]]

local _, caelCore = ...

--[[	Blacklist some UIErrorsFrame messages	]]

caelCore.uierrorsframe = caelCore.createModule("UIerrorsFrame")

local uierrorsframe = caelCore.uierrorsframe

local eventBlacklist = {
	[ERR_NO_ATTACK_TARGET] = true,
	[OUT_OF_RAGE] = true,
	[OUT_OF_ENERGY] = true,
	[ERR_ABILITY_COOLDOWN] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[ERR_SPELL_COOLDOWN] = true,
}

uierrorsframe:RegisterEvent("UI_ERROR_MESSAGE")
uierrorsframe:SetScript("OnEvent", function(self, event, error)
	if(not eventBlacklist[error]) then
		UIErrorsFrame:AddMessage(error, 0.69, 0.31, 0.31)
	end
end)

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")