--[[	$Id: miscellaneous.lua 1242 2010-06-13 18:20:14Z sdkyron@gmail.com $	]]

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