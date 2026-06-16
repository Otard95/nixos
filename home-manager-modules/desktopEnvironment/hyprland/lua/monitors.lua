local M = {}

local function get_monitor_names()
  local names = {}
  for _, m in ipairs(hl.get_monitors()) do
    names[m.name] = true
  end
  return names
end

local function assign_workspaces(map)
  for ws, mon in pairs(map) do
    hl.workspace_rule({ workspace = ws, monitor = mon })
    hl.dispatch(hl.dsp.workspace.move({ workspace = ws, monitor = mon }))
  end
end

local function apply()
  local monitors = get_monitor_names()

  if monitors["DP-9"] and monitors["DP-7"] then
    assign_workspaces({
      [1]="HDMI-A-1", [2]="DP-9",  [3]="DP-7",
      [4]="HDMI-A-1", [5]="DP-9",  [6]="DP-7",
      [7]="HDMI-A-1", [8]="DP-9",  [9]="DP-7",
    })
  elseif monitors["DP-11"] and monitors["DP-8"] then
    assign_workspaces({
      [1]="HDMI-A-1", [2]="DP-11", [3]="DP-8",
      [4]="HDMI-A-1", [5]="DP-11", [6]="DP-8",
      [7]="HDMI-A-1", [8]="DP-11", [9]="DP-8",
    })
  else
    -- undocked or external: everything on the built-in display
    local map = {}
    for i = 1, 10 do map[i] = "eDP-1" end
    assign_workspaces(map)
  end
end

function M.setup()
  hl.on("hyprland.start",        apply)
  hl.on("monitor.layout_changed", apply)
end

return M
