{ config, lib, ... }:
let
  cfg = config.modules.system;
  enable = cfg.enable;
in {

  options.modules.system.enable = lib.mkEnableOption "system modules";

  imports = [
    ./gc.nix
    ./i18n.nix
  ];

  config = lib.mkIf enable {
    modules.system.gc.enable = lib.mkDefault true;
    modules.system.i18n.enable = lib.mkDefault true;
  };
}
