--[[	Blacklist some UIErrorsFrame messages	]]

local eventBlacklist = {
	[ERR_NO_ATTACK_TARGET] = true,
	[OUT_OF_ENERGY] = true,
	[ERR_ABILITY_COOLDOWN] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[ERR_SPELL_COOLDOWN] = true,
}

caelTweaks:RegisterEvent("UI_ERROR_MESSAGE")
caelTweaks.UI_ERROR_MESSAGE = function(self, event, error)
	if(not eventBlacklist[error]) then
		UIErrorsFrame:AddMessage(error, 0.69, 0.31, 0.31)
	end
end

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")