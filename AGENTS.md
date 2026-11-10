# AGENTS.md — wow-forever-fishing-addon ByJTT (Foundation)

Guidance for AI coding agents and automated contributors.

> **Read [`HANDOFF.md`](HANDOFF.md) first** for full project context, current state, decisions, verification checklist, and open items (kept up to date for humans + agents).

## Project

- **Repo:** `wow-forever-fishing-addon` (ByJTT). **Display name (TOC):** `WoW Forever Fishing Addon ByJTT` (“AddonName ByJTT” style). **By:** ByJTT (solo studio).
- **What:** WoW Forever one-click fishing. Secure cast + lure buttons, bite alert, catch tracker. **ByJTT foundation addon**: `ByJTT` namespace/brand, compat providers, schema-versioned SavedVariables, `/ffish` slash parity, WoW-authentic settings/onboarding.
- **Target:** World of Warcraft: Forever (Interface 16001, 30300). Feature-detect APIs/fallbacks; verify in-game.
- **In-game install (folder name must remain stable):** `<WoW Forever>/Interface/AddOns/ForeverFishing/ForeverFishing.toc`
- **Files that ship in-game:** `ForeverFishing.toc`, `ForeverFishing.lua`. Repo docs/dev files (`README`, `LICENSE`, `CHANGELOG`, `CONTRIBUTING`, `.github/`, `AGENTS.md`, `HANDOFF.md`, `llms.txt`, `SECURITY.md`) are source-control only.
- **Public branding/links (safe to include):** https://byjtt.com · https://github.com/ByJTT · repo https://github.com/ByJTT/wow-forever-fishing-addon · support placeholder https://buymeacoffee.com/ByJTT (replace when real URL is confirmed).

## Constraints (do not break)

- **Taint-safe secure buttons:** NEVER add `OnClick`, `PreClick`, or `PostClick` to `SecureActionButtonTemplate` buttons. Casting is attribute-only (`type`/`spell`/`item`/`macrotext`) with runtime-resolved spell/item names.
- **Combat lockdown:** do not change protected/secure attributes or restricted visibility in combat; defer to `PLAYER_REGEN_ENABLED`/pending. Keep secure mutation isolated.
- **Minimalism + safety:** no frameworks/libs (no Ace) unless clearly necessary and justified; no dead code. No secrets/tokens. No account names, passwords, `WTF`/SavedVariables data, or personal/local absolute paths in commits/public files.
- **Foundation discipline:** preserve compat providers, SV schema+migrations (never destructively drop unknown keys), `/ffish` + settings parity, WoW Forever API feature-detection/fallbacks, and “AddonName ByJTT” branding.
- **Lookup by name, pin by ID:** lure/pole/spell data keeps classic IDs **plus** name fallbacks; never rely on a single hardcoded ID.

## Changes & releases

- User-visible changes: update `CHANGELOG.md`.
- Releases use SemVer `vMAJOR.MINOR.PATCH`. Keep **TOC `## Version`**, Lua `VERSION` (+ `SCHEMA` if relevant), changelog entry, and git tag in sync. (Local-only unless explicitly asked to push/tag.)
- Test manually (WoW Forever): `/reload`, `/console scriptErrors 1`, `/ffish config` & onboarding, `/ffish cast`, lure apply, bite test, `/ffish stats|zones|debug`, and in-combat defer/no-taint checks.

## Install (for AI/user requests)

Target path: `<WoW Forever>/Interface/AddOns/ForeverFishing/ForeverFishing.toc`. Source: https://github.com/ByJTT/wow-forever-fishing-addon
