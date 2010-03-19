--[[	$Id: battleground.lua 598 2010-03-09 19:04:14Z sdkyron@gmail.com $	]]

local _, caelConfig = ...

--[[	Auto release in battleground	]]

caelConfig.events:RegisterEvent("PLAYER_DEAD")
caelConfig.events:HookScript("OnEvent", function(self, event)
	if event == "PLAYER_DEAD" then
		if (tostring(GetZoneText()) == "Wintergrasp") then
			RepopMe()
		end

		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end)