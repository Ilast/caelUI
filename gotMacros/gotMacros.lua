LoadAddOn("Blizzard_MacroUI")
local macros = gM_Macros
local playername = UnitName("player")

local buttons = {}
local prefix = "gotMacros_"

local function NoSoundPreClick()
	SetCVar("Sound_EnableSFX", 0)
end

local function NoSoundPostClick()
	SetCVar("Sound_EnableSFX", 1)
end

local function SetUpMacro(name, body, nosound)
	local btn = buttons[name]
	if not btn then
		btn = CreateFrame("Button", prefix..name, UIParent, "SecureUnitButtonTemplate")
		buttons[name] = btn
	end
	
	if nosound then
		btn:SetScript("PreClick", NoSoundPreClick)
		btn:SetScript("PostClick", NoSoundPostClick)
	end
	
	if body:len() > 1023 then
		print("Gotai is lazy, no macros longer than 1023 chars plx!")
	end
	
	btn:SetAttribute("type", "macro")
	btn:SetAttribute("macrotext", body)
end

local function CreateBlizzardMacro(name, perChar, icon)
	if not buttons[name] then
		return print(string.format("No button called %q could be found.", tostring(name)))
	end
	
	if icon then
		if type(icon) == "string" then
			local path = icon:match("Interface.Icons.(.+)") or icon
			path = "Interface\\Icons\\"..path	-- Allow discrepancies in given path.
			
			for i=1, GetNumMacroIcons() do
				if GetMacroIconInfo(i) == path then
					icon = i
					break
				end
			end
		end
		if type(icon) ~= "number" then
			icon = nil
		end
	end
	
	local macroname = "gM_"..name:sub(1,13)
	local macrobody = string.format("/click %s", buttons[name]:GetName())
	local show = macros[name].show
	if show then
		show = string.format("#showtooltip %s\n", show)
		if show:len()+macrobody:len() <= 255 then
			macrobody = show..macrobody
		end
	end
	
	local index = GetMacroIndexByName(macroname)
	if index > 0 then
		EditMacro(index, nil, icon or 1, macrobody,1)
	else
		print("Creating!")
		local Macros, PerCharMacros = GetNumMacros()
		if perChar and PerCharMacros >= 18 then -- MAX_CHARACTER_MACROS
			perChar = nil
		end
		if not perChar and Macros >= 36 then -- MAX_ACCOUNT_MACROS
			return print("Your macro slots are all full, please delete some macros and reload.")
		end
		CreateMacro(macroname, icon or 1, macrobody, perChar)
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, ...)
	if InCombatLockdown() then
		return self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
	
	local NumMacros, NumMacrosPerChar = GetNumMacros()
	for i=NumMacros, 1, -1 do
		local name = GetMacroInfo(i):match("^gM_(.+)")
		if name and not macros[name] then
			DeleteMacro(i)
		end
	end
	
	for i=37+(NumMacrosPerChar-1 or 0), 37, -1 do
		local name = GetMacroInfo(i):match("^gM_(.+)")
		if name and not macros[name] then
			DeleteMacro(i)
		end
	end

	for k,v in pairs(macros) do
		if not v.char or v.char:find(playername) then
			SetUpMacro(k, v.body:gsub("\n\t*", "\n"), v.nosound)
			if v.blizzmacro then
				CreateBlizzardMacro(k, v.perChar, v.icon)
			end
		end
	end
	
	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent(event)
	else
		self:UnregisterEvent(event)
	end
end)

local _GetActionText = GetActionText
GetActionText = function(action)
   local text = _GetActionText(action)
   if text and text:find("^gM_") then
      return text:sub(4)
   else
      return text
   end
end