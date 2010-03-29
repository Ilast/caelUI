--[[	$Id$	]]

local _, caelDataFeeds = ...

caelDataFeeds.lfg, caelDataFeeds.lfgFrame = createModule()

caelDataFeeds.lfg:SetPoint("CENTER", caelPanel8, "CENTER", -150, 1) 

caelDataFeeds.lfgFrame:RegisterEvent("LFG_UPDATE")
caelDataFeeds.lfgFrame:RegisterEvent("UPDATE_LFG_LIST")
caelDataFeeds.lfgFrame:RegisterEvent("LFG_PROPOSAL_UPDATE")
caelDataFeeds.lfgFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
caelDataFeeds.lfgFrame:RegisterEvent("LFG_ROLE_CHECK_UPDATE")
caelDataFeeds.lfgFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelDataFeeds.lfgFrame:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")

local red, green = "AF5050", "559655"

caelDataFeeds.lfgFrame:SetScript("OnEvent", function(self, event)
	MiniMapLFGFrame:UnregisterAllEvents()
	MiniMapLFGFrame:Hide()
	MiniMapLFGFrame.Show = function() end

	local hasData, _, tankNeeds, healerNeeds, dpsNeeds, _, _, _, _, _, _, myWait = GetLFGQueueStats()

	local mode, _ = GetLFGMode()

	if mode == "listed" then
		caelDataFeeds.lfg:SetText("|cffD7BEA5LFR|r")
		return
	elseif mode == "queued" and not hasData then
		caelDataFeeds.lfg:SetText("|cffD7BEA5LFG|r Searching")
		return
	elseif not hasData then
		caelDataFeeds.lfg:SetText("|cffD7BEA5LFG|r Standby")
		return
	end

	caelDataFeeds.lfg:SetText(
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

caelDataFeeds.lfgFrame:SetScript("OnMouseDown", function(self, button)
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
		ToggleDropDownMenu(1, nil, MiniMapLFGFrameDropDown, lfgFrame, 0, 0)
	end
end)