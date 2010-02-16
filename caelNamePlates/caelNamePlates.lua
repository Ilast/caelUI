local caelNamePlates = CreateFrame("Frame", nil, UIParent)
caelNamePlates:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

local barTexture = [=[Interface\Addons\caelNamePlates\media\normtexa]=]
local overlayTexture = [=[Interface\Tooltips\Nameplate-Border]=]
local glowTexture = [=[Interface\Addons\caelNamePlates\media\glowtex]=]
local font, fontSize, fontOutline = [=[Interface\Addons\caelNamePlates\media\neuropol x cd rg.ttf]=], 9, "OUTLINE"
local backdrop = {
	edgeFile = glowTexture, edgeSize = 3,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
}

local select = select

local SetUpAnimGroup = function(self)
	self.anim = self:CreateAnimationGroup("Flash")
	self.anim:SetLooping("REPEAT")
	self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
	self.anim.fadein:SetChange(0.75)
	self.anim.fadein:SetOrder(2)

	self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
	self.anim.fadeout:SetChange(-0.75)
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

-- Execute/Kill Shot/Hammer of Wrath/Drain Soul
local nukeRangeFactor
local _, playerClass = UnitClass("player")

if playerClass == "WARLOCK" then
	nukeRangeFactor = 4
elseif playerClass == "HUNTER" or playerClass == "WARRIOR" or playerClass == "PALADIN" then
	nukeRangeFactor = 5
end

local IsValidFrame = function(frame)
	if frame:GetName() then
		return
	end

	overlayRegion = select(2, frame:GetRegions())

	return overlayRegion and overlayRegion:GetObjectType() == "Texture" and overlayRegion:GetTexture() == overlayTexture
end

local UpdateTime = function(self, curValue)
	local minValue, maxValue = self:GetMinMaxValues()
	if self.channeling then
		self.time:SetFormattedText("%.1f ", curValue)
	else
		self.time:SetFormattedText("%.1f ", maxValue - curValue)
	end
end

local ThreatUpdate = function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed >= 0.2 then
		if not self.oldglow:IsShown() then
			self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
		else
			local r, g, b = self.oldglow:GetVertexColor()
			if g + b == 0 then
				self.healthBar.hpGlow:SetBackdropBorderColor(1, 0, 0)
			else
				self.healthBar.hpGlow:SetBackdropBorderColor(1, 1, 0)
			end
--			self.healthBar.hpGlow:SetBackdropBorderColor(self.oldglow:GetVertexColor())
		end

		self.healthBar:SetStatusBarColor(self.r, self.g, self.b)

		self.elapsed = 0
	end
end

local UnitType
local UpdateFrame = function(self)
	self.healthBar.UnitType = nil
	local r, g, b = self.healthBar:GetStatusBarColor()
	local newr, newg, newb
	if g + b == 0 then
		-- Hostile unit
		newr, newg, newb = 0.69, 0.31, 0.31
		self.healthBar:SetStatusBarColor(0.69, 0.31, 0.31)
--		if self.boss:IsShown() or self.elite:IsShown() then
			self.healthBar.UnitType = "Hostile"
--		end
	elseif r + b == 0 then
		-- Friendly unit
		newr, newg, newb = 0.33, 0.59, 0.33
		self.healthBar:SetStatusBarColor(0.33, 0.59, 0.33)
	elseif r + g == 0 then
		-- Friendly player
		newr, newg, newb = 0.31, 0.45, 0.63
		self.healthBar:SetStatusBarColor(0.31, 0.45, 0.63)
	elseif 2 - (r + g) < 0.05 and b == 0 then
		-- Neutral unit
		newr, newg, newb = 0.65, 0.63, 0.35
		self.healthBar:SetStatusBarColor(0.65, 0.63, 0.35)
	else
		-- Hostile player - class colored.
		newr, newg, newb = r, g, b
	end

	self.r, self.g, self.b = newr, newg, newb

	self.healthBar:ClearAllPoints()
	self.healthBar:SetPoint("CENTER", self.healthBar:GetParent())
	self.healthBar:SetHeight(6.5)
	self.healthBar:SetWidth(100)

	self.castBar:ClearAllPoints()
	self.castBar:SetPoint("TOP", self.healthBar, "BOTTOM", 0, -4)
	self.castBar:SetHeight(5)
	self.castBar:SetWidth(100)

	self.highlight:ClearAllPoints()
	self.highlight:SetAllPoints(self.healthBar)

	self.name:SetText(self.oldname:GetText())

	local level, elite, mylevel = tonumber(self.level:GetText()), self.elite:IsShown(), UnitLevel("player")
	self.level:ClearAllPoints()
	self.level:SetPoint("RIGHT", self.healthBar, "LEFT", -2, 1)
	if self.boss:IsShown() then
		self.level:SetText("B")
		self.level:SetTextColor(0.8, 0.05, 0)
		self.level:Show()
	elseif not elite and level == mylevel then
		self.level:Hide()
	else
		self.level:SetText(level..(elite and "+" or ""))
	end
end

local OnHealthChanged = function(self)
	local r, g, b = self:GetStatusBarColor()
	local _, max = self:GetMinMaxValues()
	local cur = self:GetValue()
	if self.UnitType == "Hostile" and cur > 0 and cur < max/nukeRangeFactor and self:GetParent():GetAlpha() == 1 and not self.Trigger then
		self.Trigger = true
		Flash(self, 0.3)

		if RecScrollAreas then
			RecScrollAreas:AddText("|cffAF5050Kill Shot|r", true, "Notification", true)
		end
	elseif self.UnitType == "Hostile" and cur >= max/nukeRangeFactor and self.Trigger then
		self.Trigger = false
		StopFlash(self)
	end
end

local FixCastbar = function(self)
	self.castbarOverlay:Hide()

	self:SetHeight(5)
	self:ClearAllPoints()
	self:SetPoint("TOP", self.healthBar, "BOTTOM", 0, -4)
end

local ColorCastBar = function(self, shielded)
	if shielded then
		self:SetStatusBarColor(0.8, 0.05, 0)
		self.cbGlow:SetBackdropBorderColor(0.75, 0.75, 0.75)
	else
		self.cbGlow:SetBackdropBorderColor(0, 0, 0)
	end
end

local OnSizeChanged = function(self)
	self.needFix = true
end

local OnValueChanged = function(self, curValue)
	UpdateTime(self, curValue)
	if self.needFix then
		FixCastbar(self)
		self.needFix = nil
	end
end

local OnShow = function(self)
	self.channeling  = UnitChannelInfo("target") 
	FixCastbar(self)
	ColorCastBar(self, self.shieldedRegion:IsShown())
end

local OnHide = function(self)
	self.highlight:Hide()
	self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
end

local OnEvent = function(self, event, unit)
	if unit == "target" then
		if self:IsShown() then
			ColorCastBar(self, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
		end
	end
end

local CreateFrame = function(frame)
	if frame.done then
		return
	end

	frame.nameplate = true

	frame.healthBar, frame.castBar = frame:GetChildren()
	local healthBar, castBar = frame.healthBar, frame.castBar
	local glowRegion, overlayRegion, castbarOverlay, shieldedRegion, spellIconRegion, highlightRegion, nameTextRegion, levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion = frame:GetRegions()

	frame.oldname = nameTextRegion
	nameTextRegion:Hide()

	local newNameRegion = frame:CreateFontString()
	newNameRegion:SetPoint("BOTTOM", healthBar, "TOP", 0, 1)
	newNameRegion:SetFont(font, fontSize, fontOutline)
	newNameRegion:SetTextColor(0.84, 0.75, 0.65)
	newNameRegion:SetShadowOffset(1.25, -1.25)
	frame.name = newNameRegion

	frame.level = levelTextRegion
	levelTextRegion:SetFont(font, fontSize, fontOutline)
	levelTextRegion:SetShadowOffset(1.25, -1.25)

	healthBar:SetStatusBarTexture(barTexture)
	if nukeRangeFactor then
		healthBar:HookScript("OnValueChanged", OnHealthChanged)
	end

	local hpOffset = UIParent:GetScale() / healthBar:GetEffectiveScale()
	healthBar.hpBackground = healthBar:CreateTexture(nil, "BACKGROUND")
	healthBar.hpBackground:SetPoint("TOPLEFT", -hpOffset, hpOffset)
	healthBar.hpBackground:SetPoint("BOTTOMRIGHT", hpOffset, -hpOffset)
	healthBar.hpBackground:SetTexture(barTexture)
	healthBar.hpBackground:SetVertexColor(0.15, 0.15, 0.15)

	healthBar.hpGlow = CreateFrame("Frame", nil, healthBar)
	healthBar.hpGlow:SetFrameLevel(healthBar:GetFrameLevel() -1)
	healthBar.hpGlow:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -3, 3)
	healthBar.hpGlow:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 3, -3)
	healthBar.hpGlow:SetBackdrop(backdrop)
	healthBar.hpGlow:SetBackdropColor(0.25, 0.25, 0.25)
	healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)

	castBar.castbarOverlay = castbarOverlay
	castBar.healthBar = healthBar
	castBar.shieldedRegion = shieldedRegion
	castBar:SetStatusBarTexture(barTexture)

	castBar:HookScript("OnShow", OnShow)
	castBar:HookScript("OnSizeChanged", OnSizeChanged)
	castBar:HookScript("OnValueChanged", OnValueChanged)
	castBar:HookScript("OnEvent", OnEvent)
	castBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	castBar:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

	castBar.time = castBar:CreateFontString(nil, "ARTWORK")
	castBar.time:SetPoint("RIGHT", castBar, "LEFT", -2, 1)
	castBar.time:SetFont(font, fontSize, fontOutline)
	castBar.time:SetTextColor(0.84, 0.75, 0.65)
	castBar.time:SetShadowOffset(1.25, -1.25)

	local cbOffset = UIParent:GetScale() / castBar:GetEffectiveScale()
	castBar.cbBackground = castBar:CreateTexture(nil, "BACKGROUND")
	castBar.cbBackground:SetPoint("TOPLEFT", -cbOffset, cbOffset)
	castBar.cbBackground:SetPoint("BOTTOMRIGHT", cbOffset, -cbOffset)
	castBar.cbBackground:SetTexture(barTexture)
	castBar.cbBackground:SetVertexColor(0.15, 0.15, 0.15)

	castBar.cbGlow = CreateFrame("Frame", nil, castBar)
	castBar.cbGlow:SetFrameLevel(castBar:GetFrameLevel() -1)
	castBar.cbGlow:SetPoint("TOPLEFT", castBar, "TOPLEFT", -3, 3)
	castBar.cbGlow:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", 3, -3)
	castBar.cbGlow:SetBackdrop(backdrop)
	castBar.cbGlow:SetBackdropColor(0.25, 0.25, 0.25)
	castBar.cbGlow:SetBackdropBorderColor(0, 0, 0)

	spellIconRegion:SetHeight(0.01)
	spellIconRegion:SetWidth(0.01)
	
	highlightRegion:SetTexture(barTexture)
	highlightRegion:SetVertexColor(0.25, 0.25, 0.25)
	frame.highlight = highlightRegion

	raidIconRegion:ClearAllPoints()
	raidIconRegion:SetPoint("LEFT", healthBar, "RIGHT", 2, 0)
	raidIconRegion:SetHeight(15)
	raidIconRegion:SetWidth(15)

	frame.oldglow = glowRegion
	frame.elite = stateIconRegion
	frame.boss = bossIconRegion

	frame.done = true

	glowRegion:SetTexture(nil)
	overlayRegion:SetTexture(nil)
	shieldedRegion:SetTexture(nil)
	castbarOverlay:SetTexture(nil)
	stateIconRegion:SetTexture(nil)
	bossIconRegion:SetTexture(nil)

	UpdateFrame(frame)
	frame:SetScript("OnShow", UpdateFrame)
	frame:SetScript("OnHide", OnHide)

	frame.elapsed = 0
	frame:SetScript("OnUpdate", ThreatUpdate)
end

local numKids = 0
local lastUpdate = 0
local OnUpdate = function(self, elapsed)
	lastUpdate = lastUpdate + elapsed

	if lastUpdate > 0.1 then
		lastUpdate = 0

		local newNumKids = WorldFrame:GetNumChildren()
		if newNumKids ~= numKids then
			for i = numKids+1, newNumKids do
				frame = select(i, WorldFrame:GetChildren())

				if IsValidFrame(frame) then
					CreateFrame(frame)
				end
			end
			numKids = newNumKids
		end
	end
end

caelNamePlates:SetScript("OnUpdate", OnUpdate)

caelNamePlates:RegisterEvent("PLAYER_REGEN_ENABLED")
function caelNamePlates:PLAYER_REGEN_ENABLED()
	SetCVar("nameplateShowEnemies", 0)
end

caelNamePlates:RegisterEvent("PLAYER_REGEN_DISABLED")
function caelNamePlates.PLAYER_REGEN_DISABLED()
	SetCVar("nameplateShowEnemies", 1)
end