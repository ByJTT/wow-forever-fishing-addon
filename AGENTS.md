# AGENTS.md - WoW Forever Fishing Addon ByJTT (repo root)

> Canonical instructions for AI coding agents working in this repo. Human-facing overview: [README.md](README.md). Full handoff/context: [HANDOFF.md](HANDOFF.md).

## Project overview

- **What:** WoW Forever fishing helper. One smart **Fish!** secure button (equip best pole if needed -> apply lure only if the pole is bare -> cast), bite alert (flash/sound, best-effort), and session/zone/lifetime catch tracking. **ByJTT foundation-style**: compat providers (WoW Forever API fallbacks), schema-versioned SavedVariables, onboarding + WoW-authentic settings (with standalone fallback), `/ffish` slash parity, and diagnostics (`/ffish debug`).
- **Target:** World of Warcraft: Forever (Interface 16001, 30300). Feature-detect APIs/fallbacks; verify in-game.
- **In-game install (folder name must remain stable):** `<WoW Forever>/Interface/AddOns/ForeverFishing/ForeverFishing.toc`
- **Files that ship in-game:** `ForeverFishing.toc`, `ForeverFishing.lua` (as listed in the TOC). Repo docs/dev files (`README`, `LICENSE`, `CHANGELOG`, `CONTRIBUTING`, `.github/`, `AGENTS.md`, `HANDOFF.md`, `llms.txt`, `SECURITY.md`) are source-control only.
- **Public branding/links (safe to include):** https://byjtt.com - https://github.com/ByJTT - repo https://github.com/ByJTT/wow-forever-fishing-addon - support placeholder https://buymeacoffee.com/ByJTT (replace when real URL is confirmed).

## Constraints (do not break)

- **Taint-safe / secure UI:** never attach `OnClick`, `PreClick`, or `PostClick` scripts to secure action buttons; drive actions via attributes only (`type`/`spell`/`item`/`macrotext`). Defer protected/secure changes out of combat (`InCombatLockdown` / `PLAYER_REGEN_ENABLED` / pending flags).
- **Minimal footprint:** no Ace/framework dependencies; single Lua + TOC unless there is a clear, justified reason. Prefer clear, data-driven helpers over duplication.
- **Safe-by-default:** do not automate protected gameplay. No auto-looting (player clicks the bobber), no keypress simulation, no hardware/bot behavior. One-click, player-initiated flow only.
- **Compatibility:** support WoW Forever API variance with feature-detection/fallbacks (Retail vs Classic-style globals). Fail gracefully with `pcall`/guards where needed.
- **Data/SV discipline:** keep SavedVariables schema-versioned (`_schema`) and additive; never destructively drop unknown keys. Preserve migrations/backward compatibility. Keep TOC `## Version`, Lua `VERSION`, and changelog aligned for releases (SemVer).
- **Branding/naming:** preserve "AddonName ByJTT" display style and stable in-game folder name `ForeverFishing`. Document repo vs install name clearly.

## Commands & behavior

- Primary slash: `/ffish`. Key commands: `help`, `config`, `onboarding`, `show|hide`, `cast`, `lure`, `stats`, `zones`, `reset`, `lock|unlock|move`, `scale`, `bite`, `test`, `debug`, `rl`.
- **`cast`** performs the same smart sequence as the Fish button (equip best pole if needed, apply best lure if the pole is bare, then cast) with combat/availability checks. **`lure`** applies the best bag lure out of combat when the pole is bare, with feedback and refresh.
- State/UI should refresh from events (spells, bags/equipment/skill/inventory changes, loot, combat, logout, entering world, and fishing channel state) with coalesced refresh and stay in sync with the secure button plan. Bite detection and loot/catch tracking are best-effort (emote/channel/loot heuristics vary by client) and intentionally non-automated.

## Changes & releases

- Update `CHANGELOG.md` (`[Unreleased]` -> versioned) for user-visible changes and keep `## Version` in TOC + `VERSION`/schema notes in Lua aligned with SemVer tags (`vMAJOR.MINOR.PATCH`) when releasing.
- Preserve backward-compatible settings migrations; document behavior changes in README/changelog.
- Manual verification (WoW Forever): `/reload`, `/console scriptErrors 1`, `/ffish config` & onboarding, `/ffish cast`, `/ffish lure`, `/ffish show|hide`, bite test, `/ffish stats|zones|debug`, and in-combat defer/no-taint checks.

## Security & privacy

- Never commit secrets, tokens, account data, `WTF`/SavedVariables data, or local personal paths. Treat issue reports/logs as public-safe.
- See [SECURITY.md](SECURITY.md).
