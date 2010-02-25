local class, filename = UnitClass("player")
if filename ~= "HUNTER" then
	print("You are not a hunter. BadPet has disabled itself.")
	return DisableAddOn("BadPet")
end

-- Constants
BINDING_HEADER_BadPet = "BadPet"
_G["BINDING_NAME_CLICK BadPetButton:LeftButton"] = "BadPet button"

local prefix = "|cffc0ff3eBadPet: |r"
local redtag, greentag = "|cffff0000", "|cff00ff00"
local BOOKTYPE_PET = BOOKTYPE_PET

local defaults = {
	sound = true,
	showbutton = true,
	showincombat = true,
	output = true,
	}


local print = function(...)
	_G.print(prefix, ...)
end

local BadPet = CreateFrame("Frame", "BadPetFrame")
BadPet.ButtonHooks = {}
BadPet.AnonButtons = {}

-- Generic OnEvent handler.
BadPet:SetScript("OnEvent", function(self, event, ...)
	if not self[event] then
		return print("Unhandled event: "..event)
	end
	return self[event](self, ...)
end)

local NoUpdate, pause
local petID, groupstatus, spec

function BadPet:GetGroupStatus()
	if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 1 then
		return "group"
	else
		return "solo"
	end
end

function BadPet:GetPetID()
	petID = UnitGUID("pet")
	if petID and HasPetSpells() and bit.band(petID:sub(1,5), 0x00f) == 0x004 then
		petID = petID:sub(6,12)
	else
		petID = nil
	end
end

function BadPet:ProfileCheck()
	if self.db[petID] and self.db[petID][spec] and self.db[petID][spec][groupstatus] then
		return true
	end
end

function BadPet:SetupProfileTables()
	if not self.db[petID] then
		self.db[petID] = {}
	end
	
	if not self.db[petID][spec] then
		self.db[petID][spec] = {}
	end
	
	if not self.db[petID][spec][groupstatus] then
		self.db[petID][spec][groupstatus] = {}
	end
end

-- Iterate pet skills and return name and autocast info.
do
	local name
	function BadPet:IteratePetSkills()
		local function PetSkillIterator(_, i)
			i = i+1
			name = GetSpellInfo(i, BOOKTYPE_PET)
			if name then
				return i, name, GetSpellAutocast(i, BOOKTYPE_PET)
			else
				return nil
			end
		end
		
		return PetSkillIterator, nil, 0
	end
end

function BadPet:SaveAutoCastStatus()
	groupstatus = groupstatus or self:GetGroupStatus()
	
	-- Create table layout for profile.
	self:SetupProfileTables()
	
	local message = string.format("Profile (spec %d - %s) saved.", spec, groupstatus)
	for i, name, autoCastAble, autoCastStatus in self:IteratePetSkills() do
		if autoCastAble then
			self.db[petID][spec][groupstatus][name] = not not autoCastStatus
			if self.db.settings.verbose then
				message = string.format("%s%s%s(%s), ", message, (autoCastStatus and greentag or redtag), name, (autoCastStatus and "on" or "off"))
			end
		end
	end
	
	if self.db.settings.output then
		print(message)
	end
	
	self.pause = nil
	self:SetupButton()
end

function BadPet:CheckAutoCastStatus(feedback)
	if not petID or self.pause or not UnitExists("pet") then
		return
	end
	
	groupstatus = groupstatus or self:GetGroupStatus()
	if not groupstatus then
		return
	end
	
	if not self:ProfileCheck() then
		self.pause = true
		return print(string.format("No profile found for spec %d - %s. Please set-up your pet's skills and run '/badpet save'", spec, groupstatus))
	end
	
	local message
	
	for i, name, autoCastAble, autoCastStatus in self:IteratePetSkills() do
		if autoCastAble and self.db[petID][spec][groupstatus][name] ~= not not autoCastStatus then
			message = string.format("%s%s%s", (message and message..", "or"Changed: "), (autoCastStatus and greentag or redtag), name)
		end
	end
	
	if message then
		if feedback then
			self.lastmessage = message
			return message
		end
		
		if message == self.lastmessage then
			-- Don't spam the user.
			return
		end
		
		if self.db.settings.sound then
			PlaySoundFile("Sound\\Item\\Weapons\\Whip\\BullWhipHit2.wav")
		end
		
		self:ShowButton()
		if self.db.settings.output then
			print(message)
		end
	else
		self:HideButton()
	end
	self.lastmessage = message
end

-- Button hooks.
local function ButtonPreClick(self, button)
	if self:GetName():find("SpellButton") or (self.BadPetButton and self.BadPetButton:find(button)) or self == BadPet.button then
		BadPet.NoUpdate = true
	end
end

local function ButtonPostClick(self, button)
	if self:GetName():find("SpellButton") or (self.BadPetButton and self.BadPetButton:find(button)) or self == BadPet.button then
		BadPet.NoUpdate = nil
	end
end

local function ActionButtonOnClickHook(self, button)
	if self.BadPetButton and self.BadPetButton:find(button) then
		BadPet:SaveAutoCastStatus()
	end
end

-- Note that the spellbuttons are shared with player skills, therefore we're
-- using a slightly different OnClick hook to check the bookType.
local function SpellButtonOnClick(self, button)
	if SpellBookFrame.bookType == BOOKTYPE_PET and button == "RightButton" then
		BadPet:SaveAutoCastStatus()
	end
end
	
-- Hook spellbook buttons.
for i = 1, SPELLS_PER_PAGE do
	local spellbutton = _G["SpellButton"..i]
	
	spellbutton:HookScript("PreClick", ButtonPreClick)
	spellbutton:HookScript("PostClick", ButtonPostClick)
	spellbutton:HookScript("OnClick", SpellButtonOnClick)
end

function BadPet:HookActionButton(button)
	if self.ButtonHooks[button] then
		return
	end
	
	button:HookScript("PreClick", ButtonPreClick)
	button:HookScript("PostClick", ButtonPostClick)
	button:HookScript("OnClick", ActionButtonOnClickHook)

	self.ButtonHooks[button] = true
end

function BadPet:AddButtonWatch(MouseButton)
	local button = GetMouseFocus()
	if not button or not button:GetObjectType():find("Button") then
		return print("You were not hovering over a valid button, or the button was not identifiable by BadPet. Please contact Gotai on WoWInterface if you feel this is an error.")
	end
	
	local name = button:GetName()

	-- Default to right-click
	if not MouseButton then
		MouseButton = "RightButton"
	elseif MouseButton == "both" then
		MouseButton = "LeftButton, RightButton"
	else
		if MouseButton:find("left") then
			MouseButton = "LeftButton"
		else
			MouseButton = "RightButton"
		end
	end
		
	button.BadPetButton = MouseButton
	
	if (self.db.buttons[name] or AnonButtons[button]) == MouseButton then
		return print("Your button is already watched, stop making me do more work!")
	end
	
	if not name then
		print("BadPet is only able to save named buttons in the saved variables. While your button will be monitored during this session, it will need to be added again manually when the UI is reloaded")
	end
	
	self:HookActionButton(button)
	if name then
		self.db.buttons[name] = MouseButton
	else
		self.AnonButtons[button] = MouseButton
	end
	
	print((name or "Anon Button").." is now being watched for "..MouseButton..".")
end

-- Secure Action Button to set autocast status back to profile.
function BadPet:CreateButton()
	local button = CreateFrame("Button", "BadPetButton", UIParent, "SecureActionButtonTemplate, ActionButtonTemplate")
	button:SetAlpha(0)
	button:Hide()
	button:SetPoint("CENTER", UIParent, "CENTER")
	button:SetAttribute("type", "macro")
	button:HookScript("PreClick", ButtonPreClick)
	button:SetScript("PostClick", function(self, button)
		ButtonPostClick(self, button)
		
		local message = BadPet:CheckAutoCastStatus(nil, true)
		if not message then
			-- Skills fixed!
			BadPet:HideButton()
			message = self.message
		end

		if message and BadPet.db.settings.output then
			print(message)
		end
	end)
	
	button:SetMovable(true)
	button:SetUserPlaced(true)
	button:RegisterForDrag("LeftButton")
	button:SetScript("OnDragStart",
		function(self)
			if InCombatLockdown() or not IsAltKeyDown() then
				return
			end
			
			self:StartMoving()
		end
	)
	
	button:SetScript("OnDragStop",
		function(self)
			self:StopMovingOrSizing()
		end
	)
	
	button:RegisterEvent("PLAYER_REGEN_ENABLED")
	button:RegisterEvent("PLAYER_REGEN_DISABLED")
	button:SetScript("OnEvent", function(self, event)
		BadPet:PrepareButton(event == "PLAYER_REGEN_DISABLED")
	end)
	BadPetButtonIcon:SetTexture("Interface\\Icons\\inv_misc_crop_01")
	
	self.button = button
end

function BadPet:SetupButton()
	if InCombatLockdown() then
		return self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
	
	if not self.button then
		CreateButton()
	end
	
	if not self:ProfileCheck() then
		return
	end
	
	local t = {}
	for skill,status in pairs(self.db[petID][spec][groupstatus]) do
		if status then
			t[#t + 1] = "/petautocaston "..skill
		else
			t[#t + 1] = "/petautocastoff "..skill
		end
	end
	self.button:SetAttribute("macrotext", table.concat(t, "\n"))
	self.button.message = string.format("Saved settings restored for spec %d - %s", spec, groupstatus)
end

function BadPet:PrepareButton(combat)
	local button = self.button
	if combat then
		if self.db.settings.showincombat then
			button:Show()
		end
	else
		if button:GetAlpha() <= 0 then
			-- Button wasn't shown, we can hide it now.
			button:Hide()
		end
	end
end

function BadPet:HideButton()
	local button = self.button
	
	button:SetAlpha(0)
	if not InCombatLockdown() then
		-- Button can be hidden properly.
		button:Hide()
	end
end

function BadPet:ShowButton(show)
	local button = self.button
	
	button:SetAlpha(1)
	if (show or self.db.settings.showbutton) and not InCombatLockdown() then
		-- Button needs to be Shown as well.
		button:Show()
	end
end

BadPet.PLAYER_REGEN_ENABLED = BadPet.SetupButton

function BadPet:ADDON_LOADED(addon)
	if addon == "BadPet" then
		_G["BadPet"] = _G["BadPet"] or {}
		self.db = _G["BadPet"]
		if not self.db.settings then
			self.db.settings = {}
		end
		if not self.db.buttons then
			self.db.buttons = {}
		end
		setmetatable(self.db.settings, {__index = defaults})
		self:CreateButton()
	end
end
BadPet:RegisterEvent("ADDON_LOADED")

function BadPet:PET_BAR_UPDATE()	
	if self.NoUpdate then
		return
	end
	self:CheckAutoCastStatus()
end

-- Turn grabbing petID into function. Also call from PEW.
function BadPet:UNIT_PET(unit)
	if unit == "player" then
		self:GetPetID()
		if petID then
			self:SetupButton()
			self:CheckAutoCastStatus()
		else
			self.lastmessage = nil
			if self.button:IsShown() then
				self:HideButton()
			end
		end
	end
end
BadPet:RegisterEvent("UNIT_PET")

function BadPet:PARTY_MEMBERS_CHANGED()
	groupstatus = self:GetGroupStatus()
	self:SetupButton()
	self:CheckAutoCastStatus()
end
BadPet:RegisterEvent("PARTY_MEMBERS_CHANGED")

BadPet.RAID_ROSTER_UPDATE = BadPet.PARTY_MEMBERS_CHANGED
BadPet:RegisterEvent("RAID_ROSTER_UPDATE")

function BadPet:PLAYER_TALENT_UPDATE()
	spec = GetActiveTalentGroup()
	self:SetupButton()
end
BadPet:RegisterEvent("PLAYER_TALENT_UPDATE")

BadPet.PLAYER_LOGIN = BadPet.PLAYER_TALENT_UPDATE
BadPet:RegisterEvent("PLAYER_LOGIN")

function BadPet:PLAYER_ENTERING_WORLD()
	groupstatus = self:GetGroupStatus()
	self:GetPetID()
	self:CheckAutoCastStatus()
	
	if self.db.buttons then
		for btnname,mousebtn in pairs(self.db.buttons) do
			local button = _G[btnname]
			if button then
				self:HookActionButton(button)
				-- Update older saved variables to new format.
				if mousebtn == true then
					mousebtn = "RightButton"
					self.db.buttons[btnname] = mousebtn
				end
				button.BadPetButton = mousebtn
			else
				self.db.buttons[btnname] = nil
			end
		end
	end
	
	self:SetupButton()
	
	self:RegisterEvent("PET_BAR_UPDATE")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end
BadPet:RegisterEvent("PLAYER_ENTERING_WORLD")

local function MoveButton(BadPet)
	if InCombatLockdown() then
		return print("Can only move button out of combat.")
	end
	if BadPet.button:IsShown() then
		BadPet:HideButton()
	else
		print("Please alt-click to drag the button.")
		BadPet:ShowButton(true)
	end
end

local function ToggleShow(BadPet, args)
	local settings = BadPet.db.settings
	if args and args:find("combat") then
		settings.showincombat = not BadPet.db.settings.showincombat
		print("Button will "..(BadPet.db.settings.showincombat and "" or "not ").."show in combat.")
	else
		settings.showbutton = not settings.showbutton
		if not settings.showbutton then
			BadPet:HideButton()
		end
		print("Button will "..(settings.showbutton and "" or "not ").."be shown.")
	end
end

local function ToggleSound(BadPet)
	local settings = BadPet.db.settings
	settings.sound = not settings.sound
	print("Sound "..(settings.sound and "enabled" or "disabled"))
end

local function ToggleOutput(BadPet)
	local settings = BadPet.db.settings
	settings.output = not settings.output
	print("Text output has been "..(settings.output and "enabled" or "disabled")..".")
end

local function ToggleVerbose(BadPet)
	local settings = BadPet.db.settings
	settings.verbose = not settings.verbose
	print("Verbose text output has been "..(settings.verbose and "enabled" or "disabled")..".")
end

local SlashCommands = {
	save = BadPet.SaveAutoCastStatus,
	watch = BadPet.AddButtonWatch,
	sound = ToggleSound,
	show = ToggleShow,
	move = MoveButton,
	output = ToggleOutput,
	verbose = ToggleVerbose,
}

do
	local t = {}
	for key in pairs(SlashCommands) do
		t[#t+1] = key
	end
	
	SlashCommands.commands = table.concat(t, ", ")
	wipe(t)
	t=nil
end

SlashCmdList["BADPET"] = function(cmd)
	local Cmd, Args = strsplit(" ", cmd:lower(), 2)
	if SlashCommands[Cmd] then
		return SlashCommands[Cmd](BadPet, Args)
	else
		print(string.format("Unknown slash command '%s', valid commands are: %s", Cmd, SlashCommands.commands))
	end
end

SLASH_BADPET1 = "/badpet"