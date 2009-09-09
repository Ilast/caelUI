local Holder = CreateFrame("Frame")

caelStats.bags = caelPanel10:CreateFontString(nil, "OVERLAY")
caelStats.bags:SetFont(font, fontSize, fontOutline)
caelStats.bags:SetPoint("CENTER", caelPanel10, "CENTER", -300, 0.5)

local OnEvent = function(self)
	local freeSlots, totalSlots = 0, 0
	for i = 0, 4 do
		local slots, slotsTotal = GetContainerNumFreeSlots(i), GetContainerNumSlots(i)
		freeSlots = freeSlots + slots
		totalSlots = totalSlots + slotsTotal
	end
--	caelStats.bags:SetText("|cffD7BEA5Bags |r"..freeSlots.." / "..totalSlots)
	caelStats.bags:SetFormattedText("|cffD7BEA5Bags |r%d / %d", freeSlots, totalSlots)
end

Holder:EnableMouse(true)
Holder:SetAllPoints(caelStats.bags)
Holder:RegisterEvent("BAG_UPDATE")
Holder:RegisterEvent("UNIT_INVENTORY_CHANGED")
Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
Holder:SetScript("OnMouseDown", function() OpenAllBags() end)
Holder:SetScript("OnEvent", OnEvent)