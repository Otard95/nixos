{ pkgs, ... }:
{
  enable = true;
  catppuccin.enable = false;

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
    window-format = "{w}; · {c} · {t}";
  };

  theme = ./rofi.theme.rasi;
}
