#!/usr/bin/env sh
set -o errexit

usage() {
  echo "Usage:" >&2
  echo "  $0 host -s \"12345678 87654321\"" >&2
  echo "  $0 installer -s \"12345678 87654321\"" >&2
  echo "  $0 bootstrap USER -s \"12345678 87654321\"" >&2
  exit 1
}

# ======= Step 1: Parsing CONTEXT
if [ $# -lt 1 ]; then
  echo "Error: CONTEXT is required" >&2
  usage
fi

CONTEXT="$1"
# Shift CONTEXT off the arguments list
shift

# Validate CONTEXT early
case "$CONTEXT" in
host | installer | bootstrap)
  ;;
*)
  echo "Error: Unknown CONTEXT '$CONTEXT'" >&2
  echo "Valid contexts: host installer bootstrap" >&2
  exit 1
  ;;
esac

BOOTSTRAP_USER=""
# Bootstrap mode needs the target user's name
if [ "$CONTEXT" = "bootstrap" ]; then
  if [ $# -lt 1 ] || [ "${1#-}" != "$1" ]; then
    echo "Error: bootstrap mode requires a username before -s" >&2
    usage
  fi

  BOOTSTRAP_USER="$1"
  shift
fi

# ======= Step 2: Parsing -s option
SERIALS="" # Helper variable that we will use to split up the values from -s
while [ $# -gt 0 ]; do
  case "$1" in
  -s)
    shift
    if [ $# -eq 0 ]; then
      echo "Error: Option -s requires at least one serial number." >&2
      usage
    fi
    while [ $# -gt 0 ]; do
      SERIALS="$SERIALS $1"
      shift
    done
    ;;
  *)
    echo "Error: Unexpected argument '$1'" >&2
    usage
    ;;
  esac
done

# ======= Step 3: Validate Yubikey serial numbers
if [ -z "$SERIALS" ]; then
  echo "Error: -s option is required and cannot be empty." >&2
  usage
fi

# Use `set` to split the string into positional parameters
set -- $SERIALS

# Validate the values from the -s parameter
for id in "$@"; do
  case "$id" in
  [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) ;;
  *)
    echo "Error: Each value in -s must be exactly 8 numeric digits. Found: '$id'" >&2
    exit 1
    ;;
  esac
done

# ======= Step 4: Begin the provisioning of the key file
# Announce what deposit mode the script will use based on CONTEXT
case $CONTEXT in
host)
  echo "Host mode enabled."
  echo "Output: COPY_ME_ELSEWHERE/keys.txt"
  ;;

installer)
  echo "Installer mode enabled."
  echo "Output: /mnt/var/lib/sops/keys.txt"
  ;;

bootstrap)
  echo "Bootstrap mode enabled."
  echo "User: $BOOTSTRAP_USER"
  echo "Output: ./bootstrap filesystem tree"
  ;;
esac

# Create temporary folder to create the key file in (this will be removed later
# either if the script fails or when it completes successfully)
tempdir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename "$0").XXXXXXXXXX") || {
  echo "Error: Failed to create temp directory." >&2
  exit 3
}
keyfile="$tempdir/keys.txt"
cleanup() {
  echo "Removing temporary keyfile"
  rm -rf "$tempdir"
}
trap cleanup EXIT

# Find identity file for a age key located in slot 1 for each yubikey serial
# number from the -s option
found_keys=0
failed_keys=0
for id in "$@"; do
  echo "Searching for yubikey with the serial number $id"
  if age-plugin-yubikey --serial "$id" --slot 1 --identity >>"$keyfile"; then
    echo "Found! Added identity file"
    found_keys=$((found_keys + 1))
  else
    echo "Warning: Could not find or read Yubikey with serial $id, skipping" >&2
    failed_keys=$((failed_keys + 1))
  fi
  echo
done

if [ "$found_keys" -eq 0 ]; then
  echo "Error: No Yubikey age identities were generated." >&2
  exit 1
fi

echo "Added $found_keys Yubikey identity file(s)."

if [ "$failed_keys" -gt 0 ]; then
  echo "Warning: $failed_keys Yubikey identity file(s) failed to generate." >&2
fi

# ======= Step 5: Transfer newly generated keyfile into paths based on selected CONTEXT
# Just drop the file if we're not in installer mode
if [ "$CONTEXT" = "host" ]; then
  echo "Dropping keyfile into COPY_ME_ELSEWHERE folder. Please make sure to copy them into either the system-level sops 'keys.txt' folder or the user level sops 'keys.txt' folder!"
  mkdir --parents ./COPY_ME_ELSEWHERE
  cp "$keyfile" ./COPY_ME_ELSEWHERE/keys.txt
  chmod 600 ./COPY_ME_ELSEWHERE/keys.txt
  dir ./COPY_ME_ELSEWHERE/keys.txt -l
  echo "Done!"
  exit 0
fi

if [ "$CONTEXT" = "bootstrap" ]; then
  echo "Dropping keyfile for nixos-anywhere extra-files..."
  # System-level sops identity
  mkdir --parents ./bootstrap/var/lib/sops
  cp "$keyfile" ./bootstrap/var/lib/sops/keys.txt

  # User-level sops identity
  mkdir --parents -- "./bootstrap/home/$BOOTSTRAP_USER/.config/sops/age"
  cp "$keyfile" -- "./bootstrap/home/$BOOTSTRAP_USER/.config/sops/age/keys.txt"

  chmod 600 \
    ./bootstrap/var/lib/sops/keys.txt \
    "./bootstrap/home/$BOOTSTRAP_USER/.config/sops/age/keys.txt"

  dir ./bootstrap/var/lib/sops/keys.txt -l
  dir "./bootstrap/home/$BOOTSTRAP_USER/.config/sops/age/keys.txt" -l
  echo "Done!"

  exit 0
fi

# Make sure that we partitioned the drive
if [ "$CONTEXT" = "installer" ]; then
  if [ ! -d "/mnt" ]; then
    echo "Error: You didn't finish partitioning the new system! /mnt doesn't exist!" >&2
    exit 4
  fi

  echo "Deploying identities into host sops path: /mnt/var/lib/sops"
  sudo mkdir --parents /mnt/var/lib/sops
  sudo cp "$keyfile" /mnt/var/lib/sops/keys.txt
  sudo chmod 600 /mnt/var/lib/sops/keys.txt
  dir /mnt/var/lib/sops/keys.txt -l
  echo "Done!"
  exit 0
fi

echo "Error: Unexpected execution path." >&2
exit 9
