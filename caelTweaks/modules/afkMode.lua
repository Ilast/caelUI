--[[	Turn my name on when i'm AFK	]]

caelTweaks:RegisterEvent("PLAYER_LOGOUT")
caelTweaks.PLAYER_LOGOUT = function(self, event, ...)
	SetCVar("UnitNameOwn", 0)
end

caelTweaks:RegisterEvent("CHAT_MSG_SYSTEM")
caelTweaks.CHAT_MSG_SYSTEM = function(self, event, ...)
	SetCVar("UnitNameOwn", UnitIsAFK("player") and 1 or 0)

	if string.find(..., CLEARED_AFK) then
		SetCVar("UnitNameOwn", 0)
	elseif string.find(..., string.gsub(MARKED_AFK_MESSAGE, "%%s", ".*")) or string.find(..., MARKED_AFK) then
		SetCVar("UnitNameOwn", 1)
	end
end

caelTweaks:RegisterEvent("PLAYER_ENTERING_WORLD")
caelTweaks.PLAYER_ENTERING_WORLD = function(self, event, ...)
		SetCVar("UnitNameOwn", UnitIsAFK("player") and 1 or 0)
end