local M = {}

function M.setup()
  -- ED Expedition
  hl.window_rule({ match = { initial_title = "ed-expedition" }, float = true })

  -- Rofi
  hl.window_rule({ match = { class = "Rofi" }, float = true })
  hl.window_rule({ match = { class = "Rofi" }, stay_focused = true })

  -- Zen Browser
  hl.window_rule({ match = { class = "zen", title = "Extension" },          float = true })
  hl.window_rule({ match = { initial_title = "^Picture-in-Picture$" },      float = true })
  hl.window_rule({ match = { initial_title = "^Picture-in-Picture$" },      size = { 944, 530 } })

  -- File dialogs
  hl.window_rule({ match = { initial_title = "^File Operation Progress$" }, float = true })
  hl.window_rule({ match = { initial_title = "^File Operation Progress$" }, size = { 500, 200 } })

  -- Wine
  hl.window_rule({ match = { initial_title = "Wine System Tray" },          move = { "50%", 20 } })
  hl.window_rule({ match = { initial_title = "Wine System Tray" },          pin = true })

  -- Gnome Clocks
  hl.window_rule({ match = { class = "org.gnome.clocks" }, float = true })

  -- Flameshot
  hl.window_rule({ match = { initial_title = "Upload image" },      float = true })
  hl.window_rule({ match = { initial_title = "Configuration" },     float = true })
  hl.window_rule({ match = { initial_title = "Capture Launcher" },  float = true })
  hl.window_rule({ match = { initial_title = "Save screenshot" },   float = true })
end

return M
