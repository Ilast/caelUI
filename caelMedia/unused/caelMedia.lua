--[[	$Id: caelMedia.lua 521 2010-03-06 16:47:07Z sdkyron@gmail.com $	]]

-- tab size is 4
-- registrations for media from the client itself belongs in LibSharedMedia-3.0

if not SharedMedia then return end
local revision = tonumber(string.sub("$Revision: 76383 $", 12, -3))
SharedMedia.revision = (revision > SharedMedia.revision) and revision or SharedMedia.revision

-- -----
-- BACKGROUND
-- -----

-- -----
--  BORDER
-- ----
	SharedMedia:Register("border", "Border 1", [[Interface\Addons\caelMedia\Borders\border1.tga]])
-- -----
--   FONT
-- -----
	SharedMedia:Register("font", "neuropol x cd rg", [[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]])
	SharedMedia:Register("font", "neuropol x cd rg it", [[Interface\Addons\caelMedia\Fonts\neuropol x cd rg it.ttf]])
	SharedMedia:Register("font", "neuropol x cd bd", [[Interface\Addons\caelMedia\Fonts\neuropol x cd bd.ttf]])
	SharedMedia:Register("font", "neuropol x cd bd it", [[Interface\Addons\caelMedia\Fonts\neuropol x cd bd it.ttf]])
	SharedMedia:Register("font", "xenara rg", [[Interface\Addons\caelMedia\Fonts\xenara rg.ttf]])
-- -----
--   SOUND
-- -----
	SharedMedia:Register("sound", "Custom: Aggro", [[Interface\Addons\caelMedia\Sounds\babe.mp3]])
	SharedMedia:Register("sound", "Custom: Alarm", [[Interface\Addons\caelMedia\Sounds\alarm.mp3]])
	SharedMedia:Register("sound", "Custom: Leaving Combat", [[Interface\Addons\caelMedia\Sounds\combat-.mp3]])
	SharedMedia:Register("sound", "Custom: Entering Combat", [[Interface\Addons\caelMedia\Sounds\combat+.mp3]])
	SharedMedia:Register("sound", "Custom: Combo Points", [[Interface\Addons\caelMedia\Sounds\combo.mp3]])
	SharedMedia:Register("sound", "Custom: Godlike", [[Interface\Addons\caelMedia\Sounds\godlike.mp3]])
	SharedMedia:Register("sound", "Custom: 5 Combo Points", [[Interface\Addons\caelMedia\Sounds\finish.mp3]])
	SharedMedia:Register("sound", "Custom: LnL Proc", [[Interface\Addons\caelMedia\Sounds\lnl.mp3]])
	SharedMedia:Register("sound", "Custom: Skill Up", [[Interface\Addons\caelMedia\Sounds\skill up.mp3]])
	SharedMedia:Register("sound", "Custom: Warning", [[Interface\Addons\caelMedia\Sounds\warning.mp3]])
	SharedMedia:Register("sound", "Custom: Whisper", [[Interface\Addons\caelMedia\Sounds\whisper.mp3]])
-- -----
--   STATUSBAR
-- -----
	SharedMedia:Register("statusbar", "normTex A", [[Interface\Addons\caelMedia\StatusBars\normtexa.tga]])
	SharedMedia:Register("statusbar", "normTex B", [[Interface\Addons\caelMedia\StatusBars\normtexb.tga]])
-- -----
--   MISCELLANEOUS
-- -----
	SharedMedia:Register("miscellaneous", "glowTex", [[Interface\Addons\caelMedia\Miscellaneous\glowtex.tga]])
	SharedMedia:Register("miscellaneous", "Mail Icon", [[Interface\Addons\caelMedia\Miscellaneous\mail.tga]])
	SharedMedia:Register("miscellaneous", "Charmed", [[Interface\Addons\caelMedia\Miscellaneous\charmed.tga]])
	SharedMedia:Register("miscellaneous", "Nandini", [[Interface\Addons\caelMedia\Miscellaneous\nandini.tga]])
	SharedMedia:Register("miscellaneous", "Party Icon", [[Interface\Addons\caelMedia\Miscellaneous\partyicon.tga]])
	SharedMedia:Register("miscellaneous", "Raid Icon", [[Interface\Addons\caelMedia\Miscellaneous\raidicon.tga]])
-- -----
--   BUTTON
-- -----
	SharedMedia:Register("button", "Button Overlay", [[Interface\Addons\caelMedia\Buttons\buttonoverlay.tga]])
	SharedMedia:Register("button", "Button Border 1", [[Interface\Addons\caelMedia\Buttons\buttonborder1.tga]])
	SharedMedia:Register("button", "Button Border 2", [[Interface\Addons\caelMedia\Buttons\buttonborder2.tga]])