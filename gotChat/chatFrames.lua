local chatFrames = CreateFrame("Frame")

CHAT_TELL_ALERT_TIME = 0 -- sound on every whisper
DEFAULT_CHATFRAME_ALPHA = 0 -- remove mouseover background

local print = function(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffD7BEA5cael|rChat: "..tostring(text))
end

local myName = UnitName("player")
local _, myClass = UnitClass("player")

local ChatFrameEditBox = ChatFrameEditBox
ChatFrameEditBox:SetAltArrowKeyMode(nil)
ChatFrameEditBox:ClearAllPoints()
ChatFrameEditBox:SetHeight(25)
ChatFrameEditBox:SetPoint("BOTTOMLEFT",  caelPanel1, "TOPLEFT", 0, 1.5)
ChatFrameEditBox:SetPoint("BOTTOMRIGHT", caelPanel1, "TOPRIGHT", 0, 1.5)
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
gradient:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0.84, 0.75, 0.65, 0.33)

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
chatFrames:HookScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon == "Blizzard_CombatLog" then
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
					frame:SetPoint("TOPLEFT", caelPanel1, "TOPLEFT", 5, -6)
					frame:SetPoint("BOTTOMRIGHT", caelPanel1, "BOTTOMRIGHT", -5, 10)
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
					frame:SetPoint("TOPLEFT", caelPanel2, "TOPLEFT", 5, -30)
					frame:SetPoint("BOTTOMRIGHT", caelPanel2, "BOTTOMRIGHT", -5, 10)
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
end)

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
local chatFrames_OnUpdate = function(self, elapsed)
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
chatFrames:RegisterEvent("PLAYER_ENTERING_WORLD")
chatFrames:HookScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		chatStuff()

		if first then
			chatFrames:SetScript("OnUpdate", chatFrames_OnUpdate)
			first = nil
		end
	end
end)