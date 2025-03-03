{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.protonvpn;
  enable = cfg.enable;
in {
  options.modules.packages.apps.protonvpn.enable =
    lib.mkEnableOption "protonvpn";

  config = lib.mkIf enable {

    environment.systemPackages = with pkgs; [
      protonvpn-gui
    ];

    networking.firewall.checkReversePath = "loose";

  };
}
