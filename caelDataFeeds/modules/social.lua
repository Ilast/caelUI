--[[	$Id$	]]

local _, caelDataFeeds = ...

local LOGIN_GUILDUPDATE_DELAY = 10

caelDataFeeds.social = caelDataFeeds.createModule("Social")

local social = caelDataFeeds.social

social.text:SetPoint("CENTER", caelPanel8, "CENTER", caelLib.scale(325), caelLib.scale(1))

social:RegisterEvent("FRIENDLIST_UPDATE")
social:RegisterEvent("GUILD_ROSTER_UPDATE")

local numOnlineGuildMembers = 0

local numFriends = 0
local numOnlineFriends = 0

local lastGuildRosterCall
local CURRENT_GUILD_SORTING
hooksecurefunc("GuildRoster", function() lastGuildRosterCall = time() end)
hooksecurefunc("SortGuildRoster", function(type) CURRENT_GUILD_SORTING = type end)

local function MakeTooltip(self)
	self.generateTooltip = false
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, caelLib.scale(4))

	if numOnlineGuildMembers > 0 then

		local sortingOrder = CURRENT_GUILD_SORTING
		if sortingOrder ~= "class" then
			SortGuildRoster("class")
		end

		GameTooltip:AddLine("Online Guild Members", 0.84, 0.75, 0.65)
		GameTooltip:AddLine(" ")

		for i = 1, numOnlineGuildMembers + 1 do
			local name, _, _, level, _, zone, _, _, isOnline, status, classFileName = GetGuildRosterInfo(i)
			local color = RAID_CLASS_COLORS[classFileName]

			if isOnline and name ~= caelLib.playerName then
				GameTooltip:AddDoubleLine("|cffD7BEA5"..level.." |r"..name.." "..status, zone, color.r, color.g, color.b, 0.65, 0.63, 0.35)
			end
		end

		if numOnlineFriends > 0 then
			GameTooltip:AddLine(" ")
		end
	end

	if numOnlineFriends > 0 then
		GameTooltip:AddLine("Online Friends", 0.84, 0.75, 0.65)
		GameTooltip:AddLine(" ")
		for i = 1, numFriends do
			local name, level, class, zone, isOnline, status = GetFriendInfo(i)

			if not isOnline then break end

			for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
				if class == v then
					class = k
				end
			end

			if caelLib.Locale ~= "enUS" then -- female class localization
				for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
					if class == v then
						class = k
					end
				end
			end

			local color = RAID_CLASS_COLORS[class]
			if isOnline then
				GameTooltip:AddDoubleLine("|cffD7BEA5"..level.." |r"..name.." "..status, zone, color.r, color.g, color.b, 0.65, 0.63, 0.35)
			end
		end
	end

	GameTooltip:Show()
end

social:SetScript("OnEnter", function(self)
	-- Update if last GuildRoster call was more than 10 seconds ago.
	if not lastGuildRosterCall or time() - lastGuildRosterCall > 10 then
		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, caelLib.scale(4))
		GameTooltip:AddLine("Loading...")
		
		self.generateTooltip = true
		GuildRoster()
	-- Else just show the tooltip with the data we've got.
	else
		MakeTooltip(self)
	end
end)

social:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" then
		if GuildFrame:IsShown() then
			FriendsFrame:Hide()
		else
			FriendsFrame:Show()
			FriendsFrameTab3:Click()
		end
	elseif button == "RightButton" then
		if GuildFrame:IsShown() then
			FriendsFrameTab1:Click()
		elseif FriendsFrame:IsShown() then
			FriendsFrame:Hide()
		else
			FriendsFrame:Show()
			FriendsFrameTab1:Click()
		end
	end
end)

local guildUpdateDelay = LOGIN_GUILDUPDATE_DELAY
local function DelayedUpdate(self, elapsed)
	if guildUpdateDelay then
		guildUpdateDelay = guildUpdateDelay - elapsed
		if guildUpdateDelay <= 0 then
			GuildRoster()
			guildUpdateDelay = LOGIN_GUILDUPDATE_DELAY
			self:SetScript("OnUpdate", nil)
		end
	end
end

-- Monitor 'Jimbob has come online./Jimbob has gone offline.' messages.
-- Schedule guild roster call.
-- Update on GUILD_ROSTER_UPDATE
local comeOnlineMsg = ERR_FRIEND_ONLINE_SS:gsub("%.", "%%.$"):gsub("\124H.+\124h", "^.-")
local goOfflineMsg = "^"..ERR_FRIEND_OFFLINE_S:gsub("%%s", ".-").."$"

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg, ...)
	if msg:find(comeOnlineMsg) or msg:find(goOfflineMsg) then
		social:SetScript("OnUpdate", DelayedUpdate)
		return false, msg, ...
	else
		return false, msg, ...
	end
end)

local Text
local updateFriends
social:SetScript("OnEvent", function(self, event, ...)
	if event == "GUILD_ROSTER_UPDATE" then
		if self.guildCheckIsRunning then
			return
		end
		
		if ... then
			GuildRoster()
		elseif IsInGuild("player") then
			self.guildCheckIsRunning = true
			
			local ShowOfflineSetting = GetGuildRosterShowOffline()
			SetGuildRosterShowOffline(false)
			
			numOnlineGuildMembers = GetNumGuildMembers() - 1
			
			SetGuildRosterShowOffline(ShowOfflineSetting)
			
			if self.generateTooltip then
				MakeTooltip(self)
			end
			
			self.guildCheckIsRunning = false
		end
	elseif event == "FRIENDLIST_UPDATE" then
		if updateFriends or FriendsFrame:IsShown() then
			numOnlineFriends = 0
			numFriends = GetNumFriends()
			
			if numFriends > 0 then
				for i = 1, numFriends do
					local friendIsOnline = select(5, GetFriendInfo(i))
					if friendIsOnline then
						numOnlineFriends = numOnlineFriends + 1
					end
				end
			end
			
			updateFriends = false
		else
			ShowFriends()
			updateFriends = true
		end
	end

	if numOnlineGuildMembers > 0 then
		Text = string.format("%s %d", numOnlineFriends > 0 and "|cffD7BEA5G|r" or "|cffD7BEA5Guild|r", numOnlineGuildMembers)
	end

	if numOnlineFriends > 0 then
		Text = string.format("%s %s %d", (numOnlineGuildMembers > 0) and Text or "", numOnlineGuildMembers > 0 and "- |cffD7BEA5F|r" or (numOnlineFriends > 1 and "|cffD7BEA5Friends|r" or "|cffD7BEA5Friend|r"), numOnlineFriends)
	end

	if numOnlineGuildMembers == 0 and numOnlineFriends == 0 then
		Text = ""
	end

	self.text:SetText(Text)
end)