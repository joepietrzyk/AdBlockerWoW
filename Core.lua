local addonName = ...

AdBlockerWoW = LibStub("AceAddon-3.0"):NewAddon(addonName)
local addon = AdBlockerWoW
local L = AdBlockerWoW_L

local defaults = {
    profile = {
        enabled = true,
        logBlocked = false,
    }
}

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("AdBlockerWoWDB", defaults, true)
    self:SetupOptions()
end

function addon:OnEnable()
    print(L["ADDON_LOADED"])
    if self.db.profile.enabled then
        Filters:Register()
    end
end

function addon:IsEnabled()
    return self.db and self.db.profile.enabled
end
