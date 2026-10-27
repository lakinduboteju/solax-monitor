#!/bin/sh
# The image from `docker build .` still starts the server.
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
image=$(docker build -q "$root")
cmd=$(docker image inspect --format '{{json .Config.Cmd}}' "$image")

if [ "$cmd" != '["solax-server"]' ]; then
  printf 'release image command is %s, expected ["solax-server"]\n' "$cmd" >&2
  exit 1
fi

printf 'release image command is solax-server\n'
