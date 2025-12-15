{ config, lib, inputs, ... }:
let
  cfg = config.modules.packages.apps.affinity;
  enable = cfg.enable;
in {
  options.modules.packages.apps.affinity.enable =
    lib.mkEnableOption "affinity";

  config = lib.mkIf enable {

    environment.systemPackages = [
      inputs.affinity-nix.packages.x86_64-linux.photo
      inputs.affinity-nix.packages.x86_64-linux.designer
    ];

  };
}
