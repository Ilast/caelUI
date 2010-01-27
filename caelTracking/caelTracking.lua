local print = function(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffD7BEA5cael|rTracking: "..tostring(text))
end

if select(2, UnitClass("player")) ~= "HUNTER" then
	print("You are not a Hunter, caelTracking will be disabled on next UI reload.")
	return DisableAddOn("caelTracking")
end

local caelTracking = CreateFrame("Frame")
caelTracking:Hide()

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
		if select(2, UnitClass("player")) == "HUNTER" then
			SetTracking(nil)
		end
	end
end

caelTracking:RegisterEvent("ZONE_CHANGED_NEW_AREA")
caelTracking.ZONE_CHANGED_NEW_AREA = function(self)
	return ZoneChange(GetRealZoneText())
end

caelTracking:RegisterEvent("WORLD_MAP_UPDATE")
caelTracking.WORLD_MAP_UPDATE = function(self)
	local zone = GetRealZoneText()
	if zone and zone ~= "" then
		self:UnregisterEvent("WORLD_MAP_UPDATE")
		return ZoneChange(zone)
	end
end

local TrackingTypeToID, TrackingTypeToTexture
caelTracking:RegisterEvent("PLAYER_ENTERING_WORLD")
caelTracking.PLAYER_ENTERING_WORLD = function(self)
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

local timeleft
local OnUpdate = function(self, elapsed)
	timeleft = timeleft - elapsed
	if timeleft <= 0 then
		self:Hide()
		return self:UNIT_TARGET(nil, "player")
	end
end

caelTracking:RegisterEvent("UNIT_TARGET")
caelTracking.UNIT_TARGET = function(self, event, unit)
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

OnEvent = function(self, event, ...)
	if type(self[event]) == "function" then
		return self[event](self, event, ...)
	else
		print(string.format("Unhandled event: %s", event))
	end
end

caelTracking:SetScript("OnUpdate", OnUpdate)
caelTracking:SetScript("OnEvent", OnEvent)