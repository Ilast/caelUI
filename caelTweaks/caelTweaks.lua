caelTweaks = CreateFrame("Frame")

local print = function(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffD7BEA5cael|rTweaks: "..tostring(text))
end

format = string.format

OnEvent = function(self, event, ...)
	if type(self[event]) == 'function' then
		return self[event](self, event, ...)
	else
		print(string.format("Unhandled event: %s", event))
	end
end

caelTweaks:SetScript("OnEvent", OnEvent)