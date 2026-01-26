{ config, lib, ... }:
let
  cfg = config.modules.term.opencode;
  enable = cfg.enable;
in {

  options.modules.term.opencode.enable = lib.mkEnableOption "opencode configuration";

  config = lib.mkIf enable {

    programs.opencode = {
      enable = true;

      settings = {
        theme = lib.mkForce "catppuccin-frappe-transparent";
      };

      themes = {
        catppuccin-frappe-transparent = import ./themes/catppuccin-frappe-transparent.nix;
      };

      commands = let
        fileNames = builtins.attrNames (builtins.readDir ./commands);
        files = map (name: {
          name = "${lib.strings.removeSuffix ".md" name}";
          value = builtins.readFile (lib.path.append ./commands "${name}");
        }) fileNames;
      in builtins.listToAttrs files;

      agents = let
        fileNames = builtins.attrNames (builtins.readDir ./agents);
        files = map (name: {
          name = "${lib.strings.removeSuffix ".md" name}";
          value = builtins.readFile (lib.path.append ./agents "${name}");
        }) fileNames;
      in builtins.listToAttrs files;

    };

  };

}
