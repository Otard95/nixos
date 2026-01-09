{ config, lib, ... }:
let
  cfg = config.modules.system.graphics;
  enable = cfg.enable;

  busIDType = lib.types.strMatching "([[:print:]]+[\:\@][0-9]{1,3}\:[0-9]{1,2}\:[0-9])?";
  mkBusIDOption = name: lib.mkOption {
    type = busIDType;
    description = ''
      Bus ID of the ${name}. You can find it using lspci; for example if lspci
      shows this GPU at "01:00.0", set this option to "PCI:1:0:0".
      Use this to get the correct value:
      $ nix --experimental-features "flakes nix-command" run github:eclairevoyant/pcids
    '';
  };

  mkGpuOption = name: lib.mkOption {
    type = lib.types.nullOr (lib.types.submodule {
      options = {
        type = lib.mkOption {
          type = lib.types.enum [
            "nvidia"
            "amdgpu"
            "intel"
          ];
          description = "The type/manufacturer of the ${name}";
        };
        busId = mkBusIDOption name;
      };
    });
    default = null;
    description = "Options for the ${name}";
  };

  gpuTypes = []
    ++ lib.optional (cfg.iGPU != null) cfg.iGPU.type
    ++ lib.optional (cfg.dGPU != null) cfg.dGPU.type;
in {

  options.modules.system.graphics = {

    enable = lib.mkEnableOption "graphics";

    iGPU = mkGpuOption "iGPU";
    dGPU = mkGpuOption "dGPU";

    nvidia = {
      package = lib.mkOption {
        default = config.boot.kernelPackages.nvidiaPackages.stable;
        defaultText = lib.literalExpression "config.boot.kernelPackages.nvidiaPackages.stable";
        example = "config.boot.kernelPackages.nvidiaPackages.legacy_470";
        description = "The NVIDIA driver package to use.";
      };
      powerManagement = lib.mkOption {
        type = lib.types.enum [ "off" "on" "finegrained" ];
        default = "on";
        description = "What level of power management should we enable for the nvidia GPU.";
      };
      open = lib.mkEnableOption "NVidia open source kernel module" // { default = true; };

      prime = lib.mkOption {
        description = "Choose offload, sync, or reverse sync mode";
        default = "sync";
        type = lib.types.enum [
          "offload"
          "sync"
          "reverseSync"
        ];
      };
    };
  };

  config = lib.mkIf enable (lib.mkMerge [

    {
      hardware.graphics.enable = true;
      services.xserver.videoDrivers = builtins.filter (type: type != "intel") gpuTypes;
    }

    (lib.mkIf (builtins.elem "nvidia" gpuTypes) {
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = builtins.elem cfg.nvidia.powerManagement [ "on" "finegrained" ];
        open = cfg.nvidia.open;
        nvidiaSettings = true;
        package = cfg.nvidia.package;
      };
    })

    (lib.mkIf (builtins.elem "amdgpu" gpuTypes) {
      boot.kernelParams = [ "amdgpu.dc=1" "amdgpu.dpm=1" ];
    })

    (lib.mkIf (lib.length gpuTypes == 2 && builtins.elem "nvidia" gpuTypes) {
      assertions = [
        {
          assertion = cfg.dGPU.busId != "";
          message = "You must provide the `dGPU.busId` for the nvidia card when when you have multiple GPU's";
        }
        {
          assertion = cfg.iGPU.busId != "";
          message = "You must provide the `iGPU.busId` for the ${cfg.iGPU.type} card when when you have multiple GPU's";
        }
      ];

      hardware.nvidia = {
        powerManagement.finegrained = cfg.nvidia.powerManagement == "finegrained";

        prime = {
          nvidiaBusId = cfg.dGPU.busId;
          intelBusId = lib.mkIf (builtins.elem "intel" gpuTypes) cfg.iGPU.busId;
          amdgpuBusId = lib.mkIf (builtins.elem "amdgpu" gpuTypes) cfg.iGPU.busId;

          offload = lib.mkIf (cfg.nvidia.prime == "offload") {
            enable = true;
            enableOffloadCmd = true;
          };
          sync.enable = cfg.nvidia.prime == "sync";
          reverseSync.enable = cfg.nvidia.prime == "reverseSync";
        };
      };
    })

  ]);
}
