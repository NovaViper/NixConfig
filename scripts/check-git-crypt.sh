#!/usr/bin/env sh
# Based on https://gist.github.com/svarrette-anssi/fcc1014d4cf6bfaa4ec722598fc69c9f

if [ -d "${PWD}.git/git-crypt" ]; then
	STAGED_FILES=$(git diff --cached --name-status | awk '$1 != "D" { print $2 }' | xargs echo)
	if [ -n "${STAGED_FILES}" ]; then
		if ! git-crypt status "${STAGED_FILES}" >/dev/null 2>&1; then
			git-crypt status -e "${STAGED_FILES}"
			echo '/!\ You should have first unlocked your repository BEFORE staging the above file(s)'
			echo '/!\ Proceed now as follows:'
			printf "\t git reset HEAD -- %s" "${STAGED_FILES}"
			printf "\t git crypt unlock"
			printf "\t git add %s" "${STAGED_FILES}"
			exit 1
		fi
	fi
fi
