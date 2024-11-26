{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages;
  enable = cfg.enable;
in {

  options.modules.packages.enable = lib.mkEnableOption "packages";

  imports = [
    ./notification.nix
    ./apps
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
        { init = { defaultBranch = "main"; }; }
        { merge = { conflictstyle = "diff3"; }; }
        { diff = { colorMoved = "default"; }; }
        { pull = { rebase = true; }; }
        { checkout = { defaultRemote = "origin"; }; }
        { rerere = { enable = true; }; }
      ];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [];
  };
}
