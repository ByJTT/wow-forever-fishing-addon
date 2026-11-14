# HANDOFF.md - wow-forever-fishing-addon ByJTT

> **Single-source handoff/status for humans and AI agents.** Read this first to get full context without re-explaining the project. Keep it updated when state/decisions change.
>
> - Repo: `ByJTT/wow-forever-fishing-addon` (public) - https://github.com/ByJTT/wow-forever-fishing-addon
> - Display name (TOC, "AddonName ByJTT"): **WoW Forever Fishing Addon ByJTT**
> - By: **ByJTT** (solo studio) - https://byjtt.com - https://github.com/ByJTT
> - Support (PLACEHOLDER - replace before release/marketing): https://buymeacoffee.com/ByJTT
> - Target: **World of Warcraft: Forever** (Interface `16001, 30300`), feature-detected API fallbacks
> - **In-game folder name must remain `ForeverFishing`** (repo name != install folder name)
> - License: MIT

## Current state (as of 2026-11-14, autopilot continuation)

**Working tree clean and in sync with `origin/main`** (`https://github.com/ByJTT/wow-forever-fishing-addon.git`, branch `main`). Latest: `dfd9471 feat: add update-notify settings toggle and CurseForge release prep`. It has **NOT** been fully verified in-game on WoW Forever.

### What's shipped in code (working baseline intent)
- **Taint-safe secure core (do not break):** `SecureActionButtonTemplate`, attribute-only actions (`type`/`spell`/`item`/`macrotext`) with runtime-resolved names; **NO** `OnClick`/`PreClick`/`PostClick` on secure buttons; protected/secure attribute or restricted visibility changes **deferred out of combat** (`InCombatLockdown` / `pendingSecure` -> `PLAYER_REGEN_ENABLED`). Read/apply split.
- **ByJTT foundation:** `ByJTT.Brand`/`ByJTT.Addons.ForeverFishing` namespace, compat providers (`pcall`/feature-detect for `C_Spell`/`GetSpellInfo`, `GetItemCount`, profession APIs, zone APIs), schema-versioned SavedVariables (`_schema=1`, additive migrations, **never destructively drop unknown keys**).
- **Features:** one smart **Fish!** button (equip best pole -> apply best lure only if pole is bare -> cast) with coalesced refresh and broader event coverage; bite alert (emote-driven flash + sound, best-effort); catch/session/zone/lifetime tracking (best-effort, tuned to avoid false positives) with session counter restore; `/ffish` slash parity (`cast|lure|show|hide|stats|zones|config|...`) + settings (with standalone fallback) + onboarding + richer debug.
- **Peer update notifications (best-effort, no internet):** in-game version check via addon comms with group/raid/instance/guild peers (shared ByJTT prefix `BYJTTVER`). Notifies once per session if a peer runs a newer version of this addon. Toggle `/ffish update` and settings checkbox (on by default, persisted). **No internet/CurseForge API checks and no auto-install** - actual updates via addon managers (CurseForge/WowUp/Wago) when released, or GitHub repo.
- **CurseForge/release prep (partial):** `.pkgmeta` added for packager-friendly zips (package-as `ForeverFishing`, ignores repo/dev files). TOC/Lua `VERSION` remain `1.0.0` (unreleased polish in `[Unreleased]` changelog).
- **Branding:** "AddonName ByJTT" style - display/TOC: `WoW Forever Fishing Addon ByJTT`. byjtt.com + GitHub links. Support is a **PLACEHOLDER** URL in TOC/Lua/docs/UI (`https://buymeacoffee.com/ByJTT`) - replace with the real Buy Me a Coffee URL everywhere before release/marketing.
- **Docs/contract:** `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, `CHANGELOG.md` (foundation/hardening + notifier/unreleased notes), `llms.txt`, `.github/*`, `.luarc.json`, `.pkgmeta`.

## In-game files (ship/install)
- `ForeverFishing.toc`, `ForeverFishing.lua`. Everything else is repo/docs.
- Install path: `<WoW Forever>/Interface/AddOns/ForeverFishing/ForeverFishing.toc` (folder name **`ForeverFishing`**).

## Key commands (in game)
`/ffish help|config|show|hide|cast|lure|stats|zones|reset|lock|unlock|move|scale|bite|update|test|debug|onboarding|rl`. Enable Lua errors: `/console scriptErrors 1`.

## Verification checklist (do this in-game on WoW Forever first)
1. `/reload` + `/console scriptErrors 1` - **no Lua errors/taint**.
2. **Cast:** Fish button casts Fishing; Lure button appears with lures in bags and applies best lure; `/ffish cast`, `/ffish lure` work.
3. **Bite + tracker:** `/ffish test` flashes + sounds; real bite flashes; catches increment `/ffish stats` + `/ffish zones`.
4. **Combat/lockdown:** in combat, no protected attribute/visibility churn/taint (deferred); after leaving combat refresh applies.
5. **UX:** onboarding appears once (re-open via `/ffish onboarding`), `/ffish config` opens (or fallback), drag/lock/scale/bite toggle/reset work.
6. **Updates (peer):** `/ffish update` toggles notifications (and settings checkbox), `/ffish debug` shows notifier state; peer version notice appears once per session only when a newer peer is detected (group/raid/instance/guild). No internet, no auto-install.
7. **Data tuning:** confirm lure IDs/names and Fishing spell resolution for WoW Forever via `/ffish debug`; prefer ID + name fallback coverage.

## Open items / next steps (priority)
1. **In-game verification on WoW Forever:** run the checklist above; fix any client-specific API/event/Settings issues (feature-detect/pcall). Lure/spell/pole/bite/loot behavior and notifier comms/channels are **best-effort** and likely need tuning from `/ffish debug` + real testing.
2. **Replace Buy Me a Coffee placeholder** `https://buymeacoffee.com/ByJTT` with the real URL in: `ForeverFishing.lua` (`ByJTT.Brand.support`), `ForeverFishing.toc` (`X-ByJTT-Support`), `README.md`, `AGENTS.md`, `llms.txt`, `CHANGELOG.md` notes, and in-game About/onboarding text.
3. **Local install for testing:** copy/symlink repo `ForeverFishing/` files to `<WoW Forever>/Interface/AddOns/ForeverFishing/`.
4. **Decide SemVer/release when verified:** sync TOC `## Version` + Lua `VERSION`/`SCHEMA` + `CHANGELOG` + git tag `vX.Y.Z` + GitHub release **only when explicitly requested**.
5. **Future (post-verification):** optional pole-equip refinements, auto re-lure prompt, per-character profiles, tournament mode. Keep minimal until verified.

## Architecture anchors (quick)
- `ForeverFishing.lua`: header/brand/ns, constants (spell/poles/lures), compat, SV schema+migration, UI root + secure buttons (`UpdateSecure`/`pendingSecure`), tracker state, BuildButtonStates/ApplyStates, onboarding, options (feature-detected), peer update notifier (addon comms, best-effort), events (bite + loot + addon comms), slash (`/ffish`). **Central invariant:** no secure handlers; no protected changes in combat.
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
- **"AddonName ByJTT"** display style; in-game folder/`ADDON_NAME` remain `ForeverFishing` for loader stability (repo name SEO-friendly). By = solo studio **ByJTT** (not a personal name in branding).
- **1 Lua + TOC, no libs** for low risk/simple install; mirrors the buff-reminder foundation pattern.
- **Best-in-bags lure, not auto-lure** (v1): one-click apply keeps the player in control; fully automatic re-luring risks taint/combat edge cases.
- **Emote-driven bite alert** (v1): no dedicated bobber event exists; channel-state + emote match is the classic reliable cue. Sound ID reused from foundation (verify in-game).
- **Updates:** best/common distribution via addon managers (CurseForge/WowUp/Wago) when released, or GitHub; in-game peer notifier is best-effort complement only (no internet, no auto-install).
- **Local-only until verified**; tag/release only after verification + real support URL.

## 2026-11-13 (autopilot continuation)

- Confirmed addon is committed, pushed, and in sync with `origin/main` (`bcd7f03` includes `.luarc.json` editor diagnostics; smart Fish! and reliability/UX hardening commits pushed). Working tree clean.
- Updated this handoff to reflect current git/remote state and shipped behavior (replacing stale "not yet pushed" / v1-local-only notes), including `show|hide` command and current open items.
- No in-game verification performed in this environment. Buy Me a Coffee URLs remain placeholders; no tags/releases created. Core open work remains in-game verification/tuning on WoW Forever and release hygiene when verified.

## 2026-11-14 (autopilot continuation)

- Implemented **peer update notifier** (best-effort, in-game addon comms only): shared `BYJTTVER` prefix, per-addon key/version broadcast, throttled sends to group/raid/instance/guild, once-per-session "update available" notice when a peer runs newer, `/ffish update` toggle + settings checkbox (default on, persisted), and debug/status reporting. No internet checks and no auto-install; actual updates via CurseForge/WowUp/Wago when released or GitHub repo.
- Updated `README.md`, `CHANGELOG.md` ([Unreleased]), `llms.txt`, `AGENTS.md`, and this `HANDOFF.md` for update behavior and CurseForge/manager guidance. Added `.pkgmeta` for future CurseForge/packager releases.
- Committed and pushed notifier/release-prep changes to `origin/main` (`dfd9471`). Working tree clean after push.
- Core open work remains: in-game verification/tuning on WoW Forever (including notifier behavior across clients/channels), bite/loot/lure/spell tuning, replace Buy Me a Coffee placeholder URL, and SemVer/tag/release when verified.
