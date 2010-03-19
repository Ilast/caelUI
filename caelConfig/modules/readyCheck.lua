--[[	$Id$	]]

local _, caelConfig = ...

--[[	Force readycheck warning	]]

ReadyCheckListenerFrame:SetScript("OnShow", nil) -- Stop the default
caelConfig.events:RegisterEvent("READY_CHECK")
caelConfig.events:HookScript("OnEvent", function(self, event)
	if event == "READY_CHECK" then
		PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
	end
end)