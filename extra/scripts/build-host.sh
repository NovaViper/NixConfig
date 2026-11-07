#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: just build-host [OPTIONS] [--] HOST ACTION

ARGUMENTS
  HOST      Flake host name and SSH target alias
  ACTION    nixos-rebuild action, for example:
    switch      Activate now and make the configuration the boot default
    test        Activate now without changing the boot default
    boot        Make the configuration the boot default; activate on reboot
    build       Build only; do not activate or change the boot default

OPTIONS
  -b, --build-on LOCATION     Choose the build location (default: auto):
    local       Build on this machine
    remote      Build on HOST
    auto        Build locally if platforms match, otherwise on HOST
  -h, --help                  Show this help

NOTES
  Options may appear before or after the positional arguments.
  "--" ends option parsing so values starting with "-" aren't mistaken for flags.

EXAMPLES
  just build-host -b remote HOST switch
  just build-host HOST test --build-on local
  just build-host -b auto HOST boot
EOF
}

if [ "$#" -eq 0 ]; then
  usage
  exit 0
fi

BUILD_ON=auto
POSITIONAL=()
while [ "$#" -gt 0 ]; do
  case "$1" in
  -b | --build-on)
    case "${2:-}" in
    auto | local | remote) BUILD_ON="$2" ;;
    *)
      echo "Error: --build-on requires auto, local, or remote." >&2
      exit 1
      ;;
    esac
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  --)
    shift
    POSITIONAL+=("$@")
    break
    ;;
  -*)
    echo "Error: Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  *) POSITIONAL+=("$1") ;;
  esac
  shift
done

if [ "${#POSITIONAL[@]}" -ne 2 ]; then
  usage >&2
  exit 1
fi
HOST="${POSITIONAL[0]}"
ACTION="${POSITIONAL[1]}"
cd "$(git rev-parse --show-toplevel)"

if [ "$BUILD_ON" = auto ]; then
  LOCAL_SYSTEM=$(nix eval --impure --raw --expr builtins.currentSystem)
  HOST_SYSTEM=$(nix eval --raw ".#nixosConfigurations.$HOST.pkgs.stdenv.hostPlatform.system")
  if [ "$LOCAL_SYSTEM" = "$HOST_SYSTEM" ]; then
    BUILD_ON=local
  else
    BUILD_ON=remote
  fi
  echo "Auto build selection: local platform $LOCAL_SYSTEM, target platform $HOST_SYSTEM."
fi

BUILD_OPTIONS=()
if [ "$BUILD_ON" = remote ]; then
  echo "Building remotely on $HOST."
  BUILD_OPTIONS=(--build-host "$HOST")
else
  echo "Building locally, targeting $HOST."
fi

# A PTY merges remote stderr into stdout, corrupting captured Nix store paths.
# Override RequestTTY from SSH aliases; rebuild handles sudo prompts itself.
NIX_SSHOPTS="${NIX_SSHOPTS:+$NIX_SSHOPTS }-T" nixos-rebuild \
  --target-host "$HOST" "${BUILD_OPTIONS[@]}" \
  --show-trace --no-reexec --elevate=sudo --ask-elevate-password \
  --flake ".#$HOST" "$ACTION"
