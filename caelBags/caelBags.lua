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

local buttonSpacing = 2
local columns = 10
local numBags = 5
local numBankBags = 7
local bankColumns = 20
local buttonSize = 30

local _G = getfenv(0)
local format = string.format
local bu, con, col, row
local buttons, bankbuttons = {}, {}
local firstOpened, firstbankopened = 1, 1

--[[ Function to move buttons ]]
local MoveButtons = function(table, frame, columns)
	col, row = 0, 0
	for i = 1, #table do
		bu = table[i]
		local na = bu:GetName()
		local nt = _G[format("%sNormalTexture", na)]
		local co = _G[format("%sCount", na)]
		local ic = _G[format("%sIconTexture", na)]

		-- Replace textures
		bu:SetNormalTexture([=[Interface\AddOns\caelMedia\Buttons\buttonborder1]=])
		bu:SetPushedTexture([=[Interface\AddOns\caelMedia\Buttons\buttonborder1pushed]=])
		bu:SetHighlightTexture([=[Interface\AddOns\caelMedia\Buttons\buttonborder1highlight]=])

		bu:SetWidth(buttonSize)
		bu:SetHeight(buttonSize)
		bu:ClearAllPoints()
		bu:SetPoint("TOPLEFT", frame, "TOPLEFT", col * (buttonSize + buttonSpacing) + 2, -1 * row * (buttonSize + buttonSpacing) - 1)
		bu.SetPoint = dummy

		-- Size and position the NormalTexture (the "frame" around the button)
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
		--     -1, 3 looked good at 30x30 buttons
		--     -5, 7 looked good at 60x60 buttons
		co:ClearAllPoints()
		co:SetPoint("BOTTOMRIGHT", bu, -3, 3)
		co:SetFont([=[Interface\Addons\caelMedia\Fonts\xenara rg.ttf]=], 10, "OUTLINE")

		if(col > (columns - 2)) then
			col = 0
			row = row + 1
		else
			col = col + 1
		end
	end

	frame:SetHeight((row + (col == 0 and 0 or 1)) * (buttonSize + buttonSpacing) + 16 + 3)
	frame:SetWidth(columns * buttonSize + buttonSpacing * (columns - 1) + 3)
end

--[[ Bags ]]
caelBags.bags = CreateFrame("Button", nil, UIParent)
caelBags.bags:SetPoint("TOPRIGHT", UIParent, "RIGHT", -15, 0)
caelBags.bags:SetFrameStrata("HIGH")
caelBags.bags:Hide()
caelBags.bags:SetBackdrop(backdrop)
caelBags.bags:SetBackdropColor(0, 0, 0, 0.7)
caelBags.bags:SetBackdropBorderColor(0, 0, 0, 1)

local ReanchorButtons = function()
	if firstOpened == 1  then
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
				tinsert(buttons, bu)
			end
		end
		MoveButtons(buttons, caelBags.bags, columns)
		firstOpened = 0
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
caelBags.bank:SetBackdropColor(0.15, 0.15, 0.15, 1)
caelBags.bank:SetBackdropBorderColor(0, 0, 0, 1)

local ReanchorBankButtons = function()
	if firstbankopened == 1 then
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
		MoveButtons(bankbuttons, caelBags.bank, bankColumns)
		caelBags.bank:SetPoint("BOTTOMRIGHT", caelBags.bags, "BOTTOMLEFT", -15 , 0)
		firstbankopened = 0
	end
	caelBags.bank:Show()
end

local money = _G["BankFrameMoneyFrame"]
money:Hide()
money.show = dummy

--[[ Hiding misc. frames ]]
_G["BankFramePurchaseInfo"]:Hide()
_G["BankFramePurchaseInfo"].Show = dummy

for f = 1, 7 do _G["BankFrameBag"..f]:Hide() end

--[[ Show & Hide functions etc ]]
tinsert(UISpecialFrames, caelBags.bank)
tinsert(UISpecialFrames, caelBags.bags)

local CloseBags = function()
	caelBags.bank:Hide()
	caelBags.bags:Hide()
	for i = 0, 11 do
		CloseBag(i)
	end
end

local OpenBags = function()
	for i = 0, 11 do
		OpenBag(i)
	end
end

local ToggleBags = function()
	if(IsBagOpen(0)) then
		CloseBankFrame()
		CloseBags()
	else
		OpenBags()
	end
end

hooksecurefunc(_G["ContainerFrame"..numBags], "Show", ReanchorButtons)
hooksecurefunc(_G["ContainerFrame"..numBags], "Hide", CloseBags)
--hooksecurefunc(_G[format("ContainerFrame%s", NumBags)], "Show", ReanchorButtons)
--hooksecurefunc(_G[format("ContainerFrame%s", NumBags)], "Hide", CloseBags)
hooksecurefunc(BankFrame, "Show", function()
	OpenBags()
	ReanchorBankButtons()
end)
hooksecurefunc(BankFrame, "Hide", CloseBags)

ToggleBackpack = ToggleBags
OpenAllBags = ToggleBags
OpenBackpack = OpenBags
CloseBackpack = CloseBags
CloseAllBags = CloseBags