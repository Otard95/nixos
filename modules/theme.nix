{ pkgs, theme, capFirst, ... }:
{
  # Enable Theme
  # environment.variables.GTK_THEME = "catppuccin-${theme.flavor}-${theme.accent}-${theme.size}";
  console.catppuccin.enable = true;

  # Override packages
  nixpkgs.config.packageOverrides = pkgs: {
    colloid-icon-theme = pkgs.colloid-icon-theme.override { colorVariants = [ theme.accent ]; };
    catppuccin-gtk = pkgs.catppuccin-gtk.override {
      accents = [ theme.flavor ]; # You can specify multiple accents here to output multiple themes 
      variant = theme.accent;
      size = theme.size;
    };
  };

  catppuccin = {
    enable = true;
    flavor = theme.flavor;
    accent = theme.accent;
  };

  environment.systemPackages = with pkgs; [
    numix-icon-theme-circle
    colloid-icon-theme
    catppuccin-gtk
    catppuccin-cursors.frappeTeal
  ];
}
