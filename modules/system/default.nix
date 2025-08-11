{ config, lib, ... }:
let
  cfg = config.modules.system;
  enable = cfg.enable;
in {

  options.modules.system.enable = lib.mkEnableOption "system modules";

  imports = [
    ./battery-monitor.nix
    ./bluetooth.nix
    ./fingerprint.nix
    ./fonts.nix
    ./gc.nix
    ./graphics.nix
    ./i18n.nix
    ./networking.nix
    ./printing.nix
    ./shell.nix
    ./sound.nix
  ];

  config = lib.mkIf enable {
    modules.system.bluetooth.enable = lib.mkDefault true;
    modules.system.gc.enable = lib.mkDefault true;
    modules.system.i18n.enable = lib.mkDefault true;
    modules.system.networking.enable = lib.mkDefault true;
    modules.system.shell.enable = lib.mkDefault true;
  };
}
