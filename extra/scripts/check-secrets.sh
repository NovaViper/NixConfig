#!/usr/bin/env sh

if [ -x "$(command -v agenix)" ]; then
	secretAgent="agenix"
	secretPkg="agenix"
elif [ -x "$(command -v sops)" ]; then
	secretAgent="sops-nix"
	secretPkg="sops"
else
	echo "You need to have either sops or agenix installed!"
	exit 1
fi

# HACK: Best I could find sadly, but there's gotta be a better way right?
secrets_result=$(journalctl --no-pager --no-hostname --since "10 minutes ago" |
	tac |
	awk '!flag; /Starting ${secretAgent} activation/{flag = 1};' |
	tac |
	grep $secretPkg)

# If we don't have "Finished agenix/sops-nix activation." in the logs, then we failed
echo "$secrets_result" | grep "Finished ${secretAgent} activation" >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "ERROR: Secrets failed to activate"
	echo "ERROR: $secrets_result"
	exit 15
fi

echo "Secrets have successfully been activated and mounted!"
exit 0
