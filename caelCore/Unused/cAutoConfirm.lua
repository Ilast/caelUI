--[[	$Id: cAutoConfirm.lua 686 2010-03-19 09:47:09Z sdkyron@gmail.com $	]]

local cAutoConfirm = CreateFrame("Frame", "cAutoConfirmFrame")

local curLootSlots = {}
local curSlot

local function print(text)
	DEFAULT_CHAT_FRAME:AddMessage(GetAddOnMetadata("cAutoConfirm", "Title") .. text)
end

local function AutoConfirmIsAllowed()
	if (GetNumRaidMembers() > 0) or (GetNumPartyMembers() > 0) then
		return false
	else
		return true
	end
end

function cAutoConfirm:LOOT_BIND_CONFIRM()
	if AutoConfirmIsAllowed() then
		StaticPopup_Hide("LOOT_BIND")
		curLootSlots[#curLootSlots+1] = arg1
	end
end

function cAutoConfirm:LOOT_SLOT_CLEARED()
	if AutoConfirmIsAllowed() then
		for i, v in ipairs(curLootSlots) do
			if v == curSlot then
				curLootSlots[i] = nil
				curSlot = nil
			end
		end
	end
end

cAutoConfirm:RegisterEvent("LOOT_BIND_CONFIRM")
cAutoConfirm:RegisterEvent("LOOT_SLOT_CLEARED")

cAutoConfirm:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

cAutoConfirm:SetScript("OnUpdate", function()
	for _, v in ipairs(curLootSlots) do
		curSlot = v
		ConfirmLootSlot(v)
	end
end)