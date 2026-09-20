# SOVARA GIFT v1.5.3

Production build for `https://gift.sovara.ru`.

## v1.5 FINAL POLISH
- Viewer/admin website sessions survive Node/systemd restarts (7-day cookie lifetime).
- Human-readable frontend errors for auth, admin, backup and giveaway actions.
- Admin audit log is visible in the admin panel.
- Daily/manual backups plus owner-only download and restore; restore creates a safety backup first.
- Owner-only global emergency pause freezes chat, watchtime and manual point awards.
- Next-round settings in the admin UI: prize, ticket cost, ticket cap, minimum participants and duration.
- System status block: app version, uptime, active sessions, Twitch auth, EventSub and latest backup.
- Existing persistent Twitch service authorization, anti-spam cooldown, test rounds, additional admins and archive remain intact.

## Production layout
The release intentionally contains only five files:
- `.gitignore`
- `README.md`
- `index.html`
- `package.json`
- `server.js`

Runtime data, sessions, backups and Twitch secrets stay outside GitHub in `/var/lib/sovara-giveaway` and `/etc/sovara-giveaway.env`.


## v1.5.3
- Profile fields can be saved partially. Contacts no longer require complete prize details.
- Giveaway eligibility still requires a complete profile.


## v1.5.3
- Clear prize fulfillment terms in the viewer cabinet.
- Steam game: one game up to the prize limit; unused remainder is not compensated.
- In-game donation: one standard package up to the prize limit; packages are not combined to exhaust the remainder.
