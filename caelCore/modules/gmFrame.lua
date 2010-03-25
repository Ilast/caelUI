--[[	$Id$	]]

local _, caelCore = ...

--[[	GM chat frame enhancement	]]

caelCore.events:RegisterEvent("ADDON_LOADED")
local enhanceGMFrame = function(self, event, name)
	if (event ~= "ADDON_LOADED") or (name ~= "Blizzard_GMChatUI") then return end

	GMChatFrame:EnableMouseWheel()
	GMChatFrame:SetScript("OnMouseWheel", ChatFrame1:GetScript("OnMouseWheel"))
	GMChatFrame:ClearAllPoints()
	GMChatFrame:SetHeight(ChatFrame1:GetHeight())
	GMChatFrame:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 48)
	GMChatFrame:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 0, 48)
	GMChatFrameCloseButton:ClearAllPoints()
	GMChatFrameCloseButton:SetPoint("TOPRIGHT", GMChatFrame, "TOPRIGHT", 7, 8)
	GMChatFrameUpButton:Hide()
	GMChatFrameDownButton:Hide()
	GMChatFrameBottomButton:Hide()
	GMChatTab:Hide()

	enhanceGMFrame = caelCore.dummy
end
caelCore.events:HookScript("OnEvent", enhanceGMFrame)