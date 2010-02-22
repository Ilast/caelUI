--[[	Auto release in battleground	]]

caelTweaks:RegisterEvent("PLAYER_DEAD")
caelTweaks.PLAYER_DEAD = function(self)
	if (event == "PLAYER_DEAD") then
		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end