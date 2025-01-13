{ config, lib, ... }:
let
  cfg = config.modules.term.direnv;
  enable = cfg.enable;
in {
  options.modules.term.direnv.enable =
    lib.mkEnableOption "direnv";

  config = lib.mkIf enable {

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;

      silent = true;

      stdlib = ''
        # Example: export_alias zz "ls -la"
        export_alias() {
          local name=$1
          shift
          local alias_dir=$PWD/.direnv/aliases
          local target="$alias_dir/$name"
          mkdir -p "$alias_dir"
          PATH_add "$alias_dir"
          echo "#!/usr/bin/env bash" > "$target"
          echo "$@ \"\$@\"" >> "$target"
          chmod +x "$target"
        }
      '';
    };

  };
}
