#!/bin/sh
# test/build.sh <vaultwarden-tag> <abbild-version>: offizielles Tag klonen, Commit prüfen, Patches anwenden, bauen.
set -eu
TAG=${1:?vaultwarden-tag}; VERSION=${2:?abbild-version}
COMMIT_1_37_3=eb212e23fad88e6136723f43e5b73543fa7026d3
hier=$(cd "$(dirname "$0")/.." && pwd)
arbeit=$(mktemp -d); trap 'rm -rf "$arbeit"' EXIT
git clone -q --depth 1 --branch "$TAG" https://github.com/dani-garcia/vaultwarden.git "$arbeit/src"
cd "$arbeit/src"
if [ "$TAG" = 1.37.3 ] && [ "$(git rev-parse HEAD)" != "$COMMIT_1_37_3" ]; then
  echo "FEHLER: Tag $TAG zeigt nicht auf $COMMIT_1_37_3" >&2; exit 1
fi
for p in "$hier"/patches/*.patch; do git apply "$p"; echo "angewendet: $(basename "$p")"; done
docker buildx build --platform linux/amd64 -f docker/Dockerfile.alpine --build-arg VW_VERSION="$VERSION" \
  -t "dtadmin-vaultwarden:$VERSION" --load .
