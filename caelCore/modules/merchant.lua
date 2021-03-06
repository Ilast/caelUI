﻿--[[	$Id$	]]

local _, caelCore = ...

--[[	Auto sell junk & auto repair	]]

caelCore.merchant = caelCore.createModule("Merchant")

local merchant = caelCore.merchant

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
merchant:RegisterEvent("PLAYER_MONEY")
merchant:RegisterEvent("MERCHANT_SHOW")
merchant:SetScript("OnEvent", function(self, event)
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

		if CanMerchantRepair() then
			local cost, needed = GetRepairAllCost()
			if needed then
				local GuildWealth = CanGuildBankRepair() and GetGuildBankWithdrawMoney() > cost
				if GuildWealth then
					RepairAllItems(1)
					print(format("|cffD7BEA5cael|rCore: Guild bank repaired for %s.", formatMoney(cost)))
				elseif cost < GetMoney() then
					RepairAllItems()
					print(format("|cffD7BEA5cael|rCore: Repaired for %s.", formatMoney(cost)))
				else
					print("|cffD7BEA5cael|rCore: Repairs were unaffordable.")
				end
			end
		end
	elseif event == "PLAYER_MONEY" then
		local newMoney = GetMoney()
		local diffMoney
		if oldMoney and oldMoney > 0 then
			diffMoney = newMoney - oldMoney
		else
			diffMoney = 0
		end

		if diffMoney > 0 and itemCount > 0 then
			print(format("|cffD7BEA5cael|rCore: Sold %d trash item%s for %s.", itemCount, itemCount ~= 1 and "s" or "", formatMoney(diffMoney)))
		end
		itemCount = 0
	end
end)