local addon = AdBlockerWoW
local L = AdBlockerWoW_L

local options = {
    type = "group",
    name = "AdBlockerWoW",
    get = function(info)
        return addon.db.profile[info[#info]]
    end,
    set = function(info, val)
        addon.db.profile[info[#info]] = val
        if info[#info] == "enabled" then
            if val then
                Filters:Register()
            else
                Filters:Unregister()
            end
        end
    end,
    args = {
        enabled = {
            type = "toggle",
            name = L["SETTING_ENABLED"],
            desc = L["SETTING_ENABLED_DESC"],
            order = 1,
        },
        logBlocked = {
            type = "toggle",
            name = L["SETTING_LOG"],
            desc = L["SETTING_LOG_DESC"],
            order = 2,
        },
        sessionCount = {
            type = "description",
            name = function()
                return string.format(L["STATS_BLOCKED"], Filters.sessionBlocked)
            end,
            fontSize = "medium",
            order = 3,
        },
    },
}

function addon:SetupOptions()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("AdBlockerWoW", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AdBlockerWoW", "AdBlockerWoW")

    local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("AdBlockerWoW_Profiles", profileOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AdBlockerWoW_Profiles", L["PROFILES"], "AdBlockerWoW")
end
