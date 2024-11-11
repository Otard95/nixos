{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.yubikey;
  enable = cfg.enable;
in {
  options.modules.packages.apps.yubikey.enable = lib.mkEnableOption "yubikey";

  config = lib.mkIf enable {
    services.pcscd.enable = true;

    environment.systemPackages = with pkgs; [ yubioath-flutter ];
  };
}
