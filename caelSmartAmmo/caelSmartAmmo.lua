local print = function(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffD7BEA5cael|rSmartAmmo: "..tostring(text))
end

if select(2, UnitClass("player")) ~= "HUNTER" then
	print("You are not a Hunter, caelSmartAmmo will be disabled on next UI reload.")
	return DisableAddOn("caelSmartAmmo")
end

local caelSmartAmmo = CreateFrame("Frame", nil, UIParent)

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

	if not GetInventoryItemLink("player", 0):match("item:"..tostring(itemid)..":") then
		EquipItemByName(itemid)
	end
end

local AmmosSwitch = function(zone)
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
			caelSmartAmmo:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			local _, instanceType = IsInInstance()
			if instanceType == "raid" then
				EquipAmmo(hiAmmo, medAmmo, loAmmo, vloAmmo)
			else
				EquipAmmo(vloAmmo, loAmmo, medAmmo, hiAmmo)
			end
		end
	end
end

caelSmartAmmo.PLAYER_REGEN_ENABLED = function(self)
	return AmmosSwitch(zone)
end

caelSmartAmmo:RegisterEvent("UNIT_INVENTORY_CHANGED")
caelSmartAmmo.UNIT_INVENTORY_CHANGED = function(self)
	return AmmosSwitch(zone)
end

caelSmartAmmo:RegisterEvent("PLAYER_ENTERING_WORLD")
caelSmartAmmo.PLAYER_ENTERING_WORLD = function(self)
	return AmmosSwitch(zone)
end

OnEvent = function(self, event, ...)
	if type(self[event]) == "function" then
		return self[event](self, event, ...)
	else
		print(string.format("Unhandled event: %s", event))
	end
end

caelSmartAmmo:SetScript("OnEvent", OnEvent)
-- caelSmartAmmo:RegisterEvent("PLAYER_TARGET_CHANGED")