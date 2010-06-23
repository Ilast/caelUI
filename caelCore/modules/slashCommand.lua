--[[	$Id$	]]

--[[	Some new slash commands	]]

SlashCmdList["FRAMENAME"] = function() print(GetMouseFocus():GetName()) end
SlashCmdList["PARENT"] = function() print(GetMouseFocus():GetParent():GetName()) end
SlashCmdList["MASTER"] = function() ToggleHelpFrame() end
SlashCmdList["RELOAD"] = function() ReloadUI() end
SlashCmdList["ENABLE_ADDON"] = function(s) EnableAddOn(s) end
SlashCmdList["DISABLE_ADDON"] = function(s) DisableAddOn(s) end
SlashCmdList["CLFIX"] = function() CombatLogClearEntries() end
SlashCmdList["READYCHECK"] = function() DoReadyCheck() end
SlashCmdList["GROUPDISBAND"] = function()
	if UnitInRaid("player") then
		SendChatMessage("Disbanding raid.", "RAID")
		for i = 1, GetNumRaidMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= caelLib.playerName then
				UninviteUnit(name)
			end
		end
	else
		SendChatMessage("Disbanding group.", "PARTY")
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if GetPartyMember(i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end
	LeaveParty()
end

SLASH_FRAMENAME1 = "/frame"
SLASH_PARENT1 = "/parent"
SLASH_MASTER1 = "/gm"
SLASH_RELOAD1 = "/rl"
SLASH_ENABLE_ADDON1 = "/en"
SLASH_DISABLE_ADDON1 = "/dis"
SLASH_CLFIX1 = "/clfix"
SLASH_READYCHECK1 = "/rc"
SLASH_GROUPDISBAND1 = "/radisband"