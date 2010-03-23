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

local Spacing = 2
local Columns = 10
local NumBags = 5
local NumBankBags = 7
local BankColumns = 20

local _G = getfenv(0)
local bu, container, col, row
local buttons, bankbuttons = {}, {}
local firstopened, firstbankopened = 1, 1

--[[ Function to move buttons ]]
local MoveButtons = function(table, frame, columns)
	col, row = 0, 0
	for i = 1, #table do
		bu = table[i]
		bu:ClearAllPoints()
		bu:SetPoint("TOPLEFT", frame, "TOPLEFT", col * (37 + Spacing) + 2, -1 * row * (37 + Spacing) - 1)
		bu.SetPoint = dummy
--		bu:SetNormalTexture([=[Interface\Addons\caelMedia\Buttons\buttonborder3.tga]=])
		if(col > (columns - 2)) then
			col = 0
			row = row + 1
		else
			col = col + 1
		end
	end

	frame:SetHeight((row + (col==0 and 0 or 1)) * (37 + Spacing) + 16 + 3)
	frame:SetWidth(columns * 37 + Spacing * (columns - 1) + 3)
end

--[[ Bags ]]
caelBags.bags = CreateFrame("Button", nil, UIParent)
caelBags.bags:SetPoint("TOPRIGHT", UIParent, "RIGHT", -15, 0)
caelBags.bags:SetFrameStrata("HIGH")
caelBags.bags:Hide()
caelBags.bags:SetBackdrop(backdrop)
caelBags.bags:SetBackdropColor(0, 0, 0, 0.7)

local ReanchorButtons = function()
	if firstopened == 1  then
		for f = 1, NumBags do
			container = "ContainerFrame"..f
			_G[container]:EnableMouse(false)
			_G[container.."CloseButton"]:Hide()
			_G[container.."PortraitButton"]:EnableMouse(false)

			for i = 1, 7 do
				select(i, _G[container]:GetRegions()):SetAlpha(0)
			end

			for i = GetContainerNumSlots(f-1), 1, -1  do
				bu = _G[container.."Item"..i]
				bu:SetFrameStrata("HIGH")
				tinsert(buttons, bu)
			end
		end
		MoveButtons(buttons, caelBags.bags, Columns)
		firstopened = 0
	end
	caelBags.bags:Show()
end

local money = _G["ContainerFrame1MoneyFrame"]
money:SetFrameStrata("DIALOG")
money:SetParent(caelBags.bags)
money:ClearAllPoints()
money:SetPoint("BOTTOMRIGHT", caelBags.bags, "BOTTOMRIGHT", 12, 2)

--[[ Bank ]]
caelBags.bank = CreateFrame("Button", nil, UIParent)
caelBags.bank:SetFrameStrata("HIGH")
caelBags.bank:Hide()
caelBags.bank:SetBackdrop(backdrop)
caelBags.bank:SetBackdropColor(0, 0, 0, 0.7)

local ReanchorBankButtons = function()
	if firstbankopened == 1 then
		for f = 1, 28 do
			bu = _G["BankFrameItem"..f]
			bu:SetFrameStrata("HIGH")
			tinsert(bankbuttons, bu)
		end
		_G["BankFrame"]:EnableMouse(false)
		_G["BankCloseButton"]:Hide()

		for f = 1, 5 do
			select(f, _G["BankFrame"]:GetRegions()):SetAlpha(0)
		end

		for f = NumBags + 1, NumBags + NumBankBags, 1 do
			container = "ContainerFrame"..f
			_G[container]:EnableMouse(false)
			_G[container.."CloseButton"]:Hide()
			_G[container.."PortraitButton"]:EnableMouse(false)

			for i = 1, 7 do
				select(i, _G[container]:GetRegions()):SetAlpha(0)
			end

			for i = GetContainerNumSlots(f-1), 1, -1  do
				bu = _G[container.."Item"..i]
				bu:SetFrameStrata("HIGH")
				tinsert(bankbuttons, bu)
			end
		end
		MoveButtons(bankbuttons, caelBags.bank, BankColumns)
		caelBags.bank:SetPoint("BOTTOMRIGHT", caelBags.bags, "BOTTOMLEFT", -15 , 0)
		firstbankopened = 0
	end
	caelBags.bank:Show()
end

local money = _G["BankFrameMoneyFrame"]
money:SetFrameStrata("DIALOG")
money:ClearAllPoints()
money:SetPoint("BOTTOMRIGHT", caelBags.bank, "BOTTOMRIGHT", 12, 2)

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

hooksecurefunc(_G["ContainerFrame"..NumBags], "Show", ReanchorButtons)
hooksecurefunc(_G["ContainerFrame"..NumBags], "Hide", CloseBags)
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