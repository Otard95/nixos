{ config, lib, sources, ... }:
let
  cfg = config.modules.desktopEnvironment;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment = let
    imageOption = name: defaultImage: lib.mkOption {
      description = "Path to the ${name} image to use";
      type = lib.types.path;
      default = defaultImage;
    };
  in {
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

    background-image = imageOption "background" sources.images.background.falling-into-infinity;
    splash-image = imageOption "splash" sources.images.splash.spacegirl;
  };

  imports = [
    ./app-launcher
    ./hyprland
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
