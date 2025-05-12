{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.wezterm;
  enable = cfg.enable;
in {
  options.modules.term.wezterm.enable =
    lib.mkEnableOption "wezterm";

  config = lib.mkIf enable {

    catppuccin.wezterm.enable = false;

    # Fucks with starship otherwise
    programs.bash.initExtra = lib.mkOrder 9999 ''
      source "${pkgs.wezterm}/etc/profile.d/wezterm.sh"
    '';

    xdg.configFile = let
      fileNames = builtins.attrNames (builtins.readDir ./.);
      entries = map (name: {
        name = "wezterm/${name}";
        value = { source = lib.path.append ./. "${name}"; };
      }) (builtins.filter (name: !(lib.strings.hasSuffix "nix" name)) fileNames);
      files = builtins.listToAttrs entries;
    in files;

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
        require('behaviour').apply_to_config(config)

        return config

      '';

    };
    
  };
}
