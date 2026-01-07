#!/usr/bin/env bash

set -euo pipefail

#-------------------------------
# GLOBAL VARIABLE
#-------------------------------
# Safely initialize variables
: "${SSH_DIR:=$HOME/.ssh}"
: "${DRY_RUN:=false}"

# Check for command-line arguments
for arg in "$@"; do
  case "$arg" in
  --dry-run) DRY_RUN=true ;;
  esac
done

# Global temp folders registry
declare -a TMP_DIRS
declare -a YUBIKEYS

# Arrays storing per-key summaries (indexed)
TOTAL_SERIAL=()
TOTAL_MODEL=()
TOTAL_FF=()
TOTAL_INSTALLED=()
TOTAL_SKIPPED=()

#-------------------------------
# HELPERS
#-------------------------------
create_tmpdir() {
  local dir
  dir=$(mktemp -d)
  TMP_DIRS+=("$dir")
  echo "$dir"
}

# shellcheck disable=SC2329
global_cleanup() {
  for dir in "${TMP_DIRS[@]}"; do
    [ -d "$dir" ] && rm -rf "$dir"
  done
}

cleanup_tmpdir() {
  local dir="$1"
  [ -n "$dir" ] && [ -d "$dir" ] && rm -rf "$dir"
}

# Normalize Yubikey form factor
normalize_form_factor() {
  local raw="$1"
  local prefix=""
  local ff

  # Append nano indicator if applicable
  [[ $raw == *Nano* ]] && prefix="n"

  case "$raw" in
  *USB-C*) ff="usbc" ;;
  *USB-A*) ff="usba" ;;
  *) ff="unknown" ;;
  esac

  echo "${prefix}${ff}"
}

# Run global cleanup on exit
trap global_cleanup EXIT
#-------------------------------

# Ensure .ssh exists, but only create it if it's missing
if [ ! -d "$SSH_DIR" ]; then
  mkdir "$SSH_DIR"
  chmod 700 "$SSH_DIR"
  echo "Created $SSH_DIR"
fi

# Detect Yubikeys
while IFS= read -r line; do
  # Extract serial number
  serial=$(sed -n 's/.*Serial: \([0-9]\+\).*/\1/p' <<<"$line")
  # Strip serial from line, remove [OTP+FIDO+CCID], trim leading space and trailing whitespace
  model="$(
    sed \
      -e 's/ Serial: [0-9]\+//' \
      -e 's/\[OTP+FIDO+CCID\]//' \
      -e 's/^[[:space:]]*//' \
      -e 's/[[:space:]]*$//' \
      <<<"$line"
  )"

  # Query form factor safely
  info=$(ykman --device "$serial" info 2>/dev/null || true)
  raw_ff=$(echo "$info" | grep -i "Form factor" | sed 's/^Form factor: *//' || echo "")
  ff=$(normalize_form_factor "$raw_ff")

  YUBIKEYS+=("${serial}|${model}|${ff}")
done < <(ykman list)

# Check if any keys found
if [ "${#YUBIKEYS[@]}" -eq 0 ]; then
  echo "No YubiKeys detected."
  exit 1
fi

# Display detected keys
echo "Detected YubiKeys:"
for entry in "${YUBIKEYS[@]}"; do
  IFS='|' read -r serial model ff <<<"$entry"
  printf "  Model: %s | Serial Num: %s | Form Factor: %s\n" "$model" "$serial" "$ff"
done

# Process each Yubikey sequentially
for entry in "${YUBIKEYS[@]}"; do
  IFS='|' read -r SERIAL MODEL FORM_FACTOR <<<"$entry"

  echo
  echo "Processing $MODEL"
  echo "Serial #: $SERIAL, Form Factor: $FORM_FACTOR"
  echo "Please remove all other Yubikeys except this one, then press ENTER..."
  read -r

  # Temporary folder for this key
  TMP_DIR=$(create_tmpdir)
  cd "$TMP_DIR"

  # Import resident keys into temporary folder
  echo "Importing resident SSH keys..."
  ssh-keygen -K
  echo

  # Rename and install keys
  for privkey in "$TMP_DIR"/id_*_sk_rk_*; do
    [ -f "$privkey" ] || continue
    [[ $privkey == *.pub ]] && continue
    pubkey="$privkey.pub"

    # Extract application name and key type
    base=$(basename "$privkey")
    name="${base#id_}"           # e.g. ed25519_sk_rk_application
    KEY_PREFIX="${name%_rk_*}"   # e.g. ed25519_sk
    APPLICATION="${name##*_rk_}" # e.g. application

    # Normalize key type
    case "$KEY_PREFIX" in
    ed25519_sk) KEY_TYPE="ed25519-sk" ;;
    ecdsa_sk) KEY_TYPE="ecdsa-sk" ;;
    *) KEY_TYPE="$KEY_PREFIX" ;;
    esac

    # Format of the new name we want to rename the keys to
    NEW_BASE="${APPLICATION}_${KEY_TYPE}_${FORM_FACTOR}"

    if [ "$DRY_RUN" = true ]; then
      echo "[DRY-RUN] Would move: $privkey → $SSH_DIR/$NEW_BASE"
      echo "[DRY-RUN] Would move: $pubkey → $SSH_DIR/$NEW_BASE.pub"
      continue
    fi

    # Skip if already exists
    if [ -e "$SSH_DIR/$NEW_BASE" ] || [ -e "$SSH_DIR/$NEW_BASE.pub" ]; then
      echo "Skipping: $NEW_BASE already exists"
      TOTAL_SKIPPED+=("$NEW_BASE")
      continue
    fi

    echo "Installing keypair: $base -> $NEW_BASE"
    mv "$privkey" "$SSH_DIR/$NEW_BASE"
    mv "$pubkey" "$SSH_DIR/$NEW_BASE.pub"
    chmod 600 "$SSH_DIR/$NEW_BASE"
    chmod 644 "$SSH_DIR/$NEW_BASE.pub"
    TOTAL_INSTALLED+=("$NEW_BASE")
  done

  # Cleanup temp folder for this key
  echo Deleting temporary folder used for this key...
  cleanup_tmpdir "$TMP_DIR"

  # Update summary arrays (if we're not in dry-run mode)
  if [ "$DRY_RUN" = false ]; then
    TOTAL_SERIAL+=("$SERIAL")
    TOTAL_MODEL+=("$MODEL")
    TOTAL_FF+=("$FORM_FACTOR")
  fi
done

# Quit early if we are doing dry runs
if [ "$DRY_RUN" = true ]; then
  echo Dry run completed! Exiting...
  exit 0
fi

# Summary
echo
echo "===================="
echo "Import summary"
echo "===================="
for i in "${!TOTAL_SERIAL[@]}"; do
  printf "YubiKey %s | Model: %s | Form Factor: %s\n" \
    "${TOTAL_SERIAL[i]}" \
    "${TOTAL_MODEL[i]}" \
    "${TOTAL_FF[i]}"
done

echo
echo "Installed keys : ${#TOTAL_INSTALLED[@]}"
echo "Skipped keys   : ${#TOTAL_SKIPPED[@]}"
exit 0
