local myName = UnitName("player")

local gsub, find, match, lower = string.gsub, string.find, string.match, string.lower

--[[	Filter npc spam	]]

local npcChannels = {
	"CHAT_MSG_MONSTER_SAY",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_MONSTER_EMOTE",
	}

local isNpcChat = function(self, event, msg)
	local isResting = IsResting()
	if isResting and not msg:find(myName) then
		return true
	else
		return false
	end
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

local IsSpam = function(self, event, msg)
	if find(msg, "%*%*%*") or find(msg, "%<%D%B%M%>") then 
		return true
	else
		return false
	end
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

local GmSpam = {}

GmSpam["nWelcomeLine"]    = "Bienvenue dans World of Warcraft !"
GmSpam["nGMSpamLine1"]    = "La mise à jour 3.3 est désormais disponible et la citadelle de la Couronne"
GmSpam["nGMSpamLine2"]    = "de glace vous attend !"
GmSpam["nGMSpamLine3"]    = "Joignez-vous à nous pour fêter le 5e anniversaire de World of Warcraft sur "
GmSpam["nGMSpamLine4"]    = "http://www.wow-europe.com/wowanniversary !"

local LoginSpamFilter = function(self, event, msg)
	for key, value in pairs(GmSpam) do
		if msg == value then
			return true
		end
	end
	return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", LoginSpamFilter)

--[[	Filter various crap	]]

local SystemMessageFilter = function(self, event, msg, ...)
	if msg:match("You have earned the title 'Patron Caellian'.") then return true end
	if msg:match("You have earned the title 'Matron Caellian'.") then return true end
	if msg:match("You have lost the title 'Patron Caellian'.") then return true end
	if msg:match("You have lost the title 'Matron Caellian'.") then return true end
	if msg:match("^(%S+) has come online%.") then return true end
	if msg:match("^(%S+) has gone offline%.") then return true end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SystemMessageFilter)

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

--[[	RaidNotice to Scrolling frame	]]

local hooks = {}
hooks["RaidNotice_AddMessage"] = RaidNotice_AddMessage

RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo, ...)
	if noticeFrame then
		if MikScrollingBattleText then
			MikSBT.DisplayMessage(textString, MikSBT.DISPLAYTYPE_NOTIFICATION, true, 140, 145, 155, 16, "neuropol x cd bd", 2)
		elseif RecScrollAreas then
			RecScrollAreas:AddText("|cffD7BEA5"..textString.."|r", true, "Notification") 
		else
			hooks.RaidNotice_AddMessage(noticeFrame, textString, colorInfo, ...)
		end
		PlaySoundFile([=[Interface\Addons\caelMedia\Sounds\alarm.mp3]=])
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