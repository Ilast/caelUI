cargBags_Caellian = CreateFrame('Frame', 'cargBags_Caellian', UIParent)
cargBags_Caellian:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
cargBags_Caellian:RegisterEvent("ADDON_LOADED")
cargBags_Caellian:RegisterEvent("TRADE_SHOW")
if (cargBags.Handler["Anywhere"]) then cargBags:SetActiveHandler("Anywhere") end

local CatDropDown = CreateFrame("Frame", "CatDropDown", UIParent, "UIDropDownMenuTemplate")

---------------------------------------------
---------------------------------------------
local L = cBcaelL
cBcael_CatInfo = {}
cB_Bags = {}
cB_BagHidden = {}

-- Those are default values only, change them ingame via "/cbcael":
local optDefaults = {
                    AmmoAlwaysHidden = true,
                    scale = 0.75,
                    CompressEmpty = false,
                    SortBags = false,
                    SortBank = false,
                    }

-- Those are internal settings, don't touch them at all:
local defaults =    { 
                    showAmmo = false, 
                    }

local bankOpenState = false

function cargBags_Caellian:LoadDefaults()
	cBcael = cBcael or {}
	for k,v in pairs(defaults) do
		if(type(cBcael[k]) == 'nil') then cBcael[k] = v end
	end
    cBcaelCfg = cBcaelCfg or {}
	for k,v in pairs(optDefaults) do
		if(type(cBcaelCfg[k]) == 'nil') then cBcaelCfg[k] = v end
	end
end

function cargBags_Caellian:ADDON_LOADED(event, addon)
	if (addon ~= 'cargBags_Caellian') then return end
	self:UnregisterEvent(event)
	self:LoadDefaults()
    if cBcaelCfg.optAmmoAlwaysHidden then cBcael.showAmmo = false end
    UIDropDownMenu_Initialize(CatDropDown, cargBags_Caellian.CatDropDownInit, "MENU")

    -----------------
    -- Frame Spawns
    -----------------

    -- Bank bags
    local t = cargBags:Spawn("cBcael_Bank")
    t:SetFilter(cB_Filters.fBank, true)
    if cBcaelCfg.CompressEmpty then t:SetFilter(cB_Filters.fHideEmpty, true) end
    cB_Bags.bank = t
    
    -- Keyring
    local t = cargBags:Spawn("cBcael_Keyring")
    t:SetFilter(cB_Filters.fKeyring, true)
    t:SetFilter(cB_Filters.fHideEmpty, true)
    cB_Bags.key = t

    -- Soul Shards frame
    local t = cargBags:Spawn("cBcael_Soulshards")
    t:SetFilter(cB_Filters.fSoulShards, true)
    cB_Bags.bagSoul = t

    -- Ammo Frame
    local t = cargBags:Spawn("cBcael_Ammo")
    t:SetFilter(cB_Filters.fAmmo, true)
    cB_Bags.bagAmmo = t

    -- Bagpack and bags
    local t = cargBags:Spawn("cBcael_Bag")
    t:SetFilter(cB_Filters.fBags, true)
    if cBcaelCfg.CompressEmpty then t:SetFilter(cB_Filters.fHideEmpty, true) end
    cB_Bags.main = t

    -----------------------------------------------
    -- Store the anchoring order:
    -- read: "tar" is anchored to "src" in the direction denoted by "dir".
    -----------------------------------------------
    local function CreateAnchorInfo(src,tar,dir)
        tar.AnchorTo = src
        tar.AnchorDir = dir
        if src then
            if not src.AnchorTargets then src.AnchorTargets = {} end
            src.AnchorTargets[tar] = true
        end
    end

    -- Main Anchors:
    CreateAnchorInfo(nil, cB_Bags.main, "Bottom")
    CreateAnchorInfo(nil, cB_Bags.bank, "Bottom")

    cB_Bags.main:SetPoint("RIGHT",UIParent,"RIGHT",-15,175)

    CreateAnchorInfo(cB_Bags.main, cB_Bags.bank, "Left")
    CreateAnchorInfo(cB_Bags.main, cB_Bags.key, "Top")
    CreateAnchorInfo(cB_Bags.main, cB_Bags.bagSoul, "Bottom")
    CreateAnchorInfo(cB_Bags.bagSoul, cB_Bags.bagAmmo, "Bottom")

    -- To toggle containers when entering / leaving a bank
    local bankToggle = CreateFrame"Frame"
    bankToggle:RegisterEvent"BANKFRAME_OPENED"
    bankToggle:RegisterEvent"BANKFRAME_CLOSED"
    bankToggle:SetScript("OnEvent", function(self, event)
        if(event == "BANKFRAME_OPENED") then
            OpenCargBank()
            OpenCargBags()
            bankOpenState = true
        else
            CloseCargBank()
            bankOpenState = false
        end
    end)

    -- Close real bank frame when our bank frame is hidden
    cB_Bags.bank:SetScript("OnHide", CloseBankFrame)

    -- Hide the original bank frame
    BankFrame:UnregisterAllEvents()

    -- Blizzard Replacement Functions
    ToggleBackpack = ToggleCargBags
    ToggleBag = function() ToggleCargBags() end
    OpenAllBags = ToggleCargBags
    CloseAllBags = CloseCargBags
    OpenBackpack = OpenCargBags
    CloseBackpack = CloseCargBags    
end

function cargBags_Caellian:TRADE_SHOW(event)
    OpenCargBags()
end

local function ShowBag(bag) 
    if not cB_BagHidden[bag.Name] then bag:Show() end
end

-- This function is only used inside the layout, so the cargBags-core doesn't care about it
-- It creates the border for glowing process in UpdateButton()
local createGlow = function(button, rarity)
	local glow = button:CreateTexture(nil, "OVERLAY")
	glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	glow:SetBlendMode("ADD")
    glow:SetAlpha((rarity > 1) and .6 or .4)
	glow:SetWidth(65)
	glow:SetHeight(65)
	glow:SetPoint("CENTER", button)
	button.Glow = glow
end

-- The main function for updating an item button,
-- the item-table holds all data known about the item the button is holding, e.g.
--   bagID, slotID, texture, count, locked, quality - from GetContainerItemInfo()
--   link - well, from GetContainerItemLink() ofcourse ;)
--   name, link, rarity, level, minLevel, type, subType, stackCount, equipLoc - from GetItemInfo()
-- if you need cooldown item data, use self:RequestCooldownData()
local UpdateButton = function(self, button, item)
	button.Icon:SetTexture(item.texture)
    if IsAddOnLoaded("Tabard-O-Matic") then
		local slot = button:GetID()
		local link = item.link
		if (link) then
			local itemID = tonumber(link:match("item:(%d+)"))
			local TabardValue = TabardTextures[itemID]
			if TabardValue then Tabard_O_Matic:SetTheButtons(button, TabardValue.ItemName) end
		end
	end	    
	SetItemButtonCount(button, item.count)
	SetItemButtonDesaturated(button, item.locked, 0.5, 0.5, 0.5)

	-- Color the button's border based on the item's rarity / quality!
	if(item.rarity and item.rarity >= 1) then
		if(not button.Glow) then createGlow(button, item.rarity) end
		button.Glow:SetVertexColor(GetItemQualityColor(item.rarity))
		button.Glow:Show()
	else
		if(button.Glow) then button.Glow:Hide() end
	end
end

-- Updates if the item is locked (currently moved by user)
--   bagID, slotID, texture, count, locked, quality - from GetContainerItemInfo()
-- if you need all item data, use self:RequestItemData()
local UpdateButtonLock = function(self, button, item)
	SetItemButtonDesaturated(button, item.locked, 0.5, 0.5, 0.5)
end

-- Updates the item's cooldown
--   cdStart, cdFinish, cdEnable - from GetContainerItemCooldown()
-- if you need all item data, use self:RequestItemData()
local UpdateButtonCooldown = function(self, button, item)
	if(button.Cooldown) then
		CooldownFrame_SetTimer(button.Cooldown, item.cdStart, item.cdFinish, item.cdEnable) 
	end
end

local GetNumFreeSlots = function(bagType)
    local free, max = 0, 0
    if bagType == "bag" then
        for i = 0,4 do
            free = free + cargBags:GetHandler().GetContainerNumFreeSlots(i)
            max = max + cargBags:GetHandler().GetContainerNumSlots(i)
        end
    else
        local containerIDs = {-1,5,6,7,8,9,10,11}
        for _,i in next, containerIDs do    
            free = free + cargBags:GetHandler().GetContainerNumFreeSlots(i)
            max = max + cargBags:GetHandler().GetContainerNumSlots(i)
        end
    end
    return free, max
end

local GetFirstFreeSlot = function(bagtype)
    if bagtype == "bag" then
        for i = 0,4 do
            local t = cargBags:GetHandler().GetContainerNumFreeSlots(i)
            if t > 0 then
                local tNumSlots = cargBags:GetHandler().GetContainerNumSlots(i)
                for j = 1,tNumSlots do
                    local tLink = GetContainerItemLink(i,j)
                    if not tLink then return i,j end
                end
            end
        end
    else
        local containerIDs = {-1,5,6,7,8,9,10,11}
        for _,i in next, containerIDs do
            local t = cargBags:GetHandler().GetContainerNumFreeSlots(i)
            if t > 0 then
                local tNumSlots = cargBags:GetHandler().GetContainerNumSlots(i)
                for j = 1,tNumSlots do
                    local tLink = GetContainerItemLink(i,j)
                    if not tLink then return i,j end
                end
            end
        end    
    end
    return false
end

local function QuickSort(tTable)
    local function QS_int(left,right,t,c)
        if left < right then
            local l, r = left, right
            local pe = t[floor((l+r)/2)][c] -- pivot element
            while l < r do
                while t[l][c] > pe do l = l + 1 end
                while t[r][c] < pe do r = r - 1 end
                if l <= r then
                    local tItem = t[l]
                    t[l] = t[r]
                    t[r] = tItem
                    l = l + 1
                    r = r - 1
                end            
            end
            if left < r then QS_int(left, r, t, c) end
            if right > l then QS_int(l, right, t, c) end
        end
    end

    local function tcount(tTable)
        local n = #tTable
        if (n == 0) then for _ in pairs(tTable) do n = n + 1 end end
        return n
    end

    -- sort by quality first:
    local tNum = tcount(tTable)
    QS_int(1, tNum, tTable, 2)
    
    -- then sort by itemID:
    local s, tQ = 1, 0
    if tTable[1] then tQ = tTable[1][2] end
    for e,v in ipairs(tTable) do
        if (v[2] ~= tQ) or (e >= tNum) then
            local b = (e >= tNum) and (v[2] == tQ)
            QS_int(s, b and e or e-1, tTable, 1)
            s, tQ = e, v[2]
        end        
    end
    return tTable
end

-- The function for positioning the item buttons in the bag object
local UpdateButtonPositions = function(self)
	local col, row = 0, 0
    local yPosOffs = self.Caption and 20 or 0
    local isEmpty = true
    
    local tName = self.Name    
    local tBankBags = string.find(tName, "cBcael_Bank%a+")
    local tBank = tBankBags or (tName == "cBcael_Bank")
    
    local buttonIDs = {}
  	for i, button in self:IterateButtons() do
        local tLink = GetContainerItemLink(button.bagID, button.slotID)
        if tLink then
            local _,_,tStr = string.find(tLink, "^|c%x+|H(.+)|h%[.*%]")
            local _,tID = strsplit(":", tStr)
            local _,_,tQ = GetItemInfo(tLink)
            buttonIDs[i] = { tonumber(tID), tQ, button }
        else
            buttonIDs[i] = { 0, -2, button }
        end
    end
    if (tBank and cBcaelCfg.SortBank) or (not tBank and cBcaelCfg.SortBags) then buttonIDs = QuickSort(buttonIDs) end
    
	for _,v in ipairs(buttonIDs) do
        local button = v[3]
		button:ClearAllPoints()
      
        local xPos = col * 38
        local yPos = (-1 * row * 38) - yPosOffs

        button:SetPoint("TOPLEFT", self, "TOPLEFT", xPos, yPos)
        if(col >= self.Columns-1) then
            col = 0
            row = row + 1
        else
            col = col + 1
        end
        isEmpty = false
    end

    if cBcaelCfg.CompressEmpty then
        local xPos = col * 38
        local yPos = (-1 * row * 38) - yPosOffs

        local tDrop = self.DropTarget
        if tDrop then
            tDrop:ClearAllPoints()
            tDrop:SetPoint("TOPLEFT", self, "TOPLEFT", xPos, yPos)
            if(col >= self.Columns-1) then
                col = 0
                row = row + 1
            else
                col = col + 1
            end
        end
        
        cB_Bags.main.EmptySlotCounter:SetText(GetNumFreeSlots("bag"))
        cB_Bags.bank.EmptySlotCounter:SetText(GetNumFreeSlots("bank"))
    end
    
	-- This variable stores the size of the item button container
	self.ContainerHeight = (row + (col>0 and 1 or 0)) * 38

	if (self.UpdateDimensions) then self:UpdateDimensions() end -- Update the bag's height
    local t = (tName == "cBcael_Bag") or (tName == "cBcael_Bank") or (tName == "cBcael_Keyring")
    if (not tBankBags and cB_Bags.main:IsShown() and not t) or (tBankBags and cB_Bags.bank:IsShown()) then 
        if isEmpty then self:Hide() else self:Show() end 
    end

    cB_BagHidden[tName] = (not t) and isEmpty or false
    cargBags_Caellian:UpdateAnchors(self)
    collectgarbage("collect")
end

-- Function is called after a button was added to an object
-- We color the borders of the button to see if it is an ammo bag or else
-- Please note that the buttons are in most cases recycled and not new created
local PostAddButton = function(self, button, bag)
	if(not button.NormalTexture) then return end

	local bagType = cargBags.Bags[button.bagID].bagType
	if(button.bagID == KEYRING_CONTAINER) then
		button.NormalTexture:SetVertexColor(.71,.43,.27)	-- Key ring
	elseif(bagType and bagType > 0 and bagType < 8) then
		button.NormalTexture:SetVertexColor(.65,.63,.35)		-- Ammo bag
	elseif(bagType and bagType > 4) then
		button.NormalTexture:SetVertexColor(.33,.59,.33)		-- Profession bags
	else
		button.NormalTexture:SetVertexColor(1, 1, 1)		-- Normal bags
	end
    
    button:SetScript('OnMouseUp', function(self, mouseButton)
        if (mouseButton == 'RightButton') and (IsAltKeyDown()) then
            local tLink = GetContainerItemLink(button.bagID, button.slotID)
            if tLink then 
                local tName = GetItemInfo(tLink) 
                CatDropDown.item = tName
                ToggleDropDownMenu(1, nil, CatDropDown, button, 0, 0)
            end
        end
    end)
end

local function PostSetPlayer() OpenCargBank() end

-- More slot buttons -> more space!
local UpdateDimensions = function(self)
	local height = 0			-- Normal margin space
	if self.BagBar and self.BagBar:IsShown() then
		height = height + 43	-- Bag button space
	end
	if self.Space then
		height = height + 16	-- additional info display space
	end
	if self.Money or self.bagToggle then
		height = height + 24
	end
	if self.Caption then	    -- Space for captions
		height = height + 20
	end
	self:SetHeight(self.ContainerHeight + height)
end

local function createTextButton(name, parent, width, height)
	local button = CreateFrame("Button", nil, parent)
	button:SetNormalFontObject(GameFontHighlightSmall)
	button:SetText(name)
	button:SetWidth(width)
	button:SetHeight(height)
	button:SetScript("OnEnter", buttonEnter)
	button:SetScript("OnLeave", buttonLeave)
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	button:SetBackdrop{
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		edgeFile = [=[Interface\Addons\cargBags_Caellian\media\glowTex]=], edgeSize = 2,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	button:SetBackdropColor(0, 0, 0)
	button:SetBackdropBorderColor(0, 0, 0)
	return button
end

-- Style of the bag and its contents
local func = function(settings, self, type)
    local tName = self.Name
    local tBag, tBank, tKey = (tName == "cBcael_Bag"), (tName == "cBcael_Bank"), (tName == "cBcael_Keyring")
    local tBankBags = string.find(tName, "cBcael_Bank")
	self:EnableMouse(true)

	self.UpdateDimensions = UpdateDimensions
	self.UpdateButtonPositions = UpdateButtonPositions
	self.UpdateButton = UpdateButton
	self.UpdateButtonLock = UpdateButtonLock
	self.UpdateButtonCooldown = UpdateButtonCooldown
	self.PostAddButton = PostAddButton
    cargBags:GetHandler().PostSetPlayer = PostSetPlayer
    
	self:SetFrameStrata("HIGH")
	tinsert(UISpecialFrames, self:GetName()) -- Close on "Esc"

   self.Columns = 10
	self.ContainerHeight = 0
	self:UpdateDimensions()
	self:SetWidth(38*self.Columns)

	-- The frame background
	local background = CreateFrame("Frame", nil, self)
	background:SetBackdrop{
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		edgeFile = [=[Interface\Addons\cargBags_Caellian\media\glowTex]=], edgeSize = 2,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}

	background:SetFrameStrata("HIGH")
   background:SetFrameLevel(1)
	background:SetBackdropColor(0, 0, 0, 0.5)
	background:SetBackdropBorderColor(0, 0, 0)

	background:SetPoint("TOPLEFT", -6, 6)
	background:SetPoint("BOTTOMRIGHT", 6, -6)

	local gradient = background:CreateTexture(nil, "BORDER")
	gradient:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	gradient:SetPoint("TOP", background, 0, -2)
	gradient:SetPoint("LEFT", background, 2, 0)
	gradient:SetPoint("RIGHT", background, -2, 0)
	gradient:SetPoint("BOTTOM", background, 0, 2)
	gradient:SetBlendMode("ADD")
	gradient:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0.55, 0.57, 0.61, 0.25)

	-- Caption and close button
	local caption = background:CreateFontString(background, "OVERLAY", "GameFontNormal")
	if(caption) then
		local t = L.bagCaptions[self.Name]
		if not t then t = self.Name end
		caption:SetText(t)
		caption:SetPoint("TOPLEFT", 8, -6)
		self.Caption = caption
        
        if tBag or tBank then
            local close = CreateFrame("Button", nil, self, "UIPanelCloseButton")
            close:SetPoint("TOPRIGHT", 5, 8)
            if tBank then
                close:SetScript("OnClick", function(self) self:GetParent():Hide() end)
            else
                close:SetScript("OnClick", function(self) CloseCargBags() end)
            end
        end
	end

    local tBtnOffs = 0
  	if tBag or tBank then
		-- The money display
        if tBag then
            local money = self:SpawnPlugin("Money")
            if money then money:SetPoint("BOTTOMLEFT", self, 0, 4) end
            self.anywhere = self:SpawnPlugin("Anywhere")
            if self.anywhere then 
                self.anywhere:SetPoint("TOPRIGHT", self, -20, 4)
                tBtnOffs = 20
            end
        end

		 -- Bag bar for changing bags
		local bagType = tBag and "bags" or "bank"
		local bagButtons = self:SpawnPlugin("BagBar", bagType)
		if(bagButtons) then
			bagButtons:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 23)
			bagButtons:Hide()

			-- main window gets a fake bag button for toggling key ring
			if tBag then
				local keytoggle = bagButtons:CreateKeyRingButton()
				keytoggle:SetScript("OnClick", function()
					if cBcael_Keyring:IsShown() then
						cBcael_Keyring:Hide()
						keytoggle:SetChecked(0)
					else
						cBcael_Keyring:Show()
						keytoggle:SetChecked(1)
					end
				end)
			end
		end
        self.bagButtons = bagButtons
		
		-- We don't need the bag bar every time, so let's create a toggle button for them to show
        self.bagToggle = createTextButton("Bags", self, 40, 20)
        self.bagToggle:SetPoint("BOTTOMRIGHT", self,"BOTTOMRIGHT",0,0)
        self.bagToggle:SetScript("OnClick", function()
			if(self.BagBar:IsShown()) then self.BagBar:Hide() else self.BagBar:Show() end
			self:UpdateDimensions()
		end)

        if tBag then
            -- Button to toggle Ammo/Shard bag:
            local AmmoBtn = createTextButton("A/S", self, 35, 20)
            AmmoBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
            AmmoBtn:SetScript("OnClick", function() 
                if not cBcael.showAmmo then
                    cBcael.showAmmo = true
                    ShowBag(cB_Bags.bagSoul)
                    ShowBag(cB_Bags.bagAmmo)
                else 
                    cBcael.showAmmo = false
                    cB_Bags.bagSoul:Hide()
                    cB_Bags.bagAmmo:Hide()                
                end
            end)
            
            -- Button to open bank when Anywhere is active:
            if self.anywhere then
                local BankBtn = createTextButton("Bank", self, 45, 20)
                BankBtn:SetPoint("RIGHT", AmmoBtn, "LEFT")
                BankBtn:SetScript("OnClick", function() ToggleCargBank() end)
            end
        end        
    end

	-- For purchasing bank slots
	if tBank then
		local purchase = self:SpawnPlugin("Purchase")
		if(purchase) then
			purchase:SetText(BANKSLOTPURCHASE)
			purchase:SetPoint("TOPLEFT", self.bagButtons, "BOTTOMLEFT", 0, -2)
			if(self.BagBar) then purchase:SetParent(self.BagBar) end

			purchase.Cost = self:SpawnPlugin("Money", "static")
			purchase.Cost:SetParent(purchase)
			purchase.Cost:SetPoint("LEFT", purchase, "RIGHT", 4, 0)
		end
	end

    -- Item drop target
    if cBcaelCfg.CompressEmpty and (tBag or tBank) then
        self.DropTarget = CreateFrame("Button", nil, self, "ItemButtonTemplate")
        self.DropTarget:SetWidth(37)
        self.DropTarget:SetHeight(37)
        
        local DropTargetProcessItem = function()
            if CursorHasItem() then
                local bID, sID = GetFirstFreeSlot(tBag and "bag" or "bank")
                if bID then PickupContainerItem(bID, sID) end
            end
        end
        self.DropTarget:SetScript("OnMouseUp", DropTargetProcessItem)
        self.DropTarget:SetScript("OnReceiveDrag", DropTargetProcessItem)
        
        local fs = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetShadowColor(0,0,0)
        fs:SetShadowOffset(0.8, -0.8)
        fs:SetTextColor(1,1,1)
        fs:SetJustifyH("LEFT")
        fs:SetPoint("BOTTOMRIGHT", self.DropTarget, "BOTTOMRIGHT", -5, 3)
        self.EmptySlotCounter = fs
    end
    
	self:SetScale(cBcaelCfg.scale)
	return self
end

cargBags:RegisterStyle("Caellian", setmetatable({}, {__call = func}))

-- Opening / Closing Functions
function cargBags_Caellian:UpdateAnchors(self)
    if not self.AnchorTargets then return end
    for v,_ in pairs(self.AnchorTargets) do
        local t, u = v.AnchorTo, v.AnchorDir
        if t then
            local h = cB_BagHidden[t.Name]
            v:ClearAllPoints()
            if      not h   and u == "Top"      then v:SetPoint("BOTTOM", t, "TOP", 0, 15)
            elseif  h       and u == "Top"      then v:SetPoint("BOTTOM", t, "BOTTOM")
            elseif  not h   and u == "Bottom"   then v:SetPoint("TOP", t, "BOTTOM", 0, -15)
            elseif  h       and u == "Bottom"   then v:SetPoint("TOP", t, "TOP")
            elseif u == "Left" then v:SetPoint("TOPRIGHT", t, "TOPLEFT", -15, 0)
            elseif u == "Right" then v:SetPoint("TOPLEFT", t, "TOPRIGHT", 15, 0) end
        end
    end
end

function OpenCargBags()
    cB_Bags.main:Show()
    if cBcael.showAmmo and not cBcaelCfg.AmmoAlwaysHidden then
        ShowBag(cB_Bags.bagSoul)
        ShowBag(cB_Bags.bagAmmo)
    end
end

function CloseCargBags()
	cB_Bags.main:Hide()
	cB_Bags.key:Hide()
    cB_Bags.bagSoul:Hide()
    cB_Bags.bagAmmo:Hide()
    if cBcaelCfg.AmmoAlwaysHidden then cBcael.showAmmo = false end
end

function ToggleCargBags(forceopen)
	if (cB_Bags.main:IsShown() and not forceopen) then CloseCargBags() else OpenCargBags() end
end

function OpenCargBank()
    cB_Bags.bank:Show()
end

function CloseCargBank()
    cB_Bags.bank:Hide()
end

function ToggleCargBank()
	if cB_Bags.bank:IsShown() then CloseCargBank() else OpenCargBank() end
end

local function StatusMsg(str1, str2, data, name, short)
    local R,G,t = '|cFFFF0000', '|cFF00FF00', ''
    if (data ~= nil) then t = data and G..(short and 'on|r' or 'enabled|r') or R..(short and 'off|r' or 'disabled|r') end
    if name then t = '|cFFFFFF00cargBags_Caellian:|r '..str1..t..str2 else t = str1..t..str2 end
    ChatFrame1:AddMessage(t)
end

local function StatusMsgVal(str1, str2, data, name)
    local G,t = '|cFF00FF00', ''
    if (data ~= nil) then t = G..data..'|r' end
    if name then t = '|cFFFFFF00cargBags_Caellian:|r '..str1..t..str2 else t = str1..t..str2 end
    ChatFrame1:AddMessage(t)
end

function cargBags_Caellian:CatDropDownInit()
    level = 1
    local info = UIDropDownMenu_CreateInfo()
  
    local function AddInfoItem(caption)
        local t = L.bagCaptions[caption]
        info.text = t and t or caption
        info.value = caption
        info.func = function() cargBags_Caellian:CatDropDownOnClick() end
        info.owner = this:GetParent()
        UIDropDownMenu_AddButton(info, level)
    end

    AddInfoItem("cBcael_Ammo")
    AddInfoItem("cBcael_Bag")
end

function cargBags_Caellian:CatDropDownOnClick()
    local value = this.value
    local item = CatDropDown.item
    cBcael_CatInfo[item] = value
    cargBags:UpdateBags()
end