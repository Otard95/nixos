{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.television;
  enable = cfg.enable;
in {

  options.modules.term.television.enable = lib.mkEnableOption "television configuration";

  config = lib.mkIf enable {
    modules.term.fd.enable = lib.mkDefault true;

    programs.television = {
      enable = true;

      channels = {
        tldr = {
          metadata = {
            name = "tldr";
            description = "Browse and preview TLDR help pages";
            requirements = [ "tldr" ];
          };
          source.command = "${lib.getExe pkgs.tldr} --list";
          preview.command = "${lib.getExe pkgs.tldr} --color=always '{}'";
        };
        nix-pkgs = {
          metadata = {
            name = "nix-pkgs";
            description = "Browse nixpkgs";
            requirements = [ "nix" "jq" ];
          };
          source.command = ''
            nix search --json nixpkgs '.*' 2>/dev/null | jq -r 'keys | .[] | sub("legacyPackages.x86_64-linux.";"")'
          '';
          preview.command = ''
            nix search nixpkgs 'legacyPackages.x86_64-linux.{}' 2>/dev/null
          '';
          ui.preview_panel.size = 10;
          keybindings = {
            "ctrl-s" = "actions:shell";
            "ctrl-e" = "actions:execute";
          };
          actions = {
            shell = {
              description = "Starte a nix-shell with this package";
              command = "nix-shell -p {}";
              mode = "execute";
            };
            execute = {
              description = "Starte a nix-shell with this package";
              command = "nix-shell -p {} --run {}";
              mode = "execute";
            };
          };
        };
      };

      settings = {
        ui = {
          orientation = "portrait";
        };
      };
    };
  };

}
