--[[	$Id$	]]

local _, caelBags = ...

local dummy = function() end

-- Sizing
local numBagColumns = 10
local numBankColumns = 20
local buttonSize = 30
local buttonSpacing = -2

-- Margins
local bottomMargin = 30
local sideMargin   = 5
local topMargin    = 5

-- Local copies of oft used vars.
local _G = getfenv(0)
local format = string.format

-- Slot mapping tables.
local ammoButtons, backpackButtons, bankButtons = {}, {}, {}

-- Container Frames
local backpack = CreateFrame("Frame", "recBagsBackpack", UIParent)
local ammo     = CreateFrame("Frame", "recBagsAmmo", UIParent)
local bank     = CreateFrame("Frame", "recBagsBank", UIParent)

-- TODO: Implement this.
BankFramePurchaseInfo:Hide()
BankFramePurchaseInfo.Show = dummy

-- Set up the backpack container
backpack:SetBackdrop(caelMedia.backdropTable)
backpack:SetBackdropColor(0, 0, 0, 0.7)
backpack:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
backpack:SetPoint("TOPRIGHT", UIParent, "RIGHT", -15, 0)
backpack:SetFrameStrata("HIGH")
backpack:Hide()

-- Set up ammo container.
ammo:SetFrameStrata("HIGH")
ammo:Hide()
ammo:SetBackdrop(caelMedia.backdropTable)
ammo:SetBackdropColor(0, 0, 0, 0.7)
ammo:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
ammo:SetPoint("BOTTOMRIGHT", backpack, "TOPRIGHT")
ammo:SetFrameStrata("HIGH")
ammo:Hide()

-- Set up bank container.
bank:SetFrameStrata("HIGH")
bank:Hide()
bank:SetBackdrop(caelMedia.backdropTable)
bank:SetBackdropColor(0, 0, 0, 0.7)
bank:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
bank:SetPoint("BOTTOMRIGHT", backpack, "BOTTOMLEFT")
bank:SetFrameStrata("HIGH")
bank:Hide()

-- Creates a button which will be used for things like the A/S button.
local function CreateToggleButton(name, caption, parent)
	local bu = CreateFrame("Button", name, parent, nil)
	bu:SetText(caption)
	bu:SetWidth(50)
	bu:SetHeight(20)
	bu:SetNormalFontObject(GameFontNormalSmall)
	bu:SetBackdrop(caelMedia.backdropTable)
	bu:SetBackdropColor(0, 0, 0, 1)
	bu:SetBackdropBorderColor(.5, .5, .5, 1)
	return bu
end

-- Functions which hide/show container frames and buttons.
local function hideFrame(frame)
	frame:Hide()
	for k,v in pairs(string.find(frame:GetName(), "Ammo") and ammoButtons or string.find(frame:GetName(), "Bank") and bankButtons or string.find(frame:GetName(), "Backpack") and backpackButtons) do
		v:Hide()
	end
end

local function showFrame(frame)
	frame:Show()
	for k,v in pairs(string.find(frame:GetName(), "Ammo") and ammoButtons or string.find(frame:GetName(), "Bank") and bankButtons or string.find(frame:GetName(), "Backpack") and backpackButtons) do
		v:Show()
	end
end

-- Create A/S toggle button.
local ammoButton = CreateToggleButton("ammoButton", "A / S", backpack)
ammoButton:SetPoint("BOTTOMLEFT", backpack, "BOTTOMLEFT", 5, 5)
ammoButton:SetScript("OnClick", function()
	if ammo:IsShown() then
		hideFrame(ammo)
	else
		showFrame(ammo)
	end
end)

-- Helper functions for nullifying frames/functions
local Kill = function(object)
	local object_reference = object
	if type(object) == "string" then
		object_reference = _G[object]
	else
		object_reference = object
	end
	if not object_reference then return end
	if type(object_reference) == "frame" then
		object_reference:UnregisterAllEvents()
	end
	object_reference.Show = dummy
	object_reference:Hide()
end

-- Disable all blizzard textures and interactions that we don't want.
updateContainerFrameAnchors = dummy
Kill(ContainerFrame1MoneyFrame)
Kill(BankFrameMoneyFrame)

local function DisableBlizzard(cf)
	cf:ClearAllPoints()
	cf:SetPoint("TOPRIGHT", 9001, 9001)
	cf:EnableMouse(false)
	_G[format("%sCloseButton", cf:GetName())]:Hide()
	_G[format("%sPortraitButton", cf:GetName())]:EnableMouse(false)
	for regionIndex = 1, 7 do
		select(regionIndex, cf:GetRegions()):SetAlpha(0)
	end
end

for i = 1, NUM_CONTAINER_FRAMES do
	DisableBlizzard(_G[format("ContainerFrame%d", i)])
end

do
	BankFrame:ClearAllPoints()
	BankFrame:SetPoint("TOPRIGHT", 9001, 9001)
	BankFrame.SetPoint = dummy
	BankFrame:EnableMouse(false)
	BankCloseButton:Hide()

	for f = 1, 5 do
		select(f, BankFrame:GetRegions()):SetAlpha(0)
	end
end

-- Helper function to find out what kind of bag the id references.
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

-- Positions bag slot buttons.
local function PlaceButtons(buttonTable, bagFrame, containerColumns)
	local col, row = 0, 0
	for _, bu in pairs(buttonTable) do
		--bu:SetParent(bagFrame)
		local na = bu:GetName()
		local nt = _G[format("%sNormalTexture", na)]
		local co = _G[format("%sCount", na)]
		local ic = _G[format("%sIconTexture", na)]
		local qt = _G[na.."IconQuestTexture"]

		-- Hide that ugly new quest border
		qt:Hide()
		qt.Show = dummy
		
		-- Replace textures
		bu:SetNormalTexture(caelMedia.files.buttonNormal)
		bu:SetPushedTexture(caelMedia.files.buttonPushed)
		bu:SetHighlightTexture(caelMedia.files.buttonHighlight)
		
		-- Set size and position of the button itself
		bu:SetWidth(buttonSize)
		bu:SetHeight(buttonSize)
		bu:ClearAllPoints()
		bu:SetPoint("TOPLEFT", bagFrame, "TOPLEFT", (col * (buttonSize + buttonSpacing)) + sideMargin, -1 * row * (buttonSize + buttonSpacing) - topMargin)
		-- Do not let others move the button
		--bu.SetPoint = dummy
		
		-- Size and position the NormalTexture (the "frame" around the button)
		nt:SetHeight(buttonSize)
		nt:SetWidth(buttonSize)
		nt:ClearAllPoints()
		nt:SetPoint("CENTER")
		
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
		co:SetPoint("BOTTOMRIGHT", bu, -1, 3)
		co:SetFont([=[Interface\Addons\caelMedia\fonts\xenara rg.ttf]=], 10, "OUTLINE")
		
		if(col > (containerColumns - 2)) then
			col = 0
			row = row + 1
		else
			col = col + 1
		end
		bu:Hide()
	end
	bagFrame:SetHeight((row + (col==0 and 0 or 1)) * (buttonSize + buttonSpacing) + (string.find(bagFrame:GetName(), "Ammo") and topMargin or bottomMargin) + topMargin)
	bagFrame:SetWidth(containerColumns * buttonSize + buttonSpacing * (containerColumns - 1) + (2 * sideMargin))
end

-- We have to have a delay when opening the bags (1/4 second) due to the way we set up the bags.
local updateFrame = CreateFrame("Frame")
local timer = .125
local function UpdateBag(self, elapsed)
	timer = timer - elapsed
	if timer <= 0 then
		updateFrame:SetScript("OnUpdate", nil)
		timer = 0.01
		wipe(ammoButtons)
		wipe(backpackButtons)
		wipe(bankButtons)
		for i = 1, NUM_CONTAINER_FRAMES do
			local cf = _G[format("ContainerFrame%d", i)]
			local bagID = cf:GetID()
			if bagID < 100 then
				local numSlots = GetContainerNumSlots(bagID)
				if bagID > -1 and bagID < 5 then
					local bagType = GetBagType(bagID)
					if bagType == "ammo" then
						-- This is an ammo bag slot
						for slotIndex = numSlots, 1, -1 do
							local bu = _G[format("%sItem%s", cf:GetName(), slotIndex)]
							bu:SetFrameStrata("HIGH")
							--bu:SetParent(ammo)
							tinsert(ammoButtons, bu)
						end
					else
						-- This is a regular bag slot
						for slotIndex = numSlots, 1, -1 do
							local bu = _G[format("%sItem%s", cf:GetName(), slotIndex)]
							--bu:SetParent(backpack)
							bu:SetFrameStrata("HIGH")
							tinsert(backpackButtons, bu)
						end
					end
				elseif bagID > 4 and bagID < 100 then
					-- This is a bank slot
					for slotIndex = numSlots, 1, -1 do
						local bu = _G[format("%sItem%s", cf:GetName(), slotIndex)]
						--bu:SetParent(bank)
						bu:SetFrameStrata("HIGH")
						tinsert(bankButtons, bu)
					end
				end
			end
		end
		if BankFrame and BankFrame:IsShown() then
			local bagID = -1
			local numSlots = GetContainerNumSlots(bagID)
			for f = 1, 28 do
				local bu = _G[format("BankFrameItem%s", f)]
				--bu:SetParent(bank)
				bu:SetFrameStrata("HIGH")
				tinsert(bankButtons, bu)
			end
		end
		
		PlaceButtons(ammoButtons, ammo, 10)
		PlaceButtons(backpackButtons, backpack, 10)
		PlaceButtons(bankButtons, bank, 12)
		
		-- Show backpack
		showFrame(backpack)
		if ammo:IsShown() then
			hideFrame(ammo)
			showFrame(ammo)
		end
		-- Only show bank if blizzard bank is shown
		if BankFrame:IsShown() then
			showFrame(bank)
		end
	end
end

-- Allow containers to be closed on Esc press.
tinsert(UISpecialFrames, ammo)
tinsert(UISpecialFrames, bank)
tinsert(UISpecialFrames, backpack)

-- Functions to open/close all bags.
local CloseBags = function()
	hideFrame(bank)
	hideFrame(ammo)
	hideFrame(backpack)
	for i = 0, 11 do
		CloseBag(i)
	end
	if BankFrame:IsShown() then
		CloseBankFrame()
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

-- Using this flag, we only do the 1/4 second delay on first bag opening.
-- To be honest, I'm not sure if this should be here still
-- TODO: Check removing this flag. As you see, the bank frame doesn't use it...
local updateDone = false
-- Give a slight delay (1/4 second) so all bags will register as open.
for i = 1, NUM_CONTAINER_FRAMES do
	hooksecurefunc(_G[format("ContainerFrame%d", i)], "Show", function() --if not updateDone then updateDone = true;
		updateFrame:SetScript("OnUpdate", UpdateBag) -- end
	end)
	hooksecurefunc(_G[format("ContainerFrame%d", i)], "Hide", function() updateDone = false; CloseBags() end)
end

hooksecurefunc(BankFrame, "Show", function()
	OpenBags()
	updateFrame:SetScript("OnUpdate", UpdateBag)
end)

hooksecurefunc(BankFrame, "Hide", CloseBags)

-- Remap Blizzard bag functions.
ToggleBackpack = ToggleBags
OpenAllBags    = ToggleBags
OpenBackpack   = OpenBags
CloseBackpack  = CloseBags
CloseAllBags   = CloseBags