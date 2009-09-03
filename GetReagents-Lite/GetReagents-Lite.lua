--[[====================================================
GetReagents-Lite.lua
$Revision: 336 $
$Date: 2009-08-14 04:48:00 -0500 (Fri, 14 Aug 2009) $
======================================================]]

--[[
	This is where you will add your characters, their realm, and the stock levels
	of each item they will want auto-stocked.
--]]
local reagents = {
	["The Maelstrom"] = {
		["Caellian"] = {[31735] = 18000, [33445] = 40, [35953] = 40}, -- [31737] = 18000
		["Pimiko"] = {[33445] = 40}
	},
}

-- Internal settings, local globals.
local name, realm
local not_enough_money		= "GetReagents-Lite: Not enough money."
local itemid_pattern		= "item:(%d+)"
local GetContainerNumSlots	= _G.GetContainerNumSlots
local GetContainerItemLink	= _G.GetContainerItemLink
local GetContainerItemInfo	= _G.GetContainerItemInfo
local GetMerchantNumItems	= _G.GetMerchantNumItems
local GetMerchantItemInfo	= _G.GetMerchantItemInfo
local GetMerchantItemLink	= _G.GetMerchantItemLink
local BuyMerchantItem		= _G.BuyMerchantItem
local UnitName				= _G.UnitName
local GetRealmName			= _G.GetRealmName
local GetItemInfo			= _G.GetItemInfo
local GetMoney				= _G.GetMoney
local select				= select
local print					= print
local math_max				= math.max
local math_min				= math.min
local math_floor			= math.floor
local tonumber				= tonumber
local string_find			= string.find

-- Our frame, for events.
local f = CreateFrame("Frame", "GetReagentsLite", UIParent)

--[[
	Returns the amount of checkid which would be needed to stock the item to the preset level.
	This does NOT return the amount of the item which will be purchased (due to possible
	overstock), rather the total amount which would be ideal.
--]]
local function HowMany(checkid)
	if not reagents[realm][name][checkid] then return 0 end
	local total = 0
	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local id = tonumber(select(3, string_find(link, itemid_pattern)))
				local stack = select(2, GetContainerItemInfo(bag, slot))
				if id == checkid then total = total + stack
				end
			end
		end
	end
	return math_max(0, (reagents[realm][name][checkid] - total))
end

--[[
	Purchases the required amount of reagents to come as close as possible to the requested
	stock level.  Does NOT overstock, so you may end up with less than the stock level you
	asked for.
--]]
local function BuyReagents()
	for i=1, GetMerchantNumItems() do
		local link, id = GetMerchantItemLink(i)
		if link then id = tonumber(select(3, string_find(link, itemid_pattern))) end
		if id and reagents[realm][name][id] then
			local price, stack, stock = select(3, GetMerchantItemInfo(i))
			local quantity = HowMany(id)
			if quantity > 0 then
				if stock ~= -1 then quantity = math_min(quantity, stock) end
				subtotal = price * (quantity/stack)
				if subtotal > GetMoney() then print(not_enough_money); return end
				local fullstack = select(8, GetItemInfo(id))
				while quantity > fullstack do
					BuyMerchantItem(i, math_floor(fullstack/stack))
					quantity = quantity - fullstack
				end
				if quantity >= stack then
					BuyMerchantItem(i, math_floor(quantity/stack))
				end
			end
		end
	end
end

--[[
	Ensures that we have the player's name, their realm, and that a table actually exists for
	that particular character before scanning the vendor for purchases.
--]]
local function OnMerchantShow()
	if not name then name = UnitName("player") end
	if not realm then realm = GetRealmName() end
	if reagents[realm] and reagents[realm][name] then BuyReagents() end
end

-- Frame events.
f:SetScript("OnEvent", OnMerchantShow)
f:RegisterEvent("MERCHANT_SHOW")