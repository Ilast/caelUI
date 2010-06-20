--[[	$Id$	]]

local _, caelCore = ...

caelCore.battleground = caelCore.createModule("Battleground")

local battleground = caelCore.battleground

--[[	Auto release in battleground	]]

battleground:RegisterEvent("PLAYER_DEAD")
battleground:SetScript("OnEvent", function(self, event)
	if tostring(GetZoneText()) == "Wintergrasp" or MiniMapBattlefieldFrame.status == "active" then
		RepopMe()
	end
end)