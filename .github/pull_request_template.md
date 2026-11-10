## Summary

## Testing (WoW Forever, in game)
- [ ] `/reload` (Lua errors on: `/console scriptErrors 1`)
- [ ] `/ffish config` opens settings; toggles persist
- [ ] `/ffish onboarding` shows; first-run behavior sane
- [ ] `/ffish cast` casts fishing (secure, taint-safe)
- [ ] Lure button appears with lures in bags; click applies best lure
- [ ] `/ffish test` flashes + sounds bite alert
- [ ] `/ffish stats` + `/ffish zones` track catches
- [ ] Drag (Shift+Drag) / lock / scale / bite toggle work
- [ ] `/ffish debug` output reviewed
- [ ] Combat transitions: no taint/Lua errors; protected changes deferred

## Safety & foundation
- [ ] Taint-safe: **no** `OnClick`/`PreClick`/`PostClick` on `SecureActionButtonTemplate`; attribute-only actions
- [ ] No protected/secure changes in combat (defer to `PLAYER_REGEN_ENABLED`)
- [ ] No secrets, account data, or local personal paths
- [ ] `CHANGELOG.md` updated (if user-visible); TOC `## Version` + Lua `VERSION`/schema aligned for releases
- [ ] Branding/links correct (ByJTT / byjtt.com / GitHub / support placeholder as applicable)
