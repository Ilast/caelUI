--[[	$Id$	]]

local _, caelDataFeeds = ...

function createModule()
    local fontString = caelPanel8:CreateFontString(nil, "OVERLAY")
    fontString:SetFont(caelMedia.files.fontRg, 10)

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetAllPoints(fontString)
	frame:EnableMouse(true)
	frame:SetScript("OnLeave", function() GameTooltip:Hide() end)

	return fontString, frame
end