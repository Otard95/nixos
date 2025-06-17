{ config, lib, ... }:
let
  cfg = config.modules.term.scripts;
  enable = cfg.enable;
in {
  options.modules.term.scripts.enable =
    lib.mkEnableOption "scripts";

  imports = [
    ./fabric
  ];

  config = lib.mkIf enable {

    home = {

      sessionPath = [ "$HOME/scripts" ];

      file = let
        fileNames = builtins.attrNames (builtins.readDir ./.);
        files = map (name: {
          name = "scripts/${name}";
          value = { executable = true; source = lib.path.append ./. "${name}"; };
        }) (builtins.filter (name: lib.strings.hasSuffix "sh" name) fileNames);
        scripts = builtins.listToAttrs files;
      in scripts;

    };

  };
}
