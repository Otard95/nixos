{ pkgs, theme, ... }:
{
  # Override packages
  nixpkgs.config.packageOverrides = pkgs: {
    colloid-icon-theme = pkgs.colloid-icon-theme.override { colorVariants = [ theme.accent ]; };
    catppuccin-gtk = pkgs.catppuccin-gtk.override {
      size = theme.size;
      variant = theme.flavor;
      accents = [ theme.accent ]; # You can specify multiple accents here to output multiple themes 
    };
  };

  catppuccin = {
    enable = true;
    flavor = theme.flavor;
    accent = theme.accent;

    tty.enable = true;
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  environment.systemPackages = with pkgs; [
    numix-icon-theme-circle
    colloid-icon-theme
    catppuccin-gtk
    catppuccin-cursors.frappeTeal
    rose-pine-hyprcursor
  ];
}
