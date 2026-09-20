#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; COOKIE="$(mktemp)"; PORT=4213
cleanup(){ kill "${PID:-}" 2>/dev/null || true; rm -rf "$TMP" "$COOKIE"; }
trap cleanup EXIT
cp -a "$ROOT/data/." "$TMP/"
HOST=127.0.0.1 PORT=$PORT DATA_DIR="$TMP" NODE_ENV=development node "$ROOT/server.js" >/tmp/sovara-v13-test.log 2>&1 & PID=$!
sleep 1
BASE="http://127.0.0.1:$PORT"
curl -fsS -c "$COOKIE" -H 'Content-Type: application/json' -d '{"admin":true}' "$BASE/api/auth/demo" >/dev/null
# Two test viewers with valid profiles.
for i in 1 2; do curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "$BASE/api/admin/demo/add" >/dev/null; done
# Enable offline chat and 30 sec cooldown.
curl -fsS -b "$COOKIE" -X PUT -H 'Content-Type: application/json' -d '{"countMessagesOffline":true,"messagePointsEnabled":true,"watchtimePointsEnabled":true,"pointsPerMessage":1,"pointsPerMinute":1,"chatCooldownSeconds":30}' "$BASE/api/admin/settings" >/dev/null
python3 - "$TMP/state.json" <<'PY'
import json,sys
s=json.load(open(sys.argv[1])); ids=[k for k in s['users'] if k.startswith('990')]
assert len(ids)>=2
open('/tmp/v13ids','w').write('\n'.join(ids[:2]))
PY
mapfile -t IDS </tmp/v13ids
U1="${IDS[0]}"; U2="${IDS[1]}"
# First chat counts, second is cooldown.
A=$(curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d "{\"twitchUserId\":\"$U1\",\"text\":\"first\"}" "$BASE/api/admin/chat/simulate")
B=$(curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d "{\"twitchUserId\":\"$U1\",\"text\":\"second\"}" "$BASE/api/admin/chat/simulate")
python3 - "$TMP/state.json" "$A" "$B" <<'PY'
import json,sys
s=json.load(open(sys.argv[1])); a=json.loads(sys.argv[2]); b=json.loads(sys.argv[3])
assert a['result']['counted'] is True
assert b['result']['counted'] is False and b['result']['reason']=='cooldown'
uid=a['result']['user']['twitchUserId']
open('/tmp/v13before','w').write(json.dumps({k:{'points':u['points'],'tickets':u['tickets'],'totalWatchMinutes':u['totalWatchMinutes']} for k,u in s['users'].items()}))
print('OK cooldown: second message blocked without losing chat history')
PY
# Start safe test round.
curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{"minParticipants":2,"durationMinutes":5}' "$BASE/api/admin/giveaway/test/start" >/dev/null
# Test reset should zero counters; then give both one ticket.
for U in "$U1" "$U2"; do curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d "{\"twitchUserId\":\"$U\",\"amount\":300}" "$BASE/api/admin/user/points" >/dev/null; done
python3 - "$TMP/state.json" <<'PY'
import json,sys,time
p=sys.argv[1]; s=json.load(open(p)); g=s['giveaway']
assert g['isTest'] is True and g['startedAt'] and g['endsAt']
assert g['minParticipants']==2 and g['testDurationMinutes']==5
# expire it without waiting
s['giveaway']['endsAt']=int(time.time()*1000)-1000
json.dump(s,open(p,'w'),ensure_ascii=False,indent=2)
print('OK test round: starts with custom participant count and duration')
PY
curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "$BASE/api/admin/giveaway/draw" >/dev/null
curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "$BASE/api/admin/giveaway/prize-delivered" >/dev/null
curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "$BASE/api/admin/giveaway/complete" >/dev/null
ARCH=$(curl -fsS "$BASE/api/archive")
python3 - "$ARCH" <<'PY'
import json,sys
a=json.loads(sys.argv[1])['giveaways']; assert a==[], a
print('OK test archive: completed test is never public')
PY
# Return to real round; old counters must be restored.
curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "$BASE/api/admin/giveaway/new-round" >/dev/null
python3 - "$TMP/state.json" <<'PY'
import json,sys
s=json.load(open(sys.argv[1])); before=json.load(open('/tmp/v13before'))
assert s['giveaway']['isTest'] is False and s['giveaway']['roundNumber']==1 and s['giveaway']['startedAt'] is None
for uid,v in before.items():
    u=s['users'][uid]
    assert u['points']==v['points'] and u['tickets']==v['tickets'] and u['totalWatchMinutes']==v['totalWatchMinutes'], (uid,u,v)
print('OK test restore: real round progress restored exactly')
PY
# Manual backup + audit.
BK=$(curl -fsS -b "$COOKIE" -H 'Content-Type: application/json' -d '{}' "$BASE/api/admin/backups/create")
AUD=$(curl -fsS -b "$COOKIE" "$BASE/api/admin/audit?limit=200")
python3 - "$TMP" "$BK" "$AUD" <<'PY'
import json,sys,os,glob
root=sys.argv[1]; b=json.loads(sys.argv[2]); a=json.loads(sys.argv[3])['audit']
assert b['ok'] and b['backup']['name'].startswith('backup-')
assert os.path.exists(os.path.join(root,'backups',b['backup']['name']))
types={x['type'] for x in a}
for t in ['admin_settings_updated','test_round_started','winner_selected','test_giveaway_completed','test_round_restored','backup_created']:
    assert t in types, (t,types)
actors=[x.get('data',{}).get('actor') for x in a if x.get('data',{}).get('actor')]
assert actors and all(x.get('login')=='sovara_' for x in actors)
print('OK audit + backups: actor tracked and backup file created')
PY
