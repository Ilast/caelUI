--[[	$Id$	]]

local _, caelCore = ...

--[[	Force readycheck warning	]]

caelCore.readycheck = caelCore.createModule("ReadyCheck")

local readycheck = caelCore.readycheck

ReadyCheckListenerFrame:SetScript("OnShow", nil) -- Stop the default
readycheck:RegisterEvent("READY_CHECK")
readycheck:SetScript("OnEvent", function(self, event)
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
end)