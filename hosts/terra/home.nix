{ theme, ...}:
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

  catppuccin = {
    enable = true;
    inherit (theme) flavor accent;
    pointerCursor.enable = true;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ theme.font.regular theme.font.icons ];
      sansSerif = [ theme.font.regular theme.font.icons ];
      monospace = [ theme.font.mono theme.font.icons ];
    };
  };

  # home.packages = with pkgs; [ ];
}
