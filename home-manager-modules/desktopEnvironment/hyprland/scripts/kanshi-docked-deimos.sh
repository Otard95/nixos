#!/usr/bin/env bash

hyprctl --batch " \
keyword workspace 1,monitor:HDMI-A-1; \
keyword workspace 2,monitor:DP-9; \
keyword workspace 3,monitor:DP-7; \
keyword workspace 4,monitor:HDMI-A-1; \
keyword workspace 5,monitor:DP-9; \
keyword workspace 6,monitor:DP-7; \
keyword workspace 7,monitor:HDMI-A-1; \
keyword workspace 8,monitor:DP-9; \
keyword workspace 9,monitor:DP-7; \
dispatch moveworkspacetomonitor 1 HDMI-A-1; \
dispatch moveworkspacetomonitor 2 DP-9; \
dispatch moveworkspacetomonitor 3 DP-7; \
dispatch moveworkspacetomonitor 4 HDMI-A-1; \
dispatch moveworkspacetomonitor 5 DP-9; \
dispatch moveworkspacetomonitor 6 DP-7; \
dispatch moveworkspacetomonitor 7 HDMI-A-1; \
dispatch moveworkspacetomonitor 8 DP-9; \
dispatch moveworkspacetomonitor 9 DP-7"
