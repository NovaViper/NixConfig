#!/usr/bin/env sh

set -o errexit

INPUTS="$1"

cleanup() {
	# If flake.lock has been modified
	if ! git diff --exit-code --quiet flake.lock >/dev/null; then
		echo "Undoing flake.lock changes."
		git restore flake.lock
		exit 1
	fi
}
trap cleanup EXIT

joined=""
for input in $INPUTS; do
	# Replace all separating spaces with commas
	if [ -z "$joined" ]; then
		joined="$input"
	else
		joined="$joined,$input"
	fi

	# Update flakes with given input
	nix flake update "$input" || exit
done

echo "$joined"
git commit --quiet --message "chore: update $joined" flake.lock

if ! git ls-remote origin --quiet >/dev/null; then
	echo "Can't reach the remote repo to push. Try pushing again later."
	exit 1
fi

git push origin main
echo "Done updating inputs! Exiting"

exit 0
