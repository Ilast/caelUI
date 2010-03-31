--[[	$Id$	]]

local _, caelBossWhisperer = ...

caelBossWhisperer.eventFrame = CreateFrame("Frame", nil, UIParent)

local inCombat = nil
local dndBanner = "<caelBossWhisperer> "

local dndString = dndBanner .. "I'm busy fighting %s (currently at %d%% with %d/%d players alive). You'll be notified when combat ends."
--local combatEndedString = dndBanner .. "Combat ended after %d minutes."
local combatEndedString = dndBanner .. "Combat against %s ended %safter %d minutes."

local whisperers = {}
local combatStart = nil
local boss = nil
local bossHp = nil
local totalElapsed = 0

local playerName = UnitName("player")

local bannerTest = "^" .. dndBanner
local is31 = GetNumTalentGroups and true or nil
local outgoingFilter, incomingFilter

if is31 then
	outgoingFilter = function(self, event, msg, ...)
		if msg:find(bannerTest) then return true end
	end
else
	outgoingFilter = function()
		if arg1:find(bannerTest) then return true end
	end
end

if is31 then
	incomingFilter = function(self, event, msg, ...)
		if not boss then return end
		local sender = ...
		local gm = select(5, ...)

		if type(sender) ~= "string" or sender == playerName or
		  (UnitExists("target") and UnitName("target") == sender) or UnitInRaid(sender) or
		  (type(gm) == "string" and gm == "GM") then return false, msg, ... end

		if not whisperers[sender] or whisperers[sender] == 1 or msg == "status" then
			-- Let him know we are fighting a boss
			whisperers[sender] = 2

			local total = GetNumRaidMembers()
			local alive = 0
			for i = 1, total do
				if not UnitIsDeadOrGhost(GetRaidRosterInfo(i)) then alive = alive + 1 end
			end
			SendChatMessage(dndString:format(boss, bossHp, alive, total), "WHISPER", nil, sender)
		end
	end
else
	incomingFilter = function()
		if not boss then return end

		if type(arg2) ~= "string" or arg2 == playerName or
		  (UnitExists("target") and UnitName("target") == arg2) or UnitInRaid(arg2) or
		  (type(arg6) == "string" and arg6 == "GM") then return end

		if not whisperers[arg2] or whisperers[arg2] == 1 or arg1 == "status" then
			-- Let him know we are fighting a boss
			whisperers[arg2] = 2

			local total = GetNumRaidMembers()
			local alive = 0
			for i = 1, total do
				if not UnitIsDeadOrGhost(GetRaidRosterInfo(i)) then alive = alive + 1 end
			end
			SendChatMessage(dndString:format(boss, bossHp, alive, total), "WHISPER", nil, arg2)
		end
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", incomingFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", outgoingFilter)

local checkTarget = function(id)
	return UnitExists(id) and UnitAffectingCombat(id) and UnitClassification(id) == "worldboss"
end

local scan = function()
	if checkTarget("target") then return "target" end
	if checkTarget("focus") then return "focus" end
	if UnitInRaid("player") then
		for i = 1, GetNumRaidMembers() do
			if checkTarget("raid"..i.."target") then return "raid"..i.."target" end
		end
	else
		for i = 1, 5 do
			if checkTarget("party"..i.."target") then return "party"..i.."target" end
		end
	end
end

local updateBossTarget = function()
	local target = scan()
	if not target then return end
	if not boss then
		caelBossWhisperer.eventFrame:RegisterEvent("UNIT_HEALTH")
	end
	boss = UnitName(target)
	bossHp = floor(UnitHealth(target) / UnitHealthMax(target) * 100 + 0.5)
end

local caelBossWhisperer_OnUpdate = function(self, elapsed)
	totalElapsed = totalElapsed + elapsed
	if totalElapsed > 1 then
		local t = scan()
		if t then totalElapsed = 0; return end
		self:SetScript("OnUpdate", nil)

		local time = GetTime() - combatStart
--		local msg = combatEndedString:format(math.floor(time / 60))
		local msg = combatEndedString:format(boss, math.floor(time / 60), (alive and alive > 0) and "" or "with a wipe ")
		for k, v in pairs(whisperers) do
			-- Notify people that combat has ended
			SendChatMessage(msg, "WHISPER", nil, k)
			whisperers[k] = nil
		end
		combatStart = nil
		if boss then
			self:UnregisterEvent("UNIT_HEALTH")
			boss = nil
			bossHp = nil
		end
		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	end
end

caelBossWhisperer.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
caelBossWhisperer.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
caelBossWhisperer.eventFrame:SetScript("OnEvent", function(self, event, msg)
	if event == "PLAYER_REGEN_DISABLED" then
		local _, instanceType = IsInInstance()
		if instanceType ~= "raid" then return end
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:SetScript("OnUpdate", nil)
		totalElapsed = 0
		combatStart = GetTime()
		updateBossTarget()
	elseif event == "PLAYER_TARGET_CHANGED" then
		updateBossTarget()
	elseif event == "PLAYER_REGEN_ENABLED" then
		if combatStart then
			self:SetScript("OnUpdate", caelBossWhisperer_OnUpdate)
		end
	elseif event == "UNIT_HEALTH" and msg and UnitName(msg) == boss then
		bossHp = floor(UnitHealth(msg) / UnitHealthMax(msg) * 100 + 0.5)
		-- Allow new status whispers every 10%
		if bossHp % 10 == 0 then
			for k in pairs(whisperers) do
				whisperers[k] = 1
			end
		end
	end
end)