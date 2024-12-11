{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.dbeaver;
  enable = cfg.enable;
in {
  options.modules.packages.apps.dbeaver.enable =
    lib.mkEnableOption "dbeaver";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ dbeaver-bin ];
  };
}
