# SOVARA Giveaway v1.2

Production web app for recurring SOVARA Twitch giveaways.

## VPS runtime

- Node.js 18+
- Nginx reverse proxy
- systemd service: `sovara-giveaway`
- persistent data: `/var/lib/sovara-giveaway`
- app code: `/opt/sovara-giveaway`
- public URL: `https://gift.sovara.ru`

## v1.0

- Public giveaway archive with round statistics and winner prize type.
- Public archive never returns private winner profile/contact/payment fields.
- Admin can delete completed test rounds from the archive.
- Recurring round lifecycle from v0.9 remains: 10 participants -> 30 days -> draw -> prize delivered -> complete -> new round.


## v1.1
- Broadcaster/admin account is excluded from points, tickets, participants and winner pool.
- Viewer Twitch login requests only `openid`.
- Admin Twitch service authorization is separate and requests `user:read:chat moderator:read:chatters`.
- Admin UI has a Connect/Reconnect Twitch services button.
- Points inputs are wider in admin UI.


## v1.2
- Owner can add/remove delegated site administrators by Twitch login.
- Delegated admins can operate giveaways, points, bans and participant data, but cannot manage admins or reconnect Twitch service scopes.
- Owner and delegated admins are excluded from giveaway points/tickets/winner pool.
- Header brand is non-selectable and uses a new owl favicon.
- Header includes a Twitch return button with LIVE/OFFLINE state when Twitch services are connected.
