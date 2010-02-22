--[[	Dungeons no more...	]]

caelTweaks:RegisterEvent("ADDON_LOADED")
caelTweaks.ADDON_LOADED = function(self, event, addon)
	if(addon == "caelTweaks") then
		RequestRaidInfo()

		self:UnregisterEvent(event, ADDON_LOADED)
	end
end

caelTweaks:RegisterEvent("UPDATE_INSTANCE_INFO")
caelTweaks.UPDATE_INSTANCE_INFO = function(self, event)
	self:UnregisterEvent("UPDATE_INSTANCE_INFO", UPDATE_INSTANCE_INFO)
	for i = 1, GetNumSavedInstances() do
		local name, _, _, _, lock, extend = GetSavedInstanceInfo(i)

		if(name == "The Oculus" or name == "The Culling of Stratholme" and not(lock or extend)) then
			return SetSavedInstanceExtend(i, true)
		end
	end
end