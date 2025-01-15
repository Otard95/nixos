{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.system.fonts;
  enable = cfg.enable;
in {

  options.modules.system.fonts.enable = lib.mkEnableOption "fonts";

  config = lib.mkIf enable {
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;
      packages = with pkgs; [
        meslo-lg
        nerd-fonts.symbols-only
        noto-fonts-cjk-sans
      ];

      fontconfig = {
        defaultFonts = {
          serif = [ theme.font.regular.default theme.font.icons ] ++
            theme.font.regular.extra;
          sansSerif = [ theme.font.regular.default theme.font.icons ] ++
            theme.font.regular.extra;
          monospace = [ theme.font.mono.default theme.font.icons ];
        };
      };
    };
  };
}
