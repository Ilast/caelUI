--[[	$Id$	]]

local _, caelDataFeeds = ...

caelDataFeeds.durability = caelDataFeeds.createModule("Durability")

local durability = caelDataFeeds.durability

durability.text:SetPoint("CENTER", caelPanel8, "CENTER", 225, 1) 

durability:RegisterEvent("UPDATE_INVENTORY_DURABILITY")

local Total = 0
local current, max
local Slots = {
    [1] = {1, "Head", 1000},
    [2] = {3, "Shoulder", 1000},
    [3] = {5, "Chest", 1000},
    [4] = {6, "Waist", 1000},
    [5] = {7, "Legs", 1000},
    [6] = {8, "Feet", 1000},
    [7] = {9, "Wrist", 1000},
    [8] = {10, "Hands", 1000},
    [9] = {16, "Main Hand", 1000},
    [10] = {17, "Off Hand", 1000},
    [11] = {18, "Ranged", 1000}
}

durability:SetScript("OnEvent", function(self, event)
	for i = 1, 11 do
		if GetInventoryItemLink("player", Slots[i][1]) ~= nil then
			current, max = GetInventoryItemDurability(Slots[i][1])
			if current ~= max then
				Slots[i][3] = current/max
					Total = Total + 1
			end
		end
	end
	table.sort(Slots, function(a, b) return a[3] < b[3] end)
	
	if Total > 0 then
		self.text:SetFormattedText("|cffD7BEA5Dur|r %d%s", floor(Slots[1][3] * 100), "%")
	else
		self.text:SetText("100% |cffD7BEA5Armor|r")
	end
end)

durability:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	for i = 1, 11 do
		if Slots[i][3] ~= 1000 then
			green = Slots[i][3] * 2
			red = 1 - green
			GameTooltip:AddDoubleLine(Slots[i][2], floor(Slots[i][3]*100).."%", 0.84, 0.75, 0.65, red + 1, green, 0)
		end
	end
	GameTooltip:Show()
	Total = 0
end)