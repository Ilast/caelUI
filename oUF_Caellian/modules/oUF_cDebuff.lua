if not oUF then return end

local _, playerClass = UnitClass("player")

local CanDispel = {
	PRIEST = { Magic = true, Disease = true },
	SHAMAN = { Curse = true, Poison = true, Disease = true },
	PALADIN = { Magic = true, Poison = true, Disease = true },
	MAGE = { Curse = true },
	DRUID = { Curse = true, Poison = true }
}
local dispellist = CanDispel[playerClass] or {}

local function GetDebuffType(unit)
	if not UnitCanAssist("player", unit) then return end

	local firstDebuffType, firstDebuffIcon

	local i = 1
	while true do
		local _, _, texture, _, debufftype, _, _, _, _ = UnitAura(unit, i, "HARMFUL")

		if not texture then break end

		if debufftype then
			if not firstDebuffType then
				firstDebuffType = debufftype
				firstDebuffIcon = texture
			end

			if dispellist[debufftype] then
				return firstDebuffType, firstDebuffIcon, debufftype, texture
			end
		end

		i = i + 1
	end

	return firstDebuffType, firstDebuffIcon
end

local function Update(self, event, unit)
	if self.unit ~= unit  then return end
	local unfilteredDebuffType, unfilteredDebuffTexture, filteredDebuffType, filteredDebuffTexture = GetDebuffType(unit)

	if self.cDebuffBackdrop then
		local color

		if self.cDebuffBackdropFilter and filteredDebuffType then
			color = DebuffTypeColor[filteredDebuffType]
			self.cDebuffBackdrop:SetVertexColor(color.r, color.g, color.b, 1)
		elseif not self.cDebuffBackdropFilter and unfilteredDebuffType then
			color = DebuffTypeColor[unfilteredDebuffType]
			self.cDebuffBackdrop:SetVertexColor(color.r, color.g, color.b, 1)
		else
			self.cDebuffBackdrop:SetVertexColor(0, 0, 0, 0)
		end
	end

	if self.cDebuff.Icon then
		if self.cDebuffIconFilter and filteredDebuffTexture then
			self.cDebuff.Icon:SetTexture(filteredDebuffTexture)
			self.cDebuff.IconOverlay:SetVertexColor(0.25, 0.25, 0.25, 1)
			self.cDebuff.IconOverlay:SetTexture([=[Interface\Addons\oUF_Caellian\media\textures\buttontex]=])
		elseif not self.cDebuffIconFilter and unfilteredDebuffTexture then
			self.cDebuff.Icon:SetTexture(unfilteredDebuffTexture)
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
	if not self.cDebuffBackdrop and not self.cDebuff.Icon then return end

	if (self.cDebuffBackdropFilter and self.cDebuffIconFilter) and not CanDispel[playerClass] then
		return
	end

	self:RegisterEvent("UNIT_AURA", Update)

	return true
end

local function Disable(self)
	if self.cDebuffBackdrop or self.cDebuff.Icon then
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement('cDebuff', Update, Enable, Disable)