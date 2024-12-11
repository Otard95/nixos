{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.clickup;
  enable = cfg.enable;
in {
  options.modules.packages.apps.clickup.enable =
    lib.mkEnableOption "clickup";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ clickup ];
  };
}
