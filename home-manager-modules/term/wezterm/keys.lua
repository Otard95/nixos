local wezterm = require 'wezterm'
local actions = require 'actions'

local M = {}

function M.apply_to_config(config)
  config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
  config.keys = {
    -- Wezterm pallet?? well see how this'll work
    {
      key = 'P',
      mods = 'CTRL',
      action = wezterm.action.ActivateCommandPalette,
    },
    -- Create split panes
    {
      key = '|',
      mods = 'LEADER',
      action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      key = '-',
      mods = 'LEADER',
      action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    -- Toggle zen/zoom of pane
    {
      key = 'z',
      mods = 'LEADER',
      action = wezterm.action.TogglePaneZoomState,
    },
    -- t-smart-tmux-session-manager remake inspired by sessionizer.wezterm
    {
      key = 'j',
      mods = 'LEADER',
      action = actions.Sessionizer(),
    },
    -- Create a new workspace running requested command
    {
      key = 'x',
      mods = 'LEADER',
      action = actions.SpawnProcessInWorkspace(),
    },
    {
      key = 'r',
      mods = 'LEADER',
      action = actions.RenameWorkspace(),
    },
    -- Navigate wezterm and nvim splits/panes
    {
      key = 'h',
      mods = 'CTRL',
      action = actions.MovePane 'Left',
    },
    {
      key = 'j',
      mods = 'CTRL',
      action = actions.MovePane 'Down',
    },
    {
      key = 'k',
      mods = 'CTRL',
      action = actions.MovePane 'Up',
    },
    {
      key = 'l',
      mods = 'CTRL',
      action = actions.MovePane 'Right',
    }
  }
end

return M
