#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; COOKIE="$(mktemp)"; PORT=4199
cleanup(){ kill "${PID:-}" 2>/dev/null || true; rm -rf "$TMP" "$COOKIE"; }
trap cleanup EXIT
cp -a "$ROOT/data/." "$TMP/"
HOST=127.0.0.1 PORT=$PORT DATA_DIR="$TMP" NODE_ENV=development node "$ROOT/server.js" >/tmp/sovara-giveaway-v10-test.log 2>&1 & PID=$!
sleep 1
curl -fsS -c "$COOKIE" -H 'Content-Type: application/json' -d '{"admin":true}' "http://127.0.0.1:$PORT/api/auth/demo" >/dev/null
for i in $(seq 1 10); do curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "http://127.0.0.1:$PORT/api/admin/demo/add" >/dev/null; done
EARLY=$(curl -sS -o /tmp/early-v10.json -w '%{http_code}' -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "http://127.0.0.1:$PORT/api/admin/giveaway/draw")
[ "$EARLY" = "409" ]
python3 - "$TMP/state.json" <<'PY'
import json,sys,time
p=sys.argv[1];s=json.load(open(p));t=int(time.time()*1000)
assert s['giveaway']['startedAt']
uid=next(k for k in s['users'] if k.startswith('990'))
open('/tmp/profile-v10.json','w').write(json.dumps({'uid':uid,'profile':s['users'][uid]['profile']},ensure_ascii=False))
s['giveaway']['startedAt']=t-31*86400000;s['giveaway']['endsAt']=t-86400000
json.dump(s,open(p,'w'),ensure_ascii=False,indent=2)
PY
CLOSED=$(curl -sS -o /tmp/closed-v10.json -w '%{http_code}' -b "$COOKIE" -H 'Content-Type: application/json' -d '{"twitchUserId":"9900000001","amount":300}' "http://127.0.0.1:$PORT/api/admin/user/points")
[ "$CLOSED" = "409" ]
curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "http://127.0.0.1:$PORT/api/admin/giveaway/draw" >/tmp/draw-v10.json
curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "http://127.0.0.1:$PORT/api/admin/giveaway/prize-delivered" >/dev/null
curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "http://127.0.0.1:$PORT/api/admin/giveaway/complete" >/dev/null
curl -fsS "http://127.0.0.1:$PORT/api/archive" >/tmp/archive-v10.json
python3 - <<'PY'
import json
a=json.load(open('/tmp/archive-v10.json'))['giveaways']
assert len(a)==1
x=a[0]; w=x['winner']
assert x['participantsCount']==10 and x['totalTickets']>0
assert w['prizeLabel']=='Пополнение Steam'
assert 'profile' not in w
raw=json.dumps(a,ensure_ascii=False)
for forbidden in ['steamLogin','ozonEmail','contactTelegram','contactVk','steamFriendCode','donationAccount']:
    assert forbidden not in raw, forbidden
print('OK public archive: stats + prize label, no private profile fields')
PY
curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "http://127.0.0.1:$PORT/api/admin/giveaway/new-round" >/tmp/newround-v10.json
python3 - "$TMP/state.json" <<'PY'
import json,sys
s=json.load(open(sys.argv[1]));keep=json.load(open('/tmp/profile-v10.json'));uid=keep['uid']
assert s['giveaway']['roundNumber']==2 and s['giveaway']['startedAt'] is None and s['giveaway']['winner'] is None
assert len(s['giveawayHistory'])==1
assert s['giveawayHistory'][0]['winner']['profile']['prizeType']=='steam_balance'
assert s['giveawayHistory'][0]['participantsCount']==10 and s['giveawayHistory'][0]['totalTickets']>0
assert all(u['points']==0 and u['tickets']==0 for u in s['users'].values())
assert s['users'][uid]['profile']==keep['profile']
print('OK lifecycle: round reset preserves profile and archive snapshot')
PY
curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{"roundNumber":1}' "http://127.0.0.1:$PORT/api/admin/giveaway/history/delete" >/tmp/delete-v10.json
curl -fsS "http://127.0.0.1:$PORT/api/archive" >/tmp/archive-after-delete-v10.json
python3 - "$TMP/state.json" <<'PY'
import json,sys
s=json.load(open(sys.argv[1]));a=json.load(open('/tmp/archive-after-delete-v10.json'))['giveaways']
assert len(s['giveawayHistory'])==0 and a==[]
assert s['giveaway']['roundNumber']==2
print('OK archive delete: completed test round removed; active round untouched')
PY
