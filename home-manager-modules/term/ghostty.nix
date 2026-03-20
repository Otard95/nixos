{ config, lib, theme, ... }:
let
  cfg = config.modules.term.ghostty;
  enable = cfg.enable;
in {

  options.modules.term.ghostty.enable = lib.mkEnableOption "ghostty configuration";

  config = lib.mkIf enable {

    programs.ghostty = {
      enable = true;
      enableBashIntegration = true;

      systemd.enable = true;

      settings = {
        theme = "catppuccin-frappe";
        font-size = 10;
        font-family = theme.font.mono.default;
        background-opacity = 0.95;
        cursor-style-blink = false;

        copy-on-select = true;
        working-directory = "home";
        window-inherit-working-directory = false;

        keybind = [
          "ctrl+enter=unbind"

          "ctrl+shift+digit_1=text:\\x011"
          "ctrl+shift+digit_2=text:\\x012"
          "ctrl+shift+digit_3=text:\\x013"
          "ctrl+shift+digit_4=text:\\x014"
          "ctrl+shift+digit_5=text:\\x015"
          "ctrl+shift+digit_6=text:\\x016"
          "ctrl+shift+digit_7=text:\\x017"
          "ctrl+shift+digit_8=text:\\x018"
          "ctrl+shift+digit_9=text:\\x019"

          "ctrl+shift+comma=text:\\x01<"
          "ctrl+shift+period=text:\\x01>"

          "ctrl+shift+t=unbind"
          "ctrl+shift+w=unbind"
          "ctrl+shift+j=unbind"
          "ctrl+shift+,=unbind"
        ];
      };

    };

  };

}
