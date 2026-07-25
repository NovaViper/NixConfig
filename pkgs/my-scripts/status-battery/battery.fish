#!/usr/bin/env fish

# Prep variables, local to keep shell clean!
set -l low_threshold 15
set -l normal_bg "\$rosewater"
set -l left_bg yellow
set -l right_bg "\$mauve"
set -l bat ""

# Get the system's battery
for dev in /sys/class/power_supply/*

    # Must be on real battery
    test "$(cat "$dev/type" 2>/dev/null)" = Battery; or continue

    # Ignore peripherals
    test "$(cat "$dev/scope" 2>/dev/null)" != Device; or continue

    # And it must be marked present (not unplugged)
    if test -f "$dev/present"
        test "$(cat "$dev/present" 2>/dev/null)" = 1; or continue
    end

    # If we got here, then we got ourselves a battery
    set bat $dev
    break
end

# Fallback for desktops if we got nothing at all
if test -z "$bat"
    printf "#[fg=green,bg=%s]#[fg=\$crust,bg=green] ♥ AC #[fg=%s,bg=green]#[default]" \
        $left_bg $right_bg
    exit 0
end

# Read the battery state safely
set -l capacity (string trim -- (cat "$bat/capacity" 2>/dev/null))
set -l bat_status (string trim -- (cat "$bat/status" 2>/dev/null))

# Error state
if test -z "$capacity"; or test -z "$bat_status"
    printf "#[fg=red,bg=%s]#[fg=\$crust,bg=red] ? N/A #[fg=%s,bg=red]#[default]" \
        "$left_bg" "$right_bg"
    exit 0
end

set -l bg ""
set -l icon ""

# Icons and segment colors are based on the battery/charging state
if test "$bat_status" = Charging
    set bg green
    set icon 󰂄
else
    # Battery icon switching logic; based on capacity level
    if test $capacity -ge 90
        set icon 󰁹
    else if test $capacity -ge 80
        set icon 󰂂
    else if test $capacity -ge 70
        set icon 󰂁
    else if test $capacity -ge 60
        set icon 󰂀
    else if test $capacity -ge 50
        set icon 󰁿
    else if test $capacity -ge 40
        set icon 󰁾
    else if test $capacity -ge 30
        set icon 󰁽
    else if test $capacity -ge 20
        set icon 󰁼
    else if test $capacity -ge 10
        set icon 󰁻
    else
        set icon 󰁺
    end

    # Low battery warning
    if test $capacity -lt $low_threshold
        set bg red
    else
        set bg $normal_bg
    end
end

printf "#[fg=%s,bg=%s]#[fg=\$crust,bg=%s] %s %s%% #[fg=%s,bg=%s]#[default]" \
    $bg $left_bg \
    $bg \
    $icon $capacity \
    $right_bg $bg
