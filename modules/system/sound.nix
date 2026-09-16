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
        # Stop apps (e.g. Zen/Meet) from auto-switching the BT headset to
        # HFP. The rapid A2DP<->HFP churn hits a kernel SCO/eSCO race that
        # silences the mic (dmesg: "SCO packet for unknown connection handle").
        # Switch to headset mode manually in pavucontrol for calls instead.
        wireplumber.extraConfig."51-disable-bt-autoswitch" = {
          "wireplumber.settings" = {
            "bluetooth.autoswitch-to-headset-profile" = false;
          };
        };
      };
    };
  };
}
