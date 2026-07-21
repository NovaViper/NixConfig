#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage:" >&2
  echo "  $0 HOST TARGET USER SERIAL..." >&2
  echo >&2
  echo "Examples:" >&2
  echo "  $0 desktop root@192.168.1.50 novaviper 12345678" >&2
  echo "  $0 desktop root@192.168.1.50 novaviper 12345678 87654321" >&2
  exit 1
}

if [ $# -lt 4 ]; then
  echo "Error: Missing required arguments." >&2
  usage
fi

HOST="$1"
TARGET="$2"
USER="$3"
shift 3

# Ensure we can support instances like:
#   12345678 87654321
#   "12345678 87654321"
SERIALS="$*"

FLAKE_DIR="$(git rev-parse --show-toplevel)"
SECRETS_REPO="$(dirname "$FLAKE_DIR")/nix-secrets"
if [ ! -d "$SECRETS_REPO" ]; then
  echo "Error: Could not find nix-secrets repository:"
  echo "  $SECRETS_REPO"
  exit 1
fi

BOOTSTRAP=$(mktemp -d)

cleanup() {
  if [ -n "${PKCS:-}" ]; then
    ssh-add -e "$PKCS" 2>/dev/null || true
  fi

  rm -rf "$BOOTSTRAP"
}
trap cleanup EXIT

echo "==> Phase 1: Retrieve installer host key"
echo "  -> Fetching SSH host key from installer target"
HOST_AGE=$(
  ssh "$TARGET" \
    "cat /etc/ssh/ssh_host_ed25519_key.pub" |
    ssh-to-age
)
echo "  -> Add this key to nix-secrets:"
echo "     $HOST_AGE"
echo
echo "  -> Repository: $SECRETS_REPO"
echo "  -> Host:   $HOST"
echo "  -> Target: $TARGET"
echo
read -rp "Press enter after rekeying nix-secrets..."

echo
echo "==> Phase 2: Update nix-secrets flake input"

cd "$FLAKE_DIR"
if [ -z "${PKCS:-}" ]; then
  echo "Error: PKCS environment variable is not set." >&2
  echo "Enter the devshell that provides the PIV PKCS#11 path." >&2
  exit 1
fi

echo "  -> Removing existing PIV provider"
ssh-add -e "$PKCS" 2>/dev/null || true
echo "  -> Loading Yubikey PIV key"
if ! ssh-add -s "$PKCS"; then
  echo "Error: Failed to load YubiKey PIV key." >&2
  exit 1
fi
echo "  -> Updating nix-secrets input"
if ! nix flake lock nix-secrets; then
  echo "Error: Failed to update nix-secrets input." >&2
  echo "Verify the YubiKey PIV key and secrets access." >&2
  exit 1
fi

echo "  -> Removing YubiKey PIV provider"
ssh-add -e "$PKCS" 2>/dev/null || true
echo
echo "  -> PIV session released"
echo "  -> Age plugin requires a fresh YubiKey session"
echo "  -> Unplug and replug your YubiKey"
read -rp "Press enter after reinserting the YubiKey..."

echo "==> Phase 3: Generate Yubikey age identities"
echo "  -> Generating age identities for $USER with proposed serials: $SERIALS"
if ! just generate-age-keylist bootstrap "$USER" -s "$SERIALS"; then
  echo "Error: Failed to generate YubiKey age identities." >&2
  exit 1
fi
echo "  -> Verifying generated key files"
if [ ! -f "./bootstrap/var/lib/sops/keys.txt" ] ||
  [ ! -f "./bootstrap/home/$USER/.config/sops/age/keys.txt" ]; then
  echo "Error: Bootstrap key files were not generated." >&2
  exit 1
fi
if [ ! -s "./bootstrap/var/lib/sops/keys.txt" ] ||
  [ ! -s "./bootstrap/home/$USER/.config/sops/age/keys.txt" ]; then
  echo "Error: Bootstrap key files are empty." >&2
  exit 1
fi

echo
echo "==> Phase 4: Preparing nixos-anywhere extra files"
echo "  -> Creating temporary filesystem tree"
mkdir -p \
  "$BOOTSTRAP/var/lib/sops" \
  "$BOOTSTRAP/home/$USER/.config/sops/age"
echo "  -> Copying system sops identity"
cp ./bootstrap/var/lib/sops/keys.txt \
  "$BOOTSTRAP/var/lib/sops/keys.txt"
echo "  -> Copying user sops identity"
cp ./bootstrap/home/"$USER"/.config/sops/age/keys.txt \
  "$BOOTSTRAP/home/$USER/.config/sops/age/keys.txt"
echo "  -> Applying permissions"
chmod 600 \
  "$BOOTSTRAP/var/lib/sops/keys.txt" \
  "$BOOTSTRAP/home/$USER/.config/sops/age/keys.txt"

echo "  -> Bootstrap files:"
dir "$BOOTSTRAP/var/lib/sops/keys.txt" -l
dir "$BOOTSTRAP/home/$USER/.config/sops/age/keys.txt" -l

echo
echo "==> Phase 5: Install NixOS with nixos-anywhere"

nix run github:nix-community/nixos-anywhere -- \
  --flake ".#$HOST" \
  --copy-host-keys \
  --extra-files "$BOOTSTRAP" \
  "$TARGET"

echo
echo "==> Remote install complete!"
