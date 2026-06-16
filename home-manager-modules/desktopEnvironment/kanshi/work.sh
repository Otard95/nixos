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
    hl.workspace_rule({ workspace = 1, monitor = \"$1\" })
    hl.workspace_rule({ workspace = 2, monitor = \"$2\" })
    hl.workspace_rule({ workspace = 3, monitor = \"$3\" })
    hl.workspace_rule({ workspace = 4, monitor = \"$1\" })
    hl.workspace_rule({ workspace = 5, monitor = \"$2\" })
    hl.workspace_rule({ workspace = 6, monitor = \"$3\" })
    hl.workspace_rule({ workspace = 7, monitor = \"$1\" })
    hl.workspace_rule({ workspace = 8, monitor = \"$2\" })
    hl.workspace_rule({ workspace = 9, monitor = \"$3\" })
    hl.dispatch(hl.dsp.workspace.move({ workspace = 1, monitor = \"$1\" }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = 2, monitor = \"$2\" }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = 3, monitor = \"$3\" }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = 4, monitor = \"$1\" }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = 5, monitor = \"$2\" }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = 6, monitor = \"$3\" }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = 7, monitor = \"$1\" }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = 8, monitor = \"$2\" }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = 9, monitor = \"$3\" }))
  "
fi
