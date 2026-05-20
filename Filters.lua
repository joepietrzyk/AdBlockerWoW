Filters = {}
local L = AdBlockerWoW_L

-- Channel event types to intercept
local WATCHED_EVENTS = {
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_TRADE",
    "CHAT_MSG_GENERAL",
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
}

-- Patterns that identify service-selling messages.
-- Each entry: { pattern (lowercase), description }
local SERVICE_PATTERNS = {
    -- AotC boosting
    { pattern = "aotc",             description = "AotC" },
    { pattern = "ahead of the curve", description = "AotC" },

    -- Mythic+ timed runs
    { pattern = "timed%s*%+?%s*%d", description = "timed M+" },
    { pattern = "mythic%+?%s*carry", description = "M+ carry" },
    { pattern = "m%+%s*boost",       description = "M+ boost" },
    { pattern = "keystone%s*boost",  description = "keystone boost" },

    -- Gold selling
    { pattern = "wts%s*gold",       description = "gold" },
    { pattern = "selling%s*gold",   description = "gold" },
    { pattern = "buy%s*gold",       description = "gold" },
    { pattern = "gold%s*for%s*sale", description = "gold" },
    { pattern = "g%s*=%s*%$",       description = "gold RMT" },
}

local function messageMatchesFilter(message)
    local lower = message:lower()
    for _, entry in ipairs(SERVICE_PATTERNS) do
        if lower:find(entry.pattern) then
            return true, entry.description
        end
    end
    return false, nil
end

local function onChatMessage(self, event, message, sender)
    if not AdBlockerWoW:IsEnabled() then return end

    local blocked = messageMatchesFilter(message)
    if blocked then
        if AdBlockerWoW.db.logBlocked then
            print(string.format(L["MSG_BLOCKED"], sender or "?"))
        end
        -- Returning true suppresses the message from appearing in chat.
        return true
    end
end

function Filters:Register()
    for _, event in ipairs(WATCHED_EVENTS) do
        ChatFrame_AddMessageEventFilter(event, onChatMessage)
    end
end

function Filters:Unregister()
    for _, event in ipairs(WATCHED_EVENTS) do
        ChatFrame_RemoveMessageEventFilter(event, onChatMessage)
    end
end
