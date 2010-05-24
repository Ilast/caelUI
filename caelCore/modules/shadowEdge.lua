--[[	$Id$	]]

local _, caelCore = ...

--[[	Put a shadow edge around the screen	]]

caelCore.shadowedge = caelCore.createModule("ShadowEdge")

local shadowedge = caelCore.shadowedge

shadowedge:SetPoint("TOPLEFT")
shadowedge:SetPoint("BOTTOMRIGHT")
shadowedge:SetFrameLevel(0)
shadowedge:SetFrameStrata("BACKGROUND")
shadowedge.tex = shadowedge:CreateTexture()
shadowedge.tex:SetTexture([=[Interface\Addons\caelMedia\Miscellaneous\shadow.tga]=])
shadowedge.tex:SetAllPoints()

shadowedge:RegisterEvent("PLAYER_ENTERING_WORLD")
shadowedge:SetScript("OnEvent", function(self)
	self:SetAlpha(0.85)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)