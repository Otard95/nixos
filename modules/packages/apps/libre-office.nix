{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.libre-office;
  enable = cfg.enable;
in {
  options.modules.packages.apps.libre-office.enable =
    lib.mkEnableOption "libre-office";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      libreoffice-qt
      hunspell
      hunspellDicts.nb_NO
      hunspellDicts.en_US
    ];
  };
}
