----
-- Add previous "hacks" from old caelActionBars
----
local mouseOverPetBar = 1

local _G = getfenv(0)

function caelActionBars_OnLoad(self)
  self:RegisterEvent("PLAYER_ENTERING_WORLD");
}

function caelActionBars_Initialize()
	local FramesToHide = {
		MainMenuBar,
		VehicleMenuBar,

		CharacterMicroButton,
		SpellbookMicroButton,
		TalentMicroButton,
		AchievementMicroButton,
		QuestLogMicroButton,
		SocialsMicroButton,
		PVPMicroButton,
		LFGMicroButton,
		MainMenuMicroButton,
		HelpMicroButton,
	}

	-- Remove BonusActionBar Frame Textures
	for i = 1, BONUSACTIONBAR_NUM_TEXTURES do
		_G["BonusActionBarFrameTexture" .. i]:Hide();
	end

	-- Remove Default frames.
	for _, frame in pairs(FramesToHide) do
		frame:SetScale(0.01)
		frame:SetAlpha(0)
	end

	SetActionBarToggles(true, true, true, false, ALWAYS_SHOW_MULTIBARS)
	MultiActionBars_Update()
	UIParent_ManageFramePositions()

	Actionbutton_HideGrid = function() end

	for i = 1, 12 do
		local button = _G["ActionButton" .. i]
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)

		button = _G["BonusActionButton" .. i]
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)
	end
end

function caelActionBars_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		caelActionBars_Initialize()
	end
end

--[[
-- New MultiActionBars.lua
NUM_MULTIBAR_BUTTONS = 12;

function MultiActionBarFrame_OnLoad (self)
	-- Hack no longer needed here.
	-- This is where i will load the actionbar states
end

function MultiActionButtonDown (bar, id)
	local button = _G[bar.."Button"..id];
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
end

function MultiActionButtonUp (bar, id)
	local button = _G[bar.."Button"..id];
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		SecureActionButton_OnClick(button, "LeftButton");
		ActionButton_UpdateState(button);
	end
end

function MultiActionBar_Update ()
	if ( SHOW_MULTI_ACTIONBAR_1 and MainMenuBar.state=="player" ) then
		MultiBar1:Show();
		MultiBar1.isShowing = 1;
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMLEFT_ACTIONBAR_PAGE] = nil;
	else
		MultiBar1:Hide();
		MultiBar1.isShowing = nil;
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMLEFT_ACTIONBAR_PAGE] = 1;
	end
	if ( SHOW_MULTI_ACTIONBAR_2 and MainMenuBar.state=="player") then
		MultiBarBottomRight:Show();
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMRIGHT_ACTIONBAR_PAGE] = nil;
	else
		MultiBarBottomRight:Hide();
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMRIGHT_ACTIONBAR_PAGE] = 1;
	end
	if ( SHOW_MULTI_ACTIONBAR_3 and MainMenuBar.state=="player") then
		MultiBarRight:Show();
		VIEWABLE_ACTION_BAR_PAGES[RIGHT_ACTIONBAR_PAGE] = nil;
	else
		MultiBarRight:Hide();
		VIEWABLE_ACTION_BAR_PAGES[RIGHT_ACTIONBAR_PAGE] = 1;
	end
	if ( SHOW_MULTI_ACTIONBAR_3 and SHOW_MULTI_ACTIONBAR_4 and MainMenuBar.state=="player") then
		MultiBarLeft:Show();
		VIEWABLE_ACTION_BAR_PAGES[LEFT_ACTIONBAR_PAGE] = nil;
	else
		MultiBarLeft:Hide();
		VIEWABLE_ACTION_BAR_PAGES[LEFT_ACTIONBAR_PAGE] = 1;
	end
	
	--Adjust VehicleSeatIndicator position
	if ( VehicleSeatIndicator ) then
		if ( SHOW_MULTI_ACTIONBAR_3 and SHOW_MULTI_ACTIONBAR_4 ) then
			VehicleSeatIndicator:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -100, -13);
		elseif ( SHOW_MULTI_ACTIONBAR_3 ) then
			VehicleSeatIndicator:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -62, -13);
		else
			VehicleSeatIndicator:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", 0, -13);
		end
	end
end

function MultiActionBar_ShowAllGrids ()
	MultiActionBar_UpdateGrid("MultiBar1", true);
	MultiActionBar_UpdateGrid("MultiBarBottomRight", true);
	MultiActionBar_UpdateGrid("MultiBarRight", true);
	MultiActionBar_UpdateGrid("MultiBarLeft", true);
end

function MultiActionBar_HideAllGrids ()
	MultiActionBar_UpdateGrid("MultiBar1", false);
	MultiActionBar_UpdateGrid("MultiBarBottomRight", false);
	MultiActionBar_UpdateGrid("MultiBarRight", false);
	MultiActionBar_UpdateGrid("MultiBarLeft", false);
end

function MultiActionBar_UpdateGrid (barName, show)
	for i=1, NUM_MULTIBAR_BUTTONS do
		if ( show ) then
			ActionButton_ShowGrid(_G[barName.."Button"..i]);
		else
			ActionButton_HideGrid(_G[barName.."Button"..i]);
		end
	end
end

function MultiActionBar_UpdateGridVisibility ()
	if ( ALWAYS_SHOW_MULTIBARS == "1" or ALWAYS_SHOW_MULTIBARS == 1 ) then
		MultiActionBar_ShowAllGrids();
	else
		MultiActionBar_HideAllGrids();
	end
end

function Multibar_EmptyFunc (show)
	
end

function MultibarGrid_IsVisible ()
	STATE_AlwaysShowMultibars = ALWAYS_SHOW_MULTIBARS;
	return ALWAYS_SHOW_MULTIBARS;
end

function MultiBar1_IsVisible ()
	STATE_MultiBar1 = SHOW_MULTI_ACTIONBAR_1;
	return SHOW_MULTI_ACTIONBAR_1;
end

function MultiBar2_IsVisible ()
	STATE_MultiBar2 = SHOW_MULTI_ACTIONBAR_2;
	return SHOW_MULTI_ACTIONBAR_2;
end

function MultiBar3_IsVisible ()
	STATE_MultiBar3 = SHOW_MULTI_ACTIONBAR_3;
	return SHOW_MULTI_ACTIONBAR_3;
end

function MultiBar4_IsVisible ()
	STATE_MultiBar4 = SHOW_MULTI_ACTIONBAR_4;
	return SHOW_MULTI_ACTIONBAR_4;
end
]]--
