{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.modules.packages.voxtype;
  enable = cfg.enable;
in {
  options.modules.packages.voxtype.enable =
    lib.mkEnableOption "voxtype";

  config = lib.mkIf enable {
    programs.voxtype = {
      enable = true;
      package = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.vulkan;
      model.name = "base.en";
      service.enable = true;
      settings = {
        hotkey.enabled = false;
        whisper.language = "en";
      };
    };

    modules.desktopEnvironment.keybinds = [
      { key = "f8";
        exec = "uwsm app -- voxtype record start";
      }
      { key = "f8";
        release = true;
        exec = "uwsm app -- voxtype record stop";
      }
    ];
  };
}
