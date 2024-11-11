{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages;
  enable = cfg.enable;
in {

  options.modules.packages.enable = lib.mkEnableOption "packages";

  imports = [
    ./notification.nix
    ./apps
  ];

  config = lib.mkIf enable {
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [ git ];
  };
}
