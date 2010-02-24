local _, caelConfig = ...

--[[	Dungeons no more...	]]

caelConfig.events:RegisterEvent("ADDON_LOADED")
local requestUpdate = function(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon == "caelConfig" then
			RequestRaidInfo()
			requestUpdate = caelConfig.dummy
		end
	end
end
caelConfig.events:HookScript("OnEvent", requestUpdate)

caelConfig.events:RegisterEvent("UPDATE_INSTANCE_INFO")
local lockInstance = function(self, event)
	if event == "UPDATE_INSTANCE_INFO" then
		lockInstance = caelConfig.dummy
		for i = 1, GetNumSavedInstances() do
			local name, _, _, _, isLocked, isExtended = GetSavedInstanceInfo(i)

			if(name == "The Oculus" or name == "The Culling of Stratholme" and not(isLocked or isExtended)) then
				SetSavedInstanceExtend(i, true)
			end
		end
	end
end
caelConfig.events:HookScript("OnEvent", lockInstance)