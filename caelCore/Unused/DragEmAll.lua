--[[	$Id: DragEmAll.lua 686 2010-03-19 09:47:09Z sdkyron@gmail.com $	]]

local addon = CreateFrame("Frame")

local frames = {
  -- ["FrameName"] = true (the parent frame should be moved) or false (the frame itself should be moved)
  
  -- Blizzard Frames
  ["SpellBookFrame"] = false,
  ["QuestLogFrame"] = false,
  ["FriendsFrame"] = false,
  ["LFGParentFrame"] = false,
  ["KnowledgeBaseFrame"] = true,
  ["HelpFrame"] = false,
  ["GossipFrame"] = false,
  ["MerchantFrame"] = false,
  ["MailFrame"] = false,
  ["OpenMailFrame"] = false,
  ["GuildRegistrarFrame"] = false,
  ["DressUpFrame"] = false,
  ["TabardFrame"] = false,
  ["TaxiFrame"] = false,
  ["QuestFrame"] = false,
  ["TradeFrame"] = false,
  ["LootFrame"] = false,
  ["PetStableFrame"] = false,
  ["StackSplitFrame"] = false,
  ["PetitionFrame"] = false,
  ["WorldStateScoreFrame"] = false,
  ["BattlefieldFrame"] = false,
  ["ArenaFrame"] = false,
  ["ItemTextFrame"] = false,
  ["GameMenuFrame"] = false,
  ["InterfaceOptionsFrame"] = false,
  ["MacOptionsFrame"] = false,
  ["PetPaperDollFrame"] = true,
  ["PetPaperDollFrameCompanionFrame"] = "CharacterFrame",
  ["PetPaperDollFramePetFrame"] = "CharacterFrame",
  ["PaperDollFrame"] = true,
  ["ReputationFrame"] = true,
  ["SkillFrame"] = true,
  ["PVPFrame"] = true,
  ["PVPBattlegroundFrame"] = true,
  ["SendMailFrame"] = true,
  ["TokenFrame"] = true,
  ["InterfaceOptionsFrame"] = false,
  ["VideoOptionsFrame"] = false,
  ["AudioOptionsFrame"] = false,
  ["BankFrame"] = false,
}

-- Frames provided by load on demand addons, hooked when the addon is loaded.
local lodFrames = {
  -- AddonName = { list of frames, same syntax as above }
  Blizzard_AuctionUI = { ["AuctionFrame"] = false },
  Blizzard_BindingUI = { ["KeyBindingFrame"] = false },
  Blizzard_CraftUI = { ["CraftFrame"] = false },
  Blizzard_GMSurveyUI = { ["GMSurveyFrame"] = false },
  Blizzard_InspectUI = { ["InspectFrame"] = false, ["InspectPVPFrame"] = true, ["InspectTalentFrame"] = true },
  Blizzard_ItemSocketingUI = { ["ItemSocketingFrame"] = false },
  Blizzard_MacroUI = { ["MacroFrame"] = false },
  Blizzard_TalentUI = { ["PlayerTalentFrame"] = false },
  Blizzard_TradeSkillUI = { ["TradeSkillFrame"] = false },
  Blizzard_TrainerUI = { ["ClassTrainerFrame"] = false },
  Blizzard_GuildBankUI = { ["GuildBankFrame"] = false, ["GuildBankEmblemFrame"] = true },
  Blizzard_TimeManager = { ["TimeManagerFrame"] = false },
  Blizzard_AchievementUI = { ["AchievementFrame"] = false, ["AchievementFrameHeader"] = true, ["AchievementFrameCategoriesContainer"] = "AchievementFrame" },
  Blizzard_TokenUI = { ["TokenFrame"] = true },
  Blizzard_ItemSocketingUI = { ["ItemSocketingFrame"] = false },
  Blizzard_GlyphUI = { ["GlyphFrame"] = "PlayerTalentFrame" },
  Blizzard_BarbershopUI = { ["BarberShopFrame"] = false },
  Blizzard_Calendar = { ["CalendarFrame"] = false, ["CalendarCreateEventFrame"] = true },
}

local parentFrame = {}
local hooked = {}

local function print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("DragEmAll: " .. msg)
end

function addon:PLAYER_LOGIN()
  self:HookFrames(frames)
  -- Bugfix for 3.1.0 Battleground frame (wrong anchor)
  if PVPBattlegroundFrameFrameLabel and PVPBattlegroundFrame then
    PVPBattlegroundFrameFrameLabel:ClearAllPoints()
    PVPBattlegroundFrameFrameLabel:SetPoint("TOP", PVPBattlegroundFrame, "TOP", 3, -16)
  end
end

function addon:ADDON_LOADED(name)
  local frameList = lodFrames[name]
  if frameList then
    self:HookFrames(frameList)
  end
end

local function MouseDownHandler(frame, button)
  frame = parentFrame[frame] or frame
  if frame and button == "LeftButton" then
    frame:StartMoving()
    frame:SetUserPlaced(false)
  end
end

local function MouseUpHandler(frame, button)
  frame = parentFrame[frame] or frame
  if frame and button == "LeftButton" then
    frame:StopMovingOrSizing()
  end
end

function addon:HookFrames(list)
  for name, child in pairs(list) do
    self:HookFrame(name, child)
  end
end

function addon:HookFrame(name, moveParent)
  local frame = _G[name]
  local parent
  if frame and not hooked[name] then
    if moveParent then
      if type(moveParent) == "string" then
        parent = _G[moveParent]
      else
        parent = frame:GetParent()
      end
      if not parent then
        print("Parent frame not found: " .. name)
        return
      end
      parentFrame[frame] = parent
    end
    if parent then
      parent:SetMovable(true)
      parent:SetClampedToScreen(false)
    end
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(false)
    self:HookScript(frame, "OnMouseDown", MouseDownHandler)
    self:HookScript(frame, "OnMouseUp", MouseUpHandler)
    hooked[name] = true
  end
end

function addon:HookScript(frame, script, handler)
  local oldHandler = frame:GetScript(script)
  if oldHandler then
    frame:SetScript(script, function(...)
      handler(...)
      oldHandler(...)
    end)
  else
    frame:SetScript(script, handler)
  end
end

addon:SetScript("OnEvent", function(f, e, ...) f[e](f, ...) end)
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("ADDON_LOADED")

-- Hook bag frames
hooksecurefunc("ContainerFrame_GenerateFrame", function(frame, size, id)
  if id <= NUM_BAG_FRAMES or id == KEYRING_CONTAINER then
    addon:HookFrame(frame:GetName())
  end
end)