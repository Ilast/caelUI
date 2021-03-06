--[[	$Id$	]]

local _, caelBags = ...

local bagButtons = {}
bagButtons[0] = "MainMenuBarBackpackButton"
bagButtons[1] = "CharacterBag0Slot"
bagButtons[2] = "CharacterBag1Slot"
bagButtons[3] = "CharacterBag2Slot"
bagButtons[4] = "CharacterBag3Slot"
bagButtons[5] = "BankFrameBag1"
bagButtons[6] = "BankFrameBag2"
bagButtons[7] = "BankFrameBag3"
bagButtons[8] = "BankFrameBag4"
bagButtons[9] = "BankFrameBag5"
bagButtons[10] = "BankFrameBag6"
bagButtons[11] = "BankFrameBag7"

local bagBar, bagsButton
local bankBagBar, bankBagsButton
local buySlotCost, buySlotButton
local bagBarReady, bankBagBarReady

local function CreateContainerFrame(name)
    local f = CreateFrame("Frame", name, UIParent)
    f:SetFrameStrata("HIGH")
    f:SetBackdrop(caelMedia.backdropTable)
    f:SetBackdropColor(0, 0, 0, 0.7)
    f:SetBackdropBorderColor(0, 0, 0)
    return f
end

local function SkinButton(b)
	b:SetSize(caelLib.scale(54), caelLib.scale(18))
	b:SetNormalFontObject(GameFontNormalSmall)
--	b:SetNormalTexture(caelMedia.files.buttonNormal)
--	b:SetPushedTexture(caelMedia.files.buttonPushed)
--	b:SetHighlightTexture(caelMedia.files.buttonHighlight, "ADD")
	b:SetBackdrop(caelMedia.backdropTable)
	b:SetBackdropColor(0, 0, 0, 0.7)
	b:SetBackdropBorderColor(0, 0, 0)
end
	

local CreateToggleButton = function (name, caption, parent)
	local b = CreateFrame("Button", name, parent, nil)
	b:SetText(caption)
	SkinButton(b)
	
	return b
end

local function BagString(num)
    return string.format("Bag%d", num)
end

bagBar = CreateContainerFrame("bagBar")
bagBar:SetPoint("TOPLEFT", caelBagsbag, "BOTTOMLEFT", 0, 0)
bagBar:SetPoint("BOTTOMRIGHT", caelBagsbag, "BOTTOMRIGHT", 0, caelLib.scale(-35))
bagBar.buttons = {}

bankBagBar = CreateContainerFrame("bankBagBar")
bankBagBar:SetPoint("TOPLEFT", caelBagsbank, "BOTTOMLEFT", 0, 0)
bankBagBar:SetPoint("BOTTOMRIGHT", caelBagsbank, "BOTTOMRIGHT", 0, caelLib.scale(-35))
bankBagBar.buttons = {}

function bankBagBar:Update() 
	local numSlots, full = GetNumBankSlots();
	local button;
	for i = 1, #self.buttons do
		button = self.buttons[i]
		if ( button ) then
			if ( i <= numSlots ) then
				SetItemButtonTextureVertexColor(button, 1, 1, 1);
				button.tooltipText = BANK_BAG;
			else
				SetItemButtonTextureVertexColor(button, 1, 0.1, 0.1);
				button.tooltipText = BANK_BAG_PURCHASE;
			end
		end
	end

	-- pass in # of current slots, returns cost of next slot
	if not full then
		local cost = GetBankSlotCost(numSlots);
		if( GetMoney() >= cost ) then
			SetMoneyFrameColor("BankFrameDetailMoneyFrame", "white");
		else
			SetMoneyFrameColor("BankFrameDetailMoneyFrame", "red")
		end
		MoneyFrame_Update("BankFrameDetailMoneyFrame", cost);
		
		self.buySlotButton:Show()
		self.buySlotCost:Show()
	else
		self.buySlotButton:Hide()
		self.buySlotCost:Hide()
	end
end

function bankBagBar:init()
	local buySlotButton = BankFramePurchaseButton
	buySlotButton:SetParent(self)
	SkinButton(buySlotButton)
	buySlotButton:GetNormalTexture():SetTexCoord(0, 1, 1, 0)
	buySlotButton:GetHighlightTexture():SetTexCoord(0, 1, 1, 0)
	buySlotButton:GetPushedTexture():SetTexCoord(0, 1, 1, 0)
	buySlotButton:ClearAllPoints()
	buySlotButton:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 5, 5 * 2)
	self.buySlotButton = buySlotButton

	local buySlotCost = BankFrameDetailMoneyFrame
	buySlotCost:ClearAllPoints()
	buySlotCost:SetParent(self)
	buySlotCost:SetPoint("LEFT", buySlotButton, "RIGHT", 0, 0)
	self.buySlotCost = buySlotCost
	
	bankBagBar:SetScript("OnShow", function(self) self:RegisterEvent("PLAYER_MONEY") self:Update() end)
	bankBagBar:SetScript("OnHide", function(self) self:UnregisterEvent("PLAYER_MONEY") end)
	bankBagBar:SetScript("OnEvent", bankBagBar.Update)
	bankBagBar:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
end

local function CreateBagBar(bank)
    local start_bag = bank and 5 or 0
    local end_bag = bank and 11 or 4
    local bag_index = 0

    local bar = bank and bankBagBar or bagBar
    
    for bag = start_bag, end_bag do
        local name = bagButtons[bag]
	local b = _G[name]

	b:SetSize(caelLib.scale(24), caelLib.scale(24))

	b:Show()
	b.Bar = bar
	b:SetParent(bar)

        b.Icon = _G[name.."IconTexture"]
        b.Icon:SetSize(caelLib.scale(28), caelLib.scale(28))
	
        b.NormalTexture = _G[name.."NormalTexture"]
        b:SetNormalTexture(caelMedia.files.buttonNormal)
        b.NormalTexture:SetSize(caelLib.scale(28), caelLib.scale(28))
	
	if not bank then
		b:SetCheckedTexture(nil)
	else
		_G[name.."HighlightFrameTexture"]:SetTexture(nil)
	end
	
	b:ClearAllPoints()
        b:SetPoint("RIGHT", bar, "RIGHT", caelLib.scale(bag_index * -28 - 5 * 2 - 4 * bag_index) , 1.5)
	tinsert(bar.buttons, b)
	
        bag_index = bag_index + 1
    end
    
    if not bank then
	-- Give the keychain button a place.
	local button = KeyRingButton
	button:SetParent(bar)
	button:SetScale(0.675)
	button:ClearAllPoints()
	button:SetPoint("BOTTOMRIGHT", CharacterBag3Slot, "BOTTOMLEFT", -10, -3)
	button.bar = bar
    end
    
    if bar.init then
	bar:init()
    end
    
end

bagsButton = CreateToggleButton("bagsButton", "Bag Bar", caelBagsbag)
bagsButton:SetPoint("BOTTOMRIGHT", caelBagsbag, "BOTTOMRIGHT", caelLib.scale(-5), caelLib.scale(5))
bagsButton:SetScript("OnClick", function(self)
    if not self.ready then
	CreateBagBar()
	self.ready = true
    end
    
    if bagBar:IsShown() then
        bagBar:Hide()
    else
        bagBar:Show()
    end
end)

bankBagsButton = CreateToggleButton("bankBagsButton", "Bag Bar", caelBagsbank)
bankBagsButton:SetPoint("BOTTOMRIGHT", caelBagsbank, "BOTTOMRIGHT", caelLib.scale(-5), caelLib.scale(5))
bankBagsButton:SetScript("OnClick", function(self)
    if not self.ready then
	CreateBagBar(true)
	self.ready = true
    end
    
    if bankBagBar:IsShown() then
        bankBagBar:Hide()
    else
        bankBagBar:Show()
    end
end)

caelBagsbag:HookScript("OnHide", function() bagBar:Hide() end)
caelBagsbank:HookScript("OnHide", function() bankBagBar:Hide() end)
caelBagsbag:HookScript("OnShow", function() bagBar:Hide() end)
caelBagsbank:HookScript("OnShow", function() bankBagBar:Hide() end)