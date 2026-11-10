# Contributing — WoW Forever Fishing Addon ByJTT

Thanks for helping improve **WoW Forever Fishing Addon ByJTT** (ByJTT foundation addon for WoW Forever). Keep it **small, reliable, taint-safe, and WoW-authentic**.

## Ground rules

- **Taint-safe (non-negotiable):** NEVER add `OnClick`, `PreClick`, or `PostClick` to `SecureActionButtonTemplate` buttons. Attribute-only secure actions.
- **Combat lockdown:** do not change protected/secure attributes or restricted visibility in combat; defer to `PLAYER_REGEN_ENABLED`/pending.
- **Minimal:** no frameworks/libs (no Ace) unless clearly necessary. Prefer simple Lua, small focused functions, no dead code.
- **Privacy:** no personal data, account data, tokens/secrets, hardcoded local absolute paths, or `WTF`/SavedVariables data in commits/PRs. Public branding links (byjtt.com, GitHub, repo, support placeholder) are OK.
- **Foundation discipline:** preserve compat providers, schema migrations (additive; never destructively drop unknown keys), `/ffish` + settings parity, WoW Forever API feature-detection/fallbacks, and “AddonName ByJTT” branding. Lure/pole/spell lookups keep **ID + name fallback** coverage.
- **Release sync:** TOC `## Version`, Lua `VERSION`/`SCHEMA` (as applicable), `CHANGELOG.md`, and git tag must match (SemVer).

## Reporting issues

Use issue templates and include:
- WoW client/variant (**WoW Forever**) and interface/build if known
- Addon version + state (`/ffish debug` output)
- Expected vs actual behavior, steps to reproduce
- Lua errors (`/console scriptErrors 1`, then `/reload`)
- No account data/local personal paths

## Pull requests

1. Branch from `main`. Keep PRs focused.
2. Test in game (WoW Forever): `/reload`, `/ffish config`, `/ffish onboarding`, `/ffish cast`, lure apply, `/ffish test`, `/ffish stats|zones|debug`, and combat transitions/defer (no taint/Lua errors).
3. Update `CHANGELOG.md` for user-visible changes.

## Local dev

```text
/ffish config     settings UI
/ffish cast       cast fishing
/ffish lure       apply best lure
/ffish stats      session + zone summary
/ffish test       bite alert test
/ffish debug      print state/tracker
/ffish onboarding show onboarding
/ffish rl         reload UI
/console scriptErrors 1
```
