local L = cBcaelL
cB_Filters = {}

--------------------
--General filters
--------------------

-- Bag filter
cB_Filters.fBags = function(item) return item.bagID >= 0 and item.bagID <= 4 end
--Keyring filter
cB_Filters.fKeyring = function(item) return item.bagID == -2 end
-- Bank filter
cB_Filters.fBank = function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 end
cB_Filters.fBankFilter = function() return cBcaelCfg.FilterBank end

----------------
-- Bag filters
----------------

-- Hide unused slots
cB_Filters.fHideEmpty = function(item) return item.link ~= nil end

-- Soul shard filter
cB_Filters.fSoulShards = function(item)
    local t = false
    local bagType = GetItemFamily(GetBagName(item.bagID))
    if bagType then
        if (bagType == 4) then t = true end
    end
    if item.name == L.SoulShard then t = true end
    return t
end

-- Ammo filter
cB_Filters.fAmmo = function(item) 
    local tC = cBcael_CatInfo[item.name]
    if tC then return (tC == "cBcael_Ammo") and true or false end
    local t = false
    local bagType = GetItemFamily(GetBagName(item.bagID))
    if bagType then 
        if (bagType >= 1 and bagType <= 3) then t = true end
    end
    if (item.type == L.Arrow) or (item.type == L.Bullet) then t = true end
    return t
end