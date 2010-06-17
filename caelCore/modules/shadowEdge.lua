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
shadowedge.tex:SetVertexColor(0, 0, 0, 0.5)

shadowedge:RegisterEvent("UNIT_HEALTH")
shadowedge:SetScript("OnEvent", function(self, event, unit)
	if (unit ~= "player") then return end

	local currentHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	local healthPercent = (currentHealth/maxHealth)

	if (currentHealth > 0 and healthPercent < 0.25) then
		shadowedge.tex:SetVertexColor(0.69, 0.31, 0.31, 0.5)
	elseif (healthPercent > 0.25 and healthPercent < 0.5)then
		shadowedge.tex:SetVertexColor(0.65, 0.63, 0.35, 0.5)
	else
		shadowedge.tex:SetVertexColor(0, 0, 0, 0.5)
	end
end)