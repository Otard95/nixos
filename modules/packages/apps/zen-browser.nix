{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.zen-browser;
  enable = cfg.enable;
in {
  options.modules.packages.apps.zen-browser.enable = lib.mkEnableOption "zen-browser";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      inputs.zen-browser.packages."${system}".default
    ];
  };
}
