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
  hyprctl eval "
    $(for i in $(seq 1 10); do echo "hl.workspace_rule({ workspace = $i, monitor = \"eDP-1\" })"; done)
    $(for i in $(seq 1 10); do echo "hl.dispatch(hl.dsp.workspace.move({ workspace = $i, monitor = \"eDP-1\" }))"; done)
  "
fi
