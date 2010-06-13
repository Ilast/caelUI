--[[	$Id$	]]

local _, caelCore = ...

--[[	Auto cancel various buffs	]]

caelCore.miscellaneous = caelCore.createModule("Miscellaneous")

local miscellaneous = caelCore.miscellaneous

miscellaneous:RegisterEvent("UNIT_AURA")
miscellaneous:SetScript("OnEvent", function(self, event)
	if UnitBuff("player", "Mohawked!") then
		CancelUnitBuff("player", "Mohawked!")
	end

	if UnitBuff("player", "Hand of Protection") then
		CancelUnitBuff("player", "Hand of Protection")
	end
end