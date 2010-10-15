local bBuffs = true -- false to enable Blizzard buffs
local pBuffs = true -- false to disable player buffs
local pDebuffs = true -- false to disable player debuffs

local rothTex = 'Interface\\Addons\\oUF_Caellian\\media\\rothTex'
local rothTexV = 'Interface\\Addons\\oUF_Caellian\\media\\rothTexV'
local bubbleTex = 'Interface\\Addons\\oUF_Caellian\\media\\bubbleTex'
local highlightTex = 'Interface\\Addons\\oUF_Caellian\\media\\highlightTex'
local highlightTexV = 'Interface\\Addons\\oUF_Caellian\\media\\highlightTexV'
local highlightBorder = 'Interface\\Addons\\oUF_Caellian\\media\\highlightBorder'

local font = 'Interface\\AddOns\\oUF_Caellian\\media\\neuropol x cd bd.ttf'

local _, class = UnitClass('player')

if(bBuffs == true) then	
	BuffFrame:Hide()
	TemporaryEnchantFrame:Hide()
end

oUF.colors.power['MANA'] = {.31,.45,.63}
oUF.colors.power['RAGE'] = {.69,.31,.31}
oUF.colors.power['FOCUS'] = {.71,.43,.27}
oUF.colors.power['ENERGY'] = {.65,.63,.35}

--[[
oUF.colors.power['HAPPINESS'] = {}
oUF.colors.power['RUNES'] = {}
oUF.colors.power['RUNIC_POWER'] = {}
oUF.colors.power['AMMOSLOT'] = {}
oUF.colors.power['FUEL'] = {}
--]]

oUF.colors.tapped = {.55,.57,.61}
oUF.colors.disconnected = {.84,.75,.65}

oUF.colors.smooth = {.69,.31,.31, .65,.63,.35, .15,.15,.15}

oUF.colors.happiness = {
	[1] = {.69,.31,.31},
	[2] = {.65,.63,.35},
	[3] = {.33,.59,.33},
}

local classification = {
	worldboss = '%s |cffD7BEA5Boss|r',
	rareelite = '%s |cff%02x%02x%02x%s|r|cffD7BEA5+ R|r',
	elite = '%s |cff%02x%02x%02x%s|r|cffD7BEA5+|r',
	rare = '%s |cff%02x%02x%02x%s|r |cffD7BEA5R|r',
	normal = '%s |cff%02x%02x%02x%s|r',
	trivial = '%s |cff%02x%02x%02x%s|r',
}

local function Menu(self)
	local cunit = self.unit:gsub('(.)', string.upper, 1)
	if(_G[cunit..'FrameDropDown']) then
		ToggleDropDownMenu(1, nil, _G[cunit..'FrameDropDown'], 'cursor')
	elseif(self.unit:match('party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, 'cursor')
	end
end

local function SetFontString(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, 'OVERLAY')
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH('LEFT')
	fs:SetShadowColor(0,0,0)
	fs:SetShadowOffset(1.25, -1.25)
	return fs
end

local function UpdateColor(self, unit, func)
	local colorA, colorB
	local _, class = UnitClass(unit)

	if(UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		colorA = oUF.colors.tapped
	elseif(UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit)) then
		colorA = oUF.colors.disconnected
	elseif(unit =='pet' and GetPetHappiness()) then
		colorA = oUF.colors.happiness[GetPetHappiness()]
	elseif(UnitIsPlayer(unit)) then
		colorA = oUF.colors.class[class]
	else
		colorB = FACTION_BAR_COLORS[UnitReaction(unit, 'player')]
	end

	if(colorA) then
		self:SetTextColor(colorA[1], colorA[2], colorA[3])
	elseif(colorB) then
		self:SetTextColor(colorB.r, colorB.g, colorB.b)
	end
end

local function GetDifficultyColor(level)
	if level == '??' then
		return  .69,.31,.31
	else
	local levelDiff = UnitLevel('target') - UnitLevel('player')
		if levelDiff >= 5 then
			return .69,.31,.31
		elseif levelDiff >= 3 then
			return .71,.43,.27
		elseif levelDiff >= -2 then
			return .84,.75,.65
		elseif -levelDiff <= GetQuestGreenRange() then
			return .33,.59,.33
		else
			return  .55,.57,.61
		end
	end
end

local function ShortValue(value)
	if value >= 1e7 then
		return ('%.1fm'):format(value / 1e6):gsub('%.?0+([km])$', '%1')
	elseif value >= 1e6 then
		return ('%.2fm'):format(value / 1e6):gsub('%.?0+([km])$', '%1')
	elseif value >= 1e5 then
		return ('%.0fk'):format(value / 1e3)
	elseif value >= 1e3 then
		return ('%.1fk'):format(value / 1e3):gsub('%.?0+([km])$', '%1')
	else
		return value
	end
end

local function OverrideUpdateName(self, event, unit)
	if(self.unit ~= unit or not self.Name) then return end

	local uName = UnitName(unit)
	if(unit == 'player') then
		self.Name:Hide()
	elseif(unit == 'target') then
		local level = not UnitIsConnected(unit) and '??' or UnitLevel(unit) < 1 and '??' or UnitLevel(unit)
		local r, g, b = GetDifficultyColor(level)
		if(uName:utf8len() > 18) then
			self.Name:SetFormattedText(classification[UnitClassification(unit)], uName:utf8sub(1, 18)..'...', r*255,g*255,b*255, level)
		else
			self.Name:SetFormattedText(classification[UnitClassification(unit)], uName, r*255,g*255,b*255, level)
		end
	elseif (unit == 'pet' and uName == 'Unknown') then
		self.Name:SetText('Pet')
	elseif(self:GetParent():GetName():match'oUF_Raid') then
		self.Name:SetFormattedText(uName:utf8sub(1, 5))
	else
		if(uName:utf8len() > 10) then
			self.Name:SetFormattedText(uName:utf8sub(1, 10)..'...')
		else
			self.Name:SetText(uName)
		end
	end
	UpdateColor(self.Name, unit, 'SetTextColor')
end

local function PostUpdateHealth(self, event, unit, bar, min, max)
	if(max ~= 0) then
		r, g, b = self.ColorGradient(min/max, .69,.31,.31, .65,.63,.35, .33,.59,.33)
	end

	if(not UnitIsConnected(unit)) then
		bar:SetValue(0)
		bar.value:SetText('|cffD7BEA5'..'Offline')
	elseif(UnitIsDead(unit)) then
		bar.value:SetText('|cffD7BEA5'..'Dead')
	elseif(UnitIsGhost(unit)) then
		bar.value:SetText('|cffD7BEA5'..'Ghost')
	else
		if(min~=max) then
			if(unit == 'player') then
				bar.value:SetFormattedText('|cffAF5050%d|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r', min, r*255, g*255, b*255, (min/max)*100)
			elseif(not unit or (unit and unit ~= 'player' and unit ~= 'target')) then
				bar.value:SetFormattedText('|cff%02x%02x%02x%d%%|r', r*255, g*255, b*255, (min/max)*100)
			else
				bar.value:SetFormattedText('|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r', ShortValue(min), r*255, g*255, b*255, (min/max)*100)
			end
		else
			if(unit ~= 'player' and unit ~= 'pet') then
				bar.value:SetText('|cff559655'..ShortValue(max))
			else
				bar.value:SetText('|cff559655'..max)
			end
		end
	end
	self:UNIT_NAME_UPDATE(event, unit)
end

local function PostUpdatePower(self, event, unit, bar, min, max)
	if(unit ~= 'player' and unit ~= 'target') then
		bar.value:Hide()
	else
		if(min==0) then
			bar.value:SetText()
		elseif(not UnitIsPlayer(unit) or not UnitIsConnected(unit)) then
			bar.value:SetText()
		elseif(UnitIsDead(unit) or UnitIsGhost(unit)) then
			bar.value:SetText()
		elseif((min==100) and (max==100) or (min==110) and (max==110)) then
			if(UnitPowerType(unit)==3) then
				bar.value:SetText()
			end
		else
			if(min ~= max) then
				if(UnitPowerType(unit)==0) then
					if(unit ~= 'player') then
						bar.value:SetFormattedText('%d%% |cffD7BEA5-|r %s', (min/max)*100, ShortValue(max-(max-min)))
					else
						bar.value:SetFormattedText('%d%% |cffD7BEA5-|r %s', (min/max)*100, max-(max-min))
					end
				else
					bar.value:SetText(max-(max-min))
				end
			else
				if(unit ~= 'player') then
					bar.value:SetText(ShortValue(min))
				else
					bar.value:SetText(min)
				end
			end
			local _, pType = UnitPowerType(unit)
			local color = self.colors.power[pType]
			if(color) then bar.value:SetTextColor(color[1], color[2], color[3]) end
		end
	end

	if(unit == 'target') then
		self.Name:ClearAllPoints()
		if(self.Power.value:GetText()) then
			self.Name:SetPoint('CENTER', 0, 1)
		else
			self.Name:SetPoint('LEFT', 1, 1)
		end
	end
	self:UNIT_NAME_UPDATE(event, unit)
end

local function UpdateDruidMana(self)
	local manaMin, manaMax, pType
	pType = UnitPowerType('player')
	if(pType ~= 0) then
		manaMin = UnitPower('player', 0)
		manaMax = UnitPowerMax('player', 0)

		if(manaMin ~= manaMax) then
			self:SetFormattedText('%d%%', (manaMin/manaMax)*100)
		else
			self:SetText()
		end

		self:SetAlpha(1)
	else
		self:SetAlpha(0)
	end
end

local function PostCreateAuraIcon(self, button, icons, index, debuff)
	icons.showDebuffType = true
	button.cd:SetReverse()
	button.icon:SetTexCoord(.07, .93, .07, .93)
	if (not debuff) then
		button:SetScript('OnMouseUp', function(self, mouseButton)
			if mouseButton == 'RightButton' then
				CancelUnitBuff('player', index)
			end
		end)
	end

	self.ButtonOverlay = button:CreateTexture(nil, 'OVERLAY')
	self.ButtonOverlay:SetPoint('TOPLEFT', -2.5, 2.5)
	self.ButtonOverlay:SetPoint('BOTTOMRIGHT', 2.5, -2.5)
	self.ButtonOverlay:SetTexture('Interface\\AddOns\\oUF_Caellian\\media\\entropy\\border')
	self.ButtonOverlay:SetVertexColor(.15,.15,.15)
	self.ButtonOverlay:SetBlendMode('BLEND')

	self.ButtonGloss = button:CreateTexture(nil, 'OVERLAY')
	self.ButtonGloss:SetPoint('TOPLEFT', -3, 3)
	self.ButtonGloss:SetPoint('BOTTOMRIGHT', 3, -3)
	self.ButtonGloss:SetTexture('Interface\\AddOns\\oUF_Caellian\\media\\entropy\\gloss')
	self.ButtonGloss:SetVertexColor(.84,.75,.65)
	self.ButtonGloss:SetBlendMode('ADD')
end

local function SetStyle(self, unit)
	self.menu = Menu
	self:RegisterForClicks('AnyUp')
	self:SetAttribute('*type2', 'menu')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self:SetBackdrop({bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', insets = {top = -1, left = -1, bottom = -1, right = -1}})
	self:SetBackdropColor(.15,.15,.15)

	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetFrameLevel(unit and 1 or 2) -- puts the hp frame lower than the highlight frame
	self.Health:SetHeight((unit == 'player' or unit == 'target') and 22 or 17.5) -- This line is only needed for HealComm to work
	self.Health:SetPoint('TOPLEFT')
	self.Health:SetPoint('BOTTOMRIGHT', 0, (unit == 'player' or unit == 'target') and 31 or 6)
	self.Health:SetStatusBarTexture(rothTex)
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = true
	self.Health.Smooth = true
	self.Health.frequentUpdates = true
	if(self:GetParent():GetName():match'oUF_Raid') then
		self.Health:SetPoint('TOPLEFT')
		self.Health:SetPoint('BOTTOMRIGHT', -6, 0)
		self.Health:SetOrientation('VERTICAL')
	end

	self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(rothTex)
	self.Health.bg.multiplier = .33

	self.Highlight = self:CreateTexture(nil, 'HIGHLIGHT')
	self.Highlight:SetAllPoints(self.Health)
	self.Highlight:SetBlendMode('ADD')
	self.Highlight:SetTexture(highlightTex)
	if(self:GetParent():GetName():match'oUF_Raid') then
		self.Highlight:SetTexture(highlightTexV)
	end

	self.Power = CreateFrame('StatusBar', nil, self)
	self.Power:SetHeight((unit == 'player' or unit == 'target') and 7 or 5) -- This line is only needed for HealComm to work
	self.Power:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', 0, (unit == 'player' or unit == 'target') and -24 or -1)
	self.Power:SetPoint('BOTTOMRIGHT')
	self.Power:SetStatusBarTexture(rothTex)
	self.Power.colorTapping = true
	self.Power.colorClass = true
	self.Power.colorClassNPC = true
	self.Power.colorReaction = true
	self.Power.Smooth = true
	self.Power.frequentUpdates = true
	if(self:GetParent():GetName():match'oUF_Raid') then
		self.Power:SetPoint('TOPLEFT', self.Health, 'TOPRIGHT', 1, 0)
		self.Power:SetPoint('BOTTOMRIGHT')
		self.Power:SetOrientation('VERTICAL')
		self.Power:SetStatusBarTexture(rothTexV)
	end

	self.Power.bg = self.Power:CreateTexture(nil, 'BORDER')
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetTexture(rothTex)
	self.Power.bg.multiplier = .33
	if(self:GetParent():GetName():match'oUF_Raid') then
		self.Power.bg:SetTexture(rothTexV)
	end

	if(unit == 'player' or unit == 'target') then
		self.Portrait = CreateFrame('PlayerModel', nil, self)
		self.Portrait:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', 0, -1)
		self.Portrait:SetPoint('BOTTOMRIGHT', self.Power, 'TOPRIGHT', 0, 1)

		self.Portrait2 = CreateFrame('StatusBar', nil, self.Portrait)
		self.Portrait2:SetAllPoints(self.Portrait)
		self.Portrait2:SetStatusBarTexture(rothTex)
		self.Portrait2:SetStatusBarColor(.55,.57,.61,.33)
	end

	self.Health.value = SetFontString(self.Health, font,(unit == 'player' or unit == 'target') and 11 or 9)
	if(self:GetParent():GetName():match'oUF_Raid') then
		self.Health.value:SetPoint('BOTTOM', 0, 3)
	else
		self.Health.value:SetPoint('RIGHT', -1, 1)
	end

	self.Power.value = SetFontString(self.Health, font, 11)
	self.Power.value:SetPoint('LEFT', 1, 1)

	self.Name = SetFontString(self.Health, font,(unit == 'player' or unit == 'target') and 11 or 9)
	if(self:GetParent():GetName():match'oUF_Raid') then
		self.Name:SetPoint('TOP', 0, 0)
	else
		self.Name:SetPoint('LEFT', 1, 1)
	end

	self.Buffs = CreateFrame('Frame', nil, self)
	self.Buffs.spacing = 5.3
	self.Buffs:SetHeight(18.5)
	self.Buffs:SetWidth(self.Buffs:GetHeight() * 8 + self.Buffs.spacing * 7)
	self.Buffs.size = math.floor(self.Buffs:GetHeight())
	if(unit == 'player' and pBuffs == true) then
		self.Buffs:SetPoint('TOPRIGHT', self, 'TOPLEFT', -4, -1)
		self.Buffs.initialAnchor = 'TOPRIGHT'
		self.Buffs['growth-x'] = 'LEFT'
		self.Buffs['growth-y'] = 'DOWN'
		self.Buffs.filter = true
	elseif(unit == 'pet') then
		self.Buffs:SetPoint('TOPRIGHT', self, 'TOPLEFT', -4, -1)
		self.Buffs.initialAnchor = 'TOPRIGHT'
		self.Buffs['growth-x'] = 'LEFT'

		self.Power.colorPower = true
		self.Power.colorHappiness = true
		self.Power.colorReaction = false
	elseif(unit == 'target') then
		self.Buffs:SetPoint('TOPLEFT', self, 'TOPRIGHT', 4, -1)
		self.Buffs.initialAnchor = 'TOPLEFT'
		self.Buffs['growth-y'] = 'DOWN'

		self.CPoints = {}
		self.CPoints.unit = 'player'
		self.CPoints[1] = self.Power:CreateTexture(nil, 'OVERLAY')
		self.CPoints[1]:SetHeight(12)
		self.CPoints[1]:SetWidth(12)
		self.CPoints[1]:SetPoint('LEFT')
		self.CPoints[1]:SetTexture(bubbleTex)
		self.CPoints[1]:SetVertexColor(.33,.59,.33)

		self.CPoints[2] = self.Power:CreateTexture(nil, 'OVERLAY')
		self.CPoints[2]:SetHeight(12)
		self.CPoints[2]:SetWidth(12)
		self.CPoints[2]:SetPoint('LEFT', self.CPoints[1], 'RIGHT', 1)
		self.CPoints[2]:SetTexture(bubbleTex)
		self.CPoints[2]:SetVertexColor(.33,.59,.33)

		self.CPoints[3] = self.Power:CreateTexture(nil, 'OVERLAY')
		self.CPoints[3]:SetHeight(12)
		self.CPoints[3]:SetWidth(12)
		self.CPoints[3]:SetPoint('LEFT', self.CPoints[2], 'RIGHT', 1)
		self.CPoints[3]:SetTexture(bubbleTex)
		self.CPoints[3]:SetVertexColor(.65,.63,.35)

		self.CPoints[4] = self.Power:CreateTexture(nil, 'OVERLAY')
		self.CPoints[4]:SetHeight(12)
		self.CPoints[4]:SetWidth(12)
		self.CPoints[4]:SetPoint('LEFT', self.CPoints[3], 'RIGHT', 1)
		self.CPoints[4]:SetTexture(bubbleTex)
		self.CPoints[4]:SetVertexColor(.65,.63,.35)

		self.CPoints[5] = self.Power:CreateTexture(nil, 'OVERLAY')
		self.CPoints[5]:SetHeight(12)
		self.CPoints[5]:SetWidth(12)
		self.CPoints[5]:SetPoint('LEFT', self.CPoints[4], 'RIGHT', 1)
		self.CPoints[5]:SetTexture(bubbleTex)
		self.CPoints[5]:SetVertexColor(.69,.31,.31)
	end

	self.Debuffs = CreateFrame('Frame', nil, self)
	self.Debuffs.spacing = 5.3
	self.Debuffs:SetHeight(18.5)
	self.Debuffs:SetWidth(230)
	self.Debuffs.size = math.floor(self.Debuffs:GetHeight())
	if(unit == 'player'and pDebuffs == true) then
		self.Debuffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 1, -5)
		self.Debuffs.initialAnchor = 'TOPLEFT'
		self.Debuffs['growth-y'] = 'DOWN'
	elseif(unit == 'target') then
		self.Debuffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 1, -5)
		self.Debuffs.initialAnchor = 'TOPLEFT'
		self.Debuffs['growth-y'] = 'DOWN'
	end

	self.DebuffHighlight = self.Health:CreateTexture(nil, 'OVERLAY')
	self.DebuffHighlight:SetAllPoints(self.Health)
	self.DebuffHighlight:SetTexture(highlightBorder)
	self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	self.DebuffHighlight:SetBlendMode('ADD')
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightFilter = false

	self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
	self.RaidIcon:SetHeight((self:GetParent():GetName():match'oUF_Raid') and 10 or 14)
	self.RaidIcon:SetWidth((self:GetParent():GetName():match'oUF_Raid') and 10 or 14)
	self.RaidIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')
	if(self:GetParent():GetName():match'oUF_Raid') then
		self.RaidIcon:SetPoint('Center', -13, 1)
	else
		self.RaidIcon:SetPoint('TOP', 0, 8)
	end

	self.Threat = self.Health:CreateTexture(nil, 'OVERLAY')
	self.Threat:SetHeight(12)
	self.Threat:SetWidth(12)
	self.Threat:SetPoint('CENTER')
	self.Threat:SetTexture(bubbleTex)

	self.BarFade = true

	if(unit == 'player') then
		self.Combat = self.Health:CreateTexture(nil, 'OVERLAY')
		self.Combat:SetHeight(14)
		self.Combat:SetWidth(14)
		self.Combat:SetPoint('CENTER')
		self.Combat:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
		self.Combat:SetTexCoord(0.58, 0.90, 0.08, 0.41)

		if UnitLevel('player') ~= MAX_PLAYER_LEVEL then
			self.Resting = self.Power:CreateTexture(nil, 'OVERLAY')
			self.Resting:SetHeight(18)
			self.Resting:SetWidth(18)
			self.Resting:SetPoint('BOTTOMLEFT', -8.5, -8.5)
			self.Resting:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
			self.Resting:SetTexCoord(0,0.5,0,0.421875)
		end		

		if(IsAddOnLoaded('oUF_AutoShot') and class == 'HUNTER') then
			self.AutoShot = CreateFrame('StatusBar', nil, self)
			self.AutoShot:SetPoint('BOTTOMLEFT', self.Health, 'TOPLEFT', 0, 36)
			self.AutoShot:SetPoint('TOPRIGHT', self.Health, 'TOPRIGHT', 0, 41)
			self.AutoShot:SetStatusBarTexture(rothTex)
			self.AutoShot:SetStatusBarColor(.55,.57,.61)
			self.AutoShot:SetBackdrop({bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', insets = {top = -1, left = -1, bottom = -1, right = -1}})
			self.AutoShot:SetBackdropColor(.15,.15,.15)

			self.AutoShot.Time = SetFontString(self.AutoShot, font, 9)
			self.AutoShot.Time:SetPoint('CENTER', 0, 1)
			self.AutoShot.Time:SetTextColor(.84,.75,.65) 

			self.AutoShot.bg = self.AutoShot:CreateTexture(nil, 'BORDER')
			self.AutoShot.bg:SetAllPoints(self.AutoShot)
			self.AutoShot.bg:SetTexture(rothTex)
			self.AutoShot.bg:SetVertexColor(.15,.15,.15)
		end

		if(class == 'DRUID') then
			CreateFrame('Frame'):SetScript('OnUpdate', function() UpdateDruidMana(self.DruidMana) end)
			self.DruidMana = SetFontString(self.Portrait2, font, 11)
			self.DruidMana:SetPoint('CENTER', 0, 1)
			self.DruidMana:SetTextColor(1, .49, .04)
		end

		if(IsAddOnLoaded('oUF_Experience')) then
			self.Experience = CreateFrame('StatusBar', nil, self)
			self.Experience:SetPoint('BOTTOMLEFT', self.Health, 'TOPLEFT', 0, 2.5)
			self.Experience:SetPoint('TOPRIGHT', self.Health, 'TOPRIGHT', 0, 7.5)
			self.Experience:SetStatusBarTexture(rothTex)
			self.Experience:SetBackdrop({bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', insets = {top = -1, left = -1, bottom = -1, right = -1}})
			self.Experience:SetBackdropColor(.15,.15,.15)

			self.Experience.bg = self.Experience:CreateTexture(nil, 'BORDER')
			self.Experience.bg:SetAllPoints(self.Experience)
			self.Experience.bg:SetTexture(rothTex)
			self.Experience.bg:SetVertexColor(.15,.15,.15)

			self.colorExperience = {.55,.57,.61}
			self.colorReputation = {.55,.57,.61}
			self.Experience.MouseOver = true
			self.Experience.Tooltip = true
		end
	end

	if(unit == 'player' or unit == 'target') then
		self.CombatFeedbackText = SetFontString(self.Portrait2, font, 18, 'OUTLINE')
		self.CombatFeedbackText:SetPoint('CENTER', 0, 1)

		self.Castbar = CreateFrame('StatusBar', nil, self)
		self.Castbar:SetFrameStrata('HIGH')
		self.Castbar:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', 0, -1)
		self.Castbar:SetPoint('BOTTOMRIGHT', self.Power, 'TOPRIGHT', 0, 1)
		self.Castbar:SetStatusBarTexture(rothTex)
		self.Castbar:SetStatusBarColor(.86,.86,.86,.5)

		self.Castbar.bg = self.Castbar:CreateTexture(nil, 'BORDER')
		self.Castbar.bg:SetAllPoints(self.Castbar)
		self.Castbar.bg:SetTexture(rothTex)
		self.Castbar.bg:SetVertexColor(.15,.15,.15)

		self.Castbar.SafeZone = self.Castbar:CreateTexture(nil,'ARTWORK')
		self.Castbar.SafeZone:SetPoint('TOPRIGHT')
		self.Castbar.SafeZone:SetPoint('BOTTOMRIGHT')
		self.Castbar.SafeZone:SetTexture(rothTex)
		self.Castbar.SafeZone:SetVertexColor(.69,.31,.31)

		self.Castbar.Text = SetFontString(self.Castbar, font, 11)
		self.Castbar.Text:SetPoint('LEFT', 1, 1)
		self.Castbar.Text:SetTextColor(.84,.75,.65)

		self.Castbar.Time = SetFontString(self.Castbar, font, 11)
		self.Castbar.Time:SetPoint('RIGHT', -1, 1)
		self.Castbar.Time:SetTextColor(.84,.75,.65)
		self.Castbar.Time:SetJustifyH('RIGHT')

		self.Castbar.Icon = self.Castbar:CreateTexture(nil, 'ARTWORK')
		self.Castbar.Icon:SetHeight(20)
		self.Castbar.Icon:SetWidth(20)
		self.Castbar.Icon:SetTexCoord(0.1,0.9,0.1,0.9)
		if(unit =='player') then
			self.Castbar.Icon:SetPoint('RIGHT', 24, 0)
		else
			self.Castbar.Icon:SetPoint('LEFT', -24, 0)
		end

		self.IconOverlay = self.Castbar:CreateTexture(nil, 'OVERLAY')
		self.IconOverlay:SetPoint('TOPLEFT', self.Castbar.Icon, 'TOPLEFT', -2.5, 2.5)
		self.IconOverlay:SetPoint('BOTTOMRIGHT', self.Castbar.Icon, 'BOTTOMRIGHT', 2.5, -2.5)
		self.IconOverlay:SetTexture('Interface\\AddOns\\oUF_Caellian\\media\\entropy\\border')
		self.IconOverlay:SetVertexColor(.31,.45,.63)
		self.IconOverlay:SetBlendMode('BLEND')

		self.IconGloss = self.Castbar:CreateTexture(nil, 'OVERLAY')
		self.IconGloss:SetPoint('TOPLEFT', self.Castbar.Icon, 'TOPLEFT', -3, 3)
		self.IconGloss:SetPoint('BOTTOMRIGHT', self.Castbar.Icon, 'BOTTOMRIGHT', 3, -3)
		self.IconGloss:SetTexture('Interface\\AddOns\\oUF_Caellian\\media\\entropy\\gloss')
		self.IconGloss:SetVertexColor(.84,.75,.65)
		self.IconGloss:SetBlendMode('ADD')
	end

	if(self:GetParent():GetName():match'oUF_Raid' or self:GetParent():GetName():match'oUF_Party' or unit == 'player') then
		self.Leader = self.Health:CreateTexture(nil, 'OVERLAY')
		self.Leader:SetHeight(16)
		self.Leader:SetWidth(16)
		self.Leader:SetPoint('TOPLEFT', 0, 10)
		self.Leader:SetTexture('Interface\\GroupFrame\\UI-Group-LeaderIcon')
		if(self:GetParent():GetName():match'oUF_Raid' or self:GetParent():GetName():match'oUF_Party') then
			self.outsideRangeAlpha = .35
			self.inRangeAlpha = 1
			self.Range = true

			self.ReadyCheck = self.Health:CreateTexture(nil, 'OVERLAY')
			self.ReadyCheck:SetHeight(13)
			self.ReadyCheck:SetWidth(13)
			if(self:GetParent():GetName():match'oUF_Raid') then
				self.ReadyCheck:SetPoint('CENTER', 13, 1)
			else
				self.ReadyCheck:SetPoint('TOPRIGHT', 7, 7)
			end
		end
	end

	self:SetAttribute('initial-height', 23.5)
	self:SetAttribute('initial-width', 109.5)
	if(unit == 'player' or unit == 'target') then
		self:SetAttribute('initial-width', 230)
		self:SetAttribute('initial-height', 53)
	elseif(self:GetParent():GetName():match'oUF_Raid') then
		self:SetAttribute('initial-height', 35)
		self:SetAttribute('initial-width', 50)
	end

	self.PostCreateAuraIcon = PostCreateAuraIcon
	self.UNIT_NAME_UPDATE = OverrideUpdateName
	self.PostUpdateHealth = PostUpdateHealth
	self.PostUpdatePower = PostUpdatePower

	return self
end

oUF:RegisterSubTypeMapping('UNIT_LEVEL')
oUF:RegisterStyle('Caellian', SetStyle)
oUF:SetActiveStyle('Caellian')

oUF:Spawn('player'):SetPoint('CENTER', UIParent, -249.5, -174)
oUF:Spawn('target'):SetPoint('CENTER', UIParent, 249.5, -174)

oUF:Spawn('pet'):SetPoint('BOTTOMLEFT', oUF.units.player, 'TOPLEFT', 0, 10)
oUF:Spawn('focus'):SetPoint('BOTTOMRIGHT', oUF.units.player, 'TOPRIGHT', 0, 10)
oUF:Spawn('focustarget'):SetPoint('BOTTOMLEFT', oUF.units.target, 'TOPLEFT', 0, 10)
oUF:Spawn('targettarget'):SetPoint('BOTTOMRIGHT', oUF.units.target, 'TOPRIGHT', 0, 10)

local maintank = oUF:Spawn('header', 'oUF_MainTank')
maintank:SetPoint('BOTTOMRIGHT', oUF.units.player, 'TOPRIGHT', 0, 43.5)
maintank:SetManyAttributes('showRaid', true, 'groupFilter', 'MAINTANK', 'yOffset', -2.5)
maintank:Show()

local party = oUF:Spawn('header', 'oUF_Party')
party:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 15, -15)
party:SetManyAttributes('yOffset', -5, 'showParty', true)

local partyToggle = CreateFrame('Frame')
local partytarget = {}
for i = 1, 5 do
	partytarget[i] = oUF:Spawn('party'..i..'target', 'oUF_Party'..i..'Target')
	if i == 1 then
		partytarget[i]:SetPoint('TOPLEFT', party, 'TOPRIGHT', 5, 0)
	else
		partytarget[i]:SetPoint('TOP', partytarget[i-1], 'BOTTOM', 0, -5)
	end
end

local raid = {}
for i = 1, 8 do
	local raidgroup = oUF:Spawn('header', 'oUF_Raid'..i)
	raidgroup:SetManyAttributes('groupFilter', tostring(i), 'showRaid', true, 'yOffSet', -5)
	table.insert(raid, raidgroup)
	if(i==1) then
		raidgroup:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 15, -15)
	else
		raidgroup:SetPoint('TOPLEFT', raid[i-1], 'TOPRIGHT', 5, 0)
	end
end

partyToggle:RegisterEvent('PLAYER_LOGIN')
partyToggle:RegisterEvent('RAID_ROSTER_UPDATE')
partyToggle:RegisterEvent('PARTY_LEADER_CHANGED')
partyToggle:RegisterEvent('PARTY_MEMBERS_CHANGED')
partyToggle:SetScript('OnEvent', function(self)
	if(InCombatLockdown()) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		if(GetNumRaidMembers() > 5) then
			party:Hide()
			for i,v in ipairs(raid) do v:Show() end
			for i,v in ipairs(partytarget) do v:Disable()	end
		else
			party:Show()
			for i,v in ipairs(raid) do v:Hide() end
			for i,v in ipairs(partytarget) do v:Enable() end
		end
	end
end)