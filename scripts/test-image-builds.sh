#!/bin/sh
# `docker build --target test .` produces an image.
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
image=$(docker build -q --target test "$root")
docker image inspect "$image" >/dev/null
printf 'test target produced an image\n'
