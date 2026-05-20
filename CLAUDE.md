# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

AdBlockerWoW is a World of Warcraft addon (Interface: 120000 / The War Within) that silently drops chat messages selling AotC boosts, Mythic+ carries, and gold. It uses WoW's `ChatFrame_AddMessageEventFilter` API so filtered messages never appear in chat.

## Linting

```bash
luacheck .
```

The devcontainer installs `lua5.1` and `luacheck` automatically. CI runs `luacheck .` on every push. All globals must be declared in `.luacheckrc` — add new addon-written globals to `globals` and WoW/Lua API globals to `read_globals`.

The VS Code Lua language server uses `.luarc.json` (`Lua.diagnostics.globals`) for IDE diagnostics. There is no way to share config between the two files — they use incompatible formats. This duplication is the community norm; projects like WeakAuras and Ace3 do the same. When adding a new global, update both files.

## Releasing

Push a `v*` tag (e.g. `git tag v1.0.0 && git push origin v1.0.0`). The `release.yml` workflow runs [BigWigsMods/packager](https://github.com/BigWigsMods/packager), which fetches Ace3 libraries via the `.pkgmeta` externals, strips dev files, and creates a GitHub release with a zip ready for manual install or CurseForge upload.

## Libraries (Ace3)

Ace3 libraries live in `Libs/` which is **gitignored**. They are fetched in two ways:

- **Local dev**: run `.devcontainer/fetch-libs.sh` (or rebuild the devcontainer — `postCreateCommand` runs it automatically). Requires `subversion`.
- **Release**: BigWigsMods/packager fetches them via the `externals` block in `.pkgmeta`.

Libraries in use: LibStub, CallbackHandler-1.0, AceAddon-3.0, AceDB-3.0, AceDBOptions-3.0, AceGUI-3.0, AceConfig-3.0 (bundles AceConfigCmd-3.0, AceConfigDialog-3.0, AceConfigRegistry-3.0).

## Architecture

File load order is determined by the `.toc`. Libraries load first, then:

1. **`Locales/enUS.lua`** — Creates `AdBlockerWoW_L` (the global locale table). Must load first; all other files read from it.
2. **`Core.lua`** — Creates the `AdBlockerWoW` addon via `AceAddon:NewAddon`. `OnInitialize` sets up the AceDB database and calls `SetupOptions`. `OnEnable` registers filters. Exposes `AdBlockerWoW:IsEnabled()`.
3. **`Filters.lua`** — Defines the `Filters` global. `Filters:Register()` / `Filters:Unregister()` add or remove `onChatMessage` as a filter on each event in `WATCHED_EVENTS` via `ChatFrame_AddMessageEventFilter`. The filter function checks the lowercased message against `SERVICE_PATTERNS` (Lua patterns) and returns `true` to suppress a match. Increments `Filters.sessionBlocked` on each suppressed message.
4. **`UI.lua`** — Creates `AdBlockerWoWStatsFrame`, a draggable backdrop window showing the session blocked count (updates every 0.5 s). Registers the `/abw` slash command to toggle the window. Stores the frame at `AdBlockerWoW.statsFrame`.
5. **`Settings.lua`** — Defines `addon:SetupOptions()`, called from `OnInitialize`. Registers an AceConfig options table and adds it to Interface → AddOns as "AdBlockerWoW", with a Profiles sub-panel via AceDBOptions.

### Adding a new filter pattern

Add an entry to `SERVICE_PATTERNS` in [Filters.lua](Filters.lua):

```lua
{ pattern = "your%s*pattern", description = "human label" },
```

Patterns are matched case-insensitively (message is lowercased before matching). Use Lua pattern syntax (`%s`, `%d`, `%+`, etc.).

### Adding a new watched chat channel

Add the event name to `WATCHED_EVENTS` in [Filters.lua](Filters.lua) and add it to `read_globals` in [.luacheckrc](.luacheckrc) and `Lua.diagnostics.globals` in [.luarc.json](.luarc.json) if the linters complain.

### Adding a new setting

1. Add a default value to `defaults.profile` in [Core.lua](Core.lua).
2. Add an `args` entry to the options table in [Settings.lua](Settings.lua).
3. Add a locale string to [Locales/enUS.lua](Locales/enUS.lua).
4. Access the value at runtime via `AdBlockerWoW.db.profile.<key>`.

### SavedVariables / settings

`AdBlockerWoWDB` (declared in the `.toc`) persists between sessions. Managed by AceDB-3.0. Default values live in `defaults` in [Core.lua](Core.lua) under the `profile` key. Current keys: `enabled` (bool) and `logBlocked` (bool). Access settings via `AdBlockerWoW.db.profile`.

### Localization

Strings live in [Locales/enUS.lua](Locales/enUS.lua) and are accessed via the module-local alias `local L = AdBlockerWoW_L`. Add new keys there before referencing them in other files.
