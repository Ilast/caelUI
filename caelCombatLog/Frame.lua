--[[	$Id$	]]

local _, caelCombatLog = ...

caelCombatLog.frame = CreateFrame("Frame", "caelCombatLogFrame", UIParent)

caelCombatLog.frame:SetWidth(caelLib.scale(311.5))
caelCombatLog.frame:SetHeight(caelLib.scale(104.5))
caelCombatLog.frame:SetPoint("BOTTOM", UIParent, "BOTTOM", caelLib.scale(-401), caelLib.scale(43))

local function ScrollFrame(self, delta)
	if delta > 0 then
		for i = 1, #self:GetParent().collumns do
			if IsShiftKeyDown() then
				self:GetParent().collumns[i]:ScrollToTop()
			else
				self:GetParent().collumns[i]:ScrollUp()
			end
		end
	elseif delta < 0 then
		for i = 1, #self:GetParent().collumns do
			if IsShiftKeyDown() then
				self:GetParent().collumns[i]:ScrollToBottom()
			else
				self:GetParent().collumns[i]:ScrollDown()
			end
		end
	end
end

local function OnHyperlinkEnter(self, data, link)
	local linktype, contents = data:sub(1,4),data:sub(6)
	if linktype == "Clog" and contents ~= "" then
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:SetText(data:sub(6))
		GameTooltip:Show()
	end
end

local function OnHyperlinkLeave(self)
	GameTooltip:Hide()
end

local function OnHyperlinkClick(self, data, link)
	local linktype, contents = data:sub(1, 4), data:sub(6)
	if linktype == "Clog" and contents ~= "" and IsShiftKeyDown() then
		local chatType = ChatFrameEditBox:GetAttribute("chatType")
		local tellTarget = ChatFrameEditBox:GetAttribute("tellTarget")
		local channelTarget = ChatFrameEditBox:GetAttribute("channelTarget")
--		ChatFrameEditBox:Show()
		local from, to, pos
		for i = 1, 5 do
			from, to = string.find(contents, "\n", pos or 1)
			SendChatMessage(string.sub(contents, pos or 1, (from or 0) - 1), chatType, GetDefaultLanguage("player"), tellTarget or channelTarget)
			if not from then return end
			pos = (to or 0) + 1
		end
--	ChatFrameEditBox:Insert(contents:gsub("\n", " | "))
	end
end

local function OnLeave(self)
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide()
	end
end

caelCombatLog.frame.collumns = {}
for i = 1, 3 do
   local smf = CreateFrame("ScrollingMessageFrame", nil, caelCombatLog.frame)
    smf:SetMaxLines(1000)
    smf:SetFont(caelMedia.fonts.CHAT_FONT, 9)
    smf:SetSpacing(2)
    smf:SetFading(true)
	smf:SetFadeDuration(5)
	smf:SetTimeVisible(20)
	smf:SetScript("OnMouseWheel", ScrollFrame)
	smf:EnableMouse(true)
	smf:EnableMouseWheel(true)
	smf:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)
	smf:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
	smf:SetScript("OnHyperlinkClick", OnHyperlinkClick)
	smf:SetScript("OnLeave", OnLeave)
	if i == 1 or i == 3 then
		smf:SetWidth(caelCombatLog.frame:GetWidth()/3 - 45)
	else
		smf:SetWidth(caelCombatLog.frame:GetWidth()/3 + 82)
	end
	caelCombatLog.frame.collumns[i] = smf
end

caelCombatLog.frame.collumns[1]:SetPoint("TOPLEFT")
caelCombatLog.frame.collumns[1]:SetPoint("BOTTOMLEFT")
caelCombatLog.frame.collumns[2]:SetPoint("TOP")
caelCombatLog.frame.collumns[2]:SetPoint("BOTTOM")
caelCombatLog.frame.collumns[3]:SetPoint("TOPRIGHT")
caelCombatLog.frame.collumns[3]:SetPoint("BOTTOMRIGHT")

caelCombatLog.frame.collumns[1]:SetJustifyH("LEFT")
caelCombatLog.frame.collumns[2]:SetJustifyH("CENTER")
caelCombatLog.frame.collumns[3]:SetJustifyH("RIGHT")

--local icon = "Interface\\LFGFrame\\LFGRole"
local icon = [=[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]=]

local tex1 = caelCombatLog.frame:CreateTexture(nil, "ARTWORK")
tex1:SetSize(caelLib.scale(14), caelLib.scale(14))
tex1:SetTexture(icon)
--tex1:SetTexCoord(1/2, 0, 1/2, 1, 3/4, 0, 3/4, 1)
tex1:SetTexCoord(0, 19/64, 22/64, 41/64)
tex1:SetPoint("TOPLEFT", caelCombatLog.frame, "BOTTOMLEFT", 0, caelLib.scale(-5))

local tex2 = caelCombatLog.frame:CreateTexture(nil, "ARTWORK")
tex2:SetSize(caelLib.scale(14), caelLib.scale(14))
tex2:SetTexture(icon)
--tex2:SetTexCoord(3/4, 0, 3/4, 1, 1, 0, 1, 1)
tex2:SetTexCoord(20/64, 39/64, 1/64, 20/64)
tex2:SetPoint("TOP", caelCombatLog.frame, "BOTTOM", 0, caelLib.scale(-5))

local tex3 = caelCombatLog.frame:CreateTexture(nil, "ARTWORK")
tex3:SetSize(caelLib.scale(14), caelLib.scale(14))
tex3:SetTexture(icon)
--tex3:SetTexCoord(1/4, 0, 1/4, 1, 1/2, 0, 1/2, 1)
tex3:SetTexCoord(20/64, 39/64, 22/64, 41/64)
tex3:SetPoint("TOPRIGHT", caelCombatLog.frame, "BOTTOMRIGHT", 0, caelLib.scale(-5))