local _, caelTweaks = ...

--[[	Auto release in battleground	]]

caelTweaks.events:RegisterEvent("PLAYER_DEAD")
caelTweaks.events:HookScript("OnEvent", function(self, event)
	if event == "PLAYER_DEAD" then
		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end)