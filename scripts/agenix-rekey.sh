#!/usr/bin/env sh
username=$1
file=$2
identity=$3
useHost=$4

# Enter into the folder for the specific user we chose
cd "${PWD}"/secrets/"$username" || exit 5

# Create a temp folder to move all other secrets into and copy
# all but the specified secret file (make sure to ignore the
# eval-secrets.json as that doesn't get touched by agenix)
[ -d temp ] || mkdir temp
find . -maxdepth 1 -mindepth 1 ! -name "$file" \
	! -name eval-secrets.json ! \
	-name temp -print0 |
	xargs -0 mv -t temp/

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
mv temp/* .
rm -d temp/
