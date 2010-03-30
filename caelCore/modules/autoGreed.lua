--[[	$Id$	]]

local _, caelCore = ...

--[[	Auto disenchant/greed on BoE green	]]

caelCore.autogreed = caelCore.createModule("AutoGreed")

local autogreed = caelCore.autogreed

autogreed:RegisterEvent("START_LOOT_ROLL")
autogreed:SetScript("OnEvent", function(self, event, id)
	if UnitLevel("player") < 60 then return end
	if(id and select(4, GetLootRollItemInfo(id))==2 and not (select(5, GetLootRollItemInfo(id)))) then
		if RollOnLoot(id, 3) then
			RollOnLoot(id, 3)
		else
			RollOnLoot(id, 2)
		end
	end
end)