{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.wezterm;
  enable = cfg.enable;
in {
  options.modules.term.wezterm.enable =
    lib.mkEnableOption "wezterm";

  config = lib.mkIf enable {

    catppuccin.wezterm.enable = false;

    programs.bash.initExtra = lib.mkOrder 9999 ''
      source "${pkgs.wezterm}/etc/profile.d/wezterm.sh"
    '';

    programs.wezterm = {

      enable = true;
      enableBashIntegration = false;

      extraConfig = ''

        -- Config object: https://wezterm.org/config/files.html
        --   The `require 'wezterm'` is provided by nix automatically
        local config = wezterm.config_builder()

        -- Lua Modules: https://wezterm.org/config/files.html#making-your-own-lua-modules
        require('mux').apply_to_config(config)
        require('theme').apply_to_config(config)
        require('keys').apply_to_config(config)

        return config

      '';

    };
    
  };
}
