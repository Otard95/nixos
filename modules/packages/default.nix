{ config, lib, ... }:
let
  cfg = config.modules.packages;
  enable = cfg.enable;
in {

  options.modules.packages.enable = lib.mkEnableOption "packages";

  imports = [
    ./apps
    ./btop.nix
    ./docker.nix
    ./fabric.nix
    ./kalker.nix
    ./numbat.nix
    ./notification.nix
    ./ollama.nix
    ./pangolin.nix
  ];

  config = lib.mkIf enable {
    programs.git = {
      enable = true;

      config = [
        {
          user = {
            email = "otard.code@proton.me";
            name = "Stian M";
          };
        }
        { init     = { defaultBranch = "main";                               }; }
        { merge    = { conflictstyle = "diff3";                              }; }
        { diff     = { colorMoved    = "default";                            }; }
        { pull     = { rebase        = true;                                 }; }
        { checkout = { defaultRemote = "origin";                             }; }
        { rerere   = { enable        = true;                                 }; }
      ];
    };

    modules.packages = {
      btop.enable     = lib.mkDefault true;
      numbat.enable   = lib.mkDefault true;
    };
  };
}
