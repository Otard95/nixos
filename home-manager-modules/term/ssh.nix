{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.ssh;
  enable = cfg.enable;
in {
  options.modules.term.ssh.enable =
    lib.mkEnableOption "ssh";

  config = lib.mkIf enable {

    programs.ssh = {

      enable = true;

      matchBlocks = {
        home = {
          host = "home";
          hostname = "ssh.core-lab.net";
          user = "otard";
          port = 22;
          proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
        };
        pi = {
          host = "pi";
          hostname = "raspberrypi.core-lab.net";
          user = "otard";
          port = 22;
          proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
        };
      };

    };

  };
}
