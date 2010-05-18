--[[	$Id$	]]

--[[	Some new slash commands	]]

SlashCmdList["FRAMENAME"] = function() print(GetMouseFocus():GetName()) end
SlashCmdList["PARENT"] = function() print(GetMouseFocus():GetParent():GetName()) end
SlashCmdList["MASTER"] = function() ToggleHelpFrame() end
SlashCmdList["RELOAD"] = function() ReloadUI() end
SlashCmdList["ENABLE_ADDON"] = function(s) EnableAddOn(s) end
SlashCmdList["DISABLE_ADDON"] = function(s) DisableAddOn(s) end
SlashCmdList["CLFIX"] = function() CombatLogClearEntries() end

SLASH_FRAMENAME1 = "/frame"
SLASH_PARENT1 = "/parent"
SLASH_MASTER1 = "/gm"
SLASH_RELOAD1 = "/rl"
SLASH_ENABLE_ADDON1 = "/en"
SLASH_DISABLE_ADDON1 = "/dis"
SLASH_CLFIX1 = "/clfix"