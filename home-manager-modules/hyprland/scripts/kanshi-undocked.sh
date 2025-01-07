#!/usr/bin/env bash

hyprctl --batch " \
keyword workspace 1,monitor:eDP-1; \
keyword workspace 2,monitor:eDP-1; \
keyword workspace 3,monitor:eDP-1; \
keyword workspace 4,monitor:eDP-1; \
keyword workspace 5,monitor:eDP-1; \
keyword workspace 6,monitor:eDP-1; \
keyword workspace 7,monitor:eDP-1; \
keyword workspace 8,monitor:eDP-1; \
keyword workspace 9,monitor:eDP-1; \
keyword workspace 10,monitor:eDP-1; \
dispatch moveworkspacetomonitor 1 eDP-1; \
dispatch moveworkspacetomonitor 2 eDP-1; \
dispatch moveworkspacetomonitor 3 eDP-1; \
dispatch moveworkspacetomonitor 4 eDP-1; \
dispatch moveworkspacetomonitor 5 eDP-1; \
dispatch moveworkspacetomonitor 6 eDP-1; \
dispatch moveworkspacetomonitor 7 eDP-1; \
dispatch moveworkspacetomonitor 8 eDP-1; \
dispatch moveworkspacetomonitor 9 eDP-1; \
dispatch moveworkspacetomonitor 10 eDP-1"
