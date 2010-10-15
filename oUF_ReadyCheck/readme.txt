Here's an example for your layouts.

	local readycheck = hp:CreateTexture(nil, "OVERLAY")
	readycheck:SetHeight(16)
	readycheck:SetWidth(16)
	readycheck:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -8, 8)
	readycheck:Hide()
	self.ReadyCheck = readycheck