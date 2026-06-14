#!/usr/bin/env fish

function read_cpu --description "Get total and idle CPU times from /proc/stat"
    # Get the first line of /proc/stat and extract the numeric values
    set -l p (string match -ar '[0-9]+' (head -n 1 /proc/stat))

    # Assign values to variables for clarity
    set -l user $p[1]
    set -l nice $p[2]
    set -l system $p[3]
    set -l idle $p[4]
    set -l iowait $p[5]
    set -l irq $p[6]
    set -l softirq $p[7]
    set -l steal $p[8]

    # Calculate idle time and total time
    set -l idle_time (math "$idle + $iowait")
    set -l total (math "$user + $nice + $system + $idle + $iowait + $irq + $softirq + $steal")
    # Return total and idle time as a space-separated string
    string join \n $total $idle_time
end

function cpu_usage
    # Get initial CPU times
    set -l t1 (read_cpu)
    set -l total1 $t1[1]
    set -l idle1 $t1[2]

    sleep 1

    # Get the cpu times again after a short delay
    set -l t2 (read_cpu)
    set -l total2 $t2[1]
    set -l idle2 $t2[2]

    # Calculate the differences in total and idle times
    set -l total_delta (math "$total2 - $total1")
    set -l idle_delta (math "$idle2 - $idle1")

    # If we got 0 or negative, then something went wrong so return 0%
    if test $total_delta -le 0
        echo "0%"
        return
    end

    # Output the CPU usage percentage, rounded to the nearest whole number
    printf "%d%%\n" (math "round(100 * ($total_delta - $idle_delta) / $total_delta)")
end

function mem_usage
    # Prep variables
    set -l total
    set -l avail

    # Get total and available memory from /proc/meminfo, which is in kB (leave
    # behind the units.. don't need them)
    while read -l key value unit
        switch $key
            case "MemTotal:"
                set total $value
            case "MemAvailable:"
                set avail $value
                break
        end
    end </proc/meminfo

    # If we didn't get anything, then show 0
    if test -z "$total" -o -z "$avail"
        echo "0%"
        return
    end

    # Print the memory usage percentage, rounded down to the nearest whole
    # number
    printf "%d%%\n" (math "floor(100 * ($total - $avail) / $total)")
end

# Command switcher for convince..
switch $argv[1]
    case cpu
        cpu_usage
    case mem memory ram
        mem_usage
    case '*'
        echo "Usage: $argv[1] {cpu|mem}" >&2
        exit 1
end
