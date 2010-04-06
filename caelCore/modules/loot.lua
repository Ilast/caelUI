--[[	$Id$	]]

-- Move/scale loot frames each time they get shown.
local function onShow(self, ...)
    self:ClearAllPoints()
    if self:GetName() == "GroupLootFrame1" then
        self:SetPoint("BOTTOM", caelPanel3, "TOP", 0, 5)
    else
        local _, _, num = self:GetName():find("GroupLootFrame(%d)")
        self:SetPoint("BOTTOM", _G[string.format("GroupLootFrame%d", num-1)], "TOP", 0, 5)
    end
    self:SetScale(.75)

    if self.onShow then
        self:onShow(...)
    end
end

-- Hook our override function into each loot frame.
for i = 1, NUM_GROUP_LOOT_FRAMES do
    local frame = _G["GroupLootFrame"..i]
    frame.onShow = frame:GetScript("OnShow")
    frame:SetScript("OnShow", onShow)
end

LootFrame:HookScript("OnShow", function(self)
	self:SetScale(0.85)
	self:SetClampedToScreen(false)
	self:ClearAllPoints()
	self:SetPoint("TOPRIGHT", UIParent, "RIGHT", 50, 50)
end)