--[[	$Id$	]]

local _, caelBags = ...

local bgTexture = [=[Interface\ChatFrame\ChatFrameBackground]=]
local glowTexture = [=[Interface\Addons\caelMedia\Miscellaneous\glowtex]=]
local backdrop = {
	bgFile = bgTexture,
	edgeFile = glowTexture, edgeSize = 3,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
}

local dummy = function() end

local Spacing = 2
local Columns = 10
local NumBags = 5
local NumBankBags = 7
local BankColumns = 20

local _G = getfenv(0)
local bu, con, col, row
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
		bu:SetNormalTexture([=[Interface\Addons\caelMedia\Buttons\buttonborder3.tga]=])
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
local holder = CreateFrame("Button", "caelBagsHolder", UIParent)
holder:SetPoint("TOPLEFT", UIParent, "CENTER", -50, 50)
holder:SetFrameStrata("HIGH")
holder:Hide()
holder:SetBackdrop(backdrop)
holder:SetBackdropColor(0, 0, 0, 0.7)

local ReanchorButtons = function()
	if firstopened == 1  then
		for f = 1, NumBags do
			con = "ContainerFrame"..f
			_G[con]:EnableMouse(false)
			_G[con.."CloseButton"]:Hide()
			_G[con.."PortraitButton"]:EnableMouse(false)

			for i = 1, 7 do
				select(i, _G[con]:GetRegions()):SetAlpha(0)
			end

			for i = GetContainerNumSlots(f-1), 1, -1  do
				bu = _G[con.."Item"..i]
				bu:SetFrameStrata("HIGH")
				tinsert(buttons, bu)
			end
		end
		MoveButtons(buttons, holder, Columns)
		firstopened = 0
	end
	holder:Show()
end

local money = _G["ContainerFrame1MoneyFrame"]
money:SetFrameStrata("DIALOG")
money:SetParent(holder)
money:ClearAllPoints()
money:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 12, 2)

--[[ Bank ]]
local bankholder = CreateFrame("Button", "caelBagsBankHolder", UIParent)
bankholder:SetFrameStrata("HIGH")
bankholder:Hide()
bankholder:SetBackdrop(backdrop)
bankholder:SetBackdropColor(0, 0, 0, 0.7)

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
			con = "ContainerFrame"..f
			_G[con]:EnableMouse(false)
			_G[con.."CloseButton"]:Hide()
			_G[con.."PortraitButton"]:EnableMouse(false)

			for i = 1, 7 do
				select(i, _G[con]:GetRegions()):SetAlpha(0)
			end

			for i = GetContainerNumSlots(f-1), 1, -1  do
				bu = _G[con.."Item"..i]
				bu:SetFrameStrata("HIGH")
				tinsert(bankbuttons, bu)
			end
		end
		MoveButtons(bankbuttons, bankholder, BankColumns)
		bankholder:SetPoint("BOTTOMRIGHT", "caelBagsHolder", "BOTTOMLEFT", -10 , 0)
		firstbankopened = 0
	end
	bankholder:Show()
end

local money = _G["BankFrameMoneyFrame"]
money:SetFrameStrata("DIALOG")
money:ClearAllPoints()
money:SetPoint("BOTTOMRIGHT", bankholder, "BOTTOMRIGHT", 12, 2)

--[[ Hiding misc. frames ]]
_G["BankFramePurchaseInfo"]:Hide()
_G["BankFramePurchaseInfo"].Show = dummy

for f = 1, 7 do _G["BankFrameBag"..f]:Hide() end

--[[ Show & Hide functions etc ]]
tinsert(UISpecialFrames, bankholder)
tinsert(UISpecialFrames, holder)

local CloseBags = function()
	bankholder:Hide()
	holder:Hide()
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