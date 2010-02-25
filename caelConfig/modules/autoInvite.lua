local _, caelConfig = ...

--[[	Auto accept some invites	]]

local AcceptFriends = false
local AcceptGuild = false

local playerList = {
	["Bonewraith"] = true,
	["Caellian"] = true,
	["Callysto"] = true,
	["Cowdiak"] = true,
	["Pimiko"] = true,

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

	return false
end

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
		end
	end
end)