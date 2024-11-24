{ config, lib, ... }:
let
  cfg = config.modules.power-menu;
  enable = cfg.enable;
in {

  options.modules.power-menu = {
    enable = lib.mkEnableOption "power menu";
    launcher = lib.mkOption {
      default = "rofi";
      description = "Select a power menu to use";
      type = lib.types.enum [
        "rofi"
      ];
    };
  };

  imports = [
    ./rofi.nix
  ];

  config = lib.mkIf enable {
    modules.power-menu.rofi.enable = lib.mkDefault (cfg.launcher == "rofi");
  };

}
