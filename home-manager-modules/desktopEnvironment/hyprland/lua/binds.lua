local M = {}

---@param args { terminal: string, wl_paste: string }
function M.setup(args)
  local mod = "SUPER"

  -- Window management
  hl.bind(mod .. " + SHIFT + Q",        hl.dsp.window.close())
  hl.bind(mod .. " + SHIFT + CTRL + M", hl.dsp.exec_cmd("uwsm stop"))
  hl.bind(mod .. " + SHIFT + SPACE",    hl.dsp.window.float())
  hl.bind(mod .. " + SPACE",            hl.dsp.window.cycle_next({ floating = true }))
  hl.bind(mod .. " + BACKSPACE",        hl.dsp.window.cycle_next({ tiled = true }))
  hl.bind(mod .. " + SHIFT + F",        hl.dsp.window.fullscreen())
  hl.bind(mod .. " + E",                hl.dsp.layout("togglesplit"))

  -- Terminal
  hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("uwsm app -- " .. args.terminal))

  -- Groups
  hl.bind(mod .. " + W",               hl.dsp.group.toggle())
  hl.bind(mod .. " + ALT + E",         hl.dsp.group.next())
  hl.bind(mod .. " + ALT + W",         hl.dsp.group.next())
  hl.bind(mod .. " + ALT + L",         hl.dsp.group.next())
  hl.bind(mod .. " + ALT + H",         hl.dsp.group.prev())
  hl.bind(mod .. " + ALT + SHIFT + L", hl.dsp.group.move_window())
  hl.bind(mod .. " + ALT + SHIFT + H", hl.dsp.group.move_window({ forward = false }))

  -- Focus
  hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))
  hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
  hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
  hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }))

  -- Move windows (group-aware)
  hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r", group_aware = true }))
  hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l", group_aware = true }))
  hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u", group_aware = true }))
  hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d", group_aware = true }))

  -- Workspaces
  for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
  end

  -- Unix timestamp converter (wl-paste)
  local wl_paste = args.wl_paste
  hl.bind(mod .. " + CTRL + D", hl.dsp.exec_cmd(
    wl_paste .. " --primary | xargs -I {} date -d @{} | xargs -I {} notify-send '{}'" ..
    "; " .. wl_paste .. " | xargs -I {} date -d @{} | xargs -I {} notify-send '{}'"
  ))

  -- Mouse
  hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
  hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

  -- Volume
  hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
  hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),  { locked = true, repeating = true })
  hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

  -- Media
  hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
  hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
  hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),        { locked = true })

  hl.bind(mod .. " + N", hl.dsp.submap("notifications"))
  hl.define_submap("notifications", function()
    hl.bind(mod .. " + C", hl.dsp.exec_cmd("uwsm app -- makoctl dismiss"))
    hl.bind(mod .. " + A", hl.dsp.exec_cmd("uwsm app -- makoctl invoke && makoctl dismiss"))
    hl.bind(mod .. " + H", hl.dsp.exec_cmd("uwsm app -- makoctl restore"))
    hl.bind("catchall",    hl.dsp.submap("reset"))
  end)

  -- Startup (exec-once equivalents without Nix interpolation)
  hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.dispatch(hl.dsp.exec_cmd("uwsm app -- zen",                              { workspace = "1 silent" }))
    hl.dispatch(hl.dsp.exec_cmd("uwsm app -- " .. args.terminal, { workspace = "2 silent" }))
  end)

  -- Reload (exec equivalent — runs on every config load)
  hl.exec_cmd("pkill waybar; sleep 0.5 && uwsm app -- waybar")
end

return M
