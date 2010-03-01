local _, caelConfig = ...
caelConfig.events = CreateFrame("Frame")

caelConfig.dummy = function() end

--caelConfig.events:RegisterEvent("PLAYER_ENTERING_WORLD")
--caelConfig.events:SetScript("OnEvent", function() collectgarbage("collect") end)