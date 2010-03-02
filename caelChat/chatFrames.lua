local chatFrames = CreateFrame("Frame")

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\Addons\caelMedia\Miscellaneous\glowtex]=], edgeSize = 2,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
}

local print = function(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffD7BEA5cael|rChat: "..tostring(text))
end

local _G = getfenv(0)

local _, playerClass = UnitClass("player")

CHAT_TELL_ALERT_TIME = 0 -- sound on every whisper
DEFAULT_CHATFRAME_ALPHA = 0 -- remove mouseover background

local ChatFrameEditBox = ChatFrameEditBox
ChatFrameEditBox:SetAltArrowKeyMode(nil)
ChatFrameEditBox:ClearAllPoints()
ChatFrameEditBox:SetHeight(25)
ChatFrameEditBox:SetPoint("BOTTOMLEFT",  caelPanel1, "TOPLEFT", 0, 1.5)
ChatFrameEditBox:SetPoint("BOTTOMRIGHT", caelPanel1, "TOPRIGHT", 0, 1.5)
ChatFrameEditBox:SetFontObject(neuropolrg12)
ChatFrameEditBox:SetBackdrop(backdrop)
ChatFrameEditBox:SetBackdropColor(0, 0, 0, 0.66)
ChatFrameEditBox:SetBackdropBorderColor(0, 0, 0)
ChatFrameEditBoxHeader:SetFontObject(neuropolrg12)

local function colorize(r, g, b)
	ChatFrameEditBox:SetBackdropColor(r * 0.33, g * 0.33, b * 0.33, 0.5)
end

hooksecurefunc("ChatEdit_UpdateHeader", function()
	local type = ChatFrameEditBox:GetAttribute("chatType")
	if type == "CHANNEL" then
		local chatType = GetChannelName(ChatFrameEditBox:GetAttribute("channelTarget"))
		if chatType == 0 then
			colorize(0.5, 0.5, 0.5)
		else
			colorize(ChatTypeInfo[type..chatType].r, ChatTypeInfo[type..chatType].g, ChatTypeInfo[type..chatType].b)
		end
	else
		colorize(ChatTypeInfo[type].r, ChatTypeInfo[type].g,ChatTypeInfo[type].b)
	end
end)

local background = ChatFrameEditBox:CreateTexture(nil, "BORDER")
background:SetTexture([=[Interface\Addons\caelMedia\Backgrounds\carbonCenter]=])
background:SetPoint("TOPLEFT", 2, -2)
background:SetPoint("BOTTOMRIGHT", -2, 2)
background:SetVertexColor(0.25, 0.25, 0.25, 0.5)
background:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.5, 1, 1, 1, 0.75)

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
	
--	MessageGroups only.
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

local function Kill(obj)
	obj.Show = function() end
	obj:Hide()
end

-- Container frame for tab buttons
local cftbb = CreateFrame("Frame", "ChatButtonBar", UIParent)

--	Make chat tab flash.
local function FlashTab(tab, start)
        if start and tab.flash:IsShown() then
                return
        elseif not start and not tab.flash:IsShown() then
                return
        elseif start then
			tab.flash:SetAlpha(0)
			tab.flash.elapsed = 0
            tab.flash:Show()
        else
            tab.flash:Hide()
        end
end

-- FCF override funcs
local function GetCurrentChatFrame(...)
--	Gets the chat frame which should be currently shown.
	return _G[format("ChatFrame%s", ChatButtonBar.id)]
end

local function GetChatFrameID(...)
--	Gets the current chat frame's id.
	return ChatButtonBar.id
end

local function ShowChatFrame(self)
--	Set required id variables.
	ChatButtonBar.id = self.id
	SELECTED_CHAT_FRAME = _G[format("ChatFrame%s", self.id)]

--	Hide all chat frames
	for i = 1, 4 do
		if i ~= 2 then
			_G[format("ChatButton%s", i)]:SetBackdropBorderColor(0.5, 0.5, 0.5)
			_G[format("ChatFrame%s", i)]:Hide()
		end
	end

--	Make sure tab is not flashing (stop on click)
	FlashTab(self)

--	Change our tab to a colored version so the user can see which tab is selected.
	self:SetBackdropBorderColor(0.33, 0.59, 0.33)

	_G[format("ChatFrame%s", self.id)]:Show()
end

local ctddm = CreateFrame("Frame", "ChatTabDropDown")
ctddm.displayMode = "MENU"
ctddm.info = {}
ctddm.initialize = function(self, level)
	local info = self.info
	local id = self.id
	
	if level == 1 then
		wipe(info)
		info.text = "Config"
		info.notCheckable = 1
		info.hasArrow = false
		info.func = function() ShowUIPanel(ChatConfigFrame) end
		UIDropDownMenu_AddButton(info, level)
		wipe(info)
		info.text = "Font Size"
		info.notCheckable = 1
		info.hasArrow = true
		info.value = "FONTSIZE"
		UIDropDownMenu_AddButton(info, level)
	elseif level == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == "FONTSIZE" then
			for _, size in pairs(CHAT_FONT_HEIGHTS) do
				wipe(info)
				info.text = format(FONT_SIZE_TEMPLATE, size)
				info.value = size
				info.func = function()
					FCF_SetChatWindowFontSize(self, _G[format("ChatFrame%s", id)], size)
				end
				local _, currentSize, _ = _G[format("ChatFrame%s", id)]:GetFont()
				if size == floor(currentSize+.5) then
					info.checked = 1
				end
				UIDropDownMenu_AddButton(info, level)
			end
		end
	end
end

chatFrames:RegisterEvent("ADDON_LOADED")
chatFrames:HookScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon == "Blizzard_CombatLog" then
			ChatConfigFrame_OnEvent(nil, "PLAYER_ENTERING_WORLD", addon)
			chatFrames:UnregisterEvent("ADDON_LOADED")
			for i = 1, NUM_CHAT_WINDOWS do 
				local frame = _G[format("ChatFrame%s", i)]
				local dockHighlight = _G[format("ChatFrame%sTabDockRegionHighlight", i)]
				
--				Kill chat tabs
				local cft = _G[format("ChatFrame%sTab", i)]
				local cftf = _G[format("ChatFrame%sTabFlash", i)]

				cft:EnableMouse(false)
				cft:SetScript("OnEnter", nil)
				cft:SetScript("OnLeave", nil)
				cft:GetHighlightTexture():SetTexture(nil)
				cft.SetAlpha = function() end

				cftf:SetScript("OnShow", nil)
				cftf:SetScript("OnHide", nil)
				cftf:GetRegions():SetTexture(nil)

				Kill(_G[format("ChatFrame%sTabLeft", i)])
				Kill(_G[format("ChatFrame%sTabMiddle", i)])
				Kill(_G[format("ChatFrame%sTabRight", i)])
				Kill(_G[format("ChatFrame%sTabText", i)])

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
--					FCF_SetChatWindowFontSize(nil, frame, 9)
					FCF_SetWindowColor(frame, 0, 0, 0)
					FCF_SetWindowAlpha(frame, 0)
					frame:SetFrameStrata("LOW")
					FCF_SetLocked(frame, 1)
					if i ~= 2 then frame:Show() end
				end
			end

--			Custom chat tabs
			local function MakeButton(id, txt, tip)
				local btn = CreateFrame("Button", format("ChatButton%s", id), cftbb)
				btn.id = id
				btn:SetSize(30, 15)
--				If you want them to only show on_enter
--				btn:SetScript("OnEnter", function(...) ChatButtonBar:SetAlpha(1) end)
--				btn:SetScript("OnLeave", function(...) ChatButtonBar:SetAlpha(0) end)
				btn:RegisterForClicks("LeftButtonDown", "RightButtonDown")
				btn:SetScript("OnClick", function(self, button, ...)
					if button == "RightButton" then
						if self.id == ChatButtonBar.id then
							ChatTabDropDown.id = self.id
							ToggleDropDownMenu(1, nil, ChatTabDropDown, "cursor")
						end
					else
						ShowChatFrame(self)
					end
				end)
				btn:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 3)
					GameTooltip:AddLine(tip)
					GameTooltip:Show()
				end)
				btn:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				btn.t = btn:CreateFontString(nil, "OVERLAY")
				btn.t:SetFontObject(neuropolrg9)
				btn.t:SetPoint("CENTER", 0, 1)
				btn.t:SetTextColor(1, 1, 1)
				btn.t:SetText(txt)

				btn:SetBackdrop(backdrop)
				btn:SetBackdropColor(0, 0, 0, 0)

--				Create the flash frame
				btn.flash = CreateFrame("Frame", format("ChatButton%sFlash", id), btn)
				btn.flash:SetAllPoints()
				btn.flash:SetBackdrop(backdrop)
				btn.flash:SetBackdropColor(0, 0, 0, 0)
				btn.flash:SetBackdropBorderColor(0.69, 0.31, 0.31)
				btn.flash.frequency = .05
				btn.flash.elapsed = 0
				btn.flash.isFading = false
				btn.flash:SetScript("OnUpdate", function(self, elapsed)
--					Check if update should happen yet
					self.elapsed = self.elapsed + elapsed
					if self.elapsed <= self.frequency then return end
					self.elapsed = 0

--					Determine if we should fade or not
					local currentAlpha = self:GetAlpha()
					if self.isFading and currentAlpha <= 0 then
						self.isFading = false
					elseif not self.isFading and currentAlpha >= 1 then
						self.isFading = true
					end

--					Change alpha
					self:SetAlpha(currentAlpha - (self.isFading and .1 or -.1))
				end)
--				Stop flashing if player sends an outgoing whisper
				btn.flash:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
				btn.flash:SetScript("OnEvent", function(self, event, ...)
					FlashTab(self:GetParent())
				end)

				btn.flash:Hide()
				return btn
			end

			local cft1 = MakeButton(1, "G", "• Gen •")
--			2 would be combat log, but not for gotChat
			local cft3 = MakeButton(3, "W", "• w <-> •")
			local cft4 = MakeButton(4, "L", "• Loot •")

			cft4:SetPoint("TOPRIGHT", caelPanel1, -3.5, -3)
			cft3:SetPoint("RIGHT", cft4, "LEFT")
			cft1:SetPoint("RIGHT", cft3, "LEFT")

--			Override old tab bar functions so that we can use our custom buttons to open chat options
			FCF_GetCurrentChatFrameID = GetChatFrameID
			FCF_GetCurrentChatFrame = GetCurrentChatFrame

--			Start with chat frame 1 shown.
			ShowChatFrame(cft1)

--			Prevent Blizzard from changing to chat tab 1 (on instance enter, flight path end etc).
			ChatFrame1:HookScript("OnShow", function()
				if ChatButtonBar.id ~= 1 then
					ShowChatFrame(_G[format("ChatButton%d", ChatButtonBar.id)])
				end
			end)

--			Hook cf3's add message so we can flash.
			oAddMessage = ChatFrame3.AddMessage
			ChatFrame3.AddMessage = function(...)
--				Flash if tab is not selected.
				if ChatButtonBar.id ~= 3 then
					FlashTab(cft3, true)
				end
				oAddMessage(...)
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
				local frame = _G[format("ChatFrame%s", i)]
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
			if playerClass == "HUNTER" then
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