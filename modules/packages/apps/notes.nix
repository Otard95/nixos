{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.notes;
  enable = cfg.enable;
in {
  options.modules.packages.apps.notes.enable =
    lib.mkEnableOption "notes";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ gedit sublime ];
  };
}
