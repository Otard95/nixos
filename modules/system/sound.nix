{ config, lib, ... }:
let
  cfg = config.modules.system.sound;
  enable = cfg.enable;
in {

  options.modules.system.sound.enable = lib.mkEnableOption "sound";

  config = lib.mkIf enable {

    services = {

      playerctld.enable = true;

      pipewire = {
        enable = true;
        audio.enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

    };

  };

}
