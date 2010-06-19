--[[	$Id$	]]

if UnitLevel("player") ~= MAX_PLAYER_LEVEL then return end

local _, caelDataFeeds = ...

caelDataFeeds.wgtimer = caelDataFeeds.createModule("WintergraspTimer")

local wgtimer = caelDataFeeds.wgtimer

wgtimer.text:SetPoint("BOTTOM", caelPanel3, "BOTTOM", 0, caelLib.scale(5))
wgtimer.text:SetParent(caelPanel3)

local delay = 0
wgtimer:SetScript("OnUpdate", function(self, elapsed)
	delay = delay - elapsed
	if delay < 0 then
		local inInstance, instanceType = IsInInstance()
--		if GetCurrentMapContinent() == 4 and IsInInstance() == nil then
--		if not (inInstance or instanceType == "pvp" or instanceType == "arena" or GetZonePVPInfo() == "combat") then
--		if not inInstance and (tostring(GetZoneText() ~= "Wintergrasp") or MiniMapBattlefieldFrame.status ~= "active") then
		if inInstance == nil then
			local nextBattleTime = SecondsToTime(GetWintergraspWaitTime())
			if nextBattleTime then
				self.text:SetFormattedText("|cffD7BEA5Wg in:|r %s", nextBattleTime)
			else
				self.text:SetText("|cffD7BEA5Wg in:|r progress")
			end
		else
			self.text:SetText("|cffD7BEA5Wg in:|r Unavailable")
		end
		delay = 1
	end
end)