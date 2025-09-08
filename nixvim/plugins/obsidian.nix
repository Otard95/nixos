{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.obsidian;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.obsidian.enable =
    lib.mkEnableOption "obsidian";

  config = lib.mkIf enable {

    programs.nixvim = {

      plugins.obsidian = {

        enable = true;

        luaConfig.pre = ''
          local time = require('utils.time')
          local path = require('utils.path')

          ---@class Workspace
          ---@field name string
          ---@field path string
          ---@field real_path string

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
        '';

        settings = {
          legacy_commands = false;
          workspaces = [
            {
              name = "Work";
              path = "~/dev/smb/vaults/work";
            }
          ];
          follow_url_func = nixvim.mkRaw ''
            function (url)
              if path.is_relative(url) then
                url = path.resolve(path.dirname(vim.api.nvim_buf_get_name(0)), url)
              end
              print('Opening: '..url)
              vim.fn.jobstart({"xdg-open", url})
            end
          '';
          follow_img_func = nixvim.mkRaw ''
            function (url)
              if path.is_relative(url) then
                url = path.resolve(path.dirname(vim.api.nvim_buf_get_name(0)), url)
              end
              print('Opening: '..url)
              vim.fn.jobstart({"xdg-open", url})
            end
          '';
          templates = {
            subdir = "Templates";
            date_format = "%d %b %Y";
            time_format = "%H:%M";
            substitutions = {
              last_daily = nixvim.mkRaw ''
                function()
                  if time.is_day_of_week(1) then
                    return get_daily(time.get_offset_time({ day = -3 })).link
                  else
                    return get_daily(time.get_offset_time({ day = -1 })).link
                  end
                end
              '';
              next_daily = nixvim.mkRaw ''
                function()
                  if time.is_day_of_week(5) then
                    return get_daily(time.get_offset_time({ day = 3 })).link
                  else
                    return get_daily(time.get_offset_time({ day = 1 })).link
                  end
                end
              '';
            };
          };
          daily_notes = {
            folder = "Dailies";
            date_format = "%Y/%b/%d";
            template = "Daily_nvim.md";
          };
          checkbox = {
            enable = true;
            insert = true;
            order = [ " " "x" "-" ">" "~" ];
          };
          ui = {
            enable = false;
            checkboxes = {
              " " = { char = "▢"; hl_group = "obsidiantodo"; };
              "x" = { char = "󰱒"; hl_group = "obsidiandone"; };
              "-" = { char = "󰥔"; hl_group = "obsidiandone"; };
              ">" = { char = ""; hl_group = "obsidianrightarrow"; };
              "~" = { char = "󰅙"; hl_group = "obsidiantilde"; };
            };
          };
        };

      };

    };

  };

}
