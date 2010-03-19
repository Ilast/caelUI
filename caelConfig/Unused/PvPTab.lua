--[[	$Id: PvPTab.lua 515 2010-03-06 16:33:44Z sdkyron@gmail.com $	]]

CharacterFrameTab3:SetWidth(57)
CharacterFrameTab3Middle:SetWidth(17)
CharacterFrameTab3Text:SetText("Rep")
CharacterFrameTab5:SetWidth(75)
CharacterFrameTab5Middle:SetWidth(35)
CharacterFrameTab5Text:SetText("Tokens")

CHARACTERFRAME_SUBFRAMES[#CHARACTERFRAME_SUBFRAMES+1] = "PVPFrame"

local pvptab = CreateFrame("Button", "CharacterFrameTab6", CharacterFrame, "CharacterFrameTabButtonTemplate")
pvptab:SetID(6)
pvptab:SetText(PVP)

CharacterFrameTab6LeftDisabled:Hide()
CharacterFrameTab6MiddleDisabled:Hide()
CharacterFrameTab6RightDisabled:Hide()

PVPFrame:SetParent("CharacterFrame")

pvptab:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(MicroButtonTooltipText(PVP, "TOGGLEPVP"), 1, 1, 1)
end)

pvptab:SetScript("OnLeave", function(self)
	GameTooltip:Hide()
end)

hooksecurefunc("CharacterFrame_OnLoad", function(...)
	PanelTemplates_SetNumTabs(CharacterFrame, #CHARACTERFRAME_SUBFRAMES)
end)

hooksecurefunc("CharacterFrameTab_OnClick", function(self, button)
	if self:GetName() == "CharacterFrameTab6" then
		ToggleCharacter("PVPFrame")
	end
end)

CharacterFrame:HookScript("OnHide", function()
	if PVPFrame:IsShown() then
		HideUIPanel(PVPFrame)
	end
end)

hooksecurefunc("ToggleCharacter", function(tab)
	for i = 1, #CHARACTERFRAME_SUBFRAMES - 1 do
		if _G["CharacterFrameTab"..i]:IsShown() then
			pvptab:SetPoint("LEFT", "CharacterFrameTab"..i, "RIGHT", -15, 0)
		end
	end
	if tab == "PVPFrame" then
		CharacterNameFrame:Hide()
		PanelTemplates_SelectTab(CharacterFrameTab6)
		PVPFrame:ClearAllPoints()
		PVPFrame:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", 0, 0)
	else
		CharacterNameFrame:Show()
		PanelTemplates_DeselectTab(CharacterFrameTab6)
	end
end)

hooksecurefunc("ToggleFrame", function(frame) 
	if frame == PVPFrame then 
		if CharacterFrame:IsShown() and not CharacterNameFrame:IsShown() then
			HideUIPanel(CharacterFrame)
		else
			HideUIPanel(PVPFrame)
			ToggleCharacter("PVPFrame")
		end
	end 
end)