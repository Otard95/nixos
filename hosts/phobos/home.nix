{ sources, ... }:
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

  modules = {
    hyprland.hyprpaper.bg-image         = sources.images.background.forrest-lake-train;
    hyprland.hyprlock.bg-image          = sources.images.background.mountain-lake-sunrise;
    app-launcher.rofi.splash-image.path = sources.images.splash.bridge-forrest-fog;
    power-menu.rofi.splash-image.path   = sources.images.splash.bridge-forrest-fog;
    term = {
      direnv.enable = true;
      gh.enable = true;
      git.user = {
        name = "Stian Myklebostad";
        email = "stian.myklebostad@schibsted.com";
      };
      k9s.enable = true;
      thefuck.enable = true;
    };
    nixvim = {
      enable = true;
      plugins.preset = "all";
    };
  };

  # home.packages = with pkgs; [ ];
}
