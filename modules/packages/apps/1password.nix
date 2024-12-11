{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps._1password;
  enable = cfg.enable;
in {
  options.modules.packages.apps._1password.enable =
    lib.mkEnableOption "_1password";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ _1password-gui ];
  };
}
