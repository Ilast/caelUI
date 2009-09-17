local panels, n = {}, 1
--local fadePanels = {}
local caelPanels = CreateFrame("frame", nil, UIParent)

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\Addons\caelMedia\Miscellaneous\glowtex]=], edgeSize = 2,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
}

CreatePanel = function(name, x, y, width, height, point, rpoint, anchor, parent, strata)
	panels[n] = CreateFrame("frame", name, parent)
	panels[n]:SetFrameStrata(strata)
	panels[n]:SetWidth(width)
	panels[n]:SetHeight(height)
	panels[n]:SetPoint(point, anchor, rpoint, x, y)
	panels[n]:SetBackdrop(backdrop)
	panels[n]:SetBackdropColor(0, 0, 0, 0.5)
	panels[n]:SetBackdropBorderColor(0, 0, 0)
	panels[n]:Show()
	n = n + 1
end

caelPanels.PLAYER_LOGIN = function(self)
	CreatePanel("caelPanel1", 401, 20, 321, 130, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- Chatframes
	CreatePanel("caelPanel2", -401, 20, 321, 130, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- CombatLog
	CreatePanel("caelPanel3", 0, 20, 130, 130, "BOTTOM", "BOTTOM", UIParent, UIParent, "LOW") -- Minimap
	CreatePanel("caelPanel4", -153, 90, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- TopLeftBar
	CreatePanel("caelPanel5", 153, 90, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- TopRightBar
	CreatePanel("caelPanel6", -153, 20, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- BottomLeftBar
	CreatePanel("caelPanel7", 153, 20, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- BottomRightBar

	if RecDamageMeter then
		CreatePanel("caelPanel8", -647, 20, 167, 130, "BOTTOM", "BOTTOM", UIParent, RecDamageMeter, "BACKGROUND") -- MeterLeft
		RecDamageMeter:ClearAllPoints()
		RecDamageMeter:SetPoint("TOPLEFT", caelPanel8, "TOPLEFT", 3, -3)
	end

	if RecThreatMeter then
		CreatePanel("caelPanel9", 647, 20, 167, 130, "BOTTOM", "BOTTOM", UIParent, RecThreatMeter, "BACKGROUND") -- MeterRight
		RecThreatMeter:ClearAllPoints()
		RecThreatMeter:SetPoint("TOPLEFT", caelPanel9, "TOPLEFT", 3, -3)
	end

	for i = 1, 10 do
		local panel = panels[i]
		if panel then
			local gradient = panel:CreateTexture(nil, "BORDER")
			gradient:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
			gradient:SetPoint("TOP", panel, 0, -2)
			gradient:SetPoint("LEFT", panel, 2, 0)
			gradient:SetPoint("RIGHT", panel, -2, 0)
			gradient:SetPoint("BOTTOM", panel, 0, 2)
			gradient:SetBlendMode("ADD")
			gradient:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0.55, 0.57, 0.61, 0.25)
		end
	end

--	for i = 4, 7 do
--		table.insert(fadePanels, panels[i])
--		table.insert(fadePanels, rABS_Bar1Holder)
--		table.insert(fadePanels, rABS_Bar2Holder)
--		table.insert(fadePanels, rABS_Bar3Holder)
--		table.insert(fadePanels, rABS_Bar45Holder)
--	end
end

caelPanels.UNIT_THREAT_SITUATION_UPDATE = function(self)
	local r, g, b
	local status = UnitThreatSituation("player")

	if (status and status > 0) then
		r, g, b = GetThreatStatusColor(status)
	else
		r, g, b = 0, 0, 0
	end

	for i = 1, 10 do
		local panel = panels[i]
		if panel then panel:SetBackdropBorderColor(r, g, b) end
	end
end

local reverse
local animElapsed = 0
local animTime = 1
local OnUpdate = function(self, elapsed)
	animElapsed = animElapsed + elapsed
	perc = reverse and (animTime - animElapsed) / animTime or animElapsed / animTime

--	for i, v in ipairs(fadePanels) do
--		v:SetAlpha(perc * 1)
--	end

	if animElapsed >= animTime then
		self:SetScript("OnUpdate", nil)
		for i, v in ipairs(fadePanels) do
			self:SetAlpha(reverse and 0 or 1)
		end
		animElapsed = 0
	end
end
--[[
function caelPanels:PLAYER_REGEN_DISABLED(event)
	reverse = false

	for i = 1, 8 do
		local panel = panels[i]
		if panel then
			if i == 1 then
				panel:SetPoint("BOTTOM", UIParent, "BOTTOM", 401, 20)
			elseif i == 2 then
				panel:SetPoint("BOTTOM", UIParent, "BOTTOM", -401, 20)
			end
		end
	end

	caelPanels:SetScript("OnUpdate", OnUpdate)
end

function caelPanels:PLAYER_REGEN_ENABLED(event)
	reverse = true

	for i = 1, 8 do
		local panel = panels[i]
		if panel then
			if i == 1 then
				panel:SetPoint("BOTTOM", UIParent, "BOTTOM", 227, 20)
			elseif i == 2 then
				panel:SetPoint("BOTTOM", UIParent, "BOTTOM", -227, 20)
			end
		end
	end

	caelPanels:SetScript("OnUpdate", OnUpdate)
end
]]
function OnEvent(self, event, ...)
	if type(self[event]) == 'function' then
		return self[event](self, event, ...)
	else
		print("Unhandled event: "..event)
	end
end

caelPanels:SetScript("OnEvent", OnEvent)

caelPanels:RegisterEvent("PLAYER_LOGIN")
-- caelPanels:RegisterEvent("PLAYER_REGEN_DISABLED")
-- caelPanels:RegisterEvent("PLAYER_REGEN_ENABLED")
caelPanels:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")