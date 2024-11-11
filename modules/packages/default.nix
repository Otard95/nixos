{ config, lib, ... }:
let
  cfg = config.modules.packages;
  enable = cfg.enable;
in {

  options.modules.packages.enable = lib.mkEnableOption "packages";

  imports = [
    ./notification.nix
  ];

  config = lib.mkIf enable {
  };
}
