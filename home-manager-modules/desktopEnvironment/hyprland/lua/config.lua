local M = {}

function M.setup()
  hl.config({
    general = {
      gaps_in    = 5,
      gaps_out   = 15,
      border_size = 0,
    },

    decoration = {
      rounding = 10,

      shadow = {
        enabled      = true,
        range        = 8,
        render_power = 3,
        -- TODO: replace with catppuccin lua vars once the module exposes them
        color          = 0xff81c8be, -- frappe teal
        color_inactive = 0xff292c3c, -- frappe mantle
      },

      blur = {
        enabled        = false,
        noise          = 0,
        size           = 2,
        passes         = 3,
        ignore_opacity = true,
      },
    },

    opengl = {
      nvidia_anti_flicker = false,
    },

    group = {
      groupbar = {
        col = {
          active          = 0xbb51576d,
          inactive        = 0xbb232634,
          locked_active   = 0xbbaa576d,
          locked_inactive = 0xbb992634,
        },
      },
    },

    misc = {
      enable_anr_dialog  = false,
      middle_click_paste = false,
    },

    input = {
      kb_layout  = "us,no",
      kb_options = "grp:alt_space_toggle",
      repeat_rate  = 50,
      repeat_delay = 160,
    },

    cursor = {
      no_hardware_cursors = true,
    },
  })

  hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

  hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "myBezier" })
  hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "default"  })
  hl.animation({ leaf = "border",     enabled = true, speed = 5, bezier = "default"  })
  hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "default"  })
  hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "default"  })
end

return M
