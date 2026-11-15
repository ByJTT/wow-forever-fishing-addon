# Handoff - WoW Forever Fishing Addon ByJTT

> Last updated: 2026-11-14 (autopilot: Blizzard-native QOL/unification polish - grouped help/chat voice, recovery/reset commands, TOC icon, shared standard/docs alignment; no in-game verification)

## Current state

- **Addon:** `WoW Forever Fishing Addon ByJTT` (repo: `wow-forever-fishing-addon`, in-game folder: `ForeverFishing`)
- **Version:** TOC `## Version 1.0.0`, Lua `ns.VERSION = "1.0.0"` (SavedVariables schema `ns.SCHEMA = 1`, per-account `ForeverFishingDB`)
- **Target:** World of Warcraft: Forever (Interface 16001, 30300). Taint-safe, secure click-to-cast. No libraries/framework dependencies.
- **Baseline:** v1.0.0 smart one-button foundation and hardening are present in git history (`1d3a10f`, `4efdc15`, `b44ae26`, `da0fd86` and subsequent commits).
- **Git:** `main` tracks `origin/main` (`https://github.com/ByJTT/wow-forever-fishing-addon.git`). This QOL/unification polish pass is committed and pushed in this session (working tree clean after push).
- **Shared standard:** `BYJTT_WOW_ADDON_STANDARD.md` (repo-only, ignored by `.pkgmeta`) documents shared ByJTT UX/quality/release conventions.

## What is implemented (v1 foundation + ongoing polish)

- **One smart Fish! button (secure):** `SecureActionButtonTemplate` action button plans and performs pole equip (if needed) + lure apply (only when pole is bare, never wasted) + cast in one click. **No** `OnClick`/`PreClick`/`PostClick` on secure buttons. Protected attribute/visibility changes deferred out of combat.
- **State/refresh:** coalesced refresh across login/spells/bags/equipment/skill/inventory/combat/channel/loot/zone events to keep the secure plan in sync (feature-detected APIs, WoW Forever fallbacks). Persistent show/hide, movable/lockable/scalable bar.
- **Helpers/tracking (best-effort):** fishing skill + best-known pole/lure detection, bite alert (flash/sound), session cast/catch counters, per-zone and lifetime catch tracking, and debug/status reporting. Bite/loot heuristics are best-effort and intentionally non-automated.
- **UX/onboarding/settings:** first-run onboarding (re-openable), Blizzard-native settings via `Settings`/`InterfaceOptions` when available with standalone movable fallback (`/ffish config`), plain-English status tooltip/help, and clear slash feedback.
- **Slash commands/diagnostics:** `/ffish` for `help`, `config`, `show|hide`, `cast` (smart sequence), `lure`, `stats`, `zones`, `reset` (session), `resetpos|resetposition|resetui` (bar position), `resetdefaults|resetsettings` (settings, keeps catch history and session), `lock|unlock|move`, `scale`, `bite`, `update`, `test`, `debug`, `onboarding`, `rl`.
- **Help/voice/recovery (this polish pass):** grouped, plain-language `/ffish help` and consistent ByJTT chat prefix/branding (`ByJTT Fishing`), clearer onboarding/tooltips/options copy and unknown-command guidance, plus reset-position/reset-settings commands and settings actions (keeps catch history/session) for easy recovery. Added `## IconTexture` for addon-list parity.
- **Compat/safety:** feature-detected providers/pcall guards (spell/item/channel/bag/skill APIs, loot/emote events) for WoW Forever (16001/30300) differences; additive schema-versioned SavedVariables.
- **Peer update notifications (best-effort):** optional in-game peer version check via addon comms (`BYJTTVER`, group/raid/instance/guild, throttled, once-per-session notice) with `/ffish update` toggle and settings/debug visibility. **No internet, no auto-install**; real updates via addon managers (CurseForge/WowUp/Wago when published) or GitHub repo.
- **Release prep/docs:** `.pkgmeta` for CurseForge/packager, README/CHANGELOG/AGENTS/CONTRIBUTING/llms and this handoff aligned.

## Recent autopilot changes (2026-11-13 to 2026-11-14)

- `da0fd86` (pushed): hardening pass - coalesced/broader event refresh, safer pole detection, improved bite/loot heuristics and timestamps, session restore, `/ffish cast/lure/show|hide/debug` and options/UX/doc polish.
- `bcd7f03` (pushed): added `.luarc.json` for editor/Lua diagnostics consistency.
- `dfd9471` / `35f126a` (pushed): update-notify settings toggle parity, `.pkgmeta` CurseForge prep, and docs/handoff sync (notifier/slash/debug already present).
- **2026-11-14 QOL/unification polish (this pass, committed/pushed):** grouped plain-language `/ffish help` and consistent chat prefix/voice (`ByJTT Fishing`), clearer onboarding/tooltips/options copy, `/ffish resetpos|resetdefaults` + settings **Reset Settings** (keeps catch history and session), `## IconTexture`, `BYJTT_WOW_ADDON_STANDARD.md`, `.pkgmeta` ignore for standard doc, and synchronized README/CHANGELOG/AGENTS/CONTRIBUTING/llms/HANDOFF. No in-game verification performed.

## Open items / next steps

1. **In-game verification (WoW Forever):** `/reload`, `/console scriptErrors 1`, `/ffish config` (Blizzard + fallback), onboarding, smart Fish! flow (pole/lure/cast), bite alert and loot/catch tracking heuristics, zone/session/lifetime stats, show/hide/move/lock/scale/persistence, `/ffish debug/cast/lure/stats/zones`, reset position/resetdefaults, combat lockdown/deferral/taint-safety, and peer notifier behavior (`/ffish update`, group/raid/instance/guild across clients/builds).
2. **API/compat tuning:** confirm fishing spell/ranks, lure/pole item IDs/names, bag/equipment/channel/loot/emote event behavior on WoW Forever and adjust feature-detected fallbacks/heuristics from in-game findings.
3. **Branding/release:** replace Buy Me a Coffee placeholder URL (`https://buymeacoffee.com/ByJTT`) everywhere before public release. Decide SemVer/tag/release only after verification (sync TOC/Lua/CHANGELOG, tag `vX.Y.Z`, GitHub release, publish to CurseForge/WowUp/Wago as appropriate).
4. **Quality:** optional CI/lint checks, further accessibility/readability passes, and keep behavior consistent with `BYJTT_WOW_ADDON_STANDARD.md`.

## Known constraints / design notes

- Bite detection and catch attribution are **best-effort heuristics** (bobber/emote/channel/loot timing varies by client); intentionally non-automated and may need in-game tuning.
- Taint safety is paramount: never add secure-button click scripts; always defer protected changes in combat.
- In-game peer notifier is best-effort only (group/raid/instance/guild peers, no internet, no auto-install). Real update detection/install is via addon managers (CurseForge/WowUp/Wago) when released or the GitHub repo.
- Keep public files free of secrets/account data/local personal paths. No destructive SV drops.

## Git/remotes

- Branch: `main` (tracks `origin/main`)
- Remote: `origin` -> `https://github.com/ByJTT/wow-forever-fishing-addon.git`
