# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0/).

## [1.0.0] - 2026-11-10 (local foundation, not yet tagged/released)

### Added
- **v1 foundation:** one-click secure **Fish** cast button (classic spell 7620 + name fallback).
- **Lure helper:** best-in-bags lure button (Bright Baubles, Aquadynamic Fish Attractor, Shiny Bauble, Nightcrawlers, Sharpened Fish Hook, …) with bonus-aware pick; one click applies.
- **Bite alert:** flash + optional sound on bobber bite (emote-driven while channeling); `/ffish test` verifies.
- **Catch tracker:** session casts/catches, per-zone breakdown (`/ffish zones`), lifetime totals from own `CHAT_MSG_LOOT`.
- **WoW-authentic UX:** onboarding (first run, re-openable), Blizzard-native settings when available (`/ffish config`), tooltips, pulse/sound, drag/lock/scale.
- **ByJTT foundation:** `ByJTT` namespace/brand, compat providers (WoW Forever API fallbacks), schema-versioned SavedVariables (`_schema=1`, additive migrations), `/ffish` slash parity, `/ffish debug` diagnostics.
- **Branding:** “AddonName ByJTT” display name (`WoW Forever Fishing Addon ByJTT`). byjtt.com + GitHub links, Buy Me a Coffee **placeholder** (replace with real URL before release/marketing).
- Public repo docs: README, MIT license, contributing guide, issue/PR templates.

### Safety
- **Taint-safe:** no `OnClick`/`PreClick`/`PostClick` on `SecureActionButtonTemplate`; attribute-only secure actions; protected changes deferred out of combat (`InCombatLockdown`/pending + `PLAYER_REGEN_ENABLED`).
