{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.thunar;
  enable = cfg.enable;
in {
  options.modules.packages.apps.thunar.enable = lib.mkEnableOption "thunar";

  config = lib.mkIf enable {
    programs.thunar.enable = true;
    # programs.xfconf.enable = true;
    services = {
      gvfs.enable = true; # Mount, trash, and other functionalities
      tumbler.enable = true; # Thumbnail support for images
    };
  };
}
