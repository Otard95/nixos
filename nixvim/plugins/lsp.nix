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
              enable = true; # TODO: needs package
              package = pkgs.intelephense;
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
            function __longest_line(s)
              local max = 0
              for line in s:gmatch("[^\n]+") do
                local len = #line
                if len > max then
                  max = len
                end
              end
              return max
            end
            function hover(_, result, ctx, config)
              if not (result and result.contents) then config.width = 80 end
              if result and type(result.contents) == "string" then config.width = __longest_line(result.contents) + 10 end
              if result and type(result.contents.value) == "string" then config.width = __longest_line(result.contents.value) + 10 end
              if type(config.width) and config.width < 25 then config.width = 25 end
              return vim.lsp.handlers.hover(_, result, ctx, config)
            end
          '';
          setupWrappers = [
            (s: ''vim.tbl_extend("keep", ${s} or {}, {
              handlers = {
                vim.lsp.handlers,
                ['textDocument/hover'] = vim.lsp.with(hover, { border = 'rounded' }),
                ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
              },
            })'')
          ];

        };

      };

      diagnostics = {
        float = {
          border = "rounded";
        };
      };

    };
  };
}
