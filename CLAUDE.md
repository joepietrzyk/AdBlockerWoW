# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

AdBlockerWoW is a World of Warcraft addon (Interface: 120000 / The War Within) that silently drops chat messages selling AotC boosts, Mythic+ carries, and gold. It uses WoW's `ChatFrame_AddMessageEventFilter` API so filtered messages never appear in chat.

## Linting

```bash
luacheck .
```

The devcontainer installs `lua5.1` and `luacheck` automatically. CI runs `luacheck .` on every push. All globals must be declared in `.luacheckrc` — add new addon-written globals to `globals` and WoW/Lua API globals to `read_globals`.

## Releasing

Push a `v*` tag (e.g. `git tag v1.0.0 && git push origin v1.0.0`). The `release.yml` workflow runs [BigWigsMods/packager](https://github.com/BigWigsMods/packager), which strips dev files (listed in `.pkgmeta`) and creates a GitHub release with a zip ready for manual install or CurseForge upload.

## Architecture

File load order is determined by the `.toc`:

1. **`Locales/enUS.lua`** — Creates `AdBlockerWoW_L` (the global locale table). Must load first; all other files read from it.
2. **`Core.lua`** — Defines the `AdBlockerWoW` addon table. Handles `ADDON_LOADED` (initialises `AdBlockerWoWDB` SavedVariables with defaults) and `PLAYER_LOGIN` (calls `Filters:Register()`). Exposes `AdBlockerWoW:IsEnabled()`.
3. **`Filters.lua`** — Defines the `Filters` global. `Filters:Register()` / `Filters:Unregister()` add or remove `onChatMessage` as a filter on each event in `WATCHED_EVENTS` via `ChatFrame_AddMessageEventFilter`. The filter function checks the lowercased message against `SERVICE_PATTERNS` (Lua patterns) and returns `true` to suppress a match. Increments `Filters.sessionBlocked` on each suppressed message.
4. **`UI.lua`** — Creates `AdBlockerWoWStatsFrame`, a draggable backdrop window showing the session blocked count (updates every 0.5 s). Registers the `/abw` slash command to toggle the window. Stores the frame at `AdBlockerWoW.statsFrame`.

### Adding a new filter pattern

Add an entry to `SERVICE_PATTERNS` in [Filters.lua](Filters.lua):

```lua
{ pattern = "your%s*pattern", description = "human label" },
```

Patterns are matched case-insensitively (message is lowercased before matching). Use Lua pattern syntax (`%s`, `%d`, `%+`, etc.).

### Adding a new watched chat channel

Add the event name to `WATCHED_EVENTS` in [Filters.lua](Filters.lua) and add it to `read_globals` in [.luacheckrc](.luacheckrc) and `Lua.diagnostics.globals` in [.luarc.json](.luarc.json) if the linters complain.

### SavedVariables / settings

`AdBlockerWoWDB` (declared in the `.toc`) persists between sessions. Default values live in `defaults` in [Core.lua](Core.lua). Current keys: `enabled` (bool) and `logBlocked` (bool). Add new settings there and access them via `AdBlockerWoW.db`.

### Localization

Strings live in [Locales/enUS.lua](Locales/enUS.lua) and are accessed via the module-local alias `local L = AdBlockerWoW_L`. Add new keys there before referencing them in other files.
