--[[	$Id$	]]

local _, caelDataFeeds = ...

caelDataFeeds.lfg = caelDataFeeds.createModule("LFG")

local lfg = caelDataFeeds.lfg

lfg.text:SetPoint("CENTER", caelPanel8, "CENTER", caelLib.scale(-150), caelLib.scale(1))

lfg:RegisterEvent("LFG_UPDATE")
lfg:RegisterEvent("UPDATE_LFG_LIST")
lfg:RegisterEvent("LFG_PROPOSAL_UPDATE")
lfg:RegisterEvent("PARTY_MEMBERS_CHANGED")
lfg:RegisterEvent("LFG_ROLE_CHECK_UPDATE")
lfg:RegisterEvent("PLAYER_ENTERING_WORLD")
lfg:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")

local red, green = "AF5050", "559655"

lfg:SetScript("OnEvent", function(self, event)
	MiniMapLFGFrame:UnregisterAllEvents()
	MiniMapLFGFrame:Hide()
	MiniMapLFGFrame.Show = function() end

	local hasData, _, tankNeeds, healerNeeds, dpsNeeds, _, _, _, _, _, _, myWait = GetLFGQueueStats()

	local mode, _ = GetLFGMode()

	if mode == "listed" then
		self.text:SetText("|cffD7BEA5LFR|r")
		return
	elseif mode == "queued" and not hasData then
		self.text:SetText("|cffD7BEA5lfg|r Searching")
		return
	elseif not hasData then
		self.text:SetText("|cffD7BEA5lfg|r Standby")
		return
	end

	self.text:SetText(
		string.format("|cffD7BEA5lfg |r %s%s%s%s%s %s",
			string.format("|cff%s%s|r", tankNeeds == 0 and green or red, "T"),
			string.format("|cff%s%s|r", healerNeeds == 0 and green or red, "H"),
			string.format("|cff%s%s|r", dpsNeeds == 3 and red or green, "D"),
			string.format("|cff%s%s|r", dpsNeeds >= 2 and red or green, "D"),
			string.format("|cff%s%s|r", dpsNeeds >= 1 and red or green, "D"),
			(myWait ~= -1 and SecondsToTime(myWait, false, false, 1) or "|cffD7BEA5Unknown|r")
		)
	)
end)

lfg:SetScript("OnMouseDown", function(self, button)
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
		ToggleDropDownMenu(1, nil, MiniMapLFGFrameDropDown, lfg, 0, 0)
	end
end)