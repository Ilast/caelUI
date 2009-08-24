local blacklist, items = {}, {}
local slots = {1, 3, 5, 6, 7, 8, 9 ,10, 16, 17, 18}

local localized, class = UnitClass('player')
local GameTooltip = GameTooltip

local ShowCloak, ShowHelm, noop = ShowCloak, ShowHelm, function() end
_G.ShowCloak, _G.ShowHelm = noop, noop

for _,check in pairs{InterfaceOptionsDisplayPanelShowCloak, InterfaceOptionsDisplayPanelShowHelm} do
	check:Disable()
	check.Enable = noop
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

local getnacked = CreateFrame("CheckButton", "StripTease", PaperDollFrame, "OptionsCheckButtonTemplate")
getnacked:ClearAllPoints()
getnacked:SetHeight(22)
getnacked:SetWidth(22)
getnacked:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", 7, -36)
getnacked:SetToplevel(true)
getnacked:SetChecked(true)
getnacked:SetScript('OnClick', onClick)

local undress = CreateFrame("Button", "StripTease_DressUpFrame", DressUpFrame, "UIPanelButtonTemplate")
undress:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT")
undress:SetHeight(22)
undress:SetWidth(80)
undress:SetText("Undress")
undress:SetScript("OnClick", function() DressUpModel:Undress() end)

local hcheck = CreateFrame("CheckButton", "HelmCheckBox", PaperDollFrame, "OptionsCheckButtonTemplate")
hcheck:ClearAllPoints()
hcheck:SetWidth(22)
hcheck:SetHeight(22)
hcheck:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", 7, 6)
hcheck:SetScript("OnClick", function() ShowHelm(not ShowingHelm()) end)
hcheck:SetScript("OnEnter", function()
 	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetText("Toggles helmet model.")
end)
hcheck:SetScript("OnLeave", function() GameTooltip:Hide() end)
hcheck:SetScript("OnEvent", function() hcheck:SetChecked(ShowingHelm()) end)
hcheck:RegisterEvent("UNIT_MODEL_CHANGED")
hcheck:SetToplevel(true)

local ccheck = CreateFrame("CheckButton", "CloakCheckBox", PaperDollFrame, "OptionsCheckButtonTemplate")
ccheck:ClearAllPoints()
ccheck:SetWidth(22)
ccheck:SetHeight(22)
ccheck:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", 7, -15)
ccheck:SetScript("OnClick", function() ShowCloak(not ShowingCloak()) end)
ccheck:SetScript("OnEnter", function()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetText("Toggles cloak model.")
end)
ccheck:SetScript("OnLeave", function() GameTooltip:Hide() end)
ccheck:SetScript("OnEvent", function() ccheck:SetChecked(ShowingCloak()) end)
ccheck:RegisterEvent("UNIT_MODEL_CHANGED")
ccheck:SetToplevel(true)

hcheck:SetChecked(ShowingHelm())
ccheck:SetChecked(ShowingCloak())