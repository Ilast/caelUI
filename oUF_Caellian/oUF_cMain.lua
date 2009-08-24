local settings = Caellian.oUF
local mediaPath = [=[Interface\Addons\oUF_Caellian\media\]=]

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {top = -1, left = -1, bottom = -1, right = -1},
}

local floor = math.floor
local format = string.format

local normTex = mediaPath..[=[textures\normTex]=]
local glowTex = mediaPath..[=[textures\glowTex]=]
local bubbleTex = mediaPath..[=[textures\bubbleTex]=]
local buttonTex = mediaPath..[=[textures\buttonTex]=]
local highlightTex = mediaPath..[=[textures\highlightTex]=]

local font = settings.font
local fontn = mediaPath..[=[fonts\russel square lt.ttf]=]

local _, class = UnitClass("player")

local lowThreshold = settings.lowThreshold
local highThreshold = settings.highThreshold

local colors = setmetatable({
	power = setmetatable({
		["MANA"] = {0.31, 0.45, 0.63},
		["RAGE"] = {0.69, 0.31, 0.31},
		["FOCUS"] = {0.71, 0.43, 0.27},
		["ENERGY"] = {0.65, 0.63, 0.35},
		["HAPPINESS"] = {0.19, 0.58, 0.58},
		["RUNES"] = {0.55, 0.57, 0.61},
		["RUNIC_POWER"] = {0, 0.82, 1},
		["AMMOSLOT"] = {0.8, 0.6, 0},
		["FUEL"] = {0, 0.55, 0.5},
		["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
		["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
	}, {__index = oUF.colors.power}),
	happiness = setmetatable({
		[1] = {.69,.31,.31},
		[2] = {.65,.63,.35},
		[3] = {.33,.59,.33},
	}, {__index = oUF.colors.happiness}),
	runes = setmetatable({
		[1] = {0.69, 0.31, 0.31},
		[2] = {0.33, 0.59, 0.33},
		[3] = {0.31, 0.45, 0.63},
		[4] = {0.84, 0.75, 0.65},
	}, {__index = oUF.colors.runes}),
}, {__index = oUF.colors})

oUF.colors.tapped = {0.55, 0.57, 0.61}
oUF.colors.disconnected = {0.84, 0.75, 0.65}

oUF.colors.smooth = {0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.15, 0.15, 0.15}

local SetUpAnimGroup = function(self)
	self.anim = self:CreateAnimationGroup("Flash")
	self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
	self.anim.fadein:SetChange(1)
	self.anim.fadein:SetOrder(2)

	self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
	self.anim.fadeout:SetChange(-1)
	self.anim.fadeout:SetOrder(1)
end

local Flash = function(self, duration)
	if not self.anim then
		SetUpAnimGroup(self)
	end

	self.anim.fadein:SetDuration(duration)
	self.anim.fadeout:SetDuration(duration)
	self.anim:Play()
end

local StopFlash = function(self)
	if self.anim then
		self.anim:Finish()
	end
end

local Menu = function(self)
	local unit = self.unit:gsub("(.)", string.upper, 1) 
	if _G[unit.."FrameDropDown"] then
		ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
	elseif (self.unit:match("party")) then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
	end
end

local SetFontString = function(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(1.25, -1.25)
	return fs
end

local ShortValue = function(value)
	if value >= 1e6 then
		return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return value
	end
end

local PostUpdateHealth = function(self, event, unit, bar, min, max)
	if not UnitIsConnected(unit) then
		bar:SetValue(0)
		bar.value:SetText("|cffD7BEA5".."Off".."|r")
	elseif UnitIsDead(unit) then
		bar.value:SetText("|cffD7BEA5".."Dead".."|r")
	elseif UnitIsGhost(unit) then
		bar.value:SetText("|cffD7BEA5".."Ghost".."|r")
	else
		if min ~= max then
			local r, g, b
			r, g, b = oUF.ColorGradient(min/max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
			if unit == "player" and self:GetAttribute("normalUnit") ~= "pet" then
				bar.value:SetFormattedText("|cffAF5050%d|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", min, r * 255, g * 255, b * 255, floor(min / max * 100))
			elseif unit == "target" then
				bar.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
			else
				bar.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", r * 255, g * 255, b * 255, floor(min / max * 100))
			end
		else
			if unit ~= "player" and unit ~= "pet" then
				bar.value:SetText("|cff559655"..ShortValue(max).."|r")
			else
				bar.value:SetText("|cff559655"..max.."|r")
			end
		end
	end
end

local PostNamePosition = function(self)
	self.Info:ClearAllPoints()
	if self.Power.value:GetText() then
		self.Info:SetPoint("CENTER", 0, 1)
	else
		self.Info:SetPoint("LEFT", 1, 1)
	end
end

local PreUpdatePower = function(self, event, unit)
	if(self.unit ~= unit) then return end
	local _, pType = UnitPowerType(unit)
	
	local color = self.colors.power[pType]
	if color then
		self.Power:SetStatusBarColor(color[1], color[2], color[3])
	end
end

local PostUpdatePower = function(self, event, unit, bar, min, max)
	if self.unit ~= "player" and self.unit ~= "pet" and self.unit ~= "target" then return end

	local pType, pToken = UnitPowerType(unit)
	local color = colors.power[pToken]

	if color then
		bar.value:SetTextColor(color[1], color[2], color[3])
	end

	if min == 0 then
		bar.value:SetText()
	elseif not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) or not UnitIsConnected(unit) then
		bar.value:SetText()
	elseif UnitIsDead(unit) or UnitIsGhost(unit) then
		bar.value:SetText()
	elseif min == max and (pType == 2 or pType == 3 and pToken ~= "POWER_TYPE_PYRITE") then
		bar.value:SetText()
	else
		if min ~= max then
			if pType == 0 then
				if unit == "target" then
					bar.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), ShortValue(max - (max - min)))
				elseif unit == "player" and self:GetAttribute("normalUnit") == "pet" or unit == "pet" then
					bar.value:SetFormattedText("%d%%", floor(min / max * 100))
				else
					bar.value:SetFormattedText("%d%% |cffD7BEA5-|r %d", floor(min / max * 100), max - (max - min))
				end
			else
				bar.value:SetText(max - (max - min))
			end
		else
			if unit == "pet" or unit == "target" then
				bar.value:SetText(ShortValue(min))
			else
				bar.value:SetText(min)
			end
		end
	end
	if self.Info then
		if self.unit == "pet" or self.unit == "target" then PostNamePosition(self) end
	end
end

do
	local f = CreateFrame("Frame")
	local entering

	f:RegisterEvent("UNIT_ENTERED_VEHICLE")
	f:RegisterEvent("UNIT_EXITED_VEHICLE")
	
	local delay = 0.5
	local OnUpdate = function(self, elapsed)
		self.elapsed = (self.elapsed or delay) - elapsed
		if self.elapsed <= 0 then
			local petframe = oUF_Caellian_pet
			petframe:PLAYER_ENTERING_WORLD()
			self:SetScript("OnUpdate", nil)
			if entering and petframe.PostEnterVehicle then
				petframe:PostEnterVehicle("enter")
			elseif not entering and petframe.PostExitVehicle then
				petframe:PostExitVehicle("exit")
			end
		end
	end

	f:SetScript("OnEvent", function(self, event, unit)
		if unit == "player" then
			if event == "UNIT_ENTERED_VEHICLE" then
				entering = true
			else
				entering = false
			end
			f.elapsed = delay
			f:SetScript("OnUpdate", OnUpdate)
		end
	end)
end

local EnterVehicle = function(self, event)
	if event == "enter" then
		self.Info:Hide()
	end
end

local ExitVehicle = function(self, event)
	if event == "exit" then
		self.Info:Show()
	end
end

local delay = 0
local viperAspectName = GetSpellInfo(34074)
local UpdateManaLevel = function(self, elapsed)
	delay = delay + elapsed
	if self.parent.unit ~= "player" or delay < 0.2 or UnitIsDeadOrGhost("player") or UnitPowerType("player") ~= 0 then return end
	delay = 0

	local percMana = UnitMana("player") / UnitManaMax("player") * 100

	if AotV then
		local viper = UnitBuff("player", viperAspectName)
		if percMana >= highThreshold and viper then
			self.ManaLevel:SetText("|cffaf5050GO HAWK|r")
			Flash(self, 0.3)
		elseif percMana <= lowThreshold and not viper then
			self.ManaLevel:SetText("|cffaf5050GO VIPER|r")
			Flash(self, 0.3)
		else
			self.ManaLevel:SetText()
			StopFlash(self)
		end
	else
		if percMana <= lowThreshold then
			self.ManaLevel:SetText("|cffaf5050LOW MANA|r")
			Flash(self, 0.3)
		else
			self.ManaLevel:SetText()
			StopFlash(self)
		end
	end
end

local UpdateDruidMana = function(self)
	if self.unit ~= "player" then return end

	local num, str = UnitPowerType("player")
	if num ~= 0 then
		local min = UnitPower("player", 0)
		local max = UnitPowerMax("player", 0)

		local percMana = min / max * 100
		if percMana <= lowThreshold then
			self.FlashInfo.ManaLevel:SetText("|cffaf5050LOW MANA|r")
			Flash(self.FlashInfo, 0.3)
		else
			self.FlashInfo.ManaLevel:SetText()
			StopFlash(self.FlashInfo)
		end

		if min ~= max then
			if self.Power.value:GetText() then
				self.DruidMana:SetPoint("LEFT", self.Power.value, "RIGHT", 1, 0)
				self.DruidMana:SetFormattedText("|cffD7BEA5-|r %d%%|r", floor(min / max * 100))
			else
				self.DruidMana:SetPoint("LEFT", 1, 1)
				self.DruidMana:SetFormattedText("%d%%", floor(min / max * 100))
			end
		else
			self.DruidMana:SetText()
		end

		self.DruidMana:SetAlpha(1)
	else
		self.DruidMana:SetAlpha(0)
	end
end

local UpdateCPoints = function(self, event, unit)
	if unit == PlayerFrame.unit and unit ~= self.CPoints.unit then
--	if oUF_Caellian_player.unit == unit or PlayerFrame.unit == unit then
		self.CPoints.unit = unit
	end
end

local FormatCastbarTime = function(self, duration)
	if self.channeling then
		self.Time:SetFormattedText("%.1f ", duration)
	elseif self.casting then
		self.Time:SetFormattedText("%.1f ", self.max - duration)
	end
end

local UpdateReputationColor = function(self, event, unit, bar)
	local name, id = GetWatchedFactionInfo()
	bar:SetStatusBarColor(FACTION_BAR_COLORS[id].r, FACTION_BAR_COLORS[id].g, FACTION_BAR_COLORS[id].b)
end

local FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		if s <= minute * 5 then
			return format('%d:%02d', floor(s/60), s % minute), s - floor(s)
		end
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
end

local CreateAuraTimer = function(self,elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = FormatTime(self.timeLeft)
--				if type(time) == "string" or time >= 10 then
					self.remaining:SetText(time)
--				else
--					self.remaining:SetFormattedText("%.1f", time)
--				end
				self.remaining:SetTextColor(0.84, 0.75, 0.65)
			else
				self.remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

local HideAura = function(self)
	if self.unit == "player" then
		if settings.noPlayerAuras then
			self.Buffs:Hide()
			self.Debuffs:Hide()
		else
			BuffFrame:Hide()
			TemporaryEnchantFrame:Hide()
		end
	elseif self.unit == "pet" and settings.noPetAuras or self.unit == "targettarget" and settings.noToTAuras then
		self.Auras:Hide()
	elseif self.unit == "target" and settings.noTargetAuras then
		self.Buffs:Hide()
		self.Debuffs:Hide()
	end
end

local CancelAura = function(self, button)
	if button == "RightButton" and not self.debuff then
		CancelUnitBuff("player", self:GetID())
	end
end

local CreateAura = function(self, button, icons)
	button.backdrop = CreateFrame("Frame", nil, button)
	button.backdrop:SetPoint("TOPLEFT", button, "TOPLEFT", -3.5, 3)
	button.backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -3.5)
	button.backdrop:SetFrameStrata("BACKGROUND")
	button.backdrop:SetBackdrop {
		edgeFile = glowTex, edgeSize = 5,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	button.backdrop:SetBackdropColor(0, 0, 0, 0)
	button.backdrop:SetBackdropBorderColor(0, 0, 0)

	button.count:SetPoint("BOTTOMRIGHT", 1, 1.5)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFont(fontn, 8, "THICKOUTLINE")
	button.count:SetTextColor(0.84, 0.75, 0.65)

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	icons.disableCooldown = true

	button.overlay:SetTexture(buttonTex)
	button.overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
	button.overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
	button.overlay:SetTexCoord(0, 1, 0.02, 1)
	button.overlay.Hide = function(self) end

	if icons ~= self.Enchant then
		button.remaining = SetFontString(button, fontn, 8, "OUTLINE")
		if self.unit == "player" then
			button:SetScript("OnMouseUp", CancelAura)
		end
	else
		button.remaining = SetFontString(button, fontn, 8, "OUTLINE")
		button.overlay:SetVertexColor(0.33, 0.59, 0.33)
	end
	button.remaining:SetPoint("TOPLEFT", 1, -1)
end

local CreateEnchantTimer = function(self, icons)
	for i = 1, 2 do
		local icon = icons[i]
		if icon.expTime then
			icon.timeLeft = icon.expTime - GetTime()
			icon.remaining:Show()
		else
			icon.remaining:Hide()
		end
		icon:SetScript("OnUpdate", CreateAuraTimer)
	end
end

local UpdateAura = function(self, icons, unit, icon, index)
	local _, _, _, _, _, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)
	if unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle" then
		if icon.debuff then
			icon.overlay:SetVertexColor(0.69, 0.31, 0.31)
		else
			icon.overlay:SetVertexColor(0.33, 0.59, 0.33)
		end
	else
		if UnitIsEnemy("player", unit) then
			if icon.debuff then
				icon.icon:SetDesaturated(true)
			end
		end
		icon.overlay:SetVertexColor(0.25, 0.25, 0.25)
	end

	if duration and duration > 0 then
		icon.remaining:Show()
	else
		icon.remaining:Hide()
	end

	icon.duration = duration
	icon.timeLeft = expirationTime
	icon.first = true
	icon:SetScript("OnUpdate", CreateAuraTimer)
end

local HidePortrait = function(self, unit)
	if self.unit == "target" then
		if not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit) then
			self.Portrait:SetAlpha(0)
		else
			self.Portrait:SetAlpha(1)
		end
	end
end

local PostUpdateThreat = function(self, event, unit, status)
	if not status or status == 0 then
		self.ThreatFeedbackFrame:SetBackdropBorderColor(0, 0, 0)
		self.ThreatFeedbackFrame:Show()
	end
end

local SetStyle = function(self, unit)
	self.menu = Menu
	self.colors = colors
	self:RegisterForClicks("AnyUp")
	self:SetAttribute("type2", "menu")

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0)

	self.Health = CreateFrame("StatusBar", self:GetName().."_Health", self)
	if unit then
		self.Health:SetFrameLevel(1)
	elseif self:GetAttribute("unitsuffix") then
		self.Health:SetFrameLevel(3)
	elseif not unit then
		self.Health:SetFrameLevel(2)
	end
	self.Health:SetHeight((unit == "player" or unit == "target" or self:GetParent():GetName():match("oUF_Raid")) and 22 or self:GetAttribute("unitsuffix") == "pet" and 10 or 16)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(normTex)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = true

	self.Health.frequentUpdates = true
	self.Health.Smooth = true

	self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(normTex)
	self.Health.bg.multiplier = 0.33

	self.Health.value = SetFontString(self.Health, font,(unit == "player" or unit == "target") and 11 or 9)
	if self:GetParent():GetName():match("oUF_Raid") then
		self.Health.value:SetPoint("BOTTOMRIGHT", -1, 2)
	else
		self.Health.value:SetPoint("RIGHT", -1, 1)
	end

	if unit ~= "player" then
		self.Info = SetFontString(self.Health, font, unit == "target" and 11 or 9)
		if self:GetParent():GetName():match("oUF_Raid") then
			self.Info:SetPoint("TOPLEFT", 1, 0)
			self:Tag(self.Info, "[GetNameColor][NameShort]")
		elseif unit == "target" then
			self.Info:SetPoint("LEFT", 1, 1)
			self:Tag(self.Info, "[GetNameColor][NameLong] [DiffColor][level] [shortclassification]")
		else
			self.Info:SetPoint("LEFT", 1, 1)
			self:Tag(self.Info, "[GetNameColor][NameMedium]")
		end
	end

	if not (self:GetAttribute("unitsuffix") == "pet") then
		self.Power = CreateFrame("StatusBar", self:GetName().."_Power", self)
		self.Power:SetHeight((unit == "player" or unit == "target") and 7 or 5)
		self.Power:SetPoint("BOTTOMLEFT")
		self.Power:SetPoint("BOTTOMRIGHT")
		self.Power:SetStatusBarTexture(normTex)

		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorPower = unit == "player" or unit == "pet" and true
		self.Power.colorClass = true
		self.Power.colorReaction = true

		self.Power.frequentUpdates = true
		self.Power.Smooth = true

		self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
		self.Power.bg:SetAllPoints(self.Power)
		self.Power.bg:SetTexture(normTex)
		self.Power.bg.multiplier = 0.33

		self.Power.value = SetFontString(self.Health, font, (unit == "player" or unit == "target") and 11 or 9)
		self.Power.value:SetPoint("LEFT", 1, 1)
	end

	if unit == "player" then
		self.Combat = self.Health:CreateTexture(nil, "OVERLAY")
		self.Combat:SetHeight(12)
		self.Combat:SetWidth(12)
		self.Combat:SetPoint("CENTER")
		self.Combat:SetTexture(bubbleTex)
		self.Combat:SetVertexColor(0.69, 0.31, 0.31)

		self.FlashInfo = CreateFrame("Frame", "FlashInfo", self)
		self.FlashInfo:SetScript("OnUpdate", UpdateManaLevel)
		self.FlashInfo.parent = self
		self.FlashInfo:SetToplevel(true)
		self.FlashInfo:SetAllPoints(self.Health)

		self.FlashInfo.ManaLevel = SetFontString(self.FlashInfo, font, 11)
		self.FlashInfo.ManaLevel:SetPoint("CENTER", 0, 1)

		if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
			self.Resting = self.Power:CreateTexture(nil, "OVERLAY")
			self.Resting:SetHeight(18)
			self.Resting:SetWidth(18)
			self.Resting:SetPoint("BOTTOMLEFT", -8.5, -8.5)
			self.Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
			self.Resting:SetTexCoord(0, 0.5, 0, 0.421875)
		end

		if IsAddOnLoaded("oUF_WeaponEnchant") then
			self.Enchant = CreateFrame("Frame", nil, self)
			self.Enchant:SetHeight(24)
			self.Enchant:SetWidth(24 * 2)
			self.Enchant:SetPoint("TOPLEFT", self, "TOPRIGHT", 9, 1)
			self.Enchant.size = 24
			self.Enchant.spacing = 1
			self.Enchant.initialAnchor = "TOPLEFT"
			self.Enchant["growth-x"] = "RIGHT"
		end

		if IsAddOnLoaded("oUF_Reputation") then
			self.Reputation = CreateFrame("StatusBar", self:GetName().."_Reputation", self)
			self.Reputation:SetHeight(5)
			self.Reputation:SetPoint("TOPLEFT", self.Health, "TOP", 2, 7.5)
			self.Reputation:SetPoint("TOPRIGHT", self.Health, "TOPRIGHT", 0, 7.5)
			self.Reputation:SetStatusBarTexture(normTex)
			self.Reputation:SetBackdrop(backdrop)
			self.Reputation:SetBackdropColor(0, 0, 0)

			self.Reputation.bg = self.Reputation:CreateTexture(nil, "BORDER")
			self.Reputation.bg:SetAllPoints(self.Reputation)
			self.Reputation.bg:SetTexture(normTex)
			self.Reputation.bg:SetVertexColor(0.15, 0.15, 0.15)

			self.Reputation.PostUpdate = UpdateReputationColor
			self.Reputation.MouseOver = true
			self.Reputation.Tooltip = true
		end

		if IsAddOnLoaded("oUF_Swing") then
			self.Swing = CreateFrame("StatusBar", self:GetName().."_Swing", self)
			self.Swing:SetHeight(5)
			self.Swing:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 50)
			self.Swing:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 50)
			self.Swing:SetStatusBarTexture(normTex)
			self.Swing:SetStatusBarColor(0.55, 0.57, 0.61)
			self.Swing:SetBackdrop(backdrop)
			self.Swing:SetBackdropColor(0, 0, 0)

			self.Swing.bg = self.Swing:CreateTexture(nil, "BORDER")
			self.Swing.bg:SetAllPoints(self.Swing)
			self.Swing.bg:SetTexture(normTex)
			self.Swing.bg:SetVertexColor(0.15, 0.15, 0.15)
		end

		if IsAddOnLoaded("oUF_RuneBar") and class == "DEATHKNIGHT" then
			self.RuneBar = {}
			for i = 1, 6 do
				self.RuneBar[i] = CreateFrame("StatusBar", self:GetName().."_RuneBar"..i, self)
				self.RuneBar[i]:SetHeight(7)
				self.RuneBar[i]:SetWidth(230/6 - 0.85)
				if (i == 1) then
					self.RuneBar[i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -1)
				else
					self.RuneBar[i]:SetPoint("TOPLEFT", self.RuneBar[i-1], "TOPRIGHT", 1, 0)
				end
				self.RuneBar[i]:SetStatusBarTexture(normTex)
				self.RuneBar[i]:SetBackdrop(backdrop)
				self.RuneBar[i]:SetBackdropColor(0, 0, 0)
				self.RuneBar[i]:SetMinMaxValues(0, 1)

				self.RuneBar[i].bg = self.RuneBar[i]:CreateTexture(nil, "BORDER")
				self.RuneBar[i].bg:SetAllPoints(self.RuneBar[i])
				self.RuneBar[i].bg:SetTexture(normTex)
				self.RuneBar[i].bg:SetVertexColor(0.15, 0.15, 0.15)
			end
		end

		if IsAddOnLoaded("oUF_TotemBar") and class == "SHAMAN" then
			self.TotemBar = {}
			for i = 1, 4 do
				self.TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
				self.TotemBar[i]:SetHeight(7)
				self.TotemBar[i]:SetWidth(230/4 - 0.75)
				if (i == 1) then
					self.TotemBar[i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -1)
				else
					self.TotemBar[i]:SetPoint("TOPLEFT", self.TotemBar[i-1], "TOPRIGHT", 1, 0)
				end
				self.TotemBar[i]:SetStatusBarTexture(normTex)
				self.TotemBar[i]:SetBackdrop(backdrop)
				self.TotemBar[i]:SetBackdropColor(0, 0, 0)
				self.TotemBar[i]:SetMinMaxValues(0, 1)

				self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
				self.TotemBar[i].bg:SetAllPoints(self.TotemBar[i])
				self.TotemBar[i].bg:SetTexture(normTex)
				self.TotemBar[i].bg:SetVertexColor(0.15, 0.15, 0.15)
			end
		end

		if class == "DRUID" then
			CreateFrame("Frame"):SetScript("OnUpdate", function() UpdateDruidMana(self) end)
			self.DruidMana = SetFontString(self.Health, font, 11)
			self.DruidMana:SetTextColor(1, 0.49, 0.04)
		end
	end

	if unit == "pet" or unit == "targettarget" then
		self.Auras = CreateFrame("Frame", nil, self)
		self.Auras:SetHeight(24)
		self.Auras:SetWidth(24 * 8)
		self.Auras.size = 24
		self.Auras.spacing = 1
		self.Auras.numBuffs = 16
		self.Auras.numDebuffs = 16
		self.Auras.gap = true
		if unit == "pet" then
			self.Auras:SetPoint("TOPRIGHT", self, "TOPLEFT", -9, 1)
			self.Auras.initialAnchor = "TOPRIGHT"
			self.Auras["growth-x"] = "LEFT"

			self.PostEnterVehicle = EnterVehicle
			self.PostExitVehicle = ExitVehicle
		else
			self.Auras:SetPoint("TOPLEFT", self, "TOPRIGHT", 9, 1)
			self.Auras.initialAnchor = "TOPLEFT"
		end
	end

	if unit == "player" or unit =="pet" then
		if IsAddOnLoaded("oUF_Experience") then
			self.Experience = CreateFrame("StatusBar", self:GetName().."_Experience", self)
			self.Experience:SetHeight(5)
			self.Experience:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 7.5)
			self.Experience:SetStatusBarTexture(normTex)
			self.Experience:SetStatusBarColor(0.55, 0.57, 0.61)
			self.Experience:SetBackdrop(backdrop)
			self.Experience:SetBackdropColor(0, 0, 0)
			if unit == "player" then
				self.Experience:SetPoint("TOPRIGHT", self, "TOP", -2, 7.5)
			elseif unit == "pet" then
				self.Experience:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 4)
			end

			self.Experience.bg = self.Experience:CreateTexture(nil, "BORDER")
			self.Experience.bg:SetAllPoints(self.Experience)
			self.Experience.bg:SetTexture(normTex)
			self.Experience.bg:SetVertexColor(0.15, 0.15, 0.15)

			self.Experience.MouseOver = true
			self.Experience.Tooltip = true
		end
	end

	if unit == "player" or unit == "target" then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetHeight(24)
		self.Buffs:SetWidth(24 * 8)
		self.Buffs.size = 24
		self.Buffs.spacing = 1

		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetHeight(23 * 0.97)
		self.Debuffs:SetWidth(230)
		self.Debuffs.size = 23 * 0.97
		self.Debuffs.spacing = 1
		if unit == "player" then
			self.Buffs:SetPoint("TOPRIGHT", self, "TOPLEFT", -9, 1)
			self.Buffs.initialAnchor = "TOPRIGHT"
			self.Buffs["growth-x"] = "LEFT"
			self.Buffs["growth-y"] = "DOWN"
			self.Buffs.filter = true

			self.Debuffs.initialAnchor = "TOPLEFT"
			self.Debuffs["growth-y"] = "DOWN"
			if IsAddOnLoaded("oUF_RuneBar") and class == "DEATHKNIGHT" or IsAddOnLoaded("oUF_TotemBar") and class == "SHAMAN" then
				self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -1, -15)
			else
				self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -1, -7.5)
			end

		elseif unit == "target" then
			self.Buffs:SetPoint("TOPLEFT", self, "TOPRIGHT", 9, 1)
			self.Buffs.initialAnchor = "TOPLEFT"
			self.Buffs["growth-y"] = "DOWN"

			self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -1, -8)
			self.Debuffs.initialAnchor = "TOPLEFT"
			self.Debuffs["growth-y"] = "DOWN"
			self.Debuffs.onlyShowPlayer = false

			self.CPoints = {}
			self.CPoints.unit = PlayerFrame.unit
			for i = 1, 5 do
				self.CPoints[i] = self.Power:CreateTexture(nil, "OVERLAY")
				self.CPoints[i]:SetHeight(12)
				self.CPoints[i]:SetWidth(12)
				self.CPoints[i]:SetTexture(bubbleTex)
				if i == 1 then
					self.CPoints[i]:SetPoint("LEFT")
					self.CPoints[i]:SetVertexColor(0.69, 0.31, 0.31)
				else
					self.CPoints[i]:SetPoint("LEFT", self.CPoints[i-1], "RIGHT", 1)
				end
			end
			self.CPoints[2]:SetVertexColor(0.69, 0.31, 0.31)
			self.CPoints[3]:SetVertexColor(0.65, 0.63, 0.35)
			self.CPoints[4]:SetVertexColor(0.65, 0.63, 0.35)
			self.CPoints[5]:SetVertexColor(0.33, 0.59, 0.33)
			self:RegisterEvent("UNIT_COMBO_POINTS", UpdateCPoints)
		end
	
			self.Portrait = CreateFrame("PlayerModel", nil, self)
			self.Portrait:SetFrameLevel(1)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -23)
			self.Portrait:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 8)
			table.insert(self.__elements, HidePortrait)
	
			self.PortraitOverlay = CreateFrame("StatusBar", self:GetName().."_PortraitOverlay", self.Portrait)
			self.PortraitOverlay:SetFrameLevel(2)
			self.PortraitOverlay:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -22)
			self.PortraitOverlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 7)
			self.PortraitOverlay:SetStatusBarTexture(normTex)
			self.PortraitOverlay:SetStatusBarColor(0.25, 0.25, 0.25, 0.5)

			self.ThinLine1 = self.PortraitOverlay:CreateTexture(nil, "OVERLAY")
			self.ThinLine1:SetHeight(1)
			self.ThinLine1:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -22)
			self.ThinLine1:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -22)
			self.ThinLine1:SetTexture(0,0,0)

			self.ThinLine2 = self.PortraitOverlay:CreateTexture(nil, "OVERLAY")
			self.ThinLine2:SetHeight(1)
			self.ThinLine2:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 7)
			self.ThinLine2:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 7)
			self.ThinLine2:SetTexture(0,0,0)

			self.CombatFeedbackText = SetFontString(self.PortraitOverlay, font, 18, "OUTLINE")
			self.CombatFeedbackText:SetPoint("CENTER", 0, 1)
			self.CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}
	
			self.Status = SetFontString(self.PortraitOverlay, font, 18, "OUTLINE")
			self.Status:SetPoint("CENTER", 0, 1)
			self.Status:SetTextColor(0.69, 0.31, 0.31, 0)
			self:Tag(self.Status, "[pvp]")
	
			self:SetScript("OnEnter", function(self) self.Status:SetAlpha(.25); UnitFrame_OnEnter(self) end)
			self:SetScript("OnLeave", function(self) self.Status:SetAlpha(0); UnitFrame_OnLeave(self) end)
		end

	if not (self:GetParent():GetName():match("oUF_Raid") or self:GetAttribute("unitsuffix") == "pet") then
		self.Castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
		self.Castbar:SetStatusBarTexture(normTex)
		self.Castbar:SetStatusBarColor(0.55, 0.57, 0.61, 0.5)

		self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
		self.Castbar.bg:SetAllPoints(self.Castbar)
		self.Castbar.bg:SetTexture(normTex)
		self.Castbar.bg:SetVertexColor(0.15, 0.15, 0.15, 0.75)


		if unit == "player" or unit == "target" then
			self.Castbar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -23)
			self.Castbar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 8)
		else
			self.Castbar:SetHeight(5)
			self.Castbar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 7.5)
			self.Castbar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 7.5)
			self.Castbar:SetBackdrop(backdrop)
			self.Castbar:SetBackdropColor(0, 0, 0)
		end

		if unit == "player" or unit == "target" then
			self.Castbar.Time = SetFontString(self.Castbar, font, 11)
			self.Castbar.Time:SetPoint("RIGHT", -1, 1)
			self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
			self.Castbar.Time:SetJustifyH("RIGHT")
			self.Castbar.CustomTimeText = FormatCastbarTime

			self.Castbar.Text = SetFontString(self.Castbar, font, 11)
			self.Castbar.Text:SetPoint("LEFT", 1, 1)
			self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -1, 0)
			self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)

			self.Castbar.Icon = self.Castbar:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetHeight(23 * 1.04)
			self.Castbar.Icon:SetWidth(23 * 1.04)
			self.Castbar.Icon:SetTexCoord(0, 1, 0, 1)
			if unit == "player" then
				self.Castbar.Icon:SetPoint("RIGHT", 33, 0)
			elseif unit == "target" then
				self.Castbar.Icon:SetPoint("LEFT", -31.5, 0)
			end

			self.IconOverlay = self.Castbar:CreateTexture(nil, "OVERLAY")
			self.IconOverlay:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -1, 1)
			self.IconOverlay:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", 1, -1)
			self.IconOverlay:SetTexture(buttonTex)
			self.IconOverlay:SetVertexColor(0.25, 0.25, 0.25)

			self.IconBackdrop = CreateFrame("Frame", nil, self)
			self.IconBackdrop:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -4, 3)
			self.IconBackdrop:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", 4, -3.5)
			self.IconBackdrop:SetParent(self.Castbar)
			self.IconBackdrop:SetBackdrop({
			  edgeFile = glowTex, edgeSize = 4,
			  insets = {left = 3, right = 3, top = 3, bottom = 3}
			})
			self.IconBackdrop:SetBackdropColor(0, 0, 0, 0)
			self.IconBackdrop:SetBackdropBorderColor(0, 0, 0, 0.7)
		end

		if unit == "player" then
			self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "ARTWORK")
			self.Castbar.SafeZone:SetTexture(normTex)
			self.Castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		end
	end

	if not unit or unit == "player" then
		self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
		self.Leader:SetHeight(14)
		self.Leader:SetWidth(14)
		self.Leader:SetPoint("TOPLEFT", 0, 10)

		self.MasterLooter = self.Health:CreateTexture(nil, "OVERLAY")
		self.MasterLooter:SetHeight(12)
		self.MasterLooter:SetWidth(12)
		self.MasterLooter:SetPoint("TOPRIGHT", 0, 10)
		if not unit then
			self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
			self.ReadyCheck:SetHeight(12)
			self.ReadyCheck:SetWidth(12)
			if (self:GetParent():GetName():match("oUF_Raid")) then
				self.ReadyCheck:SetPoint("BOTTOMLEFT", 13, 1)
			else
				self.ReadyCheck:SetPoint("TOPRIGHT", 7, 7)
			end
		end
	end

	if unit == "player" or unit == "target" then
		self:SetAttribute("initial-height", 53)
		self:SetAttribute("initial-width", 230)
	elseif self:GetAttribute("unitsuffix") == "pet" then
		self:SetAttribute("initial-height", 10)
		self:SetAttribute("initial-width", 113)
	elseif self:GetParent():GetName():match("oUF_Raid") then
		self:SetAttribute("initial-height", 28)
		self:SetAttribute("initial-width", 60)
	else
		self:SetAttribute("initial-height", 22)
		self:SetAttribute("initial-width", 113)
	end

	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetHeight((self:GetParent():GetName():match("oUF_Raid")) and 10 or 14)
	self.RaidIcon:SetWidth((self:GetParent():GetName():match("oUF_Raid")) and 10 or 14)
	if self:GetParent():GetName():match("oUF_Raid") then
		self.RaidIcon:SetPoint("BOTTOMLEFT", 1, 2)
	else
		self.RaidIcon:SetPoint("TOP", 0, 8)
	end

	self.Highlight = self:CreateTexture(nil, "HIGHLIGHT")
	self.Highlight:SetAllPoints(self.Health)
	self.Highlight:SetTexture(normTex)
	self.Highlight:SetVertexColor(0.84, 0.75, 0.65, 0.15)
	self.Highlight:SetBlendMode("ADD")

	self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.DebuffHighlight:SetAllPoints(self.Health)
	self.DebuffHighlight:SetTexture(highlightTex)
	self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	self.DebuffHighlight:SetBlendMode("ADD")
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightFilter = true

	self.FrameBackdrop = CreateFrame("Frame", nil, self)
	self.FrameBackdrop:SetPoint("TOPLEFT", self, "TOPLEFT", -4.5, 4)
	self.FrameBackdrop:SetFrameStrata("BACKGROUND")
	self.FrameBackdrop:SetBackdrop {
	  edgeFile = glowTex, edgeSize = 5,
	  insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	self.FrameBackdrop:SetBackdropColor(0, 0, 0, 0)
	self.FrameBackdrop:SetBackdropBorderColor(0, 0, 0)

	if IsAddOnLoaded("oUF_RuneBar") and unit == "player" and class == "DEATHKNIGHT" or IsAddOnLoaded("oUF_TotemBar") and unit == "player" and class == "SHAMAN" then
		self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4.5, -12)
	else
		self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4.5, -4.5)
	end
	self.ThreatFeedbackFrame = self.FrameBackdrop

	self.MoveableFrames = true
	self.outsideRangeAlpha = 0.4
	self.inRangeAlpha = 1
	self.SpellRange = true

	self.BarFade = false

	local AggroSelect = function() if (UnitExists("target")) then PlaySound("igCreatureAggroSelect") end end
	self:RegisterEvent("PLAYER_TARGET_CHANGED", AggroSelect)

	self.PostUpdateHealth = PostUpdateHealth
	self.PreUpdatePower = PreUpdatePower
	self.PostUpdatePower = PostUpdatePower
	self.PostCreateAuraIcon = CreateAura
	self.PostCreateEnchantIcon = CreateAura
	self.PostUpdateAuraIcon = UpdateAura
	self.PostUpdateEnchantIcons = CreateEnchantTimer
	self.PostUpdateThreat = PostUpdateThreat

	self:SetScale(settings.scale)
	if self.Auras then self.Auras:SetScale(settings.scale) end
	if self.Buffs then self.Buffs:SetScale(settings.scale) end
	if self.Debuffs then self.Debuffs:SetScale(settings.scale) end

	HideAura(self)
	return self
end

oUF:RegisterStyle("Caellian", SetStyle)
oUF:SetActiveStyle("Caellian")

local cfg = settings.coords

oUF:Spawn("player", "oUF_Caellian_player"):SetPoint("BOTTOM", UIParent, cfg.playerX, cfg.playerY)
oUF:Spawn("target", "oUF_Caellian_target"):SetPoint("BOTTOM", UIParent, cfg.targetX, cfg.targetY)

oUF:Spawn("pet", "oUF_Caellian_pet"):SetPoint("BOTTOMLEFT", oUF_Caellian_player, "TOPLEFT", 0, 10)
oUF:Spawn("focus", "oUF_Caellian_focus"):SetPoint("BOTTOMRIGHT", oUF_Caellian_player, "TOPRIGHT", 0, 10)
oUF:Spawn("focustarget", "oUF_Caellian_focustarget"):SetPoint("BOTTOMLEFT", oUF_Caellian_target, "TOPLEFT", 0, 10)
oUF:Spawn("targettarget", "oUF_Caellian_targettarget"):SetPoint("BOTTOMRIGHT", oUF_Caellian_target, "TOPRIGHT", 0, 10)

local party = oUF:Spawn("header", "oUF_Party")
party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cfg.partyX, cfg.partyY)
party:SetAttribute("showParty", true)
party:SetAttribute("yOffset", -27.5)
party:SetAttribute("template", "oUF_cParty")

local raid = {}
for i = 1, NUM_RAID_GROUPS do
	local raidgroup = oUF:Spawn("header", "oUF_Raid"..i)
	raidgroup:SetAttribute("groupFilter", tostring(i))
	raidgroup:SetAttribute("showRaid", true)
	raidgroup:SetAttribute("yOffSet", -7.5)
	table.insert(raid, raidgroup)
	if i == 1 then
		raidgroup:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cfg.raidX, cfg.raidY)
	else
		raidgroup:SetPoint("TOPLEFT", raid[i-1], "TOPRIGHT", (60 * settings.scale - 60) + 7.5, 0)
	end
end

local partyToggle = CreateFrame("Frame")
partyToggle:RegisterEvent("PLAYER_LOGIN")
partyToggle:RegisterEvent("RAID_ROSTER_UPDATE")
partyToggle:RegisterEvent("PARTY_LEADER_CHANGED")
partyToggle:RegisterEvent("PARTY_MEMBERS_CHANGED")
partyToggle:SetScript("OnEvent", function(self)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		local numraid = GetNumRaidMembers()
		if numraid > 0 and (numraid > 5 or numraid ~= GetNumPartyMembers() + 1) then
			party:Hide()
			if not settings.noRaid then
				for i,v in ipairs(raid) do v:Show() end
			end
		else
			party:Show()
			if not settings.noRaid then
				for i,v in ipairs(raid) do v:Hide() end
			end
		end
	end
end)