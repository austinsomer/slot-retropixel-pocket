#!/bin/sh
# Cross-compile Slot for the RetroPixel Pocket (aarch64, glibc >= 2.31) from an x86 host.
set -e
cd "$(dirname "$0")/.."
docker run --rm --platform linux/amd64 -v "$PWD":/src -v slot-cargo-x86:/usr/local/cargo/registry -w /src rust:1-bullseye sh -c '
  set -e
  dpkg -s gcc-aarch64-linux-gnu >/dev/null 2>&1 || { apt-get update -qq && apt-get install -y -qq gcc-aarch64-linux-gnu libc6-dev-arm64-cross >/dev/null; }
  rustup target add aarch64-unknown-linux-gnu >/dev/null 2>&1
  export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc
  export CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc
  cargo build --profile device --target aarch64-unknown-linux-gnu --target-dir target-pocket \
    -p slot --no-default-features --features device
  chown -R '"$(id -u):$(id -g)"' target-pocket
'
file target-pocket/aarch64-unknown-linux-gnu/device/slot
