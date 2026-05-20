# AdBlockerWoW

A World of Warcraft addon that silently filters boost and gold-selling spam from chat.

## What it does

AdBlockerWoW automatically hides chat messages that advertise paid services:

- **AotC carries** — "AOTC", "Ahead of the Curve"
- **Mythic+ boosts** — timed runs, M+ carries, keystone boosts
- **Gold selling** — WTS gold, buying/selling gold for real money

Filtered messages are dropped before they ever appear in your chat window — no strike-through, no replacement text, just gone.

## Installation

1. Download the latest release zip from the [Releases](../../releases) page.
2. Extract the `AdBlockerWoW` folder into your addons directory:
   ```
   World of Warcraft/_retail_/Interface/AddOns/
   ```
3. Restart WoW or reload your UI (`/reload`).

You should see `AdBlockerWoW loaded. Filtering service spam.` in chat when it's active.

## Options

There are no slash commands yet. Two settings can be toggled directly in the SavedVariables (`AdBlockerWoWDB`) or by a future settings UI:

| Key | Default | Effect |
|---|---|---|
| `enabled` | `true` | Master on/off switch |
| `logBlocked` | `false` | Print a notice to chat each time a message is blocked |

## Compatibility

Tested on **The War Within** (Interface 120000). It hooks WoW's built-in `ChatFrame_AddMessageEventFilter` API, so it is compatible with other chat addons.

## Contributing

Pull requests are welcome. To add a new filter pattern, edit the `SERVICE_PATTERNS` table in `Filters.lua` — each entry is a Lua pattern matched case-insensitively against the message text. Run `luacheck .` before submitting to catch any lint errors.
