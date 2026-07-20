local M = {}
local DebounceQueue = require('lua.utils.debounce-queue')

local function log(msg)
  hl.dispatch(hl.dsp.exec_cmd("logger -t monitors.lua '" .. msg .. "'"))
end

local function get_monitor_names()
  local names = {}
  for _, m in ipairs(hl.get_monitors()) do
    if m.name ~= "FALLBACK" then
      names[m.name] = true
    end
  end
  return names
end

local function sorted_names(monitors)
  local names = {}
  for n in pairs(monitors) do names[#names + 1] = n end
  table.sort(names)
  return table.concat(names, ",")
end

local function assign_workspaces(map)
  for ws, mon in pairs(map) do
    hl.workspace_rule({ workspace = tostring(ws), monitor = mon })
    hl.dispatch(hl.dsp.workspace.move({ workspace = ws, monitor = mon }))
  end
end

local function is_docked(monitors)
  if monitors["HDMI-A-1"] and monitors["DP-9"] and monitors["DP-7"] then return "docked-1" end
  if monitors["HDMI-A-1"] and monitors["DP-11"] and monitors["DP-8"] then return "docked-2" end
  return nil
end

local last_profile = nil

local function apply()
  local monitors = get_monitor_names()
  local dock = is_docked(monitors)

  -- Re-enable eDP-1 if we're undocked but it's not visible
  local edp_missing = not dock and not monitors["eDP-1"]
  if dock == last_profile and not edp_missing then return end

  log("apply() " .. tostring(last_profile) .. " -> " .. tostring(dock) ..
    " monitors=" .. sorted_names(monitors))

  if dock then
    hl.monitor({ output = "eDP-1", disabled = true })
    last_profile = dock

    if dock == "docked-1" then
      assign_workspaces({
        [1] = "HDMI-A-1", [2] = "DP-9",  [3] = "DP-7",
        [4] = "HDMI-A-1", [5] = "DP-9",  [6] = "DP-7",
        [7] = "HDMI-A-1", [8] = "DP-9",  [9] = "DP-7",
      })
    else
      assign_workspaces({
        [1] = "HDMI-A-1", [2] = "DP-11", [3] = "DP-8",
        [4] = "HDMI-A-1", [5] = "DP-11", [6] = "DP-8",
        [7] = "HDMI-A-1", [8] = "DP-11", [9] = "DP-8",
      })
    end
  else
    hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, disabled = false })
    last_profile = nil

    local map = {}
    for i = 1, 10 do map[i] = "eDP-1" end
    assign_workspaces(map)
  end
end

function M.setup()
  hl.monitor({ output = "",         mode = "preferred", position = "auto", scale = 1 })
  hl.monitor({ output = "DP-7",     mode = "2560x1440@59.95", position = "4000x0", transform = 3 })
  hl.monitor({ output = "DP-9",     mode = "2560x1440@59.95", position = "2560x0", transform = 1 })
  hl.monitor({ output = "DP-8",     mode = "2560x1440@59.95", position = "4000x0", transform = 3 })
  hl.monitor({ output = "DP-11",    mode = "2560x1440@59.95", position = "2560x0", transform = 1 })
  hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@59.95", position = "0x485" })

  local queue = DebounceQueue:create(1500, apply)
  local function on(event)
    hl.on(event, function()
      log("event: " .. event)
      queue:push()
    end)
  end
  on("hyprland.start")
  on("config.reloaded")
  on("monitor.added")
  on("monitor.removed")
end

return M
