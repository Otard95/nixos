{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.lazydev;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.lazydev.enable =
    lib.mkEnableOption "lazydev";

  config = lib.mkIf enable {
    programs.nixvim.plugins.lazydev = {
      enable = true;

      settings = {
        integrations = {
          cmp = true;
          lspconfig = true;
        };
        library = [
          "/etc/nixos/home-manager-modules/term/wezterm"
          { path = "/home/otard/.config/wezterm/wezterm-types"; mods = [ "wezterm" ]; }
        ];
      };
    };
  };
}
