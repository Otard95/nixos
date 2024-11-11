{ config, lib, pkgs, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;

  cfg = config.modules.app-launcher.rofi;
  enable = cfg.enable;
in {

  options.modules.app-launcher.rofi.enable = lib.mkEnableOption "rofi";

  config = lib.mkIf enable {
    xdg.configFile."rofi/splash-images".source =
      mkOutOfStoreSymlink "/etc/nixos/home-manager-modules/app-launcher/splash-images";

    home.packages = with pkgs; [
      rofi-wayland
    ];

    programs.rofi = {
      enable = true;
      catppuccin.enable = false;

      package = pkgs.rofi-wayland;

      font = "MesloLGM Nerd Font";

      extraConfig = {
        modi = "drun,run,filebrowser,window";
        show-icons = true;
        icon-theme = "Numix-Circle";
        display-drun = "APPS";
        display-run = "RUN";
        display-filebrowser = "FILES";
        display-window = "WINDOW";
        drun-display-format = "{name}";
        window-format = "{w} · {c} · {t}";
      };

      theme = ./rofi.theme.rasi;
    };

  };

}
