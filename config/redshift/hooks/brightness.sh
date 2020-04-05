#!/bin/sh

# Set brightness via brightnessclt when redshift status changes

# Set brightness values for each status.
# Range from 1 to 100 is valid
brightness_day="100%"
brightness_transition="50%"
brightness_night="20%"
# Animating the change is currently not possible natively.
# See https://github.com/Hummer12007/brightnessctl/issues/26
#
# Set fade time for changes to one minute
# fade_time=60000

case $1 in
	period-changed)
    # prev_period=$2
    new_period=$3
		case $new_period in
			night)
        brightnessctl set "$brightness_night"
				;;
			transition)
        brightnessctl set "$brightness_transition"
				;;
			daytime)
        brightnessctl set "$brightness_day"
				;;
		esac
		;;
esac
