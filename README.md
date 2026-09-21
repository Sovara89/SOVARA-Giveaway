# SOVARA GIFT v1.6.1

Production package for `gift.sovara.ru`.

## v1.6.0 — DB-first public site
- Public `/api/status` and `/api/participants` read only local persisted state. They never call Twitch.
- Guest, logged-in viewer and admin therefore receive the same participant/ticket snapshot.
- Twitch follower synchronization runs in the background every 10 minutes and persists Follow state into the local database.
- EventSub updates new follows immediately. Full periodic sync catches unfollows.
- Chat/watchtime admission still requires confirmed Follow before a new viewer is added.
- The web server starts immediately from local state even if Twitch is slow or unavailable. Twitch services restore asynchronously.
- Twitch Client ID settings remain owner-only.
- Header points/tickets counter remains enabled for logged-in viewers.

## Production files
- `server.js`
- `index.html`
- `package.json`
- `.gitignore`
- `README.md`

Runtime state, backups, sessions and Twitch credentials remain outside GitHub on the VPS.


## v1.6.1
- Fixed anonymous `/api/status`: guest requests no longer dereference a missing session after follower cache loads.
- Public giveaway/participant counts remain DB-first and identical for guests, users and admins.
