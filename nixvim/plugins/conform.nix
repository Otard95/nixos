{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.conform;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.conform.enable =
    lib.mkEnableOption "conform plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      keymaps = [
        {
          action = nixvim.mkRaw "require('conform').format";
          key = "<C-f>";
          options.silent = true;
        }
      ];

      plugins.conform-nvim = {
        enable = true;

        autoInstall.enable = true;

        settings = {
          formatters_by_ft.php = [ "php_cs_fixer" ];
          default_format_opts.lsp_format = "last";
        };
      };
    };
  };
}
