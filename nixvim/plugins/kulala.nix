{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.kulala;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.kulala.enable =
    lib.mkEnableOption "kulala plugin";

  config = lib.mkIf enable {

    programs.nixvim = {

      extraPackages = [ pkgs.prettier ];

      plugins.kulala = {
        enable = true;

        settings = {
          environment_scope = "g";
          split_direction = "horizontal";
          global_keymaps = true;
          global_keymaps_prefix = "<leader>r";
        };
      };

    };

  };
}
