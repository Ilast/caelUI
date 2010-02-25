local neuropolrg9 = CreateFont("neuropolrg9")
neuropolrg9:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 9, "")
local neuropolrg10 = CreateFont("neuropolrg10")
neuropolrg10:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 10, "")
local neuropolrg12 = CreateFont("neuropolrg12")
neuropolrg12:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 12, "")

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

local caelFonts = CreateFrame("Frame")
caelFonts:RegisterEvent("ADDON_LOADED")

caelFonts:SetScript("OnEvent", function(self, event, addon)

	if addon ~= "caelMedia" then return end

	local NORMAL     = [=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=]
	local BOLD       = [=[Interface\Addons\caelMedia\Fonts\neuropol x cd bd.ttf]=]
	local BOLDITALIC = [=[Interface\Addons\caelMedia\Fonts\neuropol x cd bd it.ttf]=]
	local ITALIC     = [=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg it.ttf]=]
	local NUMBER     = [=[Interface\Addons\caelMedia\Fonts\neuropol x cd bd.ttf]=]

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}

	UNIT_NAME_FONT     = NORMAL
	NAMEPLATE_FONT     = BOLD
	DAMAGE_TEXT_FONT   = NUMBER
	STANDARD_TEXT_FONT = NORMAL

	-- Base fonts
	SetFont(AchievementFont_Small,                BOLD, 10)
	SetFont(GameTooltipHeader,                    BOLD, 13, "OUTLINE")
	SetFont(InvoiceFont_Med,                    ITALIC, 11, nil, 0.15, 0.09, 0.04)
	SetFont(InvoiceFont_Small,                  ITALIC, 9, nil, 0.15, 0.09, 0.04)
	SetFont(MailFont_Large,                     ITALIC, 13, nil, 0.15, 0.09, 0.04, 0.54, 0.4, 0.1, 1, -1)
	SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, 11, "OUTLINE")
	SetFont(NumberFont_Outline_Huge,            NUMBER, 28, "THICKOUTLINE", 28)
	SetFont(NumberFont_Outline_Large,           NUMBER, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med,             NUMBER, 13, "OUTLINE")
	SetFont(NumberFont_Shadow_Med,              NORMAL, 12)
	SetFont(NumberFont_Shadow_Small,            NORMAL, 10)
	SetFont(QuestFont_Large,                    NORMAL, 14)
	SetFont(QuestFont_Shadow_Huge,                BOLD, 17, nil, nil, nil, nil, 0.54, 0.4, 0.1)
	SetFont(ReputationDetailFont,                 BOLD, 10, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(SpellFont_Small,                      BOLD, 9)
	SetFont(SystemFont_InverseShadow_Small,       BOLD, 9)
	SetFont(SystemFont_Large,                   NORMAL, 15)
	SetFont(SystemFont_Med1,                    NORMAL, 11)
	SetFont(SystemFont_Med2,                    ITALIC, 12, nil, 0.15, 0.09, 0.04)
	SetFont(SystemFont_Med3,                    NORMAL, 13)
	SetFont(SystemFont_OutlineThick_Huge2,      NORMAL, 20, "THICKOUTLINE")
	SetFont(SystemFont_OutlineThick_Huge4,  BOLDITALIC, 25, "THICKOUTLINE")
	SetFont(SystemFont_OutlineThick_WTF,    BOLDITALIC, 29, "THICKOUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(SystemFont_Outline_Small,           NUMBER, 11, "OUTLINE")
	SetFont(SystemFont_Shadow_Huge1,              BOLD, 18)
	SetFont(SystemFont_Shadow_Huge3,              BOLD, 23)
	SetFont(SystemFont_Shadow_Large,            NORMAL, 15)
	SetFont(SystemFont_Shadow_Med1,             NORMAL, 11)
	SetFont(SystemFont_Shadow_Med3,             NORMAL, 13)
	SetFont(SystemFont_Shadow_Outline_Huge2,    NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small,              BOLD, 9)
	SetFont(SystemFont_Small,                   NORMAL, 10)
	SetFont(SystemFont_Tiny,                    NORMAL, 9)
	SetFont(Tooltip_Med,                        NORMAL, 11)
	SetFont(Tooltip_Small,                        BOLD, 10)

	-- Derived fonts
	SetFont(BossEmoteNormalHuge,     BOLDITALIC, 25, "THICKOUTLINE")
	SetFont(CombatTextFont,              NORMAL, 24)
	SetFont(ErrorFont,                   ITALIC, 14, nil, 58)
	SetFont(QuestFontNormalSmall,          BOLD, 11, nil, nil, nil, nil, 0.54, 0.4, 0.1)
	SetFont(WorldMapTextFont,        BOLDITALIC, 29, "THICKOUTLINE",  38, nil, nil, 0, 0, 0, 1, -1)

	for i = 1, 7 do
		local frame = _G["ChatFrame"..i]
		local font, size = frame:GetFont()
		frame:SetFont([=[Interface\Addons\caelMedia\Fonts\xenara rg.ttf]=], size)
	end

	hooksecurefunc("PlayerTitleFrame_UpdateTitles", FixTitleFont)
	FixTitleFont()
	
	SetFont = nil
	self:SetScript("OnEvent", nil)
	self:UnregisterAllEvents()
	self = nil
end)