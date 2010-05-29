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
	CHAT_FONT 		= [=[Interface\Addons\caelMedia\fonts\xenara rg.ttf]=],
}

local fonts = setmetatable(caelMedia.customFonts, {__index = originalFonts})

caelMedia.eventFrame = CreateFrame("Frame", nil, UIParent)

local SetFont = function(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

local FixTitleFont = function()
	for _,butt in pairs(PlayerTitlePickerScrollFrame.buttons) do
		butt.text:SetFontObject(GameFontHighlightSmallLeft)
	end
end

caelMedia.eventFrame:RegisterEvent("ADDON_LOADED")
caelMedia.eventFrame:SetScript("OnEvent", function(self, event, addon)

	if addon ~= "caelMedia" then return end

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}

	UNIT_NAME_FONT     = fonts.NORMAL
	NAMEPLATE_FONT     = fonts.BOLD
	DAMAGE_TEXT_FONT   = fonts.NUMBER
	STANDARD_TEXT_FONT = fonts.NORMAL

	-- Base fonts
	SetFont(AchievementFont_Small,                fonts.BOLD, 10)
	SetFont(GameTooltipHeader,                    fonts.BOLD, 13, "OUTLINE")
	SetFont(InvoiceFont_Med,                    fonts.ITALIC, 11, nil, 0.15, 0.09, 0.04)
	SetFont(InvoiceFont_Small,                  fonts.ITALIC, 9, nil, 0.15, 0.09, 0.04)
	SetFont(MailFont_Large,                     fonts.ITALIC, 13, nil, 0.15, 0.09, 0.04, 0.54, 0.4, 0.1, 1, -1)
	SetFont(NumberFont_OutlineThick_Mono_Small, fonts.NUMBER, 11, "OUTLINE")
	SetFont(NumberFont_Outline_Huge,            fonts.NUMBER, 28, "THICKOUTLINE", 28)
	SetFont(NumberFont_Outline_Large,           fonts.NUMBER, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med,             fonts.NUMBER, 13, "OUTLINE")
	SetFont(NumberFont_Shadow_Med,              fonts.NORMAL, 12)
	SetFont(NumberFont_Shadow_Small,            fonts.NORMAL, 10)
	SetFont(QuestFont_Large,                    fonts.NORMAL, 14)
	SetFont(QuestFont_Shadow_Huge,                fonts.BOLD, 17, nil, nil, nil, nil, 0.54, 0.4, 0.1)
	SetFont(ReputationDetailFont,                 fonts.BOLD, 10, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(SpellFont_Small,                      fonts.BOLD, 9)
	SetFont(SystemFont_InverseShadow_Small,       fonts.BOLD, 9)
	SetFont(SystemFont_Large,                   fonts.NORMAL, 15)
	SetFont(SystemFont_Med1,                    fonts.NORMAL, 11)
	SetFont(SystemFont_Med2,                    fonts.ITALIC, 12, nil, 0.15, 0.09, 0.04)
	SetFont(SystemFont_Med3,                    fonts.NORMAL, 13)
	SetFont(SystemFont_OutlineThick_Huge2,      fonts.NORMAL, 20, "THICKOUTLINE")
	SetFont(SystemFont_OutlineThick_Huge4,  fonts.BOLDITALIC, 25, "THICKOUTLINE")
	SetFont(SystemFont_OutlineThick_WTF,    fonts.BOLDITALIC, 29, "THICKOUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(SystemFont_Outline_Small,           fonts.NUMBER, 11, "OUTLINE")
	SetFont(SystemFont_Shadow_Huge1,              fonts.BOLD, 18)
	SetFont(SystemFont_Shadow_Huge3,              fonts.BOLD, 23)
	SetFont(SystemFont_Shadow_Large,            fonts.NORMAL, 15)
	SetFont(SystemFont_Shadow_Med1,             fonts.NORMAL, 11)
	SetFont(SystemFont_Shadow_Med3,             fonts.NORMAL, 13)
	SetFont(SystemFont_Shadow_Outline_Huge2,    fonts.NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small,              fonts.BOLD, 9)
	SetFont(SystemFont_Small,                   fonts.NORMAL, 10)
	SetFont(SystemFont_Tiny,                    fonts.NORMAL, 9)
	SetFont(Tooltip_Med,                        fonts.NORMAL, 11)
	SetFont(Tooltip_Small,                        fonts.BOLD, 10)

	-- Derived fonts
	SetFont(BossEmoteNormalHuge,     fonts.BOLDITALIC, 25, "THICKOUTLINE")
	SetFont(CombatTextFont,              fonts.NORMAL, 24)
	SetFont(ErrorFont,                   fonts.ITALIC, 14, nil, 58)
	SetFont(QuestFontNormalSmall,          fonts.BOLD, 11, nil, nil, nil, nil, 0.54, 0.4, 0.1)
	SetFont(WorldMapTextFont,        fonts.BOLDITALIC, 29, "THICKOUTLINE",  38, nil, nil, 0, 0, 0, 1, -1)

	for i = 1, NUM_CHAT_WINDOWS do
		local frame =_G[format("ChatFrame%s", i)]
		local _, size = frame:GetFont()
		frame:SetFont(fonts.CHAT_FONT, size)
	end

	hooksecurefunc("PlayerTitleFrame_UpdateTitles", FixTitleFont)
	FixTitleFont()

	SetFont = nil
	self:SetScript("OnEvent", nil)
	self:UnregisterAllEvents()
	self = nil
end)