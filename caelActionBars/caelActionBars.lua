--[[	$Id$	]]

--[[
local mouseOverBar1 = 0
local mouseOverBar2 = 0
local mouseOverBar3 = 0
local mouseOverBar45 = 0
local mouseOverShiftBar = 0
--]]
local mouseOverPetBar = 1

local _G = getfenv(0)

local actionBars = CreateFrame("Frame", nil, UIParent)
actionBars:RegisterEvent("PLAYER_ENTERING_WORLD")
actionBars:SetScript("OnEvent", function()
	-- Force bottom left, bottom right and right bars to be shown.
	SetActionBarToggles(true, true, true, false, ALWAYS_SHOW_MULTIBARS)
	MultiActionBar_Update()
	UIParent_ManageFramePositions()
	
	-- Force empty buttons to be shown.
	ActionButton_HideGrid = function() end
	for i = 1, 12 do
		local button = _G[format("ActionButton%d", i)]
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)

		button = _G[format("BonusActionButton%d", i)]
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)
	end
end)

---------------------------------------------------
-- CREATE ALL THE HOLDER FRAMES
---------------------------------------------------
    
-- Frame to hold the ActionBar1 and the BonusActionBar
local bar1Holder = CreateFrame("Frame", "Bar1Holder", caelPanel5)
bar1Holder:SetFrameStrata("MEDIUM")
bar1Holder:SetAllPoints()

-- Frame to hold the MultibarBottomLeft
local bar2Holder = CreateFrame("Frame", "Bar2Holder", caelPanel6)
bar2Holder:SetFrameStrata("MEDIUM")
bar2Holder:SetAllPoints()


-- Frame to hold the MultibarRight
local bar3Holder = CreateFrame("Frame", "Bar3Holder", caelPanel7)
bar3Holder:SetFrameStrata("MEDIUM")
bar3Holder:SetAllPoints()

-- Frame to hold the right bars
local bar45Holder = CreateFrame("Frame", "Bar45Holder", caelPanel4)
bar45Holder:SetFrameStrata("MEDIUM")
bar45Holder:SetAllPoints()


-- Frame to hold the pet bars  
local petBarHolder = CreateFrame("Frame", "PetBarHolder", UIParent)
petBarHolder:SetWidth(120)
petBarHolder:SetHeight(47)
petBarHolder:SetPoint("BOTTOM", UIParent, -337, 359)
  
-- Frame to hold the shapeshift bars  
local shiftBarHolder = CreateFrame("Frame", "ShapeShiftHolder", UIParent)
shiftBarHolder:SetWidth(355)
shiftBarHolder:SetHeight(50)
shiftBarHolder:SetScale(0.01)
shiftBarHolder:SetAlpha(0)
shiftBarHolder:SetPoint("BOTTOM", -154, 239) 
 
-- Frame to hold the vehicle button
local vehicleButton = CreateFrame("Frame", "VEBHolder", UIParent)
vehicleButton:SetWidth(70)
vehicleButton:SetHeight(70)
vehicleButton:SetPoint("BOTTOM", -150, 277)   

---------------------------------------------------
-- CREATE MY OWN VEHICLE EXIT BUTTON
---------------------------------------------------
  
local veb = CreateFrame("BUTTON", "VehicleExitButton", vehicleButton, "SecureActionButtonTemplate")
veb:SetWidth(32.5)
veb:SetHeight(32.5)
veb:SetPoint("CENTER",0,0)
veb:SetAlpha(0)
veb:RegisterForClicks("AnyUp")
veb:SetNormalTexture([=[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]=])
veb:SetPushedTexture([=[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]=])
veb:SetHighlightTexture([=[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]=])
veb:SetScript("OnClick", function(self) VehicleExit() end)
veb:RegisterEvent("UNIT_ENTERING_VEHICLE")
veb:RegisterEvent("UNIT_ENTERED_VEHICLE")
veb:RegisterEvent("UNIT_EXITING_VEHICLE")
veb:RegisterEvent("UNIT_EXITED_VEHICLE")
veb:SetScript("OnEvent", function(self,event,...)
	local arg1 = ...
	if(((event == "UNIT_ENTERING_VEHICLE") or (event == "UNIT_ENTERED_VEHICLE")) and arg1 == "player") then
		veb:SetAlpha(1)
	elseif(((event == "UNIT_EXITING_VEHICLE") or (event == "UNIT_EXITED_VEHICLE")) and arg1 == "player") then
		veb:SetAlpha(0)
	end
end)
 
---------------------------------------------------
-- MOVE STUFF INTO POSITION
---------------------------------------------------

local currentButton

ActionButton1:ClearAllPoints()
ActionButton1:SetPoint("TOPLEFT", bar1Holder, 4.5, -4.5)

for i = 1, 12 do
	currentButton = _G["ActionButton"..i]
	currentButton:SetParent(bar1Holder)
	currentButton:SetScale(0.68625)

	if i > 1 and i ~= 7 then
		currentButton:ClearAllPoints()
		currentButton:SetPoint("LEFT", _G["ActionButton"..i-1], "RIGHT", 5, 0)
	elseif i == 7 then
		currentButton:ClearAllPoints()
		currentButton:SetPoint("TOPLEFT", _G["ActionButton"..i-6],"BOTTOMLEFT", 0, -6.5)
	end
end

BonusActionBarFrame:SetParent(bar1Holder)
BonusActionBarFrame:SetWidth(0.01)
BonusActionBarTexture0:Hide()
BonusActionBarTexture1:Hide()

BonusActionButton1:ClearAllPoints()
BonusActionButton1:SetPoint("TOPLEFT", bar1Holder, 4.5, -4.5)

BonusActionButton7:ClearAllPoints()
BonusActionButton7:SetPoint("TOPLEFT", BonusActionButton1, "BOTTOMLEFT", 0, -5)

for i = 1, 12 do
	currentButton = _G["BonusActionButton"..i]
	currentButton:SetScale(0.68625)

	if i > 1 and i ~= 7 then
		currentButton:ClearAllPoints()
		currentButton:SetPoint("LEFT", _G["BonusActionButton"..i-1], "RIGHT", 5, 0)
	elseif i == 7 then
		currentButton:ClearAllPoints()
		currentButton:SetPoint("TOPLEFT",_G["BonusActionButton"..i-6],"BOTTOMLEFT",0, -6.5)
	end
end

MultiBarBottomLeft:SetParent(bar2Holder)
MultiBarBottomLeftButton1:ClearAllPoints()
MultiBarBottomLeftButton1:SetPoint("TOPLEFT", bar2Holder, 4.5, -4.5)

for i = 1, 12 do
	currentButton = _G["MultiBarBottomLeftButton"..i]
	currentButton:SetScale(0.68625)

	if i > 1 and i ~= 7 then
		currentButton:ClearAllPoints()
		currentButton:SetPoint("LEFT", _G["MultiBarBottomLeftButton"..i-1], "RIGHT", 5, 0)
	elseif i == 7 then
		currentButton:ClearAllPoints()
		currentButton:SetPoint("TOPLEFT", _G["MultiBarBottomLeftButton"..i-6], "BOTTOMLEFT", 0, -6.5)
	end
end

MultiBarBottomRight:SetParent(bar3Holder)
MultiBarBottomRightButton1:ClearAllPoints()
MultiBarBottomRightButton1:SetPoint("TOPLEFT", bar3Holder, 4.5, -4.5)

for i = 1, 12 do
	currentButton = _G["MultiBarBottomRightButton"..i]
	currentButton:SetScale(0.68625)

	if i > 1 and i ~= 7 then
		currentButton:ClearAllPoints()
		currentButton:SetPoint("LEFT", _G["MultiBarBottomRightButton"..i-1], "RIGHT", 5, 0)
	elseif i == 7 then
		currentButton:ClearAllPoints()
		currentButton:SetPoint("TOPLEFT", _G["MultiBarBottomRightButton"..i-6], "BOTTOMLEFT", 0, -6.5)
	end
end

MultiBarRight:SetParent(bar45Holder)
MultiBarRightButton1:ClearAllPoints()
MultiBarRightButton1:SetPoint("TOPLEFT", bar45Holder, 4.5, -4.5)

for i = 1, 12 do
	currentButton = _G["MultiBarRightButton"..i]
	currentButton:SetScale(0.68625)

	if i > 1 and i ~= 7 then
		currentButton:ClearAllPoints()
		currentButton:SetPoint("LEFT", _G["MultiBarRightButton"..i-1], "RIGHT", 5, 0)
	elseif i == 7 then
		currentButton:ClearAllPoints()
		currentButton:SetPoint("TOPLEFT", _G["MultiBarRightButton"..i-6], "BOTTOMLEFT", 0, -6.5)
	end
end

for i = 1, 12 do
	_G["MultiBarLeftButton"..i]:SetScale(0.68625)
end

MultiBarLeft:SetParent(UIParent)
MultiBarLeftButton1:ClearAllPoints()
MultiBarLeftButton1:SetPoint("RIGHT", UIParent, "RIGHT", -15, 0)

ShapeshiftBarFrame:SetParent(shiftBarHolder)
ShapeshiftBarFrame:SetWidth(0.01)
ShapeshiftButton1:ClearAllPoints()
ShapeshiftButton1:SetPoint("BOTTOMLEFT",shiftBarHolder, 10, 10)

PossessBarFrame:SetParent(shiftBarHolder)
PossessButton1:ClearAllPoints()
PossessButton1:SetPoint("BOTTOMLEFT", shiftBarHolder, 10, 10)

for i = 1, 10 do
	_G["PetActionButton"..i]:SetScale(0.63)
end
PetActionBarFrame:SetParent(petBarHolder)
PetActionBarFrame:SetWidth(0.01)
PetActionButton1:ClearAllPoints()
PetActionButton1:SetPoint("TOPLEFT", petBarHolder, 4.5, -4.5)
PetActionButton6:ClearAllPoints()
PetActionButton6:SetPoint("TOPLEFT", PetActionButton1, "BOTTOMLEFT" ,0, -5)

---------------------------------------------------
-- ACTIONBUTTONS MUST BE HIDDEN
---------------------------------------------------
  
-- hide actionbuttons when the bonusbar is visible (rogue stealth and such)
local function showhideactionbuttons(alpha)
   local f = "ActionButton"
   for i = 1, 12 do
      _G[f..i]:SetAlpha(alpha)
   end
end
BonusActionBarFrame:HookScript("OnShow", function(self) showhideactionbuttons(0) end)
BonusActionBarFrame:HookScript("OnHide", function(self) showhideactionbuttons(1) end)
if BonusActionBarFrame:IsShown() then
   showhideactionbuttons(0)
end

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

local function showhidepet(alpha)
   for i = 1, NUM_PET_ACTION_SLOTS do
      local pb = _G["PetActionButton"..i]
      pb:SetAlpha(alpha)
   end
end

if mouseOverPetBar == 1 then
   petBarHolder:EnableMouse(true)
   petBarHolder:SetScript("OnEnter", function(self) showhidepet(1) end)
   petBarHolder:SetScript("OnLeave", function(self) showhidepet(0) end)  
   for i = 1, NUM_PET_ACTION_SLOTS do
      local pb = _G["PetActionButton"..i]
      pb:SetAlpha(0)
      pb:HookScript("OnEnter", function(self) showhidepet(1) end)
      pb:HookScript("OnLeave", function(self) showhidepet(0) end)
   end
end

---------------------------------------------------
-- MAKE THE DEFAULT BARS UNVISIBLE
---------------------------------------------------

local FramesToHide = {
	MainMenuBar,
	VehicleMenuBar,

--	MainMenuBarBackpackButton,
--	CharacterBag0Slot,
--	CharacterBag1Slot,
--	CharacterBag2Slot,
--	CharacterBag3Slot,
	KeyRingButton,

	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	SocialsMicroButton,
	PVPMicroButton,
	LFGMicroButton,
	MainMenuMicroButton,
	HelpMicroButton,
}  
  
local function HideDefaultFrames()
	for _, frame in pairs(FramesToHide) do
		frame:SetScale(0.001)
		frame:SetAlpha(0)
	end
end

HideDefaultFrames()

--	caelActionBars - roth 2009

--	TEXTURES
--	default border texture  
local buttonTex = [=[Interface\AddOns\caelMedia\Buttons\buttonborder1]=]

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
	ic:SetPoint("TOPLEFT", bu, 2, -2)
	ic:SetPoint("BOTTOMRIGHT", bu, -2, 2)

--	Non-equipped coloring.
	nt:SetVertexColor(color.r, color.g, color.b, 1)

--	Set Texture position
	nt:SetHeight(bu:GetHeight())
	nt:SetWidth(bu:GetWidth())
	nt:SetPoint("Center", 0, 0)

	if action then
--		Regular bar shortcuts
		local co  = _G[format("%sCount", name)]
		local bo  = _G[format("%sBorder", name)]
		local ho  = _G[format("%sHotKey", name)]
		local cd  = _G[format("%sCooldown", name)]
		local na  = _G[format("%sName", name)]

		bo:Hide()

		ho:SetFont(caelMedia.files.fontRg, 12)
		co:SetFont(caelMedia.files.fontRg, 12)
		na:SetFont(caelMedia.files.fontRg, 10)
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