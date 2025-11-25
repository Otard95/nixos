local wezterm = require 'wezterm' --[[@as Wezterm]]
local actions = require 'actions'
local tbl = require 'utils.table'
local keys = require 'utils.keys'
local M = {}

---@param config Config
function M.apply_to_config(config)
  config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
  config.keys = {
    -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    keys.map { 'a', 'LEADER|CTRL', wezterm.action.SendString '\x01' },

    -- Wezterm pallet?? well see how this'll work
    keys.map { 'P', 'CTRL', wezterm.action.ActivateCommandPalette },

    -- Panes
    keys.map { '|', 'LEADER|SHIFT', wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    keys.map { '-', 'LEADER', wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
    keys.map { 'z', 'LEADER', wezterm.action.TogglePaneZoomState },

    -- Sessions
    keys.map { 'j', 'LEADER', actions.Sessionizer() },
    keys.map { 'x', 'LEADER', actions.SpawnProcessInWorkspace() },
    keys.map { 'r', 'LEADER', actions.RenameWorkspace() },
    keys.map { 'l', 'LEADER', actions.SwitchToLastWorkspace() },

    -- Navigate wezterm and nvim splits/panes
    keys.map { 'h', 'CTRL', actions.MovePane 'Left' },
    keys.map { 'j', 'CTRL', actions.MovePane 'Down' },
    keys.map { 'k', 'CTRL', actions.MovePane 'Up' },
    keys.map { 'l', 'CTRL', actions.MovePane 'Right' },
    keys.map { '<', 'CTRL|SHIFT', wezterm.action.MoveTabRelative(-1) },
    keys.map { '>', 'CTRL|SHIFT', wezterm.action.MoveTabRelative(1) },
    keys.map { 'h', 'CTRL|SHIFT', wezterm.action.AdjustPaneSize { 'Left', 5 } },
    keys.map { 'j', 'CTRL|SHIFT', wezterm.action.AdjustPaneSize { 'Down', 5 } },
    keys.map { 'k', 'CTRL|SHIFT', wezterm.action.AdjustPaneSize { 'Up', 5 } },
    keys.map { 'l', 'CTRL|SHIFT', wezterm.action.AdjustPaneSize { 'Right', 5 } },

    keys.map { 'd', 'LEADER', wezterm.action_callback(function(_win, pane)
      wezterm.log_info('pane:user_vars', pane:get_user_vars())
    end) },
    keys.map { 'D', 'LEADER', wezterm.action.ShowDebugOverlay },

    --------------
    --- Unbind ---
    --------------

    keys.map { 'N', 'CTRL', wezterm.action.DisableDefaultAssignment }
  }

  config.key_tables = {
    copy_mode = tbl.concat(wezterm.gui.default_key_tables().copy_mode, {
      keys.map { 'y', wezterm.action.Multiple {
        wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
        wezterm.action.ClearSelection,
        wezterm.action.CopyMode 'ClearSelectionMode'
      } },
      keys.map { 'n', 'CTRL', actions.SendSelectedText() },
      keys.map { 'Enter', wezterm.action.CopyMode 'Close' }
    })
  }
end

return M
