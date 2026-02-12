{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.conform;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.conform.enable =
    lib.mkEnableOption "conform plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      # extraPackages = [ pkgs.phpPackages.php-cs-fixer ];

      keymaps = [
        {
          action = nixvim.mkRaw "require('conform').format";
          key = "<C-f>";
          options.silent = true;
        }
      ];

      plugins.conform-nvim = {
        enable = true;

        settings = {
          formatters_by_ft.php = [ "php-cs-fixer" ];
          default_format_opts.lsp_format = "last";
        };
      };
    };
  };
}
