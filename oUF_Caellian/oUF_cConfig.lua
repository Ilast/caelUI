Caellian = {oUF = {

noPlayerAuras = false, -- true to disable oUF buffs/debuffs on the player frame and enable default
noPetAuras = false, -- true to disable oUF buffs/debuffs on the pet frame
noTargetAuras = false, -- true to disable oUF buffs/debuffs on the target frame
noToTAuras = false, -- true to disable oUF buffs/debuffs on the ToT frame
noRaid = false, -- true to disable raid frames

font = [=[Interface\Addons\oUF_Caellian\media\fonts\neuropol x cd rg.ttf]=],

scale = 1, -- scale of the unitframes (1 being 100%)

lowThreshold = 20, -- low mana threshold for all mana classes
highThreshold = 80, -- high mana treshold for hunters

coords = {
	playerX = -278.5, -- horizontal offset for the player block frames
	playerY = 269.5, -- vertical offset for the player block frames

	targetX = 278.5, -- horizontal offset for the target block frames
	targetY = 269.5, -- vertical offset for the target block frames

	partyX = 15, -- horizontal offset for the party frames
	partyY = -15, -- vertical offset for the party frames

	raidX = 15, -- horizontal offset for the raid frames
	raidY = -15, -- vertical offset for the raid frames
}}}