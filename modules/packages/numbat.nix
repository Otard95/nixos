{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.numbat;
  enable = cfg.enable;
in {
  options.modules.packages.numbat.enable =
    lib.mkEnableOption "numbat";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ numbat ];
  };
}
