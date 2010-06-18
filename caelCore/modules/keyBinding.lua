--[[	$Id$	]]

if not caelLib.isCharListA then return end

local _, caelCore = ...

caelCore.keybinding = caelCore.createModule("KeyBinding")

local keybinding = caelCore.keybinding

local bindings = {
	["Z"] = "MOVEFORWARD",
	["UP"] = "MOVEFORWARD",
	["S"] = "MOVEBACKWARD",
	["DOWN"] = "MOVEBACKWARD",
	["Q"] = "TURNLEFT",
	["LEFT"] = "TURNLEFT",
	["D"] = "TURNRIGHT",
	["RIGHT"] = "TURNRIGHT",
	["A"] = "STRAFELEFT",
	["E"] = "STRAFERIGHT",
	["1"] = "ACTIONBUTTON1",
	["2"] = "ACTIONBUTTON2",
	["3"] = "ACTIONBUTTON3",
	["4"] = "ACTIONBUTTON4",
	["5"] = "ACTIONBUTTON5",
	["6"] = "ACTIONBUTTON6",
	["7"] = "ACTIONBUTTON7",
	["8"] = "ACTIONBUTTON8",
	["9"] = "ACTIONBUTTON9",
	["0"] = "ACTIONBUTTON10",
	[")"] = "ACTIONBUTTON11",
	["-"] = "ACTIONBUTTON12",
	["SHIFT-,"] = "MULTIACTIONBAR1BUTTON7",
	["NUMPAD1"] = "MULTIACTIONBAR1BUTTON10",
	["NUMPAD2"] = "MULTIACTIONBAR1BUTTON11",
	["MOUSEBUTTON3"] = "MULTIACTIONBAR1BUTTON11",
	["NUMPAD3"] = "MULTIACTIONBAR1BUTTON12",
	["MOUSEBUTTON5"] = "MULTIACTIONBAR1BUTTON12",
	["NUMPAD4"] = "MULTIACTIONBAR1BUTTON4",
	["NUMPAD5"] = "MULTIACTIONBAR1BUTTON5",
	["NUMPAD6"] = "MULTIACTIONBAR1BUTTON6",
	["BUTTON1"] = "CAMERAORSELECTORMOVE",
	["BUTTON2"] = "TURNORACTION",
	["BUTTON3"] = "MULTIACTIONBAR1BUTTON11",
	["BUTTON4"] = "TOGGLEAUTORUN",
	["BUTTON5"] = "MULTIACTIONBAR1BUTTON12",
	["TAB"] = "TARGETNEARESTENEMY",
	["SHIFT-TAB"] = "TARGETPREVIOUSENEMY",
	["CTRL-TAB"] = "TOGGLEWORLDSTATESCORES",
	["V"] = "NAMEPLATES",
	["SHIFT-V"] = "FRIENDNAMEPLATES",
	["CTRL-V"] = "ALLNAMEPLATES",
	["R"] = "REPLY",
	["C"] = "TOGGLECHARACTER0",
	["P"] = "TOGGLESPELLBOOK",
	["N"] = "TOGGLETALENTS",
	["O"] = "TOGGLESOCIAL",
	["L"] = "TOGGLEQUESTLOG",
	["I"] = "OPENALLBAGS",
	["M"] = "TOGGLEWORLDMAP",
	["X"] = "SITORSTAND",
	["Y"] = "TOGGLEACHIEVEMENT",
	["H"] = "TOGGLECHARACTER4",
	["²"] = "INSPECT",
	["*"] = "TOGGLERUN",
	[":"] = "TOGGLELFGPARENT",
	["SPACE"] = "JUMP",
	["ENTER"] = "OPENCHAT",
	["ESCAPE"] = "TOGGLEGAMEMENU",
	["PRINTSCREEN"] = "SCREENSHOT",
	["NUMPADDIVIDE"] = "TOGGLESHEATH",
	["MOUSEWHEELUP"] = "CAMERAZOOMIN",
	["MOUSEWHEELDOWN"] = "CAMERAZOOMOUT",
}

-- [[
	if event == "ZONE_CHANGED_NEW_AREA" then
		local _, instance = IsInInstance()
		if(instance == "pvp" or instance == "arena" or GetZonePVPInfo() == "combat") then
			SetBinding("TAB", "TARGETNEARESTENEMYPLAYER")
			SetBinding("SHIFT-TAB", "TARGETPREVIOUSENEMYPLAYER")
		else
			SetBinding("TAB", "TARGETNEARESTENEMY")
			SetBinding("SHIFT-TAB", "TARGETPREVIOUSENEMY")
		end
	end
--]]

PVPParentFrame:HookScript("OnShow", function() PVPParentFrameTab2:Click() end)

keybinding:RegisterEvent("PLAYER_ENTERING_WORLD")
keybinding:SetScript("OnEvent", function(self)
	-- Remove all keybinds
	for i = 1, GetNumBindings() do
		local command = GetBinding(i)
		while GetBindingKey(command) do
			local key = GetBindingKey(command)
			SetBinding(key) -- Clear Keybind
		end
	end

	-- Apply personal keybinds
	for key, bind in pairs(bindings) do
		SetBinding(key, bind)
	end

	-- Save keybinds
	SaveBindings(1)

	-- All done, clean up a bit.
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	bindings = nil	-- Remove table
	self = nil -- Remove frame
end)

--------------------------
---[[	Acceleration	]]---
--------------------------
for i = 1, 12 do
	local currentButton = _G["ActionButton"..i]

	currentButton:RegisterForClicks("AnyDown")

--	SetOverrideBindingClick(button, true, KEYBIND, button:GetName(), MOUSEBUTTONTOFAKE)
	SetOverrideBindingClick(currentButton, true, i == 12 and "-" or i == 11 and ")" or i == 10 and "0" or i, currentButton:GetName(), "LeftButton")
end

local driver = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
-- Create binding map.
driver:Execute([[
	bindings = newtable("1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ")", "-")
]])

-- Trigger func when form changes.
driver:SetAttribute("_onstate-form", [=[
	local name
	if newstate == "1" then
		name = "BonusActionButton%d"
	else
		name = "ActionButton%d"
	end
	
	for i=1, 12 do
			self:ClearBinding(bindings[i])
		self:SetBindingClick(true, bindings[i], name:format(i))
	end
]=])
RegisterStateDriver(driver, "form", "[vehicleui][bonusbar:5][form]1;0")