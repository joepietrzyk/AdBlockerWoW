Filters = {}
Filters.sessionBlocked = 0

local L = AdBlockerWoW_L

-- Channel event types to intercept
local WATCHED_EVENTS = {
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_WHISPER",
}

-- Words that usually mean a normal guild/community recruitment post.
-- These reduce the spam score.
local RECRUITMENT_PATTERNS = {
    "guild",
    "recruit",
    "recruiting",
    "recruitment",
    "roster",
    "raid team",
    "core team",
    "progression",
    "casual",
    "social",
    "community",
    "looking for players",
    "lf players",
    "lfm guild",
    "aotc guild",
    "mythic guild",
    "heroic guild",
    "normal guild",
    "apply",
}

-- Very strong spam/service signs.
local HARD_BLOCK_PATTERNS = {
    -- WTS variants
    "wts",
    "w t s",
    "w%-t%-s",
    "w%.t%.s",
    "w%s*t%s*s",

    -- Selling variants
    "selling",
    "sell runs",
    "sell run",
    "sell boost",
    "sell boosts",
    "selling runs",
    "selling boost",
    "selling boosts",
    "selling carry",
    "selling carries",

    -- Service wording
    "boosting service",
    "boost service",
    "carry service",
    "services",
    "service available",
    "gold only",
    "payment gold",
    "pay with gold",
    "cheap price",
    "best price",
    "discount",
    "booking",
    "book now",
    "order now",
}

-- WoW service content.
local SERVICE_PATTERNS = {
    "boost",
    "boosting",
    "carry",
    "carries",
    "run",
    "runs",
    "mythic",
    "mythic%+",
    "m%+",
    "keystone",
    "key",
    "keys",
    "timed",
    "untimed",
    "aotc",
    "ahead of the curve",
    "curve",
    "raid boost",
    "raid carry",
    "heroic raid",
    "mythic raid",
    "normal raid",
    "delve",
    "delves",
    "pvp boost",
    "arena boost",
    "rbg",
    "mount run",
    "mount boost",
    "leveling",
    "powerlevel",
}

-- Currency / transaction wording.
local MONEY_PATTERNS = {
    "gold",
    "g0ld",
    "price",
    "prices",
    "payment",
    "pay",
    "buyer",
    "buyers",
    "token",
    "cheap",
    "discount",
}

-- Contact / sales style.
local CONTACT_PATTERNS = {
    "dm",
    "pm",
    "pst",
    "whisper",
    "w me",
    "message me",
    "for info",
    "for details",
}

local function normalizeMessage(message)
    local lower = (message or ""):lower()

    -- Remove WoW texture/icon links and color codes a bit.
    lower = lower:gsub("|c%x%x%x%x%x%x%x%x", "")
    lower = lower:gsub("|r", "")
    lower = lower:gsub("|t", "")
    lower = lower:gsub("|T.-|t", "")
    lower = lower:gsub("|H.-|h", "")
    lower = lower:gsub("|h", "")

    -- Convert common separators into spaces.
    lower = lower:gsub("[%[%]%(%){}<>_/\\|,:;!%?%*#@]", " ")
    lower = lower:gsub("%s+", " ")

    return lower
end

local function compactMessage(message)
    local lower = (message or ""):lower()

    -- This version removes separators/spaces to catch stuff like W T S, W-T-S, W.T.S.
    lower = lower:gsub("|c%x%x%x%x%x%x%x%x", "")
    lower = lower:gsub("|r", "")
    lower = lower:gsub("|T.-|t", "")
    lower = lower:gsub("|H.-|h", "")
    lower = lower:gsub("|h", "")

    lower = lower:gsub("[%s%p%c]", "")

    return lower
end

local function containsAny(text, patterns)
    for _, pattern in ipairs(patterns) do
        if text:find(pattern) then
            return true, pattern
        end
    end

    return false, nil
end

local function countMatches(text, patterns)
    local count = 0

    for _, pattern in ipairs(patterns) do
        if text:find(pattern) then
            count = count + 1
        end
    end

    return count
end

local function isRecruitment(text)
    local found = containsAny(text, RECRUITMENT_PATTERNS)
    return found
end

local function messageMatchesFilter(message)
    local text = normalizeMessage(message)
    local compact = compactMessage(message)

    -- Directly catch WTS even when written as W T S / W-T-S / W.T.S.
    if compact:find("wts") then
        return true, "WTS"
    end

    -- Directly catch obvious gold/service seller combos.
    if text:find("gold only") then
        return true, "gold only"
    end

    if text:find("selling") and (
        text:find("boost") or
        text:find("carry") or
        text:find("run") or
        text:find("key") or
        text:find("raid") or
        text:find("aotc") or
        text:find("curve") or
        text:find("gold")
    ) then
        return true, "selling service"
    end

    if text:find("sell") and (
        text:find("boost") or
        text:find("carry") or
        text:find("run") or
        text:find("key") or
        text:find("raid") or
        text:find("aotc") or
        text:find("curve") or
        text:find("gold")
    ) then
        return true, "sell service"
    end

    -- Score-based filter.
    local score = 0

    score = score + countMatches(text, HARD_BLOCK_PATTERNS) * 4
    score = score + countMatches(text, SERVICE_PATTERNS) * 2
    score = score + countMatches(text, MONEY_PATTERNS) * 2
    score = score + countMatches(text, CONTACT_PATTERNS) * 1

    -- Common sales spam formatting.
    if text:find(">>") or text:find("<<") then
        score = score + 1
    end

    if text:find("www") or text:find("%.com") or text:find("discord%.gg") or text:find("http") then
        score = score + 4
    end

    -- Recruitment protection.
    -- Example allowed:
    -- "Guild recruiting for heroic raid progression"
    -- Example still blocked:
    -- "Guild selling AOTC boost gold only"
    if isRecruitment(text) then
        score = score - 5
    end

    if score >= 7 then
        return true, "service spam"
    end

    return false, nil
end

local function onChatMessage(self, event, message, sender)
    if not AdBlockerWoW:IsEnabled() then return false end

    local blocked, reason = messageMatchesFilter(message)

    if blocked then
        Filters.sessionBlocked = Filters.sessionBlocked + 1

        if AdBlockerWoW.db.logBlocked then
            if L and L["MSG_BLOCKED"] then
                print(string.format(L["MSG_BLOCKED"], sender or "?"))
            else
                print(string.format("|cffff5555AdBlocker blocked message from %s.|r Reason: %s", sender or "?", reason or "unknown"))
            end
        end

        return true
    end

    return false
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