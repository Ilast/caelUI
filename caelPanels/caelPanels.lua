--[[	$Id$	]]

local _, caelPanels = ...

caelPanels.eventFrame = CreateFrame("frame", nil, UIParent)

local panels, n = {}, 1
--	local fadePanels = {}
local bgTexture = caelMedia.files.bgFile

caelPanels.createPanel = function(name, x, y, width, height, point, rpoint, anchor, parent, strata)
	panels[n] = CreateFrame("frame", name, parent)
	panels[n]:EnableMouse(false)
	panels[n]:SetFrameStrata(strata)
	panels[n]:SetWidth(caelLib.scale(width))
	panels[n]:SetHeight(caelLib.scale(height))
	panels[n]:SetPoint(point, anchor, rpoint, caelLib.scale(x), caelLib.scale(y))
	panels[n]:SetBackdrop(caelMedia.backdropTable)
	panels[n]:SetBackdropColor(0.1, 0.1, 0.1, 1)
	panels[n]:SetBackdropBorderColor(0, 0, 0)
	panels[n]:Show()
	n = n + 1
end

caelPanels.createPanel("caelPanel1", 401, 20, 321, 130, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- Chatframes
caelPanels.createPanel("caelPanel2", -401, 20, 321, 130, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- CombatLog
caelPanels.createPanel("caelPanel3", 0, 20, 130, 130, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- Minimap
caelPanels.createPanel("caelPanel3a", 401, 150, 321, 20, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- ChatFrameEditBox
caelPanels.createPanel("caelPanel4", -153, 90, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- TopLeftBar
caelPanels.createPanel("caelPanel5", 153, 90, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- TopRightBar
caelPanels.createPanel("caelPanel6", -153, 20, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- BottomLeftBar
caelPanels.createPanel("caelPanel7", 153, 20, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- BottomRightBar
caelPanels.createPanel("caelPanel8", 0, 2, 1124, 18, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- DataFeeds bar
caelPanels.createPanel("caelPanel11", -30, 0, 31, 336, "RIGHT", "RIGHT", UIParent, UIParent, "BACKGROUND") -- Side Action Bar

caelPanels.eventFrame:RegisterEvent("PLAYER_LOGIN")
caelPanels.eventFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		if recDamageMeter then
			caelPanels.createPanel("caelPanel9", -647, 20, 167, 130, "BOTTOM", "BOTTOM", UIParent, recDamageMeter, "BACKGROUND") -- MeterLeft
			recDamageMeter:ClearAllPoints()
			recDamageMeter:SetPoint("TOPLEFT", caelPanel9, "TOPLEFT", caelLib.scale(3), caelLib.scale(-3))
		end

		if recThreatMeter then
			caelPanels.createPanel("caelPanel10", 647, 20, 167, 130, "BOTTOM", "BOTTOM", UIParent, recThreatMeter, "BACKGROUND") -- MeterRight
			recThreatMeter:ClearAllPoints()
			recThreatMeter:SetPoint("TOPLEFT", caelPanel10, "TOPLEFT", caelLib.scale(3), caelLib.scale(-3))
		end

		--[[
		for i = 1, 11 do
			local panel = panels[i]
			if panel then
				local width = caelLib.scale(panel:GetWidth() - 6)
				local height = caelLib.scale(panel:GetHeight() / 5)

				local gradientTop = panel:CreateTexture(nil, "BORDER")
				gradientTop:SetTexture(bgTexture)
				gradientTop:SetSize(width, height)
				gradientTop:SetPoint("TOPLEFT", caelLib.scale(3), caelLib.scale(-2))
				--gradientTop:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0)

				local gradientBottom = panel:CreateTexture(nil, "BORDER")
				gradientBottom:SetTexture(bgTexture)
				gradientBottom:SetSize(width, height)
				gradientBottom:SetPoint("BOTTOMRIGHT", caelLib.scale(-3), caelLib.scale(2))
				--gradientBottom:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0)
			end
		end
		--]]
	end
--	for i = 4, 7 do
--		table.insert(fadePanels, panels[i])
--		table.insert(fadePanels, rABS_Bar1Holder)
--		table.insert(fadePanels, rABS_Bar2Holder)
--		table.insert(fadePanels, rABS_Bar3Holder)
--		table.insert(fadePanels, rABS_Bar45Holder)
--	end
end)

--[[
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

caelPanels:RegisterEvent("PLAYER_REGEN_DISABLED")
caelPanels:RegisterEvent("PLAYER_REGEN_ENABLED")
--]]

-- Push panels table into global scope.
_G["caelPanels"] = panels
