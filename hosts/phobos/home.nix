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
    desktopEnvironment = {
      background-image.horizontal = sources.images.background.forrest-lake-train;
      splash-image = sources.images.splash.bridge-forrest-fog;
    };
    packages = {
      hdrop.enable = true;
    };
    term = {
      scripts.fabric.enable = true;
      direnv.enable = true;
      claude.enable = true;
      gh.enable = true;
      git = {
        user = {
          name = "Stian Myklebostad";
          email = "stian.myklebostad@mittanbud.no";
        };
        signingKey = "B2D64340F9493B0A";
      };
      scripts.enable = true;
      k9s.enable = true;
      zsh.enable = true;
    };
    nixvim = {
      enable = true;
      plugins.preset = "all";
    };
  };

  # home.packages = with pkgs; [ ];
}
