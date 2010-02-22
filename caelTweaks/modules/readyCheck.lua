local _, caelTweaks = ...

--[[	Force readycheck warning	]]

ReadyCheckListenerFrame:SetScript("OnShow", nil) -- Stop the default
caelTweaks.events:RegisterEvent("READY_CHECK")
caelTweaks.events:HookScript("OnEvent", function(self, event)
	if event == "READY_CHECK" then
		PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
	end
end)