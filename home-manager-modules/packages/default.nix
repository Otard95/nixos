{ config, lib, ... }:
let
  cfg = config.modules.packages;
  enable = cfg.enable;
in {
  options.modules.packages.enable =
    lib.mkEnableOption "packages";

  imports = [
    ./cliphist.nix
  ];

  config = lib.mkIf enable {
    modules.packages.cliphist.enable = lib.mkDefault true;
  };
}
