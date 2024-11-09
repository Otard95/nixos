local time = require('utils.time')
local path = require('utils.path')

---@class Workspace
---@field name string
---@field path string
---@field real_path string

---@type Workspace[]
local workspaces = {
  {
    name = 'Work',
    path = '~/dev/smb/vaults/Work',
    real_path = vim.fn.expand('~/dev/smb/vaults/Work'),
  },
}

---@param t integer
local function get_daily(t)
  local path = 'Dailies/' .. os.date('%Y/%b/%d', t)
  local name = os.date('%d %b %Y', t)
  return {
    path = path,
    name = name,
    link = '[[' .. path .. '|' .. name .. ']]',
  }
end

---@param url string
local function follow_url(url)
  if path.is_relative(url) then
    url = path.resolve(path.pathname(vim.api.nvim_buf_get_name(0)), url)
  end
  vim.fn.jobstart({"open", url})
end

return {
  {
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    ---@param ws Workspace
    event = vim.tbl_flatten(vim.tbl_map(function(ws)
      return {
        'BufReadPre ' .. ws.real_path .. '/**.md',
        'BufNewFile ' .. ws.real_path .. '/**.md'
      }
    end, workspaces)),
    cmd = {
      'ObsidianNew',
      'ObsidianOpen',
      'ObsidianSearch',
      'ObsidianToday',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      follow_url_func = follow_url,
      workspaces = workspaces,
      -- Date formats see :Man strftime()
      templates = {
        subdir = 'Templates',
        date_format = '%d %b %Y',
        time_format = '%H:%M',
        substitutions = {
          last_daily = function()
            if time.is_day_of_week(1) then
              return get_daily(time.get_offset_time({ day = -3 })).link
            else
              return get_daily(time.get_offset_time({ day = -1 })).link
            end
          end,
          next_daily = function()
            if time.is_day_of_week(5) then
              return get_daily(time.get_offset_time({ day = 3 })).link
            else
              return get_daily(time.get_offset_time({ day = 1 })).link
            end
          end,
        },
      },
      daily_notes = {
        folder = 'Dailies',
        date_format = '%Y/%b/%d',
        template = 'Daily_nvim.md',
      },
      ui = {
        enable = false,
        checkboxes = {
          [" "] = { char = "▢", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "◩", hl_group = "ObsidianTilde" },
        },
      },
    },
  }
}
