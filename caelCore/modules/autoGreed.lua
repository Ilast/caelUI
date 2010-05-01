--[[	$Id$	]]

local _, caelCore = ...

--[[	Auto disenchant/greed on BoE green	]]

caelCore.autogreed = caelCore.createModule("AutoGreed")

local autogreed = caelCore.autogreed

autogreed:RegisterEvent("START_LOOT_ROLL")
autogreed:SetScript("OnEvent", function(self, event, id)
	if UnitLevel("player") ~= MAX_PLAYER_LEVEL then return end

	local _, _, _, quality, BoP, _, _, canDE = GetLootRollItemInfo(id)

	if id and quality == 2 and not BoP then
		RollOnLoot(id, canDE and 3 or 2)
	end
end)