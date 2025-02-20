{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.kwallet;
  enable = cfg.enable;
in {
  options.modules.packages.apps.kwallet.enable =
    lib.mkEnableOption "kwallet";

  config = lib.mkIf enable {

    environment.systemPackages = with pkgs; [
      kdePackages.kwallet
      kdePackages.kwalletmanager
      kdePackages.kcmutils
    ];

    security.pam.services = {
      login.kwallet = {
        enable = true;
        package = pkgs.kdePackages.kwallet-pam;
      };
      kde = {
        allowNullPassword = true;
        kwallet = {
          enable = true;
          package = pkgs.kdePackages.kwallet-pam;
        };
      };
      kde-fingerprint = lib.mkIf config.services.fprintd.enable { fprintAuth = true; };
      kde-smartcard = lib.mkIf config.security.pam.p11.enable { p11Auth = true; };
    };

  };
}
