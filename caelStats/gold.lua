--[[	$Id$	]]

local _, caelStats = ...

caelStats.gold = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.gold:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 10)
caelStats.gold:SetPoint("CENTER", caelPanel8, "CENTER", -300, 1) 

caelStats.goldFrame = CreateFrame("Frame", nil, UIParent)
caelStats.goldFrame:SetAllPoints(caelStats.gold)
caelStats.goldFrame:EnableMouse(true)
caelStats.goldFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelStats.goldFrame:RegisterEvent("PLAYER_MONEY")
caelStats.goldFrame:RegisterEvent("PLAYER_TRADE_MONEY")
caelStats.goldFrame:RegisterEvent("TRADE_MONEY_CHANGED")
caelStats.goldFrame:RegisterEvent("SEND_MAIL_COD_CHANGED")
caelStats.goldFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelStats.goldFrame:RegisterEvent("SEND_MAIL_MONEY_CHANGED")

local Profit	= 0
local Spent		= 0
local OldMoney	= 0

local function formatMoney(money)
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

caelStats.goldFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		OldMoney = GetMoney()
	end
	
	local NewMoney	= GetMoney()
	local Change = NewMoney - OldMoney -- Positive if we gain money
	
	if OldMoney > NewMoney then		-- Lost Money
		Spent = Spent - Change
	else							-- Gained Money
		Profit = Profit + Change
	end
	
	caelStats.gold:SetText(formatMoney(NewMoney))
	OldMoney = NewMoney
end)

caelStats.goldFrame:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	GameTooltip:AddDoubleLine("|cffD7BEA5Earned|r", formatMoney(Profit), 0.84, 0.75, 0.65, 1, 1, 1)
	GameTooltip:AddDoubleLine("|cffD7BEA5Spent|r", formatMoney(Spent), 0.84, 0.75, 0.65, 1, 1, 1)
	if Profit < Spent then
		GameTooltip:AddDoubleLine("|cffAF5050Deficit|r", formatMoney(Profit-Spent), 0.69, 0.31, 0.31, 1, 1, 1)
	elseif (Profit-Spent)>0 then
		GameTooltip:AddDoubleLine("|cff559655Profit|r", formatMoney(Profit-Spent), 0.33, 0.59, 0.33, 1, 1, 1)
	end
	GameTooltip:Show()
end)
