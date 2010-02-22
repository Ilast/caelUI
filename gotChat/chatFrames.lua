local chatFrames = CreateFrame("Frame")

CHAT_TELL_ALERT_TIME = 0 -- sound on every whisper
DEFAULT_CHATFRAME_ALPHA = 0 -- remove mouseover background

local print = function(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffD7BEA5cael|rChat: "..tostring(text))
end

local myName = UnitName("player")
local _, myClass = UnitClass("player")
local gsub, find, match, lower = string.gsub, string.find, string.match, string.lower

local ChatFrameEditBox = ChatFrameEditBox
ChatFrameEditBox:SetAltArrowKeyMode(nil)
ChatFrameEditBox:ClearAllPoints()
ChatFrameEditBox:SetHeight(30)
ChatFrameEditBox:SetPoint("BOTTOMLEFT",  ChatFrame1, "TOPLEFT", -4.5, 7)
ChatFrameEditBox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 5, 7)
ChatFrameEditBox:SetFontObject(neuropolrg12)
ChatFrameEditBox:SetBackdrop {bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\Addons\caelMedia\Miscellaneous\glowtex]=], edgeSize = 2,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
}
ChatFrameEditBox:SetBackdropColor(0, 0, 0, 0.5)
ChatFrameEditBox:SetBackdropBorderColor(0, 0, 0)
ChatFrameEditBoxHeader:SetFontObject(neuropolrg12)

local gradient = ChatFrameEditBox:CreateTexture(nil, "BORDER")
gradient:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
gradient:SetPoint("TOP", ChatFrameEditBox, 0, -2)
gradient:SetPoint("LEFT", ChatFrameEditBox, 2, 0)
gradient:SetPoint("RIGHT", ChatFrameEditBox, -2, 0)
gradient:SetPoint("BOTTOM", ChatFrameEditBox, 0, 2)
gradient:SetBlendMode("ADD")
gradient:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0.55, 0.57, 0.61, 0.25)

local mergedTable = {
--	coloredChats values only
	[0] = "CHANNEL5",
	
--	Values which coloredChats and messageGroups have in common.
	[1] = "SAY",
	[2] = "EMOTE",
	[3] = "YELL",
	[4] = "GUILD",
	[5] = "GUILD_OFFICER",
	[6] = "GUILD_ACHIEVEMENT",
	[7] = "WHISPER",
	[8] = "PARTY",
	[9] = "PARTY_LEADER",
	[10] = "RAID",
	[11] = "RAID_LEADER",
	[12] = "RAID_WARNING",
	[13] = "BATTLEGROUND",
	[14] = "BATTLEGROUND_LEADER",
	[15] = "ACHIEVEMENT",
	
--	messageGroups only.
	[16] = "MONSTER_SAY",
	[17] = "MONSTER_EMOTE",
	[18] = "MONSTER_YELL",
	[19] = "MONSTER_WHISPER",
	[20] = "MONSTER_BOSS_EMOTE",
	[21] = "MONSTER_BOSS_WHISPER",
	[22] = "BG_HORDE",
	[23] = "BG_ALLIANCE",
	[24] = "BG_NEUTRAL",
	[25] = "SYSTEM",
	[26] = "ERRORS",
	[27] = "IGNORED",
	[28] = "CHANNEL",
}

chatFrames:RegisterEvent("ADDON_LOADED")
chatFrames.ADDON_LOADED = function(self, event, ...)
	if ... == "Blizzard_CombatLog" then
		chatFrames:UnregisterEvent("ADDON_LOADED")
		for i = 1, NUM_CHAT_WINDOWS do 
			local frame = _G["ChatFrame"..i]
			local dockHighlight = _G["ChatFrame"..i.."TabDockRegionHighlight"]

			frame:SetFading(true)
			frame:SetFadeDuration(5)
			frame:SetTimeVisible(20)

			dockHighlight:Hide()

			ChatFrame_RemoveAllChannels(frame)
			ChatFrame_RemoveAllMessageGroups(frame)

			if(i == 1) then
				FCF_SetWindowName(frame, "• Gen •")
				frame:ClearAllPoints()
				frame:SetHeight(115)
				frame:SetWidth(311.5)
				frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 401, 29.5)
				frame:SetMaxLines(1000)
				frame.SetPoint = function() end
				for i = 0, 28 do
					if i < 16 then -- Everything up to 15
						ToggleChatColorNamesByClassGroup(true, mergedTable[i])
					end
					if i > 0 then -- Everything except index 0
						ChatFrame_AddMessageGroup(frame, mergedTable[i])
					end
				end
			elseif(i == 2) then
				FCF_SetWindowName(frame, "• Log •")
				FCF_UnDockFrame(frame)
				frame:ClearAllPoints()
				frame:SetHeight(89)
				frame:SetWidth(309.5)
				frame:SetPoint("BOTTOM", UIParent, "BOTTOM", -401, 29.5)
				frame.SetPoint = function() end
				FCF_SetTabPosition(frame, 0)
				frame:SetJustifyH"RIGHT"
				frame:Hide()
				frame:UnregisterEvent("COMBAT_LOG_EVENT")
			elseif(i == 3) then
				FCF_SetWindowName(frame, "• w <-> •")
				FCF_DockFrame(frame, 2)
				ChatFrame_AddMessageGroup(frame, "WHISPER")
			elseif(i == 4) then
				FCF_SetWindowName(frame, "• Loot •")
				FCF_DockFrame(frame, 3)
				ChatFrame_AddMessageGroup(frame, "LOOT")
				ChatFrame_AddMessageGroup(frame, "MONEY")
			else
				FCF_Close(frame)
			end

			if i < 5 then
				FCF_SetChatWindowFontSize(nil, frame, 9)
				FCF_SetWindowColor(frame, 0, 0, 0)
				FCF_SetWindowAlpha(frame, 0)
				frame:SetFrameStrata("LOW")
				FCF_SetLocked(frame, 1)
				if i ~= 2 then frame:Show() end
			end
		end
	end
end

local chatStuff = function()
	local _, instanceType = IsInInstance()
	if instanceType ~= "raid" then
		ChatFrame_AddChannel(ChatFrame1, "General")
		ChatFrame_AddChannel(ChatFrame1, "Trade")
	else
		ChatFrame_RemoveChannel(ChatFrame1, "General")
	end
end

local delay1 = 5
local delay2 = 10
chatFrames:RegisterEvent("PLAYER_ENTERING_WORLD")
local OnUpdate = function(self, elapsed)
	if delay1 then
		delay1 = delay1 - elapsed
		if delay1 <= 0 then
			for i = 1, NUM_CHAT_WINDOWS do
				local frame = _G["ChatFrame"..i]
				if(i == 1) then
					chatStuff()
				end
			end
			delay1 = nil -- This stops the OnUpdate for this timer.
		end
	end
--[[
	if delay2 then
		delay2 = delay2 - elapsed
		if delay2 <= 0 then
			for i = 1, NUM_CHAT_WINDOWS do
				local frame = _G["ChatFrame"..i]
				if(i == 1) then
					ChangeChatColor("CHANNEL1", 0.55, 0.57, 0.61)
					ChangeChatColor("CHANNEL2", 0.55, 0.57, 0.61)
					ChangeChatColor("CHANNEL5", 0.84, 0.75, 0.65)
					if myClass == "HUNTER" and myName == "Caellian" then
						JoinTemporaryChannel("GICaster")
						ChatFrame_AddChannel(frame, "GICaster")
						ChangeChatColor("CHANNEL5", 0.67, 0.83, 0.45)
					end
				end
				ChangeChatColor("WHISPER", 0.3, 0.6, 0.9)
				ChangeChatColor("WHISPER_INFORM", 0.3, 0.6, 0.9)
			end
			print("Chatframes setup complete")
			self:SetScript("OnUpdate", nil) -- Done now, nil the OnUpdate completely.
		end
	end
--]]
	if delay2 then
		delay2 = delay2 - elapsed
		if delay2 <= 0 then
			ChangeChatColor("CHANNEL1", 0.55, 0.57, 0.61)
			ChangeChatColor("CHANNEL2", 0.55, 0.57, 0.61)
			ChangeChatColor("CHANNEL5", 0.84, 0.75, 0.65)
			ChangeChatColor("WHISPER", 0.3, 0.6, 0.9)
			ChangeChatColor("WHISPER_INFORM", 0.3, 0.6, 0.9)
			if myClass == "HUNTER" and myName == "Caellian" then
				JoinTemporaryChannel("GICaster")
				ChatFrame_AddChannel(_G.ChatFrame1, "GICaster")
				ChangeChatColor("CHANNEL5", 0.67, 0.83, 0.45)
			end
			print("Chatframes setup complete")
			self:SetScript("OnUpdate", nil) -- Done now, nil the OnUpdate completely.
		end
	end
end

local first = true
function chatFrames:PLAYER_ENTERING_WORLD(event)
	chatStuff()

	if first then
		chatFrames:SetScript("OnUpdate", OnUpdate)
		first = nil
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

--[[	Filter npc spam	]]

local npcChannels = {
	"CHAT_MSG_MONSTER_SAY",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_MONSTER_EMOTE",
	}
--[[
local isNpcChat = function(self, event, ...)
	local text = ...
	local isResting = IsResting()
	if isResting and not text:find(myName) then
		return true, ...
	end
	return false, ...
end
--]]
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
--[[
local IsSpam = function(self, event, ...)
	local text = ...
	if find(text, "%*%*%*") or find(text, "%<%D%B%M%>") then
		return true, ...
	end
	return false, ...
end
--]]
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

local function LoginSpamFilter(self, event, ...)
	local message = ...
	for key, value in pairs(GmSpam) do
		if message == value then
			return true, ...
		end
	end
	return false, ...
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

local function FilterFunc(_, _, msg, userID, _, _, _, _, chanID, ...)
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

OnEvent = function(self, event, ...)
	if type(self[event]) == 'function' then
		return self[event](self, event, ...)
	else
		print(string.format("Unhandled event: %s", event))
	end
end

chatFrames:SetScript("OnEvent", OnEvent)