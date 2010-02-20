local dummy = function() end

local function kill(self)
	self.Show = dummy
	self:Hide()
end

local updateText = function(self, ...)
	self = self.GetFontString and self:GetFontString() or self:GetParent():GetFontString()

	self:SetFontObject(neuropolrg10)

	self:SetTextColor(...)
end

local OnEnter = function(self)
	updateText(self, 0.84, 0.75, 0.65, 1)
end

local OnLeave = function(self)
	if(_G["ChatFrame"..self:GetID().."TabFlash"]:IsShown()) then
		updateText(self, 0.69, 0.31, 0.31, 1)
	else
		updateText(self, 0.84, 0.75, 0.65, 0)
	end
end

local OnShow = function(self)
	updateText(self, 0.69, 0.31, 0.31, 1)
end

local OnHide = function(self)
	updateText(self, 0.84, 0.75, 0.65, 1)
end

for i = 1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame"..i]
	local tab = _G["ChatFrame"..i.."Tab"]
	local flash = _G["ChatFrame"..i.."TabFlash"]

	if(frame == SELECTED_CHAT_FRAME) then
		updateText(tab, 0.84, 0.75, 0.65, 1)
	else
		updateText(tab, 0.84, 0.75, 0.65, 0)
	end

	if flash:IsShown() then
		updateText(tab, 0.69, 0.31, 0.31, 1)
	elseif(frame == SELECTED_CHAT_FRAME) then
		updateText(tab, 0.84, 0.75, 0.65, 0)
	end

	tab:SetScript("OnEnter", OnEnter)
	tab:SetScript("OnLeave", OnLeave)
	tab:GetHighlightTexture():SetTexture(nil)
	tab.SetAlpha = function() end

	flash:SetScript("OnShow", OnShow)
	flash:SetScript("OnHide", OnHide)
	flash:GetRegions():SetTexture(nil)

	kill(_G["ChatFrame"..i.."TabLeft"])
	kill(_G["ChatFrame"..i.."TabRight"])
	kill(_G["ChatFrame"..i.."TabMiddle"])
end