--[[	$Id$	]]

local _, caelConfig = ...

--[[	Turn my name on when i'm AFK	]]

caelConfig.events:RegisterEvent("CHAT_MSG_SYSTEM")
caelConfig.events:RegisterEvent("PLAYER_LOGOUT")
caelConfig.events:RegisterEvent("PLAYER_ENTERING_WORLD")
caelConfig.events:HookScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_SYSTEM" or event == "PLAYER_LOGOUT" or event == "PLAYER_ENTERING_WORLD" then
		if event == "PLAYER_LOGOUT" then
			SetCVar("UnitNameOwn", 0)
		else
			SetCVar("UnitNameOwn", UnitIsAFK("player") and 1 or 0)
			
			if event == "CHAT_MSG_SYSTEM" then
				if string.find(..., CLEARED_AFK) then
					SetCVar("UnitNameOwn", 0)
				elseif string.find(..., string.gsub(MARKED_AFK_MESSAGE, "%%s", ".*")) or string.find(..., MARKED_AFK) then
					SetCVar("UnitNameOwn", 1)
				end
			end
		end
	end
end)