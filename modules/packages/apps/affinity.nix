{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.packages.apps.affinity;
  enable = cfg.enable;
in {
  options.modules.packages.apps.affinity.enable =
    lib.mkEnableOption "affinity";

  config = lib.mkIf enable {

    nixpkgs.overlays = [ inputs.affinity-nix.overlays.default ];

    environment.systemPackages = [
      pkgs.affinity-photo
      pkgs.affinity-designer
    ];

  };
}
