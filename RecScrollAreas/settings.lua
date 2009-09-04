-- Font Settings
RecScrollAreas.font					= [=[Interface\Addons\RecScrollAreas\media\neuropol x cd rg.ttf]=]
RecScrollAreas.font_sticky			= [=[Interface\Addons\RecScrollAreas\media\neuropol x cd bd.ttf]=]
RecScrollAreas.font_flags			= "OUTLINE"	-- Some text can be hard to read without it.
RecScrollAreas.font_flags_sticky	= "OUTLINE"
RecScrollAreas.font_size_normal	= 12
RecScrollAreas.font_size_sticky	= 12

-- Animation Settings
RecScrollAreas.fade_in_time					= 0.2		-- Percentage of the animation start spent fading in.
RecScrollAreas.fade_out_time					= 0.8		-- At what percentage should we begin fading out.
RecScrollAreas.animation_duration			= 3.5		-- Time it takes for an animation to complete. (in seconds)
RecScrollAreas.animations_per_scrollframe	= 15 		-- Maximum number of displayed animations in each scrollframe.
RecScrollAreas.animation_vertical_spacing	= 10 		-- Minimum spacing between animations.
RecScrollAreas.animation_speed				= 1		-- Modifies animation_duration.  1 = 100%
RecScrollAreas.animation_delay				= 0.015	-- Frequency of animation updates. (in seconds)

-- Make your scroll areas
-- Format: RecScrollAreas:CreateScrollArea(identifier, height, x_pos, y_pos, textalign, direction)
-- Frames are relative to BOTTOM UIParent BOTTOM
--
-- Then you can pipe input into each scroll area using:
-- RecScrollAreas:AddText(text_to_show, sticky_style, scroll_area_identifer)
--
RecScrollAreas:CreateScrollArea("Notification", 140, 0, 515, "CENTER", "down")
RecScrollAreas:CreateScrollArea("Information", 100, 0, 160, "CENTER", "down")
RecScrollAreas:CreateScrollArea("Outgoing", 200, 385, 375, "RIGHT", "up")
RecScrollAreas:CreateScrollArea("Incoming", 200, -385, 375, "LEFT", "down")