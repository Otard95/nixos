{ config, lib, helpers, ... }:
let
  cfg = config.modules.packages.obsidian;
  enable = cfg.enable;

  mkOption = helpers.mkOption;
in {
  options.modules.packages.obsidian = {
    enable = lib.mkEnableOption "obsidian";

    vaults = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = mkOption.str "Vault name.";
          path = mkOption.str "Path relative to user home of the vault (defaults to `name` option)."; 
          settings = mkOption.any "The vaults settings.";
        };
      });
      default = [];
      description = "List of vaults to create.";
    };
  };

  config = lib.mkIf enable {
    # TODO: Enable when home-manager module hits stable
    # programs.obsidian = {
    #   enable = true;

    #   programs.obsidian.vaults = lib.mkMerge (builtins.map ({name, path, settings}: {
    #     "${name}" = {
    #       enable = true;
    #       target = lib.mkIf (path != null) path;
    #       settings = lib.mkIf (settings != null) settings;
    #     };
    #   }) cfg.vaults);
    # };
  };
}
