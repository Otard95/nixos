{ config, lib, ... }:
let
  cfg = config.modules.packages.apps;
  enable = cfg.enable;
in {

  options.modules.packages.apps.enable = lib.mkEnableOption "apps";

  imports = [
    ./bitwarden.nix
    ./blueman.nix
    ./clickup.nix
    ./discord.nix
    ./firefox.nix
    ./flameshot.nix
    ./grimblast.nix
    ./kdeconnect.nix
    ./loupe.nix
    ./matrix.nix
    ./mpv.nix
    ./pavucontrol.nix
    ./signal.nix
    ./slack.nix
    ./thunar.nix
    ./wooting.nix
    ./yubikey.nix
    ./zen-browser.nix
  ];

  config = lib.mkIf enable {
    modules.packages.apps = {
      bitwarden.enable = lib.mkDefault true;
      blueman.enable = lib.mkDefault config.modules.system.bluetooth.enable;
      flameshot.enable = lib.mkDefault (!config.modules.desktopEnvironment.hyprland.enable);
      grimblast.enable = lib.mkDefault config.modules.desktopEnvironment.hyprland.enable;
      loupe.enable = lib.mkDefault true;
      mpv.enable = lib.mkDefault true;
      pavucontrol.enable = lib.mkDefault true;
      signal.enable = lib.mkDefault true;
      thunar.enable = lib.mkDefault true;
      yubikey.enable = lib.mkDefault true;
      zen-browser.enable = lib.mkDefault true;
    };
  };
}
