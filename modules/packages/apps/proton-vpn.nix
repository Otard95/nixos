{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.proton-vpn;
  enable = cfg.enable;
in {
  options.modules.packages.apps.proton-vpn.enable =
    lib.mkEnableOption "proton-vpn";

  config = lib.mkIf enable {

    environment.systemPackages = with pkgs; [
      protonvpn-gui
    ];

    networking.firewall.checkReversePath = "loose";

  };
}
