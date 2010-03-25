--[[	$Id: battleground.lua 727 2010-03-25 16:10:31Z sdkyron@gmail.com $	]]

local _, caelCore = ...

--[[	Auto release in battleground	]]

caelCore.events:RegisterEvent("PLAYER_DEAD")
caelCore.events:HookScript("OnEvent", function(self, event)
	if event == "PLAYER_DEAD" then
		if (tostring(GetZoneText()) == "Wintergrasp") then
			RepopMe()
		end

		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end)