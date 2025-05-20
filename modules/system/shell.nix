{ config, lib, pkgs, ... }:
let
  cfg = config.modules.system.shell;
  enable = cfg.enable;
in {
  options.modules.system.shell = {
    enable = lib.mkEnableOption "shell";

    kind = lib.mkOption {
      description = "Select which shell to use";
      type = lib.types.enum [ "bash" "zsh" ];
      default = "bash";
    };
  };

  config = lib.mkIf enable (lib.mkMerge [
    (lib.mkIf (cfg.kind == "bash") { })
    (lib.mkIf (cfg.kind == "zsh") {
      programs.zsh.enable = true;
      users.defaultUserShell = pkgs.zsh;
    })
  ]);
}
