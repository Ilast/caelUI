--[[	$Id: readyCheck.lua 515 2010-03-06 16:33:44Z sdkyron@gmail.com $	]]

local _, caelConfig = ...

--[[	Force readycheck warning	]]

ReadyCheckListenerFrame:SetScript("OnShow", nil) -- Stop the default
caelConfig.events:RegisterEvent("READY_CHECK")
caelConfig.events:HookScript("OnEvent", function(self, event)
	if event == "READY_CHECK" then
		PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
	end
end)