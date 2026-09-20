# SOVARA GIFT v1.5.4

Production package for `gift.sovara.ru`.

## v1.5.4
- Approved tabbed admin layout: Users / Giveaway / Points / System / Audit.
- Admin user list has search, filters and pagination for large participant counts.
- Audit log no longer has its own forced scrollbar; events expand with “Show more”.
- Steam game and in-game donation terms appear only when those prize types are selected.
- Steam game / in-game donation require explicit terms acceptance before profile save; backend enforces the same rule.
- Steam balance and Ozon do not require a terms checkbox.
- Prize choice can be changed while profile editing is open for the round.
- Partial profile saving from v1.5.2 remains supported for ordinary fields; restricted prize types require terms acceptance.
- Version output is unified across package, API and startup log.

## Production files
- `server.js`
- `index.html`
- `package.json`
- `.gitignore`
- `README.md`

Runtime state, backups, sessions and Twitch credentials remain outside GitHub on the VPS.
