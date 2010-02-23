local bindings = {
	["W"] = "MOVEFORWARD",
	["S"] = "MOVEBACKWARD",
	["A"] = "TURNLEFT",
	["D"] = "TURNRIGHT",
	["Q"] = "STRAFELEFT",
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

local event_frame = CreateFrame("Frame")
event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
event_frame:SetScript("OnEvent", function(self)
	for i = 1, GetNumBindings() do
		local command = GetBinding(i)
		while GetBindingKey(command) do
			local key = GetBindingKey(command)
			SetBinding(key) -- Clear Keybind
		end
	end

	for key, bind in pairs(bindings) do
		SetBinding(key, bind)
	end
	
	SaveBindings(1)

	-- All done, clean up a bit.
	bindings = nil	-- Remove table
	event_frame = nil -- Remove frame
end)