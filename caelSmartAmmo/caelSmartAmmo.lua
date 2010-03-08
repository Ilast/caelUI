--[[	$Id$	]]

if select(2, UnitClass("player")) ~= "HUNTER" then
	print("|cffD7BEA5cael|rSmartAmmo: You are not a Hunter, caelSmartAmmo will be disabled on next UI reload.")
	return DisableAddOn("caelSmartAmmo")
end

local _, caelSmartAmmo = ...

caelSmartAmmo.eventFrame = CreateFrame("Frame", nil, UIParent)

local hiBullets, medBullets, loBullets, vloBullets = 52020, 41164, 31735, 41584 -- Shatter Rounds, Mammoth Cutters, Timeless Shell, Frostbite Bullets
local hiArrows, medArrows, loArrows, vloArrows = 52021, 41165, 31737, 41586 -- Iceblade Arrow, Saronite Razorheads, Timeless Arrow, Terrorshaft Arrow

local EquipAmmo = function(primary, secondary, tertiary, fallback)
	local itemid
	if GetItemCount(primary) > 0 then
		itemid = primary
	elseif GetItemCount(secondary) > 0 then
		itemid = secondary
	elseif GetItemCount(tertiary) > 0 then
		itemid = tertiary
	elseif GetItemCount(fallback) > 0 then
		itemid = fallback
	else
		return
	end

	local link = GetInventoryItemLink("player", 0)
	if link and not link:match("item:"..tostring(itemid)..":") then
		EquipItemByName(itemid)
	end
end

local AmmosSwitch = function(self)
--	if not UnitCanAttack("player", "target") or UnitIsDead("target") then return end

	local rangedWeapon = GetInventoryItemLink("player", GetInventorySlotInfo("RangedSlot"))
	if rangedWeapon then
		local _, _, _, _, _, _, itemType = GetItemInfo(rangedWeapon)

		local hiAmmo, medAmmo, loAmmo, vloAmmo = hiArrows, medArrows, loArrows, vloArrows

		if itemType == "Guns" then
			hiAmmo, medAmmo, loAmmo, vloAmmo = hiBullets, medBullets, loBullets, vloBullets
		end
--[[
		if UnitClassification("target") == "boss" or UnitClassification("target") == "worldboss" then
		-- (UnitClassification("target") == "elite" and UnitLevel("target") >= 82) or 
			EquipAmmo(hiAmmo, medAmmo, loAmmo, vloAmmo)
		else
			EquipAmmo(vloAmmo, loAmmo, medAmmo, hiAmmo)
		end
--]]
		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			local _, instanceType = IsInInstance()
			if instanceType == "raid" then
				EquipAmmo(hiAmmo, medAmmo, loAmmo, vloAmmo)
			else
				EquipAmmo(vloAmmo, loAmmo, medAmmo, hiAmmo)
			end
		end
	end
end

caelSmartAmmo.eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
caelSmartAmmo.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelSmartAmmo.eventFrame:SetScript("OnEvent", AmmosSwitch)