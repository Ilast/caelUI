--[[	$Id$	]]

local _, caelCore = ...

--[[	Custom whisper sound	]]

caelCore.events:RegisterEvent("CHAT_MSG_WHISPER")
caelCore.events:HookScript("OnEvent", function(self, event)
	if event == "CHAT_MSG_WHISPER" then
		PlaySoundFile([=[Interface\Addons\caelMedia\Sounds\whisper.mp3]=])
	end
end)