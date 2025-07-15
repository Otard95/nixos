{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.flameshot;
  enable = cfg.enable;
in {
  options.modules.packages.flameshot.enable = lib.mkEnableOption "flameshot";

  config = lib.mkIf enable {
    services.flameshot = {
      enable = true;
      package = pkgs.flameshot.override { enableWlrSupport = true; };
    };

    modules.desktopEnvironment.keybinds = [
      # Config from: https://github.com/flameshot-org/flameshot/issues/2978#issuecomment-1910298105
      { key = "s"; mods = [ "main" "shift" ];
        exec = "uwsm app -- flameshot gui -r | ${pkgs.wl-clipboard}/bin/wl-copy";
      }
    ];
  };
}
