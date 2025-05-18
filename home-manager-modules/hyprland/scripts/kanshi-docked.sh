#!/usr/bin/env bash

hyprctl --batch " \
keyword workspace 1,monitor:DP-5; \
keyword workspace 2,monitor:DP-4; \
keyword workspace 3,monitor:DP-3; \
keyword workspace 4,monitor:DP-5; \
keyword workspace 5,monitor:DP-4; \
keyword workspace 6,monitor:DP-3; \
keyword workspace 7,monitor:DP-5; \
keyword workspace 8,monitor:DP-4; \
keyword workspace 9,monitor:DP-3; \
dispatch moveworkspacetomonitor 1 DP-5; \
dispatch moveworkspacetomonitor 2 DP-4; \
dispatch moveworkspacetomonitor 3 DP-3; \
dispatch moveworkspacetomonitor 4 DP-5; \
dispatch moveworkspacetomonitor 5 DP-4; \
dispatch moveworkspacetomonitor 6 DP-3; \
dispatch moveworkspacetomonitor 7 DP-5; \
dispatch moveworkspacetomonitor 8 DP-4; \
dispatch moveworkspacetomonitor 9 DP-3"
