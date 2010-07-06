--[[	$Id$	]]

local _, caelCore = ...

caelCore.battleground = caelCore.createModule("Battleground")

local battleground = caelCore.battleground

--[[	Auto release in battleground	]]

battleground:RegisterEvent("PLAYER_DEAD")
battleground:SetScript("OnEvent", function(self, event)
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or tostring(GetZoneText()) == "Wintergrasp" then
		RepopMe()
	end
end)