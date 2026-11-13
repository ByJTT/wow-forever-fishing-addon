# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0/).

## [Unreleased]

### Changed
- **One smart Fish! button replaces the two-button bar:** a single click now equips your best pole (if needed), applies your best lure (only if the pole is bare - never wasted), and casts. No second button to learn.
- **Plain-English tooltip:** hover shows your skill, equipped pole, lure state, and exactly what the next click will do (status parsing/formatting cleaned up for readability).
- Button state refreshes after every cast, loot, bag/equipment/skill changes (best-effort event coverage across clients), with coalesced refresh to keep the secure button plan in sync without redundant churn.
- **Slash commands:** `/ffish cast` now performs the same smart sequence as the Fish button (equip best pole, apply lure if bare, cast) with combat/availability checks; `/ffish lure` applies the best bag lure out of combat with clearer feedback and refresh; `/ffish debug` reports richer state (hidden/shown, bite alert, equipped/bag pole, lure status, button state); help text updated.
- **Catch & bite tracking (best-effort):** loot is counted only during/shortly after fishing activity to reduce false positives; bite detection improved to trigger on bobber splash/bite emotes during recent fishing windows, with event timestamps tracked across channel start/stop.
- **Polish/foundation hardening:** fixed mojibake/encoding in docs and Lua, corrected `PLAYER_QUITTING` event handling, removed duplicate emote event registration, and improved event-driven state refresh reliability.
- **Pole detection:** equipped-pole detection now only recognizes known fishing poles (by ID/name heuristic) to avoid mistaking weapons for poles.
- **Session tracking:** restores active session cast/catch counters on reload/login when a session is in progress.
- **UX:** added `/ffish show|hide` commands (persistent hide state), and updated help text. `/ffish move` and `/ffish show` unhide the bar.
- **Options fallback:** when Blizzard Settings/InterfaceOptions are unavailable, `/ffish config` opens a standalone movable dialog with backdrop/close (WoW Forever/Classic-friendly). Options panel is now hidden by default until opened.

## [1.0.0] - 2026-11-10 (local foundation, not yet tagged/released)

### Added
- **v1 foundation:** one-click secure **Fish** cast button (classic spell 7620 + name fallback).
- **Lure helper:** best-in-bags lure button (Bright Baubles, Aquadynamic Fish Attractor, Shiny Bauble, Nightcrawlers, Sharpened Fish Hook, ...) with bonus-aware pick; one click applies.
- **Bite alert:** flash + optional sound on bobber bite (emote-driven while channeling); `/ffish test` verifies.
- **Catch tracker:** session casts/catches, per-zone breakdown (`/ffish zones`), lifetime totals from own `CHAT_MSG_LOOT`.
- **WoW-authentic UX:** onboarding (first run, re-openable), Blizzard-native settings when available (`/ffish config`), tooltips, pulse/sound, drag/lock/scale.
- **ByJTT foundation:** `ByJTT` namespace/brand, compat providers (WoW Forever API fallbacks), schema-versioned SavedVariables (`_schema=1`, additive migrations), `/ffish` slash parity, `/ffish debug` diagnostics.
- **Branding:** "AddonName ByJTT" display name (`WoW Forever Fishing Addon ByJTT`). byjtt.com + GitHub links, Buy Me a Coffee **placeholder** (replace with real URL before release/marketing).
- Public repo docs: README, MIT license, contributing guide, issue/PR templates.

### Safety
- **Taint-safe:** no `OnClick`/`PreClick`/`PostClick` on `SecureActionButtonTemplate`; attribute-only secure actions; protected changes deferred out of combat (`InCombatLockdown`/pending + `PLAYER_REGEN_ENABLED`).
