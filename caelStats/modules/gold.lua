local _, caelStats = ...

local Holder = CreateFrame("Frame")

caelStats.gold = caelPanel10:CreateFontString(nil, "OVERLAY")
caelStats.gold:SetFontObject(neuropolrg10)
caelStats.gold:SetPoint("CENTER", caelPanel10, "CENTER", 150, 0.5) 

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

local OnEvent = function(self, event)
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
end

local OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

	GameTooltip:AddDoubleLine("Earned:", formatMoney(Profit), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine("Spent:", formatMoney(Spent), 1, 1, 1, 1, 1, 1)
	if Profit < Spent then
		GameTooltip:AddDoubleLine("Deficit:", formatMoney(Profit-Spent), 1, 0, 0, 1, 1, 1)
	elseif (Profit-Spent)>0 then
		GameTooltip:AddDoubleLine("Profit:", formatMoney(Profit-Spent), 0, 1, 0, 1, 1, 1)
	end
	GameTooltip:Show()
end

Holder:EnableMouse(true)
Holder:SetAllPoints(caelStats.gold)
Holder:RegisterEvent("PLAYER_MONEY")
Holder:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
Holder:RegisterEvent("SEND_MAIL_COD_CHANGED")
Holder:RegisterEvent("PLAYER_TRADE_MONEY")
Holder:RegisterEvent("TRADE_MONEY_CHANGED")
Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
Holder:SetScript("OnEvent", OnEvent)
Holder:SetScript("OnEnter", OnEnter)
Holder:SetScript("OnLeave", function() GameTooltip:Hide() end)