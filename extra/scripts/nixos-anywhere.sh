#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: just remote-install [OPTIONS] [--] HOST TARGET USER SERIAL...

ARGUMENTS
  HOST        Flake host name to install
  TARGET      SSH target alias or user@host for the initial connection
  USER        User account receiving provisioned SOPS identities
  SERIAL...   YubiKey serial numbers, separated by spaces or in one quoted string

OPTIONS
  -r, --resume                Skip kexec and disk setup; require /mnt and /mnt/boot mounted
  -R, --reboot                Reboot after installation
  -n, --no-reboot             Stop after installation without rebooting
  -b, --build-on LOCATION     Choose the build location (default: auto):
    local     Build on this machine and copy to the TARGET
    remote    Build on the TARGET
    auto      Build locally if platforms match, otherwise on the TARGET
  -h, --help                  Show this help

NOTES
  Fresh installs reboot by default; resumed installs do not.
  Installation runs as root on the target.
  Options may appear before or after the positional arguments.
  "--" ends option parsing so values starting with "-" aren't mistaken for flags.

EXAMPLES
  just remote-install HOST SSH_TARGET USER SERIAL
  just remote-install -r -n HOST SSH_TARGET USER SERIAL1 SERIAL2
  just remote-install -r -n HOST SSH_TARGET USER "SERIAL1 SERIAL2"
  just remote-install HOST SSH_TARGET USER SERIAL --resume --reboot
  just remote-install -b remote -n HOST SSH_TARGET USER SERIAL
EOF
}

if [ "$#" -eq 0 ]; then
  usage
  exit 0
fi

RESUME=false
REBOOT=""
BUILD_ON=auto
POSITIONAL=()
while [ "$#" -gt 0 ]; do
  case "$1" in
  -r | --resume) RESUME=true ;;
  -R | --reboot) REBOOT=true ;;
  -n | --no-reboot) REBOOT=false ;;
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
set -- "${POSITIONAL[@]}"

if [ "$#" -lt 4 ]; then
  echo "Error: HOST, TARGET, USER, and at least one SERIAL are required." >&2
  usage >&2
  exit 1
fi

if [ -z "$REBOOT" ]; then
  if [ "$RESUME" = true ]; then
    REBOOT=false
  else
    REBOOT=true
  fi
fi

HOST="$1"
TARGET="$2"
INSTALL_USER="$3"
shift 3

# Disk setup and installer always run as root in nixos-anywhere, so we force the SSH target to be root.
ROOT_TARGET="root@${TARGET#*@}"

verify_mounts() {
  echo "  -> Checking /mnt and /mnt/boot on $ROOT_TARGET"
  if ! ssh "$ROOT_TARGET" 'mountpoint -q /mnt && mountpoint -q /mnt/boot'; then
    echo "Error: Both /mnt and /mnt/boot must be mounted. Refusing to install." >&2
    exit 1
  fi
}

if [ "$RESUME" = true ]; then
  echo "==> Resume mode: skipping kexec and all disk scripts"
  verify_mounts
fi

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
if ! nix flake update nix-secrets; then
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
echo "  -> Generating age identities for $INSTALL_USER with proposed serials: $SERIALS"
if ! just generate-age-keylist bootstrap "$INSTALL_USER" -s "$SERIALS"; then
  echo "Error: Failed to generate YubiKey age identities." >&2
  exit 1
fi
echo "  -> Verifying generated key files"
if [ ! -f "./bootstrap/var/lib/sops/keys.txt" ] ||
  [ ! -f "./bootstrap/home/$INSTALL_USER/.config/sops/age/keys.txt" ]; then
  echo "Error: Bootstrap key files were not generated." >&2
  exit 1
fi
if [ ! -s "./bootstrap/var/lib/sops/keys.txt" ] ||
  [ ! -s "./bootstrap/home/$INSTALL_USER/.config/sops/age/keys.txt" ]; then
  echo "Error: Bootstrap key files are empty." >&2
  exit 1
fi

echo
echo "==> Phase 4: Preparing nixos-anywhere extra files"
echo "  -> Creating temporary filesystem tree"
mkdir -p \
  "$BOOTSTRAP/var/lib/sops" \
  "$BOOTSTRAP/home/$INSTALL_USER/.config/sops/age"
echo "  -> Copying system sops identity"
cp ./bootstrap/var/lib/sops/keys.txt \
  "$BOOTSTRAP/var/lib/sops/keys.txt"
echo "  -> Copying user sops identity"
cp ./bootstrap/home/"$INSTALL_USER"/.config/sops/age/keys.txt \
  "$BOOTSTRAP/home/$INSTALL_USER/.config/sops/age/keys.txt"
echo "  -> Applying permissions"
chmod 600 \
  "$BOOTSTRAP/var/lib/sops/keys.txt" \
  "$BOOTSTRAP/home/$INSTALL_USER/.config/sops/age/keys.txt"

echo "  -> Bootstrap files:"
dir "$BOOTSTRAP/var/lib/sops/keys.txt" -l
dir "$BOOTSTRAP/home/$INSTALL_USER/.config/sops/age/keys.txt" -l

# Check if we should build locally or remotely based on the current system and the target system.
if [ "$BUILD_ON" = auto ]; then
  LOCAL_SYSTEM=$(nix eval --impure --raw --expr builtins.currentSystem)
  HOST_SYSTEM=$(nix eval --raw ".#nixosConfigurations.$HOST.pkgs.stdenv.hostPlatform.system")
  if [ "$LOCAL_SYSTEM" = "$HOST_SYSTEM" ]; then
    BUILD_ON=local
  else
    BUILD_ON=remote
  fi
fi
echo "  -> Build location: $BUILD_ON"

echo
if [ "$RESUME" = false ]; then
  echo "==> Phase 5: Kexec into the NixOS installer"
  nix run github:nix-community/nixos-anywhere -- \
    --flake ".#$HOST" \
    --build-on "$BUILD_ON" \
    --phases kexec \
    "$TARGET"

  echo
  echo "==> Phase 6: Partition, format, and mount disks"
  echo "  !! WARNING: disks-create and disks-format will PERMANENTLY ERASE all data"
  echo "     on $HOST's disks (target: $ROOT_TARGET)."
  read -rp "  Type the host name ('$HOST') to confirm and continue: " CONFIRM_HOST
  if [ "$CONFIRM_HOST" != "$HOST" ]; then
    echo "Error: Confirmation did not match '$HOST'. Aborting before touching any disks." >&2
    exit 1
  fi

  for script in disks-create disks-format disks-mount; do
    echo "  -> Building $script"
    if [ "$BUILD_ON" = remote ]; then
      script_path=$(nix build --eval-store auto --store "ssh-ng://$ROOT_TARGET" \
        --no-link --print-out-paths ".#nixosConfigurations.$HOST.config.$script")
    else
      script_path=$(nix build --no-link --print-out-paths ".#nixosConfigurations.$HOST.config.$script")
      echo "  -> Copying $script to $ROOT_TARGET"
      nix copy --to "ssh://$ROOT_TARGET" "$script_path"
    fi
    echo "  -> Running $script on $ROOT_TARGET"
    # Expand the locally built store path before sending it to the target.
    # shellcheck disable=SC2029
    ssh "$ROOT_TARGET" "$script_path/bin/$script"
  done

fi

verify_mounts

echo
echo "==> Phase 7: Install NixOS with nixos-anywhere"
INSTALL_PHASES="install"
if [ "$REBOOT" = true ]; then
  INSTALL_PHASES="install,reboot"
fi
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#$HOST" \
  --build-on "$BUILD_ON" \
  --extra-files "$BOOTSTRAP" \
  --copy-host-keys \
  --phases "$INSTALL_PHASES" \
  "$ROOT_TARGET"

echo
if [ "$REBOOT" = false ]; then
  echo "==> Installation complete. The VPS remains in the installer; no reboot was requested."
  echo "    Verify boot files and provisioned credentials before rebooting."
else
  echo "==> Remote install complete!"
fi
