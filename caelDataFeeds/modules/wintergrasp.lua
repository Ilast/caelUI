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

		if inInstance == nil then
			if GetWintergraspWaitTime() == nil then
				self.text:SetText("|cffD7BEA5wg:|r In progress")
			else
				local nextBattleTime = SecondsToTime(GetWintergraspWaitTime())
				if nextBattleTime then
					self.text:SetFormattedText("|cffD7BEA5wg:|r %s", nextBattleTime)
				end
			end
		else
			self.text:SetText("|cffD7BEA5wg:|r Unavailable")
		end
		delay = 1
	end
end)