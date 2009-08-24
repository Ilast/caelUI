﻿local caelTooltips = CreateFrame("Frame")

local TheOneScale = (768/tonumber(GetCVar("gxResolution"):match("%d+x(%d+)")))/GetCVar("uiScale")
local font, fontsize = [=[Interface\Addons\caelTooltips\media\neuropol x cd rg.ttf]=], 9/TheOneScale
local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]

local _G = _G

local gsub = string.gsub
local find = string.find
local format = string.format

_G["GameTooltipHeaderText"]:SetFont(font, fontsize + 2)
_G["GameTooltipText"]:SetFont(font, fontsize)
_G["GameTooltipTextSmall"]:SetFont(font, fontsize - 2)

local Tooltips = {
	GameTooltip,
	ItemRefTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
	WorldMapTooltip,
}

local classification = {
	worldboss = "|cffAF5050Boss|r",
	eliterare = "|cffAF5050+ Rare|r",
	elite = "|cffAF5050+|r",
	rare = "|cffAF5050Rare|r",
}

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\Addons\caelTooltips\media\glowTex]=], edgeSize = 2,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
}

local BorderColor = function(self)
	local unit = select(2, self:GetUnit())
	local reaction = unit and UnitReaction("player", unit)

	if reaction then
		local r, g, b = FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b
		self:SetBackdropBorderColor(r, g, b)
	else
		local _, link = self:GetItem()
		local quality = link and select(3, GetItemInfo(link))
		if quality and quality >= 2 then
			local r, g, b = GetItemQualityColor(quality)
			self:SetBackdropBorderColor(r, g, b, borderAlpha)
		else
			self:SetBackdropBorderColor(0, 0, 0)
		end
	end
	self:SetBackdropColor(0, 0, 0, GetMouseFocus() == WorldFrame and 0.5 or 0.85)
end

local FormatMoney = function(money)
	local gold = floor(math.abs(money) / 10000)
	local silver = mod(floor(math.abs(money) / 100), 100)
	local copper = mod(floor(math.abs(money)), 100)

	if gold ~= 0 then
		return format("%s|cffffd700g|r %s|cffc7c7cfs|r %s|cffeda55fc|r", gold, silver, copper)
	elseif silver ~= 0 then
		return format("%s|cffc7c7cfs|r %s|cffeda55fc|r", silver, copper)
	else
		return format("%s|cffeda55fc|r", copper)
	end
end

GameTooltip_SetDefaultAnchor = function(self, parent)
	self:SetOwner(parent, "ANCHOR_NONE")
	self:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 152/TheOneScale)
	self.default = 1
end

GameTooltip_UnitColor = function(unit)
	local r, g, b

	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or not UnitIsConnected(unit) or UnitIsDead(unit) then
		r, g, b = 0.55, 0.57, 0.61
	else
		r, g, b = UnitSelectionColor(unit)
	end

	return r, g, b
end

local OnTooltipSetItem = function(self)
	local link = select(2, self:GetItem())
	if link then
		local id = tonumber(link:match("item:(%d+):"))

		if id then
			local _, _, _, level, _, itype, subtype, stack = GetItemInfo(id)
			if level then
				local typetext = itype and subtype and format("Type: %s - %s", itype, subtype) or nil
				local r, g, b = 0.84, 0.75, 0.65

				self:AddDoubleLine("iLevel: "..level, "ItemID: "..id, r, g, b, r, g, b)
				if stack ~= 1 then
					self:AddDoubleLine(typetext, "Stacks to: "..stack, r, g, b, r, g, b)
				else
					self:AddLine(typetext, r, g, b)
				end
				self:Show()
			end
		end
	end
end

GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)

local OnTooltipSetUnit = function(self)
	local lines = self:NumLines()
	local _, unit = self:GetUnit()
	if(not unit or not UnitExists(unit)) then return end

	local race = UnitRace(unit)
	local level = UnitLevel(unit)
	local guild = GetGuildInfo(unit)
	local name, realm = UnitName(unit)
	local crtype = UnitCreatureType(unit)
	local classif = UnitClassification(unit)
	local r, g, b = GetQuestDifficultyColor(level).r, GetQuestDifficultyColor(level).g, GetQuestDifficultyColor(level).b

	_G["GameTooltipTextLeft1"]:SetFormattedText("%s%s", name, realm and realm ~= "" and " (*)" or "")

	if(UnitIsPlayer(unit)) then
		if UnitIsAFK(unit) then
			self:AppendText(("|cff559655 %s|r"):format(CHAT_FLAG_AFK))
		elseif UnitIsDND(unit) then 
			self:AppendText(("|cff559655 %s|r"):format(CHAT_FLAG_DND))
		end

		local offset = 2
		if guild then
			_G["GameTooltipTextLeft2"]:SetPoint("TOPLEFT", _G["GameTooltipTextLeft1"], "BOTTOMLEFT", 0, -1)
			_G["GameTooltipTextLeft2"]:SetFormattedText("%s", IsInGuild() and GetGuildInfo("player") == guild and "|cff0090ff« "..guild.." »|r" or "|cff00ff10« "..guild.." »|r")
			offset = offset + 1
		end

		for i= offset, lines do
			if(_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%d|r %s", r*255, g*255, b*255, level, race)
				break
			end
		end
	else
		for i = 2, lines do
			if((_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) or (crtype and _G["GameTooltipTextLeft"..i]:GetText():find("^"..crtype))) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r%s %s", r*255, g*255, b*255, classif ~= "worldboss" and level or "", classification[classif] or "", crtype or "")
				break
			end
		end
	end

	local pvpLine
	for i = 1, lines do
		local text = _G["GameTooltipTextLeft"..i]:GetText()
		if text and text == PVP_ENABLED then
			pvpLine = _G["GameTooltipTextLeft"..i]
			pvpLine:SetText()
			break
		end
	end

	if(UnitExists(unit.."target") and unit ~= "player") then
		local r, g, b = 0.33, 0.59, 0.33
		local text = ""

		if(UnitIsEnemy("player", unit.."target")) then
			r, g, b = 0.69, 0.31, 0.31
		elseif(not UnitIsFriend("player", unit.."target")) then
			r, g, b = 0.65, 0.63, 0.35
		end

		if(UnitName(unit.."target") == UnitName("player")) then
			text = "You"
		else
			text = UnitName(unit.."target")
		end
		
		if pvpLine then
			pvpLine:SetText("|cffD7BEA5Target:|r "..text)
			pvpLine:SetTextColor(r,g,b)
		else
			self:AddLine("|cffD7BEA5Target:|r "..text, r, g, b)
		end
	end
end

GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)

local OnTooltipAddMoney = function(self, cost, maxcost)
	r, g, b = 0.84, 0.75, 0.65
	self:AddLine("Value: "..FormatMoney(cost), r, g, b)
end

GameTooltip:SetScript("OnTooltipAddMoney", OnTooltipAddMoney)

function caelTooltips:ApplyLayout()
	for i, v in ipairs(Tooltips) do
		v:HookScript("OnShow", function(self)
			self:SetHeight(floor(self:GetHeight()))
			self:SetWidth(floor(self:GetWidth()))
			BorderColor(self)
		end)

		v:SetBackdrop(backdrop)
		v:SetScale(TheOneScale)

		local gradient = v:CreateTexture(nil, "BORDER")
		gradient:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
		gradient:SetPoint("TOP", v, 0, -2)
		gradient:SetPoint("LEFT", v, 2, 0)
		gradient:SetPoint("RIGHT", v, -2, 0)
		gradient:SetPoint("BOTTOM", v, 0, 2)
		gradient:SetBlendMode("ADD")
		gradient:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0.55, 0.57, 0.61, 0.25)

		GameTooltipStatusBar:SetAlpha(0)
	end
end

caelTooltips:RegisterEvent("PLAYER_ENTERING_WORLD")
caelTooltips.PLAYER_ENTERING_WORLD = function(self)
	self:ApplyLayout()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function OnEvent(self, event, ...)
	if type(self[event]) == 'function' then
		return self[event](self, event, ...)
	else
		print("Unhandled event: "..event)
	end
end

caelTooltips:SetScript("OnEvent", OnEvent)