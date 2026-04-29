{ config, lib, ... }:
let
  cfg = config.modules.term.ssh;
  enable = cfg.enable;

  personal_identity_files = [
    "~/.ssh/id_ed25519_sk_rk_yubikey_personal_primary"
    "~/.ssh/id_ed25519_sk_rk_yubikey_personal_secondary"
  ];
  work_identity_files = [
    "~/.ssh/id_ed25519_sk_rk_yubikey_work_primary"
    "~/.ssh/id_ed25519_sk_rk_yubikey_work_secondary"
  ];
in {
  options.modules.term.ssh = {
    enable = lib.mkEnableOption "ssh";

    identity-preset = lib.mkOption {
      description = "Identity file preset";
      type = lib.types.enum [ "personal" "work" ];
      default = "personal";
    };
  };

  config = lib.mkIf enable {

    programs.ssh = {

      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        "*" = {
          host = "*";
          identityFile = if cfg.identity-preset == "personal"
             then personal_identity_files
             else work_identity_files;
        };
        "gitea.core-lab.net" = {
          host = "gitea.core-lab.net";
          hostname = "gitea.internal";
          user = "git";
          port = 22;
          identityFile = personal_identity_files;
        };
        jove = {
          host = "jove";
          hostname = "core-lab.net";
          user = "otard";
          port = 22;
          identityFile = personal_identity_files;
          forwardAgent = true;
        };
        luna = {
          host = "luna";
          hostname = "luna-ssh.internal";
          user = "otard";
          port = 22;
          identityFile = personal_identity_files;
          forwardAgent = true;
        };
      };

    };

  };
}
