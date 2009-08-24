local print = function(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffD7BEA5cael|rSmartAmmo: "..tostring(text))
end

if select(2, UnitClass("player")) ~= "HUNTER" then
	print("You are not a Hunter, caelSmartAmmo will be disabled on next UI reload.")
	return DisableAddOn("caelSmartAmmo")
end

local caelSmartAmmo = CreateFrame("Frame")
caelSmartAmmo:SetScript("OnEvent", function(self) self:OnEvent(event) end)

local hiBullets, medBullets, loBullets = 41164, 31735, 41584 -- Mammoth Cutters, Timeless Shell, Frostbite Bullets
local hiArrows, medArrows, loArrows = 41165, 31737, 41586 -- Saronite Razorheads, Timeless Arrow, Terrorshaft Arrow

local function EquipAmmo(primary, secondary, fallback)
	local itemid
	if GetItemCount(primary) > 0 then
		itemid = primary
	elseif GetItemCount(secondary) > 0 then
		itemid = secondary
	elseif GetItemCount(fallback) > 0 then
		itemid = fallback
	else
		return
	end

	if not GetInventoryItemLink("player", 0):match("item:"..tostring(itemid)..":") then
		EquipItemByName(itemid)
	end
end

function caelSmartAmmo:OnEvent(event)
	if not UnitCanAttack("player", "target") or UnitIsDead("target") then return end

	local rangedWeapon = GetInventoryItemLink("player", GetInventorySlotInfo("RangedSlot"))
	if rangedWeapon then
		local _, _, _, _, _, _, itemType = GetItemInfo(rangedWeapon)

		local hiAmmo, medAmmo, loAmmo = hiArrows, medArrows, loArrows 

		if itemType == "Guns" then
			hiAmmo, medAmmo, loAmmo = hiBullets, medBullets, loBullets 
		end

		if UnitClassification("target") == "boss" or UnitClassification("target") == "worldboss" then
		-- (UnitClassification("target") == "elite" and UnitLevel("target") >= 82) or 
			EquipAmmo(hiAmmo, medAmmo, loAmmo)
		else
			EquipAmmo(loAmmo, medAmmo, hiAmmo)
		end
	end
end

caelSmartAmmo:RegisterEvent("PLAYER_TARGET_CHANGED")
caelSmartAmmo:RegisterEvent("UNIT_INVENTORY_CHANGED")