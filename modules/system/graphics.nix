{ config, lib, ... }:
let
  cfg = config.modules.system.graphics;
  enable = cfg.enable;

  busIDType = lib.types.strMatching "([[:print:]]+[\:\@][0-9]{1,3}\:[0-9]{1,2}\:[0-9])?";
  mkBusIDOption = name: lib.mkOption {
    type = busIDType;
    default = "";
    description = ''
      Bus ID of the ${name} GPU. You can find it using lspci; for example if lspci
      shows the Intel GPU at "01:00.0", set this option to "PCI:1:0:0".
    '';
  };
in {

  options.modules.system.graphics = {

    enable = lib.mkEnableOption "graphics";

    manufacturer = lib.mkOption {
      description = "eg. AMD, Nvidia, Intel";
      default = "nvidia";
      type = lib.types.enum [
        "nvidia"
        "amdgpu"
        "intel"
      ];
    };

    prime = {
      enable = lib.mkEnableOption "PRIME";

      mode = lib.mkOption {
        description = "Choose offload, sync, or reverse sync mode";
        default = "sync";
        type = lib.types.enum [
          "offload"
          "sync"
          "reverseSync"
        ];
      };

      intelBusId = mkBusIDOption "Intel";
      nvidiaBusId = mkBusIDOption "NVIDIA";
      amdgpuBusId = mkBusIDOption "AMD";
    };

  };

  config = lib.mkIf enable (lib.mkMerge [

    { hardware.graphics.enable = true; }

    (lib.mkIf (cfg.manufacturer == "nvidia") {
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
      services.xserver.videoDrivers = lib.mkIf (cfg.manufacturer == "nvidia") [
        "nvidia"
      ];
      boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
    })

    (lib.mkIf cfg.prime.enable {
      assertions = [
        {
          assertion = cfg.prime.intelBusId != "";
          message = "You must provide the `intelBusId` when prime is enabled";
        }
        {
          assertion = (cfg.manufacturer != "nvidia") || (cfg.prime.nvidiaBusId != "");
          message = "You must provide the `nvidiaBusId` when prime is enabled for NVIDIA dGPU";
        }
        {
          assertion = (cfg.manufacturer != "amdgpu") || (cfg.prime.amdgpuBusId != "");
          message = "You must provide the `amdgpuBusId` when prime is enabled for AMD dGPU";
        }
      ];

      hardware.nvidia.prime = {
        intelBusId = cfg.prime.intelBusId;
        nvidiaBusId = lib.mkIf (cfg.manufacturer == "nvidia") cfg.prime.nvidiaBusId;
        amdgpuBusId = lib.mkIf (cfg.manufacturer == "amdgpu") cfg.prime.amdgpuBusId;

        offload = lib.mkIf (cfg.prime.mode == "offload") {
          enable = true;
          enableOffloadCmd = true;
        };

        sync.enable = cfg.prime.mode == "sync";

        reverseSync.enable = cfg.prime.mode == "reverseSync";
      };
    })

  ]);
}
