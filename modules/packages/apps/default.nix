{ config, lib, ... }:
let
  cfg = config.modules.packages.apps;
  enable = cfg.enable;
in {

  options.modules.packages.apps.enable = lib.mkEnableOption "apps";

  imports = [
    ./bitwarden.nix
    ./blueman.nix
    ./firefox.nix
    ./zen-browser.nix
    ./pavucontrol.nix
    ./signal.nix
    ./thunar.nix
    ./wooting.nix
    ./discord.nix
    ./matrix.nix
    ./yubikey.nix
  ];

  config = lib.mkIf enable {
    modules.packages.apps = {
      bitwarden.enable = lib.mkDefault true;
      blueman.enable = lib.mkDefault config.modules.system.bluetooth.enable;
      zen-browser.enable = lib.mkDefault true;
      pavucontrol.enable = lib.mkDefault true;
      signal.enable = lib.mkDefault true;
      yubikey.enable = lib.mkDefault true;
      thunar.enable = lib.mkDefault true;
    };
  };
}
