local print = function(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffD7BEA5cael|rTracking: "..tostring(text))
end

if select(2, UnitClass("player")) ~= "HUNTER" then
	print("You are not a Hunter, caelTracking will be disabled on next UI reload.")
	return DisableAddOn("caelTracking")
end

local caelTracking = CreateFrame("Frame")
caelTracking:Hide()
caelTracking:SetScript("OnEvent", function(self, event, ...)
	return self[event](self, event, ...)
end)

local cities = {
	["Dalaran"] = true,
	["Orgrimmar"] = true,
	["Shattrath City"] = true,
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

function caelTracking:ZONE_CHANGED_NEW_AREA()
	local zone = GetRealZoneText()
	return ZoneChange(zone)
end
caelTracking:RegisterEvent("ZONE_CHANGED_NEW_AREA")

function caelTracking:WORLD_MAP_UPDATE()
	local zone = GetRealZoneText()
	if zone and zone ~= "" then
		self:UnregisterEvent("WORLD_MAP_UPDATE")
		return ZoneChange(zone)
	end
end
caelTracking:RegisterEvent("WORLD_MAP_UPDATE")

local TrackingTypeToID, TrackingTypeToTexture
function caelTracking:PLAYER_ENTERING_WORLD(event)
	TrackingTypeToID = {}
	TrackingTypeToTexture = {}
	for i=1, GetNumTrackingTypes() do
		local name, tex, smth, type = GetTrackingInfo(i)
		if type == "spell" then
			name = name:match("Track (.-)s?$")
			if name then
				TrackingTypeToID[name] = i
				TrackingTypeToTexture[name] = tex
			end
		end
	end
end
caelTracking:RegisterEvent("PLAYER_ENTERING_WORLD")

local timeleft
caelTracking:SetScript("OnUpdate", function(self, elapsed)
	timeleft = timeleft - elapsed
	if timeleft <= 0 then
		self:Hide()
		return self:UNIT_TARGET(nil, "player")
	end
end)

function caelTracking:UNIT_TARGET(event, unit)
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
caelTracking:RegisterEvent("UNIT_TARGET")