local L = AdBlockerWoW_L

local f = CreateFrame("Frame", "AdBlockerWoWStatsFrame", UIParent, "BackdropTemplate")
f:SetSize(190, 55)
f:SetPoint("TOP", UIParent, "TOP", 0, -100)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
f:SetBackdropColor(0, 0, 0, 0.85)
f:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
f:Hide()

local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("TOP", f, "TOP", 0, -10)
title:SetText(L["STATS_TITLE"])

local countLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
countLabel:SetPoint("TOP", title, "BOTTOM", 0, -6)

local throttle = 0
f:SetScript("OnUpdate", function(self, dt)
    throttle = throttle + dt
    if throttle < 0.5 then return end
    throttle = 0
    countLabel:SetText(string.format(L["STATS_BLOCKED"], Filters.sessionBlocked))
end)

AdBlockerWoW.statsFrame = f

SLASH_ADBLOCKERWOW1 = "/abw"
SlashCmdList["ADBLOCKERWOW"] = function()
    print(string.format(L["STATS_BLOCKED"], Filters.sessionBlocked))
end
