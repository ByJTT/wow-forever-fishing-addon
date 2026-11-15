# ByJTT WoW Forever Addon Standard (living guide)

This document defines the shared UX, quality, and release conventions for **ByJTT** addons on **WoW Forever** (Interface 16001, 30300). Goal: every addon feels like a natural, consistent part of the game  -  easy for all ages and skill levels, safe by default, and simple to maintain.

## Product principles
- **Zero bother:** works out of the box with sensible defaults; clear first-run guidance; never leave users stuck (empty/error states say what to do next).
- **All skill levels:** plain language, obvious controls, grouped Basic vs Advanced help, and tooltips that explain *what* and *how* (not jargon). Advanced/power features stay available but secondary.
- **Safe & respectful:** taint-safe/secure patterns for protected actions, defer protected changes out of combat, feature-detect/pcall client APIs (16001/30300 differences), schema-versioned SavedVariables with additive migrations, and guidance-only where appropriate.
- **Blizzard-native feel:** familiar Blizzard frame templates/fonts/controls, consistent drag/lock/close behavior, tooltips, and in-game settings integration when available (with a usable standalone fallback).

## Identity & metadata (TOC/addon)
- **Naming:** stable folder/addon name (e.g. `ForeverLevelingGuide`) and display title in "AddonName ByJTT" style. Consistent `## Author`, `## Notes`, `## X-Category`, `## X-License`, `## X-Website`, `## X-ByJTT-*`, and support placeholder when applicable.
- **Icon:** include `## IconTexture` (license-safe/fitting Blizzard icon) for addon list visibility.
- **Packaging:** include `.pkgmeta` for CurseForge/packager; keep repo/docs/dev/tools excluded as appropriate.
- **Brand/support:** byjtt.com + GitHub repo links; Buy Me a Coffee/support is a **placeholder** until replaced for release. Keep copy consistent and honest.

## Chat voice & help
- **Prefix:** consistent, readable ByJTT brand + addon short name in chat (subtle per-addon accent color allowed) and calm, helpful tone. No spam.
- **Help:** `/help` (and addon command) shows *How to use* + *Basic* + *Options/Navigation* + *Advanced* groups with one-line descriptions and current states where useful. Unknown commands respond with: `Unknown command. Type /<cmd> help for commands.` (or equivalent).
- **Feedback:** confirm toggles/loads/resets/waypoints in chat or UI ("Panel locked", "Guide loaded…"). Debug info stays behind `/debug` or `/debug export`.
- **Slash verbs (align where applicable):** `help`, `config/options/settings`, `show/hide/toggle`, `lock/unlock`, `reset`/`resetpos|resetui` and `resetdefaults/resetsettings` (clearly distinct), `minimap` (if present), `debug` (`export` if useful), `update`, `onboarding/welcome`  -  plus addon-specific commands.

## UI, accessibility & comfort
- **Discoverability:** at least one obvious in-game entry point without memorizing commands (panel, minimap launcher, settings, or context-appropriate UI). Minimap buttons (if used): left-click primary action, right-click secondary (e.g. guides), drag to move, saved position, hideable.
- **First-run onboarding:** short, skippable, and re-openable (`/onboarding` or Help/Settings). Explain the happy path, key controls, and any WIP/scaffold limitations plainly.
- **Settings:** Blizzard Settings/InterfaceOptions integration when available + **standalone movable fallback** dialog when not. Group options clearly; include update-notify toggle, UI visibility/lock/position/reset affordances, and About/links.
- **Tooltips:** consistent pattern  -  title, short description, green action hint ("Click to…"), and gray footer (controls + ByJTT/addon). Pair color with words/icons (ON/OFF, Locked/Unlocked); never rely on color alone.
- **Readability & interaction:** standard Blizzard fonts/sizes, sufficient contrast, large click targets, consistent drag/ESC behavior, optional/subtle alerts (sound/flash)  -  never rapid/flashy by default.
- **Recovery:** easy "Reset position/UI" and, where safe, "Reset settings to defaults" (keep important progress/data unless explicitly stated). Distinct labels for progress reset vs UI/settings reset.

## Updates & distribution
- **Real updates:** addons cannot self-update or check the internet from in-game. Actual detection/download is via addon managers (**CurseForge app, WowUp, Wago**) once published, or manual install from GitHub/releases.
- **Peer update notifier (best-effort, optional):** may broadcast/compare addon version over addon comms with group/raid/instance/guild peers and show a **once-per-session** notice when a newer peer version is seen. Must be throttled, feature-detected/pcall-safe, send no personal data, toggleable, and clearly documented as *no internet / no auto-install / no notice when solo or no updated peer*.
- **Release hygiene:** replace placeholders, bump SemVer (TOC/Lua/CHANGELOG), tag (`vX.Y.Z`) and publish releases/CurseForge only after in-game verification on WoW Forever.

## Quality & verification
- **In-game verification required (WoW Forever):** `/reload`, `/console scriptErrors 1`, UI/persistence, slash/settings, events/APIs per client (16001/30300), secure/click-cast + combat lockdown/taint where relevant, and SavedVariables behavior.
- **Data/content honesty:** never guess/ship unverified in-game IDs/coords/quest data as verified; label scaffolds/WIP clearly and provide debug/export tooling to speed verification/tuning.
- **Tooling:** prefer lightweight offline validators/lint checks and rich `/debug` (and `/debug export`) to accelerate fixes. Keep changes additive and document in `CHANGELOG`/`HANDOFF`.

## Cross-addon consistency checklist
- [ ] TOC complete (title/notes/version/interface/icon/category/license/links/support placeholder)
- [ ] `.pkgmeta` present and correct for packager
- [ ] Consistent chat prefix/help/unknown-command copy and slash verbs
- [ ] Onboarding + re-open path
- [ ] Settings panel (Blizzard + fallback) with common toggles and resets
- [ ] Tooltips, accessibility (no color-only), and clear state feedback
- [ ] Update notifier (if implemented) is best-effort, toggleable, and documented accurately
- [ ] Handoff/changelog/README updated; in-game verification items listed
