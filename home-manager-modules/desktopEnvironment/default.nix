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
          exec = helpers.mkOption.str "The command to execute on activation";
          inLock = helpers.mkOption.bool "If the keybind should work on the lockscreen" // { default = false; };
          release = helpers.mkOption.bool "Fires on release instead of press" // { default = false; };
        };
      });
    };

    background-image = helpers.mkOption.monitorBackground sources.images.background.falling-into-infinity;
    splash-image = helpers.mkOption.image "splash" // { default = sources.images.splash.spacegirl; };

    notifications.provider = (helpers.mkOption.enum
      "Notification provider to use"
      ["mako" "quickshell"]) // { default = "mako"; };
  };

  imports = [
    ./app-launcher
    ./hyprland
    ./kanshi
    ./power-menu
    ./quickshell
    ./theme
    ./mako.nix
    ./uwsm.nix
  ];

  config = lib.mkIf enable (lib.mkMerge [
    {
      # Disable portal here until this is fixed: https://github.com/nix-community/home-manager/issues/7124
      xdg.portal.enable = lib.mkForce false;
      modules.desktopEnvironment = {
        app-launcher = {
          enable = lib.mkDefault true;
          splash-image = cfg.splash-image;
        };
        power-menu = {
          enable = lib.mkDefault true;
          splash-image = cfg.splash-image;
        };
        # kanshi.enable = lib.mkDefault true;
        theme.enable = lib.mkDefault true;
      };
    }
    (lib.mkIf (cfg.windowManager == "hyprland") {
      modules.desktopEnvironment.hyprland = {
        enable = lib.mkDefault true;
        background-image = {
          horizontal = lib.mkDefault cfg.background-image.horizontal;
          vertical = lib.mkDefault cfg.background-image.vertical;
        };
      };
      wayland.windowManager.hyprland.extraConfig = let
        compileMods = mods: lib.concatStringsSep " + " (
          map
            (mod: if mod == "main" then "SUPER" else lib.toUpper mod)
            mods
        );
        escapeExec = cmd: builtins.replaceStrings [ ''"'' ] [ ''\"'' ] cmd;
        mkBind = bind:
          let
            key  = if (builtins.length bind.mods) > 0
              then "${compileMods bind.mods} + ${lib.toUpper bind.key}"
              else lib.toUpper bind.key;
            opts = with lib.attrsets; lib.generators.toLua { multiline = false; } (
              mapAttrs'
                (n: v: nameValuePair (if n == "inLock" then "locked" else n) v)
                (getAttrs [ "inLock" "release" ] bind)
            );
          in
          ''hl.bind("${key}", hl.dsp.exec_cmd("${escapeExec bind.exec}"), ${opts})'';
      in lib.concatStringsSep "\n" (
        map mkBind cfg.keybinds
      );
    })
    (lib.mkIf (cfg.notifications.provider == "mako") {
      modules.desktopEnvironment = {
        mako.enable = lib.mkDefault true;
        quickshell.notifications.backend = "mako";
      };
    })
    (lib.mkIf (cfg.notifications.provider == "quickshell") {
      assertions = [{
        assertion = config.modules.desktopEnvironment.quickshell.enable;
        message = "quickshell must be enabled to use it as a notifications provider";
      }];
      modules.desktopEnvironment.quickshell.notifications.backend = "native";
    })
  ]);
}
