{ config, lib, pkgs, ... }:
let
  cfg = config.modules.system.sound;
  enable = cfg.enable;
in {

  options.modules.system.sound.enable = lib.mkEnableOption "sound";

  config = lib.mkIf enable {
    hardware.pulseaudio = {
      enable = false;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
}
