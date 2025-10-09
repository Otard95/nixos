{ config, lib, ... }:
let
  cfg = config.modules.packages.apps;
  enable = cfg.enable;
in {

  options.modules.packages.apps.enable = lib.mkEnableOption "apps";

  imports = [
    ./1password.nix
    ./appgate.nix
    ./bitwarden.nix
    ./blueman.nix
    ./calibre.nix
    ./clickup.nix
    ./clocks.nix
    ./dbeaver.nix
    ./digiKam.nix
    ./discord.nix
    ./firefox.nix
    ./firezone.nix
    ./games.nix
    ./grimblast.nix
    ./kdeconnect.nix
    ./kwallet.nix
    ./libre-office.nix
    ./loupe.nix
    ./matrix.nix
    ./mpv.nix
    ./notes.nix
    ./obsidian.nix
    ./pavucontrol.nix
    ./proton-pass.nix
    ./proton-vpn.nix
    ./redis-insight.nix
    ./signal.nix
    ./slack.nix
    ./thunar.nix
    ./vivaldi.nix
    ./wooting.nix
    ./yubikey.nix
    ./zen-browser.nix
  ];

  config = lib.mkIf enable {
    modules.packages.apps = {
      bitwarden.enable = lib.mkDefault true;
      blueman.enable = lib.mkDefault config.modules.system.bluetooth.enable;
      # grimblast.enable = lib.mkDefault config.modules.desktopEnvironment.hyprland.enable;
      libre-office.enable = lib.mkDefault true;
      loupe.enable = lib.mkDefault true;
      mpv.enable = lib.mkDefault true;
      notes.enable = lib.mkDefault true;
      pavucontrol.enable = lib.mkDefault true;
      proton-pass.enable = lib.mkDefault true;
      proton-vpn.enable = lib.mkDefault true;
      signal.enable = lib.mkDefault true;
      thunar.enable = lib.mkDefault true;
      yubikey.enable = lib.mkDefault true;
      zen-browser.enable = lib.mkDefault true;
    };
  };
}
