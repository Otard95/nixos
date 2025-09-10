{ config, lib, pkgs, pkgs-stable, ... }:
let
  cfg = config.modules.packages.yubioath;
  enable = cfg.enable;
in {
  options.modules.packages.yubioath = {
    enable = lib.mkEnableOption "yubioath";
  };

  config = lib.mkIf enable {

    home.packages = [ pkgs-stable.yubioath-flutter pkgs.zenity ];

    # TODO: Use modules/packages/apps/yubikey.nix when fixed
    #       Wayland/EGL quirk. Fixed by GDK_BACKEND=x11 env-var
    xdg.desktopEntries."com.yubico.authenticator" = {
      name = "Yubico Authenticator";
      genericName = "Yubico Authenticator";
      exec = "env GDK_BACKEND=x11 ${pkgs-stable.yubioath-flutter}/bin/yubioath-flutter %U";
      icon = "${pkgs-stable.yubioath-flutter}/share/icons/com.yubico.yubioath.png";
      type = "Application";
      categories = [ "Utility" ];
      settings = {
        Keywords = "Yubico;Authenticator;";
      };
    };

  };
}
