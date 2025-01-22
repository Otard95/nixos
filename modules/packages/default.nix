{ config, lib, ... }:
let
  cfg = config.modules.packages;
  enable = cfg.enable;
in {

  options.modules.packages.enable = lib.mkEnableOption "packages";

  imports = [
    ./apps
    ./btop.nix
    ./notification.nix
    ./quickemu.nix
    ./docker.nix
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
        { core = { sshCommand = "ssh -i /home/otard/.ssh/id_ed25519"; }; }
      ];
    };

    modules.packages = {
      btop.enable = lib.mkDefault true;
      quickemu.enable = lib.mkDefault true;
    };
  };
}
