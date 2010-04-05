--[[	$Id$	]]

local gsub, find, match, lower = string.gsub, string.find, string.match, string.lower

--[[	Filter npc spam	]]

local npcChannels = {
	"CHAT_MSG_MONSTER_SAY",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_MONSTER_EMOTE",
	}

local isNpcChat = function(self, event, ...)
	local msg = ...
	local isResting = IsResting()
	if isResting and not msg:find(caelLib.playerName) then
		return true, ...
	end
	return false, ...
end

for i,v in ipairs(npcChannels) do
	ChatFrame_AddMessageEventFilter(v, isNpcChat)
end

--[[	Filter bossmods	]]

local filteredchannels = {
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_WHISPER",
	}

local IsSpam = function(self, event, ...)
	local msg = ...
	if msg:find("%*%*%*") or msg:find("%<%D%B%M%>") or msg:find("%<%B%W%>") then 
		return true, ...
	end
	return false, ...
end

for i, v in ipairs(filteredchannels) do
	ChatFrame_AddMessageEventFilter(v, IsSpam)
end

RaidWarningFrame:SetScript("OnEvent", function(self, event, msg)
	if event == "CHAT_MSG_RAID_WARNING" then
		if not msg:find("%*%*%*", 1, false) then
			RaidWarningFrame_OnEvent(self, event, msg)
		end 
	end
end)

--[	Filter channels join/leave	]

local eventsNotice = {
	"CHAT_MSG_CHANNEL_JOIN",
	"CHAT_MSG_CHANNEL_LEAVE",
	"CHAT_MSG_CHANNEL_NOTICE",
	"CHAT_MSG_CHANNEL_NOTICE_USER",
	}

local SuppressNotices = function()
	return true
end

for i,v in ipairs(eventsNotice) do
	ChatFrame_AddMessageEventFilter(v, SuppressNotices)
end

--[[  Filter login spam	]]

local Spam = {
	[1] = "Bienvenue dans World of Warcraft !",
	[2] = "Nous nous préoccupons de la sécurité des joueurs et vous",
	[3] = "encourageons à consulter le site http://eu.battle.net/security",
	[4] = "pour de plus amples astuces et informations à ce sujet.",
	[5] = "You have .+ the title '.atron Caellian'%.",
	[6] = "^(%S+) has come online%.",
	[7] = "^(%S+) has gone offline%.",
}

local SystemMessageFilter = function(self, event, ...)
	local msg = ...
	for _, pattern in pairs(Spam) do
		if msg:find(pattern) then
			return true, ...
		end
	end

	return false, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SystemMessageFilter)

--[[	Filter various crap	]]
--[[
local craps = {
	"%[.*%].*anal",
	"anal.*%[.*%]",
}

local FilterFunc = function(_, _, msg, userID, _, _, _, _, chanID)
	if userID == UnitName("Player") then return false end
	
	if chanID == 1 or chanID == 2 then
		msg = lower(msg) --lower all text
		msg = gsub(msg, " ", "") --Remove spaces
		for i, v in ipairs(craps) do
			if find(msg, v) then
				return true
			end
		end
	end
	return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FilterFunc)
--]]
--[[	RaidNotice to Scrolling frame	]]

local hooks = {}
hooks["RaidNotice_AddMessage"] = RaidNotice_AddMessage

RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo, ...)
	if noticeFrame then
		if MikScrollingBattleText then
			MikSBT.DisplayMessage(textString, MikSBT.DISPLAYTYPE_NOTIFICATION, true, 140, 145, 155, 16, "neuropol x cd bd", 2)
		elseif recScrollAreas then
			recScrollAreas:AddText("|cffD7BEA5"..textString.."|r", true, "Notification") 
		else
			hooks.RaidNotice_AddMessage(noticeFrame, textString, colorInfo, ...)
		end
		PlaySoundFile(caelMedia.files.soundAlarm)
	end
end

--[[	Bosses & monsters emotes to RWF	]]
--[[
chatFrames:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
chatFrames.CHAT_MSG_RAID_BOSS_EMOTE = function(self, event, arg1, arg2)
	local string = format(arg1, arg2)
	RaidNotice_AddMessage(RaidWarningFrame, string, ChatTypeInfo["RAID_WARNING"])
end
--]]