{ config, lib, pkgs, helpers, ... }:
let
  cfg = config.modules.term.bash;
  enable = cfg.enable;
in {

  options.modules.term.bash = {
    enable = lib.mkEnableOption "bash configuration";

    bindToSecret = lib.mkOption {
      description = ''
        Some commands require secrets in their environment, but you may not want
        to populate these secrets for you entire shell. This option allows you
        to create an alias (of the same name) to a command/program that adds
        these environment variables by loading them from a password-store entry.
      '';
      example = {
        gh = { GITHUB_TOKEN = "github/tokens/cli"; };
      };
      type = with lib.types; attrsOf (attrsOf str);
    };
  };

  config = lib.mkIf enable {
    programs.bash = {
      enable = true;

      shellAliases = {
        ls = "${pkgs.eza}/bin/eza";
        ll = "${pkgs.eza}/bin/eza -lah --git --icons";
        ".." = "cd ..";
      } // lib.mapAttrs (command: envs: let
          envStr = lib.concatStringsSep " " (lib.mapAttrsToList helpers.toShellVarRaw envs);
        in "pass-env ${envStr} ${command}"
      ) cfg.bindToSecret;

      historyControl = [
        "ignoreboth"
      ];

      bashrcExtra = ''
        set -o vi
      '';
    };
  };

}
