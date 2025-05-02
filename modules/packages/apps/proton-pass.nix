{ config, lib, pkgs-stable, ... }:
let
  cfg = config.modules.packages.apps.proton-pass;
  enable = cfg.enable;
in {
  options.modules.packages.apps.proton-pass.enable =
    lib.mkEnableOption "proton-pass";

  config = lib.mkIf enable {
    environment.systemPackages = [
      pkgs-stable.proton-pass
    ];
  };
}
