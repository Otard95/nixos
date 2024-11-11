{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.kitty;
  enable = cfg.enable;
in {

  options.modules.term.kitty.enable = lib.mkEnableOption "kitty configuration";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      kitty
    ];

    programs.kitty = {
      enable = true;

      font = {
        name = "MesloLGMDZ Nerd Font Mono";
      };
      themeFile = "Catppuccin-Frappe";

      settings = {
        dynamic_background_opacity = true;
        enable_audio_bell = false;
        background_opacity = "0.5";
        background_blur = 5;
        copy_on_select = "clipboard";
        window_margin_width = 5;
      };
    };
  };

}
