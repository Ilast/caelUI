--[[	$Id$	]]

local _, caelConfig = ...

--[[	Auto sell junk & auto repair	]]

local format = string.format

local formatMoney = function(value)
	if value >= 1e4 then
		return format("|cffffd700%dg |r|cffc7c7cf%ds |r|cffeda55f%dc|r", value/1e4, strsub(value, -4) / 1e2, strsub(value, -2))
	elseif value >= 1e2 then
		return format("|cffc7c7cf%ds |r|cffeda55f%dc|r", strsub(value, -4) / 1e2, strsub(value, -2))
	else
		return format("|cffeda55f%dc|r", strsub(value, -2))
	end
end

local oldMoney
local itemCount = 0
caelConfig.events:RegisterEvent("MERCHANT_SHOW")
caelConfig.events:HookScript("OnEvent", function(self, event)
	if event == "MERCHANT_SHOW" then
		oldMoney = GetMoney()
		for bag = 0, 4 do
			for slot = 0, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				if link and select(3, GetItemInfo(link)) == 0 then
					ShowMerchantSellCursor(1)
					UseContainerItem(bag, slot)
					itemCount = itemCount + GetItemCount(link)
				end
			end
		end

		if(CanMerchantRepair()) then
			local cost, afford = GetRepairAllCost()
			if(afford) then
				local GuildWealth = CanGuildBankRepair() and GetGuildBankWithdrawMoney() > cost
				if(GuildWealth) then
					RepairAllItems(1)
					print(format("Guild bank repaired for %s.", formatMoney(cost)))
				else
					RepairAllItems()
					print(format("Repaired for %s.", formatMoney(cost)))
				end
			end
		end
	end

	if event == "PLAYER_MONEY" then
		local newMoney = GetMoney()
		if oldMoney and oldMoney > 0 then
			diffMoney = newMoney - oldMoney
		else
			diffMoney = 0
		end
		if diffMoney > 0 and itemCount > 0 then
			print(format("Sold %d trash item%s for %s.", itemCount, itemCount ~= 1 and "s" or "", formatMoney(diffMoney)))
		end
		itemCount = 0
	end
end)