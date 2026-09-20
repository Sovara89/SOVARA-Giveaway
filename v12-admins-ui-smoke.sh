#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; OWNER_COOKIE="$(mktemp)"; MOD_COOKIE="$(mktemp)"; PORT=4202
cleanup(){ kill "${PID:-}" 2>/dev/null || true; rm -rf "$TMP" "$OWNER_COOKIE" "$MOD_COOKIE"; }
trap cleanup EXIT
cp -a "$ROOT/data/." "$TMP/"
HOST=127.0.0.1 PORT=$PORT DATA_DIR="$TMP" NODE_ENV=development node "$ROOT/server.js" >/tmp/sovara-v12-test.log 2>&1 & PID=$!
sleep 1
BASE="http://127.0.0.1:$PORT"

# Owner login and grants demo_viewer admin.
curl -fsS -c "$OWNER_COOKIE" -H 'Content-Type: application/json' -d '{"admin":true}' "$BASE/api/auth/demo" >/dev/null
curl -fsS -b "$OWNER_COOKIE" -H 'Content-Type: application/json' -d '{"login":"demo_viewer"}' "$BASE/api/admin/admins/add" >/tmp/v12-add.json
python3 - <<'PY'
import json
x=json.load(open('/tmp/v12-add.json'))
assert x['ok'] and x['admin']['login']=='demo_viewer'
print('OK owner can add delegated admin')
PY

# Delegated admin login gets admin access, but not owner access and gets no points/tickets.
curl -fsS -c "$MOD_COOKIE" -H 'Content-Type: application/json' -d '{"admin":false}' "$BASE/api/auth/demo" >/tmp/v12-mod-login.json
curl -fsS -b "$MOD_COOKIE" "$BASE/api/status" >/tmp/v12-mod-status.json
curl -fsS -b "$MOD_COOKIE" "$BASE/api/admin/users" >/tmp/v12-mod-admin.json
python3 - <<'PY'
import json
s=json.load(open('/tmp/v12-mod-status.json')); a=json.load(open('/tmp/v12-mod-admin.json'))
assert s['isAdmin'] is True and s['isOwner'] is False
assert a['isOwner'] is False
print('OK delegated admin can open admin panel but is not owner')
PY

# Delegated admin cannot grant admins.
CODE=$(curl -sS -o /tmp/v12-owner-only.json -w '%{http_code}' -b "$MOD_COOKIE" -H 'Content-Type: application/json' -d '{"login":"someoneelse"}' "$BASE/api/admin/admins/add")
[ "$CODE" = "403" ]
python3 - <<'PY'
import json
x=json.load(open('/tmp/v12-owner-only.json')); assert x['error']=='OWNER_REQUIRED'
print('OK delegated admin cannot manage admins')
PY

# Staff account must not appear in public participants and must have zero round points.
curl -fsS "$BASE/api/participants" >/tmp/v12-participants.json
python3 - "$TMP/state.json" <<'PY'
import json,sys
p=json.load(open('/tmp/v12-participants.json'))['participants']
s=json.load(open(sys.argv[1]))
u=s['users']['777000002']
assert all(x['login']!='demo_viewer' for x in p)
assert u['points']==0 and u['tickets']==0 and u['totalWatchMinutes']==0
print('OK admins are excluded from giveaway accrual and participants')
PY

# Owner can remove delegated admin; existing session loses access dynamically.
curl -fsS -b "$OWNER_COOKIE" -H 'Content-Type: application/json' -d '{"login":"demo_viewer"}' "$BASE/api/admin/admins/remove" >/dev/null
CODE=$(curl -sS -o /tmp/v12-removed-access.json -w '%{http_code}' -b "$MOD_COOKIE" "$BASE/api/admin/users")
[ "$CODE" = "403" ]
echo 'OK removing admin revokes access immediately'

# UI assets exist.
grep -q 'href="/favicon.png?v=121"' "$ROOT/public/index.html"
grep -q 'id="twitchReturn"' "$ROOT/public/index.html"
grep -q 'id="adminManagerBox"' "$ROOT/public/index.html"
grep -q 'user-select:none' "$ROOT/public/index.html"
[ -s "$ROOT/public/favicon.png" ]
[ -s "$ROOT/public/favicon.ico" ]
echo 'OK favicon, non-selectable brand, Twitch return button and admin manager UI present'
