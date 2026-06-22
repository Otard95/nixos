local M = {}
local DebounceQueue = require('lua.utils.debounce-queue')

-- Tracks monitors we have explicitly set as mirrors, since hl.get_monitors()
-- does not return mirrored monitors. This lets us still detect them when
-- checking docked conditions after a partial-dock apply().
local mirrored = {}

local function get_monitor_names()
  local names = {}
  for _, m in ipairs(hl.get_monitors()) do
    names[m.name] = true
  end
  for name in pairs(mirrored) do
    names[name] = true
  end
  return names
end

local function assign_workspaces(map)
  for ws, mon in pairs(map) do
    hl.workspace_rule({ workspace = tostring(ws), monitor = mon })
    hl.dispatch(hl.dsp.workspace.move({ workspace = ws, monitor = mon }))
  end
end

local function apply()
  local monitors = get_monitor_names()
  local names = {}
  for n in pairs(monitors) do names[#names + 1] = n end
  table.sort(names)
  local branch = "else"
  if monitors["HDMI-A-1"] and monitors["DP-9"] and monitors["DP-7"] then
    branch = "docked-1"
  elseif monitors["HDMI-A-1"] and monitors["DP-11"] and monitors["DP-8"] then
    branch = "docked-2"
  end
  hl.dispatch(hl.dsp.exec_cmd("logger -t monitors.lua 'apply() branch=" ..
    branch .. " monitors=" .. table.concat(names, ",") .. "'"))

  if monitors["HDMI-A-1"] and monitors["DP-9"] and monitors["DP-7"] then
    mirrored = {}
    hl.monitor({ output = "DP-7", mode = "2560x1440@59.95", position = "4000x0", transform = 3 })
    hl.monitor({ output = "DP-9", mode = "2560x1440@59.95", position = "2560x0", transform = 1 })
    hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@59.95", position = "0x485" })
    hl.monitor({ output = "eDP-1", disabled = true })
    assign_workspaces({
      [1] = "HDMI-A-1",
      [2] = "DP-9",
      [3] = "DP-7",
      [4] = "HDMI-A-1",
      [5] = "DP-9",
      [6] = "DP-7",
      [7] = "HDMI-A-1",
      [8] = "DP-9",
      [9] = "DP-7",
    })
  elseif monitors["HDMI-A-1"] and monitors["DP-11"] and monitors["DP-8"] then
    mirrored = {}
    hl.monitor({ output = "DP-8", mode = "2560x1440@59.95", position = "4000x0", transform = 3 })
    hl.monitor({ output = "DP-11", mode = "2560x1440@59.95", position = "2560x0", transform = 1 })
    hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@59.95", position = "0x485" })
    hl.monitor({ output = "eDP-1", disabled = true })
    assign_workspaces({
      [1] = "HDMI-A-1",
      [2] = "DP-11",
      [3] = "DP-8",
      [4] = "HDMI-A-1",
      [5] = "DP-11",
      [6] = "DP-8",
      [7] = "HDMI-A-1",
      [8] = "DP-11",
      [9] = "DP-8",
    })
  else
    hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, disabled = false })
    for name in pairs(monitors) do
      if name ~= "eDP-1" then
        hl.monitor({ output = name, mirror = "eDP-1" })
        mirrored[name] = true
      end
    end
    local map = {}
    for i = 1, 10 do map[i] = "eDP-1" end
    assign_workspaces(map)
  end
end

function M.setup()
  local queue = DebounceQueue:create(1500, apply)
  local function on(event)
    hl.on(event, function()
      hl.dispatch(hl.dsp.exec_cmd("logger -t monitors.lua 'event: " .. event .. "'"))
      queue:push()
    end)
  end
  on("hyprland.start")
  on("config.reloaded")
  on("monitor.added")
  on("monitor.removed")
  -- Not listening to monitor.layout_changed: our own hl.monitor() calls
  -- emit it, which would create an infinite loop.
end

return M
