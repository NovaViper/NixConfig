#!/usr/bin/env fish

# Prep variables
set -l devices (nmcli -t -f DEVICE,TYPE,STATE device)
set -l eth ""
set -l wifi ""

# For every device we find from network-manager cli
for line in $devices
    set -l fields (string split ":" $line)

    set -l dev $fields[1]
    set -l type $fields[2]
    set -l state $fields[3]

    if test "$state" = connected
        # Set ethernet if we got an ethernet connection
        if test "$type" = ethernet
            set eth $dev
            # set wifi if we got a wifi connection
        else if test "$type" = wifi
            set wifi $dev
        end
    end
end

if test -n "$eth"; or test -n "$wifi"
    echo "󰖩 ON"
else
    echo "󰖪 OFF"
end
