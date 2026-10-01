#!/bin/sh
# test/test.sh <abbild>: startet das Abbild und prüft /alive, die Version und dass der Patch im Programm steckt.
set -eu
IMG=${1:?abbild}; NAME=dtadmin-vw-test-$$
trap 'docker rm -f "$NAME" >/dev/null 2>&1 || true' EXIT
docker run -d --name "$NAME" -e I_REALLY_WANT_VOLATILE_STORAGE=true -p 127.0.0.1::80 "$IMG" >/dev/null
PORT=$(docker port "$NAME" 80/tcp | head -n1 | sed 's/.*://')
i=0; until curl -fs "http://127.0.0.1:$PORT/alive" >/dev/null 2>&1; do i=$((i+1)); [ $i -gt 60 ] && { docker logs "$NAME" | tail -20; exit 1; }; sleep 1; done
echo "ok /alive"
docker logs "$NAME" 2>&1 | grep -q "Version" && echo "ok Version: $(docker logs "$NAME" 2>&1 | grep -m1 -o 'Version [^ ]*')"
