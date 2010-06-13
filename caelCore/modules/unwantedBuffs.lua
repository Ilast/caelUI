--[[	$Id$	]]

local _, caelCore = ...

--[[	Auto cancel various buffs	]]

caelCore.miscellaneous = caelCore.createModule("Miscellaneous")

local miscellaneous = caelCore.miscellaneous

local unwantedBuffs = {
	["Mohawked!"] = true,
	["Hand of Protection"] = true,
}

miscellaneous:RegisterEvent("UNIT_AURA")
miscellaneous:SetScript("OnEvent", function(self, event)
	for k, v in pairs(unwantedBuffs) do
		CancelUnitBuff("player", k)
	end
end)