--[[	$Id$	]]

local _, caelCCBreak = ...

caelCCBreak.eventFrame = CreateFrame("Frame", nil, UIParent)

--local msg = "|cffD7BEA5%s|r on |cffAF5050%s|r broken by |cff559655%s|r%s"
local msg = "|cffD7BEA5%s|r broken by |cff559655%s|r"

local hostile = COMBATLOG_OBJECT_REACTION_HOSTILE or 64 or 0x00000040

local getName = function(id)
	return GetSpellInfo(id)
end

local spells = {
	getName(118), -- Polymorph (rank 1)
	getName(12824), -- Polymorph (rank 2)
	getName(12825), -- Polymorph (rank 3)
	getName(12826), -- Polymorph (rank 4)
	getName(28272), -- Polymorph (pig)
	getName(28271), -- Polymorph (turtle)
	getName(59634), -- Polymorph (penguin)
	getName(61025), -- Polymorph (Serpent)
	getName(61305), -- Polymorph (black cat)
	getName(61721), -- Polymorph (rabbit)
	getName(61780), -- Polymorph (turkey)

	getName(9484), -- Shackle Undead (rank 1)
	getName(9485), -- Shackle Undead (rank 2)
	getName(10955), -- Shackle Undead (rank 3)

	getName(3355), -- Freezing Trap Effect (rank 1)
	getName(14308), -- Freezing Trap Effect (rank 2)
	getName(14309), -- Freezing Trap Effect (rank 3)
	getName(60210), -- Freezing Arrow Effect (rank 1)

	getName(2637), -- Hibernate (rank 1)
	getName(18657), -- Hibernate (rank 2)
	getName(18658), -- Hibernate (rank 3)

	getName(6770), -- Sap (rank 1)
	getName(2070), -- Sap (rank 2)
	getName(11297), -- Sap (rank 3)
	getName(51724), -- Sap (rank 4)

	getName(45524), -- Chains of Ice
	getName(49203), -- Hungering Cold (rank 1)

	getName(6358), -- Seduction (succubus)

	getName(20066), -- Repentance
	getName(51514), -- Hex
}

caelCCBreak.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
caelCCBreak.eventFrame:SetScript("OnEvent", function(_, _, _, subEvent, _, sourceName, _, _, destName, destFlags, _, spellName, _, _, extraSkillName, ...)
	if subEvent == "SPELL_AURA_BROKEN_SPELL" or subEvent == "SPELL_AURA_BROKEN" then
		if bit.band(destFlags, hostile) == hostile then
			for k, v in pairs(spells) do
				if v == spellName then
--					DEFAULT_CHAT_FRAME:AddMessage(msg:format(spellName, destName, sourceName and sourceName or "Unknown", extraSkillName and "'s "..extraSkillName or ""))
					DEFAULT_CHAT_FRAME:AddMessage(msg:format(spellName, sourceName and sourceName or "Unknown"))
					break
				end
			end
		end
	end
end)