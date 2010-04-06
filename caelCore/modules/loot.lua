--[[	$Id$	]]

for i = 1, NUM_GROUP_LOOT_FRAMES do
	local frame = _G["GroupLootFrame"..i]
	frame:ClearAllPoints()
	frame:SetScale(0.75)
	if i == 1 then
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOM", caelPanel3, "TOP", 0, 5)
	elseif i > 1 then
		frame:SetPoint("BOTTOM", "GroupLootFrame"..(i-1), "TOP", 0, 5)
	end
end

LootFrame:HookScript("OnShow", function(self)
	self:SetScale(0.85)
	self:SetClampedToScreen(false)
	self:ClearAllPoints()
	self:SetPoint("TOPRIGHT", UIParent, "RIGHT", 50, 50)
end)