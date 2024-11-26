{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.btop;
  enable = cfg.enable;
in {
  options.modules.packages.btop.enable =
    lib.mkEnableOption "btop";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      btop
    ];
  };
}
