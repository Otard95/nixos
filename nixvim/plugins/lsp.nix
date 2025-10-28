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
          { key = "K";           lspBufAction = "hover"; }
          { key = "gd";          lspBufAction = "definition"; }
          { key = "gi";          lspBufAction = "implementation"; }
          { key = "<leader>vca"; lspBufAction = "code_action"; }
          { key = "<leader>vrr"; lspBufAction = "references"; }
          { key = "<leader>vrn"; lspBufAction = "rename"; }
          { key = "<C-f>";       lspBufAction = "format"; }
          { key = "]d";          action = nixvim.mkRaw "vim.diagnostic.goto_next"; }
          { key = "[d";          action = nixvim.mkRaw "vim.diagnostic.goto_prev"; }
          { key = "<leader>vd";  action = nixvim.mkRaw "vim.diagnostic.open_float"; }
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
