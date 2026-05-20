local addonName, _ = ...

AdBlockerWoW = {}
local addon = AdBlockerWoW
local L = AdBlockerWoW_L

local defaults = {
    enabled = true,
    logBlocked = false,
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            addon:OnLoad()
        end
    elseif event == "PLAYER_LOGIN" then
        addon:OnLogin()
    end
end)

function addon:OnLoad()
    AdBlockerWoWDB = AdBlockerWoWDB or {}
    for k, v in pairs(defaults) do
        if AdBlockerWoWDB[k] == nil then
            AdBlockerWoWDB[k] = v
        end
    end
    self.db = AdBlockerWoWDB
end

function addon:OnLogin()
    print(L["ADDON_LOADED"])
    Filters:Register()
end

function addon:IsEnabled()
    return self.db and self.db.enabled
end
