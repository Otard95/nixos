{ config, lib, ... }:
let
  cfg = config.modules.packages;
  enable = cfg.enable;
in {
  options.modules.packages.enable =
    lib.mkEnableOption "packages";

  imports = [
    ./cliphist.nix
    ./flameshot.nix
    ./gromit.nix
    ./hdrop.nix
  ];

  config = lib.mkIf enable {
    modules.packages = {
      cliphist.enable = lib.mkDefault true;
      flameshot.enable = lib.mkDefault true;
      gromit.enable = lib.mkDefault true;
    };
  };
}
