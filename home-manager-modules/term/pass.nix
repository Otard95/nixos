{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.term.pass;
  enable = cfg.enable;
in {
  options.modules.term.pass.enable = lib.mkEnableOption "pass";

  config = lib.mkIf enable {

    home.packages = [ (pkgs.callPackage ./pass-env {}) ];

    programs = {
      password-store.enable = true;
      gpg = {
        enable = true;
        scdaemonSettings = {
          disable-ccid = true;
        };
      };
      wayprompt = {
        enable = true;
        settings = {
          general = {
            # Font used for description, buttons and error message. Defaults to "sans:size=14".
            font-regular = "${theme.font.regular.default}:size=14";
            # Font used for title. Defaults to "sans:size=20".
            font-large = "${theme.font.regular.default}:size=20";
            # Amount of the squares in the pin area. Defaults to 16.
            pin-square-amount = 6;
            # Padding around the labels of the buttons. Defaults to 5.
            button-inner-padding = 10;
            # Top and bottom padding of the dialog prompt window. Defaults to 10.
            vertical-padding = 20;
            # Left and right padding of the dialog prompt window. Defaults to 15.
            horizontal-padding = 30;
            # # Size of of the squares in the pin area, which represent the typed characters of the secret. Defaults to 18.
            # pin-square-size = <positive integer>;
            # # Width of the border of the dialog prompt window. Defaults to 2.
            # border = <positive integer>;
            # # Width of the border around the squares in the pin area. Defaults to 1.
            # pin-square-border = <positive integer>;
            # # Width of the border around the buttons. Defaults to 1.
            # button-border = <positive integer>;
            # # The radius of the corners of the dialog prompt window. Set to 0 to disable round corners. Defaults to 10.
            # corner-radius = <positive integer>;
          };
          colours = {
            # Background colour of the dialog prompt window. Defaults to 0xFFFFFF.
            background = "303446aa";
            # Border colour of the dialog prompt window. Defaults to 0x000000.
            border = "232634ff";
            # Colour of the title, description and prompt texts. Defaults to 0x000000.
            text = "c6d0f5ff";
            # Colour if the error text. Defaults to 0xE0002B.
            error-text = "e78284ff";
            # Colour of the pin area. Defaults to 0xD0D0D0.
            pin-background = "949cbbff";
            # Colour of the pin area border and the pin square borders. Defaults to 0x000000.
            pin-border = "737994ff";
            # Colour of the pin squares. Defaults to 0x808080.
            pin-square = "81c8beff";
            # Background colour of the ok button. Defaults to 0xD5F200.
            ok-button = "81c8beff";
            # Border colour of the ok button. Defaults to 0x000000.
            ok-button-border = "8caaeeff";
            # Text colour of the ok button. Defaults to 0x000000.
            ok-button-text = "232634ff";
            # Background colour of the not ok button. Defaults to 0xFFE53E.
            not-ok-button = "ea999cff";
            # Border colour of the not ok button. Defaults to 0x000000.
            not-ok-button-border = "e78284ff";
            # Text colour of the not ok button. Defaults to 0x000000.
            not-ok-button-text = "232634ff";
            # Background colour of the cancel button. Defaults to 0xFF4647.
            cancel-button = "949cbbff";
            # Border colour of thcancel ok button. Defaults to 0x000000.
            cancel-button-border = "737994ff";
            # Text colour of the cancel button. Defaults to 0x000000.
            cancel-button-text = "232634ff";
          };
        };
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry = {
        package = pkgs.wayprompt;
        program = "pinentry-wayprompt";
      };
    };

  };
}
