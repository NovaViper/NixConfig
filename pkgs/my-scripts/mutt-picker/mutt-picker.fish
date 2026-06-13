#!/usr/bin/env fish

set fzf_command fzf --popup
set config_dir "$HOME/.config/neomutt"

set selection (
    for file in $config_dir/*
        test -f $file; or continue

        set name (basename $file)

        # whitelist rule 1: ignore hidden files
        string match -q ".*" $name; and continue

        # whitelist rule 2: must contain set from
        set email (grep -m1 "^set from=" $file 2>/dev/null \
            | string replace -r "^set from=['\"]([^'\"]+)['\"].*" '$1')

        test -n "$email"; or continue

        # only valid accounts reach here
        printf "%s (%s)\t%s\n" $name $email $name
    end |
    $fzf_command --with-nth=1 --delimiter=\t --accept-nth=2
)

test -z "$selection"; and exit 0

set basefolder $selection

echo "push '<enter-command>source ~/.config/neomutt/$basefolder<enter><sync-mailbox><change-folder>!<enter><check-stats><first-entry>'"
