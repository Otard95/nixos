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

    -- Panes
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
    {
      key = 'z',
      mods = 'LEADER',
      action = wezterm.action.TogglePaneZoomState,
    },

    -- Sessions
    {
      key = 'j',
      mods = 'LEADER',
      action = actions.Sessionizer(),
    },
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
    {
      key = 'l',
      mods = 'LEADER',
      action = actions.SwitchToLastWorkspace(),
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
    },

    --------------
    --- Unbind ---
    --------------

    {
      key = 'N',
      mods = 'CTRL',
      action = wezterm.action.DisableDefaultAssignment,
    }
  }
end

return M
