﻿--[[	$Id$	]]

local _, oUF_Caellian = ...

oUF_Caellian.Main = CreateFrame("Frame", nil, UIParent)

Main = oUF_Caellian.Main

local settings = Caellian.oUF
local mediaPath = [=[Interface\Addons\caelMedia\]=]

local floor, format, insert, sort = math.floor, string.format, table.insert, table.sort

local normtex = caelMedia.files.statusBarC
local buttonTex = caelMedia.files.buttonNormal
local raidIcons = caelMedia.files.raidIcons
local bubbleTex = mediaPath..[=[miscellaneous\bubbletex]=]
local shaderTex = mediaPath..[=[miscellaneous\smallshadertex]=]
local highlightTex = mediaPath..[=[miscellaneous\highlighttex]=]

local font = settings.font
local fontn = caelMedia.fonts.OUF_CAELLIAN_NUMBERFONT

local pixelScale = caelLib.scale
local playerClass = caelLib.playerClass

local lowThreshold = settings.lowThreshold
local highThreshold = settings.highThreshold

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {top = pixelScale(-1), left = pixelScale(-1), bottom = pixelScale(-1), right = pixelScale(-1)},
}

local runeloadcolors = {
	[1] = {0.69, 0.31, 0.31},
	[2] = {0.69, 0.31, 0.31},
	[3] = {0.33, 0.59, 0.33},
	[4] = {0.33, 0.59, 0.33},
	[5] = {0.31, 0.45, 0.63},
	[6] = {0.31, 0.45, 0.63},
}

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
		[1] = {0.69, 0.31, 0.31},
		[2] = {0.65, 0.63, 0.35},
		[3] = {0.33, 0.59, 0.33},
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

--	oUF.colors.smooth = {0.69, 0.31, 0.31, 0.25, 0.25, 0.25, 0.15, 0.15, 0.15}

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

	if not self.anim:IsPlaying() or duration ~= self.anim.fadein:GetDuration() then
		self.anim.fadein:SetDuration(duration)
		self.anim.fadeout:SetDuration(duration)
		self.anim:Play()
	end
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
	fs:SetShadowOffset(0.75, -0.75)
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

local PostUpdateHealth = function(health, unit, min, max)

	if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
		local class = select(2, UnitClass(unit))
		local color = UnitIsPlayer(unit) and oUF.colors.class[class] or {0.84, 0.75, 0.65}

		health:SetValue(0)
		health.bg:SetVertexColor(color[1] * 0.5, color[2] * 0.5, color[3] * 0.5)

		if not UnitIsConnected(unit) then
			health.value:SetText("|cffD7BEA5".."Offline".."|r")
		elseif UnitIsDead(unit) then
			health.value:SetText("|cffD7BEA5".."Dead".."|r")
		elseif UnitIsGhost(unit) then
			health.value:SetText("|cffD7BEA5".."Ghost".."|r")
		end
	else
		local r, g, b
		r, g, b = oUF.ColorGradient(min/max, 0.69, 0.31, 0.31, 0.71, 0.43, 0.27, 0.17, 0.17, 0.24)

		health:SetStatusBarColor(r, g, b)
		health.bg:SetVertexColor(0.15, 0.15, 0.15)

		if min ~= max then
			r, g, b = oUF.ColorGradient(min/max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
			if unit == "player" and health:GetAttribute("normalUnit") ~= "pet" then
				health.value:SetFormattedText("|cffAF5050%d|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", min, r * 255, g * 255, b * 255, floor(min / max * 100))
			elseif unit == "target" then
				health.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
			elseif health:GetParent():GetName():match("oUF_Party") or health:GetParent():GetName():match("oUF_Raid") then
				health.value:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, ShortValue(floor(min - max)))
			else
				health.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", r * 255, g * 255, b * 255, floor(min / max * 100))
			end
		else
			if unit ~= "player" and unit ~= "pet" then
				health.value:SetText("|cff559655"..ShortValue(max).."|r")
			else
				health.value:SetText("|cff559655"..max.."|r")
			end
		end
	end
end

local PostUpdateName = function(self, power)
	self.Info:ClearAllPoints()
	if power.value:GetText() then
		self.Info:SetPoint("CENTER", 0, pixelScale(1))
	else
		self.Info:SetPoint("LEFT", pixelScale(1), pixelScale(1))
	end
end

local PreUpdatePower = function(power, unit)
	local _, pType = UnitPowerType(unit)
	
	local color = colors.power[pType]
	if color then
		power:SetStatusBarColor(color[1], color[2], color[3])
	end
end

local PostUpdatePower = function(power, unit, min, max)

	local self = power:GetParent()

	local pType, pToken = UnitPowerType(unit)
	local color = colors.power[pToken]

	if color then
		power.value:SetTextColor(color[1], color[2], color[3])
	end

	if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
		local class = select(2, UnitClass(unit))
		local color = UnitIsPlayer(unit) and oUF.colors.class[class] or {0.84, 0.75, 0.65}

		power:SetValue(0)
		power.bg:SetVertexColor(color[1] * 0.5, color[2] * 0.5, color[3] * 0.5)
	end

	if unit ~= "player" and unit ~= "pet" and unit ~= "target" then return end

	if min == 0 then
		power.value:SetText()
	elseif not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) or not UnitIsConnected(unit) then
		power.value:SetText()
	elseif UnitIsDead(unit) or UnitIsGhost(unit) then
		power.value:SetText()
	elseif min == max and (pType == 2 or pType == 3 and pToken ~= "POWER_TYPE_PYRITE") then
		power.value:SetText()
	else
		if min ~= max then
			if pType == 0 then
				if unit == "target" then
					power.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), ShortValue(max - (max - min)))
				elseif unit == "player" and power:GetAttribute("normalUnit") == "pet" or unit == "pet" then
					power.value:SetFormattedText("%d%%", floor(min / max * 100))
				else
					power.value:SetFormattedText("%d%% |cffD7BEA5-|r %d", floor(min / max * 100), max - (max - min))
				end
			else
				power.value:SetText(max - (max - min))
			end
		else
			if unit == "pet" or unit == "target" then
				power.value:SetText(ShortValue(min))
			else
				power.value:SetText(min)
			end
		end
	end
	if self.Info then
		if unit == "pet" or unit == "target" then PostUpdateName(self, power) end
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
		local min, max = UnitPower("player", 0), UnitPowerMax("player", 0)

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
				self.DruidMana:SetPoint("LEFT", self.Power.value, "RIGHT", pixelScale(1), 0)
				self.DruidMana:SetFormattedText("|cffD7BEA5-|r %d%%|r", floor(min / max * 100))
			else
				self.DruidMana:SetPoint("LEFT", pixelScale(1), pixelScale(1))
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
		self.CPoints.unit = unit
	end
end

local PostCastStart = function(Castbar, unit, name, rank, text, castid)
	Castbar.channeling = false
	if unit == "vehicle" then unit = "player" end

	if unit == "player" then
		local latency = GetTime() - Castbar.castSent
		latency = latency > Castbar.max and Castbar.max or latency
		Castbar.Latency:SetText(("%dms"):format(latency * 1e3))
		Castbar.SafeZone:SetWidth(pixelScale(Castbar:GetWidth() * latency / Castbar.max))
		Castbar.SafeZone:ClearAllPoints()
		Castbar.SafeZone:SetPoint("TOPRIGHT")
		Castbar.SafeZone:SetPoint("BOTTOMRIGHT")
	end

	if Castbar.interrupt and UnitCanAttack("player", unit) then
		Castbar:SetStatusBarColor(0.69, 0.31, 0.31)
	else
		Castbar:SetStatusBarColor(0.55, 0.57, 0.61)
	end
end

local PostChannelStart = function(Castbar, unit, name, rank, text)
	Castbar.channeling = true
	if unit == "vehicle" then unit = "player" end

	if unit == "player" then
		local latency = GetTime() - Castbar.castSent
		latency = latency > Castbar.max and Castbar.max or latency
		Castbar.Latency:SetText(("%dms"):format(latency * 1e3))
		Castbar.SafeZone:SetWidth(pixelScale(Castbar:GetWidth() * latency / Castbar.max))
		Castbar.SafeZone:ClearAllPoints()
		Castbar.SafeZone:SetPoint("TOPLEFT")
		Castbar.SafeZone:SetPoint("BOTTOMLEFT")
	end

	if Castbar.interrupt and UnitCanAttack("player", unit) then
		Castbar:SetStatusBarColor(0.69, 0.31, 0.31)
	else
		Castbar:SetStatusBarColor(0.55, 0.57, 0.61)
	end
end

local CustomCastTimeText = function(self, duration)
	self.Time:SetText(("%.1f / %.1f"):format(self.channeling and duration or self.max - duration, self.max))
end

local CustomCastDelayText = function(self, duration)
	self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay))
end

local FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		if s <= minute * 5 then
			return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
		end
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
end

local CreateAuraTimer = function(self, elapsed)
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
				if self.timeLeft < 5 then
					self.remaining:SetTextColor(0.69, 0.31, 0.31)
				else
					self.remaining:SetTextColor(0.84, 0.75, 0.65)
				end
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

local PostCreateAura = function(auras, button)
	button.backdrop = CreateFrame("Frame", nil, button)
	button.backdrop:SetPoint("TOPLEFT", button, pixelScale(-3), pixelScale(3))
	button.backdrop:SetPoint("BOTTOMRIGHT", button, pixelScale(3), pixelScale(-3))
	button.backdrop:SetFrameStrata("BACKGROUND")
	button.backdrop:SetBackdrop(caelMedia.borderTable)
	button.backdrop:SetBackdropColor(0, 0, 0, 0)
	button.backdrop:SetBackdropBorderColor(0, 0, 0)

	button.count:SetPoint("BOTTOMRIGHT", pixelScale(1), pixelScale(1.5))
	button.count:SetJustifyH("RIGHT")
	button.count:SetFont(fontn, 8, "THICKOUTLINE")
	button.count:SetTextColor(0.84, 0.75, 0.65)

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	auras.disableCooldown = true

	button.overlay:SetTexture(buttonTex)
	button.overlay:SetPoint("TOPLEFT", button, pixelScale(-1), pixelScale(1))
	button.overlay:SetPoint("BOTTOMRIGHT", button, pixelScale(1), pixelScale(-1))
	button.overlay:SetTexCoord(0, 1, 0.02, 1)
	button.overlay.Hide = function(self) end

	button.remaining = SetFontString(button, fontn, 8, "OUTLINE")
	button.remaining:SetPoint("TOPLEFT", pixelScale(1), pixelScale(-1))

	if unit == "player" then
		button:SetScript("OnMouseUp", CancelAura)
	end
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

local PostUpdateIcon = function(icons, unit, icon, index, offset)
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
		icon.overlay:SetVertexColor(0.84, 0.75, 0.65)
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

local CustomFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, expiration, caster)
	if UnitCanAttack("player", unit) then
		local casterClass
--		if debuffFilter[name] then
		if caster then
			casterClass = select(2, UnitClass(caster))
		end

		if not icon.debuff or (casterClass and casterClass == playerClass) then
			return true
		end
	else
		local isPlayer

		if(caster == "player" or caster == "vehicle") then
			isPlayer = true
		end

		if((icons.onlyShowPlayer and isPlayer) or (not icons.onlyShowPlayer and name)) then
			icon.isPlayer = isPlayer
			icon.owner = caster
			return true
		end
	end
end

local SortAura = function(a, b)
	return (a.timeLeft) > (b.timeLeft)
end

local PreSetPosition = function(auras)
	sort(auras, SortAura)
end

local PortraitPostUpdate = function(self, unit)
	if self.unit == "target" then
		if not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit) then
			self.Portrait:SetAlpha(0)
		else
			self.Portrait:SetAlpha(1)
		end
	end
end

local updateAllElements = function(frame)
	for _, v in ipairs(frame.__elements) do
		v(frame, "UpdateElement", frame.unit)
	end
end

local SetStyle = function(self, unit)

	local unitInRaid = self:GetParent():GetName():match("oUF_Raid" )
	local unitInParty = self:GetParent():GetName():match("oUF_Party")
	local unitIsPartyPet = unit and unit:match("partypet%d")
	local unitIsPartyTarget = unit and unit:match("party%dtarget")

	self.menu = Menu
	self.colors = colors
	self:RegisterForClicks("AnyUp")
	self:SetAttribute("type2", "menu")

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:HookScript("OnShow", updateAllElements)

	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0.25, 0.25, 0.25)
	

	self.FrameBackdrop = CreateFrame("Frame", nil, self)
	self.FrameBackdrop:SetPoint("TOPLEFT", self, pixelScale(-3), pixelScale(3))
	self.FrameBackdrop:SetFrameStrata("MEDIUM")
	self.FrameBackdrop:SetBackdrop(caelMedia.backdropTable)
	self.FrameBackdrop:SetBackdropColor(0, 0, 0, 0)
	self.FrameBackdrop:SetBackdropBorderColor(0, 0, 0)

	if unit == "player" and playerClass == "DEATHKNIGHT" or IsAddOnLoaded("oUF_TotemBar") and unit == "player" and playerClass == "SHAMAN" then
		self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, pixelScale(3), pixelScale(-11))
	else
		self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, pixelScale(3), pixelScale(-3))
	end

	self.Health = CreateFrame("StatusBar", self:GetName().."_Health", self)
	self.Health:SetHeight((unit == "player" or unit == "target" or unitInRaid) and pixelScale(22) or unitIsPartyPet and pixelScale(10) or pixelScale(16))
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(normtex)
	self.Health:GetStatusBarTexture():SetHorizTile(false)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true

	self.Health.frequentUpdates = true
	self.Health.Smooth = true

	self.Health.PostUpdate = PostUpdateHealth

	self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints()
	self.Health.bg:SetTexture(normtex)
--	self.Health.bg.multiplier = 0.5

	self.Health.value = SetFontString(self.Health, font,(unit == "player" or unit == "target") and 11 or 9)
	if unitInRaid then
		self.Health.value:SetPoint("BOTTOMRIGHT", pixelScale(-1), pixelScale(2))
	else
		self.Health.value:SetPoint("RIGHT", pixelScale(-1), pixelScale(1))
	end

	if not unitIsPartyPet then
		self.Power = CreateFrame("StatusBar", self:GetName().."_Power", self)
		self.Power:SetHeight((unit == "player" or unit == "target") and pixelScale(7) or pixelScale(5))
		if unitInRaid then
			self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, pixelScale(-1))
			self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, pixelScale(-1))
		else
			self.Power:SetPoint("BOTTOMLEFT")
			self.Power:SetPoint("BOTTOMRIGHT")
		end
		self.Power:SetStatusBarTexture(normtex)
		self.Power:GetStatusBarTexture():SetHorizTile(false)

		self.Power.colorPower = unit == "player" or unit == "pet" and true
		self.Power.colorClass = true
		self.Power.colorReaction = true

		self.Power.frequentUpdates = true
		self.Power.Smooth = true

		self.Power.PreUpdate = PreUpdatePower
		self.Power.PostUpdate = PostUpdatePower

		self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
		self.Power.bg:SetAllPoints()
		self.Power.bg:SetTexture(normtex)
		self.Power.bg.multiplier = 0.5

		self.Power.value = SetFontString(self.Health, font, (unit == "player" or unit == "target") and pixelScale(11) or pixelScale(9))
		self.Power.value:SetPoint("LEFT", pixelScale(1), pixelScale(1))
	end

	if unitInRaid then
		self.Nameplate = CreateFrame("Frame", nil, self.FrameBackdrop)
		self.Nameplate:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT")
		self.Nameplate:SetPoint("BOTTOMRIGHT", self)
		self.Nameplate:SetBackdrop {
			bgFile = caelMedia.files.bgFile,
			edgeFile = caelMedia.files.bgFile,
			tile = false, tileSize = 0, edgeSize = pixelScale(1),
			insets = {left = 0, right = 0, top = 1, bottom = 0}
		}
		self.Nameplate:SetBackdropColor(0.15, 0.15, 0.15)
		self.Nameplate:SetBackdropBorderColor(0, 0, 0)
	end

	if unit ~= "player" then
		self.Info = SetFontString(unitInRaid and self.Nameplate or self.Health, font, unit == "target" and 11 or 9)
		if unitInRaid then
			self.Info:SetPoint("BOTTOM", self, 0, pixelScale(3))
			self:Tag(self.Info, "[caellian:getnamecolor][caellian:nameshort]")
		elseif unit == "target" then
			self.Info:SetPoint("LEFT", pixelScale(1), pixelScale(1))
			self:Tag(self.Info, "[caellian:getnamecolor][caellian:namelong] [caellian:diffcolor][level] [shortclassification]")
		else
			self.Info:SetPoint("LEFT", pixelScale(1), pixelScale(1))
			self:Tag(self.Info, "[caellian:getnamecolor][caellian:namemedium]")
		end
	end

	if unit == "player" then
		self.Combat = self.Health:CreateTexture(nil, "OVERLAY")
		self.Combat:SetSize(pixelScale(12), pixelScale(12))
		self.Combat:SetPoint("CENTER")
		self.Combat:SetTexture(bubbleTex)
		self.Combat:SetVertexColor(0.69, 0.31, 0.31)

		self.FlashInfo = CreateFrame("Frame", "FlashInfo", self)
		self.FlashInfo:SetScript("OnUpdate", UpdateManaLevel)
		self.FlashInfo.parent = self
		self.FlashInfo:SetToplevel(true)
		self.FlashInfo:SetAllPoints(self.Health)

		self.FlashInfo.ManaLevel = SetFontString(self.FlashInfo, font, 11)
		self.FlashInfo.ManaLevel:SetPoint("CENTER", 0, pixelScale(1))

		if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
			self.Resting = self.Power:CreateTexture(nil, "OVERLAY")
			self.Resting:SetSize(pixelScale(18), pixelScale(18))
			self.Resting:SetPoint("BOTTOMLEFT", pixelScale(-8.5), pixelScale(-8.5))
			self.Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
			self.Resting:SetTexCoord(0, 0.5, 0, 0.421875)
		end

		if IsAddOnLoaded("oUF_WeaponEnchant") then
			self.Enchant = CreateFrame("Frame", nil, self)
			self.Enchant:SetHeight(pixelScale(24))
			self.Enchant:SetWidth(pixelScale(24 * 2))
			self.Enchant:SetPoint("TOPLEFT", self, "TOPRIGHT", pixelScale(9), pixelScale(1))
			self.Enchant.size = pixelScale(24)
			self.Enchant.spacing = pixelScale(1)
			self.Enchant.initialAnchor = "TOPLEFT"
			self.Enchant["growth-x"] = "RIGHT"
			self.PostCreateEnchantIcon = PostCreateAura
			self.PostUpdateEnchantIcons = CreateEnchantTimer
		end

		if playerClass == "DEATHKNIGHT" then
			self.Runes = CreateFrame("Frame", nil, self)
			self.Runes:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, pixelScale(-1))
			self.Runes:SetHeight(pixelScale(7))
			self.Runes:SetWidth(pixelScale(230))
			self.Runes:SetBackdrop(backdrop)
			self.Runes:SetBackdropColor(0.25, 0.25, 0.25)

			for i = 1, 6 do
				self.Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
				self.Runes[i]:SetHeight(pixelScale(7))
				self.Runes[i]:SetWidth(pixelScale(230 / 6) - 0.4)
				if (i == 1) then
					self.Runes[i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, pixelScale(-1))
				else
					self.Runes[i]:SetPoint("TOPLEFT", self.Runes[i-1], "TOPRIGHT", pixelScale(1), 0)
				end
				self.Runes[i]:SetStatusBarTexture(normtex)
				self.Runes[i]:GetStatusBarTexture():SetHorizTile(false)
				self.Runes[i]:SetStatusBarColor(unpack(runeloadcolors[i]))

				self.Runes[i].bd = self.Runes[i]:CreateTexture(nil, "BORDER")
				self.Runes[i].bd:SetAllPoints()
				self.Runes[i].bd:SetTexture(normtex)
				self.Runes[i].bd:SetVertexColor(0.15, 0.15, 0.15)
			end
		end

		if IsAddOnLoaded("oUF_TotemBar") and playerClass == "SHAMAN" then
			self.TotemBar = {}
			self.TotemBar.Destroy = true
			for i = 1, 4 do
				self.TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
				self.TotemBar[i]:SetHeight(pixelScale(7))
				self.TotemBar[i]:SetWidth(pixelScale(230/4 - 0.75))
				if (i == 1) then
					self.TotemBar[i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, pixelScale(-1))
				else
					self.TotemBar[i]:SetPoint("TOPLEFT", self.TotemBar[i-1], "TOPRIGHT", pixelScale(1), 0)
				end
				self.TotemBar[i]:SetStatusBarTexture(normtex)
				self.TotemBar[i]:GetStatusBarTexture():SetHorizTile(false)
				self.TotemBar[i]:SetMinMaxValues(0, 1)

				self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
				self.TotemBar[i].bg:SetAllPoints()
				self.TotemBar[i].bg:SetTexture(normtex)
				self.TotemBar[i].bg:SetVertexColor(0.15, 0.15, 0.15)
			end
		end

		if playerClass == "DRUID" then
			CreateFrame("Frame"):SetScript("OnUpdate", function() UpdateDruidMana(self) end)
			self.DruidMana = SetFontString(self.Health, font, 11)
			self.DruidMana:SetTextColor(1, 0.49, 0.04)
		end
	end

	if unit == "pet" or unit == "targettarget" then
		self.Auras = CreateFrame("Frame", nil, self)
		self.Auras:SetHeight(pixelScale(24))
		self.Auras:SetWidth(pixelScale(24 * 8))
		self.Auras.size = pixelScale(24)
		self.Auras.spacing = pixelScale(1)
		self.Auras.numBuffs = 16
		self.Auras.numDebuffs = 16
		self.Auras.gap = true
--		self.Auras.PreSetPosition = PreSetPosition
		self.Auras.PostCreateIcon = PostCreateAura
		self.Auras.PostUpdateIcon = PostUpdateIcon
		if unit == "pet" then
			self.Auras:SetPoint("TOPRIGHT", self, "TOPLEFT", pixelScale(-9), pixelScale(1))
			self.Auras.initialAnchor = "TOPRIGHT"
			self.Auras["growth-x"] = "LEFT"
		else
			self.Auras:SetPoint("TOPLEFT", self, "TOPRIGHT", pixelScale(9), pixelScale(1))
			self.Auras.initialAnchor = "TOPLEFT"
		end
	end

	if unit == "player" or unit == "target" then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetHeight(pixelScale(24))
		self.Buffs:SetWidth(pixelScale(24 * 8))
		self.Buffs.size = pixelScale(24)
		self.Buffs.spacing = pixelScale(1)
		self.Buffs.PreSetPosition = PreSetPosition
		self.Buffs.PostCreateIcon = PostCreateAura
		self.Buffs.PostUpdateIcon = PostUpdateIcon

		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetHeight(pixelScale(23 * 0.97))
		self.Debuffs:SetWidth(pixelScale(230))
		self.Debuffs.size = pixelScale(23 * 0.97)
		self.Debuffs.spacing = pixelScale(1)
		self.Debuffs.PreSetPosition = PreSetPosition
		self.Debuffs.PostCreateIcon = PostCreateAura
		self.Debuffs.PostUpdateIcon = PostUpdateIcon
		if unit == "player" then
			self.Buffs:SetPoint("TOPRIGHT", self, "TOPLEFT", pixelScale(-9), pixelScale(1))
			self.Buffs.initialAnchor = "TOPRIGHT"
			self.Buffs["growth-x"] = "LEFT"
			self.Buffs["growth-y"] = "DOWN"
			self.Buffs.filter = true

			self.Debuffs.initialAnchor = "TOPLEFT"
			self.Debuffs["growth-y"] = "DOWN"
			if playerClass == "DEATHKNIGHT" or IsAddOnLoaded("oUF_TotemBar") and playerClass == "SHAMAN" then
				self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", pixelScale(-1), pixelScale(-15))
			else
				self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", pixelScale(-1), pixelScale(-7.5))
			end

		elseif unit == "target" then
			self.Buffs:SetPoint("TOPLEFT", self, "TOPRIGHT", pixelScale(9), pixelScale(1))
			self.Buffs.initialAnchor = "TOPLEFT"
			self.Buffs["growth-y"] = "DOWN"

			self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", pixelScale(-1), pixelScale(-8))
			self.Debuffs.initialAnchor = "TOPLEFT"
			self.Debuffs["growth-y"] = "DOWN"
			self.Debuffs.onlyShowPlayer = false
			if not settings.noClassDebuffs then
				self.Debuffs.CustomFilter = CustomFilter
			end

			self.CPoints = CreateFrame("Frame", nil, self.Power)
			self.CPoints:SetAllPoints()
			self.CPoints.unit = PlayerFrame.unit
			for i = 1, 5 do
				self.CPoints[i] = self.CPoints:CreateTexture(nil, "ARTWORK")
				self.CPoints[i]:SetSize(pixelScale(12), pixelScale(12))
				self.CPoints[i]:SetTexture(bubbleTex)
				if i == 1 then
					self.CPoints[i]:SetPoint("LEFT")
					self.CPoints[i]:SetVertexColor(0.69, 0.31, 0.31)
				else
					self.CPoints[i]:SetPoint("LEFT", self.CPoints[i-1], "RIGHT", pixelScale(1))
				end
			end
			self.CPoints[2]:SetVertexColor(0.69, 0.31, 0.31)
			self.CPoints[3]:SetVertexColor(0.65, 0.63, 0.35)
			self.CPoints[4]:SetVertexColor(0.65, 0.63, 0.35)
			self.CPoints[5]:SetVertexColor(0.33, 0.59, 0.33)
			self:RegisterEvent("UNIT_COMBO_POINTS", UpdateCPoints)
		end

			self.Portrait = CreateFrame("PlayerModel", nil, self)
			self.Portrait:SetPoint("TOPLEFT", self, 0, pixelScale(-23))
			self.Portrait:SetPoint("BOTTOMRIGHT", self, 0, pixelScale(8))

			self.Portrait.PostUpdate = PortraitPostUpdate
--			insert(self.__elements, PortraitPostUpdate)
	
			self.PortraitOverlay = CreateFrame("StatusBar", self:GetName().."_PortraitOverlay", self.Portrait)
			self.PortraitOverlay:SetFrameLevel(self.PortraitOverlay:GetFrameLevel() + 1)
			self.PortraitOverlay:SetAllPoints()
			self.PortraitOverlay:SetStatusBarTexture(shaderTex)
			self.PortraitOverlay:GetStatusBarTexture():SetHorizTile(false)
			self.PortraitOverlay:SetStatusBarColor(0.1, 0.1, 0.1, 0.75)

			self.CombatFeedbackText = SetFontString(self.PortraitOverlay, font, 18, "OUTLINE")
			self.CombatFeedbackText:SetPoint("CENTER", 0, pixelScale(1))
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
			self.Status:SetPoint("CENTER", 0, pixelScale(2))
			self.Status:SetTextColor(0.69, 0.31, 0.31, 0)
			self:Tag(self.Status, "[pvp]")
	
			self:SetScript("OnEnter", function(self) self.Status:SetAlpha(0.5); UnitFrame_OnEnter(self) end)
			self:SetScript("OnLeave", function(self) self.Status:SetAlpha(0); UnitFrame_OnLeave(self) end)
		end

	self.cDebuffFilter = true

	self.cDebuffBackdrop = self.Health:CreateTexture(nil, "OVERLAY")
	self.cDebuffBackdrop:SetAllPoints(unitInRaid and self.Nameplate or self.Health)
	self.cDebuffBackdrop:SetTexture(highlightTex)
	self.cDebuffBackdrop:SetBlendMode("ADD")
	self.cDebuffBackdrop:SetVertexColor(0, 0, 0, 0)

	self.cDebuff = CreateFrame("StatusBar", nil, (unit == "player" or unit == "target") and self.PortraitOverlay or self.Health)
	self.cDebuff:SetSize(pixelScale(16), pixelScale(16))
	self.cDebuff:SetPoint("CENTER")

	self.cDebuff.Icon = self.cDebuff:CreateTexture(nil, "ARTWORK")
	self.cDebuff.Icon:SetAllPoints()

	self.cDebuff.IconOverlay = self.cDebuff:CreateTexture(nil, "OVERLAY")
	self.cDebuff.IconOverlay:SetPoint("TOPLEFT", pixelScale(-1), pixelScale(1))
	self.cDebuff.IconOverlay:SetPoint("BOTTOMRIGHT", pixelScale(1), pixelScale(-1))
	self.cDebuff.IconOverlay:SetTexture(buttonTex)
	self.cDebuff.IconOverlay:SetVertexColor(0.25, 0.25, 0.25, 0)

	if not (unitInRaid or unitIsPartyPet) then
		self.Castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", (unit == "player" or unit == "target") and self.Portrait or self.Power)
		self.Castbar:SetStatusBarTexture(normtex)
		self.Castbar:GetStatusBarTexture():SetHorizTile(false)
		self.Castbar:SetAlpha(0.75)

		self.Castbar.PostCastStart = PostCastStart
		self.Castbar.PostChannelStart = PostChannelStart

--		self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
--		self.Castbar.bg:SetAllPoints()
--		self.Castbar.bg:SetTexture(normtex)

		if unit == "player" or unit == "target" then
			self.Castbar:SetPoint("TOPLEFT", self, 0, pixelScale(-23))
			self.Castbar:SetPoint("BOTTOMRIGHT", self, 0, pixelScale(8))
		else
			self.Castbar:SetHeight(pixelScale(5))
			self.Castbar:SetAllPoints()
		end

		if unit == "player" or unit == "target" then
			self.Castbar.Time = SetFontString(self.PortraitOverlay, font, 11)
			self.Castbar.Time:SetPoint("RIGHT", pixelScale(-1), pixelScale(1))
			self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
			self.Castbar.Time:SetJustifyH("RIGHT")
			self.Castbar.CustomTimeText = CustomCastTimeText
			self.Castbar.CustomDelayText = CustomCastDelayText

			self.Castbar.Text = SetFontString(self.PortraitOverlay, font, 11)
			self.Castbar.Text:SetPoint("LEFT", pixelScale(1), pixelScale(1))
			self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", pixelScale(-1), 0)
			self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)

			self.Castbar:HookScript("OnShow", function() self.Castbar.Text:Show(); self.Castbar.Time:Show() end)
			self.Castbar:HookScript("OnHide", function() self.Castbar.Text:Hide(); self.Castbar.Time:Hide() end)

			self.Castbar.Icon = self.Castbar:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(pixelScale(23 * 1.04), pixelScale(23 * 1.04))
			self.Castbar.Icon:SetTexCoord(0, 1, 0, 1)
			if unit == "player" then
				self.Castbar.Icon:SetPoint("RIGHT", pixelScale(33), 0)
			elseif unit == "target" then
				self.Castbar.Icon:SetPoint("LEFT", pixelScale(-31.5), 0)
			end

			self.IconOverlay = self.Castbar:CreateTexture(nil, "OVERLAY")
			self.IconOverlay:SetPoint("TOPLEFT", self.Castbar.Icon, pixelScale(-1.5), pixelScale(1.5))
			self.IconOverlay:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, pixelScale(1.5), pixelScale(-1.5))
			self.IconOverlay:SetTexture(buttonTex)
			self.IconOverlay:SetVertexColor(0.84, 0.75, 0.65)

			self.IconBackdrop = CreateFrame("Frame", nil, self.Castbar)
			self.IconBackdrop:SetPoint("TOPLEFT", self.Castbar.Icon, pixelScale(-3), pixelScale(3))
			self.IconBackdrop:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, pixelScale(3), pixelScale(-3))
			self.IconBackdrop:SetBackdrop(caelMedia.borderTable)
			self.IconBackdrop:SetBackdropColor(0, 0, 0, 0)
			self.IconBackdrop:SetBackdropBorderColor(0, 0, 0, 0.7)
		end

		if unit == "player" then
			self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "ARTWORK")
			self.Castbar.SafeZone:SetTexture(normtex)
			self.Castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)

			self.Castbar.Latency = self.Castbar:CreateFontString(nil, "OVERLAY")
			self.Castbar.Latency:SetFont(fontn, 8, "OUTLINE")
			self.Castbar.Latency:SetTextColor(0.84, 0.75, 0.65)
			self.Castbar.Latency:SetPoint("TOP", self.Castbar.Icon, "BOTTOM")
			
			self:RegisterEvent("UNIT_SPELLCAST_SENT", function(self, event, caster)
				if caster == "player" or caster == "vehicle" then
					self.Castbar.castSent = GetTime()
				end
			end)
		end
	end

	if unitInParty and not unitIsPartyPet and not unitIsPartyTarget or unitInRaid or unit == "player" then
		self.Leader = self.Health:CreateTexture(nil, "ARTWORK")
		self.Leader:SetSize(pixelScale(14), pixelScale(14))
		self.Leader:SetPoint("TOPLEFT", 0, pixelScale(10))

		self.Assistant = self:CreateTexture(nil, "ARTWORK")
		self.Assistant:SetParent(unitInRaid and self.Nameplate or self.Health)
		self.Assistant:SetSize(pixelScale(14), pixelScale(14))
		self.Assistant:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, pixelScale(-4))

		self.MasterLooter = self:CreateTexture(nil, "ARTWORK")
		self.MasterLooter:SetParent(unitInRaid and self.Nameplate or self.Health)
		self.MasterLooter:SetHeight(pixelScale(12), pixelScale(12))
		self.MasterLooter:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, pixelScale(-4))
		if not unit == "player" then
			self.ReadyCheck = self:CreateTexture(nil, "ARTWORK")
			self.ReadyCheck:SetParent(unitInRaid and self.Nameplate or self.Health)
			self.ReadyCheck:SetSize(pixelScale(12), pixelScale(12))
			if unitInRaid then
				self.ReadyCheck:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", pixelScale(-5), pixelScale(2))
			else
				self.ReadyCheck:SetPoint("TOPRIGHT", pixelScale(7), pixelScale(7))
			end
		end

		if unitInParty and not unitIsPartyPet and not unitIsPartyTarget then
			self.LFDRole = self.Health:CreateTexture(nil, "ARTWORK")
			self.LFDRole:SetSize(pixelScale(14), pixelScale(14))
			self.LFDRole:SetPoint("RIGHT", self, "LEFT", pixelScale(-1), 0)
		end
	end

	if playerClass == "HUNTER" then
		self:SetAttribute("type3", "spell")
		self:SetAttribute("spell3", "Misdirection")
	elseif playerClass == "DRUID" then
		self:SetAttribute("type3", "spell")
		self:SetAttribute("spell3", "Innervate")
	elseif playerClass == "PALADIN" then
		self:SetAttribute("type3", "spell")
		self:SetAttribute("spell3", "Righteous Defense")
	end

	if unit == "player" or unit == "target" then
		self:SetAttribute("initial-height", pixelScale(53))
		self:SetAttribute("initial-width", pixelScale(230))
	elseif unitIsPartyPet then
		self:SetAttribute("initial-height", pixelScale(10))
		self:SetAttribute("initial-width", pixelScale(113))
	elseif unitInRaid then
		self:SetAttribute("initial-height", pixelScale(43))
		self:SetAttribute("initial-width", pixelScale(64))
	else
		self:SetAttribute("initial-height", pixelScale(22))
		self:SetAttribute("initial-width", pixelScale(113))
	end

	self.RaidIcon = self:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetParent(unitInRaid and self.Nameplate or self.Health)
	self.RaidIcon:SetTexture(raidIcons)
	self.RaidIcon:SetSize(unitInRaid and pixelScale(14) or pixelScale(18), unitInRaid and pixelScale(14) or pixelScale(18))
	if unitInRaid then
		self.RaidIcon:SetPoint("CENTER", 0, pixelScale(10))
	else
		self.RaidIcon:SetPoint("TOP", 0, pixelScale(10))
	end

	if IsAddOnLoaded("oUF_SpellRange") then
		self.outsideRangeAlpha = 0.5
		self.inRangeAlpha = 1
		self.SpellRange = true
	else
		self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,}
	end

	local AggroSelect = function()
		if (UnitExists("target")) then
			PlaySound("igCreatureAggroSelect")
		end
	end
	self:RegisterEvent("PLAYER_TARGET_CHANGED", AggroSelect)

	self:SetScale(settings.scale)
	if self.Auras then self.Auras:SetScale(settings.scale) end
	if self.Buffs then self.Buffs:SetScale(settings.scale) end
	if self.Debuffs then self.Debuffs:SetScale(settings.scale) end

	HideAura(self)
	return self
end

--[[
List of the various configuration attributes
======================================================
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if "groupFilter" is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
strictFiltering = [BOOLEAN] - if true, then characters must match both a group and a class from the groupFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
groupBy = [nil, "GROUP", "CLASS", "ROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinate (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the ammount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)
--]]

oUF:RegisterStyle("Caellian", SetStyle)

oUF:Factory(function(self)
	local cfg = settings.coords

	self:Spawn("player", "oUF_Caellian_player"):SetPoint("BOTTOM", UIParent, pixelScale(cfg.playerX), pixelScale(cfg.playerY))
	self:Spawn("target", "oUF_Caellian_target"):SetPoint("BOTTOM", UIParent, pixelScale(cfg.targetX), pixelScale(cfg.targetY))

	self:Spawn("pet", "oUF_Caellian_pet"):SetPoint("BOTTOMLEFT", oUF_Caellian_player, "TOPLEFT", 0, pixelScale(10))
	self:Spawn("focus", "oUF_Caellian_focus"):SetPoint("BOTTOMRIGHT", oUF_Caellian_player, "TOPRIGHT", 0, pixelScale(10))
	self:Spawn("focustarget", "oUF_Caellian_focustarget"):SetPoint("BOTTOMLEFT", oUF_Caellian_target, "TOPLEFT", 0, pixelScale(10))
	self:Spawn("targettarget", "oUF_Caellian_targettarget"):SetPoint("BOTTOMRIGHT", oUF_Caellian_target, "TOPRIGHT", 0, pixelScale(10))

	local party = {}
	for i = 1, 5 do
		party[i] = self:Spawn("party"..i, "oUF_Party"..i)
		if i == 1 then
			party[i]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", pixelScale(15), pixelScale(-15))
		else
			party[i]:SetPoint("TOP", party[i-1], "BOTTOM", 0, pixelScale(-26.5))
		end
	end

	local partytarget = {}
	for i = 1, 5 do
		partytarget[i] = self:Spawn("party"..i.."target", "oUF_Party"..i.."Target")
		if i == 1 then
			partytarget[i]:SetPoint("TOPLEFT", party[1], "TOPRIGHT", pixelScale(7.5), 0)
		else
			partytarget[i]:SetPoint("TOP", partytarget[i-1], "BOTTOM", 0, pixelScale(-26.5))
		end
	end
	
	local partypet = {}
	for i = 1, 5 do
		partypet[i] = self:Spawn("partypet"..i, "oUF_PartyPet"..i)
		if i == 1 then
			partypet[i]:SetPoint("TOP", party[i], "BOTTOM", 0, pixelScale(-5))
		else
			partypet[i]:SetPoint("TOP", party[i-1], "BOTTOM", 0, pixelScale(-54))
		end
	end

	local raid = {}
	for i = 1, NUM_RAID_GROUPS do
		local raidgroup = self:SpawnHeader("oUF_Raid"..i, nil, visible,
		"groupFilter", tostring(i), "showRaid", true, "yOffSet", pixelScale(-3.5)
	)
		insert(raid, raidgroup)
		if i == 1 then
			raidgroup:SetPoint("TOPLEFT", UIParent, pixelScale(cfg.raidX), pixelScale(cfg.raidY))
		else
			raidgroup:SetPoint("TOPLEFT", raid[i-1], "TOPRIGHT", pixelScale(60 * settings.scale - 60) + pixelScale(3.5), 0)
		end
	end

	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		boss[i] = self:Spawn("boss"..i, "oUF_Boss"..i)

		if i == 1 then
			boss[i]:SetPoint("TOP", UIParent, 0, pixelScale(-15))
		else
			boss[i]:SetPoint("TOP", boss[i-1], "BOTTOM", 0, pixelScale(-26.5))
		end
	end

	for i, v in ipairs(boss) do v:Show() end

	local arena = {}
	for i = 1, 5 do
		arena[i] = self:Spawn("arena"..i, "oUF_Arena"..i)

		if i == 1 then
			arena[i]:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", pixelScale(-15), pixelScale(-15))
		else
			arena[i]:SetPoint("TOP", arena[i-1], "BOTTOM", 0, pixelScale(-26.5))
		end
	end

	for i, v in ipairs(arena) do v:Show() end

	local arenatarget = {}
	for i = 1, 5 do
		arenatarget[i] = self:Spawn("arena"..i.."target", "oUF_Arena"..i.."target")
		if i == 1 then
			arenatarget[i]:SetPoint("TOPRIGHT", arena[i], "TOPLEFT", pixelScale(-7.5), 0)
		else
			arenatarget[i]:SetPoint("TOP", arenatarget[i-1], "BOTTOM", 0, pixelScale(-26.5))
		end
	end

	for i, v in ipairs(arenatarget) do v:Show() end

	Main:RegisterEvent("PLAYER_LOGIN")
	Main:RegisterEvent("RAID_ROSTER_UPDATE")
	Main:RegisterEvent("PARTY_LEADER_CHANGED")
	Main:RegisterEvent("PARTY_MEMBERS_CHANGED")
	Main:SetScript("OnEvent", function(self)
		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			local numraid = GetNumRaidMembers()
			if numraid > 0 and (numraid > 5 or numraid ~= GetNumPartyMembers() + 1) then
				for i, v in ipairs(party) do v:Disable() end
				for i, v in ipairs(partypet) do v:Disable() end
				for i, v in ipairs(partytarget) do v:Disable() end
	
				if not settings.noRaid then
					for i, v in ipairs(raid) do v:Show() end
				end
			else
				for i, v in ipairs(party) do v:Enable() end
				for i, v in ipairs(partypet) do v:Enable() end
				for i, v in ipairs(partytarget) do v:Enable() end

				if not settings.noRaid then
					for i, v in ipairs(raid) do v:Hide() end
				end
			end
		end
	end)
end)