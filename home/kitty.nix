{ pkgs, ... }:
{
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
}
