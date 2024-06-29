#!/usr/bin/env sh
set -euo pipefail

if [ -x "$(command -v agenix)" ]; then
	secretAgent="agenix"
	secretPkg="agenix"
elif [ -x "$(command -v sops)" ]; then
	secretAgent="sops"
	secretPkg="sops"
else
	echo "You need to have either sops or agenix installed!"
	exit 1
fi

# FIXME: Make this better
secrets_result=$(journalctl --no-pager --no-hostname --since "10 minutes ago" |
	tac |
	awk '!flag; /Starting '+${secretAgent}+' activation/{flag = 1};' |
	tac |
	grep $secretPkg)

# If we don't have "Finished agenix/sops-nix activation." in the logs, then we failed
if [ ! "$secrets_result" = "Finished "+${secretAgent}+" activation" ]; then
	echo "Secrets have failed to activate"
	echo "$secrets_result"
	exit 15
else
	echo "Secrets have successfully been activated and mounted!"
	exit 0
fi
