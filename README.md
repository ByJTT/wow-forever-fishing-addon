# wow-forever-fishing-addon — WoW Forever Fishing Addon ByJTT

> **WoW Forever Fishing Addon ByJTT** · one-click fishing, lure & pole helpers, bite alert + catch tracker for **World of Warcraft: Forever**. Solo dev studio: **ByJTT**.
>
> **Project status / full context (humans + AI):** see [`HANDOFF.md`](HANDOFF.md). Agent rules: [`AGENTS.md`](AGENTS.md).

Shows one-click **Fish** + **Lure** buttons (only the Lure button appears when you have lures), bite alert (sound + flash), and a session/zone/lifetime catch tracker. Includes onboarding and in-game settings (`/ffish config`).

**Keywords (discovery):** WoW Forever addon, World of Warcraft Forever, fishing, one-click cast, lure helper, bite alert, catch tracker, fish watcher, ByJTT.

## Features

- **One-click cast** — secure spell button casting Fishing (classic spell 7620, name fallback).
- **Lure helper** — shows your best lure in bags (Bright Baubles, Aquadynamic Fish Attractor, Shiny Bauble, Nightcrawlers, Sharpened Fish Hook, …); one click applies it.
- **Bite alert** — flash + optional sound when the fish bites.
- **Catch tracker** — session casts/catches, per-zone breakdown (`/ffish zones`), lifetime totals.
- **Taint-safe** — no `OnClick`/`PreClick`/`PostClick` handlers on secure buttons; protected changes deferred out of combat.
- **WoW-authentic UX** — onboarding (first run), Blizzard-native settings when available (`/ffish config`), tooltips, pulse/sound, drag/lock/scale.
- **ByJTT foundation** — `ByJTT` namespace/brand, compat providers (WoW Forever API fallbacks), schema-versioned SavedVariables, `/ffish` slash parity, diagnostics (`/ffish debug`).

> **Branding/support:** by **ByJTT** · https://byjtt.com · https://github.com/ByJTT · Support (placeholder): https://buymeacoffee.com/ByJTT (set your real Buy Me a Coffee URL before release/marketing)

## Install (manual)

1. Download or clone this repository.
2. Place the addon so the final path is exactly:
   ```text
   <WoW Forever>\Interface\AddOns\ForeverFishing\ForeverFishing.toc
   ```
   **Important:** the in-game addon folder must be named **`ForeverFishing`** (the folder containing `ForeverFishing.toc`), even if the GitHub repo is named `wow-forever-fishing-addon`.
3. `/reload` in game.
4. If needed, enable **Load out of date AddOns** at character select.

## For AI assistants / automation (install request)

If a user asks an AI to “install the Forever Fishing addon for WoW Forever”:

1. Locate the WoW Forever install’s `Interface\AddOns\` directory.
2. Create/copy a folder named **`ForeverFishing`** containing `ForeverFishing.toc` and `ForeverFishing.lua` from this repo.
3. Verify `ForeverFishing.toc` exists at the path above. Tell the user to `/reload`.
4. Do **not** copy repo-only docs/dev files into the AddOns folder unless desired; only the TOC/Lua are required.

Source: https://github.com/ByJTT/wow-forever-fishing-addon

## Usage

- Click **Fish** to cast. Click **Lure** (when shown) to apply your best lure.
- **Shift+Drag** a button to move (or `/ffish move` then `/ffish lock`).
- Open in-game settings: **`/ffish config`**. Show onboarding: **`/ffish onboarding`**.

```text
/ffish                help
/ffish config         open settings (WoW UI)
/ffish cast           cast fishing now
/ffish lure           apply best lure in bags
/ffish stats          session + zone summary
/ffish zones          full zone breakdown
/ffish reset          end session, start fresh counters
/ffish lock|unlock    lock/unlock position (Shift+Drag moves)
/ffish move           show buttons and unlock for repositioning
/ffish scale <0.6-2>  button scale
/ffish bite           toggle bite alert
/ffish test           flash bite alert (test)
/ffish debug          print status / tracker state
/ffish onboarding     show onboarding
/ffish rl             reload UI
```

## Scope & foundation

- **v1 foundation:** one-click cast, lure helper (best-in-bags), bite alert, session/zone/lifetime tracker, WoW-authentic settings + onboarding.
- **WoW Forever target:** Interface `16001, 30300` with feature-detected API fallbacks. Lure/pole item IDs and spell ranks can vary by client — `/ffish debug` reports state; name fallbacks cover ID drift.
- **Not in scope (yet):** auto-recast timers, auto-lure-apply, auction/vending of catches, per-character profiles UI (SavedVariables are per-account; schema supports expansion).

| | WoW Forever Fishing Addon ByJTT | Broad fishing addons (typical) |
| --- | --- | --- |
| Goal | Clean, reliable, taint-safe one-click fishing + tracker (ByJTT foundation) | All-in-one fishing suites |
| Scope | Cast, lure, bite alert, catch tracking | Often outfit swaps, tournaments, valuation, pools |
| Setup | Onboarding + `/ffish config` | Options panels/profiles |
| Click-to-cast | Yes, secure + taint-safe | Varies |
| Footprint | 1 Lua + TOC, no libs | Larger (expected) |

## Troubleshooting

- **Buttons don't appear:** the bar shows after login; Lure only shows when you carry a lure. Run `/ffish debug` and check fishing is learned.
- **Click doesn’t cast:** run `/ffish debug` and enable Lua errors (`/console scriptErrors 1`, `/reload`). Check combat/lockdown (actions defer in combat) and that Fishing is on your spellbook.
- **Bite alert missing bites:** bite detection uses the bobber emote while channeling — noisy in groups by design. `/ffish test` verifies sound/flash.
- **Catches not tracked:** loot is parsed from your own `CHAT_MSG_LOOT`; group/raid loot assigned to others is not counted.
- **Position/UI:** `/ffish move`, `/ffish reset`, or `/ffish config`.
- **Report issues:** include WoW Forever build/interface, addon version (`/ffish debug`), steps, expected/actual, and Lua errors. No account data/local personal paths.

## Versioning & releases

- [Semantic Versioning](https://semver.org/) + [Keep a Changelog](https://keepachangelog.com/).
- Releases are tagged `vMAJOR.MINOR.PATCH`. TOC `## Version`, Lua `VERSION`, `CHANGELOG.md`, and the git tag must match.

## Contributing & security

Issues and focused PRs welcome — keep changes minimal and taint-safe. See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md).

## ByJTT (studio)

**WoW Forever Fishing Addon ByJTT** is a ByJTT foundation addon (solo studio: **ByJTT**).

- Web: https://byjtt.com
- GitHub: https://github.com/ByJTT
- Repo: https://github.com/ByJTT/wow-forever-fishing-addon
- Support (placeholder — set your real URL): https://buymeacoffee.com/ByJTT

## License

[MIT](LICENSE) · by **ByJTT**
