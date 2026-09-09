{ config, lib, pkgs, inputs, sources, ... }:
let
  cfg = config.modules.desktopEnvironment.app-launcher.vicinae;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.app-launcher.vicinae = {
    enable = lib.mkEnableOption "vicinae";
    splash-image = {
      path = lib.mkOption {
        description = "The splash-image to use";
        default = sources.images.splash.spacegirl;
        type = lib.types.path;
      };
      scale = lib.mkOption {
        description = "The scaling logic for the image, where scale is: none, both, width, height";
        default = "height";
        type = lib.types.enum [
          "height"
          "width"
          "both"
          "none"
        ];
      };
    };
  };

  config = lib.mkIf enable {

    catppuccin.vicinae.enable = false;

    programs.vicinae = {
      enable = true;
      systemd.enable = true;

      settings = {
        global_shortcuts.toggle = "";
        theme.dark.name = "catppuccin-frappe";
      };

      extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
        it-tools
        nix
        pulseaudio
        wikipedia
      ];
    };

  };

}
