# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

LavUI is a personal World of Warcraft (retail) addon built on Ace3. It started as a
port of [ZoxeTweaks](https://github.com/geek0x23/ZoxeTweaks) and adds small
utilities/tweaks that complement a specific addon stack: **AtrocityUI /
AtrocityEssentials (AES)**, **EllesmereUI**, and **BigWigs**. It is not a
standalone UI replacement — most modules read live config from those other addons
rather than duplicating settings, and several only make sense in that environment.

There is no build step, package manager, or test suite in the conventional sense —
this is Lua loaded directly by the WoW client. "Testing" means `/reload` (or relog)
in-game.

## Build / release

- `build.cmd` runs `release.sh` (via WSL) to stage a `.release/LavUI` symlink tree
  for local testing — `release.sh` is the vendored [BigWigsMods packager
  script](https://github.com/BigWigsMods/packager); don't hand-edit it.
- Actual releases are cut by pushing a git tag; `.github/workflows/release.yml` runs
  the BigWigsMods packager action, which uploads to CurseForge/Wago/GitHub using
  `.pkgmeta`.
- `.pkgmeta` also declares the `Libs/` externals (Ace3 modules, fetched from the
  WoWAce svn mirror at package time) — `Libs/` is gitignored and not present in a
  fresh checkout; it only exists after packaging.

## Architecture

Load order is defined in `LavUI.toc`:

1. `embeds.xml` — pulls in the Ace3 libraries (AceAddon, AceConfig, AceConsole,
   AceDB, AceGUI, AceHook, CallbackHandler, LibStub) from `Libs/`.
2. `LavUI.lua` — bootstraps the addon via `AceAddon-3.0:NewAddon`, exposes it as the
   global `LUI`, wires up `AceDB` (`LavUIDB` saved variable), `AceConfig`, and the
   `/lui` slash command.
3. `Utils.lua` — shared helpers hung directly on `LUI` (`LUI:Debug`,
   `LUI:InCombat`, string helpers). `LUI:Debug` no-ops unless DevTool is loaded.
4. `Options.lua` — the single source of truth for config: `LUI:GetDefaults()`
   returns the `AceDB` defaults schema, `LUI:GetOptions()` returns the
   `AceConfig` options table. Every module's enabled state lives under
   `LUI.db.global.*` and options toggles call `Module:Enable()` /
   `Module:Disable()` directly.
5. `Bindings.lua` — keybinding headers/handlers (`BINDING_HEADER_*` /
   `BINDING_NAME_*` globals + the function they invoke). Keep these as thin
   delegators to the owning module (see `LUI:TogglePanel` → `ChatPanel:TogglePanel`)
   rather than putting real logic here.
6. `Commands.lua` — currently just a stray `SLASH_BTWQUESTS2` binding; unrelated to
   the rest of the addon.
7. `Modules/*.lua` — each file is an `AceAddon` module created with
   `LUI:NewModule("Name", ...mixins)`, typically `AceHook-3.0` and/or
   `AceEvent-3.0`. Modules follow the standard Ace lifecycle:
    - `OnInitialize` — call `self:SetEnabledState(LUI.db.global.<key>)` so the
      module comes up (or doesn't) matching saved config.
    - `OnEnable` — do the actual hooking/setup; bail early if the relevant config
      flag is off (defensive, since `Enable()` can be called directly from
      `Options.lua`).
    - `OnDisable` — `self:UnhookAll()` and cancel any timers.
    - Modules talk to each other and to the addon only through the global `LUI`
      table and `LUI.db` — there are no direct module-to-module requires.

### Integrating with other addons

A recurring pattern (most fully worked out in `Modules/ChatPanel.lua`) is reading
another addon's live SavedVariables/db instead of mirroring its settings:
`LibStub("AceAddon-3.0"):GetAddon("atrocityEssentials", true):GetModule("Chat",
true)`, then re-reading its db table on every use (never cached — a profile switch
hands back a different table). When touching a frame owned by another addon, prefer
anchoring/hooking around its behavior (`SecureHook`, `SecureHookScript`,
`SetPoint` without reparenting) over fighting it, and leave a comment explaining
_which_ upstream behavior is being worked around — see the header comment in
`ChatPanel.lua` for the reference example.

### Combat safety

Blizzard taints/errors on frame mutation during combat. Anything that calls
`SetScale`, moves protected frames, etc. must check `LUI:InCombat()` first (see
`Modules/Scaling.lua`'s `ScaleGuard`). `LUI:InCombat()` checks `InCombatLockdown()`
plus player/pet affecting-combat state.

## Style

- 4-space indent, LF line endings, final newline (`.editorconfig`); Lua lines are
  not length-limited.
- EmmyLua-style annotations (`---@class`, `---@param`, `---@return`, inline
  `---@type`) are used throughout, including ad-hoc `---@class` casts at
  point-of-use to type an `AceModule` return from `self:GetModule(...)`. Match this
  when adding new modules or options.
- Comments explain _why_ (upstream quirks, taint constraints, non-obvious
  ordering), not what the code does.
