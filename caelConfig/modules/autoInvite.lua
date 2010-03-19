﻿--[[	$Id: autoInvite.lua 677 2010-03-19 00:56:12Z sdkyron@gmail.com $	]]

local _, caelConfig = ...

--[[	Auto accept some invites	]]

local AcceptFriends = false
local AcceptGuild = true

local playerList = {
	["Bonewraith"] = true,
	["Caellian"] = true,
	["Callysto"] = true,
	["Cowdiak"] = true,
	["Pimiko"] = true,
	["Dens"] = true,
}

local function IsFriend(name)
	if playerList[name] then
		return true
	end

	if AcceptFriends then
		for i = 1, GetNumFriends() do
			if GetFriendInfo(i) == name then
				return true
			end
		end
	end

	if IsInGuild() and AcceptGuild then
		for i = 1, GetNumGuildMembers() do
			if GetGuildRosterInfo(i) == name then
				return true
			end
		end
	end
end

caelConfig.events:RegisterEvent("PARTY_INVITE_REQUEST")
caelConfig.events:HookScript("OnEvent", function(self, event, name)
	if event == "PARTY_INVITE_REQUEST" then
		if IsFriend(name) then
			for i = 1, STATICPOPUP_NUMDIALOGS do
				local frame = _G["StaticPopup"..i]
				if frame:IsVisible() and frame.which == "PARTY_INVITE" then
					StaticPopup_OnClick(frame, 1)
				end
			end
		else
			SendWho(string.join("", "n-\"", name, "\""))
		end
	end
end)

StaticPopupDialogs["LOOT_BIND"].OnCancel = function(self, slot)
	if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
		ConfirmLootSlot(slot)
	end
end

--[[
caelConfig.events:RegisterEvent("PARTY_INVITE_REQUEST")
caelConfig.events:HookScript("OnEvent", function(self, event, name)
	if event == "PARTY_INVITE_REQUEST" then
		if IsFriend(name) then
			AcceptGroup()

			for i = 1, STATICPOPUP_NUMDIALOGS do
				local dialog = _G["StaticPopup"..i]
				if (dialog:IsVisible() and dialog.which == "PARTY_INVITE") then
					dialog.inviteAccepted = 1
					break
				end
			end
			StaticPopup_Hide("PARTY_INVITE")
		else
			SendWho(string.join("", "n-\"", name, "\""))
		end
	end
end)
--]]