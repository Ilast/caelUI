--[[	Auto disenchant/greed on BoE green	]]

caelTweaks:RegisterEvent("START_LOOT_ROLL")
caelTweaks.START_LOOT_ROLL = function(self, event, id)
	if(id and select(4, GetLootRollItemInfo(id))==2 and not (select(5, GetLootRollItemInfo(id)))) then
		if RollOnLoot(id, 3) then
			RollOnLoot(id, 3)
		else
			RollOnLoot(id, 2)
		end
	end
end