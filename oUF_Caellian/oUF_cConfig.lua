--[[	$Id$	]]

local _, oUF_Caellian = ...

Caellian = {oUF = {

noPlayerAuras = false, -- true to disable oUF buffs/debuffs on the player frame and enable default
noPetAuras = false, -- true to disable oUF buffs/debuffs on the pet frame
noTargetAuras = false, -- true to disable oUF buffs/debuffs on the target frame
noToTAuras = false, -- true to disable oUF buffs/debuffs on the ToT frame
noArena = false, -- true to disable arena frames
noParty = false, -- true to disable party frames
noRaid = false, -- true to disable raid frames

font = caelMedia.fonts.NORMAL,

scale = 1, -- scale of the unitframes (1 being 100%)

lowThreshold = 20, -- low mana threshold for all mana classes
highThreshold = 80, -- high mana treshold for hunters

noClassDebuffs = false, -- true to show all debuffs

coords = {
	playerX = -278.5, -- horizontal offset for the player block frames
	playerY = 269.5, -- vertical offset for the player block frames

	targetX = 278.5, -- horizontal offset for the target block frames
	targetY = 269.5, -- vertical offset for the target block frames

	arenaX = -15, -- horizontal offset for the arena frames
	arenaY = -15, -- vertical offset for the arena frames

	partyX = 15, -- horizontal offset for the party frames
	partyY = -15, -- vertical offset for the party frames

	raidX = 15, -- horizontal offset for the raid frames
	raidY = -15, -- vertical offset for the raid frames
}}}