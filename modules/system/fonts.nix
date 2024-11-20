{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.system.fonts;
  enable = cfg.enable;
in {

  options.modules.system.fonts = {
    enable = lib.mkEnableOption "fonts";
    nerdfonts = lib.mkOption {
      description = "Which nerdfonts to install";
      default = [ "Meslo" ];
      type = lib.types.listOf lib.types.singleLineStr;
    };
  };

  config = lib.mkIf enable {
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;
      packages = with pkgs; [
        (nerdfonts.override { fonts = cfg.nerdfonts; })
      ];

      fontconfig = {
        defaultFonts = {
          serif = [ theme.font.regular ];
          sansSerif = [ theme.font.regular ];
          monospace = [ theme.font.mono ];
        };
      };
    };
  };
}
