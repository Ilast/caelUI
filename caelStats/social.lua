--[[	$Id$	]]

local _, caelStats = ...

local Holder = CreateFrame("Frame")

caelStats.social = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.social:SetFontObject(neuropolrg10)
caelStats.social:SetPoint("CENTER", caelPanel8, "CENTER", 325, 1) 

local numGuildMembers = 0
local numOnlineGuildMembers = 0

local numFriends = 0
local numOnlineFriends = 0
local playerName = UnitName("player")

local delay = 0
local OnUpdate = function(self, elapsed)
	delay = delay - elapsed
	if delay < 0 then
		if IsInGuild("player") then
			GuildRoster()
		else
			Holder:SetScript("OnUpdate", nil)
		end
		delay = 15
	end
end

local OnEnter = function(self)
	numGuildMembers = GetNumGuildMembers()
	numFriends = GetNumFriends() 

	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	if numGuildMembers > 0 then
		GameTooltip:AddLine("Online Guild Members", 0.84, 0.75, 0.65)
		GameTooltip:AddLine("------------------------------", 0.55, 0.57, 0.61)

		for i = 1, numGuildMembers do
			local memberName, _, _, _, _, _, _, _, memberIsOnline, _, classFileName = GetGuildRosterInfo(i)
			local color = RAID_CLASS_COLORS[classFileName]
			if memberIsOnline then
				GameTooltip:AddLine(memberName ~= playerName and memberName, color.r, color.g, color.b)
			end
		end

		if numOnlineFriends > 0 then
			GameTooltip:AddLine("------------------------------", 0.55, 0.57, 0.61)
		end
	end

	if numOnlineFriends > 0 then
		GameTooltip:AddLine("Online Friends", 0.84, 0.75, 0.65)
		GameTooltip:AddLine("------------------------------", 0.55, 0.57, 0.61)
		for i = 1, numFriends do
			local friendName, _, friendClass, _, friendIsOnline = GetFriendInfo(i)
			if friendIsOnline then
				GameTooltip:AddLine(friendName)
			end
		end
	end

	GameTooltip:Show()
end

local OnClick = function(self, button)
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
end

local Text
local OnEvent = function(self)
	if IsInGuild("player") then
		numOnlineGuildMembers = 0
		numGuildMembers = GetNumGuildMembers()
		for i = 1, numGuildMembers do
			local memberIsOnline = select(9, GetGuildRosterInfo(i))
			if memberIsOnline then
				numOnlineGuildMembers = numOnlineGuildMembers + 1
			end
		end
	else
		Holder:SetScript("OnUpdate", nil)
	end
	numOnlineFriends = 0
	numFriends = GetNumFriends()
	
	if numFriends > 0 then
		for i = 1, numFriends do
			local friendIsOnline = select(5,GetFriendInfo(i))
			if friendIsOnline then
				numOnlineFriends = numOnlineFriends + 1
			end
		end
	end

	numOnlineGuildMembers = numOnlineGuildMembers - 1

	if numOnlineGuildMembers > 0 then
		Text = string.format("%s %d", numOnlineFriends > 0 and "|cffD7BEA5G|r" or "|cffD7BEA5Guild|r", numOnlineGuildMembers)
	end
	if numOnlineFriends > 0 then
		Text = string.format("%s %s %d", (numOnlineGuildMembers > 0) and Text or "", numOnlineGuildMembers > 0 and "- |cffD7BEA5F|r" or (numOnlineFriends > 1 and "|cffD7BEA5Friends|r" or "|cffD7BEA5Friend|r"), numOnlineFriends)
	end
	caelStats.social:SetText(Text)
end

Holder:EnableMouse(true)
Holder:SetAllPoints(caelStats.social)
Holder:RegisterEvent("GUILD_ROSTER_UPDATE")
Holder:RegisterEvent("FRIENDLIST_UPDATE")
Holder:SetScript("OnEvent", OnEvent)
Holder:SetScript("OnUpdate", OnUpdate)
Holder:SetScript("OnEnter", OnEnter)
Holder:SetScript("OnLeave", function() GameTooltip:Hide() end)
Holder:SetScript("OnMouseDown", OnClick)