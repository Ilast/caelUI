--[[	$Id$	]]

local _, caelConfig = ...

--[[	Auto release in battleground	]]

caelConfig.events:RegisterEvent("PLAYER_DEAD")
caelConfig.events:HookScript("OnEvent", function(self, event)
	if event == "PLAYER_DEAD" then
		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end)