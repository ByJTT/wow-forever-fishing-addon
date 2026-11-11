# HANDOFF.md — wow-forever-fishing-addon ByJTT

> **Single-source handoff/status for humans and AI agents.** Read this first to get full context without re-explaining the project. Keep it updated when state/decisions change.
>
> - Repo: `ByJTT/wow-forever-fishing-addon` (public) — https://github.com/ByJTT/wow-forever-fishing-addon
> - Display name (TOC, “AddonName ByJTT”): **WoW Forever Fishing Addon ByJTT**
> - By: **ByJTT** (solo studio) — https://byjtt.com · https://github.com/ByJTT
> - Support (PLACEHOLDER — replace before release/marketing): https://buymeacoffee.com/ByJTT
> - Target: **World of Warcraft: Forever** (Interface `16001, 30300`), feature-detected API fallbacks
> - **In-game folder name must remain `ForeverFishing`** (repo name ≠ install folder name)
> - License: MIT

## Current state (as of 2026-11-10)

**v1.0.0 foundation is implemented locally. NOT yet pushed, NOT yet verified in-game on WoW Forever.**

### What’s shipped in code (working baseline intent)
- **Taint-safe secure core (do not break):** `SecureActionButtonTemplate`, attribute-only actions (`type`/`spell`/`item`/`macrotext`) with runtime-resolved names; **NO** `OnClick`/`PreClick`/`PostClick` on secure buttons; protected/secure attribute or restricted visibility changes **deferred out of combat** (`InCombatLockdown` / `pendingSecure` → `PLAYER_REGEN_ENABLED`). Read/apply split.
- **ByJTT foundation:** `ByJTT.Brand`/`ByJTT.Addons.ForeverFishing` namespace, compat providers (`pcall`/feature-detect for `C_Spell`/`GetSpellInfo`, `GetItemCount`, profession APIs, zone APIs), schema-versioned SavedVariables (`_schema=1`, additive migrations, **never destructively drop unknown keys**).
- **Features v1:** one smart **Fish!** button (macro: equip best pole → apply best lure only if pole is bare → cast), bite alert (emote-driven flash + sound), catch tracker (session/zone/lifetime from own `CHAT_MSG_LOOT`), session counters, `/ffish` slash parity + settings + onboarding + debug.
- **Branding:** “AddonName ByJTT” style — display/TOC: `WoW Forever Fishing Addon ByJTT`. byjtt.com + GitHub links. Support is a **PLACEHOLDER** URL in TOC/Lua/docs/UI (`https://buymeacoffee.com/ByJTT`) — replace with the real Buy Me a Coffee URL everywhere before release/marketing.
- **Docs/contract:** `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, `CHANGELOG.md` (v1.0.0 noted local/not yet tagged+released), `llms.txt`, `.github/*`.

## In-game files (ship/install)
- `ForeverFishing.toc`, `ForeverFishing.lua`. Everything else is repo/docs.
- Install path: `<WoW Forever>/Interface/AddOns/ForeverFishing/ForeverFishing.toc` (folder name **`ForeverFishing`**).

## Key commands (in game)
`/ffish help|config|cast|lure|stats|zones|reset|lock|unlock|move|scale|bite|test|debug|onboarding|rl`. Enable Lua errors: `/console scriptErrors 1`.

## Verification checklist (do this in-game on WoW Forever first)
1. `/reload` + `/console scriptErrors 1` — **no Lua errors/taint**.
2. **Cast:** Fish button casts Fishing; Lure button appears with lures in bags and applies best lure; `/ffish cast`, `/ffish lure` work.
3. **Bite + tracker:** `/ffish test` flashes + sounds; real bite flashes; catches increment `/ffish stats` + `/ffish zones`.
4. **Combat/lockdown:** in combat, no protected attribute/visibility churn/taint (deferred); after leaving combat refresh applies.
5. **UX:** onboarding appears once (re-open via `/ffish onboarding`), `/ffish config` opens (or fallback), drag/lock/scale/bite toggle/reset work.
6. **Data tuning:** confirm lure IDs/names and Fishing spell resolution for WoW Forever via `/ffish debug`; prefer ID + name fallback coverage.

## Open items / next steps (priority)
1. **Syntax check + push:** `luac -p ForeverFishing.lua`, commit, push to `origin/main`.
2. **In-game verification on WoW Forever (Mac):** run the checklist above; fix any client-specific API/event/Settings issues (feature-detect/pcall). Lure/spell IDs are **best-effort** and likely need tuning from `/ffish debug` + real testing.
3. **Replace Buy Me a Coffee placeholder** `https://buymeacoffee.com/ByJTT` with the real URL in: `ForeverFishing.lua` (`ByJTT.Brand.support`), `ForeverFishing.toc` (`X-ByJTT-Support`), `README.md`, `AGENTS.md`, `llms.txt`, `CHANGELOG.md` notes, and in-game About/onboarding text.
4. **Local install for testing:** copy/symlink repo `ForeverFishing/` files to `<WoW Forever>/Interface/AddOns/ForeverFishing/`.
5. **Decide SemVer/release when verified:** `v1.0.0` is set — sync TOC `## Version` + Lua `VERSION`/`SCHEMA` + `CHANGELOG` + git tag `vX.Y.Z` + GitHub release **only when explicitly requested**.
6. **Future (post-v1):** pole-equip helper, auto re-lure prompt, per-character profiles, tournament mode. Keep minimal until v1 is verified.

## Architecture anchors (quick)
- `ForeverFishing.lua`: header/brand/ns, constants (spell/poles/lures), compat, SV schema+migration, UI root + secure buttons (`UpdateSecure`/`pendingSecure`), tracker state, BuildButtonStates/ApplyStates, onboarding, options (feature-detected), events (bite + loot), slash (`/ffish`). **Central invariant:** no secure handlers; no protected changes in combat.
- `ForeverFishing.toc`: metadata/version/SV/`X-ByJTT-*`/load order.
- `AGENTS.md`: agent rules (taint, lockdown, privacy, migrations, SemVer sync).

## How to work (Mac/local)
```sh
cd /Users/jordanthirkle/repos/wow-forever-fishing-addon
# edit, then copy to: /Applications/World of Warcraft/_forever_/Interface/AddOns/ForeverFishing/
# /reload in game; keep taint-safety invariants
git add -A && git commit -m "..." && git push origin main  # only when ready
```
Use `/ffish debug` + `/console scriptErrors 1` for every change. No personal data/local absolute paths/secrets in commits. No Ace/deps unless justified.

## Decisions log (why)
- **“AddonName ByJTT”** display style; in-game folder/`ADDON_NAME` remain `ForeverFishing` for loader stability (repo name SEO-friendly). By = solo studio **ByJTT** (not a personal name in branding).
- **1 Lua + TOC, no libs** for low risk/simple install; mirrors the buff-reminder foundation pattern.
- **Best-in-bags lure, not auto-lure** (v1): one-click apply keeps the player in control; fully automatic re-luring risks taint/combat edge cases.
- **Emote-driven bite alert** (v1): no dedicated bobber event exists; channel-state + emote match is the classic reliable cue. Sound ID reused from foundation (verify in-game).
- **Local-only until verified**; tag/release only after verification + real support URL.
