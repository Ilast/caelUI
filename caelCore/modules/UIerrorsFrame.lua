--[[	$Id: UIerrorsFrame.lua 727 2010-03-25 16:10:31Z sdkyron@gmail.com $	]]

local _, caelCore = ...

--[[	Blacklist some UIErrorsFrame messages	]]

local eventBlacklist = {
	[ERR_NO_ATTACK_TARGET] = true,
	[OUT_OF_ENERGY] = true,
	[ERR_ABILITY_COOLDOWN] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[ERR_SPELL_COOLDOWN] = true,
}

caelCore.events:RegisterEvent("UI_ERROR_MESSAGE")
caelCore.events:HookScript("OnEvent", function(self, event, error)
	if event == "UI_ERROR_MESSAGE" then
		if(not eventBlacklist[error]) then
			UIErrorsFrame:AddMessage(error, 0.69, 0.31, 0.31)
		end
	end
end)

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")