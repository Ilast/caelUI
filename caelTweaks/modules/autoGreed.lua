local _, caelTweaks = ...

--[[	Auto disenchant/greed on BoE green	]]

caelTweaks.events:RegisterEvent("START_LOOT_ROLL")
caelTweaks.events:HookScript("OnEvent", function(self, event, id)
	if event == "START_LOOT_ROLL" then
		if(id and select(4, GetLootRollItemInfo(id))==2 and not (select(5, GetLootRollItemInfo(id)))) then
			if RollOnLoot(id, 3) then
				RollOnLoot(id, 3)
			else
				RollOnLoot(id, 2)
			end
		end
	end
end)