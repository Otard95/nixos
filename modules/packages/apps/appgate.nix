{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.appgate;
  enable = cfg.enable;
in {
  options.modules.packages.apps.appgate.enable =
    lib.mkEnableOption "appgate";

  config = lib.mkIf enable {

    nixpkgs.overlays = [
      (final: prev: {
        appgate-sdp = prev.appgate-sdp.overrideAttrs (old: {
          version = "6.5.3";
          src = pkgs.fetchurl {
            url = "https://bin.appgate-sdp.com/${lib.versions.majorMinor "6.5.3"}/client/appgate-sdp_6.5.3_amd64.deb";
            sha256 = "sha256-MyC28cOTO9EpvHvlNWtdNRbuywl0uBD8G5+cACBzMRY=";
          };
        });
      })
    ];

    programs.appgate-sdp.enable = true;

    modules.packages.apps.kwallet.enable = lib.mkDefault true;

  };
}
