{ config, lib, sources, helpers, ... }:
let
  cfg = config.modules.desktopEnvironment;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment = {
    enable = lib.mkEnableOption "Desktop Environment";

    windowManager = lib.mkOption {
      default = "hyprland";
      description = "Select a WM to use";
      type = lib.types.enum [
        "hyprland"
      ];
    };

    keybinds = lib.mkOption {
      description = "A list of keybinds the window manager should assign";
      default = [];
      type = with lib.types; listOf (submodule {
        options = {
          key = lib.mkOption {
            description = "The key to press to activate the keybind";
            type = str;
          };
          mods = lib.mkOption {
            default = [];
            description = "If the modifier keys that needs to be pressed.";
            example = [ "ctrl" "alt" ];
            type = listOf (enum [ "ctrl" "shift" "alt" "super" "main" ]);
          };
          exec = lib.mkOption {
            description = "The command to execute on activation";
            type = str;
          };
          inLock = lib.mkOption {
            default = false;
            description = "If the keybind should work on the lockscreen";
            type = bool;
          };
        };
      });
    };

    background-image = helpers.mkOption.image "background" // { default = sources.images.background.falling-into-infinity; };
    splash-image = helpers.mkOption.image "splash" // { default = sources.images.splash.spacegirl; };
  };

  imports = [
    ./app-launcher
    ./hyprland
    ./kanshi
    ./power-menu
    ./theme
    ./mako.nix
    ./uwsm.nix
  ];

  config = lib.mkIf enable (lib.mkMerge [
    {
      modules.desktopEnvironment = {
        app-launcher = {
          enable = lib.mkDefault true;
          splash-image = cfg.splash-image;
        };
        power-menu = {
          enable = lib.mkDefault true;
          splash-image = cfg.splash-image;
        };
        kanshi.enable = lib.mkDefault true;
        theme.enable = lib.mkDefault true;
        mako.enable = lib.mkDefault true;
      };
    }
    (lib.mkIf (cfg.windowManager == "hyprland") {
      modules.desktopEnvironment.hyprland = {
        enable = lib.mkDefault true;
        background-image = cfg.background-image;
      };
      wayland.windowManager.hyprland.settings = let
        compileMods = mods: builtins.concatStringsSep "+" (
          builtins.map
          (mod: if mod == "main" then "$mod" else lib.toUpper mod)
          mods
        );
      in {
        bind = builtins.map
          (bind: (compileMods bind.mods) + ", ${lib.toUpper bind.key}, exec, ${bind.exec}")
          (builtins.filter (bind: !bind.inLock) cfg.keybinds);
        bindl = builtins.map
          (bind: (compileMods bind.mods) + ", ${lib.toUpper bind.key}, exec, ${bind.exec}")
          (builtins.filter (bind: bind.inLock) cfg.keybinds);
      };
    })
  ]);
}
