--[[	$Id$	]]

local _, caelDataFeeds = ...

caelDataFeeds.system = caelPanel8:CreateFontString(nil, "OVERLAY")
caelDataFeeds.system:SetFont([=[Interface\Addons\caelMedia\Fonts\neuropol x cd rg.ttf]=], 10)
caelDataFeeds.system:SetPoint("LEFT", caelPanel8, "LEFT", 10, 1)

caelDataFeeds.sysFrame = CreateFrame("Frame", nil, UIParent)
caelDataFeeds.sysFrame:SetAllPoints(caelDataFeeds.system)
caelDataFeeds.sysFrame:EnableMouse(true)
caelDataFeeds.sysFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)

local Addons = {}
local AddonsMemoryCompare = function(a, b)
	return Addons[a] > Addons[b]
end

local FormatMemoryNumber = function(number)
	if number > 1000 then
		return string.format("%.2f |cffD7BEA5mb|r", number / 1000)
	else
		return string.format("%.1f |cffD7BEA5kb|r", number)
	end
end

local latencyColor = {}
local ColorizeLatency = function(number)
	if number <= 25 then
		latencyColor.r = 0.33
		latencyColor.g = 0.59
		latencyColor.b = 0.33
	elseif number <= 75 then
		latencyColor.r = 0.65
		latencyColor.g = 0.63
		latencyColor.b = 0.35
	else
		latencyColor.r = 0.69
		latencyColor.g = 0.31
		latencyColor.b = 0.31
	end
end

local memory, addon, i
local latency, totalMemory
local memText, lagText, fpsText
local function UpdateMemory(self)
	totalMemory = 0
	UpdateAddOnMemoryUsage()

	for i = 1, GetNumAddOns(), 1 do
		if IsAddOnLoaded(i) then
			memory = GetAddOnMemoryUsage(i)
			Addons[GetAddOnInfo(i)] = memory 
			totalMemory = totalMemory + memory
		end
	end
end

local delay1, delay2 = 0, 0
caelDataFeeds.sysFrame:SetScript("OnUpdate", function(self, elapsed)
	delay1 = delay1 - elapsed
	delay2 = delay2 - elapsed

	latency = select(3, GetNetStats())
	ColorizeLatency(latency)

	if delay1 < 0 then
		UpdateMemory(self)
		memText = FormatMemoryNumber(totalMemory)

		lagText = string.format("|cff%02x%02x%02x%s|r |cffD7BEA5ms|r", latencyColor.r * 255, latencyColor.g * 255, latencyColor.b * 255, latency)
		delay1 = 5
	end

	if delay2 < 0 then
		fpsText = string.format("%.1f |cffD7BEA5fps|r", GetFramerate())
		caelDataFeeds.system:SetFormattedText("%s - %s - %s", memText, lagText, fpsText)
		delay2 = 1
	end
end)

caelDataFeeds.sysFrame:SetScript("OnEnter", function(self)
	if IsShiftKeyDown() then
		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)

		local SortingTable = {}
		for name in pairs(Addons) do
			SortingTable[#SortingTable + 1] = name
		end
		table.sort(SortingTable, AddonsMemoryCompare)

		local i = 0
		for _, addon in ipairs(SortingTable) do
			GameTooltip:AddDoubleLine(addon, FormatMemoryNumber(Addons[addon]), 0.84, 0.75, 0.65, 0.65, 0.63, 0.35)

			i = i + 1

			if i >= 50 then
				break
			end
		end

		GameTooltip:AddDoubleLine("---------- ----------", "---------- ----------", 0.55, 0.57, 0.61, 0.55, 0.57, 0.61)
		GameTooltip:AddDoubleLine("Addon Memory Usage", FormatMemoryNumber(totalMemory), 0.84, 0.75, 0.65, 0.65, 0.63, 0.35)
		GameTooltip:Show()
	end
end)

caelDataFeeds.sysFrame:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" then
		local collected = collectgarbage("count")
		collectgarbage("collect")
		GameTooltip:AddDoubleLine("---------- ----------", "---------- ----------", 0.55, 0.57, 0.61, 0.55, 0.57, 0.61)
		GameTooltip:AddDoubleLine("Garbage Collected:", FormatMemoryNumber(collected - collectgarbage("count")), 0.84, 0.75, 0.65, 0.65, 0.63, 0.35)
		GameTooltip:Show()
	end
end)