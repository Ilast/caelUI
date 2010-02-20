local mouseOverBar1 = 0
local mouseOverBar2 = 0
local mouseOverBar3 = 0
local mouseOverBar45 = 0
local mouseOverShiftBar = 0
local mouseOverPetBar = 1

---------------------------------------------------
-- CREATE ALL THE HOLDER FRAMES
---------------------------------------------------
    
-- Frame to hold the ActionBar1 and the BonusActionBar
local bar1Holder = CreateFrame("Frame","Bar1Holder",UIParent)
bar1Holder:SetWidth(172)
bar1Holder:SetHeight(60)
bar1Holder:SetPoint("BOTTOM", UIParent, "BOTTOM", 153, 90)  
  
-- Frame to hold the MultibarBottomLeft
local bar2Holder = CreateFrame("Frame","Bar2Holder",UIParent)
bar2Holder:SetWidth(172)
bar2Holder:SetHeight(60)
bar2Holder:SetPoint("BOTTOM", UIParent, "BOTTOM", -153, 20)  

-- Frame to hold the MultibarRight
local bar3Holder = CreateFrame("Frame","Bar3Holder",UIParent)
bar3Holder:SetWidth(172)
bar3Holder:SetHeight(60)
bar3Holder:SetPoint("BOTTOM", UIParent, "BOTTOM", 153, 20)
  
-- Frame to hold the right bars
local bar45Holder = CreateFrame("Frame","Bar45Holder",UIParent)
bar45Holder:SetWidth(172)
bar45Holder:SetHeight(60)
bar45Holder:SetPoint("BOTTOM", UIParent, "BOTTOM", -153, 90)
  
-- Frame to hold the pet bars  
local petBarHolder = CreateFrame("Frame","PetBarHolder",UIParent)
petBarHolder:SetWidth(120)
petBarHolder:SetHeight(47)
petBarHolder:SetPoint("BOTTOM", UIParent, "BOTTOM", -337, 359)
  
-- Frame to hold the shapeshift bars  
local shiftBarHolder = CreateFrame("Frame","ShapeShiftHolder",UIParent)
shiftBarHolder:SetWidth(355)
shiftBarHolder:SetHeight(50)
shiftBarHolder:SetScale(0.01)
shiftBarHolder:SetAlpha(0)
shiftBarHolder:SetPoint("BOTTOM", -154, 239) 
 
-- Frame to hold the vehicle button
local vehicleButton = CreateFrame("Frame","VEBHolder",UIParent)
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
veb:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
veb:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
veb:SetHighlightTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
veb:SetScript("OnClick", function(self) VehicleExit() end)
veb:RegisterEvent("UNIT_ENTERING_VEHICLE")
veb:RegisterEvent("UNIT_ENTERED_VEHICLE")
veb:RegisterEvent("UNIT_EXITING_VEHICLE")
veb:RegisterEvent("UNIT_EXITED_VEHICLE")
veb:SetScript("OnEvent", function(self,event,...)
	local arg1 = ...
	if(((event=="UNIT_ENTERING_VEHICLE") or (event=="UNIT_ENTERED_VEHICLE")) and arg1 == "player") then
		veb:SetAlpha(1)
	elseif(((event=="UNIT_EXITING_VEHICLE") or (event=="UNIT_EXITED_VEHICLE")) and arg1 == "player") then
		veb:SetAlpha(0)
	end
end)
 
---------------------------------------------------
-- MOVE STUFF INTO POSITION
---------------------------------------------------

ActionButton1:ClearAllPoints()
ActionButton1:SetPoint('TOPLEFT', bar1Holder, 'TOPLEFT', 4.5, -4.5)

for i = 1, 12 do
	_G["ActionButton"..i]:SetParent(bar1Holder)
	_G["ActionButton"..i]:SetScale(0.68625)

	b1 = _G["ActionButton"..i]
	if i > 1 and i ~= 7 then
		b2 = _G["ActionButton"..i-1]
		b1:ClearAllPoints()
		b1:SetPoint("LEFT", b2, "RIGHT", 5, 0)
	elseif i == 7 then
		b2 = _G["ActionButton"..i-6]
		b1:ClearAllPoints()
		b1:SetPoint("TOPLEFT",b2,"BOTTOMLEFT",0,-6.5)
	end
end

BonusActionBarFrame:SetParent(bar1Holder)
BonusActionBarFrame:SetWidth(0.01)
BonusActionBarTexture0:Hide()
BonusActionBarTexture1:Hide()

BonusActionButton1:ClearAllPoints()
BonusActionButton1:SetPoint('TOPLEFT', bar1Holder, 'TOPLEFT', 4.5, -4.5)

BonusActionButton7:ClearAllPoints()
BonusActionButton7:SetPoint('TOPLEFT', BonusActionButton1, 'BOTTOMLEFT', 0, -5)

for i = 1, 12 do
	_G["BonusActionButton"..i]:SetScale(0.68625)

	b1 = _G["BonusActionButton"..i]
	if i > 1 and i ~= 7 then
		b2 = _G["BonusActionButton"..i-1]
		b1:ClearAllPoints()
		b1:SetPoint("LEFT", b2, "RIGHT", 5, 0)
	elseif i == 7 then
		b2 = _G["BonusActionButton"..i-6]
		b1:ClearAllPoints()
		b1:SetPoint("TOPLEFT",b2,"BOTTOMLEFT",0,-6.5)
	end
end

MultiBarBottomLeft:SetParent(bar2Holder)
MultiBarBottomLeftButton1:ClearAllPoints()
MultiBarBottomLeftButton1:SetPoint('TOPLEFT', bar2Holder, 'TOPLEFT', 4.5, -4.5)

for i = 1, 12 do
	_G["MultiBarBottomLeftButton"..i]:SetScale(0.68625)

	b1 = _G["MultiBarBottomLeftButton"..i]
	if i > 1 and i ~= 7 then
		b2 = _G["MultiBarBottomLeftButton"..i-1]
		b1:ClearAllPoints()
		b1:SetPoint("LEFT", b2, "RIGHT", 5, 0)
	elseif i == 7 then
		b2 = _G["MultiBarBottomLeftButton"..i-6]
		b1:ClearAllPoints()
		b1:SetPoint("TOPLEFT", b2, "BOTTOMLEFT", 0, -6.5)
	end
end

MultiBarBottomRight:SetParent(bar3Holder)
MultiBarBottomRightButton1:ClearAllPoints()
MultiBarBottomRightButton1:SetPoint('TOPLEFT', bar3Holder, 'TOPLEFT', 4.5, -4.5)

for i = 1, 12 do
	_G["MultiBarBottomRightButton"..i]:SetScale(0.68625)

	b1 = _G["MultiBarBottomRightButton"..i]
	if i > 1 and i ~= 7 then
		b2 = _G["MultiBarBottomRightButton"..i-1]
		b1:ClearAllPoints()
		b1:SetPoint("LEFT", b2, "RIGHT", 5, 0)
	elseif i == 7 then
		b2 = _G["MultiBarBottomRightButton"..i-6]
		b1:ClearAllPoints()
		b1:SetPoint("TOPLEFT", b2, "BOTTOMLEFT", 0, -6.5)
	end
end

MultiBarRight:SetParent(bar45Holder)
MultiBarRightButton1:ClearAllPoints()
MultiBarRightButton1:SetPoint('TOPLEFT', bar45Holder, 'TOPLEFT', 4.5, -4.5)

for i = 1, 12 do
	_G["MultiBarRightButton"..i]:SetScale(0.68625)

	b1 = _G["MultiBarRightButton"..i]
	if i > 1 and i ~= 7 then
		b2 = _G["MultiBarRightButton"..i-1]
		b1:ClearAllPoints()
		b1:SetPoint("LEFT", b2, "RIGHT", 5, 0)
	elseif i == 7 then
		b2 = _G["MultiBarRightButton"..i-6]
		b1:ClearAllPoints()
		b1:SetPoint("TOPLEFT", b2, "BOTTOMLEFT", 0, -6.5)
	end
end

for i=1, 12 do
	_G["MultiBarLeftButton"..i]:SetScale(0.68625)
end

MultiBarLeft:SetParent(bar45Holder)
MultiBarLeftButton1:ClearAllPoints()
MultiBarLeftButton1:SetPoint('TOPLEFT', bar45Holder, 'TOPLEFT', 4.5, -4.5)

ShapeshiftBarFrame:SetParent(shiftBarHolder)
ShapeshiftBarFrame:SetWidth(0.01)
ShapeshiftButton1:ClearAllPoints()
ShapeshiftButton1:SetPoint("BOTTOMLEFT",shiftBarHolder,"BOTTOMLEFT",10,10)
local function MoveShapeshift()
	ShapeshiftButton1:SetPoint("BOTTOMLEFT",shiftBarHolder,"BOTTOMLEFT",10,10)
end
hooksecurefunc("ShapeshiftBar_Update", MoveShapeshift)  

PossessBarFrame:SetParent(shiftBarHolder)
PossessButton1:ClearAllPoints()
PossessButton1:SetPoint("BOTTOMLEFT", shiftBarHolder, "BOTTOMLEFT", 10, 10)

for i = 1, 10 do
	_G["PetActionButton"..i]:SetScale(0.63)
end
PetActionBarFrame:SetParent(petBarHolder)
PetActionBarFrame:SetWidth(0.01)
PetActionButton1:ClearAllPoints()
PetActionButton1:SetPoint('TOPLEFT', petBarHolder, 'TOPLEFT', 4.5, -4.5)
PetActionButton6:ClearAllPoints()
PetActionButton6:SetPoint('TOPLEFT', PetActionButton1, 'BOTTOMLEFT' ,0, -5)

---------------------------------------------------
-- ACTIONBUTTONS MUST BE HIDDEN
---------------------------------------------------
  
-- hide actionbuttons when the bonusbar is visible (rogue stealth and such)
local function showhideactionbuttons(alpha)
   local f = "ActionButton"
   for i=1, 12 do
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

local function showhidebar2(alpha)
	if MultiBarBottomLeft:IsShown() then
		for i=1, 12 do
			local pb = _G["MultiBarBottomLeftButton"..i]
			pb:SetAlpha(alpha)
		end
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
  
local function showhideshapeshift(alpha)
   for i=1, NUM_SHAPESHIFT_SLOTS do
		local pb = _G["ShapeshiftButton"..i]
		pb:SetAlpha(alpha)
	end
end
  
local function showhidepet(alpha)
   for i=1, NUM_PET_ACTION_SLOTS do
      local pb = _G["PetActionButton"..i]
      pb:SetAlpha(alpha)
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
  
if mouseOverPetBar == 1 then
   petBarHolder:EnableMouse(true)
   petBarHolder:SetScript("OnEnter", function(self) showhidepet(1) end)
   petBarHolder:SetScript("OnLeave", function(self) showhidepet(0) end)  
   for i=1, NUM_PET_ACTION_SLOTS do
      local pb = _G["PetActionButton"..i]
      pb:SetAlpha(0)
      pb:HookScript("OnEnter", function(self) showhidepet(1) end)
      pb:HookScript("OnLeave", function(self) showhidepet(0) end)
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