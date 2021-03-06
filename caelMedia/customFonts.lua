--[[	$Id$	]]

--[[	Rename this file to customFonts.lua if you want to use custom fonts	]]

_, caelMedia = ...

--[=[ 	Custom fonts should be added to the following table.
		There are a number of different fonts being used through the UI.
		The default font has various different styles, with names that speak for themselves:
		NORMAL, BOLD, BOLDITALIC, ITALIC, NUMBER
		
		Beside that, some specific fonts can also be changed, and again, the names speak for themselves:
		UNIT_NAME_FONT, NAMEPLATE_FONT, DAMAGE_TEXT_FONT, STANDARD_TEXT_FONT, CHAT_FONT
		
		The UI will always fall back to the default caelUI font if you don't specify a custom font,
		so there is no need to specify all fonts.
		
		Example:
		
		caelMedia.customFonts = {
			BOLD = [[Folder path\To my font\font.ttf]],
			UNIT_NAME_FONT = [[Folder path\To my Font\some other font.ttf]],
		}
]=]

caelMedia.customFonts = {}
