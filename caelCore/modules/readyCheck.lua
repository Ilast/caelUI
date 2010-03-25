--[[	$Id: readyCheck.lua 727 2010-03-25 16:10:31Z sdkyron@gmail.com $	]]

local _, caelCore = ...

--[[	Force readycheck warning	]]

ReadyCheckListenerFrame:SetScript("OnShow", nil) -- Stop the default
caelCore.events:RegisterEvent("READY_CHECK")
caelCore.events:HookScript("OnEvent", function(self, event)
	if event == "READY_CHECK" then
		PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
	end
end)