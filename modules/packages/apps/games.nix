{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.games;
  enable = cfg.enable;
in {
  options.modules.packages.apps.games = {
    enable = lib.mkEnableOption "games";

    minecraft = {
      enable = lib.mkEnableOption "minecraft";

      launcher = lib.mkPackageOption pkgs "prismlauncher" { };
    };
  };

  config = lib.mkIf enable {

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
    # Useful for non-steam games
    # environment.systemPackages = with pkgs; [
    #   steam-run
    # ];

    environment.systemPackages = with pkgs; [
      # lutris
      (lutris.override {
        extraLibraries =  pkgs: [
          # List library dependencies here
          dxvk
        ];
        extraPkgs = pkgs: [
          # List package dependencies here
          dxvk
        ];
      })
    ]
      ++ lib.optional cfg.minecraft.enable cfg.minecraft.launcher;

  };
}
