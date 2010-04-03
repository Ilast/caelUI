--[[	$Id$	]]

local _, caelDataFeeds = ...

caelDataFeeds.createModule = function(name)

    -- Create module frame.
    local module = CreateFrame("Frame", format("caelDataFeedsModule%s", name), caelPanel8)
    
    -- Create module text.
    module.text = caelPanel8:CreateFontString(nil, "OVERLAY")
    module.text:SetFont(caelMedia.files.fontRg, 10)
    
    -- Setup module.
    module:SetAllPoints(module.text)
    module:EnableMouse(true)
    module:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return module
end