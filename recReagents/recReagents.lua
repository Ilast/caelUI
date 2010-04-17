--[[	$Id$	]]

local _, recReagents = ...

local playerName = caelLib.playerName
local playerRealm = caelLib.playerRealm

recReagents.eventFrame = CreateFrame("Frame", nil, UIParent)

--[[
	This is where you will add your characters, their realm, and the stock levels
	of each item they will want auto-stocked.
--]]
local reagents = {
	["Illidan"] = {
		["Caellian"] = {[31737] = 18000, [33445] = 40, [35953] = 40},
		["Callysto"] = {[41586] = 18000, [33445] = 40, [35953] = 40},
	}
}

-- Internal settings, local globals.
local my_reagents
local itemid_pattern		= "item:(%d+)"
local GetContainerNumSlots	= _G.GetContainerNumSlots
local GetContainerItemLink	= _G.GetContainerItemLink
local GetContainerItemInfo	= _G.GetContainerItemInfo
local GetMerchantNumItems	= _G.GetMerchantNumItems
local GetMerchantItemInfo	= _G.GetMerchantItemInfo
local GetMerchantItemLink	= _G.GetMerchantItemLink
local BuyMerchantItem		= _G.BuyMerchantItem
local GetItemInfo			= _G.GetItemInfo
local GetMoney				= _G.GetMoney
local select				= select

--[[
	Returns the amount of checkid which would be needed to stock the item to the preset level.
	This does NOT return the amount of the item which will be purchased (due to possible
	overstock), rather the total amount which would be ideal.
--]]
local function HowMany(checkid)
	if not my_reagents[checkid] then return 0 end
	local total = 0
	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local id = tonumber(select(3, string.find(link, itemid_pattern)))
				local stack = select(2, GetContainerItemInfo(bag, slot))
				if id == checkid then total = total + stack end
			end
		end
	end
	return math.max(0, (my_reagents[checkid] - total))
end

--[[
	Purchases the required amount of reagents to come as close as possible to the requested
	stock level.  Does NOT overstock, so you may end up with less than the stock level you
	asked for.
--]]
local function BuyReagents()
	for i = 1, GetMerchantNumItems() do
		local link, id = GetMerchantItemLink(i)
		if link then id = tonumber(select(3, string.find(link, itemid_pattern))) end
		if id and my_reagents[id] then
			local price, stack, stock = select(3, GetMerchantItemInfo(i))
			local quantity = HowMany(id)
			if quantity > 0 then
				if stock ~= -1 then quantity = math.min(quantity, stock) end
				subtotal = price * (quantity/stack)
				if subtotal > GetMoney() then print("|cffD7BEA5cael|rReagents: Not enough money to purchase reagents."); return end
				local fullstack = select(8, GetItemInfo(id))
				while quantity > fullstack do
					BuyMerchantItem(i, math.floor(fullstack/stack))
					quantity = quantity - fullstack
				end
				if quantity >= stack then
					BuyMerchantItem(i, math.floor(quantity/stack))
				end
			end
		end
	end
end

--[[
	Ensures that we have the player's name, their realm, and that a table actually exists for
	that particular character before scanning the vendor for purchases.
--]]
recReagents.eventFrame:RegisterEvent("MERCHANT_SHOW")
recReagents.eventFrame:SetScript("OnEvent", function()
	if my_reagents then
		BuyReagents()
	end
end)

if reagents[playerRealm] and reagents[playerRealm][playerName] then
	my_reagents = reagents[playerRealm][playerName]
	reagents = nil
end