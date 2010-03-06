--[[	$Id$	]]

local _, caelStats = ...

local Holder = CreateFrame("Frame")

caelStats.durability = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.durability:SetFontObject(neuropolrg10)
caelStats.durability:SetPoint("CENTER", caelPanel8, "CENTER", 225, 1) 

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

local OnEvent = function(self)
	for i = 1, 11 do
		if GetInventoryItemLink("player", Slots[i][1]) ~= nil then
			current, max = GetInventoryItemDurability(Slots[i][1])
			if current then 
				Slots[i][3] = current/max
				Total = Total + 1
			end
		end
	end
	table.sort(Slots, function(a, b) return a[3] < b[3] end)
	
	if Total > 0 then
--		caelStats.durability:SetText("|cffD7BEA5Dur |r"..floor(Slots[1][3]*100).."%")
		caelStats.durability:SetFormattedText("|cffD7BEA5Dur |r%d%s", floor(Slots[1][3]*100), "%")
	else
		caelStats.durability:SetText("100% |cffD7BEA5Armor|r")
	end
end

local OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	for i = 1, 11 do
		if Slots[i][3] ~= 1000 then
			green = Slots[i][3]*2
			red = 1 - green
			GameTooltip:AddDoubleLine(Slots[i][2], floor(Slots[i][3]*100).."%",1 ,1 , 1, red + 1, green, 0)
		end
	end
	GameTooltip:Show()
	Total = 0
end

Holder:EnableMouse(true)
Holder:SetAllPoints(caelStats.durability)
Holder:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
--Holder:RegisterEvent("MERCHANT_SHOW")
--Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
Holder:SetScript("OnEnter", OnEnter)
Holder:SetScript("OnLeave", function() GameTooltip:Hide() end)
Holder:SetScript("OnEvent", OnEvent)