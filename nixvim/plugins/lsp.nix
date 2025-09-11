{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.lsp;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.lsp.enable =
    lib.mkEnableOption "lsp plugins";

  config = lib.mkIf enable {

    programs.nixvim = {

      plugins = {
        lsp-format = {
          enable = true;

          settings = {
            typescript = {
              exclude = [
                "ts_ls"
              ];
            };
          };
        };

        lsp = {
          enable = true;

          keymaps.diagnostic = {
            "]d" = "goto_next";
            "[d" = "goto_prev";
            "<leader>vd" = "open_float";
          };
          keymaps.lspBuf = {
            "K" = "hover";
            "gd" = "definition";
            "gi" = "implementation";
            "<leader>vca" = "code_action";
            "<leader>vrr" = "references";
            "<leader>vrn" = "rename";
            "<C-f>" = "format";
          };
          keymaps.extra = [
            { key = "<C-h>"; action = nixvim.mkRaw "vim.lsp.buf.signature_help"; mode = "i"; }
          ];

          servers = {
            intelephense = {
              enable = true;
              package = pkgs.intelephense;
              settings = {
                intelephense.format.braces = "k&r";
              };
            };
            eslint.enable = true;
            gopls.enable = true;
            jsonls.enable = true;
            lua_ls.enable = true;
            nixd.enable = true;
            ts_ls.enable = true;
            typos_lsp.enable = true;
          };

          preConfig = ''
            function __longest_line(lines)
              local max = 0
              for _, line in ipairs(lines) do
                local len = #line
                if len > max then
                  max = len
                end
              end
              return max
            end

            local __open_floating_preview = vim.lsp.util.open_floating_preview
            vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
              local min_width = __longest_line(contents) + 10
              local min_height = #contents + 2

              opts.width = math.max(math.min(min_width, opts.max_width or math.huge), opts.width or 0)
              opts.height = math.max(math.min(min_height, opts.max_height or math.huge), opts.height or 0)

              opts.border = opts.border or 'rounded'

              return __open_floating_preview(contents, syntax, opts)
            end
          '';

        };

      };

      diagnostic.settings = {
        float = {
          border = "rounded";
        };
      };

    };
  };
}
