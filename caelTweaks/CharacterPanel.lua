local blacklist, items = {}, {}
local slots = {1, 3, 5, 6, 7, 8, 9 ,10, 16, 17, 18}

local localized, class = UnitClass('player')
local GameTooltip = GameTooltip

local ShowCloak, ShowHelm, noop = ShowCloak, ShowHelm, function() end
_G.ShowCloak, _G.ShowHelm = noop, noop

for k, v in next, {InterfaceOptionsDisplayPanelShowCloak, InterfaceOptionsDisplayPanelShowHelm} do
	v:SetButtonState('DISABLED', true)
end

local function getFreeSlot()
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			if(not GetContainerItemLink(bag, slot) and not blacklist[bag..':'..slot]) then
				return bag, slot
			end
		end
	end
end

local function onClick(self)
	ClearCursor()

	if(next(items)) then
		for i = 1, #items do
			EquipItemByName(tremove(items))
		end

		wipe(blacklist)
	else
		for k, v in next, slots do
			local item = GetInventoryItemLink('player', v)

			if(item) then
				local name, _, _, _, _, _, _, _, ranged = GetItemInfo(item)

				if(not (v == 18 and ranged:match('RELIC'))) then
					local bag, slot = getFreeSlot()

					if(bag) then
						tinsert(items, name)
						PickupInventoryItem(v)
						PickupContainerItem(bag, slot)
						blacklist[bag..':'..slot] = true
					else
						wipe(blacklist)
						return UIErrorsFrame:AddMessage('Error: Bags are full')
					end
				end
			end
		end
	end
end

local undress = CreateFrame("Button", "StripTease_DressUpFrame", DressUpFrame, "UIPanelButtonTemplate")
undress:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT")
undress:SetHeight(22)
undress:SetWidth(80)
undress:SetText("Undress")
undress:SetScript("OnClick", function() DressUpModel:Undress() end)

local nacked = CreateFrame("CheckButton", "StripTease", PaperDollFrame, "OptionsCheckButtonTemplate")
nacked:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", 7, -36)
nacked:SetToplevel(true)
nacked:SetChecked(true)
nacked:SetScript('OnClick', onClick)
nacked:SetScript("OnEnter", function()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetText("Naked !")
end)
nacked:SetScript("OnLeave", function() GameTooltip:Hide() end)

local helm = CreateFrame('CheckButton', 'HelmToggle', PaperDollFrame, "OptionsCheckButtonTemplate")
helm:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", 7, 6)
helm:SetChecked(ShowingHelm())
helm:SetToplevel()
helm:RegisterEvent('PLAYER_FLAGS_CHANGED')
helm:SetScript('OnClick', function() ShowHelm(not ShowingHelm()) end)
helm:SetScript('OnEvent', function(self, event, unit)
	if(unit == 'player') then
		self:SetChecked(ShowingHelm())
	end
end)
helm:SetScript("OnEnter", function()
 	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetText("Toggles helmet model.")
end)
helm:SetScript("OnLeave", function() GameTooltip:Hide() end)

local cloak = CreateFrame('CheckButton', 'CloakToggle', PaperDollFrame, "OptionsCheckButtonTemplate")
cloak:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", 7, -15)
cloak:SetChecked(ShowingCloak())
cloak:SetToplevel()
cloak:RegisterEvent('PLAYER_FLAGS_CHANGED')
cloak:SetScript('OnClick', function() ShowCloak(not ShowingCloak()) end)
cloak:SetScript('OnEvent', function(self, event, unit)
	if(unit == 'player') then
		self:SetChecked(ShowingCloak())
	end
end)
cloak:SetScript("OnEnter", function()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetText("Toggles cloak model.")
end)
cloak:SetScript("OnLeave", function() GameTooltip:Hide() end)