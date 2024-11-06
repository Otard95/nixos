{ pkgs, ... }:
{
  enable = true;

  font = "MesloLGM Nerd Font";

  extraConfig = {
    show-icons = true;
    display-drun = " ❱  Apps ";
    sidebar-mode = true;
    icon-theme = "Numix-Circle";
  };
}
