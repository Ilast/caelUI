--[[	Relocating the group loot frames	]]

local frame = _G["GroupLootFrame1"]
frame:ClearAllPoints()
--frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 1.5, 169)
frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 152)
--frame:SetFrameLevel(0)
frame:SetScale(.75)
for i = 2, NUM_GROUP_LOOT_FRAMES do
	frame = _G["GroupLootFrame" .. i]
	if i > 1 then
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOM", "GroupLootFrame" .. (i-1), "TOP", 0, 5)
		frame:SetFrameLevel(0)
		frame:SetScale(.75)
	end
end