--[[	$Id$	]]

local _, caelCore = ...

--[[	Force readycheck warning	]]

ReadyCheckListenerFrame:SetScript("OnShow", nil) -- Stop the default
caelCore.events:RegisterEvent("READY_CHECK")
caelCore.events:HookScript("OnEvent", function(self, event)
	if event == "READY_CHECK" then
		PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
	end
end)