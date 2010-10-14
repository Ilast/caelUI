--[[	$Id: oUF_cConfig.lua 1428 2010-07-15 10:30:28Z sdkyron@gmail.com $	]]

local _, oUF_Caellian = ...

oUF_Caellian.config = CreateFrame("Frame", nil, UIParent)

local config = oUF_Caellian.config

config.noPlayerAuras = false -- true to disable oUF buffs/debuffs on the player frame and enable default
config.noPetAuras = false -- true to disable oUF buffs/debuffs on the pet frame
config.noTargetAuras = false -- true to disable oUF buffs/debuffs on the target frame
config.noToTAuras = false -- true to disable oUF buffs/debuffs on the ToT frame

config.noPartyRaid = false -- true to disable party/raid frames
config.noArena = false -- true to disable arena frames

config.font = caelMedia.fonts.NORMAL

config.scale = 1 -- scale of the unitframes (1 being 100%)

config.lowThreshold = 20 -- low mana threshold for all mana classes
config.highThreshold = 80 -- high mana treshold for hunters

config.noClassDebuffs = false -- true to show all debuffs

config.coords = {
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
}