--[[	$Id$	]]

if select(2, UnitClass("player")) ~= "HUNTER" then
	print("|cffD7BEA5cael|rTracking: You are not a Hunter, caelTracking will be disabled on next UI reload.")
	return DisableAddOn("caelTracking")
end

local _, caelTracking = ...

caelTracking.eventFrame = CreateFrame("Frame", nil, UIParent)

local cities = {
--	["Darnassus"] = true,
--	["Ironforge"] = true,
--	["Stormwind City"] = true,
--	["The Exodar"] = true,

	["Dalaran"] = true,
	["Shattrath City"] = true,

	["Orgrimmar"] = true,
	["Silvermoon City"] = true,
	["Thunder Bluff"] = true,
	["Undercity"] = true,
}

local ZoneChange = function(zone)
	if cities[zone] then
--		if select(2, UnitClass("player")) == "HUNTER" then
			SetTracking(nil)
--		end
	end
end

caelTracking.eventFrame:RegisterEvent("WORLD_MAP_UPDATE")
caelTracking.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
caelTracking.eventFrame:SetScript("OnEvent", function(self, event)
	if event == "WORLD_MAP_UPDATE" or event == "ZONE_CHANGED_NEW_AREA" then
		local zone = GetRealZoneText()
		if zone and zone ~= "" then
			return ZoneChange(zone)
		end
	end
end)

local TrackingTypeToID, TrackingTypeToTexture
caelTracking.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelTracking.eventFrame:HookScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		TrackingTypeToID = {}
		TrackingTypeToTexture = {}
		for i = 1, GetNumTrackingTypes() do
			local name, tex, _, type = GetTrackingInfo(i)
			if type == "spell" then
				name = name:match("Track (.-)s?$")
				if name then
					TrackingTypeToID[name] = i
					TrackingTypeToTexture[name] = tex
				end
			end
		end
		return ZoneChange(GetRealZoneText())
	end
end)

local function unitTarget(self, event, unit)
	if event == "UNIT_TARGET" then
		if unit == "player" and UnitCanAttack("player", "target") and not UnitIsDead("target") then
			local targettype = UnitCreatureType("target")
			if GetTrackingTexture() ~= TrackingTypeToTexture[targettype] then
				local id = TrackingTypeToID[targettype]
				if id then
					local start, duration = GetSpellCooldown((GetTrackingInfo(id)))
					if start ~= 0 then
						timeleft = start-GetTime()+duration
						self:Show()
						return
					end
					SetTracking(id)
				end
			end
		end
	end
end

local timeleft = 0
caelTracking.eventFrame:SetScript("OnUpdate", function(self, elapsed)
	timeleft = timeleft - elapsed
	if timeleft <= 0 then
		self:Hide()
		return unitTarget(self, "UNIT_TARGET", "player")
	end
end)

caelTracking.eventFrame:RegisterEvent("UNIT_TARGET")
caelTracking.eventFrame:HookScript("OnEvent", unitTarget)