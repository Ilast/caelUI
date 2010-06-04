--[[	$Id$	]]

local _, caelMedia = ...

local originalFonts = {
	NORMAL     = [=[Interface\Addons\caelMedia\fonts\neuropol x cd rg.ttf]=],
	BOLD       = [=[Interface\Addons\caelMedia\fonts\neuropol x cd bd.ttf]=],
	BOLDITALIC = [=[Interface\Addons\caelMedia\fonts\neuropol x cd bd it.ttf]=],
	ITALIC     = [=[Interface\Addons\caelMedia\fonts\neuropol x cd rg it.ttf]=],
	NUMBER     = [=[Interface\Addons\caelMedia\fonts\neuropol x cd bd.ttf]=],

	UNIT_NAME_FONT    	= [=[Interface\Addons\caelMedia\fonts\neuropol x cd rg.ttf]=],
	NAMEPLATE_FONT     	= [=[Interface\Addons\caelMedia\fonts\neuropol x cd bd.ttf]=],
	DAMAGE_TEXT_FONT   	= [=[Interface\Addons\caelMedia\fonts\neuropol x cd bd.ttf]=],
	STANDARD_TEXT_FONT 	= [=[Interface\Addons\caelMedia\fonts\neuropol x cd rg.ttf]=],
	CHAT_FONT	 		= [=[Interface\Addons\caelMedia\fonts\xenara rg.ttf]=],
	
	-- Addon related stuff.
	OUF_CAELLIAN_NUMBERFONT	= [=[Interface\Addons\caelMedia\fonts\russel square lt.ttf]=],
	SCROLLFRAME_NORMAL		= [=[Interface\Addons\caelMedia\fonts\neuropol nova cd rg.ttf]=],
	SCROLLFRAME_BOLD		= [=[Interface\Addons\caelMedia\fonts\neuropol nova cd bd.ttf]=],
	CAELNAMEPLATE_FONT		= [=[Interface\Addons\caelMedia\fonts\xenara rg.ttf]=],
}

local fonts
if caelMedia.customFonts then
	fonts = setmetatable(caelMedia.customFonts, {__index = originalFonts})
else
	fonts = originalFonts
end

caelMedia.fonts = fonts