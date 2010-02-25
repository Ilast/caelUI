﻿local _, caelConfig = ...

--[[	Improved color picker frame	]]

caelConfig.events:RegisterEvent("PLAYER_LOGIN")
caelConfig.events:HookScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		local r, g, b
		local copy = CreateFrame("Button", nil, ColorPickerFrame, "UIPanelButtonTemplate")
		copy:SetPoint("BOTTOMLEFT", ColorPickerFrame, "TOPLEFT", 208, -110)
		copy:SetHeight(20)
		copy:SetWidth(80)
		copy:SetText("Copy")
		copy:SetScript("OnClick", function() r, g, b = ColorPickerFrame:GetColorRGB() end)

		local paste = CreateFrame("Button", nil, ColorPickerFrame, "UIPanelButtonTemplate")
		paste:SetPoint("BOTTOMLEFT", ColorPickerFrame, "TOPLEFT", 208, -135)
		paste:SetHeight(20)
		paste:SetWidth(80)
		paste:SetText("Paste")
		paste:SetScript("OnClick", function() ColorPickerFrame:SetColorRGB(r, g, b) end)
	end
end)