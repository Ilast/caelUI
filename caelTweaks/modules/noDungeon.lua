local _, caelTweaks = ...

--[[	Dungeons no more...	]]

caelTweaks.events:RegisterEvent("ADDON_LOADED")
local requestUpdate = function(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon == "caelTweaks" then
			RequestRaidInfo()
			requestUpdate = caelTweaks.dummy
		end
	end
end
caelTweaks.events:HookScript("OnEvent", requestUpdate)

caelTweaks.events:RegisterEvent("UPDATE_INSTANCE_INFO")
local lockInstance = function(self, event)
	if event == "UPDATE_INSTANCE_INFO" then
		lockInstance = caelTweaks.dummy
		for i = 1, GetNumSavedInstances() do
			local name, _, _, _, isLocked, isExtended = GetSavedInstanceInfo(i)

			if(name == "The Oculus" or name == "The Culling of Stratholme" and not(isLocked or isExtended)) then
				SetSavedInstanceExtend(i, true)
			end
		end
	end
end
caelTweaks.events:HookScript("OnEvent", lockInstance)