--| Optional deps |--
LoadAddOn("GPS")  -- I heard there was a problem with optdeps not working. Let"s force it. 

--| Cache |--
local WorldMapButton = WorldMapButton
local WorldMapTooltip = WorldMapTooltip
local ipairs = ipairs
local pairs = pairs
local WorldMapPlayer = WorldMapPlayer
local MouseIsOver = MouseIsOver
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local upper = string.upper
local gsub = string.gsub
local UnitClass = UnitClass
local format = string.format
local UnitName = UnitName
local _G = _G
local match = string.match
local find = string.find
local UnitLevel = UnitLevel
local GetPlayerMapPosition = GetPlayerMapPosition
local GPS_buttonroster = GPS and GPS.buttonroster
local WorldMapTooltipTextRight4 = WorldMapTooltipTextRight4

--| Hooks |--
local over = {}
local OnEnter = function(self)
	if self:GetCenter() > WorldMapButton:GetCenter() then  -- Should the tooltip be on the left or right? 
		WorldMapTooltip:SetOwner(self,"ANCHOR_LEFT")
	else
		WorldMapTooltip:SetOwner(self,"ANCHOR_RIGHT")
	end
	
	for k in ipairs(over) do  -- Use an upvalue table that"s cleared to avoid garbage waste.
		over[k] = nil
	end
	
	-- Run through all the WorldMap blips to see if any are underneath "self". If so, we"ll display multiple names in the tooltip. 
	if self ~= WorldMapPlayer and WorldMapPlayer:IsVisible() and MouseIsOver(WorldMapPlayer) then
		local color = RAID_CLASS_COLORS[upper(gsub(UnitClass(WorldMapPlayer.unit)," ",""))]
		over[#over+1] = format("Player: |cff%02x%02x%02x%s|r",color.r*255,color.g*255,color.b*255,UnitName("player"))
	end
	for i = 1,4 do  -- Party.
		local btn = _G["WorldMapParty"..i]
		if btn ~= self and btn:IsVisible() and MouseIsOver(btn) then
			local color = RAID_CLASS_COLORS[upper(gsub(UnitClass(btn.unit)," ",""))]
			over[#over+1] = format("|cffaaaaffParty|r: |cff%02x%02x%02x%s|r",color.r*255,color.g*255,color.b*255,UnitName(btn.unit))
		end
	end
	for i = 1,40 do  -- Raid.
		local btn = _G["WorldMapRaid"..i]
		if btn ~= self and btn:IsVisible() and MouseIsOver(btn) then
			local color = RAID_CLASS_COLORS[upper(gsub(UnitClass(btn.unit)," ",""))]
			over[#over+1] = format("|cffff7f00Raid|r: |cff%02x%02x%02x%s|r",color.r*255,color.g*255,color.b*255,UnitName(btn.unit))
		end
	end
	if GPS_buttonroster then
		for name,btn in pairs(GPS_buttonroster) do  -- Guild.
			if btn ~= self and btn:IsVisible() and MouseIsOver(btn) then
				local color = btn.color
				over[#over+1] = format("|cff3fff3fGuild|r: |cff%02x%02x%02x%s|r",color.r*255,color.g*255,color.b*255,name)
			end
		end
	end
	
	if #over > 0 then  -- We have more than one unit to display.
		local color = RAID_CLASS_COLORS[upper(gsub(UnitClass(self.unit)," ",""))]
		local fmt
		if find(self.unit,"^raid") then
			fmt = "|cffff7f00Raid|r: |cff%02x%02x%02x%s|r"
		elseif find(self.unit,"^party") then
			fmt = "|cffaaaaffParty|r: |cff%02x%02x%02x%s|r"
		else
			fmt = "Player: |cff%02x%02x%02x%s|r"
		end
		WorldMapTooltip:AddLine(format(fmt,color.r*255,color.g*255,color.b*255,UnitName(self.unit)),1,1,1)  -- First add "self".
		for _,name in ipairs(over) do
			WorldMapTooltip:AddLine(name,1,1,1)  -- Then add the others. 
		end
	else  -- Just "self".
		local color = RAID_CLASS_COLORS[upper(gsub(UnitClass(self.unit)," ",""))]
		WorldMapTooltip:AddLine(UnitName(self.unit),color.r or 1,color.g or 1,color.b or 1)
		WorldMapTooltip:AddDoubleLine("Class:",UnitClass(self.unit),1,1,1,1,1,1)
		WorldMapTooltip:AddDoubleLine("Level:",UnitLevel(self.unit),1,1,1,1,1,1)
		local x,y = GetPlayerMapPosition(self.unit); WorldMapTooltip:AddDoubleLine("Position:",format("%.1f, %.1f",x*100,y*100),1,1,1,1,1,1)
	end
	WorldMapTooltip:Show()
end

local function OnUpdate(self)  -- Constant updating of the coords.
	self = self:GetOwner()
	if self and self.unit then
		local cur = WorldMapTooltipTextRight4:IsShown() and WorldMapTooltipTextRight4:GetText()
		if cur and match(cur,"^%d+%.%d+, %d+%.%d+$") then
			local x,y = GetPlayerMapPosition(self.unit)
			WorldMapTooltipTextRight4:SetText(format("%.1f, %.1f",x*100,y*100),1,1,1)
		end
	end
end
if WorldMapTooltip:GetScript("OnUpdate") then
	WorldMapTooltip:HookScript("OnUpdate",OnUpdate)
else
	WorldMapTooltip:SetScript("OnUpdate",OnUpdate)
end

for i = 1,4 do
	_G["WorldMapParty"..i]:SetScript("OnEnter",OnEnter)
end

for i = 1,40 do
	_G["WorldMapRaid"..i]:SetScript("OnEnter",OnEnter)
end

WorldMapPlayer:SetScript("OnEnter",OnEnter)