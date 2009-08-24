local last_use = 0

local function CollisionCheck(newtext)
	local destination_scroll_area = RecScrollAreas.anim_strings[newtext.scrollarea]
	local current_animations = #destination_scroll_area
	if current_animations > 0 then -- Only if there are already animations running

		-- Scale the per pixel time based on the animation speed.
		local perPixelTime = RecScrollAreas.scroll_area_frames[newtext.scrollarea].movement_speed / newtext.animationSpeed
		local curtext = newtext -- start with our new string
		local previoustext, previoustime

		-- cycle backwards through the table of fontstrings since our newest ones have the highest index
		for x = current_animations, 1, -1 do
			previoustext = destination_scroll_area[x]

			if not newtext.sticky then
				-- Calculate the elapsed time for the top point of the previous display event.
				-- TODO: Does this need to be changed since we anchor LEFT and not TOPLEFT?
				previoustime = previoustext.totaltime - (previoustext.fontSize + RecScrollAreas.animation_vertical_spacing) * perPixelTime

				--[[If there is a collision, then we set the older fontstring to a higher animation time
					Which 'pushes' it upward to make room for the new one--]]
				if (previoustime <= curtext.totaltime) then
					previoustext.totaltime = curtext.totaltime + (previoustext.fontSize + RecScrollAreas.animation_vertical_spacing) * perPixelTime
				else
					return -- If there was no collision, then we can safely stop checking for more of them
				end
			else
				previoustext.curpos = previoustext.curpos + (previoustext.fontSize + RecScrollAreas.animation_vertical_spacing)
			end

			-- Check the next one against the current one
			curtext = previoustext
		end
	end
end

local function Move(self, elapsed)
	local t
	-- Loop through all active fontstrings
	for k,v in pairs(RecScrollAreas.anim_strings) do

		for l,u in pairs(RecScrollAreas.anim_strings[k]) do
			t = RecScrollAreas.anim_strings[k][l]

			if t and t.inuse then
				--increment it's timer until the animation delay is fulfilled
				t.timer = (t.timer or 0) + elapsed
				if t.timer >= RecScrollAreas.animation_delay then

					--[[we store it's elapsed time separately so we can continue to delay
						its animation (so we're not updating every onupdate, but can still
						tell what its full animation duration is)--]]
					t.totaltime = t.totaltime + t.timer

					--[[If the animation is not complete, then we need to animate it by moving
						its Y coord (in our sample scrollarea) the proper amount.  If it is complete,
						then we hide it and flag it for recycling --]]
					local percentDone = t.totaltime / RecScrollAreas.animation_duration
					if (percentDone <= 1) then
						t.text:ClearAllPoints()
						local area_height = RecScrollAreas.scroll_area_frames[t.scrollarea]:GetHeight()
						if not t.sticky then
							if RecScrollAreas.scroll_area_frames[t.scrollarea].direction == "up" then
								t.curpos = area_height * percentDone -- move up
							else
								t.curpos = area_height - (area_height * percentDone)
							end
							t.text:SetPoint(RecScrollAreas.scroll_area_frames[t.scrollarea].textalign, RecScrollAreas.scroll_area_frames[t.scrollarea], "BOTTOMLEFT", 0, t.curpos)
						else
							if t.curpos > area_height/2 then t.totaltime = 99 end
							t.text:SetPoint(RecScrollAreas.scroll_area_frames[t.scrollarea].textalign, RecScrollAreas.scroll_area_frames[t.scrollarea], RecScrollAreas.scroll_area_frames[t.scrollarea].textalign, 0, t.curpos)
						end

						-- Fade in
						if (percentDone <= RecScrollAreas.fade_in_time) then t.text:SetAlpha(1 * (percentDone / RecScrollAreas.fade_in_time))
						-- Fade out
						elseif (percentDone >= RecScrollAreas.fade_out_time) then t.text:SetAlpha(1 * (1 - percentDone) / (1 - RecScrollAreas.fade_out_time))
						-- Full vis for times inbetween
						else t.text:SetAlpha(1) end
					else
						t.text:Hide()
						t.inuse = false
					end

					t.timer = 0		--reset our animation delay timer
				end
			end

			--[[Now, we loop backwards through the fontstrings to determine which ones
				can be recycled --]]
			for j = #RecScrollAreas.anim_strings[k], 1, -1 do
				t = RecScrollAreas.anim_strings[k][j]
				if not t.inuse then
					table.remove(RecScrollAreas.anim_strings[k], j)
					-- Place the used frame into our recycled cache
					RecScrollAreas.empty_strings[(#RecScrollAreas.empty_strings or 0) + 1] = t.text
					for key in next, t do t[key] = nil end
					RecScrollAreas.empty_tables[(#RecScrollAreas.empty_tables or 0)+1] = t
				end
			end
		end
	end
end

function RecScrollAreas:AddText(text, sticky, scrollarea)
	local destination_area
	if not sticky then
		destination_area = RecScrollAreas.anim_strings[scrollarea]
	else
		destination_area = RecScrollAreas.anim_strings[scrollarea.."sticky"]
	end
	local t
	-- If there are too many frames in the animation area, steal one of them first
	if not destination_area then return end
	if ((#destination_area or 0) >= RecScrollAreas.animations_per_scrollframe) then
		t = table.remove(destination_area, 1)

	-- If there are frames in the recycle bin, then snatch one of them!
	elseif (#RecScrollAreas.empty_tables or 0) > 0 then
		t = table.remove(RecScrollAreas.empty_tables, 1)

	-- If we still don't have a frame, then we'll just have to create a brand new one
	else
		t = {}
	end
	if not t.text then
		t.text = table.remove(RecScrollAreas.empty_strings, 1) or RecScrollAreas.event_frame:CreateFontString(nil, "BORDER")
	end

	-- Settings which need to be set/reset on each fontstring after it is created/obtained
	if sticky then t.fontSize = RecScrollAreas.font_size_sticky else t.fontSize = RecScrollAreas.font_size_normal end
	t.sticky = sticky
	t.text:SetFont(RecScrollAreas.font, t.fontSize, RecScrollAreas.font_flags)
	t.text:SetText(text)
	t.direction = destination_area.direction
	t.inuse = true
	t.timer = 0
	t.totaltime = 0
	t.curpos = 0
	t.text:ClearAllPoints()
	if t.sticky then
		t.text:SetPoint(RecScrollAreas.scroll_area_frames[scrollarea.."sticky"].textalign, RecScrollAreas.scroll_area_frames[scrollarea.."sticky"], RecScrollAreas.scroll_area_frames[scrollarea.."sticky"].textalign, 0, 0)
		t.text:SetDrawLayer("OVERLAY") -- on top of normal texts.
	else
		t.text:SetPoint(RecScrollAreas.scroll_area_frames[scrollarea].textalign, RecScrollAreas.scroll_area_frames[scrollarea], "BOTTOMLEFT", 0, 0)
		t.text:SetDrawLayer("ARTWORK")
	end
	t.text:SetAlpha(0)
	t.text:Show()
	t.animationSpeed = RecScrollAreas.animation_speed
	t.scrollarea = t.sticky and scrollarea.."sticky" or scrollarea

	-- Make sure that adding this fontstring will not collide with anything!
	CollisionCheck(t)

	-- Add the fontstring into our table which gets looped through during the OnUpdate
	destination_area[#destination_area+1] = t
	last_use = 0
end

local function OnUpdate(s,e)
	Move(s, e)
	-- Keep footprint down by releasing stored tables and strings after we've been idle for a bit.
	last_use = last_use + e
	if last_use > 30 then
		if #RecScrollAreas.empty_tables and #RecScrollAreas.empty_tables > 0 then
			RecScrollAreas.empty_tables = {}
		end
		if #RecScrollAreas.empty_strings and #RecScrollAreas.empty_strings > 0 then
			RecScrollAreas.empty_strings = {}
		end
		last_use = 0
	end
end
RecScrollAreas.event_frame = CreateFrame("Frame")
RecScrollAreas.event_frame:SetScript("OnUpdate", OnUpdate)
