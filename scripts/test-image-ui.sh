#!/bin/sh
# `npm test` and `npm run check` pass from ui/ inside the test image.
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$root"
docker compose run --build --rm -w /build/ui test npm test
docker compose run --build --rm -w /build/ui test npm run check
