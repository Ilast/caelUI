if not oUF then return end

local _, playerClass = UnitClass("player")

local canDispel = {
	PRIEST = { Magic = true, Disease = true },
	SHAMAN = { Curse = true, Poison = true, Disease = true },
	PALADIN = { Magic = true, Poison = true, Disease = true },
	MAGE = { Curse = true },
	DRUID = { Curse = true, Poison = true }
}

local dispelList = canDispel[playerClass] or {}

local whiteList = {
	["Essence of the Blood Queen"] = true, -- 71531
	["Hunter's Mark"] = true, -- 71531
}

local function GetDebuffType(unit)
--	if not UnitCanAssist("player", unit) then return end

	local dispelType, debuffIcon

	local i = 1
	local isWhiteList

	while true do
		local name, _, icon, _, debuffType = UnitAura(unit, i, "HARMFUL")

		if not icon then break end

		if (debuffType and dispelList[debuffType]) or whiteList[name] then
			dispelType = debuffType
			debuffIcon = icon
			
			if whiteList[name] then
				isWhiteList = true
				break
			end
		end

		i = i + 1
	end

	return dispelType, debuffIcon, isWhiteList
end

local function Update(self, event, unit)
	if self.unit ~= unit  then return end

	local dispelType, debuffIcon, isWhiteList = GetDebuffType(unit)

	if self.cDebuffBackdrop then
		local color

		if debuffIcon and (isWhiteList or not self.cDebuffFilter) then
			color = DebuffTypeColor[dispelType]
			self.cDebuffBackdrop:SetVertexColor(color.r, color.g, color.b, 1)
		else
			self.cDebuffBackdrop:SetVertexColor(0, 0, 0, 0)
		end
	end

	if self.cDebuff.Icon then
		if debuffIcon and (isWhiteList or not self.cDebuffFilter) then
			self.cDebuff.Icon:SetTexture(debuffIcon)
			self.cDebuff.IconOverlay:SetVertexColor(0.25, 0.25, 0.25, 1)
			self.cDebuff.IconOverlay:SetTexture([=[Interface\Addons\oUF_Caellian\media\textures\buttontex]=])
		else
			self.cDebuff.Icon:SetTexture(nil)
			self.cDebuff.IconOverlay:SetVertexColor(0.25, 0.25, 0.25, 0)
			self.cDebuff.IconOverlay:SetTexture(nil)
		end
	end
end

local function Enable(self)
	if not self.cDebuff then return end

	self:RegisterEvent("UNIT_AURA", Update)

	return true
end

local function Disable(self)
	if self.cDebuffBackdrop or self.cDebuff.Icon then
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("cDebuff", Update, Enable, Disable)