--[[	$Id: OutdatedCode.lua 515 2010-03-06 16:33:44Z sdkyron@gmail.com $	]]

--[[  Channel(s) muting	]]

local function ChannelMessageFilter(self, event, ...)
	id = select(7, ...)
	local _, instanceType = IsInInstance()
	if instanceType == "raid" and (id == 1 or id == 22 or id == 23) then return true end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", ChannelMessageFilter)

--[[  BossBlock	]]

-- Save the location of the original function.
local originalFunc = RaidNotice_AddMessage;

local function IsSpam(text)
 if text and string.find(text, "%*%*%*") then 
  return true
 end 
end

local function FilterFunc(frame, text, colorData)
 -- Just return if the text is spam.
 if (frame == RaidWarningFrame and IsSpam(text)) then
  return
 -- It wasn"t spam so pass the data on to the original function.
 else
  originalFunc(frame, text, colorData)
 end
end

-- Hook the original function.
RaidNotice_AddMessage = FilterFunc

--[[	Auto sell junk	]]
cTweaks:RegisterEvent("MERCHANT_SHOW")
function cTweaks:MERCHANT_SHOW()
	for bag = 0, 4 do 
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if(link) then
				local _, _, quality = GetItemInfo(link)
				if(quality == 0) then
					PickupContainerItem(bag, slot)
					PickupMerchantItem()
					DEFAULT_CHAT_FRAME:AddMessage("Selling "..link)
				end
			end		
		end
	end
end

--[[	Automatically greeds all BoE greens	]]

caelTweaks:RegisterEvent("START_LOOT_ROLL")
function caelTweaks:START_LOOT_ROLL(id)
	if id
		and (select(4, GetLootRollItemInfo(id)) == 2)
		and not (select(5, GetLootRollItemInfo(id))) then
			RollOnLoot(id, 2)
	end
end

local f = CreateFrame("Frame", nil, UIParent)

f:RegisterEvent("START_LOOT_ROLL")
f:SetScript("OnEvent", function(_, _, id)
	if id
		and (select(4, GetLootRollItemInfo(id)) == 2)
		and not (select(5, GetLootRollItemInfo(id))) then
			RollOnLoot(id, 2)
	end
end)

--[[	Chatframes modifications	]]

cTweaks:RegisterEvent("PLAYER_LOGIN")
function cTweaks:PLAYER_LOGIN()
	ChatFrame1:ClearAllPoints()
	ChatFrame1:SetPoint("TOPLEFT", UIParent, "CENTER", 245, -312)
	ChatFrame1:SetHeight(116.5)
	ChatFrame1:SetWidth(312)
	ChatFrame1.SetPoint = function() end

	ChatFrame2:ClearAllPoints()
	ChatFrame2:SetPoint("TOPRIGHT", UIParent, "CENTER", -245, -336.5)
	ChatFrame2:SetHeight(92)
	ChatFrame2:SetWidth(312)
	ChatFrame2:SetJustifyH"RIGHT"
	ChatFrame2.SetPoint = function() end

	for i = 1, NUM_CHAT_WINDOWS do
		SetChatWindowAlpha(i, 0)
		SetChatWindowLocked(i, 1)
		SetChatWindowSize(i, 9)
	end

	if ChatFrame3:IsVisible() and ChatFrame4:IsVisible() then
		for i = 3, 4 do
			SetChatWindowDocked(i, 1)
		end
	end
end