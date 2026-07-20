{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.devenv;
  enable = cfg.enable;
in {
  options.modules.term.devenv.enable =
    lib.mkEnableOption "devenv";

  config = lib.mkIf enable {

    home.packages = [
      (pkgs.devenv.overrideAttrs (
        final: prev: {
          src = pkgs.fetchFromGitHub {
            owner = "cachix";
            repo = "devenv";
            rev = "c0174f8e7d46619bca28eb2be1a7ef3cca261be6";
            hash = "sha256-kG+DE1Slci5Buio0opArMiRkbf4n697m8U/O2kPuQOw=";
          };
          cargoDeps = prev.cargoDeps.overrideAttrs (prev: {
            # https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/25
            vendorStaging = prev.vendorStaging.overrideAttrs {
              src = final.src;
              outputHash = "sha256-30VwKVx4b2vrHlzPq96EwHDfQSfcz+CauLZhOl1TbyQ=";
            };
          });
        }
      ))
    ];

    programs.bash.bashrcExtra = ''
      source ${./auto-activate-bash.sh}
    '';

  };
}
