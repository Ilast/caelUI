local _, caelStats = ...

local Holder = CreateFrame("Frame")

caelStats.lfg = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.lfg:SetFontObject(neuropolrg10)
caelStats.lfg:SetPoint("CENTER", caelPanel8, "CENTER", -150, 1) 

local red, green = "AF5050", "559655"

local OnEvent = function(self)
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
end

local OnClick = function(self, button)
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

		MiniMapLFGFrameDropDown.point = "BOTTOMLEFT"
		MiniMapLFGFrameDropDown.relativePoint = "TOPRIGHT"
		ToggleDropDownMenu(1, nil, MiniMapLFGFrameDropDown, Holder, 0, 0)
	end
end

Holder:EnableMouse(true)
Holder:SetAllPoints(caelStats.lfg)
Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
Holder:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
Holder:RegisterEvent("LFG_UPDATE")
Holder:RegisterEvent("UPDATE_LFG_LIST")
Holder:RegisterEvent("LFG_ROLE_CHECK_UPDATE")
Holder:RegisterEvent("LFG_PROPOSAL_UPDATE")
Holder:RegisterEvent("PARTY_MEMBERS_CHANGED")
Holder:SetScript("OnEvent", OnEvent)
Holder:SetScript("OnMouseDown", OnClick)