{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.calibre;
  enable = cfg.enable;
in {
  options.modules.packages.apps.calibre.enable =
    lib.mkEnableOption "calibre";

  config = lib.mkIf enable {

    # Might be needed for some devices to via USB
    # services.udisks2.enable = true;

    environment.systemPackages = with pkgs; [
      (calibre.override {
        # Needed to open .cbr and .cbz files
        unrarSupport = true;
      })
    ];

  };
}
