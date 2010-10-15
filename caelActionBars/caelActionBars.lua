--[[	$Id$	]]
--[[
-- Action Bars
--
-- Credits:
-- 	Tukz and Caellian
--
-- Rewritten by:
-- 	Jankly
--
--]]

---------------------------------------------
-- Local variable settings for action bars.
---------------------------------------------

local actionBar = {
	["settings"] = {
		["mouseOverBar1"] = false,
		["mouseOverBar2"] = false,
		["mouseOverBar3"] = false,
		["mouseOverBar4"] = false,
		["mouseOverBar5"] = false,
		["mouseOverPetBar"] = true,
		["mouseOverShapeshiftBar"] = false,
		["showGrid"] = true,
	},
}

----------------------------------
-- DO NOT TOUCH THESE VARIABLES!
----------------------------------

-- Global variable
local _G = getfenv(0)

-----------------------------------------------
-- Hide default Blizzard frames we don't need
-----------------------------------------------

do

	-- Frame List
	local elements = {
		MainMenuBar, MainMenuBarArtFrame, BonusActionBarFrame, VehicleMenuBar,
		PossessBarFrame, PetActionBarFrame,
		ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRigth,
	}

	for _, element in pairs(elements) do
		if element:GetObjectType() == "Frame" then
			element:UnregisterAllEvents()
		end
		element:Hide()
		element:SetAlpha(0)
	end
	elements = nil

	-- UI Parent Manager frame nil'ing

	-- Frame List
	local uiManagedFrames = {
		"MultiBarLeft", "MultiBarRight", "MultiBarBottomLeft", "MultiBarBottomRight",
		"ShapeshiftBarFrame", "PossessBarFrame", "PETACTIONBAR_YPOS",
		"MultiCastActionBarFrame", "MULTICASTACTIONBAR_YPOS",
	}

	for _, frame in pairs(uiManagedFrames) do
		UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
	end
	uiManagedFrames = nil

end

----------------------
-- Setup button grid
----------------------

local buttonGrid = CreateFrame("Frame")
buttonGrid:RegisterEvent("PLAYER_ENTERING_WORLD")
buttonGrid:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SetActionBarToggles(true, true, true, true, 0)
	--SetCVar("alwaysShowActionBars, 0")

	if actionBar["settings"].showGrid == true then
		for index = 1, 12 do
			local button = _G[format("ActionButton%d", index)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("BonusActionButton%d", index)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarRightButton%d", index)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarBottomRightButton%d", index)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarLeftButton%d", index)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarBottomLeftButton%d", index)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
		end
	end
end)

---------------------------------------------------
-- BAR 1
---------------------------------------------------

-- Tukui/actionbars/Bar1.lua (modified for caelUI data)
---------------------------------------------------------------------------
-- Setup Main Action Bar.
-- Now used for stances, Bonus, Vehicle at the same time.
-- Since t12, it's also working for druid cat stealth. (a lot requested)
---------------------------------------------------------------------------

local bar1 = CreateFrame("Frame", "bar1", caelPanel5, "SecureHandlerStateTemplate")
bar1:ClearAllPoints()
bar1:SetAllPoints(caelPanel5)

--[[ 
	Bonus bar classes id

	DRUID: Caster: 0, Cat: 1, Tree of Life: 2, Bear: 3, Moonkin: 4
	WARRIOR: Battle Stance: 1, Defensive Stance: 2, Berserker Stance: 3 
	ROGUE: Normal: 0, Stealthed: 1
	PRIEST: Normal: 0, Shadowform: 1
	
	When Possessing a Target: 5
]]--

local Page = {
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] %s; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["PRIEST"] = "[bonusbar:1] 7;",
	["ROGUE"] = "[bonusbar:1] 7;",
	["DEFAULT"] = "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:5] 11;"
}

local function GetBar()
	local condition = Page["DEFAULT"]
	local class = caelLib.playerClass
	local page = Page[class]
	if page then
		if class == "DRUID" then
			-- Handles prowling, prowling has no real stance, so this is a hack which utilizes the Tree of Life bar for non-resto druids.
			if IsSpellKnown(33891) then -- Tree of Life form
				page = page:format(7)
			else
				page = page:format(8)
			end
		end
		condition = condition.." "..page
	end
	condition = condition.." 1"
	return condition
end

bar1:RegisterEvent("PLAYER_LOGIN")
bar1:RegisterEvent("PLAYER_ENTERING_WORLD")
bar1:RegisterEvent("PLAYER_TALENT_UPDATE")
bar1:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
bar1:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
bar1:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
bar1:RegisterEvent("BAG_UPDATE")
bar1:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		local button
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			button = _G["ActionButton"..i]
			self:SetFrameRef("ActionButton"..i, button)
		end	

		self:Execute([[
			buttons = table.new()
			for i = 1, 12 do
				table.insert(buttons, self:GetFrameRef("ActionButton"..i))
			end
		]])

		self:SetAttribute("_onstate-page", [[ 
			for i, button in ipairs(buttons) do
				button:SetAttribute("actionpage", tonumber(newstate))
			end
		]])
		
		RegisterStateDriver(self, "page", GetBar())
	elseif event == "PLAYER_ENTERING_WORLD" then
		MainMenuBar_UpdateKeyRing()
		local button
		for i = 1, 12 do
			button = _G["ActionButton"..i]
			button:SetScale(0.68625)
			button:ClearAllPoints()
			button:SetParent(bar1)
			if i == 1 then
				button:SetPoint("TOPLEFT", caelPanel5, caelLib.scale(4.5), caelLib.scale(-6.5))
			elseif i == 7 then
				button:SetPoint("TOPLEFT", _G["ActionButton1"], "BOTTOMLEFT", 0, caelLib.scale(-6.5))
			else
				button:SetPoint("LEFT", _G["ActionButton"..i-1], "RIGHT", caelLib.scale(4.5), 0)
			end
		end
	elseif event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		if not InCombatLockdown() then -- Just to be safe
			RegisterStateDriver(self, "page", GetBar())
			-- Due to some odd reason these bars (MultiBarRight, MultiBarLeft) are changing position after you spent a talent point, and switch spec,
			-- I couldn't watch the exact event that does it even by using ':RegisterAllEvents()', until I'll figure it out, here is an awful hack. 
			if event == "ACTIVE_TALENT_GROUP_CHANGED" then 
				local t = 0
				self:SetScript("OnUpdate", function(self, elapsed)
					t = t + elapsed
					MainMenuBar:Hide()
					UIParent_ManageFramePositions()
					if t > 5 then
						t = 0
						self:SetScript("OnUpdate", nil)
					end
				end)
			end
		end
	else
		MainMenuBar_OnEvent(self, event, ...)
	end
end)

------------------------
-- BAR 2, BAR 3, BAR 4
------------------------

-- Bar2 = caelPanel6 = MultiBarBottomLeft
-- Bar3 = caelPanel7 = MultiBarBottomRight
-- Bar4 = caelPanel4 = MultiBarRight
-- Bar5 = caelPanel<NOT MADE> = MultiBarLeft

local bar2 = CreateFrame("Frame", "bar2", UIParent)
local bar3 = CreateFrame("Frame", "bar3", UIParent)
local bar4 = CreateFrame("Frame", "bar4", UIParent)

do 
	local bars = {{}, {}, {}}

	bars[1] = {
		["panel"] = caelPanel6,
		["button"] = "MultiBarBottomLeftButton",
		["barFrame"] = bar2,
		["realBar"] = MultiBarBottomLeft,
	}
	bars[2] = {
		["panel"] = caelPanel7,
		["button"] = "MultiBarBottomRightButton",
		["barFrame"] = bar3,
		["realBar"] = MultiBarBottomRight,
	}
	bars[3] = {
		["panel"] = caelPanel4,
		["button"] = "MultiBarRightButton",
		["barFrame"] = bar4,
		["realBar"] = MultiBarRight,
	}

	for _, bar in ipairs(bars) do
		local button1 = _G[bar.button .. "1"]

		-- Set the bar frame to the panel cael panel it is tied to.
		bar.barFrame:SetAllPoints(bar.panel)

		-- Set the Blizzard bar parent.
		bar.realBar:SetParent(bar.barFrame)

		for index = 1, 12 do
			local button = _G[bar.button .. index]
			local buttonPrev = _G[bar.button .. index - 1]

			button:ClearAllPoints()
			button:SetScale(0.68625)

			if index == 1 then
				button:SetPoint("TOPLEFT", bar.panel, caelLib.scale(4.5), caelLib.scale(-4.5))
			elseif index == 7 then
				button:SetPoint("TOPLEFT", button1, "BOTTOMLEFT", 0, caelLib.scale(-6.5))
			else
				button:SetPoint("LEFT", buttonPrev, "RIGHT", caelLib.scale(5), 0)
			end
		end
	end
end

-------------------
-- SHAPESHIFT BAR
-------------------

local barShift = CreateFrame("Frame", "barShift", UIParent)
barShift:ClearAllPoints()
barShift:SetPoint("BOTTOMLEFT", caelPanel5, "TOPLEFT", 0, caelLib.scale(-4))
barShift:SetWidth(29)
barShift:SetHeight(58)

-- Place buttons in the bar frame and set the barShift as the parent frame
ShapeshiftBarFrame:SetParent(barShift)
ShapeshiftBarFrame:SetWidth(0.00001)
for index = 1, NUM_SHAPESHIFT_SLOTS do
	local button = _G["ShapeshiftButton" .. index]
	local buttonPrev = _G["ShapeshiftButton" .. index - 1]
	button:ClearAllPoints()
	button:SetScale(0.68625)
	if index == 1 then
		button:SetPoint("BOTTOMLEFT", barShift, 0, caelLib.scale(6.5))
	else
		button:SetPoint("LEFT", buttonPrev, "RIGHT", caelLib.scale(4.5), 0)
	end
end

-- Hook the updating of the shapeshift bar
local function MoveShapeshift()
	ShapeshiftButton1:SetPoint("BOTTOMLEFT", barShift, 0, caelLib.scale(6.5))
end
hooksecurefunc("ShapeshiftBar_Update", MoveShapeshift)

------------
-- PET BAR
------------

-- Create pet bar frame and put it into place
local barPet = CreateFrame("Frame", "barPet", UIParent, "SecureHandlerStateTemplate")
barPet:ClearAllPoints()
barPet:SetWidth(caelLib.scale(120))
barPet:SetHeight(caelLib.scale(47))
barPet:SetPoint("BOTTOM", UIParent, caelLib.scale(-337), caelLib.scale(359))

-- Setup Blizzard pet action bar.
PetActionBarFrame:SetParent(barPet)
PetActionBarFrame:SetWidth(0.01)

-- Never hide pet buttons
PetActionBarFrame.showgrid = 1

-- function to toggle the display of the pet bar
local function togglePetBar(alpha)
	for index = 1, NUM_PET_ACTION_SLOTS do
		local button = _G["PetActionButton" .. index]
		button:SetAlpha(alpha)
	end
end

do
	local button1 = _G["PetActionButton1"]
	for index = 1, NUM_PET_ACTION_SLOTS do
		local button = _G["PetActionButton" .. index]
		local buttonPrev = _G["PetActionButton" .. index - 1]

		button:ClearAllPoints()
		button:SetParent(barPet)
		button:SetScale(0.63) 

		if index == 1 then
			button:SetPoint("TOPLEFT", barPet, caelLib.scale(4.5), caelLib.scale(-4.5))
		elseif index == (NUM_PET_ACTION_SLOTS / 2) then
			button:SetPoint("TOPLEFT", button1, "BOTTOMLEFT", 0, caelLib.scale(-5))
		else
			button:SetPoint("LEFT", buttonPrev, "RIGHT", caelLib.scale(4.5), 0)
		end

		-- Toggle buttons if mouse over is turned on.
		if actionBar["settings"].mouseOverPetBar == true then
			button:SetAlpha(0)
			button:HookScript("OnEnter", function(self) togglePetBar(1) end)
			button:HookScript("OnLeave", function(self) togglePetBar(0) end)
		end
	end
end

-- Toggle pet bar if mouse over is turned on.
if actionBar["settings"].mouseOverPetBar == true then
	barPet:EnableMouse(true)
	barPet:SetScript("OnEnter", function(self) togglePetBar(1) end)
	barPet:SetScript("OnLeave", function(self) togglePetBar(0) end)
end

------------
-- VEHICLE
------------

-- Vehicle button
local vehicleExitButton = CreateFrame("BUTTON", nil, UIParent, "SecureActionButtonTemplate")

-- Move it into place
vehicleExitButton:SetSize(caelLib.scale(70), caelLib.scale(70))
vehicleExitButton:SetPoint("BOTTOM", caelLib.scale(-150), caelLib.scale(277))

-- Handle clicking
vehicleExitButton:RegisterForClicks("AnyUp")
vehicleExitButton:SetScript("OnClick", function() VehicleExit() end)

-- Set Textures on the button
vehicleExitButton:SetNormalTexture([=[Interface\AddOns\caelMedia\miscellaneous\vehicleExit]=])
vehicleExitButton:SetPushedTexture([=[Interface\AddOns\caelMedia\miscellaneous\vehicleExit]=])
vehicleExitButton:SetHighlightTexture([=[Interface\AddOns\caelMedia\miscellaneous\vehicleExit]=])
-- TukuiDB.SetTemplate(vehicleExitButton)

-- Register and handle vehicle related events
vehicleExitButton:RegisterEvent("UNIT_ENTERING_VEHICLE")
vehicleExitButton:RegisterEvent("UNIT_ENTERED_VEHICLE")
vehicleExitButton:RegisterEvent("UNIT_EXITING_VEHICLE")
vehicleExitButton:RegisterEvent("UNIT_EXITED_VEHICLE")
vehicleExitButton:RegisterEvent("ZONE_CHANGED_NEW_AREA")
vehicleExitButton:SetScript("OnEvent", function(self, event, arg1)
	if (((event == "UNIT_ENTERING_VEHICLE") or (event == "UNIT_ENTERED_VEHICLE"))
		and arg1 == "player") then
		vehicleExitButton:SetAlpha(1)
	elseif (
		(
		(event == "UNIT_EXITING_VEHICLE") or (event == "UNIT_EXITED_VEHICLE")
		) and
		arg1 == "player") or (
		event == "ZONE_CHANGED_NEW_AREA" and not UnitHasVehicleUI("player")
		) then
		vehicleExitButton:SetAlpha(0)
	end
end)
-- Hide button on game load
vehicleExitButton:SetAlpha(0)

for i = 1, 12 do
	_G["MultiBarLeftButton"..i]:SetScale(0.68625)
end

MultiBarLeft:SetParent(UIParent)
MultiBarLeftButton1:ClearAllPoints()
MultiBarLeftButton1:SetPoint("RIGHT", UIParent, "RIGHT", caelLib.scale(-15), 0)

--- YET TO BE IMPLEMENTED
---------------------------------------------------
-- ON MOUSEOVER STUFF
---------------------------------------------------
--[[
local function showhidebar1(alpha)
if BonusActionBarFrame:IsShown() then
for i=1, 12 do
local pb = _G["BonusActionButton"..i]
pb:SetAlpha(alpha)
end
else
for i=1, 12 do
local pb = _G["ActionButton"..i]
pb:SetAlpha(alpha)
end
end
end

if mouseOverBar1 == 1 then
bar1Holder:EnableMouse(true)
bar1Holder:SetScript("OnEnter", function(self) showhidebar1(1) end)
bar1Holder:SetScript("OnLeave", function(self) showhidebar1(0) end)  
for i=1, 12 do
local pb = _G["ActionButton"..i]
pb:SetAlpha(0)
pb:HookScript("OnEnter", function(self) showhidebar1(1) end)
pb:HookScript("OnLeave", function(self) showhidebar1(0) end)
local pb = _G["BonusActionButton"..i]
pb:SetAlpha(0)
pb:HookScript("OnEnter", function(self) showhidebar1(1) end)
pb:HookScript("OnLeave", function(self) showhidebar1(0) end)
end
end

local function showhidebar2(alpha)
if MultiBarBottomLeft:IsShown() then
for i=1, 12 do
local pb = _G["MultiBarBottomLeftButton"..i]
pb:SetAlpha(alpha)
end
end
end

if mouseOverBar2 == 1 then
bar2Holder:EnableMouse(true)
bar2Holder:SetScript("OnEnter", function(self) showhidebar2(1) end)
bar2Holder:SetScript("OnLeave", function(self) showhidebar2(0) end)  
for i=1, 12 do
local pb = _G["MultiBarBottomLeftButton"..i]
pb:SetAlpha(0)
pb:HookScript("OnEnter", function(self) showhidebar2(1) end)
pb:HookScript("OnLeave", function(self) showhidebar2(0) end)
end
end

local function showhidebar3(alpha)
if MultiBarBottomRight:IsShown() then
for i=1, 12 do
local pb = _G["MultiBarBottomRightButton"..i]
pb:SetAlpha(alpha)
end
end
end

if mouseOverBar3 == 1 then
bar3Holder:EnableMouse(true)
bar3Holder:SetScript("OnEnter", function(self) showhidebar3(1) end)
bar3Holder:SetScript("OnLeave", function(self) showhidebar3(0) end)  
for i=1, 12 do
local pb = _G["MultiBarBottomRightButton"..i]
pb:SetAlpha(0)
pb:HookScript("OnEnter", function(self) showhidebar3(1) end)
pb:HookScript("OnLeave", function(self) showhidebar3(0) end)
end
end

local function showhideshapeshift(alpha)
for i=1, NUM_SHAPESHIFT_SLOTS do
local pb = _G["ShapeshiftButton"..i]
pb:SetAlpha(alpha)
end
end

if mouseOverShiftBar == 1 then
shiftBarHolder:EnableMouse(true)
shiftBarHolder:SetScript("OnEnter", function(self) showhideshapeshift(1) end)
shiftBarHolder:SetScript("OnLeave", function(self) showhideshapeshift(0) end)  
for i=1, NUM_SHAPESHIFT_SLOTS do
local pb = _G["ShapeshiftButton"..i]
pb:SetAlpha(0)
pb:HookScript("OnEnter", function(self) showhideshapeshift(1) end)
pb:HookScript("OnLeave", function(self) showhideshapeshift(0) end)
end
end

local function showhiderightbar(alpha)
if MultiBarLeft:IsShown() then
for i=1, 12 do
local pb = _G["MultiBarLeftButton"..i]
pb:SetAlpha(alpha)
end
end
if MultiBarRight:IsShown() then
for i=1, 12 do
local pb = _G["MultiBarRightButton"..i]
pb:SetAlpha(alpha)
end
end
end

if mouseOverBar45 == 1 then
bar45Holder:EnableMouse(true)
bar45Holder:SetScript("OnEnter", function(self) showhiderightbar(1) end)
bar45Holder:SetScript("OnLeave", function(self) showhiderightbar(0) end)  
for i=1, 12 do
local pb = _G["MultiBarLeftButton"..i]
pb:SetAlpha(0)
pb:HookScript("OnEnter", function(self) showhiderightbar(1) end)
pb:HookScript("OnLeave", function(self) showhiderightbar(0) end)
local pb = _G["MultiBarRightButton"..i]
pb:SetAlpha(0)
pb:HookScript("OnEnter", function(self) showhiderightbar(1) end)
pb:HookScript("OnLeave", function(self) showhiderightbar(0) end)
end
end
--]]

------------
-- STYLING (NEEDS TO BE RIPPED OUT AND PUT INTO style.lua FOR EASIER CHANGING)
------------

--	caelActionBars - roth 2009

--	TEXTURES
--	default border texture  
local buttonTex = caelMedia.files.buttonNormal

--	hide the hotkey? 0/1
local hide_hotkey = 1

--	COLORS
--	color you want to appy to the standard texture (red, green, blue in RGB)
local color = { r = 0.84, g = 0.75, b = 0.65}
--	want class color? just comment in this:
--	local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

--	color when button is usable
local usable_color = { r = 1, g = 1, b = 1}

--	color for equipped border texture (red, green, blue in RGB)
local color_equipped = { r = 0.33, g = 0.59, b = 0.33}

--	color when out of range
local range_color = { r = 0.69, g = 0.31, b = 0.31}

--	color when out of power (mana)
local mana_color = { r = 0.31, g = 0.45, b = 0.63}

--	color when button is unusable (example revenge not active, since you have not blocked yet)
local unusable_color = { r = 0.25, g = 0.25, b = 0.25}

--	!!!IMPORTANT!!! - read this before editing the value blow
--	!!!do not set this below 0.1 ever!!!
--	you have 120 actionbuttons on screen (most of you have at 80) and each of them will get updated on this timer in seconds
--	default is 1, it is needed for the rangecheck
--	if you dont want it just set the timer to 999 and the cpu usage will be near zero
--	if you set the timer to 0 it will update all your 120 buttons on every single frame
--	so if you have 120FPS it will call the function 14.400 times a second!
--	if the timer is 1 it will call the function 120 times a second (depends on actionbuttons in screen)
local update_timer = TOOLTIP_UPDATE_TIME + 0.1

---------------------------------------
-- FUNCTIONS
---------------------------------------

--	initial style func
local function StyleBar(name, action)

	--	Needed to find out which way to style bar
	local isPet        = name:find("PetActionButton")
	local isShapeshift = name:find("ShapeshiftButton")

	--	Shared shortcuts
	local bu = _G[name]
	local ic = _G[format("%sIcon", name)]
	local fl = _G[format("%sFlash", name)]
	local nt = isPet and _G[format("%sNormalTexture2", name)] or _G[format("%sNormalTexture", name)]

	--	Set Textures
	fl:SetTexture(buttonTex)
	bu:SetHighlightTexture(buttonTex)
	bu:SetPushedTexture(buttonTex)
	bu:SetCheckedTexture(buttonTex)
	bu:SetNormalTexture(buttonTex)

	--	Position Icon
	ic:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	ic:SetPoint("TOPLEFT", bu, caelLib.scale(2), caelLib.scale(-2))
	ic:SetPoint("BOTTOMRIGHT", bu, caelLib.scale(-2), caelLib.scale(2))

	--	Non-equipped coloring.
	nt:SetVertexColor(color.r, color.g, color.b, 1)

	--	Set Texture position
	nt:SetHeight(bu:GetHeight())
	nt:SetWidth(bu:GetWidth())
	nt:SetAllPoints(bu)

	if action then
		--		Regular bar shortcuts
		local co  = _G[format("%sCount", name)]
		local bo  = _G[format("%sBorder", name)]
		local ho  = _G[format("%sHotKey", name)]
		local cd  = _G[format("%sCooldown", name)]
		local na  = _G[format("%sName", name)]

		bo:Hide()

		ho:SetFont(caelMedia.fonts.NORMAL, 12)
		co:SetFont(caelMedia.fonts.NORMAL, 12)
		na:SetFont(caelMedia.fonts.NORMAL, 10)
		if hide_hotkey == 1 then
			ho:Hide()
		end
		na:Hide()

		if ( IsEquippedAction(action) ) then
			nt:SetVertexColor(color_equipped.r, color_equipped.g, color_equipped.b, 1)
		end
	elseif isShapeshift then
		-- Set Texture Postion
		nt:ClearAllPoints()
		nt:SetAllPoints(bu)
	end
end

local function caelActionBars_AB_style(self)
	StyleBar(self:GetName(), self.action)
end

--	style pet buttons
local function caelActionBars_AB_stylepet()
	for i = 1, NUM_PET_ACTION_SLOTS do
		StyleBar(format("PetActionButton%d", i))
	end
end

--	style shapeshift buttons
local function caelActionBars_AB_styleshapeshift()    
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		StyleBar(format("ShapeshiftButton%d", i))
	end
end

--	fix the grid display
--	the default function has a bug and once you move a button the alpha stays at 0.5, this gets fixed here
local function caelActionBars_AB_fixgrid(button)
	local name = button:GetName()
	local action = button.action
	local nt  = _G[format("%sNormalTexture", name)]
	if ( IsEquippedAction(action) ) then
		nt:SetVertexColor(color_equipped.r, color_equipped.g, color_equipped.b, 1)
	else
		nt:SetVertexColor(color.r, color.g, color.b, 1)
	end  
end

--	update the button colors onUpdateUsable
local function caelActionBars_AB_usable(self)
	local name = self:GetName()
	local action = self.action
	local nt  = _G[format("%sNormalTexture", name)]
	local icon = _G[format("%sIcon", name)]
	if ( IsEquippedAction(action) ) then
		nt:SetVertexColor(color_equipped.r, color_equipped.g, color_equipped.b, 1)
	else
		nt:SetVertexColor(color.r,color.g,color.b,1)
	end  
	local isUsable, notEnoughMana = IsUsableAction(action)
	if (ActionHasRange(action) and IsActionInRange(action) == 0) then
		icon:SetVertexColor(range_color.r, range_color.g, range_color.b, 1)
		return
	elseif (notEnoughMana) then
		icon:SetVertexColor(mana_color.r, mana_color.g, mana_color.b, 1)
		return
	elseif (isUsable) then
		icon:SetVertexColor(usable_color.r, usable_color.g, usable_color.b, 1)
		return
	else
		icon:SetVertexColor(unusable_color.r, unusable_color.g, unusable_color.b, 1)
		return
	end
end

--	rewrite of the onupdate func, much less cpu usage needed
local function caelActionBars_AB_onupdate(self, elapsed)
	local t = self.cAB_range
	if (not t) then
		self.cAB_range = 0
		return
	end
	t = t + elapsed
	if (t < update_timer) then
		self.cAB_range = t
		return
	else
		self.cAB_range = 0
		caelActionBars_AB_usable(self)
	end
end

--	hotkey func
local function caelActionBars_AB_hotkey(self, actionButtonType)
	if (not actionButtonType) then
		actionButtonType = "ACTIONBUTTON"
	end
	local hotkey = _G[self:GetName().."HotKey"]
	local key = GetBindingKey(actionButtonType..self:GetID()) or GetBindingKey("CLICK "..self:GetName()..":LeftButton")
	local text = GetBindingText(key, "KEY_", 1)
	hotkey:SetText(text)
	hotkey:Hide()
end

---------------------------------------
-- CALLS // HOOKS
---------------------------------------

hooksecurefunc("ActionButton_Update",   caelActionBars_AB_style)
hooksecurefunc("ActionButton_UpdateUsable",   caelActionBars_AB_usable)

--	rewrite default onUpdateFunc, the new one uses much less CPU power
ActionButton_OnUpdate = caelActionBars_AB_onupdate

--	fix grid
hooksecurefunc("ActionButton_ShowGrid", caelActionBars_AB_fixgrid)

--	call the special func to hide hotkeys after entering combat with the default actionbar
if hide_hotkey == 1 then
	hooksecurefunc("ActionButton_UpdateHotkeys", caelActionBars_AB_hotkey)
end

hooksecurefunc("ShapeshiftBar_OnLoad",   caelActionBars_AB_styleshapeshift)
hooksecurefunc("ShapeshiftBar_Update",   caelActionBars_AB_styleshapeshift)
hooksecurefunc("ShapeshiftBar_UpdateState",   caelActionBars_AB_styleshapeshift)
hooksecurefunc("PetActionBar_Update",   caelActionBars_AB_stylepet)
