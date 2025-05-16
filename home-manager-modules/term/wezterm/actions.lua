local wezterm = require 'wezterm' --[[@as Wezterm]]
local path = require 'utils.path'
local str = require 'utils.string'
local tbl = require 'utils.table'
local vim = require 'utils.vim'

local M = {
  ---@type string
  previous_workspace = 'default'
}

local direction_keys = {
  Left = "h",
  Down = "j",
  Up = "k",
  Right = "l",
}

function M.MovePane(direction)
  return wezterm.action_callback(function(win, pane)
    if vim.is_vim(pane) then
      win:perform_action(
        { SendKey = { key = direction_keys[direction], mods = "CTRL" }, },
        pane
      )
    else
      win:perform_action({ ActivatePaneDirection = direction }, pane)
    end
  end)
end

---Retrieve the directories zoxide
---@return { id: string, label: string }[]
local function get_directories_choices()
  local _, out, _ = wezterm.run_child_process { 'zoxide', 'query', '-l' }

  return tbl.map(wezterm.split_by_newlines(out), function(dir)
    local updated_path = string.gsub(dir, wezterm.home_dir, "~")
    return { id = dir, label = updated_path }
  end)
end

---Retrieve existing wezterm workspaces
---@return { label: string }[]
local function get_workspace_choices()
  return tbl.map(
    wezterm.mux.get_workspace_names(),
    function(name) return { label = name } end
  )
end

-- t-smart-tmux-session-manager remake inspired by sessionizer.wezterm
function M.Sessionizer()
  return wezterm.action_callback(function(win, pane)
    win:perform_action(
      wezterm.action.InputSelector({
        action = wezterm.action_callback(
          function(inner_win, inner_pane, id, label)
            if not id and not label then
              -- User canceled
              return
            end

            M.previous_workspace = inner_win:active_workspace()

            if id == nil then
              -- User selected a workspace
              wezterm.log_info('[Sessionizer] workspace chosen', label)
              inner_win:perform_action(
                wezterm.action.SwitchToWorkspace { name = label },
                inner_pane
              )
            else
              -- User selected a directory
              local newName = path.basename(id)
              wezterm.log_info('[Sessionizer] directory chosen', id, newName)

              inner_win:perform_action(
                wezterm.action.SwitchToWorkspace {
                  name = newName,
                  spawn = { cwd = id },
                },
                inner_pane
              )
            end
          end
        ),
        title = "Wezterm Sessionizer",
        choices = tbl.concat(get_workspace_choices(), get_directories_choices()),
        fuzzy = true
      }),
      pane
    )
  end)
end

function M.SpawnProcessInWorkspace()
  return wezterm.action.PromptInputLine {
    description = 'Spawn a process in a new workspace',
    action = wezterm.action_callback(function(win, pane, command)
      if command then
        win:perform_action(
          wezterm.action.PromptInputLine {
            description = 'Name the workspace',
            initial_value = command,
            action = wezterm.action_callback(function(inner_win, inner_pane, name)
              M.previous_workspace = inner_win:active_workspace()
              inner_win:perform_action(
                wezterm.action.SwitchToWorkspace {
                  name = name,
                  spawn = { args = str.split(command, ' '), cwd = wezterm.home_dir },
                },
                inner_pane
              )
            end),
          },
          pane
        )
      end
    end)
  }
end

function M.SwitchToLastWorkspace()
  return wezterm.action_callback(function(win, pane)
    local target_workspace = M.previous_workspace
    M.previous_workspace = win:active_workspace()
    win:perform_action(
      wezterm.action.SwitchToWorkspace { name = target_workspace, },
      pane
    )
  end)
end

function M.RenameWorkspace()
  return wezterm.action_callback(function(win, pane)
    win:perform_action(
      wezterm.action.PromptInputLine {
        description = 'Rename workspace',
        initial_value = win:active_workspace(),
        action = wezterm.action_callback(function(inner_win, _, line)
          local current_workspace = inner_win:active_workspace()
          if line then
            if current_workspace then
              local ok, out, err = wezterm.run_child_process {
                'wezterm',
                'cli',
                'rename-workspace',
                '--workspace',
                current_workspace,
                line
              }
              if not ok then
                wezterm.log_info('[RenameWorkspace] child process result', { out = out, err = err })
                inner_win:toast_notification('Rename workspace', 'Failed to rename workspace', nil, 4000)
              end
            end
          end
        end)
      },
      pane
    )
  end)
end

function M.SendSelectedText()
  return wezterm.action_callback(
    function(win, pane)
      pane:send_text(win:get_selection_text_for_pane(pane) .. ' ')
      win:perform_action(wezterm.action.ClearSelection, pane)
      win:perform_action(wezterm.action.CopyMode 'ClearSelectionMode', pane)
    end
  )
end

return M
