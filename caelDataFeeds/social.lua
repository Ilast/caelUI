--[[	$Id$	]]

local _, caelDataFeeds = ...

caelDataFeeds.social = caelPanel8:CreateFontString(nil, "OVERLAY")
caelDataFeeds.social:SetFont([=[Interface\Addons\caelMedia\fonts\neuropol x cd rg.ttf]=], 10)
caelDataFeeds.social:SetPoint("CENTER", caelPanel8, "CENTER", 325, 1) 

caelDataFeeds.socialFrame = CreateFrame("Frame", nil, UIParent)
caelDataFeeds.socialFrame:SetAllPoints(caelDataFeeds.social)
caelDataFeeds.socialFrame:EnableMouse(true)
caelDataFeeds.socialFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelDataFeeds.socialFrame:RegisterEvent("FRIENDLIST_UPDATE")
caelDataFeeds.socialFrame:RegisterEvent("GUILD_ROSTER_UPDATE")

local numGuildMembers = 0
local numOnlineGuildMembers = 0

local numFriends = 0
local numOnlineFriends = 0
local playerName = UnitName("player")

local delay = 0
caelDataFeeds.socialFrame:SetScript("OnUpdate", function(self, elapsed)
	delay = delay - elapsed
	if delay < 0 then
		if IsInGuild("player") then
			GuildRoster()
--		else
--			self:SetScript("OnUpdate", nil)
		end
		delay = 15
	end
end)

caelDataFeeds.socialFrame:SetScript("OnEnter", function(self)
	numGuildMembers = GetNumGuildMembers()
	numFriends = GetNumFriends() 

	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	if numGuildMembers > 0 then
		GameTooltip:AddLine("Online Guild Members", 0.84, 0.75, 0.65)
		GameTooltip:AddLine(" ")

		for i = 1, numGuildMembers do
			local name, _, _, level, _, zone, _, _, isOnline, status, classFileName = GetGuildRosterInfo(i)
			local color = RAID_CLASS_COLORS[classFileName]

			if isOnline and name ~= playerName then
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
			class = string.upper(class)
			if class:find(" ") then
				class = "DEATHKNIGHT"
			end
			local color = RAID_CLASS_COLORS[class]
			if isOnline then
				GameTooltip:AddDoubleLine("|cffD7BEA5"..level.." |r"..name.." "..status, zone, color.r, color.g, color.b, 0.65, 0.63, 0.35)
			end
		end
	end

	GameTooltip:Show()
end)

caelDataFeeds.socialFrame:SetScript("OnMouseDown", function(self, button)
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

local Text
caelDataFeeds.socialFrame:SetScript("OnEvent", function(self, event)
	if event == "GUILD_ROSTER_UPDATE" then
		if IsInGuild("player") then
			numOnlineGuildMembers = 0
			numGuildMembers = GetNumGuildMembers()
			for i = 1, numGuildMembers do
				local isOnline = select(9, GetGuildRosterInfo(i))
				if isOnline then
					numOnlineGuildMembers = numOnlineGuildMembers + 1
				end
			end
			numOnlineGuildMembers = numOnlineGuildMembers - 1
--		else
--			self:SetScript("OnUpdate", nil)
		end
	elseif event == "FRIENDLIST_UPDATE" then
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

	caelDataFeeds.social:SetText(Text)
end)