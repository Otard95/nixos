{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.app-launcher.rofi;
  enable = cfg.enable;
in {

  options.modules.app-launcher.rofi = {
    enable = lib.mkEnableOption "rofi";
    splash-image = lib.mkOption {
      description = "The splash-image to use";
      default = "./splash-images/spacegirl.jpg";
      type = lib.types.singleLineStr;
    };
  }

  config = lib.mkIf enable {
    xdg.configFile."rofi/splash-images".source = ./splash-images;

    home.packages = with pkgs; [
      rofi-wayland
    ];

    programs.rofi = {
      enable = true;
      catppuccin.enable = false;

      package = pkgs.rofi-wayland;

      font = theme.font.regular;

      extraConfig = {
        modi = "drun,run,filebrowser,window";
        show-icons = true;
        icon-theme = "Numix-Circle";
        display-drun = "APPS";
        display-run = "RUN";
        display-filebrowser = "FILES";
        display-window = "WINDOW";
        drun-display-format = "{name}";
        window-format = "{w} · {c} · {t}";
      };

      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
      in {
        ## /*****----- Global Properties -----*****/
        "*" = {
          font = builtins.concatStringsSep " " [ theme.font.regular "10" ];
          background = mkLiteral "#131D1F";
          background-alt = mkLiteral "#183A43";
          foreground = mkLiteral "#FFFFFF";
          selected = mkLiteral "#649094";
          active = mkLiteral "#E9CC9D";
          urgent = mkLiteral "#FEA861";

          rosewater = mkLiteral "#f2d5cf";
          flamingo = mkLiteral "#eebebe";
          pink = mkLiteral "#f4b8e4";
          mauve = mkLiteral "#ca9ee6";
          red = mkLiteral "#e78284";
          maroon = mkLiteral "#ea999c";
          peach = mkLiteral "#ef9f76";
          yellow = mkLiteral "#e5c890";
          green = mkLiteral "#a6d189";
          teal = mkLiteral "#81c8be";
          sky = mkLiteral "#99d1db";
          sapphire = mkLiteral "#85c1dc";
          blue = mkLiteral "#8caaee";
          lavender = mkLiteral "#babbf1";
          text = mkLiteral "#c6d0f5";
          subtext1 = mkLiteral "#b5bfe2";
          subtext0 = mkLiteral "#a5adce";
          overlay2 = mkLiteral "#949cbb";
          overlay1 = mkLiteral "#838ba7";
          overlay0 = mkLiteral "#737994";
          surface2 = mkLiteral "#626880";
          surface1 = mkLiteral "#51576d";
          surface0 = mkLiteral "#414559";
          base = mkLiteral "#303446";
          mantle = mkLiteral "#292c3c";
          crust = mkLiteral "#232634";

          baseAlpha = mkLiteral "#303446aa";
        };

        ## /*****----- Main Window -----*****/
        window = {
          /* properties for window widget */
          transparency = "real";
          location = mkLiteral "center";
          anchor = mkLiteral "center";
          fullscreen = mkLiteral "false";
          width = mkLiteral "1000px";
          x-offset = mkLiteral "0px";
          y-offset = mkLiteral "0px";

          /* properties for all widgets */
          enabled = mkLiteral "true";
          border-radius = mkLiteral "15px";
          cursor = "default";
          background-color = mkLiteral "@baseAlpha";
        };

        ## /*****----- Main Box -----*****/
        mainbox = {
          enabled = mkLiteral "true";
          spacing = mkLiteral "0px";
          background-color = mkLiteral "transparent";
          orientation = mkLiteral "horizontal";
          children = mkLiteral ''[ "imagebox", "listbox" ]'';
        };

        imagebox = {
          padding = mkLiteral "20px";
          background-color = mkLiteral "transparent";
          background-image = mkLiteral (lib.strings.concatStrings [
            ''url("''
            cfg.splash-image
            ''", height)''
          ]);
          orientation = mkLiteral "vertical";
          children = mkLiteral ''[ "inputbar", "dummy", "mode-switcher" ]'';
        };

        listbox = {
          spacing = mkLiteral "20px";
          padding = mkLiteral "20px";
          background-color = mkLiteral "transparent";
          orientation = mkLiteral "vertical";
          children = mkLiteral ''[ "message", "listview" ]'';
        };

        dummy = {
          background-color = mkLiteral "transparent";
        };

        ## /*****----- Inputbar -----*****/
        inputbar = {
          enabled = mkLiteral "true";
          spacing = mkLiteral "10px";
          padding = mkLiteral "15px";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "@overlay0";
          text-color = mkLiteral "@text";
          children = mkLiteral ''[ "textbox-prompt-colon", "entry" ]'';
        };
        textbox-prompt-colon = {
          enabled = mkLiteral "true";
          expand = mkLiteral "false";
          str = "";
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };
        entry = {
          enabled = mkLiteral "true";
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "text";
          placeholder = "Search";
          placeholder-color = mkLiteral "inherit";
        };

        ## /*****----- Mode Switcher -----*****/
        mode-switcher = {
          enabled = mkLiteral "true";
          spacing = mkLiteral "20px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@text";
        };
        button = {
          padding = mkLiteral "15px";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "@overlay0";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "pointer";
        };
        "button selected" = {
          background-color = mkLiteral "@teal";
          text-color = mkLiteral "@crust";
        };

        ## /*****----- Listview -----*****/
        listview = {
          enabled = mkLiteral "true";
          columns = mkLiteral "1";
          lines = mkLiteral "8";
          cycle = mkLiteral "true";
          dynamic = mkLiteral "true";
          scrollbar = mkLiteral "false";
          layout = mkLiteral "vertical";
          reverse = mkLiteral "false";
          fixed-height = mkLiteral "true";
          fixed-columns = mkLiteral "true";

          spacing = mkLiteral "10px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@text";
          cursor = "default";
        };

        ## /*****----- Elements -----*****/
        element = {
          enabled = mkLiteral "true";
          spacing = mkLiteral "15px";
          padding = mkLiteral "8px";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@text";
          cursor = mkLiteral "pointer";
        };
        "element normal.normal"  ={
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };
        "element normal.urgent" = {
          background-color = mkLiteral "@maroon";
          text-color = mkLiteral "@crust";
        };
        "element normal.active" = {
          background-color = mkLiteral "@green";
          text-color = mkLiteral "@crust";
        };
        "element selected.normal" = {
          background-color = mkLiteral "@teal";
          text-color = mkLiteral "@crust";
        };
        "element selected.urgent" = {
          background-color = mkLiteral "@maroon";
          text-color = mkLiteral "@crust";
        };
        "element selected.active" = {
          background-color = mkLiteral "@maroon";
          text-color = mkLiteral "@crust";
        };
        element-icon = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          size = mkLiteral "32px";
          cursor = mkLiteral "inherit";
        };
        element-text = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
        };

        ## /*****----- Message -----*****/
        message = {
          background-color = mkLiteral "transparent";
        };
        textbox = {
          padding = mkLiteral "15px";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "@overlay0";
          text-color = mkLiteral "@text";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
        };
        error-message = {
          padding = mkLiteral "15px";
          border-radius = mkLiteral "20px";
          background-color = mkLiteral "@surface0";
          text-color = mkLiteral "@text";
        };
      };
    };

  };

}
