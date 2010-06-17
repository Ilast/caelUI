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
shadowedge.tex:SetTexture([=[Interface\Addons\caelMedia\Miscellaneous\largeshadertex1]=])
shadowedge.tex:SetAllPoints()
shadowedge.tex:SetVertexColor(0, 0, 0, 0.75)
--[[
shadowedge:RegisterEvent("PLAYER_ENTERING_WORLD")
shadowedge:SetScript("OnEvent", function(self)
	self:SetAlpha(0.85)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)
--]]