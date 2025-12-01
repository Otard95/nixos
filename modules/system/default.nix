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
    ./hardware.nix
    ./i18n.nix
    ./networking.nix
    ./printing.nix
    ./shell.nix
    ./sound.nix
  ];

  config = lib.mkIf enable {
    programs.nix-ld.enable = true;

    modules.system = {
      bluetooth.enable = lib.mkDefault true;
      gc.enable = lib.mkDefault true;
      hardware.enable = lib.mkDefault true;
      i18n.enable = lib.mkDefault true;
      networking.enable = lib.mkDefault true;
      shell.enable = lib.mkDefault true;
    };
  };
}
