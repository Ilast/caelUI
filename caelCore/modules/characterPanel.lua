--[[	$Id$	]]

local _, caelCore = ...

caelCore.characterpanel = caelCore.createModule("CharacterPanel")

local characterpanel = caelCore.characterpanel

local helm = characterpanel.helm
local cloak = characterpanel.cloak
local undress = characterpanel.undress

CharacterModelFrameRotateLeftButton:ClearAllPoints()
CharacterModelFrameRotateLeftButton:SetPoint("LEFT", PaperDollFrame, "LEFT", 70, 5)
    
CharacterModelFrameRotateRightButton:ClearAllPoints()
CharacterModelFrameRotateRightButton:SetPoint("RIGHT", PaperDollFrame, "RIGHT", -90, 5)

local ShowCloak, ShowHelm = ShowCloak, ShowHelm
_G.ShowCloak, _G.ShowHelm = caelCore.dummy, caelCore.dummy

for k, v in next, {InterfaceOptionsDisplayPanelShowCloak, InterfaceOptionsDisplayPanelShowHelm} do
	v:SetButtonState("DISABLED", true)
end

helm = CreateFrame("CheckButton", nil, PaperDollFrame, "OptionsCheckButtonTemplate")
helm:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", 7, 6)
helm:SetChecked(ShowingHelm())
helm:SetToplevel()
helm:RegisterEvent("PLAYER_FLAGS_CHANGED")
helm:SetScript("OnClick", function() ShowHelm(not ShowingHelm()) end)
helm:SetScript("OnEvent", function(self, event, unit)
	if(unit == "player") then
		self:SetChecked(ShowingHelm())
	end
end)
helm:SetScript("OnEnter", function(self)
 	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("Toggles helmet model.")
end)
helm:SetScript("OnLeave", function() GameTooltip:Hide() end)

cloak = CreateFrame("CheckButton", nil, PaperDollFrame, "OptionsCheckButtonTemplate")
cloak:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", 7, -15)
cloak:SetChecked(ShowingCloak())
cloak:SetToplevel()
cloak:RegisterEvent("PLAYER_FLAGS_CHANGED")
cloak:SetScript("OnClick", function() ShowCloak(not ShowingCloak()) end)
cloak:SetScript("OnEvent", function(self, event, unit)
	if(unit == "player") then
		self:SetChecked(ShowingCloak())
	end
end)
cloak:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("Toggles cloak model.")
end)
cloak:SetScript("OnLeave", function() GameTooltip:Hide() end)

undress = CreateFrame("Button", nil, DressUpFrame, "UIPanelButtonTemplate")
undress:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT")
undress:SetHeight(22)
undress:SetWidth(80)
undress:SetText("Undress")
undress:SetScript("OnClick", function() DressUpModel:Undress() end)