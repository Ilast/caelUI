--[[	Custom whisper sound	]]

caelTweaks:RegisterEvent("CHAT_MSG_WHISPER")
caelTweaks.CHAT_MSG_WHISPER = function(self)
	if(event == "CHAT_MSG_WHISPER") then
		PlaySoundFile([=[Interface\Addons\caelMedia\Sounds\whisper.mp3]=])
	end
end