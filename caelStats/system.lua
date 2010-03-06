--[[	$Id$	]]

local _, caelStats = ...

local Holder = CreateFrame("Frame")

caelStats.system = caelPanel8:CreateFontString(nil, "OVERLAY")
caelStats.system:SetFontObject(neuropolrg10)
caelStats.system:SetPoint("LEFT", caelPanel8, "LEFT", 10, 1) 

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

local ColorizeLatency = function(number)
	if number <= 100 then
		return {r = 0, g = 1, b = 0}
	elseif number <= 200 then
		return {r = 1, g = 1, b = 0}
	else
		return {r = 1, g = 0, b = 0}
	end
end

local memory, addon, i
local latency, latencyColor, totalMemory
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
local OnUpdate = function(self, elapsed)
	delay1 = delay1 - elapsed
	delay2 = delay2 - elapsed

	if delay1 < 0 then
		UpdateMemory(self)
		memText = FormatMemoryNumber(totalMemory)
		lagText = string.format("%d |cffD7BEA5ms|r", select(3, GetNetStats()))
		delay1 = 5
	end

	if delay2 < 0 then
		fpsText = string.format("%.1f |cffD7BEA5fps|r", GetFramerate())
--		caelStats.system:SetText(memText.."  -  "..lagText.."  -  "..fpsText)
		caelStats.system:SetFormattedText("%s - %s - %s", memText, lagText, fpsText)
		delay2 = 1
	end
end

local OnEnter = function(self)
	if IsShiftKeyDown() then
		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 5)

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
end

local OnClick = function(self, button)
	if button == "LeftButton" then
		local collected = collectgarbage("count")
		collectgarbage("collect")
		GameTooltip:AddDoubleLine("---------- ----------", "---------- ----------", 0.55, 0.57, 0.61, 0.55, 0.57, 0.61)
		GameTooltip:AddDoubleLine("Garbage Collected:", FormatMemoryNumber(collected - collectgarbage("count")), 0.84, 0.75, 0.65, 0.65, 0.63, 0.35)
		GameTooltip:Show()
	end
end

Holder:EnableMouse(true)
Holder:SetAllPoints(caelStats.system)
Holder:SetScript("OnEnter", OnEnter)
Holder:SetScript("OnLeave", function() GameTooltip:Hide() end)
Holder:SetScript("OnMouseDown", OnClick)
Holder:SetScript("OnUpdate", OnUpdate)