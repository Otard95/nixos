local wezterm = require 'wezterm'
local tbl = require 'utils.table'
local text = require 'utils.text'

local M = {
  LEFT_BORDER = wezterm.nerdfonts.ple_left_half_circle_thick,
  RIGHT_BORDER = wezterm.nerdfonts.ple_right_half_circle_thick,
  accent = '#81c8be',
  base = '#303446',
  surface0 = '#414559',
  surface1 = '#51576d',
  text = '#c6d0f5',
  crust = '#232634',
}

function M.apply_to_config(config)
  -- Override theme: https://wezterm.org/config/appearance.html#precedence-of-colors-vs-color_schemes
  local catppuccin_frappe = wezterm.color.get_builtin_schemes()['Catppuccin Frappe']
  -- Retro Tab Bar appearance: https://wezterm.org/config/appearance.html#retro-tab-bar-appearance
  catppuccin_frappe.tab_bar.active_tab.bg_color = M.accent
  config.color_schemes = {
    ['Catppuccin Frappe'] = catppuccin_frappe
  }
  config.color_scheme = 'Catppuccin Frappe'
  config.window_background_opacity = 0.95

  -- Tab bar styling: https://wezterm.org/config/appearance.html#tab-bar-appearance-colors
  -- config.hide_tab_bar_if_only_one_tab = true
  config.use_fancy_tab_bar = false
  config.tab_max_width = 10000 -- max handled by 'format-tab-title' event
  M.attach_tab_title_event_handler()

  -- Fonts: https://wezterm.org/config/fonts.html
  config.font = wezterm.font {
    family = 'Meslo LG M DZ',
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  }
  config.font_size = 10
end

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function M.tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane in that tab
  return tab_info.active_pane.title
end

function M.attach_tab_title_event_handler()
  -- Formatting tab title: https://wezterm.org/config/lua/window-events/format-tab-title.html#format-tab-title wezterm.on(
  wezterm.on(
    'format-tab-title',
    function(tab, tabs, panes, config, hover)
      local tab_bg = (tab.is_active and M.accent) or (hover and M.surface1) or M.surface0
      local tab_fg = tab.is_active and M.crust or M.text
      local title_bg = hover and M.surface0 or M.base

      local title = wezterm.truncate_right(M.tab_title(tab), 14)

      local prefix = {}
      if tab.tab_index == 0 then
        local workspace_name = wezterm.mux.get_window(tab.window_id):get_workspace()
        prefix = tbl.concat(
          text.text_format(' ' .. M.LEFT_BORDER, { bg = M.crust, fg = M.accent }),
          text.text_format(workspace_name, { bg = M.accent, fg = M.crust }),
          text.text_format(M.RIGHT_BORDER .. ' ', { bg = M.crust, fg = M.accent })
        )
      end

      return tbl.concat(
        prefix,
        text.text_format(' ' .. M.LEFT_BORDER, { bg = M.crust, fg = tab_bg }),
        text.text_format((tab.tab_index + 1) .. ' ', { bg = tab_bg, fg = tab_fg }),
        text.text_format(' ' .. title, { bg = title_bg, fg = M.text }),
        text.text_format(M.RIGHT_BORDER .. ' ', { bg = M.crust, fg = title_bg })
      )
    end
  )
end

return M
