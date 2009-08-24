function RecScrollAreas:CreateScrollArea(id, height, x_pos, y_pos, textalign, direction)
	RecScrollAreas.scroll_area_frames[id] = CreateFrame("Frame", nil, UIParent)
	RecScrollAreas.scroll_area_frames[id.."sticky"] = CreateFrame("Frame", nil, UIParent)
	-- Enable these two lines to see the scroll area on the screen for more accurate placement, etc
	--RecScrollAreas.scroll_area_frames[id]:SetBackdrop({ bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeFile = nil, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0} })
	--RecScrollAreas.scroll_area_frames[id]:SetBackdropColor(0, 0, 0, 1)
	RecScrollAreas.scroll_area_frames[id]:SetWidth(1)
	RecScrollAreas.scroll_area_frames[id.."sticky"]:SetWidth(1)
	RecScrollAreas.scroll_area_frames[id]:SetHeight(height)
	RecScrollAreas.scroll_area_frames[id.."sticky"]:SetHeight(height)
	RecScrollAreas.scroll_area_frames[id]:SetPoint("BOTTOM", UIParent, "BOTTOM", x_pos, y_pos)
	RecScrollAreas.scroll_area_frames[id.."sticky"]:SetPoint("BOTTOM", UIParent, "BOTTOM", x_pos, y_pos)
	RecScrollAreas.scroll_area_frames[id].textalign = textalign
	RecScrollAreas.scroll_area_frames[id.."sticky"].textalign = textalign
	RecScrollAreas.scroll_area_frames[id].direction = direction or "up"
	RecScrollAreas.scroll_area_frames[id.."sticky"].direction = direction or "up"
	RecScrollAreas.anim_strings[id] = {}
	RecScrollAreas.anim_strings[id.."sticky"] = {}
	RecScrollAreas.scroll_area_frames[id].movement_speed = RecScrollAreas.animation_duration / height
	RecScrollAreas.scroll_area_frames[id.."sticky"].movement_speed = RecScrollAreas.animation_duration / height
end