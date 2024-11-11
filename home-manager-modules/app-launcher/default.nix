{ config, lib, pkgs, ... }:
let
  cfg = config.modules.app-launcher;
  enable = cfg.enable;
in {

  options.modules.app-launcher.enable = lib.mkEnableOption "app launcher";
  options.modules.app-launcher.launcher = lib.mkOption {
    default = "rofi";
    description = "Select a launcher to use";
    type = lib.types.enum [
      "rofi"
    ];
  };

  imports = [
    ./rofi.nix
  ];

  config = lib.mkIf enable {
    modules.app-launcher.rofi.enable = lib.mkDefault (cfg.launcher == "rofi");
  };

}
