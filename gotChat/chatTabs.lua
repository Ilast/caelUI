local dummy = function() end

local function HideForever(self)
	self.Show = dummy
	self:Hide()
end

local updateFS = function(self, inc, flags, ...)
	if(self.GetFontString) then
		self = self:GetFontString()
	else
		self = self:GetParent():GetFontString()
	end

	local font, fontSize = [=[Interface\Addons\gotChat\media\neuropol x cd rg.ttf]=], 9
	if(inc) then
		self:SetFont(font, fontSize + 1, flags, alpha)
	else
		self:SetFont(font, fontSize, flags, alpha)
	end

	if((...)) then
		self:SetTextColor(...)
	end
end

local OnEnter = function(self)
	updateFS(self, nil, nil, 0.84, 0.75, 0.65, 1)
end

local OnLeave = function(self)
	updateFS(self, nil, nil, 0.84, 0.75, 0.65, 0)
end

local OnShow = function(self)
	updateFS(self, true, nil, 0.69, 0.31, 0.31, 1)
end

local OnHide = function(self)
	updateFS(self, nil, nil, 0.84, 0.75, 0.65, 0)
end

for i = 1, 7 do
	local frame = _G['ChatFrame'..i]
	local tab = _G["ChatFrame"..i.."Tab"]
	local flash = _G["ChatFrame"..i.."TabFlash"]

	if(frame == SELECTED_CHAT_FRAME) then
		updateFS(tab, nil, nil, 0.84, 0.75, 0.65, 1)
	else
		updateFS(tab, nil, nil, 0.55, 0.57, 0.61, 0)
	end

	if(flash:IsShown()) then
		updateFS(tab, nil, "OUTLINE", 0.69, 0.31, 0.31, 1)
	elseif(frame == SELECTED_CHAT_FRAME) then
		updateFS(tab, nil, nil, 0.84, 0.75, 0.65, 0)
	end

	tab:SetScript("OnEnter", OnEnter)
	tab:SetScript("OnLeave", OnLeave)
	tab:GetHighlightTexture():SetTexture(nil)
	tab.SetAlpha = function() end

	flash:SetScript("OnShow", OnShow)
	flash:SetScript("OnHide", OnHide)
	flash:GetRegions():SetTexture(nil)

	HideForever(_G["ChatFrame"..i.."TabLeft"])
	HideForever(_G["ChatFrame"..i.."TabRight"])
	HideForever(_G["ChatFrame"..i.."TabMiddle"])
end