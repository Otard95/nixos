{ config, pkgs, theme, ...}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "otard";
  home.homeDirectory = "/home/otard";

  imports = [ ./modules ];

  catppuccin = {
    enable = true;
    inherit (theme) flavor accent;
    pointerCursor.enable = true;
  };

  home.packages = with pkgs; [
  ];
}
