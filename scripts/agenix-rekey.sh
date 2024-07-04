#!/usr/bin/env sh

# If Agenix isn't installed then immedately fail
if [ ! -x "$(command -v agenix)" ]; then
	echo "You need to have either sops or agenix installed!"
	exit 1
fi

username=$1
file=$2
identity=$3
useHost=$4

# Make sure that the secrets folder exists before we do anything; if it's there, then enter into the folder for the specific user we chose
if [ -d "${PWD}/secrets" ]; then
	echo "Secrets directory detected! Entering ${PWD}/secrets/${username}"
	cd "${PWD}"/secrets/"$username" || exit 5
else
	echo "Secrets directory does not exist! Please follow the agenix guide to properly create the secrets folder and the required secrets.nix file."
	exit 7
fi

# Create a temp folder to move all other secrets into and copy
# all but the specified secret file (make sure to ignore the
# eval-secrets.json as that doesn't get touched by agenix)
echo "Moving secrets into ${PWD}/temp folder"
[ -d temp ] || mkdir temp
find . -maxdepth 1 -mindepth 1 ! -name "$file.age" \
	! -name eval-secrets.json ! \
	-name temp -print0 |
	xargs -0 mv -t temp/

# Of course make sure our secrets file exists
if [ ! -f "${file}.age" ]; then
	echo "The requested file, ${file}.age does not exist! Please make sure you create the file and place it in ${PWD}"
	exit 4
fi
echo "${file}.age found! Onto rekeying..."

# Go back to main secrets directory and finally run the rekey command
cd .. || exit 5

if [ "$useHost" -eq 1 ]; then
	sudo agenix -r -i "$identity"
else
	agenix -r -i "$identity"
fi

# Make sure to go back into the specified user folder and move all
# other secrets back into it and delete the temp folder
cd "$username" || exit 5
echo "Moving secrets back into ${PWD} and deleting temp"
mv temp/* .
rm -d temp/
echo "Done!"
