{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.bitwarden;
  enable = cfg.enable;
in {
  options.modules.packages.apps.bitwarden.enable = lib.mkEnableOption "bitwarden";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ bitwarden-desktop ];
  };
}
