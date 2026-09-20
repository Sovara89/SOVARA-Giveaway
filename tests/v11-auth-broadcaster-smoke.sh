#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; COOKIE="$(mktemp)"; PORT=4201
cleanup(){ kill "${PID:-}" 2>/dev/null || true; rm -rf "$TMP" "$COOKIE"; }
trap cleanup EXIT
cp -a "$ROOT/data/." "$TMP/"
TWITCH_CLIENT_ID=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa HOST=127.0.0.1 PORT=$PORT DATA_DIR="$TMP" NODE_ENV=development node "$ROOT/server.js" >/tmp/sovara-giveaway-v11-test.log 2>&1 & PID=$!
sleep 1

curl -fsS -H 'Content-Type: application/json' -d '{}' "http://127.0.0.1:$PORT/api/auth/implicit/start" >/tmp/viewer-auth-v11.json
python3 - <<'PY'
import json,urllib.parse
x=json.load(open('/tmp/viewer-auth-v11.json'))
q=urllib.parse.parse_qs(urllib.parse.urlparse(x['url']).query)
assert q['scope']==['openid'], q
assert q['response_type']==['token id_token'], q
print('OK viewer OAuth: only openid')
PY

curl -fsS -c "$COOKIE" -H 'Content-Type: application/json' -d '{"admin":true}' "http://127.0.0.1:$PORT/api/auth/demo" >/dev/null
curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "http://127.0.0.1:$PORT/api/admin/auth/implicit/start" >/tmp/admin-auth-v11.json
python3 - <<'PY'
import json,urllib.parse
x=json.load(open('/tmp/admin-auth-v11.json'))
q=urllib.parse.parse_qs(urllib.parse.urlparse(x['url']).query)
assert q['scope']==['user:read:chat moderator:read:chatters'], q
assert q['response_type']==['token'], q
assert q['force_verify']==['true'], q
print('OK admin OAuth: service scopes separated')
PY

CODE=$(curl -sS -o /tmp/admin-points-v11.json -w '%{http_code}' -b "$COOKIE" -H 'Content-Type: application/json' -d '{"twitchUserId":"777000001","amount":300}' "http://127.0.0.1:$PORT/api/admin/user/points")
[ "$CODE" = "409" ]
python3 - <<'PY'
import json
x=json.load(open('/tmp/admin-points-v11.json'))
assert x['error']=='STAFF_EXCLUDED', x
print('OK broadcaster: manual points rejected')
PY

python3 - "$TMP/state.json" <<'PY'
import json,sys
p=sys.argv[1];s=json.load(open(p));u=s['users']['777000001']
u['points']=300;u['tickets']=1;u['profile']={'prizeType':'steam_balance','steamLogin':'owner','steamCurrency':'RUB','steamFriendCode':'','steamGameUrl':'','ozonEmail':'','donationGame':'','donationAccount':'','contactVk':'','contactTelegram':'@sovara_test'}
json.dump(s,open(p,'w'),ensure_ascii=False,indent=2)
PY
curl -fsS "http://127.0.0.1:$PORT/api/participants" >/tmp/participants-v11.json
python3 - <<'PY'
import json
x=json.load(open('/tmp/participants-v11.json'))
assert x['participants']==[] and x['totalTickets']==0, x
print('OK broadcaster: excluded from participants and ticket pool')
PY

curl -fsS -b "$COOKIE" "http://127.0.0.1:$PORT/api/admin/users" >/tmp/admin-users-v11.json
python3 - <<'PY'
import json
x=json.load(open('/tmp/admin-users-v11.json'))
assert all(u['login'].lower()!='sovara_' for u in x['users'])
print('OK broadcaster: hidden from participant-management cards')
PY
