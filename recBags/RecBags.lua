--[[	$Id$	]]

local backdrop = { bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\Addons\caelMedia\Miscellaneous\glowtex]=],
	edgeSize = 2, insets = {left = 2, right = 2, top = 2, bottom = 2}
}

-- This is just here for ease of changing it if it changes at some point in the future.
local max_bag_size = 36				-- Maximum size of each bag (32 normally, 36 with some ptr thing)

local sort_from = "bottom"

-- Frames to hold our stuff (later)
local recBags, recBagsBag, recBagsBank, recBagsBagBar, recBagsBankBagBar, recBagsBagBarToggle, recBagsBankBagBarToggle
local recBagsBankBagPurchase, recBagsBankBagPurchaseCost, recBagsMoney, recBagsAmmoBag, recBagsAmmoBagToggle
local recBagsBagRestack, recBagsBagSort, recBagsBankBagSort, recBagsBankBagRestack

-- A frame for events/updates.
recBags = CreateFrame("Frame", "recBags", UIParent, nil)

-- Flag for whether bank is open (or about to be open)
local bank_shown

-- A container to hold our bag data.
bag_map = {}

-- Create a container to hold the slots.  Note: This is the visible container, there is also a hidden container created later.
local function CreateContainerFrame(name)
	local f = CreateFrame("Frame", name, UIParent)
	f:SetFrameStrata("HIGH")
	f:SetBackdrop(backdrop)
	f:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
	f:SetBackdropBorderColor(0, 0, 0, 1)
	return f
end

recBagsBag = CreateContainerFrame("recBagsBag")
recBagsBag:SetPoint("RIGHT", UIParent, -15, 0)

recBagsBank = CreateContainerFrame("recBagsBank")
recBagsBank:SetPoint("BOTTOMRIGHT", recBagsBag, "BOTTOMLEFT", 0, 0)

recBagsBank:SetScript("OnHide", function() CloseBankFrame() end)

recBagsAmmoBag = CreateContainerFrame("recBagsAmmoBag")
recBagsAmmoBag:SetPoint("BOTTOMRIGHT", recBagsBag, "TOPRIGHT", 0, 0)

recBagsBagBar = CreateContainerFrame("recBagsBagBar")
recBagsBagBar:SetPoint("TOPLEFT", recBagsBag, "BOTTOMLEFT", 0, 0)
recBagsBagBar:SetPoint("BOTTOMRIGHT", recBagsBag, "BOTTOMRIGHT", 0, -45)

recBagsBankBagBar = CreateContainerFrame("recBagsBankBagBar")
recBagsBankBagBar:SetPoint("TOPLEFT", recBagsBank, "BOTTOMLEFT", 0, 0)
recBagsBankBagBar:SetPoint("BOTTOMRIGHT", recBagsBank, "BOTTOMRIGHT", 0, -45)

-- Flags as to whether things have been processed or not (so we don't re-process them)
local bank_bar
local bags_ready
local bag_bar_done
local bag_bar_placed
local bank_bag_bar_done
local bank_bag_bar_placed

local function BagString(num)
	return string.format("Bag%d", num)
end

local function CreateBagBar(bank)
	local bag_index
	if bank then
		start_bag = 5
		end_bag = 11
		bag_index = 5
	else
		start_bag = 0
		end_bag = 4
		bag_index = 0
	end

	for bag = start_bag,end_bag do
		local name
		if not bank then
			name = string.format("recBagsBagBarBag%d", bag_index)
		else
			name = string.format("recBagsBankBagBarBag%d", bag_index)
		end
		local b = CreateFrame("CheckButton", name, bank and recBagsBankBagBar or recBagsBagBar, "ItemButtonTemplate")
		b:SetWidth(28)
		b:SetHeight(28)
		b.Bar = bank and recBagsBankBagBar or recBagsBagBar
		b.id = bank and bag_index or bag_index == 0 and 0 or bag_index+19
		b.isBag = 1
		b.bagID = bank and b.id or bag_index == 0 and 0 or b.id
		b:SetID(bank and b.id or bag_index == 0 and 0 or b.id)
		b:RegisterForDrag("LeftButton", "RightButton")
		b:RegisterForClicks("anyUp")
		if bank then
			b.GetInventorySlot = ButtonInventorySlot
			b.UpdateTooltip = BankFrameItemButton_OnEnter
		end
		b.Icon = _G[name.."IconTexture"]
		b.Icon:SetHeight(28)
		b.Icon:SetWidth(28)
		b.Cooldown = _G[name.."Cooldown"]
		b.NormalTexture = _G[name.."NormalTexture"]
		b.NormalTexture:SetTexture([=[Interface\Addons\caelMedia\Buttons\buttonborder3.tga]=])
		b.NormalTexture:SetWidth(28)
		b.NormalTexture:SetHeight(28)
		b.NormalTexture:SetVertexColor(0.5, 0.5, 0.5, 1)
		b:SetPoint("RIGHT", bank and recBagsBankBagBar or recBagsBagBar, "RIGHT", ((((bag_index < 5 and bag_index or bag_index - 5) * 28) * -1) - (5*2) - (2.5*(bag_index < 5 and bag_index or bag_index - 5))), 0)

		if bank then
			b:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(self.tooltipText)
				CursorUpdate(self)
			end)
			b:SetScript("OnReceiveDrag", function(self)
				PutItemInBag(self:GetInventorySlot())
			end)
			b:SetScript("OnDragStart", function(self)
				BankFrameItemButtonBag_Pickup(self)
			end)
		else
			b:SetScript("OnReceiveDrag", function(self)
				PutItemInBag(self.id)
			end)
			if bag_index > 0 then
				b:SetScript("OnEnter", function(self)
					BagSlotButton_OnEnter(self)
				end)
				b:SetScript("OnDragStart", function(self)
					PickupBagFromSlot(self.id)
				end)
			end
		end
		b:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
			ResetCursor()
		end)
		b.Icon:SetTexture((bag_index > 0 and GetInventoryItemTexture("player", bank and b.id+63 or b.id)) or (bag_index == 0 and [=[Interface\Buttons\Button-Backpack-Up]=]) or empty_slot_texture)

		if bank then
			recBagsBankBagBar[BagString(bag_index)] = b
		else
			recBagsBagBar[BagString(bag_index)] = b
		end

		bag_index = bag_index + 1
	end
	if bank then
		bank_bag_bar_done = true
	else
		bag_bar_done = true
	end
end

local function UpdateBagBar()
	for i = 0, 4 do
		local bag = recBagsBagBar[BagString(i)]
		bag.Icon:SetTexture((i > 0 and GetInventoryItemTexture("player", bag.id)) or (i == 0 and [=[Interface\Buttons\Button-Backpack-Up]=]) or [=[interface\paperdoll\UI-PaperDoll-Slot-Bag]=])
	end
end

local CreateToggleButton = function (name, caption, parent)
	local b = CreateFrame("Button", name, parent, nil)
	b:SetText(caption)
	b:SetWidth(50)
	b:SetHeight(15)
	b:SetNormalFontObject(GameFontHighlightSmall)
	b:SetNormalTexture(nil)
	b:SetPushedTexture(nil)
	b:SetHighlightTexture([=[Interface\Buttons\ButtonHilight-Square]=], "ADD")
	b:SetBackdrop(backdrop)
	b:SetBackdropColor(0,0,0,0.5)
	b:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.75)
	return b
end

recBagsBankBagPurchase = CreateToggleButton("recBagsBankBagPurchase", "Purchase", recBagsBankBagBar)
recBagsBankBagPurchase:SetWidth(70)
recBagsBankBagPurchase:SetText(BANKSLOTPURCHASE)
recBagsBankBagPurchase:SetPoint("BOTTOMLEFT", recBagsBankBagBar, "BOTTOMLEFT", 5, 5*2)
recBagsBankBagPurchase:SetScript("OnClick", function()
	PlaySound("igMainMenuOption")
	StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
end)

recBagsBankBagPurchaseCost = CreateFrame("Frame", "recBagsBankBagPurchaseCost", recBagsBankBagBar, "SmallMoneyFrameTemplate")
recBagsBankBagPurchaseCost.hidden = false
recBagsBankBagPurchaseCost:SetPoint("LEFT", recBagsBankBagPurchase, "RIGHT", 0, 0)
SmallMoneyFrame_OnLoad(recBagsBankBagPurchaseCost)
MoneyFrame_SetType(recBagsBankBagPurchaseCost, "STATIC")

local function UpdateBankBagBarPurchase()
	local numSlots,full = GetNumBankSlots()
	if not full then
		local cost = GetBankSlotCost(numSlots)
		BankFrame.nextSlotCost = cost
		SetMoneyFrameColor("recBagsBankBagPurchaseCost", "white")
		MoneyFrame_Update("recBagsBankBagPurchaseCost", cost)
		recBagsBankBagPurchase:Show()
		recBagsBankBagPurchaseCost:Show()
	else
		recBagsBankBagPurchase:Hide()
		recBagsBankBagPurchaseCost:Hide()
	end
end

local function GetBagType(bag_id)
	local _, bag_type = GetContainerNumFreeSlots(bag_id)
	if bag_id == KEYRING_CONTAINER then
		return "keyring"
	elseif bag_type and bag_type > 0 and bag_type < 8 then
		return "ammo"
	elseif bag_type and bag_type > 4 then
		return "profession"
	else
		return "normal"
	end
end

local function PopulateSlots(bank, keys)

	if not bags_ready then
		return
	end

	-- Determine which range of bags we need to populate
	local start_bag, end_bag
	if bank then
		start_bag = -1
		end_bag = 11
	elseif keys then
		start_bag = -2
		end_bag = -2
	else
		start_bag = 0
		end_bag = 4
	end

	for bag = start_bag, end_bag do


		local bag_type = GetBagType(bag)
		bag_map[bag].frame.bag_type = bag_type

		for slot = 1, GetContainerNumSlots(bag) do
			-- Shorthand reference
			local s = bag_map[bag].slots[slot]
			
			-- Turn off cooldown, will get updated in a minute.
			CooldownFrame_SetTimer(s.Cooldown, 0, 0, 0)

			if bag_type == "keyring" then
				s.NormalTexture:SetVertexColor(0.71, 0.43, 0.27, 1)
			elseif bag_type == "ammo" then
				s.NormalTexture:SetVertexColor(0.65, 0.63, 0.35, 1)
			elseif bag_type == "profession" then
				s.NormalTexture:SetVertexColor(0.33, 0.59, 0.33, 1)
			else
				s.NormalTexture:SetVertexColor(0.5, 0.5, 0.5, 1)
			end

			-- If the slot does not have a glow already, then create one for it
			if not s.glow then
				s.glow = s:CreateTexture(nil, "OVERLAY")
				s.glow:SetTexture([=[Interface\Addons\caelMedia\Buttons\buttonoverlay]=])
				s.glow:SetBlendMode("ADD")
				s.glow:SetWidth(32)
				s.glow:SetHeight(32)
				s.glow:ClearAllPoints()
				s.glow:SetPoint("CENTER", s)
			end
			s.glow:SetVertexColor(0.84,0.75,0.65,0.25)

			if not s.glow_border then
				s.glow_border = s:CreateTexture(nil, "OVERLAY")
				s.glow_border:SetTexture([=[Interface\Addons\caelMedia\Buttons\buttonborder3]=])
				s.glow_border:SetWidth(32)
				s.glow_border:SetHeight(32)
				s.glow_border:ClearAllPoints()
				s.glow_border:SetPoint("CENTER", s)
			end
			s.glow_border:SetVertexColor(0.84,0.75,0.65,0.75)

			-- Determine if there is an item in this slot
			local link = GetContainerItemLink(bag,slot)
			if link then

				-- Obtain information about the item
				local _, _, rarity, _, _, _, _, _, _, texture, _ = GetItemInfo(link)
				local stack, lock = select(2, GetContainerItemInfo(bag, slot))

				-- Set the slot's texture
				s.Icon:SetTexture(texture)

				-- Set the stack count of the item
				SetItemButtonCount(s, stack)

				-- Get cooldown information about the item
				local cooldown_start, cooldown_finish, cooldown_enable = GetContainerItemCooldown(bag, slot)
				if cooldown_finish > 0 then
					CooldownFrame_SetTimer(s.Cooldown, cooldown_start, cooldown_finish, cooldown_enable)
				end

				-- If the item is locked (due to trade/AH etc) then dim the color.
				SetItemButtonDesaturated(s, lock, 0.5, 0.5, 0.5)

				if rarity and 1 and rarity > 1 then
					local rr, rg, rb = GetItemQualityColor(rarity)
					s.glow:SetVertexColor(rr, rg, rb, 0.25)
					s.glow_border:SetVertexColor(rr, rg, rb, 0.75)
				end
				if not(1) then
					local rr, rg, rb
					if rarity then
						rr, rg, rb = GetItemQualityColor(rarity)
					else
						rr, rg, rb = 0.84, 0.75, 0.65
					end
					s.glow:SetVertexColor(rr, rg, rb, 0.25)
					if not(rarity) then
						rr, rg, rb = 0.84, 0.75, 0.65
					end
					s.glow_border:SetVertexColor(rr, rg, rb, 0.75)
				end
			else
				-- The slot doesn't have an item, so make sure to 'reset' it's settings.
				s.Icon:SetTexture(nil)
				SetItemButtonCount(s, nil)
				SetItemButtonDesaturated(s, nil, 0.5, 0.5, 0.5)
			end
		end
	end
end

local function ResizeContainer(frame, slots)
	local is_bank = string.find(frame:GetName(), "Bank") and true or false
	local bag_columns = is_bank and 20 or 10
	local rows_needed = floor(slots/bag_columns) + ((slots % bag_columns > 0) and 1 or 0)
	frame:SetHeight(((rows_needed + 1) * 2.5) + (rows_needed * 28) + 20 + (5 * 2))
	frame:SetWidth(((bag_columns + 1) * 2.5) + (bag_columns * 28) + (5 * 2))
	return rows_needed
end

local function TotalSlots(bank, ammo)
	local total_slots = 0

	if bank then
		for bag_id = 5,11 do
			if bag_map[bag_id].frame.slots then
				total_slots = total_slots + bag_map[bag_id].frame.slots
			end
		end
		total_slots = total_slots + bag_map[-1].frame.slots
	else
		for bag_id = 0,4 do
			if bag_map[bag_id].frame.slots then
				if ammo and bag_map[bag_id].frame.bag_type == "ammo" then
					total_slots = total_slots + bag_map[bag_id].frame.slots
				elseif not(ammo) and bag_map[bag_id].frame.bag_type ~= "ammo" then
					total_slots = total_slots + bag_map[bag_id].frame.slots
				end
			end
		end
	end

	return total_slots
end

local function UpdateBankBagBar()
	local numSlots,full = GetNumBankSlots()
	local button
	for i=5,11 do
		button = _G[string.format("recBagsBankBagBarBag%d", i)]
		button.Icon:SetTexture((button.id and GetInventoryItemTexture("player", button.id+63)) or (i == 0 and [=[Interface\Buttons\Button-Backpack-Up]=]) or [=[interface\paperdoll\UI-PaperDoll-Slot-Bag]=])
		if (i - 4) <= numSlots then
			SetItemButtonTextureVertexColor(button, 0.84,0.75,0.65)
			button.tooltipText = "Bag Slot"
		else
			SetItemButtonTextureVertexColor(button, 0.69,0.31,0.31)
			button.tooltipText = "Purchasable Bag Slot"
		end
	end
end

local function DisplayBar(frame)
	if not bags_ready then return end

	local is_bank = string.find(frame:GetName(), "Bank") and true or false

	if is_bank then
		recBagsBankBagBar:Show()
	else
		recBagsBagBar:Show()
	end
end

recBagsBagBarToggle = CreateToggleButton("recBagsBagBarToggle", "Bag Bar", recBagsBag)
recBagsBagBarToggle:SetPoint("BOTTOMRIGHT", recBagsBag, "BOTTOMRIGHT", -5, 10)
recBagsBagBarToggle:SetScript("OnClick", function()
	if recBagsBagBar:IsShown() then
		recBagsBagBar:Hide()
	else
		DisplayBar(recBagsBagBar)
	end
end)

recBagsBankBagBarToggle = CreateToggleButton("recBagsBankBagBarToggle", "Bag Bar", recBagsBank)
recBagsBankBagBarToggle:SetPoint("BOTTOMRIGHT", recBagsBank, "BOTTOMRIGHT", -5, 10)
recBagsBankBagBarToggle:SetScript("OnClick", function()
	if recBagsBankBagBar:IsShown() then
		recBagsBankBagBar:Hide()
	else
		DisplayBar(recBagsBankBagBar)
	end
end)

local function DisplayContainer(frame)
	if not bags_ready then return end
	-- Flag for if this is the bank frame or ammo frame.
	local is_bank = string.find(frame:GetName(), "Bank") and true or false
	local is_ammo = string.find(frame:GetName(), "Ammo") and true or false

	-- Find out how many slots will be in this frame
	local slots = TotalSlots(is_bank, is_ammo)

	-- Size the container based on this amount of slots
	local rows_needed = ResizeContainer(frame, slots)

	-- Find out which bag to start with.
	local current_bag = is_bank and -1 or 0

	-- Place the slots in the correct location.
	local slots_remaining = bag_map[current_bag].frame.slots -- Always valid to start
	local slot	-- Shorthand reference
	local slot_index = 1	-- index of the slot we are on in the current bag
	local bag_columns = is_bank and 20 or 10
	for row=1,rows_needed do
		for column=1,bag_columns do
			if row == rows_needed and (slots % bag_columns) ~= 0 and column > (slots % bag_columns) then
				-- Do nothing
			else
				-- Make sure we have an ammo bag, if this is an ammo bag.
				if is_ammo and bag_map[current_bag].frame.bag_type ~= "ammo" then
					while bag_map[current_bag].frame.bag_type ~= "ammo" do
						current_bag = current_bag + 1
					end
					slots_remaining = bag_map[current_bag].frame.slots
				end

				-- If we are out of slots, then we need to find the next bag to use.
				if slots_remaining == 0 then
					-- If it's the end of the primary bank, then skip to the bank's other bags.
					if current_bag == -1 then current_bag = 4 end

					-- Keep going through the bags until we find a bag with slots to use
					repeat
						if current_bag == 11 then
							--print('wut!', row, rows_needed, column, bag_columns)
							return
						end
						current_bag = current_bag + 1
						slots_remaining = bag_map[current_bag].frame.slots
					until slots_remaining > 0

					-- Reset our bag_map slot index.
					slot_index = 1
				end

				slot = bag_map[current_bag].slots[slot_index]
				local new_x = ((2.5 * column) + (28 * (column - 1)) + 5)
				local new_y = ((2.5 * row) + (28 * (row - 1)) + 5) * -1

				slot:ClearAllPoints()
				slot:SetPoint("TOPLEFT", frame, "TOPLEFT", new_x, new_y)
				slot:SetPoint("BOTTOMRIGHT", frame, "TOPLEFT", new_x + 28, new_y - 28)
				slot:Show()

				slots_remaining = slots_remaining - 1
				slot_index = slot_index + 1
			end
		end
	end

	PopulateSlots(is_bank)

	-- Show the frame
	frame:Show()
end

recBagsKeyringBag = CreateContainerFrame("recBagsKeyringBag")
recBagsKeyringBag:SetPoint("BOTTOMLEFT", recBagsBag, "TOPLEFT", 0, 0)

local function DisplayKeys()
	local slots = GetContainerNumSlots(-2)
	local rows_needed = ResizeContainer(recBagsKeyringBag, slots)

	-- Place the slots in the correct location.
	local slots_remaining = bag_map[-2].frame.slots -- Always valid to start
	local slot	-- Shorthand reference
	local slot_index = 1	-- index of the slot we are on in the current bag
	local bag_columns = 10
	for row=1,rows_needed do
		for column=1,bag_columns do
			if row == rows_needed and (slots % bag_columns) ~= 0 and column > (slots % bag_columns) then
				-- Do nothing
			else
				slot = bag_map[-2].slots[slot_index]
				local new_x = ((2.5 * column) + (28 * (column - 1)) + 5)
				local new_y = ((2.5 * row) + (28 * (row - 1)) + 5) * -1

				slot:ClearAllPoints()
				slot:SetPoint("TOPLEFT", recBagsKeyringBag, "TOPLEFT", new_x, new_y)
				slot:SetPoint("BOTTOMRIGHT", recBagsKeyringBag, "TOPLEFT", new_x + 28, new_y - 28)
				slot:Show()

				slots_remaining = slots_remaining - 1
				slot_index = slot_index + 1
			end
		end
	end

	PopulateSlots(false, true) --is_bank, is_keys

	-- Show the frame
	recBagsKeyringBag:Show()
end

recBagsKeyringToggle = CreateToggleButton("recBagsKeyringToggle", "Keys", recBagsBagBar)
recBagsKeyringToggle:SetPoint("BOTTOMLEFT", recBagsBagBar, "BOTTOMLEFT", 5, 10)
recBagsKeyringToggle:SetScript("OnClick", function()
	if recBagsKeyringBag:IsShown() then
		PlaySound("KeyRingClose")
		recBagsKeyringBag:Hide()
	else
		PlaySound("KeyRingOpen")
		if recBagsAmmoBag:IsShown() then
			recBagsKeyringBag:SetPoint("BOTTOMLEFT", recBagsBag, "TOPLEFT", 0, (recBagsAmmoBag:GetHeight()))
		else
			recBagsKeyringBag:SetPoint("BOTTOMLEFT", recBagsBag, "TOPLEFT", 0, 0)
		end
		DisplayKeys()
	end
end)

local restack_threads = {}
local restack_frame = CreateFrame("Frame")
local Restack
local function MoveItem(bag1,slot1,bag2,slot2)
    	ClearCursor()
    	while true do
        	local _, _, locked1 = GetContainerItemInfo(bag1, slot1)
	        local _, _, locked2 = GetContainerItemInfo(bag2, slot2)
    	    if locked1 or locked2 then
        	    coroutine.yield()
        	else
            	break
        	end
    	end
    	PickupContainerItem(bag1, slot1)
    	PickupContainerItem(bag2, slot2)
    	ClearCursor()
end
function RestackCheck()
	for thread_index,thread in ipairs(restack_threads) do
		if coroutine.status(thread) == "dead" then
			restack_threads[thread_index] = nil
		else
    		coroutine.resume(thread)
    	end
    end

    if Restack() and (#restack_threads or #restack_threads == 0) then
    	restack_threads = {}
		restack_frame:SetScript("OnUpdate", nil)
		collectgarbage("collect")	-- i think we can remove this!
	end
end

local count = 0
Restack = function()
	local data = {}
	for bag = 0,4 do
		if not data[bag] then data[bag] = {} end
		local num_slots = GetContainerNumSlots(bag)
		for slot = 1, num_slots do
			if not data[bag][slot] then data[bag][slot] = {} end
			local item_link = GetContainerItemLink(bag, slot)
			if item_link then
				local _, slot_count, item_lock = GetContainerItemInfo(bag, slot)
				local item_name, _, _, _, _, _, _, max_item_stack = GetItemInfo(item_link)
				for a_bag, bag_data in pairs(data) do
					for a_slot, slot_data in pairs(bag_data) do
						if slot_data.item_name == item_name and slot_data.slot_count < max_item_stack then
							local thread_index = (#restack_threads or 0) + 1
							local thread = restack_threads[thread_index]
							thread = coroutine.create(function() MoveItem(bag,slot,a_bag,a_slot) end)
							coroutine.resume(thread)
							restack_frame:SetScript("OnUpdate", RestackCheck)
							return false
						end
					end
				end
				data[bag][slot].item_name = item_name
				data[bag][slot].slot_count = slot_count
			end
		end
	end
	collectgarbage("collect")
	return true
end
recBagsBagRestack = CreateToggleButton("recBagsBagRestack", "Restack", recBagsBag)
recBagsBagRestack:SetPoint("BOTTOMLEFT", recBagsBag, "BOTTOMLEFT", 5, 10)
recBagsBagRestack:SetScript("OnClick", Restack)

local RestackBank
local bank_restack_threads = {}
local bank_restack_frame = CreateFrame("Frame")
local function MoveBankItem(bag1,slot1,bag2,slot2)
    ClearCursor()
    while true do
        local _, _, locked1 = GetContainerItemInfo(bag1, slot1)
        local _, _, locked2 = GetContainerItemInfo(bag2, slot2)
        if locked1 or locked2 then
            coroutine.yield()
        else
            break
        end
    end
   	PickupContainerItem(bag1, slot1)
   	PickupContainerItem(bag2, slot2)
   	ClearCursor()
end
function BankRestackCheck()
	for thread_index,thread in ipairs(bank_restack_threads) do
		if coroutine.status(thread) == "dead" then
			bank_restack_threads[thread_index] = nil
		else
    		coroutine.resume(thread)
    	end
    end

    if RestackBank() and (#bank_restack_threads or #bank_restack_threads == 0) then
    	bank_restack_threads = {}
		bank_restack_frame:SetScript("OnUpdate", nil)
		collectgarbage("collect")	-- i think we can remove this!
	end
end
RestackBank = function()
	local data = {}
	local done = false
	for bag = 0,7 do
		if bag == 0 then bag = bag - 1 else bag = bag + 4 end
		if not data[bag] then data[bag] = {} end
		local num_slots = GetContainerNumSlots(bag)
		for slot = 1, num_slots do
			if not data[bag][slot] then data[bag][slot] = {} end
			local item_link = GetContainerItemLink(bag, slot)
			if item_link then
				local _, slot_count, item_lock = GetContainerItemInfo(bag, slot)
				local item_name, _, _, _, _, _, _, max_item_stack = GetItemInfo(item_link)
				for a_bag, bag_data in pairs(data) do
					for a_slot, slot_data in pairs(bag_data) do
						if slot_data.item_name == item_name and slot_data.slot_count < max_item_stack then
							local thread_index = (#bank_restack_threads or 0) + 1
							local thread = bank_restack_threads[thread_index]
							thread = coroutine.create(function() MoveBankItem(bag,slot,a_bag,a_slot) end)
							coroutine.resume(thread)
							bank_restack_frame:SetScript("OnUpdate", BankRestackCheck)
							return false
						end
					end
				end
				data[bag][slot].item_name = item_name
				data[bag][slot].slot_count = slot_count
			end
		end
	end
	collectgarbage("collect")
	return true
end

recBagsBankBagRestack = CreateToggleButton("recBagsBankBagRestack", "Restack", recBagsBank)
recBagsBankBagRestack:SetPoint("BOTTOMLEFT", recBagsBank, "BOTTOMLEFT", 5, 10)
recBagsBankBagRestack:SetScript("OnClick", RestackBank)

-----------------------------------------------------------------------------------------
--									BAG SORTING
-----------------------------------------------------------------------------------------

-- vars we need
sort_data = {}
local BankSort, Sort, sort_in_progress, times_fired
local sort_frame = CreateFrame("Frame")

-- This is called on bag_update during sorting.  Bag_update is called twice when we move an item, so we count
-- the times that this event has fired, and only release the sorting lock after it is done updating.
local function SortEvent()
	times_fired = times_fired + 1
	if times_fired == 2 then
		sort_in_progress = false
		return
	end
end

-- This is our OnUpdate loop to sort each item in the sort_data table.
local function DoSort()
	-- Just wait if we are still sorting.
	if sort_in_progress then return end

	-- We're done
	if not(sort_data) or #sort_data == 0 then
		-- Remove frame scripts, as we don't need them anymore
		sort_frame:SetScript("OnEvent", nil)
		sort_frame:SetScript("OnUpdate", nil)

		-- Cleanup
		collectgarbage("collect")

		-- Inform user
		print("recBags: Sorting finished.")
		return
	end

	-- If we didn't return already, then it is time to sort the next item.

	-- Set a lock so we don't try to update the next item until we are done with this one.
	sort_in_progress = true

	-- If the item is already in the correct slot, then don't do anything at all.
	if sort_data[1].dest_bag == sort_data[1].source_bag and sort_data[1].dest_slot == sort_data[1].source_slot then
		table.remove(sort_data, 1)
		sort_in_progress = false
		return
	end

	-- Reset our bag_update counter
	times_fired = 0

	-- If moving this item will displace a previous item, we need to set the previous item's source data to the source data
	-- of the item we are replacing it with.  This essentially updates our table to reflect the item swap
	for k,v in ipairs(sort_data) do
		if k ~= 1 then	-- skip ourselves
			if v.source_bag == sort_data[1].dest_bag and v.source_slot == sort_data[1].dest_slot then
				v.source_bag = sort_data[1].source_bag
				v.source_slot = sort_data[1].source_slot
			end
		end
	end

	-- Generate a coroutine thread for this move.
	local thread = coroutine.create(function()
		MoveItem(sort_data[1].source_bag, sort_data[1].source_slot, sort_data[1].dest_bag, sort_data[1].dest_slot)
	end)

	local i = 0
	while true do
		-- Start moving the item
		i = i + 1
        local status = coroutine.resume(thread)
		if not status then break end

		if i == 25 then
			-- This shouldn't happen anymore, but toss an error if it does, just in case.
			print(string.format("ERROR: Stuck on %d,%d -> %d,%d", sort_data[1].source_bag, sort_data[1].source_slot, sort_data[1].dest_bag, sort_data[1].dest_slot))
			break
		end
    end

	-- Remove the table
   	table.remove(sort_data, 1)
end

-- Generates a table of all items in the players bags with data we will need to sort them.
local function CreateSortData()
	sort_data = {}
	for bag = 0,4 do
		if GetBagType(bag) == "normal" then
			local num_slots = GetContainerNumSlots(bag)
			for slot = 1, num_slots do
				local item_link = GetContainerItemLink(bag, slot)
				if item_link then
					local item_name, _, item_rarity = GetItemInfo(item_link)
					local new_index = (#sort_data or 0) + 1
					sort_data[new_index] = {}
					local i = sort_data[new_index]
					i.name = item_name
					i.rarity = tonumber(item_rarity)
					i.source_bag = bag
					i.source_slot = slot
				end
			end
		end
	end
end

-- Generates a table of all items in the players bags with data we will need to sort them.
local function CreateBankSortData()
	sort_data = {}
	for bag = 0,7 do
		if bag == 0 then bag = -1 end
		if bag > 0 then bag = bag + 4 end
		if GetBagType(bag) == "normal" then
			local num_slots = GetContainerNumSlots(bag)
			for slot = 1, num_slots do
				local item_link = GetContainerItemLink(bag, slot)
				if item_link then
					local item_name, _, item_rarity = GetItemInfo(item_link)
					local new_index = (#sort_data or 0) + 1
					sort_data[new_index] = {}
					local i = sort_data[new_index]
					i.name = item_name
					i.rarity = tonumber(item_rarity)
					i.source_bag = bag
					i.source_slot = slot
				end
			end
		end
	end
end

-- Sorts items by rarity and name
local function rarity_sort(a,b)
	if a.rarity == b.rarity then
		return a.name < b.name
	end
	return a.rarity > b.rarity
end

-- Sorts items by rarity and name
local function rarity_sort_reverse(a,b)
	if a.rarity == b.rarity then
		return a.name < b.name
	end
	return a.rarity < b.rarity
end

Sort = function(reverse)
	-- Creates a table of all items and relevant data
	CreateSortData()

	-- Sorts table by rarity and name
	if reverse then
		table.sort(sort_data, rarity_sort_reverse)
	else
		table.sort(sort_data, rarity_sort)
	end

	if sort_from == "top" then
		-- Determines which slot items should go to based on the sorted order
		local dest_bag, dest_slot = 0, 1
		for k,v in ipairs(sort_data) do
			-- Skip ammo bags, or move to next bag if this bag is done.
			if GetBagType(dest_bag) ~= "normal" or dest_slot > GetContainerNumSlots(dest_bag) then
				repeat
					dest_bag = dest_bag + 1
				until GetBagType(dest_bag) == "normal"
				dest_slot = 1
			end

			-- Save destination data
			sort_data[k].dest_bag = dest_bag
			sort_data[k].dest_slot = dest_slot

			-- Increment destination slot for next item
			dest_slot = dest_slot + 1
		end
	else -- sort_from == "bottom"
		-- Determines which slot items should go to based on the sorted order
		local dest_bag, dest_slot = 4, GetContainerNumSlots(4)

		-- Go through table backwards
		for k = #sort_data, 1, -1 do

			-- Skip ammo bags, or move to next bag if this bag is done.
			if GetBagType(dest_bag) ~= "normal" or dest_slot == 0 then
				repeat
					dest_bag = dest_bag - 1
					dest_slot = GetContainerNumSlots(dest_bag)
				until GetBagType(dest_bag) == "normal" and dest_slot ~= 0
			end

			-- Save destination data
			sort_data[k].dest_bag = dest_bag
			sort_data[k].dest_slot = dest_slot

			-- Increment destination slot for next item
			dest_slot = dest_slot - 1
		end
	end

	-- Start updating to sort!
	print("recBags: Sort in progress, please wait...")
	sort_frame:SetScript("OnEvent", SortEvent)
	sort_frame:RegisterEvent("BAG_UPDATE")
	sort_frame:SetScript("OnUpdate", DoSort)
end

BankSort = function(reverse)
	-- Creates a table of all items and relevant data
	CreateBankSortData()

	-- Sorts table by rarity and name
	if reverse then
		table.sort(sort_data, rarity_sort_reverse)
	else
		table.sort(sort_data, rarity_sort)
	end

	if sort_from == "top" then
		-- Determines which slot items should go to based on the sorted order
		local dest_bag, dest_slot = -1, 1
		for k,v in ipairs(sort_data) do
			-- Skip ammo bags, or move to next bag if this bag is done.
			if GetBagType(dest_bag) ~= "normal" or dest_slot > GetContainerNumSlots(dest_bag) then
				repeat
					dest_bag = dest_bag + 1
					if dest_bag == 0 then dest_bag = 5 end	-- Move on to next bank bag if we were on the main bag
				until GetBagType(dest_bag) == "normal"
				dest_slot = 1
			end

			-- Save destination data
			sort_data[k].dest_bag = dest_bag
			sort_data[k].dest_slot = dest_slot

			-- Increment destination slot for next item
			dest_slot = dest_slot + 1
		end
	else -- sort_from == "bottom"
		-- Determines which slot items should go to based on the sorted order
		local dest_bag, dest_slot = 11, GetContainerNumSlots(11)	-- Start with final bank bag

		-- Go through table backwards
		for k = #sort_data, 1, -1 do

			-- Skip ammo bags, or move to next bag if this bag is done.
			if GetBagType(dest_bag) ~= "normal" or dest_slot == 0 then
				repeat
					dest_bag = dest_bag - 1
					if dest_bag == 4 then dest_bag = -1 end	-- Move to main bank bag if we're done with other bank bags
					dest_slot = GetContainerNumSlots(dest_bag)
				until GetBagType(dest_bag) == "normal" and dest_slot ~= 0
			end

			-- Save destination data
			sort_data[k].dest_bag = dest_bag
			sort_data[k].dest_slot = dest_slot

			-- Increment destination slot for next item
			dest_slot = dest_slot - 1
		end
	end

	-- Start updating to sort!
	print("recBags: Sort in progress, please wait...")
	sort_frame:SetScript("OnEvent", SortEvent)
	sort_frame:RegisterEvent("BAG_UPDATE")
	sort_frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	sort_frame:SetScript("OnUpdate", DoSort)
end

-- Show tooltip when mouse is over sort button
local function ShowSortTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(string.format("Sort to: %s", sort_from))
	GameTooltip:AddLine("Left-click: Grey on bottom")
	GameTooltip:AddLine("Right-click: Grey on top")
	GameTooltip:Show()
end

-- Our button to click to start the sort
recBagsBagSort = CreateToggleButton("recBagsBagSort", "Sort", recBagsBag)
recBagsBagSort:SetPoint("LEFT", recBagsBagRestack, "RIGHT", 5, 0)
recBagsBagSort:RegisterForClicks("LeftButtonUp", "RightButtonUp")
recBagsBagSort:SetScript("OnEnter", ShowSortTooltip)
recBagsBagSort:SetScript("OnLeave", function() GameTooltip:Hide() end)
recBagsBagSort:SetScript("OnClick", function(self, button)
	GameTooltip:Hide()
	if button == "LeftButton" then
		-- Grey on bottom
		Sort()
	else -- button == "RightButton"
		-- Grey on top
		Sort(true)
	end
end)

-- Our button to click to start the bank sort
recBagsBankBagSort = CreateToggleButton("recBagsBankBagSort", "Sort", recBagsBank)
recBagsBankBagSort:SetPoint("LEFT", recBagsBankBagRestack, "RIGHT", 5, 0)
recBagsBankBagSort:RegisterForClicks("LeftButtonUp", "RightButtonUp")
recBagsBankBagSort:SetScript("OnEnter", ShowSortTooltip)
recBagsBankBagSort:SetScript("OnLeave", function() GameTooltip:Hide() end)
recBagsBankBagSort:SetScript("OnClick", function(self, button)
	GameTooltip:Hide()
	if button == "LeftButton" then
		-- Grey on bottom
		BankSort()
	else -- button == "RightButton"
		-- Grey on top
		BankSort(true)
	end
end)

-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------

recBagsAmmoBagToggle = CreateToggleButton("recBagsAmmoBagToggle", "A / S", recBagsBag)
recBagsAmmoBagToggle:SetPoint("RIGHT", recBagsBagBarToggle, "LEFT", -5, 0)
recBagsAmmoBagToggle:SetScript("OnClick", function()
	if recBagsAmmoBag:IsShown() then
		if recBagsKeyringBag:IsShown() then
			recBagsKeyringBag:SetPoint("BOTTOMLEFT", recBagsBag, "TOPLEFT", 0, 0)
		else
			recBagsKeyringBag:SetPoint("BOTTOMLEFT", recBagsBag, "TOPLEFT", 0, (recBagsAmmoBag:GetHeight()))
		end
		recBagsAmmoBag:Hide()
	else
		if recBagsKeyringBag:IsShown() then
			recBagsKeyringBag:SetPoint("BOTTOMLEFT", recBagsBag, "TOPLEFT", 0, (recBagsAmmoBag:GetHeight()))
		else
			recBagsKeyringBag:SetPoint("BOTTOMLEFT", recBagsBag, "TOPLEFT", 0, 0)
		end
		DisplayContainer(recBagsAmmoBag)
	end
end)

-- Creates a hidden bag frame with details/references needed
local function CreateBagFrame(bag_id)
	-- Bail if we already have something in this slot.
	if bag_map[bag_id] and bag_map[bag_id].frame then return end

	local parent
	if bag_id == -2 then
		parent = "recBagsKeyringBag"
	elseif bag_id == -1 or bag_id > 4 then
		parent = "recBagsBank"
	elseif GetBagType(bag_id) == "ammo" then
		parent = "recBagsAmmoBag"
	else
		parent = "recBagsBag"
	end

	-- Create 'bag link' frame.
	local f = CreateFrame("Frame", string.format("recBagsBag%dFrame", bag_id), _G[parent], nil)

	f.bag_type = GetBagType(bag_id)

	-- Determine bag references
	f.bagID = bag_id
	f:SetID(bag_id)

	-- Set active slots (just zero for now)
	f.slots = 0

	return f
end

local function CreateBagSlot(bag_id, slot_id)
	-- Bail if we already have something in this slot.
	if bag_map[bag_id].slots[slot_id] then return end

	-- Determine name to use
	local name = string.format("recBagsBag%dSlot%d", bag_id, slot_id)

	-- Determine button template
	local template
	if bag_id == -2 or bag_id > -1 then
		template = "ContainerFrameItemButtonTemplate"
	else
		template = "BankItemButtonGenericTemplate"
	end

	-- Create slot button
	local b = CreateFrame("Button", name, _G[string.format("recBagsBag%dFrame", bag_id)], template)

	b:SetBackdrop({
		bgFile = nil,
		edgeFile = nil,
		edgeSize = nil,
		insets = { left = nil, right = nil, top = nil, bottom = nil }
	})
	b:SetBackdropColor(0,0,0,0)

	-- Assign count attributes
	b.Count = _G[string.format("%sCount", name)]
	b.Count:SetFont("Fonts\\ARIALN.TTF", 14, "OUTLINE")
	b.Count:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 3)

	-- Assign icon attributes
	b.Icon = _G[string.format("%sIconTexture", name)]
	b.Icon:SetHeight(28)
	b.Icon:SetWidth(28)

	-- Assign Cooldown attributes
	b.Cooldown = _G[string.format("%sCooldown", name)]
	b.Cooldown:SetHeight(28)
	b.Cooldown:SetWidth(28)

	-- Assign Texture attributes
	b.NormalTexture = _G[string.format("%sNormalTexture", name)]
	b.NormalTexture:SetTexture([=[Interface\Addons\caelMedia\Buttons\buttonborder3.tga]=])
	b.NormalTexture:ClearAllPoints()
	b.NormalTexture:SetPoint("CENTER", b)
	b.NormalTexture:SetWidth(28)
	b.NormalTexture:SetHeight(28)
	b.NormalTexture:SetVertexColor(0.5, 0.5, 0.5, 1)

	_G[name]:SetHighlightTexture(nil)
	_G[name]:SetPushedTexture(nil)

	-- Assign ids
	b.slotID = slot_id
	b:SetID(slot_id)
	if bag_id > 0 then
		b.bagID = bag_id
	end

	return b
end

-- Hides all existing bag slots
local function HideAllSlots()
	for i = -2, 11, 1 do
		if bag_map[i] then
			for j = 1, max_bag_size, 1 do
				if bag_map[i].slots[j] then
					bag_map[i].slots[j]:Hide()
				end
			end
		end
	end
end

-- Creates and updates the bag map to the current slots in-game
local function UpdateBagMap()
	HideAllSlots()

	-- Loop through all possible bag slots.
	for i = -2, 11, 1 do

		-- Create this bag table if it does not exist.
		if not bag_map[i] then bag_map[i] = {} end
		if not bag_map[i].frame then bag_map[i].frame = CreateBagFrame(i) end
		if not bag_map[i].slots then bag_map[i].slots = {} end

		-- Set/update the number of slots in this bag.
		local bag_size = GetContainerNumSlots(i)
		bag_map[i].frame.slots = bag_size or 0

		-- Create any bag slots that are not already created.
		if bag_size and bag_size > 0 then
			for j = 1, bag_size, 1 do
				if not bag_map[i].slots[j] then
					bag_map[i].slots[j] = CreateBagSlot(i, j)
				end
			end
		end

	end
end

local login_delay = 1
local function LoginTimer(self, elapsed)

	-- After a small delay, we do our initial addon loading process.
	login_delay = login_delay - elapsed
	if login_delay <= 0 then

		-- Turn off our timer
		recBags:UnregisterEvent("PLAYER_ENTERING_WORLD")
		recBags:SetScript("OnUpdate", nil)

		-- Basic initialization
		UpdateBagMap()
		CreateBagBar()

		-- Set a flag to let other parts of code know that it is okay to do what they do.
		bags_ready = true
	end

end

local function OpenBags()
	DisplayContainer(recBagsBag)
	PopulateSlots(false)
end
local function CloseBags()
	recBagsBag:Hide()
	recBagsBagBar:Hide()
	recBagsBank:Hide()
	recBagsBankBagBar:Hide()
	recBagsAmmoBag:Hide()
	recBagsKeyringBag:Hide()
end

local function ToggleBags()
	if recBagsBag:IsShown() then
		CloseBags()
	else
		OpenBags()
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then

		-- Some bag data is not available immediately after PEW fires, so we delay our loading calls.
		recBags:SetScript("OnUpdate", LoginTimer)

	elseif event == "BANKFRAME_OPENED" then
		-- Set a flag to let other parts of the code know the bank is available.
		bank_shown = true
		UpdateBagMap()
		if not bank_bar then
			CreateBagBar(true)
			UpdateBankBagBarPurchase()
			bank_bar = true
		end
		DisplayContainer(recBagsBag)
		if recBagsBagBar:IsShown() then
			DisplayBar(recBagsBagBar)
		end
		DisplayContainer(recBagsBank)
		UpdateBankBagBar()
		if recBagsAmmoBag:IsShown() then
			DisplayContainer(recBagsAmmoBag)
		end
		if recBagsKeyringBag:IsShown() then
			DisplayKeys()
		end

	elseif event == "BANKFRAME_CLOSED" then
		-- Set our bank flag
		bank_shown = false
		CloseBags()

	elseif event == "BAG_UPDATE" then
		if not bags_ready then return end
		if recBagsBag:IsShown() then
			UpdateBagMap()
			DisplayContainer(recBagsBag)
			UpdateBagBar()
		end
		if recBagsBank:IsShown() then
			DisplayContainer(recBagsBank)
		end
		if recBagsAmmoBag:IsShown() then
			DisplayContainer(recBagsAmmoBag)
		end
		if recBagsKeyringBag:IsShown() then
			DisplayKeys(recBagsKeyringBag)
		end
		PopulateSlots(false)
	elseif event == "BAG_CLOSED" then
		-- A bag in the bag bar was moved/removed
	elseif event == "PLAYERBANKSLOTS_CHANGED" then
		if arg1 > NUM_BANKGENERIC_SLOTS then
			UpdateBankBagBar()
			if bank_shown then
				if recBagsBankBagBar:IsShown() then
					DisplayBar(recBagsBankBagBar)
				end
			end
		else
			-- player moved an item in the bank
			PopulateSlots(true)
		end
	elseif event == "PLAYERBANKBAGSLOTS_CHANGED" then
		UpdateBankBagBar()
		UpdateBankBagBarPurchase()
		if recBagsBankBagBar:IsShown() then
			DisplayBar(recBagsBankBagBar)
		end
	elseif event == "BAG_UPDATE_COOLDOWN" or event == "ITEM_LOCK_CHANGED" then
		if recBagsBank:IsShown() then
			DisplayContainer(recBagsBank)
			if recBagsBankBagBar:IsShown() then
				DisplayBar(recBagsBankBagBar)
			end
			PopulateSlots(true)
		end
		if recBagsBag:IsShown() then
			DisplayContainer(recBagsBag)
			if recBagsBagBar:IsShown() then
				DisplayBar(recBagsBagBar)
			end
			if recBagsKeyringBag:IsShown() then
				DisplayKeys(recBagsKeyringBag)
			end
			PopulateSlots(false)
		end
		if recBagsAmmoBag:IsShown() then
			DisplayContainer(recBagsAmmoBag)
			PopulateSlots()
		end
	end
end

recBags:SetScript("OnEvent", OnEvent)
recBags:RegisterEvent("PLAYER_ENTERING_WORLD")
recBags:RegisterEvent("BANKFRAME_OPENED")
recBags:RegisterEvent("BANKFRAME_CLOSED")
recBags:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
recBags:RegisterEvent("BAG_UPDATE")
recBags:RegisterEvent("BAG_CLOSED")
recBags:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED") -- Fired when player buys a bag slot
recBags:RegisterEvent("BAG_UPDATE_COOLDOWN")		-- Fired when an item cooldown needs to be updated
recBags:RegisterEvent("ITEM_LOCK_CHANGED")		-- Fired when items get locked (item in trade, auction etc)

-- Override blizzard versions
ToggleBackpack	= ToggleBags
ToggleBag		= ToggleBags
OpenAllBags		= ToggleBags
CloseAllBags	= CloseBags
OpenBackpack	= OpenBags
CloseBackpack	= CloseBags
BankFrame:UnregisterAllEvents()

CloseBags()

tinsert(UISpecialFrames,"recBagsBag")
tinsert(UISpecialFrames,"recBagsBank")
tinsert(UISpecialFrames,"recBagsBagBar")
tinsert(UISpecialFrames,"recBagsBankBagBar")
tinsert(UISpecialFrames,"recBagsAmmoBag")
tinsert(UISpecialFrames,"recBagsKeyringBag")