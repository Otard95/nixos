#!/usr/bin/env bash

includes() {
  local haystack="${1^^}"
  local needle="${2^^}"
  case $haystack in
    *$needle*)
      return 0
  esac
  return 1
}

if includes "$DESKTOP_SESSION $XDG_CURRENT_DESKTOP" "hyprland"; then
  hyprctl --batch " \
  keyword workspace 1,monitor:$1; \
  keyword workspace 2,monitor:$2; \
  keyword workspace 3,monitor:$3; \
  keyword workspace 4,monitor:$1; \
  keyword workspace 5,monitor:$2; \
  keyword workspace 6,monitor:$3; \
  keyword workspace 7,monitor:$1; \
  keyword workspace 8,monitor:$2; \
  keyword workspace 9,monitor:$3; \
  dispatch moveworkspacetomonitor 1 $1; \
  dispatch moveworkspacetomonitor 2 $2; \
  dispatch moveworkspacetomonitor 3 $3; \
  dispatch moveworkspacetomonitor 4 $1; \
  dispatch moveworkspacetomonitor 5 $2; \
  dispatch moveworkspacetomonitor 6 $3; \
  dispatch moveworkspacetomonitor 7 $1; \
  dispatch moveworkspacetomonitor 8 $2; \
  dispatch moveworkspacetomonitor 9 $3"
fi
