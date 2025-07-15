{ config, lib, ... }:
let
  cfg = config.modules.packages.gromit;
  enable = cfg.enable;
in {
  options.modules.packages.gromit.enable =
    lib.mkEnableOption "gromit";

  config = lib.mkIf enable {
    services.gromit-mpx = {
      enable = true;
    };

    systemd.user.services.gromit-mpx = lib.mkForce {};

    modules.desktopEnvironment.keybinds = [
      { key = "f9";
        exec = "uwsm app -- bash -c 'pidof gromit-mpx && gromit-mpx -q || gromit-mpx -a'";
      }
    ];
  };
}
