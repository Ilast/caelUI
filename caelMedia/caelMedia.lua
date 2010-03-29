--[[	$Id$	]]

caelMedia = {}

caelMedia.DIRECTORY = [=[Interface\Addons\caelMedia]=]

caelMedia.files = {
	bgFile				= [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile			= [=[Interface\Addons\caelMedia\borders\glowtex]=],
	statusBarA			= [=[Interface\Addons\caelMedia\statusbars\normtexa]=],
	statusBarB			= [=[Interface\Addons\caelMedia\statusbars\normtexb]=],

	fontRg				= [=[Interface\Addons\caelMedia\fonts\neuropol x cd rg.ttf]=],
	fontBd				= [=[Interface\Addons\caelMedia\fonts\neuropol x cd bd.ttf]=],

	soundAlarm			= [=[Interface\Addons\caelMedia\sounds\alarm.mp3]=],
	soundLeavingCombat	= [=[Interface\Addons\caelMedia\sounds\combat-.mp3]=],
	soundEnteringCombat	= [=[Interface\Addons\caelMedia\sounds\combat+.mp3]=],
	soundCombo			= [=[Interface\Addons\caelMedia\sounds\combo.mp3]=],
	soundComboMax		= [=[Interface\Addons\caelMedia\sounds\finish.mp3]=],
	soundGodlike		= [=[Interface\Addons\caelMedia\sounds\godlike.mp3]=],
	soundLnLProc		= [=[Interface\Addons\caelMedia\sounds\lnl.mp3]=],
	soundskillUp		= [=[Interface\Addons\caelMedia\sounds\skill up.mp3]=],
	soundWarning		= [=[Interface\Addons\caelMedia\sounds\warning.mp3]=],
	soundAggro			= [=[Interface\Addons\caelMedia\sounds\aggro.mp3]=],
	soundWhisper		= [=[Interface\Addons\caelMedia\sounds\whisper.mp3]=],

	iconBorder			= [=[Interface\Addons\caelMedia\texture\border]=],
	iconHighlight		= [=[Interface\Addons\caelMedia\texture\highlight]=],

	buttonNormal		= [=[Interface\AddOns\caelMedia\texture\button_normal]=],
	buttonGloss			= [=[Interface\AddOns\caelMedia\texture\button_gloss]=],
	buttonFlash			= [=[Interface\AddOns\caelMedia\texture\button_flash]=],
	buttonHover			= [=[Interface\AddOns\caelMedia\texture\button_hover]=],
	buttonPushed		= [=[Interface\AddOns\caelMedia\texture\button_pushed]=],
	buttonChecked		= [=[Interface\AddOns\caelMedia\texture\button_checked]=],
	buttonEquipped		= [=[Interface\AddOns\caelMedia\texture\button_gloss]=],
	buttonBackdrop		= [=[Interface\AddOns\caelMedia\texture\button_backdrop]=],
	buttonHighlight		= [=[Interface\AddOns\caelMedia\texture\button_highlight]=]
}

--	caelMedia.files.fontObject = CreateFont("caelMediaFontObject")
--	caelMedia.files.fontObject:SetFont(caelMedia.files.fontRg, 10, nil)

caelMedia.files.insetTable = {
    left = 2,
    right = 2,
    top = 2,
    bottom = 2
}
caelMedia.files.backdropTable = {
    bgFile   = caelMedia.files.bgFile,
    edgeFile = caelMedia.files.edgeFile,
    edgeSize = 2,
    insets   = caelMedia.files.insetTable
}

caelMedia.files.borderTable = {
    bgFile   = nil,
    edgeFile = caelMedia.files.edgeFile,
    edgeSize = 4,
    insets   = caelMedia.files.insetTable
}

caelMedia.files.buttonTable = {
    bgFile = caelMedia.files.buttonBackdrop,
    edgeFile = nil,
    edgeSize = 0,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
}