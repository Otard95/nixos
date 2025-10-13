{ config, lib, pkgs-stable, ... }:
let
  cfg = config.modules.packages.apps.digiKam;
  enable = cfg.enable;
in {
  options.modules.packages.apps.digiKam.enable =
    lib.mkEnableOption "digiKam - image manager";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs-stable; [ digikam ];
  };
}
