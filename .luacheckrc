std = "none"
max_line_length = false
unused_args = false
exclude_files = {".luarocks"}

-- Addon globals written by this addon (including the locale table set by Locales/enUS.lua)
globals = {
    "AdBlockerWoW",
    "AdBlockerWoWDB",
    "AdBlockerWoW_L",
    "Filters",
    "SLASH_ADBLOCKERWOW1",
    "SlashCmdList",
}

-- WoW API and Lua standard library globals read but not written by this addon
read_globals = {

    -- Lua
    "ipairs",
    "pairs",
    "print",
    "select",
    "string",
    "tostring",
    "tonumber",
    "type",
    "unpack",
    "setmetatable",
    "getmetatable",
    "rawget",
    "rawset",
    "next",

    -- WoW API
    "CreateFrame",
    "ChatFrame_AddMessageEventFilter",
    "ChatFrame_RemoveMessageEventFilter",
    "UIParent",
}
