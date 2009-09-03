local caelTweaks = CreateFrame("Frame")

local font, fontSize, fontOutline = [=[Interface\Addons\caelTweaks\media\neuropol x cd rg.ttf]=], 11, "OUTLINE"

local print = function(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffD7BEA5cael|rTweaks: "..tostring(text))
end

local format = string.format

--[[	Improved color picker frame	]]

caelTweaks:RegisterEvent("PLAYER_LOGIN")
caelTweaks.PLAYER_LOGIN = function(self)
	local r, g, b
	local copy = CreateFrame("Button", nil, ColorPickerFrame, "UIPanelButtonTemplate")
	copy:SetPoint("BOTTOMLEFT", ColorPickerFrame, "TOPLEFT", 208, -110)
	copy:SetHeight(20)
	copy:SetWidth(80)
	copy:SetText("Copy")
	copy:SetScript("OnClick", function() r, g, b = ColorPickerFrame:GetColorRGB() end)

	local paste = CreateFrame("Button", nil, ColorPickerFrame, "UIPanelButtonTemplate")
	paste:SetPoint("BOTTOMLEFT", ColorPickerFrame, "TOPLEFT", 208, -135)
	paste:SetHeight(20)
	paste:SetWidth(80)
	paste:SetText("Paste")
	paste:SetScript("OnClick", function() ColorPickerFrame:SetColorRGB(r, g, b) end)
end

--[[	Auto sell junk & auto repair	]]

local formatMoney = function(value)
	if value >= 1e4 then
		return format("|cffffd700%dg |r|cffc7c7cf%ds |r|cffeda55f%dc|r", value/1e4, strsub(value, -4) / 1e2, strsub(value, -2))
	elseif value >= 1e2 then
		return format("|cffc7c7cf%ds |r|cffeda55f%dc|r", strsub(value, -4) / 1e2, strsub(value, -2))
	else
		return format("|cffeda55f%dc|r", strsub(value, -2))
	end
end

local oldMoney
local itemCount = 0
caelTweaks:RegisterEvent("MERCHANT_SHOW")
caelTweaks.MERCHANT_SHOW = function(self)
	oldMoney = GetMoney()
	for bag = 0, 4 do
		for slot = 0, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link and select(3, GetItemInfo(link)) == 0 then
				ShowMerchantSellCursor(1)
				UseContainerItem(bag, slot)
				itemCount = itemCount + GetItemCount(link)
			end
		end
	end

	if(CanMerchantRepair()) then
		local cost, afford = GetRepairAllCost()
		if(afford) then
			local GuildWealth = CanGuildBankRepair() and GetGuildBankWithdrawMoney() > cost
			if(GuildWealth) then
				RepairAllItems(1)
				print(format("Guild Bank Repaired for %s.", formatMoney(cost)))
			else
				RepairAllItems()
				print(format("Repaired for %s.", formatMoney(cost)))
			end
		end
	end
end

caelTweaks:RegisterEvent("PLAYER_MONEY")
caelTweaks.PLAYER_MONEY = function(self)
	local newMoney = GetMoney()
	if oldMoney and oldMoney > 0 then
		diffMoney = newMoney - oldMoney
	else
		diffMoney = 0
	end
	if diffMoney > 0 and itemCount > 0 then
		print(format("Sold %d trash item%s for %s.", itemCount, itemCount ~= 1 and "s" or "", formatMoney(diffMoney)))
	end
	itemCount = 0
end

--[[	Auto greed on BoE green	]]

caelTweaks:RegisterEvent("START_LOOT_ROLL")
caelTweaks.START_LOOT_ROLL = function(self, event, id)
	if(id and select(4, GetLootRollItemInfo(id))==2 and not (select(5, GetLootRollItemInfo(id)))) then
		RollOnLoot(id, 2)
	end
end

--[[	Auto accept some invites	]]

local AcceptFriends = false
local AcceptGuild = false

local playerList = {
	["Aksing"] = true,
	["Caellian"] = true,
	["Kanirvatha"] = true,
	["Myrdin"] = true,
	["Pimiko"] = true,
	["Pincen"] = true,
	["Zotan"] = true,
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

caelTweaks:RegisterEvent("PARTY_INVITE_REQUEST")
caelTweaks.PARTY_INVITE_REQUEST = function(self, event, name)
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

--[[	Sound on new mail	]]

caelTweaks:RegisterEvent("UPDATE_PENDING_MAIL")
caelTweaks.UPDATE_PENDING_MAIL = function()
	if HasNewMail() and not MailFrame:IsShown() then
		PlaySoundFile([=[Interface\AddOns\caelTweaks\media\mail.wav]=])
	end
end

--[[	Force readycheck warning	]]

ReadyCheckListenerFrame:SetScript("OnShow", nil) -- Stop the default
caelTweaks:RegisterEvent("READY_CHECK")
caelTweaks.READY_CHECK = function(self)
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
end

--[[	Custom whisper sound	]]

caelTweaks:RegisterEvent("CHAT_MSG_WHISPER")
caelTweaks.CHAT_MSG_WHISPER = function(self)
	if(event == "CHAT_MSG_WHISPER") then
		PlaySoundFile([=[Interface\Addons\caelMedia\Sounds\whisper.mp3]=])
	end
end

--[[	Auto release in battleground	]]

caelTweaks:RegisterEvent("PLAYER_DEAD")
caelTweaks.PLAYER_DEAD = function(self)
	if (event == "PLAYER_DEAD") then
		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end

--[[	Hiding the vehicle seat indicator	]]

VehicleSeatIndicator:UnregisterAllEvents()
VehicleSeatIndicator_UnloadTextures()
VehicleSeatIndicator:Hide() 

--[[	Relocating the group loot frames	]]

local frame = _G["GroupLootFrame1"]
frame:ClearAllPoints()
--frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 1.5, 169)
frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 152)
--frame:SetFrameLevel(0)
frame:SetScale(.75)
for i = 2, NUM_GROUP_LOOT_FRAMES do
	frame = _G["GroupLootFrame" .. i]
	if i > 1 then
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOM", "GroupLootFrame" .. (i-1), "TOP", 0, 5)
		frame:SetFrameLevel(0)
		frame:SetScale(.75)
	end
end

--[[	Relocating the character rotation buttons	]]

CharacterModelFrameRotateLeftButton:ClearAllPoints()
CharacterModelFrameRotateLeftButton:SetPoint("LEFT", PaperDollFrame, "LEFT", 70, 5)
    
CharacterModelFrameRotateRightButton:ClearAllPoints()
CharacterModelFrameRotateRightButton:SetPoint("RIGHT", PaperDollFrame, "RIGHT", -90, 5)

WorldStateAlwaysUpFrame:SetScale(0.9)

--[[	Hide UIErrorsFrame	]]

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")

--[[	GM chat frame enhancement	]]

caelTweaks:RegisterEvent("ADDON_LOADED")
caelTweaks.ADDON_LOADED = function(self, event, name)
	if(name ~= "Blizzard_GMChatUI") then return end

	GMChatFrame:EnableMouseWheel()
	GMChatFrame:SetScript("OnMouseWheel", ChatFrame1:GetScript("OnMouseWheel"))
	GMChatFrame:ClearAllPoints()
	GMChatFrame:SetHeight(ChatFrame1:GetHeight())
	GMChatFrame:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 48)
	GMChatFrame:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 0, 48)
	GMChatFrameCloseButton:ClearAllPoints()
	GMChatFrameCloseButton:SetPoint("TOPRIGHT", GMChatFrame, "TOPRIGHT", 7, 8)
	GMChatFrameUpButton:Hide()
	GMChatFrameDownButton:Hide()
	GMChatFrameBottomButton:Hide()
	GMChatTab:Hide()

	self:UnregisterEvent(event)
end

--[[	Some new slash commands	]]

SlashCmdList["FRAMENAME"] = function() print(GetMouseFocus():GetName()) end
SlashCmdList["PARENT"] = function() print(GetMouseFocus():GetParent():GetName()) end
SlashCmdList["MASTER"] = function() ToggleHelpFrame() end
SlashCmdList["RELOAD"] = function() ReloadUI() end
SlashCmdList["ENABLE_ADDON"] = function(s) EnableAddOn(s) end
SlashCmdList["DISABLE_ADDON"] = function(s) DisableAddOn(s) end

SLASH_FRAMENAME1 = "/frame"
SLASH_PARENT1 = "/parent"
SLASH_MASTER1 = "/gm"
SLASH_RELOAD1 = "/rl"
SLASH_ENABLE_ADDON1 = "/en"
SLASH_DISABLE_ADDON1 = "/dis"

function OnEvent(self, event, ...)
	if type(self[event]) == "function" then
		return self[event](self, event, ...)
	else
		print("Unhandled event: "..event)
	end
end

caelTweaks:SetScript("OnEvent", OnEvent)