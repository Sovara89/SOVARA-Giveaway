# SOVARA Giveaway

SOVARA Twitch giveaway web app.

## Railway

Runtime settings:
- `NODE_ENV=production`
- `DATA_DIR=/data` when a persistent volume is mounted at `/data`
- `TWITCH_CLIENT_ID` — Twitch application Client ID
- `TWITCH_AUTH_MODE=device`
- `TWITCH_LOGIN_SCOPES=user:read:chat moderator:read:chatters`
- `ADMIN_TWITCH_LOGIN=sovara_`
- `PUBLIC_BASE_URL=https://<your-domain>` once a public domain is assigned

Start command: `npm start`. Railway injects `PORT` automatically.

Production disables the local demo-admin and web setup endpoints.
