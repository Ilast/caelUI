--[[	$Id$	]]

local playerName = UnitName("player")
local playerFaction
local targets = {}

local caelEmote = CreateFrame("Frame")
caelEmote:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

function caelEmote:PLAYER_ENTERING_WORLD()
	playerFaction = UnitFactionGroup("player")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end
caelEmote:RegisterEvent("PLAYER_ENTERING_WORLD")

function caelEmote:COMBAT_LOG_EVENT_UNFILTERED(timestamp, subevent, sourceGUID, sourceName, sourceFlags, destGUID, destName)
	if subevent == "PARTY_KILL" then
		local dashPos = destName:find("-")
		if dashPos then
			destName = destName:sub(0, dashPos - 1)
		end
		if targets[destName] then
			if sourceName == playerName then
				DoEmote("GLOAT", destName)
				PlaySoundFile([=[Interface\Addons\caelMedia\Sounds\godlike.mp3]=])
			end
			targets[destName] = nil
		end
	end
end
caelEmote:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

function caelEmote:PLAYER_TARGET_CHANGED()
	if UnitExists("target") and UnitIsPlayer("target") and UnitIsEnemy("player", "target") and UnitFactionGroup("target") ~= playerFaction then
		targets[UnitName("target")] = true
	end
end
caelEmote:RegisterEvent("PLAYER_TARGET_CHANGED")