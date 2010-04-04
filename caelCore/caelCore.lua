﻿--[[	$Id$	]]

local _, caelCore = ...

caelCore.dummy = function() end

caelCore.createModule = function(name)

    -- Create module frame.
    local module = CreateFrame("Frame", format("caelCoreModule%s", name), UIParent)
    
    return module
end