--[[	$Id$	]]

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