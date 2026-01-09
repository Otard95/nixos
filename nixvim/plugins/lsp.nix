{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.lsp;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.lsp.enable =
    lib.mkEnableOption "lsp plugins";

  config = lib.mkIf enable {

    programs.nixvim = {

      lsp = {

        keymaps = [
          { key = "K";           lspBufAction = "hover";          mode = "n"; }
          { key = "gd";          lspBufAction = "definition";     mode = "n"; }
          { key = "gi";          lspBufAction = "implementation"; mode = "n"; }
          { key = "<leader>vca"; lspBufAction = "code_action";    mode = "n"; }
          { key = "<leader>vrr"; lspBufAction = "references";     mode = "n"; }
          { key = "<leader>vrn"; lspBufAction = "rename";         mode = "n"; }
          { key = "<C-f>";       lspBufAction = "format";         mode = "n"; }
          { key = "]d";          action = nixvim.mkRaw "function() vim.diagnostic.jump({ count = 1 }) end"; mode = "n"; }
          { key = "[d";          action = nixvim.mkRaw "function() vim.diagnostic.jump({ count = -1 }) end"; mode = "n"; }
          { key = "<leader>vd";  action = nixvim.mkRaw "vim.diagnostic.open_float"; mode = "n"; }
          { key = "<C-h>";       action = nixvim.mkRaw "vim.lsp.buf.signature_help"; mode = "i"; }
        ];

        servers = {
          phpactor = {
            enable = true;
            config = {
              root_markers = [
                "index.php"
                "compile.php"
              ];
            };
          };
          eslint.enable = true;
          gopls.enable = true;
          jsonls.enable = true;
          lua_ls.enable = true;
          nixd.enable = true;
          ts_ls.enable = true;
          typos_lsp.enable = true;
          basedpyright.enable = true;
          svelte.enable = true;
        };

      };

      plugins = {
        lsp.enable = true;
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
      };

    };
  };
}
