#!/bin/sh
# `cargo test --workspace` passes inside the test image.
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$root"
docker compose run --rm test cargo test --workspace
