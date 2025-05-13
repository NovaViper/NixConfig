#!/usr/bin/env sh
set -o errexit

# ======= Step 1: Parsing CONTEXT and the -s option
CONTEXT="$1"

# Shift CONTEXT off the arguments list
shift

input=""                   # Helper variable that we will use to split up the values from -s
while getopts "s:" opt; do # Validate the values of -s
	case "$opt" in
	s) input="$OPTARG" ;;
	:)
		echo "Error: Option -$OPTARG requires an argument!" >&2
		exit 1
		;;
	\?)
		echo "Error: Invalid option -$OPTARG" >&2
		exit 1
		;;
	esac
done

# Use `set` to split the string into positional parameters
set -- $input

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

# ======= Step 2: Begin the provisioning of the key file
# Annouce what deposit mode the script will use based on CONTEXT
case $CONTEXT in
"host")
	echo "Host mode enabled, will drop the result into the COPY_ME_ELSEWHERE to be moved later"
	;;
"installer")
	echo "Installer mode enabled, will drop the result into /mnt/var/lib/sops/keys.txt"
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
for id in "$@"; do
	echo "Searching for yubikey with the serial number $id"
	age-plugin-yubikey --serial "$id" --slot 1 --identity >>"$keyfile" && echo "Found! Added identity file"
	echo
done

# ======= Step 2: Transfer newly generated keyfile into paths based on selected CONTEXT
# Just drop the file if we're not in installer mode
if [ "$CONTEXT" = "host" ]; then
	echo "Dropping keyfile into COPY_ME_ELSEWHERE folder. Please make sure to copy them into either the system-level sops 'keys.txt' folder or the user level sops 'keys.txt' folder!"
	mkdir --parents ./COPY_ME_ELSEWHERE && cp "$keyfile" ./COPY_ME_ELSEWHERE
	exit 0
fi

# Make sure that we partitioned the drive
if [ -d "/mnt" ]; then
	echo "Found all available keys and their first identity slot"
	echo "Deploying identities into host sops path: /mnt/var/lib/sops"
	sudo mkdir --parents /mnt/var/lib/sops && sudo cp "$keyfile" /mnt/var/lib/sops
	dir /mnt/var/lib/sops/keys.txt -l
	echo "Done!"
	exit 0
else
	echo "Error: You didn't finish partioning the new system! /mnt doesn't exist!"
	exit 4
fi

echo "Error: Couldn't find any matching yubikeys!"
exit 9
