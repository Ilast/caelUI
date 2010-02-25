--[[	Relocating the group loot frames	]]
--[[
local frame = _G["GroupLootFrame1"]
frame:ClearAllPoints()
frame:SetPoint("BOTTOM", caelPanel3, "BOTTOM", 0, 175)
frame:SetScale(0.75)
for i = 2, NUM_GROUP_LOOT_FRAMES do
	frame = _G["GroupLootFrame" .. i]
	if i > 1 then
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOM", "GroupLootFrame" .. (i-1), "TOP", 0, 5)
		frame:SetFrameLevel(0)
		frame:SetScale(0.75)
	end
end
--]]
for i = 1, NUM_GROUP_LOOT_FRAMES do
	local frame = _G["GroupLootFrame"..i]
	frame:ClearAllPoints()
	frame:SetScale(0.75)
	if i == 1 then
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOM", caelPanel3, "BOTTOM", 0, 1)
	elseif i > 1 then
		frame:SetPoint("BOTTOM", "GroupLootFrame"..(i-1), "TOP", 0, 5)
	end
end