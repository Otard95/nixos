{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktopEnvironment.hyprland.wm;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.hyprland.wm = {
    enable = lib.mkEnableOption "hyprland configuration";
  };

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      hyprcursor
    ];

    catppuccin.hyprland.enable = true;

    modules.desktopEnvironment.uwsm = {
      enable = true;

      envs = [
        { name = "WLR_NO_HARDWARE_CURSORS"; value = "1"; }
        { name = "SLURP_ARGS";              value = "-d -b 16897a44 -c 04d6c8 -B 0e999e22"; }
        { name = "GRIMBLAST_EDITOR";        value = "pinta"; }
      ];
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;

      configType = "lua";

      extraLuaFiles = {
        "lua/config"                = { content = ./lua/config.lua; autoLoad = false; };
        "lua/binds"                 = { content = ./lua/binds.lua;  autoLoad = false; };
        "lua/rules"                 = { content = ./lua/rules.lua;  autoLoad = false; };
        "lua/monitors"              = { content = ./lua/monitors.lua;  autoLoad = false; };
        "lua/utils/debounce-queue"  = { content = ./lua/utils/debounce-queue.lua;  autoLoad = false; };
      };

      extraConfig = ''
        require("lua.config").setup()
        require("lua.binds").setup({
          terminal = "${config.modules.term.defaultTerminal}",
          wl_paste  = "${pkgs.wl-clipboard}/bin/wl-paste",
        })
        require("lua.rules").setup()
        require("lua.monitors").setup()
      '';

    };

    xdg.configFile."hypr/xdph.conf".text = ''
      screencopy {
        allow_token_by_default = true
      }
    '';

  };
}
