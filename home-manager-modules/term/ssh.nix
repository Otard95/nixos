{ config, lib, ... }:
let
  cfg = config.modules.term.ssh;
  enable = cfg.enable;
in {
  options.modules.term.ssh.enable =
    lib.mkEnableOption "ssh";

  config = lib.mkIf enable {

    programs.ssh = {

      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        "gitea.core-lab.net" = {
          host = "gitea.core-lab.net";
          hostname = "gitea.internal";
          user = "git";
          port = 22;
        };
        jove = {
          host = "jove";
          hostname = "core-lab.net";
          user = "otard";
          port = 22;
        };
      };

    };

  };
}
