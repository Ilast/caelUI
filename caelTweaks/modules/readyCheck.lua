--[[	Force readycheck warning	]]

ReadyCheckListenerFrame:SetScript("OnShow", nil) -- Stop the default
caelTweaks:RegisterEvent("READY_CHECK")
caelTweaks.READY_CHECK = function(self)
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
end