{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.btop;
  enable = cfg.enable;
in {
  options.modules.packages.btop.enable =
    lib.mkEnableOption "btop";

  config = with pkgs; lib.mkIf enable {
    nixpkgs.overlays = [
      (self: super: {
        btop = super.btop.overrideAttrs (old: let pkgs = super; in {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.patchelf ];
          fixupPhase = (old.fixupPhase or "") + ''
            patchelf --add-rpath /run/opengl-driver/lib $out/bin/btop
          '';
        });
      })
    ];

    environment.systemPackages = [ btop ];
  };
}
