local _, caelConfig = ...

--[[	Custom whisper sound	]]

caelConfig.events:RegisterEvent("CHAT_MSG_WHISPER")
caelConfig.events:HookScript("OnEvent", function(self, event)
	if event == "CHAT_MSG_WHISPER" then
		PlaySoundFile([=[Interface\Addons\caelMedia\Sounds\whisper.mp3]=])
	end
end)