{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.packages.apps.zen-browser;
  enable = cfg.enable;
in {
  options.modules.packages.apps.zen-browser.enable = lib.mkEnableOption "zen-browser";

  config = lib.mkIf enable {

    environment = {

      sessionVariables.MOZ_USE_XINPUT2 = "1";

      systemPackages = with pkgs; [
        inputs.zen-browser.packages."${stdenv.hostPlatform.system}".default
        (makeDesktopItem {
          name = "zen-browser-personal";
          desktopName = "Zen Browser";
          genericName = "Personal";
          exec = "zen -P Personal";
          icon = "zen";
          startupWMClass = "zen-alpha";
          categories = [ "Network" "WebBrowser" ];
          startupNotify = true;
          terminal = false;
          keywords = [ "Internet" "WWW" "Browser" "Web" "Explorer" ];
        })
      ];

    };

  };
}
