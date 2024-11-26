{ config, lib, ... }:
let
  cfg = config.modules.system.graphics;
  enable = cfg.enable;
in {

  options.modules.system.graphics = {
    enable = lib.mkEnableOption "graphics";
    manufacturer = lib.mkOption {
      description = "eg. AMD, Nvidia, Intel";
      default = "nvidia";
      type = lib.types.enum [
        "nvidia"
        "amd"
        "intel"
      ];
    };
  };

  config = lib.mkIf enable {
    # Graphics
    hardware = {
      graphics = {
        enable = true;
      };
      nvidia = lib.mkIf (cfg.manufacturer == "nvidia") {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
    };
    services.xserver.videoDrivers = lib.mkIf (cfg.manufacturer == "nvidia") [
      "nvidia"
    ];
    boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
  };
}
