#!/bin/sh
# solax stays on the host network with its three mounts. The test service
# does not, and it does not mount the live database, config, or metrics file.
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$root"

ROOT="$root" python3 - <<'PY'
import json
import os
import subprocess
import sys
from pathlib import Path

root = Path(os.environ["ROOT"]).resolve()
config = json.loads(
    subprocess.check_output(["docker", "compose", "config", "--format", "json"], cwd=root)
)
services = config["services"]

def fail(message):
    print(message, file=sys.stderr)
    sys.exit(1)

solax = services.get("solax")
if solax is None:
    fail("solax service is missing")
if solax.get("network_mode") != "host":
    fail(f"solax network_mode is {solax.get('network_mode')!r}, expected 'host'")

def mount(volume):
    source = Path(volume["source"]).resolve().relative_to(root).as_posix()
    selinux = (volume.get("bind") or {}).get("selinux")
    return (source, volume["target"], bool(volume.get("read_only", False)), selinux)

expected = {
    ("solax-data", "/app/solax-data", False, "z"),
    ("config.toml", "/app/config.toml", True, "z"),
    ("server/metrics.toml", "/app/metrics.toml", True, "z"),
}
got = {mount(volume) for volume in solax.get("volumes") or []}
if got != expected:
    fail(f"solax mounts are {sorted(got)}, expected {sorted(expected)}")

test = services.get("test")
if test is None:
    fail("test service is missing")
if test.get("network_mode") == "host":
    fail("test service uses host network")

forbidden_sources = {"solax-data", "config.toml", "server/metrics.toml"}
forbidden_targets = {"/app/solax-data", "/app/config.toml", "/app/metrics.toml"}
for volume in test.get("volumes") or []:
    source = Path(volume["source"]).resolve().relative_to(root).as_posix()
    target = volume["target"]
    if source in forbidden_sources or target in forbidden_targets:
        fail(f"test service mounts {source} at {target}")

print("solax stays on the host network with its three mounts; test mounts neither the database nor config")
PY
