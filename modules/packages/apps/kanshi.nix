{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.kanshi;
  enable = cfg.enable;
in {
  options.modules.packages.apps.kanshi.enable =
    lib.mkEnableOption "kanshi";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ kanshi ];
  };
}
