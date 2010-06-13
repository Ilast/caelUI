--[[	$Id$	]]

local _, caelCore = ...

--[[	Auto cancel various buffs	]]

caelCore.badbuffs = caelCore.createModule("BadBuffs")

local badbuffs = caelCore.badbuffs

local badBuffsList = {
	["Mohawked!"] = true,
	["Hand of Protection"] = true,
}

badbuffs:RegisterEvent("UNIT_AURA")
badbuffs:SetScript("OnEvent", function(self, event)
	for k, v in pairs(badBuffsList) do
		CancelUnitBuff("player", k)
	end
end)