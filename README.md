# SOVARA Giveaway v1.0

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
