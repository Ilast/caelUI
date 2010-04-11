--[[	$Id$	]]

if caelLib.isCharListA then return end

local _, caelBags = ...

local bagBar, bagsButton
local bankBagBar, bankBagsButton
local buySlotCost, buySlotButton
local bagBarReady, bankBagBarReady

local function CreateContainerFrame(name)
    local f = CreateFrame("Frame", name, UIParent)
    f:SetFrameStrata("HIGH")
    f:SetBackdrop(caelMedia.backdropTable)
    f:SetBackdropColor(0, 0, 0, 1)
    f:SetBackdropBorderColor(0, 0, 0, 1)
    return f
end

local function BagString(num)
    return string.format("Bag%d", num)
end

bagBar = CreateContainerFrame("bagBar")
bagBar:SetPoint("TOPLEFT", caelBagsbag, "BOTTOMLEFT", 0, 0)
bagBar:SetPoint("BOTTOMRIGHT", caelBagsbag, "BOTTOMRIGHT", 0, -45)

bankBagBar = CreateContainerFrame("bankBagBar")
bankBagBar:SetPoint("TOPLEFT", caelBagsbank, "BOTTOMLEFT", 0, 0)
bankBagBar:SetPoint("BOTTOMRIGHT", caelBagsbank, "BOTTOMRIGHT", 0, -45)

local function CreateBagBar(bank)
    local start_bag = bank and 5 or 0
    local end_bag = bank and 11 or 4
    local bag_index = start_bag

    for bag = start_bag, end_bag do
        local name
        if not bank then
            name = string.format("bagBarBag%d", bag_index)
        else
            name = string.format("bankBagBarBag%d", bag_index)
        end
        local b = CreateFrame("CheckButton", name, bank and bankBagBar or bagBar, "ItemButtonTemplate")
        b:SetWidth(28)
        b:SetHeight(28)
        b.Bar = bank and bankBagBar or bagBar
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
        b.NormalTexture:SetTexture(caelMedia.files.buttonNormal)
        b.NormalTexture:SetWidth(32)
        b.NormalTexture:SetHeight(32)
        b.NormalTexture:SetVertexColor(1, 1, 1, 1)
        b:SetPoint("RIGHT", bank and bankBagBar or bagBar, "RIGHT", ((((bag_index < 5 and bag_index or bag_index - 5) * 28) * -1) - (5*2) - (4*(bag_index < 5 and bag_index or bag_index - 5))), 0)

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
        b.Icon:SetTexture((bag_index > 0 and GetInventoryItemTexture("player", bank and b.id+63 or b.id)) or (bag_index == 0 and [[Interface\Buttons\Button-Backpack-Up]]) or empty_slot_texture)

        if bank then
            bankBagBar[BagString(bag_index)] = b
        else
            bagBar[BagString(bag_index)] = b
        end

        bag_index = bag_index + 1
    end
end

local function UpdateBagBar()
    for i=0,4 do
        local bag = bagBar[BagString(i)]
        bag.Icon:SetTexture((i > 0 and GetInventoryItemTexture("player", bag.id)) or (i == 0 and [[Interface\Buttons\Button-Backpack-Up]]) or [[interface\paperdoll\UI-PaperDoll-Slot-Bag]])
    end
end

local CreateToggleButton = function (name, caption, parent)
    local b = CreateFrame("Button", name, parent, nil)
    b:SetText(caption)
    b:SetWidth(50)
    b:SetHeight(15)
    b:SetNormalFontObject(GameFontNormalSmall)
    b:SetNormalTexture(caelMedia.files.buttonNormal)
    b:SetPushedTexture(caelMedia.files.buttonPushed)
    b:SetHighlightTexture(caelMedia.files.buttonHighlight, "ADD")
    b:SetBackdrop(caelMedia.backdropTable)
    b:SetBackdropColor(0, 0, 0, 1)
    b:SetBackdropBorderColor(.1, .1, .1, 1)
    return b
end

buySlotButton = CreateToggleButton("buySlotButton", "Purchase", bankBagBar)
buySlotButton:SetWidth(70)
buySlotButton:SetText(BANKSLOTPURCHASE)
buySlotButton:SetPoint("BOTTOMLEFT", bankBagBar, "BOTTOMLEFT", 5, 5*2)
buySlotButton:SetScript("OnClick", function()
    PlaySound("igMainMenuOption")
    StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
end)

buySlotCost = CreateFrame("Frame", "buySlotCost", bankBagBar, "SmallMoneyFrameTemplate")
buySlotCost.hidden = false
buySlotCost:SetPoint("LEFT", buySlotButton, "RIGHT", 0, 0)
SmallMoneyFrame_OnLoad(buySlotCost)
MoneyFrame_SetType(buySlotCost, "STATIC")

local function UpdateBankBagBarPurchase()
    local numSlots,full = GetNumBankSlots()
    if not full then
        local cost = GetBankSlotCost(numSlots)
        BankFrame.nextSlotCost = cost
        SetMoneyFrameColor("buySlotCost", "white")
        MoneyFrame_Update("buySlotCost", cost)
        buySlotButton:Show()
        buySlotCost:Show()
    else
        buySlotButton:Hide()
        buySlotCost:Hide()
    end
end

local function UpdateBankBagBar()
    local numSlots,full = GetNumBankSlots()
    local button
    for i=5,11 do
        button = _G[string.format("bankBagBarBag%d", i)]
        button.Icon:SetTexture((button.id and GetInventoryItemTexture("player", button.id+63)) or (i == 0 and [[Interface\Buttons\Button-Backpack-Up]]) or [[interface\paperdoll\UI-PaperDoll-Slot-Bag]])
        if (i - 4) <= numSlots then
            SetItemButtonTextureVertexColor(button, 1, 1, 1)
            button.tooltipText = "Bag Slot"
        else
            SetItemButtonTextureVertexColor(button, 1, .1, .1)
            button.tooltipText = "Purchasable Bag Slot"
        end
    end
end

local function DisplayBar(frame)
    if not bagBarReady then return end

    local is_bank = string.find(frame:GetName(), "bank") and true or false

    if is_bank then
        bankBagBar:Show()
    else
        bagBar:Show()
    end
end

bagsButton = CreateToggleButton("bagsButton", "Bag Bar", caelBagsbag)
bagsButton:SetPoint("BOTTOMRIGHT", caelBagsbag, "BOTTOMRIGHT", -5, 10)
bagsButton:SetScript("OnClick", function()
    if bagBar:IsShown() then
        bagBar:Hide()
    else
        DisplayBar(bagBar)
    end
end)

bankBagsButton = CreateToggleButton("bankBagsButton", "Bag Bar", caelBagsbank)
bankBagsButton:SetPoint("BOTTOMRIGHT", caelBagsbank, "BOTTOMRIGHT", -5, 10)
bankBagsButton:SetScript("OnClick", function()
    if bankBagBar:IsShown() then
        bankBagBar:Hide()
    else
        DisplayBar(bankBagBar)
    end
end)

caelBagsbag:HookScript("OnHide", function() bagBar:Hide() end)
caelBagsbank:HookScript("OnHide", function() bankBagBar:Hide() end)
caelBagsbag:HookScript("OnShow", function() bagBar:Hide() end)
caelBagsbank:HookScript("OnShow", function() bankBagBar:Hide() end)

local loginTimer = 1
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("BANKFRAME_OPENED")
eventFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
eventFrame:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        self:SetScript("OnUpdate", function(self, elapsed)
            loginTimer = loginTimer - elapsed
            if loginTimer <= 0 then
                CreateBagBar()
                self:SetScript("OnUpdate", nil)
                loginTimer = nil
                bagBarReady = true
            end
        end)
        return
    elseif not bankBagBarReady and event == "BANKFRAME_OPENED" then
        bankBagBarReady = true
        CreateBagBar(true)
    end

    if not bagBarReady then return end

	UpdateBagBar()
	if caelBagsbank:IsShown() then
		UpdateBankBagBar()
		UpdateBankBagBarPurchase()
	end
end)