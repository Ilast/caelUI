local _, caelTweaks = ...

--[[	Custom whisper sound	]]

caelTweaks.events:RegisterEvent("CHAT_MSG_WHISPER")
caelTweaks.events:HookScript("OnEvent", function(self, event)
	if event == "CHAT_MSG_WHISPER" then
		PlaySoundFile([=[Interface\Addons\caelMedia\Sounds\whisper.mp3]=])
	end
end)