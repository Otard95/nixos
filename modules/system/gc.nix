{ config, lib, ... }:
let
  cfg = config.modules.system.gc;
  enable = cfg.enable;
in {

  options.modules.system.gc = {
    enable = lib.mkEnableOption "garbage collection";
    interval = lib.mkOption {
      description = "How often to do garbage collection";
      default = "weekly";
      type = lib.types.singleLineStr;
    };
    olderThan = lib.mkOption {
      description = "Remove only generations older than this";
      default = "14d";
      type = lib.types.singleLineStr;
    };
  };

  config = lib.mkIf enable {
    # Optimize storage and automatic scheduled GC running
    # If you want to run GC manually, use commands:
    # `nix-store --optimize` for finding and eliminating redundant copies of identical store paths
    # `nix-store --gc` for optimizing the nix store and removing unreferenced and obsolete store paths
    # `nix-collect-garbage -d` for deleting old generations of user profiles
    nix.settings.auto-optimise-store = true;
    nix.optimise.automatic = true;
    nix.gc = {
      automatic = true;
      dates = cfg.interval;
      options = "--delete-older-than ${cfg.olderThan}";
    };
  };
}
