{ config, lib, ... }:
let
  cfg = config.modules.packages.apps;
  enable = cfg.enable;
in {

  options.modules.packages.apps.enable = lib.mkEnableOption "apps";

  imports = [
    ./firefox.nix
    ./zen-browser.nix
    ./pavucontrol.nix
    ./wooting.nix
    ./discord.nix
    ./matrix.nix
    ./yubikey.nix
  ];

  config = lib.mkIf enable {
    modules.packages.apps.zen-browser.enable = lib.mkDefault true;
    modules.packages.apps.pavucontrol.enable = lib.mkDefault true;
    modules.packages.apps.yubikey.enable = lib.mkDefault true;
  };
}
