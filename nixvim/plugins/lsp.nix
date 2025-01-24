{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.lsp;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.lsp.enable =
    lib.mkEnableOption "lsp plugins";

  config = lib.mkIf enable {
    programs.nixvim.plugins = {
      lsp-format.enable = true;

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
      };
    };
  };
}
