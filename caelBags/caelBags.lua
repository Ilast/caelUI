--[[	$Id$	]]

local _, caelBags = ...

local bgTexture = [=[Interface\ChatFrame\ChatFrameBackground]=]
local glowTexture = [=[Interface\Addons\caelMedia\Miscellaneous\glowtex]=]
local backdrop = {
	bgFile = bgTexture,
	edgeFile = glowTexture, edgeSize = 2,
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local dummy = function() end

-- Bag counts
local numBags = NUM_BAG_FRAMES + 1 -- slots + backpack
local numBankBags = NUM_CONTAINER_FRAMES - numBags

-- Sizing
local numBagColumns = 10
local numBankColumns = 20
local buttonSize = 30
local buttonSpacing = -2

-- Margins
local bottomMargin = -4
local sideMargin   = 10
local topMargin    = 10

local _G = getfenv(0)
local format = string.format
local bu, con, col, row
local backpackButtons, bankbuttons = {}, {}
local firstOpening, firstBankOpening = true, true

--[[ Function to move buttons ]]
local MoveButtons = function(buttonTable, bagFrame, containerColumns)
	col, row = 0, 0
	for i = 1, #buttonTable do
		bu = buttonTable[i]
		local na = bu:GetName()
		local nt = _G[format("%sNormalTexture", na)]
		local co = _G[format("%sCount", na)]
		local ic = _G[format("%sIconTexture", na)]

		-- Replace textures
		bu:SetNormalTexture([=[Interface\AddOns\caelMedia\Buttons\buttonborder1]=])
		bu:SetPushedTexture([=[Interface\AddOns\caelMedia\Buttons\buttonborder1pushed]=])
		bu:SetHighlightTexture([=[Interface\AddOns\caelMedia\Buttons\buttonborder1highlight]=])

		-- Set size and position of the button itself
		bu:SetWidth(buttonSize)
		bu:SetHeight(buttonSize)
		bu:ClearAllPoints()
		bu:SetPoint("TOPLEFT", bagFrame, "TOPLEFT", col * (buttonSize + buttonSpacing) + 2, -1 * row * (buttonSize + buttonSpacing) - 2)
		-- Do not let others move the button
		bu.SetPoint = dummy

		-- Size and position the NormalTexture (the "bagFrame" around the button)
		nt:SetHeight(buttonSize)
		nt:SetWidth(buttonSize)
		nt:ClearAllPoints()
		nt:SetPoint("CENTER")
		nt:SetVertexColor(0.84, 0.75, 0.65)
		
		-- Offset the icon image a little to remove 'round' edges
		ic:SetTexCoord(.08, .92, .08, .92)
		-- Position icon using SetPoint relative to the button.
		ic:ClearAllPoints()
		ic:SetPoint("TOPLEFT", bu, 4, -3)
		ic:SetPoint("BOTTOMRIGHT", bu, -3, 4)
		
		-- Move item count text into a readable position
		-- TODO: Perhaps there is some magic formula to figure this out?  I had to change it depending on button size.
		--     -1, 3 looked good at 30x30 backpackButtons
		--     -5, 7 looked good at 60x60 backpackButtons
		co:ClearAllPoints()
		co:SetPoint("BOTTOMRIGHT", bu, -3, 3)
		co:SetFont([=[Interface\Addons\caelMedia\Fonts\xenara rg.ttf]=], 10, "OUTLINE")

		if(col > (containerColumns - 2)) then
			col = 0
			row = row + 1
		else
			col = col + 1
		end
	end

	bagFrame:SetHeight((row + (col == 0 and 0 or 1)) * (buttonSize + buttonSpacing) + bottomMargin + topMargin)
--	bagFrame:SetWidth(containerColumns * buttonSize + buttonSpacing * (containerColumns - 1) + (2 * sideMargin))
	bagFrame:SetWidth(containerColumns * buttonSize + buttonSpacing * (containerColumns - 1) + 4)
end

--[[ Bags ]]
caelBags.bags = CreateFrame("Button", nil, UIParent)
caelBags.bags:SetPoint("TOPRIGHT", UIParent, "RIGHT", -15, 0)
caelBags.bags:SetFrameStrata("HIGH")
caelBags.bags:Hide()
caelBags.bags:SetBackdrop(backdrop)
caelBags.bags:SetBackdropColor(0, 0, 0, 0.7)
caelBags.bags:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)

local reanchorButtons = function()
	if firstOpening  then
		for f = 1, numBags do
			con = "ContainerFrame"..f
			_G[con]:EnableMouse(false)
			_G[format("%sCloseButton", con)]:Hide()
			_G[format("%sPortraitButton", con)]:EnableMouse(false)

			for i = 1, 7 do
				select(i, _G[con]:GetRegions()):SetAlpha(0)
			end

			for i = GetContainerNumSlots(f-1), 1, -1  do
				bu = _G[format("%sItem%s", con, i)]
				bu:SetFrameStrata("HIGH")
				tinsert(backpackButtons, bu)
			end
		end
		MoveButtons(backpackButtons, caelBags.bags, numBagColumns)
		firstOpening = false
	end
	caelBags.bags:Show()
end

local money = _G["ContainerFrame1MoneyFrame"]
money:Hide()
money.Show = dummy

--[[ Bank ]]
caelBags.bank = CreateFrame("Button", nil, UIParent)
caelBags.bank:SetFrameStrata("HIGH")
caelBags.bank:Hide()
caelBags.bank:SetBackdrop(backdrop)
caelBags.bank:SetBackdropColor(0, 0, 0, 0.5)
caelBags.bank:SetBackdropBorderColor(0, 0, 0, 1)

local reanchorBankButtons = function()
	if firstBankOpening then
		for f = 1, 28 do
			bu = _G[format("BankFrameItem%s", f)]
			bu:SetFrameStrata("HIGH")
			tinsert(bankbuttons, bu)
		end
		_G["BankFrame"]:EnableMouse(false)
		_G["BankCloseButton"]:Hide()

		for f = 1, 5 do
			select(f, _G["BankFrame"]:GetRegions()):SetAlpha(0)
		end

		for f = numBags + 1, numBags + numBankBags, 1 do
			con = "ContainerFrame"..f
			_G[con]:EnableMouse(false)
			_G[format("%sCloseButton", con)]:Hide()
			_G[format("%sPortraitButton", con)]:EnableMouse(false)

			for i = 1, 7 do
				select(i, _G[con]:GetRegions()):SetAlpha(0)
			end

			for i = GetContainerNumSlots(f-1), 1, -1  do
				bu = _G[format("%sItem%s", con, i)]
				bu:SetFrameStrata("HIGH")
				tinsert(bankbuttons, bu)
			end
		end
		MoveButtons(bankbuttons, caelBags.bank, numBankColumns)
		caelBags.bank:SetPoint("BOTTOMRIGHT", caelBags.bags, "BOTTOMLEFT", -15 , 0)
		firstBankOpening = false
	end
	caelBags.bank:Show()
end

local money = _G["BankFrameMoneyFrame"]
money:Hide()
money.show = dummy

--[[ Hiding misc. frames ]]
_G["BankFramePurchaseInfo"]:Hide()
_G["BankFramePurchaseInfo"].Show = dummy

for f = 1, 7 do _G[format("BankFrameBag%s", f)]:Hide() end

--[[ Show & Hide functions etc ]]
tinsert(UISpecialFrames, caelBags.bank)
tinsert(UISpecialFrames, caelBags.bags)

local closeBags = function()
	caelBags.bank:Hide()
	caelBags.bags:Hide()
	for i = 0, 11 do
		CloseBag(i)
	end
end

local openBags = function()
	for i = 0, 11 do
		OpenBag(i)
	end
end

local toggleBags = function()
	if(IsBagOpen(0)) then
		CloseBankFrame()
		closeBags()
	else
		openBags()
	end
end

hooksecurefunc(_G[format("ContainerFrame%s", numBags)], "Show", reanchorButtons)
hooksecurefunc(_G[format("ContainerFrame%s", numBags)], "Hide", closeBags)
hooksecurefunc(BankFrame, "Show", function()
	openBags()
	reanchorBankButtons()
end)
hooksecurefunc(BankFrame, "Hide", closeBags)

ToggleBackpack = toggleBags
OpenAllBags = toggleBags
OpenBackpack = openBags
CloseBackpack = closeBags
CloseAllBags = closeBags