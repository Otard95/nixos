{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.loupe;
  enable = cfg.enable;
in {
  options.modules.packages.apps.loupe.enable =
    lib.mkEnableOption "loupe - image viewer";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ loupe ];
  };
}
