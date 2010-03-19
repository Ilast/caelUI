--[[	$Id$	]]

local _, caelStats = ...

caelStats.lfg = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.lfg:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 10)
caelStats.lfg:SetPoint("CENTER", caelPanel8, "CENTER", -150, 1) 

caelStats.lfgFrame = CreateFrame("Frame", nil, UIParent)
caelStats.lfgFrame:SetAllPoints(caelStats.lfg)
caelStats.lfgFrame:EnableMouse(true)
caelStats.lfgFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
caelStats.lfgFrame:RegisterEvent("LFG_UPDATE")
caelStats.lfgFrame:RegisterEvent("UPDATE_LFG_LIST")
caelStats.lfgFrame:RegisterEvent("LFG_PROPOSAL_UPDATE")
caelStats.lfgFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
caelStats.lfgFrame:RegisterEvent("LFG_ROLE_CHECK_UPDATE")
caelStats.lfgFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelStats.lfgFrame:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")

local red, green = "AF5050", "559655"

caelStats.lfgFrame:SetScript("OnEvent", function(self, event)
	MiniMapLFGFrame:UnregisterAllEvents()
	MiniMapLFGFrame:Hide()
	MiniMapLFGFrame.Show = function() end

	local hasData, _, tankNeeds, healerNeeds, dpsNeeds, _, _, _, _, _, _, myWait = GetLFGQueueStats()

	local mode, _ = GetLFGMode()

	if mode == "listed" then
		caelStats.lfg:SetText("|cffD7BEA5LFR|r")
		return
	elseif mode == "queued" and not hasData then
		caelStats.lfg:SetText("|cffD7BEA5LFG|r Searching")
		return
	elseif not hasData then
		caelStats.lfg:SetText("|cffD7BEA5LFG|r Standby")
		return
	end

	caelStats.lfg:SetText(
		string.format("|cffD7BEA5LFG |r %s%s%s%s%s %s",
			string.format("|cff%s%s|r", tankNeeds == 0 and green or red, "T"),
			string.format("|cff%s%s|r", healerNeeds == 0 and green or red, "H"),
			string.format("|cff%s%s|r", dpsNeeds == 3 and red or green, "D"),
			string.format("|cff%s%s|r", dpsNeeds >= 2 and red or green, "D"),
			string.format("|cff%s%s|r", dpsNeeds >= 1 and red or green, "D"),
			(myWait ~= -1 and SecondsToTime(myWait, false, false, 1) or "|cffD7BEA5Unknown|r")
		)
	)
end)

caelStats.lfgFrame:SetScript("OnMouseDown", function(self, button)
	local mode, _ = GetLFGMode()
	if button == "LeftButton" then
		if mode == "listed" then
			ToggleLFRParentFrame()
		else
			ToggleLFDParentFrame()
		end
	elseif button == "RightButton" then
		if mode == "proposal" then
			if not LFDDungeonReadyPopup:IsShown() then
				StaticPopupSpecial_Show(LFDDungeonReadyPopup)
				return
			end
		end

		MiniMapLFGFrameDropDown.point = "BOTTOM"
		MiniMapLFGFrameDropDown.relativePoint = "TOP"
		ToggleDropDownMenu(1, nil, MiniMapLFGFrameDropDown, caelStats.lfgFrame, 0, 0)
	end
end)